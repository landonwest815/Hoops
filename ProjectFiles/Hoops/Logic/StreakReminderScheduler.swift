import UserNotifications
import SwiftData

struct StreakReminderScheduler {
    static func updateReminder(in context: ModelContext) {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        guard settings.authorizationStatus == .authorized else {
          UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["streakReminder"])
          print("🗑️ StreakReminderScheduler: no auth, clearing any pending reminders")
          return
        }

        DispatchQueue.main.async {
          if StreakLogic.hasSessionThisWeek(in: context) {
            UNUserNotificationCenter.current()
              .removePendingNotificationRequests(withIdentifiers: ["streakReminder"])
            print("✅ StreakReminderScheduler: already hooped this week, cancelled reminder")
          } else {
            let totalSeconds = UserDefaults.standard.integer(forKey: "streakReminderSeconds")
            let hour   = totalSeconds / 3600
            let minute = (totalSeconds % 3600) / 60
            print("⏰ StreakReminderScheduler: scheduling for \(hour):\(String(format: "%02d", minute))")
            scheduleWeekly(atHour: hour, minute: minute)
          }
        }
      }
    }
    
    private static func scheduleWeekly(atHour hour: Int, minute: Int) {
        // same weekday logic as before…
        let startName  = UserDefaults.standard.string(forKey: AppSettingsKeys.startOfWeek) ?? "Sunday"
        let names      = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        let startIndex = names.firstIndex(of: startName) ?? 0
        let lastIndex  = (startIndex + 6) % 7
        let weekday    = lastIndex + 1
        
        var dc = DateComponents()
        dc.weekday = weekday
        dc.hour    = hour
        dc.minute  = minute + 20
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Keep Your Streak Alive! ⏳"
        content.body  = "Put some shots up before the end of the day!"
        content.sound = .default
        
        let req = UNNotificationRequest(
            identifier: "streakReminder",
            content:   content,
            trigger:   trigger
        )
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["streakReminder"])
        center.add(req) { if let err = $0 { print("⚠️", err) } }
    }
}


struct StreakLogic {
  /// Returns the date at the start of the user’s current week.
  static func startOfCurrentWeek() -> Date {
    let startName = UserDefaults.standard.string(forKey: AppSettingsKeys.startOfWeek) ?? "Sunday"
    let calendar = Calendar.current
    let today = Date()
    let todayIndex = calendar.component(.weekday, from: today)
    let startIndex = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
                      .firstIndex(of: startName)! + 1
    let daysBack = (todayIndex - startIndex + 7) % 7
    let startOfDay = calendar.startOfDay(for: today)
    return calendar.date(byAdding: .day, value: -daysBack, to: startOfDay)!
  }

  /// Returns true if there’s at least one session on or after the start of the week.
  static func hasSessionThisWeek(in context: ModelContext) -> Bool {
    let cutoff = startOfCurrentWeek()
    // Build a FetchDescriptor with a SwiftData predicate
    let descriptor = FetchDescriptor<HoopSession>(
      predicate: #Predicate { $0.date >= cutoff }
    )
    // Fetch only the count, by limiting to 1 result
    var d = descriptor
    d.fetchLimit = 1
    return (try? context.fetch(d))?.isEmpty == false
  }
}
