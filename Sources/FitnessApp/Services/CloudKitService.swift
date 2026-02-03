import Foundation
import CloudKit

final class CloudKitService {
    private let container: CKContainer
    private let database: CKDatabase
    private let recordID = CKRecord.ID(recordName: "appdata-singleton")
    private let recordType = "AppData"

    init(containerIdentifier: String = "iCloud.com.fitnessapp") {
        self.container = CKContainer(identifier: containerIdentifier)
        self.database = container.privateCloudDatabase
    }

    func fetchAppData() async throws -> AppData? {
        try await withCheckedThrowingContinuation { continuation in
            database.fetch(withRecordID: recordID) { record, error in
                if let error = error as? CKError, error.code == .unknownItem {
                    continuation.resume(returning: nil)
                    return
                }
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let record, let data = record["payload"] as? Data else {
                    continuation.resume(returning: nil)
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(AppData.self, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func saveAppData(_ appData: AppData) async throws {
        let record = CKRecord(recordType: recordType, recordID: recordID)
        let encoder = JSONEncoder()
        let data = try encoder.encode(appData)
        record["payload"] = data as CKRecordValue

        try await withCheckedThrowingContinuation { continuation in
            database.save(record) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
