import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .animation(.spring(response: 0.3), value: task.isCompleted)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Label(task.timeSlot, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label(task.durationText, systemImage: "timer")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    FrequencyBadge(frequency: task.frequency)
                }

                if task.isDeferred, let original = task.originalDate {
                    Label("Moved from \(original.shortFormatted)", systemImage: "arrow.right.circle")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(task.isCompleted
                      ? Color(.systemGray6)
                      : Color(.systemBackground))
                .shadow(color: .black.opacity(task.isCompleted ? 0 : 0.06), radius: 4, x: 0, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
    }
}

struct FrequencyBadge: View {
    let frequency: TaskFrequency

    var body: some View {
        Text(frequency.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch frequency {
        case .daily:    return .blue
        case .weekly:   return .purple
        case .monthly:  return .orange
        case .asNeeded: return .teal
        }
    }
}

private extension Date {
    var shortFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: self)
    }
}
