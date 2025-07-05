package io.ysmirnov.capacitor.permissions

import android.Manifest
import android.os.Build
import android.util.Log
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.RequiresApi
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
    private var shouldShowNotificationsRationale = false
    private var hasOnGoingNotificationsRequest = false
    private var notificationsRequestCall: PluginCall? = null

    private lateinit var notificationsPermissionLauncher: ActivityResultLauncher<String>

    override fun load() {
        notificationsPermissionLauncher =
            bridge.registerForActivityResult(
                ActivityResultContracts.RequestPermission(),
            ) { granted ->
                val result: String =
                    if (granted) {
                        PermissionStatus.GRANTED.rawValue
                    } else {
                        if (!shouldShowNotificationsRationale &&
                            !ActivityCompat.shouldShowRequestPermissionRationale(activity, PUSH_PERMISSION)
                        ) {
                            PermissionStatus.PERMANENTLY_DENIED.rawValue
                        } else {
                            PermissionStatus.DENIED.rawValue
                        }
                    }

                notificationsRequestCall?.resolve(JSObject().put("result", result))

                shouldShowNotificationsRationale = false
                hasOnGoingNotificationsRequest = false
                notificationsRequestCall = null
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
    public fun checkNotifications(call: PluginCall) {
        val granted = NotificationManagerCompat.from(context.applicationContext).areNotificationsEnabled()

        call.resolve(
            JSObject().put(
                "result",
                if (granted) PermissionStatus.GRANTED.rawValue else PermissionStatus.DENIED.rawValue,
            ),
        )
    }

    @PluginMethod
    public fun shouldShowNotificationsRationale(call: PluginCall) {
        val result: Boolean =
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                false
            } else {
                ActivityCompat.shouldShowRequestPermissionRationale(activity, PUSH_PERMISSION)
            }

        call.resolve(JSObject().put("result", result))
    }

    @PluginMethod
    public fun requestNotifications(call: PluginCall) {
        val granted = NotificationManagerCompat.from(context.applicationContext).areNotificationsEnabled()

        if (granted) {
            call.resolve(JSObject().put("result", PermissionStatus.GRANTED.rawValue))
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            call.resolve(
                JSObject().put("result", PermissionStatus.PERMANENTLY_DENIED.rawValue),
            )

            return
        }

        shouldShowNotificationsRationale = ActivityCompat.shouldShowRequestPermissionRationale(activity, PUSH_PERMISSION)
        hasOnGoingNotificationsRequest = true
        notificationsRequestCall = call

        notificationsPermissionLauncher.launch(PUSH_PERMISSION)
    }

    private companion object {
        @RequiresApi(Build.VERSION_CODES.TIRAMISU)
        private const val PUSH_PERMISSION = Manifest.permission.POST_NOTIFICATIONS
    }
}
