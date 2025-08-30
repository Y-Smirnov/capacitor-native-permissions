//
//  Created by Yevhenii Smirnov on 26/08/2025.
//

import Foundation

public enum NativePermissionsError: Error {
    case noPermissionOptions
    case invalidPermissionOptions
    case invalidRequestSequence(message: String)
}
