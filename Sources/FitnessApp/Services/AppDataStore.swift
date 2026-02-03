import Foundation
import SwiftUI

final class AppDataStore: ObservableObject {
    @Published private(set) var users: [UserProfile] = []
    @Published private(set) var notes: [CoachNote] = []
    @Published private(set) var tags: [String] = []
    @Published private(set) var thresholds: [UserThresholds] = []
    @Published private(set) var syncState: SyncState = .idle
    @Published private(set) var lastSyncDate: Date? = nil

    private let fileName = "appdata.json"
    private let cloudService = CloudKitService()
    private var isApplyingRemote = false
    private var lastModified: Date = Date()
    private let sourceId = DeviceIdentity.currentId()

    init() {
        load()
        seedIfNeeded()
        Task { await syncFromCloud() }
    }

    func addNote(for userId: UUID, text: String, tags: [String]) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        notes.insert(CoachNote(userId: userId, text: trimmed, tags: tags), at: 0)
        persist()
    }

    func deleteNote(_ note: CoachNote) {
        notes.removeAll { $0.id == note.id }
        persist()
    }

    func addTag(_ tag: String) {
        let normalized = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        if !tags.contains(normalized) {
            tags.append(normalized)
            tags.sort()
            persist()
        }
    }

    func notes(for userId: UUID) -> [CoachNote] {
        notes.filter { $0.userId == userId }.sorted { $0.date > $1.date }
    }

    func addUser(name: String, age: Int, initials: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let user = UserProfile(id: UUID(), name: trimmed, age: age, avatarInitials: initials.uppercased())
        users.append(user)
        thresholds.append(UserThresholds(id: user.id))
        persist()
    }

    func updateUser(_ user: UserProfile) {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        users[index] = user
        persist()
    }

    func deleteUser(_ user: UserProfile) {
        users.removeAll { $0.id == user.id }
        notes.removeAll { $0.userId == user.id }
        thresholds.removeAll { $0.id == user.id }
        persist()
    }

    func thresholds(for userId: UUID) -> UserThresholds {
        if let existing = thresholds.first(where: { $0.id == userId }) {
            return existing
        }
        let created = UserThresholds(id: userId)
        thresholds.append(created)
        persist()
        return created
    }

    func updateThresholds(_ updated: UserThresholds) {
        if let index = thresholds.firstIndex(where: { $0.id == updated.id }) {
            thresholds[index] = updated
        } else {
            thresholds.append(updated)
        }
        persist()
    }

    // MARK: - Persistence

    private func load() {
        guard let url = storageURL(),
              let data = try? Data(contentsOf: url)
        else { return }

        if let decoded = try? JSONDecoder().decode(AppData.self, from: data) {
            users = decoded.users
            notes = decoded.notes
            tags = decoded.tags
            thresholds = decoded.thresholds
            lastModified = decoded.lastModified
            lastSyncDate = decoded.lastSyncDate
        }
    }

    private func persist() {
        guard let url = storageURL() else { return }
        if !isApplyingRemote {
            lastModified = Date()
        }
        let payload = AppData(
            users: users,
            notes: notes,
            tags: tags,
            thresholds: thresholds,
            lastModified: lastModified,
            lastSyncDate: lastSyncDate,
            sourceId: sourceId
        )
        if let data = try? JSONEncoder().encode(payload) {
            try? data.write(to: url, options: [.atomic])
        }
        guard !isApplyingRemote else { return }
        Task { await syncToCloud(payload) }
    }

    private func seedIfNeeded() {
        guard users.isEmpty else { return }
        users = [
            UserProfile(id: UUID(), name: "Avery", age: 28, avatarInitials: "AV"),
            UserProfile(id: UUID(), name: "Jordan", age: 34, avatarInitials: "JD"),
            UserProfile(id: UUID(), name: "Riley", age: 41, avatarInitials: "RL")
        ]
        tags = ["Recovery", "Training", "Nutrition", "Sleep", "Mood"]
        thresholds = users.map { UserThresholds(id: $0.id) }
        lastModified = Date()
        persist()
    }

    private func storageURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    }

    private func applyRemote(_ payload: AppData) {
        isApplyingRemote = true
        users = payload.users
        notes = payload.notes
        tags = payload.tags
        thresholds = payload.thresholds
        lastModified = payload.lastModified
        lastSyncDate = payload.lastSyncDate
        persist()
        isApplyingRemote = false
    }

    private func syncFromCloud() async {
        syncState = .syncing
        do {
            if let remote = try await cloudService.fetchAppData() {
                let local = AppData(
                    users: users,
                    notes: notes,
                    tags: tags,
                    thresholds: thresholds,
                    lastModified: lastModified,
                    lastSyncDate: lastSyncDate,
                    sourceId: sourceId
                )

                let decision = SyncResolver.decide(local: local, remote: remote)
                switch decision {
                case .useRemote:
                    applyRemote(remote)
                case .useLocal:
                    await syncToCloud(local)
                case .noChange:
                    break
                }
            }
            lastSyncDate = Date()
            syncState = .synced
            persist()
        } catch {
            syncState = .error
        }
    }

    private func syncToCloud(_ payload: AppData) async {
        syncState = .syncing
        do {
            try await cloudService.saveAppData(payload)
            lastSyncDate = Date()
            syncState = .synced
        } catch {
            syncState = .error
        }
    }
}

struct AppData: Codable {
    let users: [UserProfile]
    let notes: [CoachNote]
    let tags: [String]
    let thresholds: [UserThresholds]
    let lastModified: Date
    let lastSyncDate: Date?
    let sourceId: String
}

extension AppDataStore {
    static func performBackgroundSync() async {
        let cloudService = CloudKitService()
        let fileName = "appdata.json"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)

        let local: AppData? = {
            guard let url, let data = try? Data(contentsOf: url) else { return nil }
            return try? JSONDecoder().decode(AppData.self, from: data)
        }()

        if let remote = try? await cloudService.fetchAppData() {
            if let local, SyncResolver.decide(local: local, remote: remote) == .useLocal {
                try? await cloudService.saveAppData(local)
            } else if let url, let data = try? JSONEncoder().encode(remote) {
                try? data.write(to: url, options: [.atomic])
            }
        } else if let local {
            try? await cloudService.saveAppData(local)
        }
    }
}
