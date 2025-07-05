//
//  Created by Yevhenii Smirnov on 05/07/2025.
//

internal enum PermissionStatus: String, CaseIterable {
    case granted = "granted"
    case denied = "denied"
    case permanentlyDenied = "permanently_denied"
}
