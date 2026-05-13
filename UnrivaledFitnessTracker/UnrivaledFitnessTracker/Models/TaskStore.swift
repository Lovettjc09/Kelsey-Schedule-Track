import Foundation
import Combine

class TaskStore: ObservableObject {
    @Published var tasksByDate: [String: [TaskItem]] = [:]

    private let storageKey = "unrivaled_tasks"
    private let calendar = Calendar.current

    static let shared = TaskStore()

    init() {
        loadTasks()
        ensureTasksExistForCurrentWeek()
    }

    // MARK: - Date Helpers

    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func tasks(for date: Date) -> [TaskItem] {
        (tasksByDate[dateKey(date)] ?? []).sorted {
            $0.timeSlot < $1.timeSlot
        }
    }

    // MARK: - Toggle Completion

    func toggleCompletion(task: TaskItem, on date: Date) {
        let key = dateKey(date)
        guard let index = tasksByDate[key]?.firstIndex(where: { $0.id == task.id }) else { return }
        tasksByDate[key]?[index].isCompleted.toggle()
        saveTasks()
    }

    // MARK: - Defer Uncompleted Tasks

    func moveUncompletedTasks(from date: Date, to targetDate: Date) -> Int {
        let key = dateKey(date)
        let targetKey = dateKey(targetDate)

        guard var dayTasks = tasksByDate[key] else { return 0 }

        var movedCount = 0
        var updatedSource: [TaskItem] = []

        for task in dayTasks {
            if !task.isCompleted {
                var deferred = task
                deferred.id = UUID()
                deferred.assignedDate = targetDate
                deferred.isDeferred = true
                deferred.originalDate = task.originalDate ?? date
                deferred.isCompleted = false

                if tasksByDate[targetKey] == nil {
                    tasksByDate[targetKey] = []
                }
                tasksByDate[targetKey]?.append(deferred)
                movedCount += 1
            } else {
                updatedSource.append(task)
            }
        }

        tasksByDate[key] = updatedSource
        saveTasks()
        return movedCount
    }

    // MARK: - Delete Completed

    func clearCompleted(for date: Date) {
        let key = dateKey(date)
        tasksByDate[key] = tasksByDate[key]?.filter { !$0.isCompleted }
        saveTasks()
    }

    // MARK: - Seed / Generate Tasks

    func ensureTasksExistForCurrentWeek() {
        let today = Date()
        let weekStart = startOfWeek(for: today)
        for offset in 0..<5 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else { continue }
            let key = dateKey(day)
            if tasksByDate[key] == nil {
                tasksByDate[key] = generateTasks(for: day)
            }
        }
        saveTasks()
    }

    func generateTasksForDate(_ date: Date) {
        let key = dateKey(date)
        if tasksByDate[key] == nil {
            tasksByDate[key] = generateTasks(for: date)
            saveTasks()
        }
    }

    private func startOfWeek(for date: Date) -> Date {
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        comps.weekday = 2 // Monday
        return calendar.date(from: comps) ?? date
    }

    private func generateTasks(for date: Date) -> [TaskItem] {
        let weekday = calendar.component(.weekday, from: date)
        var tasks: [TaskItem] = []

        // Daily tasks always present on weekdays
        let isWeekday = (2...6).contains(weekday)
        guard isWeekday else { return [] }

        tasks += dailyTasks(for: date)

        switch weekday {
        case 2: tasks += mondayTasks(for: date)
        case 3: tasks += tuesdayTasks(for: date)
        case 4: tasks += wednesdayTasks(for: date)
        case 5: tasks += thursdayTasks(for: date)
        case 6: tasks += fridayTasks(for: date)
        default: break
        }

        return tasks
    }

    // MARK: - Task Definitions

    private func dailyTasks(for date: Date) -> [TaskItem] {
        [
            TaskItem(title: "Mindbody EOD class check (late cancel / no-show cleanup)",
                     timeSlot: "12:30–1:00", estimatedMinutes: 15,
                     frequency: .daily, assignedDate: date),
            TaskItem(title: "Social media engagement (respond to comments & DMs)",
                     timeSlot: "12:00–12:30", estimatedMinutes: 15,
                     frequency: .daily, assignedDate: date)
        ]
    }

    private func mondayTasks(for date: Date) -> [TaskItem] {
        [
            TaskItem(title: "Weekly call with Josh",
                     timeSlot: "9:00–9:30", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .monday, assignedDate: date),
            TaskItem(title: "Review class schedule; assign coach workouts",
                     timeSlot: "9:30–10:00", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .monday, assignedDate: date),
            TaskItem(title: "Google Calendar: sub coordination & TBAs",
                     timeSlot: "10:00–10:30", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .monday, assignedDate: date),
            TaskItem(title: "Social media post + reel publish",
                     timeSlot: "10:30–11:00", estimatedMinutes: 15,
                     frequency: .weekly, scheduledDay: .monday, assignedDate: date),
            TaskItem(title: "Fundraiser / challenge coordination",
                     timeSlot: "12:30–1:00", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .monday, assignedDate: date),
            TaskItem(title: "Challenge participant check-in & motivation",
                     timeSlot: "12:00–12:30", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .monday, assignedDate: date)
        ]
    }

    private func tuesdayTasks(for date: Date) -> [TaskItem] {
        [
            TaskItem(title: "Mindbody Admin: Trial follow-ups & expired cards",
                     timeSlot: "9:00–9:30", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .tuesday, assignedDate: date),
            TaskItem(title: "Mindbody Admin: continued",
                     timeSlot: "9:30–10:00", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .tuesday, assignedDate: date),
            TaskItem(title: "Social media post + reel publish",
                     timeSlot: "10:00–10:30", estimatedMinutes: 15,
                     frequency: .weekly, scheduledDay: .tuesday, assignedDate: date),
            TaskItem(title: "Membership retention outreach",
                     timeSlot: "10:30–11:00", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .tuesday, assignedDate: date),
            TaskItem(title: "Specialty event/workout scheduling",
                     timeSlot: "12:00–12:30", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .tuesday, assignedDate: date)
        ]
    }

    private func wednesdayTasks(for date: Date) -> [TaskItem] {
        [
            TaskItem(title: "Content Creation: reels/graphics for social",
                     timeSlot: "9:00–9:30", estimatedMinutes: 60,
                     frequency: .weekly, scheduledDay: .wednesday, assignedDate: date),
            TaskItem(title: "Content Creation: continued",
                     timeSlot: "9:30–10:00", estimatedMinutes: 60,
                     frequency: .weekly, scheduledDay: .wednesday, assignedDate: date),
            TaskItem(title: "Event planning: member mingle, bonding, community",
                     timeSlot: "10:00–10:30", estimatedMinutes: 60,
                     frequency: .monthly, scheduledDay: .wednesday, assignedDate: date),
            TaskItem(title: "Coach feedback, supplies & improvements check-in",
                     timeSlot: "10:30–11:00", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .wednesday, assignedDate: date),
            TaskItem(title: "Social media engagement & DM responses",
                     timeSlot: "12:00–12:30", estimatedMinutes: 15,
                     frequency: .weekly, scheduledDay: .wednesday, assignedDate: date)
        ]
    }

    private func thursdayTasks(for date: Date) -> [TaskItem] {
        [
            TaskItem(title: "Mindbody Admin: Expiring contracts & cancellations",
                     timeSlot: "9:00–9:30", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .thursday, assignedDate: date),
            TaskItem(title: "Challenge check-in: participant outreach",
                     timeSlot: "9:30–10:00", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .thursday, assignedDate: date),
            TaskItem(title: "Merch/supply coordination with Carolina Prints",
                     timeSlot: "10:00–10:30", estimatedMinutes: 30,
                     frequency: .monthly, scheduledDay: .thursday, assignedDate: date),
            TaskItem(title: "Social media post + engagement check",
                     timeSlot: "10:30–11:00", estimatedMinutes: 15,
                     frequency: .weekly, scheduledDay: .thursday, assignedDate: date),
            TaskItem(title: "Event planning follow-up",
                     timeSlot: "12:00–12:30", estimatedMinutes: 60,
                     frequency: .asNeeded, scheduledDay: .thursday, assignedDate: date)
        ]
    }

    private func fridayTasks(for date: Date) -> [TaskItem] {
        [
            TaskItem(title: "Weekly recap & Sunday prep notes",
                     timeSlot: "9:00–9:30", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .friday, assignedDate: date),
            TaskItem(title: "Social media post scheduling",
                     timeSlot: "9:30–10:00", estimatedMinutes: 60,
                     frequency: .weekly, scheduledDay: .friday, assignedDate: date),
            TaskItem(title: "EOW Mindbody check: class attendance cleanup",
                     timeSlot: "10:00–10:30", estimatedMinutes: 15,
                     frequency: .weekly, scheduledDay: .friday, assignedDate: date),
            TaskItem(title: "Admin catch-up / flex time",
                     timeSlot: "10:30–11:00", estimatedMinutes: 30,
                     frequency: .weekly, scheduledDay: .friday, assignedDate: date),
            TaskItem(title: "Monthly planning review: month-ahead scheduling",
                     timeSlot: "12:00–12:30", estimatedMinutes: 60,
                     frequency: .monthly, scheduledDay: .friday, assignedDate: date)
        ]
    }

    // MARK: - Persistence

    private func saveTasks() {
        if let data = try? JSONEncoder().encode(tasksByDate) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: [TaskItem]].self, from: data)
        else { return }
        tasksByDate = decoded
    }

    func completionStats(for date: Date) -> (completed: Int, total: Int) {
        let all = tasks(for: date)
        return (all.filter { $0.isCompleted }.count, all.count)
    }
}
