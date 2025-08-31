//
//  Created by Yevhenii Smirnov on 20/08/2025.
//

import CoreBluetooth

internal final class Bluetooth: NSObject, CBCentralManagerDelegate {
    internal static let instance = Bluetooth()

    private var centralManager: CBCentralManager?
    private var continuation: CheckedContinuation<PermissionStatus, Never>?

    internal func checkStatus() -> PermissionStatus {
        if #available(iOS 13.1, *) {
            switch CBManager.authorization {
            case .allowedAlways:
                return .granted
            case .denied:
                return .permanentlyDenied
            case .restricted:
                return .denied
            case .notDetermined:
                return .denied
            @unknown default:
                return .denied
            }
        } else {
            return .granted
        }
    }

    internal func requestPermission() async -> PermissionStatus {
        let status = checkStatus()

        if status == .granted || status == .permanentlyDenied {
            return status
        }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }

    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard let continuation = continuation else { return }

        switch central.state {
        case .unsupported, .unauthorized, .unknown:
            continuation.resume(returning: .denied)

        case .poweredOn, .poweredOff, .resetting:
            continuation.resume(returning: .granted)

        @unknown default:
            continuation.resume(returning: .denied)
        }

        self.centralManager = nil
        self.continuation = nil
    }
}
