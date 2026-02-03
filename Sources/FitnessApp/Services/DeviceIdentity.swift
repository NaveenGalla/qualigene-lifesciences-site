import Foundation

enum DeviceIdentity {
    private static let key = "fitnessapp.device.id"

    static func currentId() -> String {
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let generated = UUID().uuidString
        UserDefaults.standard.set(generated, forKey: key)
        return generated
    }
}
