import Foundation
import Combine

@MainActor
final class AlarmViewModel: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var activeAlarmId: UUID?

    private var cancellables = Set<AnyCancellable>()

    init(notificationManager: NotificationManager = .shared) {
        loadAlarms()
        loadActiveAlarm()
        notificationManager.requestAuthorization()

        notificationManager.alarmActivation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] id in
                self?.activeAlarmId = id
            }
            .store(in: &cancellables)
    }

    func add(alarm: Alarm) {
        alarms.append(alarm)
        persistAlarms()
        NotificationManager.shared.scheduleNotification(for: alarm)
    }

    func update(alarm: Alarm) {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else { return }
        alarms[index] = alarm
        persistAlarms()
        NotificationManager.shared.cancelNotification(for: alarm)
        NotificationManager.shared.scheduleNotification(for: alarm)
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            let alarm = alarms[index]
            NotificationManager.shared.cancelNotification(for: alarm)
        }
        alarms.remove(atOffsets: offsets)
        persistAlarms()
    }

    func activate(alarmId: UUID) {
        activeAlarmId = alarmId
        NotificationManager.shared.persistActiveAlarm(id: alarmId)
    }

    func dismissActiveAlarm() {
        if let id = activeAlarmId, let alarm = alarms.first(where: { $0.id == id }) {
            NotificationManager.shared.cancelNotification(for: alarm)
        }
        activeAlarmId = nil
        NotificationManager.shared.persistActiveAlarm(id: nil)
    }

    private func persistAlarms() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(alarms) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.alarms)
        }
    }

    private func loadAlarms() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.alarms) else { return }
        let decoder = JSONDecoder()
        if let stored = try? decoder.decode([Alarm].self, from: data) {
            alarms = stored
        }
    }

    private func loadActiveAlarm() {
        if let idString = UserDefaults.standard.string(forKey: UserDefaultsKeys.activeAlarmId),
           let uuid = UUID(uuidString: idString) {
            activeAlarmId = uuid
        }
    }
}
