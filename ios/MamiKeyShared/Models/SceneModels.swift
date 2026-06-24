import Foundation

enum CommunicationScene: String, CaseIterable, Codable, Identifiable {
    case parentToChild = "parent_to_child"
    case parentToTeacher = "parent_to_teacher"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .parentToChild: return "对孩子"
        case .parentToTeacher: return "对老师"
        }
    }
}

enum ChildSubScene: String, CaseIterable, Codable, Identifiable {
    case homework = "催作业"
    case screenTime = "玩手机"
    case talkingBack = "顶嘴"
    case praise = "表扬"
    case chat = "谈心"
    case apology = "道歉和好"

    var id: String { rawValue }

    var defaultStyle: String {
        switch self {
        case .homework, .screenTime: return "温和坚定"
        case .talkingBack: return "先共情再引导"
        case .praise: return "温暖鼓励"
        case .chat: return "轻松平等"
        case .apology: return "真诚简短"
        }
    }

    var availableStyles: [String] {
        switch self {
        case .homework, .screenTime: return ["温和坚定", "先共情再引导"]
        case .talkingBack: return ["先共情再引导", "温和坚定"]
        case .praise: return ["温暖鼓励", "轻松平等"]
        case .chat: return ["轻松平等", "温暖鼓励"]
        case .apology: return ["真诚简短", "先共情再引导"]
        }
    }
}

enum TeacherSubScene: String, CaseIterable, Codable, Identifiable {
    case leave = "请假"
    case inquiry = "了解表现"
    case feedback = "反馈问题"
    case thanks = "感谢"
    case apology = "道歉"
    case meeting = "约沟通"

    var id: String { rawValue }

    var defaultStyle: String {
        switch self {
        case .leave, .inquiry, .meeting: return "礼貌简洁"
        case .feedback: return "委婉合作"
        case .thanks: return "真诚得体"
        case .apology: return "诚恳负责"
        }
    }

    var availableStyles: [String] {
        switch self {
        case .leave: return ["礼貌简洁", "诚恳负责"]
        case .inquiry: return ["礼貌简洁", "委婉合作"]
        case .feedback: return ["委婉合作", "礼貌简洁"]
        case .thanks: return ["真诚得体", "礼貌简洁"]
        case .apology: return ["诚恳负责", "真诚得体"]
        case .meeting: return ["礼貌简洁", "委婉合作"]
        }
    }
}

enum ReplyLength: String, CaseIterable, Codable {
    case short = "短"
    case medium = "中"

    var promptHint: String {
        switch self {
        case .short: return "短=1-2句/约40字内"
        case .medium: return "中=2-4句/约80字内"
        }
    }
}

enum GenerateMode: String, Codable {
    case generate
    case polish
}

struct GenerateRequest: Codable {
    var scene: CommunicationScene
    var childSubScene: ChildSubScene?
    var teacherSubScene: TeacherSubScene?
    var style: String
    var message: String
    var context: String?
    var childAge: String?
    var grade: String?
    var length: ReplyLength
    var mode: GenerateMode
    var candidateCount: Int

    var subSceneTitle: String {
        switch scene {
        case .parentToChild:
            return childSubScene?.rawValue ?? ""
        case .parentToTeacher:
            return teacherSubScene?.rawValue ?? ""
        }
    }
}

struct HistoryEntry: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    let scene: CommunicationScene
    let subScene: String
    let inputMessage: String
    let replies: [String]
    let selectedReply: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        scene: CommunicationScene,
        subScene: String,
        inputMessage: String,
        replies: [String],
        selectedReply: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.scene = scene
        self.subScene = subScene
        self.inputMessage = inputMessage
        self.replies = replies
        self.selectedReply = selectedReply
    }
}
