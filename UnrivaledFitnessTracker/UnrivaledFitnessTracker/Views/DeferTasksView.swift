import SwiftUI

struct DeferTasksView: View {
    let sourceDate: Date
    let incompleteCount: Int
    @Binding var isPresented: Bool
    let onDefer: (Date) -> Void

    @State private var targetDate: Date
    @State private var showingConfirmation = false

    private let calendar = Calendar.current

    init(sourceDate: Date, incompleteCount: Int, isPresented: Binding<Bool>, onDefer: @escaping (Date) -> Void) {
        self.sourceDate = sourceDate
        self.incompleteCount = incompleteCount
        self._isPresented = isPresented
        self.onDefer = onDefer
        // Default to next weekday
        self._targetDate = State(initialValue: Self.nextWeekday(after: sourceDate))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)

                    Text("Move Uncompleted Tasks")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(incompleteCount) task\(incompleteCount == 1 ? "" : "s") will be moved")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Move to")
                        .font(.headline)
                        .padding(.horizontal)

                    DatePicker(
                        "Target Date",
                        selection: $targetDate,
                        in: dayAfter(sourceDate)...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .onChange(of: targetDate) { _ in
                        // Snap to weekday
                        if !isWeekday(targetDate) {
                            targetDate = Self.nextWeekday(after: targetDate)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                QuickDateButtons(sourceDate: sourceDate, selected: $targetDate)

                Spacer()

                Button(action: { showingConfirmation = true }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Move \(incompleteCount) Task\(incompleteCount == 1 ? "" : "s") to \(targetDate.shortFormatted)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(14)
                    .padding(.horizontal)
                }
                .alert("Move Tasks?", isPresented: $showingConfirmation) {
                    Button("Move", role: .destructive) {
                        onDefer(targetDate)
                        isPresented = false
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Move \(incompleteCount) uncompleted task\(incompleteCount == 1 ? "" : "s") to \(targetDate.longFormatted)?")
                }
            }
            .navigationTitle("Defer Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }

    private func dayAfter(_ date: Date) -> Date {
        calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }

    private func isWeekday(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return (2...6).contains(weekday)
    }

    static func nextWeekday(after date: Date) -> Date {
        let calendar = Calendar.current
        var next = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        while ![2, 3, 4, 5, 6].contains(calendar.component(.weekday, from: next)) {
            next = calendar.date(byAdding: .day, value: 1, to: next) ?? next
        }
        return next
    }
}

struct QuickDateButtons: View {
    let sourceDate: Date
    @Binding var selected: Date

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Select")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(quickDates, id: \.self) { date in
                        Button(action: { selected = date }) {
                            VStack(spacing: 2) {
                                Text(weekdayName(date))
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                Text(date.shortFormatted)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(calendar.isDate(selected, inSameDayAs: date)
                                        ? Color.orange : Color(.secondarySystemBackground))
                            .foregroundColor(calendar.isDate(selected, inSameDayAs: date)
                                             ? .white : .primary)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var quickDates: [Date] {
        var dates: [Date] = []
        var cursor = calendar.date(byAdding: .day, value: 1, to: sourceDate) ?? sourceDate
        while dates.count < 5 {
            let weekday = calendar.component(.weekday, from: cursor)
            if (2...6).contains(weekday) { dates.append(cursor) }
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }
        return dates
    }

    private func weekdayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }
}

private extension Date {
    var shortFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: self)
    }

    var longFormatted: String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: self)
    }
}
