package io.ysmirnov.capacitor.permissions.models

internal enum class PermissionStatus {
    DENIED,
    GRANTED,
    PERMANENTLY_DENIED,
    ;

    internal val rawValue: String
        get() =
            when (this) {
                DENIED -> "denied"
                GRANTED -> "granted"
                PERMANENTLY_DENIED -> "permanently_denied"
            }
}
