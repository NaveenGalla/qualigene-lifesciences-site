import Foundation

enum SyncDecision {
    case useLocal
    case useRemote
    case noChange
}

enum SyncResolver {
    static func decide(local: AppData, remote: AppData) -> SyncDecision {
        if remote.lastModified > local.lastModified {
            return .useRemote
        }
        if local.lastModified > remote.lastModified {
            return .useLocal
        }
        if local.sourceId == remote.sourceId {
            return .noChange
        }
        return .noChange
    }
}
