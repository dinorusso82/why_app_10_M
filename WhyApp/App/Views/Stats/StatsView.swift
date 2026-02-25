import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: SharedDataStore

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Stats")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.whyPrimary)
                    Text(headerSubtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Color.whySecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)

            if store.accessAttempts.isEmpty {
                Spacer()
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.whySurface)
                            .frame(width: 100, height: 100)
                        Image(systemName: "chart.bar")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.whyTertiary)
                    }
                    Text("No data yet")
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.whyPrimary)
                    Text("Interact with your blocked apps\nand your progress will show here.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.whySecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        summaryRow
                        weeklyChart
                        perItemBreakdown
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .whyBackground()
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: 12) {
            StatChip(
                label: "Total",
                value: "\(totalAttempts)",
                color: .whyWarm
            )
            StatChip(
                label: "Walk-away",
                value: "\(walkAwayRate)%",
                color: .whySage
            )
            StatChip(
                label: "Streak",
                value: "\(currentStreak)d",
                color: .whyAmber
            )
        }
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        WhyCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Last 7 Days")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.whyPrimary)

                GeometryReader { geo in
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(last7Days, id: \.date) { day in
                            DayBarColumn(day: day, maxCount: maxDailyCount)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .frame(height: 100)

                // Legend
                HStack(spacing: 16) {
                    LegendDot(color: .whySage, label: "Walked away")
                    LegendDot(color: .whyRose, label: "Proceeded")
                }
            }
        }
    }

    // MARK: - Per-Item Breakdown

    private var perItemBreakdown: some View {
        VStack(spacing: 12) {
            ForEach(itemStats) { stat in
                WhyCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(stat.name)
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color.whyPrimary)
                            Spacer()
                            Text("\(stat.walkedAway)/\(stat.total)")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(Color.whySecondary)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.whyRose.opacity(0.18))
                                    .frame(width: geo.size.width, height: 8)

                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.whySage)
                                    .frame(
                                        width: stat.total > 0
                                            ? geo.size.width * CGFloat(stat.walkedAway) / CGFloat(stat.total)
                                            : 0,
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)

                        Text("\(stat.walkedAway) walked away · \(stat.total - stat.walkedAway) proceeded")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(Color.whyTertiary)
                    }
                }
            }
        }
    }

    // MARK: - Computed stats

    private var totalAttempts: Int {
        store.accessAttempts.count
    }

    private var walkedAwayCount: Int {
        store.accessAttempts.filter { !$0.proceeded }.count
    }

    private var walkAwayRate: Int {
        guard totalAttempts > 0 else { return 0 }
        return Int(round(Double(walkedAwayCount) / Double(totalAttempts) * 100))
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var day = calendar.startOfDay(for: Date())

        while true {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day)!
            let hasWalkAway = store.accessAttempts.contains {
                !$0.proceeded && $0.timestamp >= day && $0.timestamp < nextDay
            }
            if hasWalkAway {
                streak += 1
                day = calendar.date(byAdding: .day, value: -1, to: day)!
            } else {
                break
            }
        }
        return streak
    }

    private var headerSubtitle: String {
        guard totalAttempts > 0 else { return "Your progress will appear here" }
        return "You've walked away \(walkedAwayCount) of \(totalAttempts) time\(totalAttempts == 1 ? "" : "s")"
    }

    private var last7Days: [DayStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset -> DayStat in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let next = calendar.date(byAdding: .day, value: 1, to: day)!
            let attempts = store.accessAttempts.filter { $0.timestamp >= day && $0.timestamp < next }
            let walked = attempts.filter { !$0.proceeded }.count
            let proceeded = attempts.filter { $0.proceeded }.count
            let label = calendar.isDateInToday(day) ? "Today"
                : calendar.weekdaySymbols[calendar.component(.weekday, from: day) - 1]
                    .prefix(3)
                    .description
            return DayStat(date: day, walkedAway: walked, proceeded: proceeded, label: label)
        }
    }

    private var maxDailyCount: Int {
        max(1, last7Days.map { $0.walkedAway + $0.proceeded }.max() ?? 1)
    }

    private var itemStats: [ItemStat] {
        store.blockedItems.map { item in
            let attempts = store.accessAttempts.filter { $0.blockedItemId == item.id }
            let walked = attempts.filter { !$0.proceeded }.count
            return ItemStat(id: item.id, name: item.name, walkedAway: walked, total: attempts.count)
        }
        .filter { $0.total > 0 }
        .sorted { $0.total > $1.total }
    }
}

// MARK: - Supporting types

private struct DayStat {
    let date: Date
    let walkedAway: Int
    let proceeded: Int
    let label: String
}

private struct ItemStat: Identifiable {
    let id: UUID
    let name: String
    let walkedAway: Int
    let total: Int
}

// MARK: - Sub-views

private struct StatChip: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        WhyCard {
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(Color.whySecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct DayBarColumn: View {
    let day: DayStat
    let maxCount: Int

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    if day.walkedAway + day.proceeded == 0 {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.whyDivider)
                            .frame(height: 4)
                    } else {
                        let total = day.walkedAway + day.proceeded
                        let barHeight = geo.size.height * CGFloat(total) / CGFloat(maxCount)
                        let walkedFrac = CGFloat(day.walkedAway) / CGFloat(total)

                        VStack(spacing: 0) {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(Color.whyRose.opacity(0.7))
                                .frame(height: barHeight * (1 - walkedFrac))
                            RoundedRectangle(cornerRadius: 0, style: .continuous)
                                .fill(Color.whySage)
                                .frame(height: barHeight * walkedFrac)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    }
                }
                .frame(height: geo.size.height)
            }

            Text(day.label == "Today" ? "Now" : String(day.label.prefix(1)))
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(Color.whyTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(Color.whySecondary)
        }
    }
}
