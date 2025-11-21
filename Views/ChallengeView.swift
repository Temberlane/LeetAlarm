import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject private var alarmViewModel: AlarmViewModel
    @EnvironmentObject private var challengeViewModel: ChallengeViewModel
    let alarm: Alarm

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Alarm Challenge")
                .font(.largeTitle)
                .bold()
            Text("Difficulty: \(alarm.difficulty.displayName) • Remaining: \(max(0, alarm.questionsRequired - challengeViewModel.questionsSolved))")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let question = challengeViewModel.currentQuestion {
                VStack(alignment: .leading, spacing: 12) {
                    Text(question.title)
                        .font(.title2)
                        .bold()
                    Text(question.prompt)
                    ForEach(question.options.indices, id: \.self) { index in
                        Button(action: {
                            challengeViewModel.submit(answerIndex: index)
                        }) {
                            HStack {
                                Text(question.options[index])
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .disabled(challengeViewModel.isCompleted)
                    }
                }
            } else {
                Text("Great job! Tap below to dismiss the alarm.")
            }

            if let feedback = challengeViewModel.feedback {
                Text(feedback)
                    .font(.footnote)
                    .foregroundColor(.green)
            }

            Spacer()

            if challengeViewModel.isCompleted {
                Button(action: dismissAlarm) {
                    Text("Dismiss Alarm")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            alarmViewModel.activate(alarmId: alarm.id)
            challengeViewModel.start(alarm: alarm)
        }
    }

    private func dismissAlarm() {
        alarmViewModel.dismissActiveAlarm()
    }
}

struct ChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeView(alarm: Alarm(hour: 7, minute: 30, repeatOption: .daily, difficulty: .medium, questionsRequired: 2))
            .environmentObject(AlarmViewModel())
            .environmentObject(ChallengeViewModel())
    }
}
