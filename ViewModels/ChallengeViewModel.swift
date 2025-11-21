import Foundation
import Combine

@MainActor
final class ChallengeViewModel: ObservableObject {
    @Published var currentQuestion: Question?
    @Published var questionsSolved: Int = 0
    @Published var requiredQuestions: Int = 0
    @Published var isCompleted: Bool = false
    @Published var feedback: String?

    private var questionPool: [Question]
    private var queue: [Question] = []

    init(sampleQuestions: [Question] = QuestionSamples.all) {
        self.questionPool = sampleQuestions
    }

    func start(alarm: Alarm) {
        requiredQuestions = max(1, alarm.questionsRequired)
        questionsSolved = 0
        isCompleted = false
        feedback = nil
        queue = makeQueue(for: alarm.difficulty, count: requiredQuestions)
        currentQuestion = queue.first
    }

    func submit(answerIndex: Int) {
        guard let question = currentQuestion else { return }
        if answerIndex == question.correctAnswerIndex {
            questionsSolved += 1
            feedback = "Correct! \(question.explanation)"
            queue.removeFirst()
            currentQuestion = queue.first
            if questionsSolved >= requiredQuestions {
                isCompleted = true
            }
        } else {
            feedback = "Not quite. \(question.explanation)"
        }
    }

    private func makeQueue(for difficulty: Difficulty, count: Int) -> [Question] {
        let mappedDifficulty: Question.QuestionDifficulty
        switch difficulty {
        case .easy: mappedDifficulty = .easy
        case .medium: mappedDifficulty = .medium
        case .hard: mappedDifficulty = .hard
        }

        let filtered = questionPool.filter { $0.difficulty == mappedDifficulty }
        if filtered.count >= count {
            return Array(filtered.shuffled().prefix(count))
        }

        var queue = filtered
        while queue.count < count {
            queue.append(contentsOf: filtered)
        }
        return Array(queue.prefix(count))
    }
}

enum QuestionSamples {
    static let all: [Question] = [
        Question(
            title: "Two Sum",
            prompt: "Given an array of integers, return indices of the two numbers such that they add up to a specific target.",
            options: [
                "Use a hash map to store complements",
                "Sort the array then use binary search",
                "Try every pair with two loops",
                "Use dynamic programming"
            ],
            correctAnswerIndex: 0,
            explanation: "A hash map lets you find complements in O(n) time.",
            difficulty: .easy
        ),
        Question(
            title: "Reverse Linked List",
            prompt: "Reverse a singly linked list.",
            options: [
                "Use recursion only",
                "Iterate and adjust next pointers",
                "Use a stack of nodes",
                "Copy values into an array"
            ],
            correctAnswerIndex: 1,
            explanation: "Iteratively moving through the list and rewiring next pointers yields O(1) space.",
            difficulty: .easy
        ),
        Question(
            title: "Binary Tree Level Order Traversal",
            prompt: "Return the level order traversal of a binary tree's nodes' values.",
            options: [
                "Depth-first search with recursion",
                "In-order traversal",
                "Breadth-first search with a queue",
                "Reverse post-order traversal"
            ],
            correctAnswerIndex: 2,
            explanation: "BFS with a queue visits nodes level by level.",
            difficulty: .medium
        ),
        Question(
            title: "Top K Frequent Elements",
            prompt: "Given a non-empty array, return the k most frequent elements.",
            options: [
                "Sort the array",
                "Use a frequency map and min-heap",
                "Sliding window",
                "Prefix sums"
            ],
            correctAnswerIndex: 1,
            explanation: "A frequency map plus a min-heap (or bucket sort) tracks the top k efficiently.",
            difficulty: .medium
        ),
        Question(
            title: "Word Ladder",
            prompt: "Find the length of shortest transformation sequence from beginWord to endWord.",
            options: [
                "Depth-first search",
                "Breadth-first search over transformations",
                "Union find",
                "Greedy choice"
            ],
            correctAnswerIndex: 1,
            explanation: "BFS explores transformations layer by layer to find the shortest path.",
            difficulty: .hard
        ),
        Question(
            title: "Median of Two Sorted Arrays",
            prompt: "Find the median of two sorted arrays in O(log (m+n)).",
            options: [
                "Merge the arrays fully",
                "Binary search partitioning",
                "Randomized quickselect",
                "Two-pointer linear scan"
            ],
            correctAnswerIndex: 1,
            explanation: "Binary searching partition indices yields the median without full merge.",
            difficulty: .hard
        )
    ]
}
