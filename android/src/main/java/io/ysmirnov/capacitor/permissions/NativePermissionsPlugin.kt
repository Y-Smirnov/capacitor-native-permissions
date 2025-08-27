package io.ysmirnov.capacitor.permissions

import android.Manifest
import android.content.pm.PackageManager
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
    private lateinit var permissionsLauncher: ActivityResultLauncher<Array<String>>

    override fun load() {
        permissionsLauncher =
            bridge.registerForActivityResult(
                ActivityResultContracts.RequestMultiplePermissions(),
            ) { permissions ->
                val request = currentRequest ?: throw Exception("Activity result without currently ongoing permission")

                val status =
                    permissions
                        .all { it.value }
                        .let { granted ->
                            if (granted) {
                                PermissionStatus.GRANTED
                            } else {
                                val manifestValues =
                                    request.manifestValues.firstOrNull()
                                        ?: throw Exception("Activity result without permission manifest value")

                                if (!request.shouldShowRationale &&
                                    !ActivityCompat.shouldShowRequestPermissionRationale(
                                        activity,
                                        permissions.keys.first(),
                                    )
                                ) {
                                    PermissionStatus.PERMANENTLY_DENIED
                                } else {
                                    PermissionStatus.DENIED
                                }
                            }
                        }

                request.pluginCall.resolve(JSObject().put("result", status.rawValue))

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

    @PluginMethod
    public fun check(call: PluginCall) {
        val permission =
            getPermission(call) ?: run {
                call.reject("Missing or invalid 'permission' parameter.")
                return
            }

        val options = getOptions(call)
        val manifestValues = permission.manifestValues(options)

        val granted =
            when (permission) {
                AppPermission.NOTIFICATIONS -> {
                    NotificationManagerCompat.from(context.applicationContext).areNotificationsEnabled()
                }

                else ->
                    manifestValues?.all { manifestValues ->
                        ActivityCompat.checkSelfPermission(activity, manifestValues) == PackageManager.PERMISSION_GRANTED
                    } ?: true
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

        val options = getOptions(call)
        val manifestPermissions =
            permission.manifestValues(options) ?: run {
                call.resolve(JSObject().put("result", false))
                return
            }

        if (manifestPermissions.isEmpty()) {
            call.resolve(JSObject().put("result", false))
        } else {
            val shouldShow = ActivityCompat.shouldShowRequestPermissionRationale(activity, manifestPermissions.first())
            call.resolve(JSObject().put("result", shouldShow))
        }
    }

    @PluginMethod
    public fun request(call: PluginCall) {
        val permission =
            getPermission(call) ?: run {
                call.reject("Missing or invalid 'permission' parameter.")
                return
            }

        val options = getOptions(call)
        val manifestValues = permission.manifestValues(options)

        if (manifestValues.isNullOrEmpty()) {
            when (permission) {
                AppPermission.NOTIFICATIONS -> {
                    val granted = NotificationManagerCompat.from(context.applicationContext).areNotificationsEnabled()

                    call.resolve(
                        JSObject().put(
                            "result",
                            if (granted) PermissionStatus.GRANTED.rawValue else PermissionStatus.PERMANENTLY_DENIED.rawValue,
                        ),
                    )

                    return
                }

                else -> {
                    call.resolve(
                        JSObject().put(
                            "result",
                            PermissionStatus.GRANTED.rawValue,
                        ),
                    )

                    return
                }
            }
        }

        currentRequest =
            CurrentRequest(
                manifestValues = manifestValues,
                shouldShowRationale =
                    ActivityCompat.shouldShowRequestPermissionRationale(
                        activity,
                        manifestValues.first(),
                    ),
                pluginCall = call,
            )

        permissionsLauncher.launch(manifestValues.toTypedArray())
    }

    private fun getPermission(call: PluginCall): AppPermission? {
        val permission = call.getString("permission") ?: return null

        return AppPermission.entries.firstOrNull { it.name.equals(permission, ignoreCase = true) }
    }

    private fun getOptions(call: PluginCall): Array<String>? {
        val jsArray = call.getArray("options") ?: return null
        val list = mutableListOf<String>()

        for (i in 0 until jsArray.length()) {
            list.add(jsArray.optString(i))
        }

        return list.toTypedArray()
    }

    private companion object {
        private data class CurrentRequest(
            val manifestValues: List<String>,
            val shouldShowRationale: Boolean,
            val pluginCall: PluginCall,
        )

        enum class AppPermission {
            NOTIFICATIONS,
            BLUETOOTH,
            CALENDAR,
            CAMERA,
            CONTACTS,
            ;

            fun manifestValues(options: Array<String>? = null): List<String>? {
                return when (this) {
                    NOTIFICATIONS ->
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            listOf(Manifest.permission.POST_NOTIFICATIONS)
                        } else {
                            null
                        }

                    BLUETOOTH ->
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val options = options ?: throw Exception("Missing bluetooth permission options")

                            options.mapNotNull { opt ->
                                when (opt.uppercase()) {
                                    "SCAN" -> Manifest.permission.BLUETOOTH_SCAN
                                    "ADVERTISE" -> Manifest.permission.BLUETOOTH_ADVERTISE
                                    "CONNECT" -> Manifest.permission.BLUETOOTH_CONNECT
                                    else -> null
                                }
                            }
                        } else {
                            null
                        }

                    CALENDAR -> {
                        val options = options ?: throw Exception("Missing calendar permission options")

                        val manifestValues =
                            options.mapNotNull { opt ->
                                when (opt.uppercase()) {
                                    "READ" -> Manifest.permission.READ_CALENDAR
                                    "WRITE" -> Manifest.permission.WRITE_CALENDAR
                                    else -> null
                                }
                            }

                        return if (!manifestValues.isEmpty()) manifestValues else null
                    }

                    CAMERA -> listOf(Manifest.permission.CAMERA)

                    CONTACTS -> listOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR)
                }
            }

            fun isSupported(): Boolean = manifestValues() != null
        }
    }
}
