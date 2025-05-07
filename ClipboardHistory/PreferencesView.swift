import SwiftUI

struct PreferencesView: View {
    @AppStorage("maxItems") var maxItems: Int = 50
    @AppStorage("retentionDays") var retentionDays: Int = 7
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false

    var body: some View {
        Form {
            Section(header: Text("General")) {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { LaunchAtLoginManager.setEnabled($0) }
            }
            Section(header: Text("Storage Limits")) {
                Stepper("Max Items: \(maxItems)", value: $maxItems, in: 10...1000)
                Stepper("Retention (days): \(retentionDays)", value: $retentionDays, in: 1...365)
            }
            Section(header: Text("Actions")) {
                Button("Purge Old Entries Now") {
                    do {
                        try PersistenceController.shared.purgeOldEntries(olderThan: retentionDays)
                    } catch {
                        print("Error purging old entries: \(error)")
                    }
                }
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            launchAtLogin = LaunchAtLoginManager.isEnabled()
        }
    }
}
