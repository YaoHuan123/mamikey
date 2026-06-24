# Mami Key TODO

> 产品：家长沟通 AI 键盘（形态对齐 LoveKey / 蜜语）  
> 当前阶段：**iOS MVP v0.1**  
> 场景范围：家长对孩子、家长对老师

---

## 文档（已完成）

- [x] README 产品定位
- [x] `docs/MVP.md` 功能清单
- [x] `docs/prompts.md` Prompt 模板与示例

---

## iOS MVP v0.1（进行中）

### 项目骨架
- [x] Xcode 工程 `ios/MamiKey.xcodeproj`
- [x] 主 App Target `MamiKey`
- [x] 键盘扩展 Target `MamiKeyKeyboard`
- [x] 共享代码 `MamiKeyShared`
- [x] App Group `group.io.github.YaoHuan123.mami-key`

### 共享层（MamiKeyShared）
- [x] 场景 / 子场景 / 风格模型
- [x] PromptBuilder（对接 `docs/prompts.md`）
- [x] GenerateService（OpenAI 兼容 API + Mock 降级）
- [x] QuotaManager（每日 5 次免费额度）
- [x] HistoryStore（本地最近 20 条）
- [x] SharedSettings（API 配置、App Group 读写）
- [x] SensitiveWordFilter（基础敏感词过滤）

### 键盘扩展（MamiKeyKeyboard）
- [x] KeyboardViewController + SwiftUI 根视图
- [x] 剪贴板自动读取对方消息
- [x] 场景 Tab：对孩子 / 对老师
- [x] 子场景 Chip 选择
- [x] 风格选择
- [x] 可选背景补充
- [x] 生成 3 条候选回复
- [x] 点击候选插入到输入框
- [x] 额度用尽提示
- [ ] 真机测试：微信内切换键盘
- [ ] 开启「允许完全访问」引导优化

### Codemagic 打包（参考 hello me）
- [x] `codemagic.yaml`（TestFlight 自动上传）
- [x] `scripts/codemagic-prebuild.sh`
- [x] `docs/codemagic.md` 签名与上架说明
- [ ] Apple Developer 创建 App ID ×2 + App Group
- [ ] Codemagic 上传描述文件 `mamikey-appstore` / `mamikey-keyboard-appstore`
- [x] Git 仓库 `git@github.com:YaoHuan123/mamikey.git` + `ios` 分支已推送

### 主 App（MamiKey）
- [x] 键盘安装引导页
- [x] API 设置（Base URL、API Key、Model）
- [x] 使用 Mock 模式开关（无 Key 时可演示）
- [x] 生成历史列表
- [ ] StoreKit 订阅（月卡 / 年卡）
- [ ] 隐私政策与用户协议页

### 后端（可选，v0.2）
- [ ] `POST /generate` 服务端代理（隐藏 API Key）
- [ ] 用量统计与订阅校验
- [ ] 敏感词服务端二次过滤

---

## iOS v0.2 计划

- [ ] 润色模式（家长草稿 → 得体回复）
- [ ] 回复长度：短 / 中
- [ ] 再生成（换一批）
- [ ] 对孩子 / 对老师默认 Tab 记忆
- [ ] 埋点：场景分布、生成成功率、付费转化

---

## Android（未开始）

- [ ] 输入法 IME 工程
- [ ] 与 iOS 共用 API 契约
- [ ] 对标 iOS v0.1 功能集

---

## 验收清单（iOS v0.1 上线前）

参考 `docs/prompts.md` 第六节 12 条人工评测用例。

- [ ] 12 条场景回复质量人工通过
- [ ] 键盘在微信中可切换、可插入文本
- [ ] 无 API Key 时 Mock 模式可完整演示
- [ ] 免费额度扣减与重置正确
- [ ] 无辱骂 / 威胁 / 甩锅类输出（抽检）

---

## 当前阻塞 / 备注

- iOS 键盘调用网络 API 需用户开启「允许完全访问」
- 本地调试：macOS + Xcode 15+；**CI 打包：Codemagic（push `ios` 分支）**
- Windows 环境无法本地编译，可用 Codemagic 或 Mac 构建
