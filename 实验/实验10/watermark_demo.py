# watermark_demo.py
# 复现论文: "A Watermark for Large Language Models" (Kirchenbauer et al., ICML 2023)
# 算法: Red-Green List Watermark

import os
import torch
import scipy.stats
from transformers import AutoTokenizer, AutoModelForCausalLM, LogitsProcessor

# ============================================================
# 设置 HuggingFace 镜像（国内加速，不需要可删掉）
os.environ["HF_ENDPOINT"] = "https://hf-mirror.com"
# ============================================================


# ───────────────────────────────────────────────
# 核心类 1: 水印嵌入 —— 在生成时偏置 logits
# ───────────────────────────────────────────────
class WatermarkLogitsProcessor(LogitsProcessor):
    """
    论文 Section 2.2: Soft Watermark
    
    原理: 每次生成第 i 个 token 前:
      1. 用第 i-1 个 token 作为随机种子
      2. 将整个词表随机分成绿名单(50%)和红名单(50%)
      3. 给绿名单 token 的 logit 加上偏置 delta
      => 模型会更倾向于选绿名单 token
      => 但因为种子是上下文决定的，外人不知道当前绿名单是什么
    """

    def __init__(self, vocab_size: int, gamma: float = 0.5, delta: float = 2.0, seeding_scheme: str = "simple"):
        """
        vocab_size: 词表大小
        gamma:      绿名单比例，论文默认 0.5（即一半 token 是绿色）
        delta:      加在绿名单 logits 上的偏置值，越大水印越强但越影响质量
        seeding_scheme: 用哪个 token 做种子，"simple" = 用前一个 token
        """
        self.vocab_size = vocab_size
        self.gamma = gamma
        self.delta = delta
        self.seeding_scheme = seeding_scheme
        self.rng = torch.Generator()  # 可复现的随机数生成器

    def _get_greenlist(self, prev_token_id: int) -> torch.Tensor:
        """
        根据前一个 token 的 id，生成当前位置的绿名单（token id 列表）
        
        关键：相同的 prev_token_id 永远生成相同的绿名单
             这样检测时可以复现，而攻击者不知道 secret key
        """
        # 用 prev_token_id 设置随机种子（实际上 secret key 应该混入这里）
        self.rng.manual_seed(prev_token_id)
        
        # 从词表里随机排列，取前 gamma 比例作为绿名单
        vocab_perm = torch.randperm(self.vocab_size, generator=self.rng)
        greenlist_size = int(self.vocab_size * self.gamma)
        greenlist = vocab_perm[:greenlist_size]
        return greenlist

    def __call__(self, input_ids: torch.LongTensor, scores: torch.FloatTensor) -> torch.FloatTensor:
        """
        HuggingFace 的 LogitsProcessor 接口
        每次生成新 token 前都会调用这个函数
        
        input_ids: 已生成的所有 token ids, shape: (batch_size, seq_len)
        scores:    当前 token 的 logits,   shape: (batch_size, vocab_size)
        """
        for batch_idx in range(input_ids.shape[0]):
            # 取序列中最后一个 token 作为种子（即论文中的 context window = 1）
            prev_token = input_ids[batch_idx, -1].item()
            
            # 获取绿名单
            greenlist = self._get_greenlist(prev_token)
            
            # 给绿名单 token 的 logits 加上 delta 偏置
            scores[batch_idx, greenlist] += self.delta
        
        return scores


# ───────────────────────────────────────────────
# 核心类 2: 水印检测 —— 统计检验
# ───────────────────────────────────────────────
class WatermarkDetector:
    """
    论文 Section 2.3: Detection via Hypothesis Testing
    
    原理: 对每个 token，检查它是否在当时的绿名单里
         如果文本有水印，绿名单 token 比例会显著 > gamma (= 0.5)
         用 z-test 检验这个假设
    
    H0（无水印）: 绿名单 token 比例 ≈ gamma（随机）
    H1（有水印）: 绿名单 token 比例 >> gamma
    
    z = (观察到的绿token数 - 期望绿token数) / 标准差
      = (|s_G| - gamma * T) / sqrt(T * gamma * (1-gamma))
    """

    def __init__(self, tokenizer, vocab_size: int, gamma: float = 0.5, delta: float = 2.0, z_threshold: float = 4.0):
        self.tokenizer = tokenizer
        self.vocab_size = vocab_size
        self.gamma = gamma
        self.delta = delta
        self.z_threshold = z_threshold  # z > 4.0 则判定有水印
        self.rng = torch.Generator()

    def _get_greenlist(self, prev_token_id: int) -> set:
        """与 Processor 里完全一样的绿名单生成逻辑（必须一致！）"""
        self.rng.manual_seed(prev_token_id)
        vocab_perm = torch.randperm(self.vocab_size, generator=self.rng)
        greenlist_size = int(self.vocab_size * self.gamma)
        return set(vocab_perm[:greenlist_size].tolist())

    def detect(self, text: str) -> dict:
        """
        对输入文本计算 z-score，返回检测结果
        """
        # 将文本 tokenize
        tokens = self.tokenizer.encode(text, return_tensors="pt")[0]
        
        T = len(tokens) - 1  # 有效 token 数（第一个 token 没有前驱，跳过）
        if T <= 0:
            return {"z_score": 0.0, "is_watermarked": False, "green_count": 0, "total": 0}

        green_count = 0  # 落在绿名单里的 token 数量

        for i in range(1, len(tokens)):
            prev_token = tokens[i - 1].item()
            curr_token = tokens[i].item()
            
            greenlist = self._get_greenlist(prev_token)
            if curr_token in greenlist:
                green_count += 1

        # z-score 公式（论文 Eq. 5）
        # z = (|s_G| - gamma * T) / sqrt(T * gamma * (1-gamma))
        expected = self.gamma * T
        std = (T * self.gamma * (1 - self.gamma)) ** 0.5
        z_score = (green_count - expected) / std

        # 对应的 p-value（单侧检验）
        p_value = scipy.stats.norm.sf(z_score)  # P(Z > z_score)

        return {
            "z_score": round(z_score, 4),
            "p_value": round(p_value, 6),
            "is_watermarked": z_score > self.z_threshold,
            "green_count": green_count,
            "total_tokens": T,
            "green_ratio": round(green_count / T, 4),
        }


# ───────────────────────────────────────────────
# 主流程
# ───────────────────────────────────────────────
def main():
    print("=" * 60)
    print("Loading GPT-2 model and tokenizer...")
    print("=" * 60)

    model_name = "gpt2"
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(model_name)
    model.eval()

    vocab_size = tokenizer.vocab_size  # GPT-2 = 50257

    # 初始化水印处理器和检测器（参数必须一致）
    GAMMA = 0.25   # 绿名单占词表 25%（更容易检测，偏置更明显）
    DELTA = 2.0    # logit 偏置强度
    Z_THRESH = 4.0 # z-score 判断阈值

    processor = WatermarkLogitsProcessor(vocab_size, gamma=GAMMA, delta=DELTA)
    detector  = WatermarkDetector(tokenizer, vocab_size, gamma=GAMMA, delta=DELTA, z_threshold=Z_THRESH)

    # 输入 prompt
    prompt = "The history of artificial intelligence is a story of"
    input_ids = tokenizer.encode(prompt, return_tensors="pt")

    print(f"\nPrompt: {prompt}\n")

    # ── 生成1: 无水印（正常生成）──
    print("Generating text WITHOUT watermark...")
    with torch.no_grad():
        output_no_wm = model.generate(
            input_ids,
            max_new_tokens=200,
            do_sample=True,
            temperature=0.7,
        )
    text_no_wm = tokenizer.decode(output_no_wm[0], skip_special_tokens=True)
    # 只保留生成的新部分（去掉 prompt）
    text_no_wm_gen = tokenizer.decode(output_no_wm[0][input_ids.shape[1]:], skip_special_tokens=True)

    # ── 生成2: 有水印 ──
    print("Generating text WITH watermark...")
    with torch.no_grad():
        output_wm = model.generate(
            input_ids,
            max_new_tokens=200,
            do_sample=True,
            temperature=0.7,
            logits_processor=[processor],  # 👈 只需加这一行！
        )
    text_wm_gen = tokenizer.decode(output_wm[0][input_ids.shape[1]:], skip_special_tokens=True)

    # ── 打印生成结果 ──
    print("\n" + "=" * 60)
    print("【无水印文本】")
    print(text_no_wm_gen)
    print("\n【有水印文本】")
    print(text_wm_gen)

    # ── 检测 ──
    print("\n" + "=" * 60)
    print("DETECTION RESULTS")
    print("=" * 60)

    result_no_wm = detector.detect(text_no_wm_gen)
    result_wm    = detector.detect(text_wm_gen)

    print(f"\n[无水印文本检测]")
    print(f"  Green token 比例 : {result_no_wm['green_ratio']} (期望 ≈ {GAMMA})")
    print(f"  z-score          : {result_no_wm['z_score']}")
    print(f"  p-value          : {result_no_wm['p_value']}")
    print(f"  判定结果          : {'⚠️  有水印' if result_no_wm['is_watermarked'] else '✅ 无水印'}")

    print(f"\n[有水印文本检测]")
    print(f"  Green token 比例 : {result_wm['green_ratio']} (期望 ≈ {GAMMA})")
    print(f"  z-score          : {result_wm['z_score']}")
    print(f"  p-value          : {result_wm['p_value']}")
    print(f"  判定结果          : {'⚠️  有水印' if result_wm['is_watermarked'] else '✅ 无水印'}")

    print("\n" + "=" * 60)
    print(f"z-score 阈值 = {Z_THRESH}")
    print(f"z > {Z_THRESH} => 判定为有水印")


if __name__ == "__main__":
    main()