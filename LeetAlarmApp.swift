import SwiftUI
import UserNotifications

@main
struct LeetAlarmApp: App {
    @StateObject private var alarmViewModel = AlarmViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(alarmViewModel)
                .environmentObject(challengeViewModel)
        }
    }
}
