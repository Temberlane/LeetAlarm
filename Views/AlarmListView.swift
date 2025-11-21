import SwiftUI

struct AlarmListView: View {
    @EnvironmentObject private var alarmViewModel: AlarmViewModel
    @EnvironmentObject private var challengeViewModel: ChallengeViewModel
    @State private var showEditor: Bool = false
    @State private var editingAlarm: Alarm?

    var body: some View {
        List {
            ForEach(alarmViewModel.alarms) { alarm in
                Button {
                    editingAlarm = alarm
                    showEditor = true
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(alarm.timeLabel)
                                .font(.title2)
                            Text("Difficulty: \(alarm.difficulty.displayName) • Questions: \(alarm.questionsRequired)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(alarm.repeatOption.description)
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
            .onDelete(perform: alarmViewModel.delete)
        }
        .navigationTitle("Leet Alarms")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    editingAlarm = nil
                    showEditor = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            AlarmEditorView(alarm: editingAlarm) { updatedAlarm in
                if let _ = editingAlarm {
                    alarmViewModel.update(alarm: updatedAlarm)
                } else {
                    alarmViewModel.add(alarm: updatedAlarm)
                }
            }
        }
        .onChange(of: alarmViewModel.activeAlarmId) { _, newValue in
            guard let id = newValue, let alarm = alarmViewModel.alarms.first(where: { $0.id == id }) else { return }
            challengeViewModel.start(alarm: alarm)
        }
    }
}

struct AlarmListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlarmListView()
                .environmentObject(AlarmViewModel())
                .environmentObject(ChallengeViewModel())
        }
    }
}
