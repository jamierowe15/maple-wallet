import Core
import SwiftUI
import WidgetKit

struct BalanceEntry: TimelineEntry {
    let date: Date
    let accountName: String
    let balance: String
}

struct BalanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry {
        BalanceEntry(date: .now, accountName: "Everyday Chequing", balance: "$1,234.56")
    }

    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceEntry>) -> Void) {
        completion(Timeline(entries: [loadEntry()], policy: .after(.now.addingTimeInterval(30 * 60))))
    }

    private func loadEntry() -> BalanceEntry {
        guard let data = UserDefaults(suiteName: WidgetSnapshot.appGroup)?.data(forKey: WidgetSnapshot.defaultsKey),
              let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data) else {
            return BalanceEntry(date: .now, accountName: "Maple Wallet", balance: "Open the app")
        }
        return BalanceEntry(date: snapshot.updatedAt, accountName: snapshot.accountName,
                            balance: snapshot.balance.formatted())
    }
}

struct BalanceWidgetView: View {
    let entry: BalanceEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.accountName)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(entry.balance)
                .font(.title3.bold().monospacedDigit())
                .minimumScaleFactor(0.7)
                .privacySensitive() // redacted on the Lock Screen / when locked
            Spacer()
            Text(entry.date, style: .relative)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "maplewallet://accounts"))
    }
}

@main
struct BalanceWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BalanceWidget", provider: BalanceProvider()) { entry in
            BalanceWidgetView(entry: entry)
        }
        .configurationDisplayName("Balance")
        .description("Your main account balance.")
        .supportedFamilies([.systemSmall])
    }
}
