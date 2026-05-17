//
//  Created by Yevhenii Smirnov on 20/08/2025.
//

#if PERMISSION_BLUETOOTH

@preconcurrency import CoreBluetooth

internal final class Bluetooth: NSObject, CBCentralManagerDelegate, @unchecked Sendable {
    internal static let instance = Bluetooth()

    @MainActor private var centralManager: CBCentralManager?
    @MainActor private var continuations: [CheckedContinuation<PermissionStatus, Never>] = []

    internal func checkStatus() -> PermissionStatus {
        switch CBManager.authorization {
        case .allowedAlways:
            return .granted
        case .denied:
            return .permanentlyDenied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .denied
        @unknown default:
            return .denied
        }
    }

    @MainActor
    internal func requestPermission() async -> PermissionStatus {
        let status = checkStatus()

        guard status != .granted,
              status != .permanentlyDenied,
              status != .restricted
        else {
            return status
        }

        return await withCheckedContinuation { continuation in
            continuations.append(continuation)

            guard centralManager == nil else { return }

            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }

    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            let status: PermissionStatus

            switch central.state {
            case .unsupported, .unauthorized, .unknown:
                status = .denied

            case .poweredOn, .poweredOff, .resetting:
                status = .granted

            @unknown default:
                status = .denied
            }

            let continuations = self.continuations
            self.continuations.removeAll()
            self.centralManager = nil

            continuations.forEach {
                $0.resume(returning: status)
            }
        }
    }
}

#endif
