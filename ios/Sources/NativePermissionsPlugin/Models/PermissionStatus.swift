//
//  Created by Yevhenii Smirnov
//

internal enum PermissionStatus: String, CaseIterable {
    case granted = "granted"
    case restricted = "restricted"
    case denied = "denied"
    case permanentlyDenied = "permanently_denied"
}
