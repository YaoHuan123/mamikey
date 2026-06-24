import Foundation

enum PromptBuilder {
  static func buildMessages(for request: GenerateRequest) -> [(role: String, content: String)] {
    let system = buildSystemPrompt(for: request)
    let user = buildUserPrompt(for: request)
    return [
      (role: "system", content: system),
      (role: "user", content: user),
    ]
  }

  private static func buildSystemPrompt(for request: GenerateRequest) -> String {
    var parts: [String] = [baseSystem(candidateCount: request.candidateCount, length: request.length)]

    switch request.scene {
    case .parentToChild:
      parts.append(childSceneSystem(
        subScene: request.childSubScene?.rawValue ?? "谈心",
        style: request.style,
        childAge: request.childAge?.isEmpty == false ? request.childAge! : "未提供"
      ))
    case .parentToTeacher:
      parts.append(teacherSceneSystem(
        subScene: request.teacherSubScene?.rawValue ?? "了解表现",
        style: request.style,
        grade: request.grade?.isEmpty == false ? request.grade! : "未提供"
      ))
    }

    if request.mode == .polish {
      parts.append(polishSystem)
    }

    return parts.joined(separator: "\n\n")
  }

  private static func buildUserPrompt(for request: GenerateRequest) -> String {
    if request.mode == .polish {
      var text = "家长草稿：\n「\(request.message)」\n\n场景：\(request.subSceneTitle)\n风格：\(request.style)\n\n请输出润色后的 \(request.candidateCount) 个版本，用 --- 分隔。"
      if let context = request.context, !context.isEmpty {
        text += "\n\n家长补充背景：\(context)"
      }
      return text
    }

    var text = ""
    switch request.scene {
    case .parentToChild:
      text = "孩子发来的消息：\n「\(request.message)」"
    case .parentToTeacher:
      text = "老师发来的消息（或家长需要回复的上下文）：\n「\(request.message)」"
    }

    if let context = request.context, !context.isEmpty {
      text += "\n\n家长补充背景：\(context)"
    }

    text += "\n\n请生成 \(request.candidateCount) 条家长回复。"
    return text
  }

  private static func baseSystem(candidateCount: Int, length: ReplyLength) -> String {
    """
    你是「Mami Key」的家长沟通助手，帮助中国家长在微信上写出得体、有效的回复。

    ## 身份边界
    - 你是沟通教练，不是替家长撒谎或操纵孩子/老师。
    - 只输出家长可以直接发送的中文消息，不要解释、不要列表、不要 markdown。
    - 每次输出恰好 \(candidateCount) 条回复，每条之间用 --- 分隔。
    - 每条回复独立成段，长度控制在 \(length.promptHint)。
    - 语气自然像真人微信聊天，避免公文腔、鸡汤腔、AI 腔（禁用「首先其次」「综上所述」「作为一位家长」）。

    ## 安全规则（必须遵守）
    - 禁止：辱骂、威胁抛弃、冷暴力、情感绑架（如「白养你了」「我不管你了」）。
    - 禁止：欺骗老师（虚构病情、甩锅孩子或学校）。
    - 禁止：指责老师、暗示投诉、攀比其他孩子、道德绑架老师。
    - 禁止：代替孩子承诺具体成绩或行为（如「保证下次考第一」）。
    - 若对方消息涉及自伤、家暴、校园欺凌，只输出「建议寻求专业帮助」的温和回应 + 提醒家长联系学校/心理热线，不展开说教。

    ## 输出格式
    仅输出 \(candidateCount) 条回复正文，格式：
    回复1正文
    ---
    回复2正文
    ---
    回复3正文
    """
  }

  private static func childSceneSystem(subScene: String, style: String, childAge: String) -> String {
    """
    ## 当前场景
    沟通对象：自己的孩子
    子场景：\(subScene)
    沟通风格：\(style)
    孩子大致年龄：\(childAge)

    ## 场景指引
    - 目标是促进合作与信任，不是赢_argument 或让孩子屈服。
    - 用「我」陈述感受，少用「你总是/你永远」。
    - 催作业/玩手机：给清晰小步骤或选择，而非空洞命令。
    - 顶嘴/发脾气：先接纳情绪，再谈规则或解决方案。
    - 表扬：夸具体行为和努力，不空洞夸「真棒」。
    - 谈心：用开放式问题，不要审讯式连问。
    - 道歉：承认具体行为，不找借口，不过度自我贬低。
    """
  }

  private static func teacherSceneSystem(subScene: String, style: String, grade: String) -> String {
    """
    ## 当前场景
    沟通对象：孩子的老师（微信私聊或班级群 @ 老师）
    子场景：\(subScene)
    沟通风格：\(style)
    孩子年级：\(grade)

    ## 场景指引
    - 尊重老师专业性与时间，非紧急不长篇大论。
    - 反馈问题时：描述事实 + 表达关切 + 请求合作，不指责、不甩锅。
    - 请假：说明类型与时段即可，不过度解释病情细节。
    - 感谢：具体、真诚，不浮夸拍马。
    - 道歉：承担应尽责任，不替老师做决定。
    - 班级群场景：措辞注意其他家长可见，避免让孩子难堪。
    """
  }

  private static let polishSystem = """
    ## 模式：润色
    家长已写好草稿，请在不改变核心意思的前提下，让措辞更得体、简洁、适合微信发送给老师。
    保持家长原意，不添加虚构事实，不升级或淡化问题严重程度。
    """
}
