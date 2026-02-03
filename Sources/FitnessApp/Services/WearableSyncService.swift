import Foundation

enum WearableProvider: String, CaseIterable, Identifiable {
    case apple = "Apple Health"
    case google = "Google Fit"
    case garmin = "Garmin"
    case whoop = "Whoop"
    case fitbit = "Fitbit"
    case oura = "Oura"
    case polar = "Polar"

    var id: String { rawValue }
}

final class WearableSyncService {
    func availableProviders() -> [WearableProvider] {
        WearableProvider.allCases
    }

    func connect(_ provider: WearableProvider) async throws {
        // Placeholder for provider-specific SDK or OAuth setup.
    }
}
