import Foundation

struct Question: Identifiable, Codable, Equatable {
    enum QuestionDifficulty: String, Codable {
        case easy
        case medium
        case hard
    }

    let id: UUID
    let title: String
    let prompt: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let difficulty: QuestionDifficulty

    init(
        id: UUID = UUID(),
        title: String,
        prompt: String,
        options: [String],
        correctAnswerIndex: Int,
        explanation: String,
        difficulty: QuestionDifficulty
    ) {
        self.id = id
        self.title = title
        self.prompt = prompt
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.difficulty = difficulty
    }
}
