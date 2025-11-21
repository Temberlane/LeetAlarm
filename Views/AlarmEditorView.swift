import SwiftUI

struct AlarmEditorView: View {
    var alarm: Alarm?
    var onSave: (Alarm) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var time: Date
    @State private var repeatOption: RepeatOption
    @State private var difficulty: Difficulty
    @State private var questionsRequired: Int

    init(alarm: Alarm?, onSave: @escaping (Alarm) -> Void) {
        self.alarm = alarm
        self.onSave = onSave
        if let alarm = alarm {
            let components = DateComponents(calendar: .current, hour: alarm.hour, minute: alarm.minute)
            _time = State(initialValue: components.date ?? Date())
            _repeatOption = State(initialValue: alarm.repeatOption)
            _difficulty = State(initialValue: alarm.difficulty)
            _questionsRequired = State(initialValue: alarm.questionsRequired)
        } else {
            _time = State(initialValue: Date())
            _repeatOption = State(initialValue: .once)
            _difficulty = State(initialValue: .easy)
            _questionsRequired = State(initialValue: 1)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Time")) {
                    DatePicker("Alarm Time", selection: $time, displayedComponents: .hourAndMinute)
                }

                Section(header: Text("Options")) {
                    Picker("Repeat", selection: $repeatOption) {
                        ForEach(RepeatOption.allCases) { option in
                            Text(option.description).tag(option)
                        }
                    }

                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases) { diff in
                            Text(diff.displayName).tag(diff)
                        }
                    }

                    Stepper(value: $questionsRequired, in: 1...10) {
                        Text("Questions Required: \(questionsRequired)")
                    }
                }
            }
            .navigationTitle(alarm == nil ? "New Alarm" : "Edit Alarm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAlarm()
                    }
                }
            }
        }
    }

    private func saveAlarm() {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: time)
        guard let hour = comps.hour, let minute = comps.minute else { return }

        let newAlarm = Alarm(
            id: alarm?.id ?? UUID(),
            hour: hour,
            minute: minute,
            repeatOption: repeatOption,
            difficulty: difficulty,
            questionsRequired: questionsRequired
        )
        onSave(newAlarm)
        dismiss()
    }
}

struct AlarmEditorView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmEditorView(alarm: nil) { _ in }
    }
}
