import SwiftUI

struct DayTasksView: View {
    @EnvironmentObject var store: TaskStore
    let date: Date

    @State private var showingDeferSheet = false
    @State private var deferFeedback: String? = nil

    private var tasks: [TaskItem] { store.tasks(for: date) }
    private var stats: (completed: Int, total: Int) { store.completionStats(for: date) }
    private var incompleteCount: Int { stats.total - stats.completed }

    var body: some View {
        VStack(spacing: 0) {
            progressHeader

            if tasks.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(tasks) { task in
                            TaskRowView(task: task) {
                                store.toggleCompletion(task: task, on: date)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                    .animation(.default, value: tasks.map { $0.isCompleted })
                }
            }

            bottomBar
        }
        .sheet(isPresented: $showingDeferSheet) {
            DeferTasksView(
                sourceDate: date,
                incompleteCount: incompleteCount,
                isPresented: $showingDeferSheet
            ) { targetDate in
                let count = store.moveUncompletedTasks(from: date, to: targetDate)
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                deferFeedback = "\(count) task\(count == 1 ? "" : "s") moved to \(formatter.string(from: targetDate))"
            }
        }
        .overlay(feedbackBanner, alignment: .top)
    }

    // MARK: - Subviews

    private var progressHeader: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(stats.completed) of \(stats.total) completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if stats.completed > 0 {
                    Button(action: { store.clearCompleted(for: date) }) {
                        Label("Clear Done", systemImage: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)

            ProgressView(value: Double(stats.completed), total: Double(max(stats.total, 1)))
                .tint(progressColor)
                .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("All done!")
                .font(.title2)
                .fontWeight(.bold)
            Text("No tasks scheduled for this day.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private var bottomBar: some View {
        Group {
            if incompleteCount > 0 {
                Button(action: { showingDeferSheet = true }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Move \(incompleteCount) Uncompleted to Later")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(0)
                }
                .shadow(color: .orange.opacity(0.3), radius: 8, y: -4)
            }
        }
    }

    @ViewBuilder
    private var feedbackBanner: some View {
        if let msg = deferFeedback {
            Text(msg)
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { deferFeedback = nil }
                    }
                }
        }
    }

    private var progressColor: Color {
        let ratio = Double(stats.completed) / Double(max(stats.total, 1))
        if ratio == 1 { return .green }
        if ratio >= 0.5 { return .blue }
        return .orange
    }
}
