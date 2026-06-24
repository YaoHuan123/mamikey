import Foundation

public enum GenerateError: LocalizedError {
  case quotaExceeded
  case emptyMessage
  case network(String)
  case parseFailed
  case allFiltered

  public var errorDescription: String? {
    switch self {
    case .quotaExceeded:
      return "今日免费次数已用完，请在主 App 开通订阅或明日再试。"
    case .emptyMessage:
      return "请先复制对方的消息，或输入要回复的内容。"
    case .network(let message):
      return "生成失败：\(message)"
    case .parseFailed:
      return "未能解析 AI 回复，请重试。"
    case .allFiltered:
      return "生成内容未通过安全过滤，请重试。"
    }
  }
}

public enum GenerateService {
  public static func generate(_ request: GenerateRequest) async throws -> [String] {
    let trimmed = request.message.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { throw GenerateError.emptyMessage }
    guard QuotaManager.canGenerate else { throw GenerateError.quotaExceeded }

    let replies: [String]
    if SharedSettings.useMockMode {
      replies = MockGenerateService.generate(for: request)
    } else {
      replies = try await APIGenerateService.generate(for: request)
    }

    let safe = SensitiveWordFilter.filter(replies)
    guard !safe.isEmpty else { throw GenerateError.allFiltered }

    _ = QuotaManager.consumeOne()

    let entry = HistoryEntry(
      scene: request.scene,
      subScene: request.subSceneTitle,
      inputMessage: trimmed,
      replies: safe
    )
    HistoryStore.append(entry)

    return Array(safe.prefix(request.candidateCount))
  }

  static func parseReplies(from content: String) -> [String] {
    content
      .components(separatedBy: "---")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
  }
}

enum MockGenerateService {
  static func generate(for request: GenerateRequest) -> [String] {
    switch request.scene {
    case .parentToChild:
      return childMocks(for: request)
    case .parentToTeacher:
      return teacherMocks(for: request)
    }
  }

  private static func childMocks(for request: GenerateRequest) -> [String] {
    switch request.childSubScene {
    case .homework:
      return [
        "我知道写作业很烦，拖久了明天更赶。咱们先写语文这一科，25分钟写完你可以休息一会。",
        "作业多确实头疼。我们先做最简单的三道，做完告诉我，我陪你对一下。",
        "不想写很正常，但明天要交。现在写15分钟，写不完的部分我们一起想办法。",
      ]
    case .screenTime:
      return [
        "可以，再玩十分钟。十分钟后你自己放下，我们说到做到。",
        "我知道你还没玩够。咱们约定最后十分钟，闹钟响了就休息，好吗？",
        "今天已经玩了一会儿了。再给你十分钟收尾，然后我们去洗漱准备睡觉。",
      ]
    case .talkingBack:
      return [
        "听起来你现在很生气。我不是要跟你吵，只是想听听到底怎么了。",
        "你这么冲我理解你心情不好。我们先把火气放一放，你冷静了我再跟你聊。",
        "你说我不懂，也许确实有些地方我没做好。你愿意告诉我是哪件事吗？",
      ]
    case .praise:
      return [
        "真不错！你这段时间的努力看得见，继续加油。",
        "太厉害了！你自己复习得很认真吧？妈妈为你高兴。",
        "全对真不容易。今晚奖励你选个喜欢的睡前故事。",
      ]
    case .chat:
      return [
        "今天在学校有什么开心或烦心的事吗？我想听听。",
        "最近和同学相处怎么样？有什么想跟我聊聊的？",
        "这周有什么新鲜事？不用紧张，随便说说就好。",
      ]
    case .apology:
      return [
        "刚才妈妈声音太大了，对不起。我不该那样说你，我们好好聊聊好吗？",
        "对不起，刚才我态度不好。我在乎你，只是没控制好情绪。",
        "妈妈向你道歉。我不该冲动，你愿意原谅我吗？",
      ]
    case .none:
      return ["我在听，你愿意多说一点吗？", "没关系，我们慢慢聊。", "不管怎样，妈妈都爱你。"]
    }
  }

  private static func teacherMocks(for request: GenerateRequest) -> [String] {
    switch request.teacherSubScene {
    case .leave:
      return [
        "老师好，我家孩子明天请病假一天，去医院看一下，谢谢老师。",
        "老师您好，孩子明天因病请假，预计休息一天，麻烦老师了。",
        "老师好，明天孩子请假，到校后我会让他补上作业，感谢老师关照。",
      ]
    case .inquiry:
      return [
        "谢谢老师。想请教一下孩子最近课堂专注度和作业完成情况怎么样？",
        "好的老师。麻烦您有空时帮我看看他最近上课状态，我们好配合，感谢。",
        "谢谢老师关照。想了解一下他最近在您课上表现如何，有需要加强的地方吗？",
      ]
    case .feedback:
      return [
        "老师好，练习我会督促完成。最近他写到比较晚，想请教是否有调整建议，谢谢老师。",
        "老师您好，作业我们一定跟进。孩子这周压力有点大，麻烦老师指点一下节奏，感谢。",
        "老师好，收到。我们会认真完成。也想和老师沟通一下，看怎么帮他跟上又不至于太累。",
      ]
    case .thanks:
      return [
        "老师辛苦了，感谢您对孩子的耐心和付出！",
        "谢谢老师一直以来的关照，孩子进步离不开您的教导。",
        "老师您好，衷心感谢您的用心，我们会继续配合您的工作。",
      ]
    case .apology:
      return [
        "收到，谢谢老师及时告知。回家我会和孩子认真谈，让他向同学道歉。",
        "谢谢老师反馈。我们会严肃跟孩子沟通，有需要配合的请随时联系我。",
        "老师好，给您添麻烦了。今晚我会了解情况，让孩子认识到错误并道歉。",
      ]
    case .meeting:
      return [
        "老师好，想跟您约个时间当面沟通一下孩子最近的情况，您看哪天方便？",
        "老师您好，有些情况想当面请教，请问这周您哪天方便接电话或到校？",
        "老师好，方便时想和您简短聊一下，我按您的时间配合，谢谢。",
      ]
    case .none:
      return [
        "老师好，收到，谢谢老师。",
        "好的老师，我们会配合，感谢。",
        "谢谢老师告知，辛苦了。",
      ]
    }
  }
}

enum APIGenerateService {
  static func generate(for request: GenerateRequest) async throws -> [String] {
    let apiKey = SharedSettings.apiKey
    guard !apiKey.isEmpty else {
      return MockGenerateService.generate(for: request)
    }

    let base = SharedSettings.apiBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
    let urlString = base.hasSuffix("/") ? base + "v1/chat/completions" : base + "/v1/chat/completions"
    guard let url = URL(string: urlString) else {
      throw GenerateError.network("API 地址无效")
    }

    let messages = PromptBuilder.buildMessages(for: request)
    let body: [String: Any] = [
      "model": SharedSettings.modelName,
      "temperature": request.mode == .polish ? 0.4 : 0.7,
      "max_tokens": 512,
      "messages": messages.map { ["role": $0.role, "content": $0.content] },
    ]

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: urlRequest)
    guard let http = response as? HTTPURLResponse else {
      throw GenerateError.network("无有效响应")
    }
    guard (200 ... 299).contains(http.statusCode) else {
      let text = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
      throw GenerateError.network(text)
    }

    guard
      let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
      let choices = json["choices"] as? [[String: Any]],
      let first = choices.first,
      let message = first["message"] as? [String: Any],
      let content = message["content"] as? String
    else {
      throw GenerateError.parseFailed
    }

    let replies = GenerateService.parseReplies(from: content)
    guard !replies.isEmpty else { throw GenerateError.parseFailed }
    return replies
  }
}
