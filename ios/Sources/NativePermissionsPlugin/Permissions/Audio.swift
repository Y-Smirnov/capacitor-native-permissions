//
//  Created by Yevhenii Smirnov on 30/08/2025.
//

#if PERMISSION_RECORD

import AVFoundation

internal final class Audio {
    internal static let instance = Audio()

    internal func checkRecordPermission() -> PermissionStatus {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return .granted
        case .denied:
            return .permanentlyDenied
        case .undetermined:
            return .denied
        @unknown default:
            return .denied
        }
    }

    internal func requestRecordPermission() async -> PermissionStatus {
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    continuation.resume(returning: .granted)
                } else {
                    continuation.resume(returning: .denied)
                }
            }
        }
    }
}

#endif
