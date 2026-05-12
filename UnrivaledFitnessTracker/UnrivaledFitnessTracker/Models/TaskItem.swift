import Foundation

enum TaskFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case asNeeded = "As Needed"
}

enum DayOfWeek: Int, Codable, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6

    var name: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        }
    }

    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        }
    }
}

struct TaskItem: Identifiable, Codable {
    var id: UUID
    var title: String
    var timeSlot: String
    var estimatedMinutes: Int
    var frequency: TaskFrequency
    var scheduledDay: DayOfWeek?
    var isCompleted: Bool
    var assignedDate: Date
    var isDeferred: Bool
    var originalDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        timeSlot: String,
        estimatedMinutes: Int,
        frequency: TaskFrequency,
        scheduledDay: DayOfWeek? = nil,
        isCompleted: Bool = false,
        assignedDate: Date = Date(),
        isDeferred: Bool = false,
        originalDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.timeSlot = timeSlot
        self.estimatedMinutes = estimatedMinutes
        self.frequency = frequency
        self.scheduledDay = scheduledDay
        self.isCompleted = isCompleted
        self.assignedDate = assignedDate
        self.isDeferred = isDeferred
        self.originalDate = originalDate
    }
}

extension TaskItem {
    var durationText: String {
        estimatedMinutes >= 60
            ? "\(estimatedMinutes / 60)hr \(estimatedMinutes % 60 > 0 ? "\(estimatedMinutes % 60)min" : "")"
            : "\(estimatedMinutes)min"
    }
}
