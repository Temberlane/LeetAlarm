import Foundation

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }
    var displayName: String {
        rawValue.capitalized
    }
}

enum RepeatOption: String, Codable, CaseIterable, Identifiable {
    case once
    case daily

    var id: String { rawValue }
    var description: String {
        switch self {
        case .once:
            return "Once"
        case .daily:
            return "Daily"
        }
    }
}

struct Alarm: Identifiable, Codable, Equatable {
    let id: UUID
    var hour: Int
    var minute: Int
    var repeatOption: RepeatOption
    var difficulty: Difficulty
    var questionsRequired: Int

    init(
        id: UUID = UUID(),
        hour: Int,
        minute: Int,
        repeatOption: RepeatOption,
        difficulty: Difficulty,
        questionsRequired: Int
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.repeatOption = repeatOption
        self.difficulty = difficulty
        self.questionsRequired = questionsRequired
    }

    var timeLabel: String {
        let components = DateComponents(calendar: .current, hour: hour, minute: minute)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter.string(from: components.date ?? Date())
    }

    var triggerDateComponents: DateComponents {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return components
    }
}
