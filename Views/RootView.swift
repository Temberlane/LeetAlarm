import SwiftUI

struct RootView: View {
    @EnvironmentObject private var alarmViewModel: AlarmViewModel
    @EnvironmentObject private var challengeViewModel: ChallengeViewModel

    var body: some View {
        Group {
            if let activeId = alarmViewModel.activeAlarmId,
               let activeAlarm = alarmViewModel.alarms.first(where: { $0.id == activeId }) {
                ChallengeView(alarm: activeAlarm)
            } else {
                NavigationView {
                    AlarmListView()
                }
            }
        }
        .onReceive(NotificationManager.shared.alarmActivation) { id in
            alarmViewModel.activate(alarmId: id)
            if let alarm = alarmViewModel.alarms.first(where: { $0.id == id }) {
                challengeViewModel.start(alarm: alarm)
            }
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
            if let id = alarmViewModel.activeAlarmId,
               let alarm = alarmViewModel.alarms.first(where: { $0.id == id }) {
                challengeViewModel.start(alarm: alarm)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AlarmViewModel())
            .environmentObject(ChallengeViewModel())
    }
}
