import Foundation
import UserNotifications
import Combine

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    let alarmActivation = PassthroughSubject<UUID, Never>()

    private override init() {
        super.init()
        center.delegate = self
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Leet Alarm"
        content.body = "Solve the challenge to dismiss your alarm."
        content.sound = UNNotificationSound(named: UNNotificationSoundName("alarm.wav"))
        content.userInfo = ["alarmId": alarm.id.uuidString]

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: alarm.triggerDateComponents,
            repeats: alarm.repeatOption == .daily
        )

        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func cancelNotification(for alarm: Alarm) {
        center.removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
        center.removeDeliveredNotifications(withIdentifiers: [alarm.id.uuidString])
    }

    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let idString = response.notification.request.content.userInfo["alarmId"] as? String,
           let uuid = UUID(uuidString: idString) {
            alarmActivation.send(uuid)
            persistActiveAlarm(id: uuid)
        }
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func persistActiveAlarm(id: UUID?) {
        if let id = id {
            UserDefaults.standard.set(id.uuidString, forKey: UserDefaultsKeys.activeAlarmId)
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.activeAlarmId)
        }
    }
}

enum UserDefaultsKeys {
    static let alarms = "alarms_store_key"
    static let activeAlarmId = "active_alarm_id"
}
