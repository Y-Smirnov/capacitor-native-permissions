package io.ysmirnov.capacitor.permissions

import android.Manifest
import android.os.Build
import android.util.Log
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import io.ysmirnov.capacitor.permissions.models.PermissionStatus

@CapacitorPlugin(name = "NativePermissionsPlugin")
public class NativePermissionsPlugin : Plugin() {
    private var currentRequest: CurrentRequest? = null

    private lateinit var notificationsPermissionLauncher: ActivityResultLauncher<String>

    override fun load() {
        notificationsPermissionLauncher =
            bridge.registerForActivityResult(
                ActivityResultContracts.RequestPermission(),
            ) { granted ->
                val request = currentRequest ?: throw Exception("Activity result without currently ongoing permission")
                val permission =
                    request.permission.manifestValue()
                        ?: throw Exception("Activity result without permission manifest value")

                val result: String =
                    if (granted) {
                        PermissionStatus.GRANTED.rawValue
                    } else {
                        if (request.shouldShowRationale &&
                            !ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
                        ) {
                            PermissionStatus.PERMANENTLY_DENIED.rawValue
                        } else {
                            PermissionStatus.DENIED.rawValue
                        }
                    }

                request.pluginCall.resolve(JSObject().put("result", result))

                currentRequest = null
            }
    }

    @PluginMethod
    public fun echo(call: PluginCall) {
        val value = call.getString("value")
        Log.i("Echo", value!!)

        val ret = JSObject()
        ret.put("value", value)
        call.resolve(ret)
    }

    // Notifications

    @PluginMethod
    public fun check(call: PluginCall) {
        val permission =
            getPermission(call) ?: run {
                call.reject("Missing or invalid 'permission' parameter.")
                return
            }

        val granted =
            when (permission) {
                AppPermission.NOTIFICATIONS -> {
                    NotificationManagerCompat.from(context.applicationContext).areNotificationsEnabled()
                }
            }

        call.resolve(
            JSObject().put(
                "result",
                if (granted) PermissionStatus.GRANTED.rawValue else PermissionStatus.DENIED.rawValue,
            ),
        )
    }

    @PluginMethod
    public fun shouldShowRationale(call: PluginCall) {
        val permission =
            getPermission(call) ?: run {
                call.reject("Missing or invalid 'permission' parameter.")
                return
            }

        val manifestPermission =
            permission.manifestValue() ?: run {
                call.resolve(JSObject().put("result", false))
                return
            }

        val shouldShow = ActivityCompat.shouldShowRequestPermissionRationale(activity, manifestPermission)

        call.resolve(JSObject().put("result", shouldShow))
    }

    @PluginMethod
    public fun request(call: PluginCall) {
        val permission =
            getPermission(call) ?: run {
                call.reject("Missing or invalid 'permission' parameter.")
                return
            }

        val manifestPermission = permission.manifestValue()

        if (manifestPermission.isNullOrEmpty()) {
            var granted = false

            when (permission) {
                AppPermission.NOTIFICATIONS -> {
                    granted = NotificationManagerCompat.from(context.applicationContext).areNotificationsEnabled()
                }
            }

            call.resolve(
                JSObject().put(
                    "result",
                    if (granted) PermissionStatus.GRANTED.rawValue else PermissionStatus.PERMANENTLY_DENIED.rawValue,
                ),
            )

            return
        }

        currentRequest =
            CurrentRequest(
                permission = AppPermission.NOTIFICATIONS,
                shouldShowRationale =
                    ActivityCompat.shouldShowRequestPermissionRationale(
                        activity,
                        manifestPermission,
                    ),
                pluginCall = call,
            )

        notificationsPermissionLauncher.launch(manifestPermission)
    }

    private fun getPermission(call: PluginCall): AppPermission? {
        val permission = call.getString("permission") ?: return null

        return AppPermission.entries.firstOrNull { it.name.equals(permission, ignoreCase = true) }
    }

    private companion object {
        private data class CurrentRequest(
            val permission: AppPermission,
            val shouldShowRationale: Boolean,
            val pluginCall: PluginCall,
        )

        enum class AppPermission {
            NOTIFICATIONS,
            ;

            fun manifestValue(): String? =
                when (this) {
                    NOTIFICATIONS ->
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            Manifest.permission.POST_NOTIFICATIONS
                        } else {
                            null
                        }
                }

            fun isSupported(): Boolean = manifestValue() != null
        }
    }
}
