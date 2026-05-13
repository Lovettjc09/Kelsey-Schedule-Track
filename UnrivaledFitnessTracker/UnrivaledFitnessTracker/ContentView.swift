import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TaskStore
    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                weekStrip
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))

                DayTasksView(date: selectedDate)
                    .environmentObject(store)
                    .id(selectedDate)
            }
            .navigationTitle("Unrivaled Fitness")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: goToToday) {
                        Text("Today")
                            .fontWeight(.semibold)
                    }
                    .disabled(calendar.isDateInToday(selectedDate))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: goToToday) {
                            Label("Go to Today", systemImage: "calendar.circle")
                        }
                        Button(action: goToPreviousWeek) {
                            Label("Previous Week", systemImage: "chevron.left")
                        }
                        Button(action: goToNextWeek) {
                            Label("Next Week", systemImage: "chevron.right")
                        }
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Week Strip

    private var weekStrip: some View {
        HStack(spacing: 0) {
            Button(action: goToPreviousWeek) {
                Image(systemName: "chevron.left")
                    .padding(.horizontal, 8)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(weekDates, id: \.self) { date in
                        DayChip(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            completionRatio: completionRatio(for: date)
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDate = date
                                store.generateTasksForDate(date)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }

            Button(action: goToNextWeek) {
                Image(systemName: "chevron.right")
                    .padding(.horizontal, 8)
            }
        }
        .foregroundColor(.primary)
    }

    // MARK: - Helpers

    private var weekDates: [Date] {
        let start = startOfWeek(for: selectedDate)
        return (0..<5).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private func startOfWeek(for date: Date) -> Date {
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        comps.weekday = 2
        return calendar.date(from: comps) ?? date
    }

    private func goToToday() {
        withAnimation { selectedDate = Date() }
        store.generateTasksForDate(Date())
    }

    private func goToPreviousWeek() {
        withAnimation {
            selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        }
    }

    private func goToNextWeek() {
        withAnimation {
            selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
        }
        store.generateTasksForDate(selectedDate)
    }

    private func completionRatio(for date: Date) -> Double {
        let stats = store.completionStats(for: date)
        return stats.total == 0 ? 0 : Double(stats.completed) / Double(stats.total)
    }
}

struct DayChip: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let completionRatio: Double

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            Text(weekdayAbbr)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .secondary)

            Text(dayNumber)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(isSelected ? .white : isToday ? .blue : .primary)

            Circle()
                .fill(completionColor)
                .frame(width: 6, height: 6)
                .opacity(completionRatio > 0 ? 1 : 0.2)
        }
        .frame(width: 52, height: 68)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.1) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday && !isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
        )
    }

    private var weekdayAbbr: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    private var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private var completionColor: Color {
        if completionRatio == 1 { return .green }
        if completionRatio > 0 { return .orange }
        return .gray
    }
}
