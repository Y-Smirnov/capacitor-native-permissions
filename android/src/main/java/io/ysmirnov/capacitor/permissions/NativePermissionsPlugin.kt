package io.ysmirnov.capacitor.permissions

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
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
    private var settingsCallId: String? = null
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

    override fun handleOnResume() {
        super.handleOnResume()

        settingsCallId?.let { id ->
            val call = bridge.getSavedCall(id)

            if (call != null) {
                call.resolve()
                bridge.releaseCall(call)
            }

            settingsCallId = null
        }
    }

    @PluginMethod
    public fun check(call: PluginCall) {
        val permission =
            getPermission(call) ?: run {
                call.reject("Missing or invalid 'permission' parameter.")
                return
            }

        val manifestValues = permission.manifestValues(context)

        val granted =
            when (permission) {
                AppPermission.NOTIFICATIONS -> {
                    NotificationManagerCompat.from(context.applicationContext).areNotificationsEnabled()
                }

                else ->
                    manifestValues?.all { manifestPerm ->
                        ActivityCompat.checkSelfPermission(
                            activity,
                            manifestPerm,
                        ) == PackageManager.PERMISSION_GRANTED
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

        val manifestPermissions =
            permission.manifestValues(context) ?: run {
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
    public fun showRationale(call: PluginCall) {
        val title = call.getString("title")
        val message = call.getString("message")

        if (title == null || message == null) {
            call.reject("Title and message are required.")
            return
        }

        val positiveButton = call.getString("positiveButton") ?: "OK"
        val negativeButton = call.getString("negativeButton")

        activity.runOnUiThread {
            val builder =
                AlertDialog
                    .Builder(context)
                    .setTitle(title)
                    .setMessage(message)
                    .setCancelable(false)

            builder.setPositiveButton(positiveButton) { dialog, _ ->
                dialog.dismiss()
                call.resolve(JSObject().put("result", true))
            }

            if (negativeButton != null) {
                builder.setNegativeButton(negativeButton) { dialog, _ ->
                    dialog.dismiss()
                    call.resolve(JSObject().put("result", false))
                }
            }

            builder.show()
        }
    }

    @PluginMethod
    public fun request(call: PluginCall) {
        val permission =
            getPermission(call) ?: run {
                call.reject("Missing or invalid 'permission' parameter.")
                return
            }

        val manifestValues = permission.manifestValues(context)

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

    @PluginMethod
    public fun openAppSettings(call: PluginCall) {
        val intent =
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", context.packageName, null)
            }

        // Save call so we can resolve later
        bridge.saveCall(call)
        settingsCallId = call.callbackId

        activity.startActivity(intent)
    }

    private fun getPermission(call: PluginCall): AppPermission? {
        val permission = call.getString("permission") ?: return null

        return when (permission) {
            "locationForeground" -> AppPermission.LOCATION_FOREGROUND
            "locationBackground" -> AppPermission.LOCATION_BACKGROUND

            else -> AppPermission.entries.firstOrNull { it.name.equals(permission, ignoreCase = true) }
        }
    }

    private companion object {
        private data class CurrentRequest(
            val manifestValues: List<String>,
            val shouldShowRationale: Boolean,
            val pluginCall: PluginCall,
        )
    }

    private enum class AppPermission {
        NOTIFICATIONS,
        BLUETOOTH,
        CALENDAR,
        CAMERA,
        CONTACTS,
        MEDIA,
        RECORD,
        LOCATION_FOREGROUND,
        LOCATION_BACKGROUND,
        ;

        fun manifestValues(pluginContext: android.content.Context): List<String>? {
            val declared: (Array<out String>) -> List<String> = { perms ->
                val pm = pluginContext.packageManager
                val pkgName = pluginContext.packageName

                val requested: Array<String>? =
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        pm
                            .getPackageInfo(
                                pkgName,
                                PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()),
                            ).requestedPermissions
                    } else {
                        @Suppress("DEPRECATION")
                        pm.getPackageInfo(pkgName, PackageManager.GET_PERMISSIONS).requestedPermissions
                    }

                val set = requested?.toSet() ?: emptySet()
                perms.filter { set.contains(it) }
            }

            return when (this) {
                NOTIFICATIONS ->
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val list = declared(arrayOf(Manifest.permission.POST_NOTIFICATIONS))

                        list.ifEmpty { null }
                    } else {
                        null
                    }

                BLUETOOTH ->
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val list =
                            declared(
                                arrayOf(
                                    Manifest.permission.BLUETOOTH_SCAN,
                                    Manifest.permission.BLUETOOTH_ADVERTISE,
                                    Manifest.permission.BLUETOOTH_CONNECT,
                                ),
                            )

                        list.ifEmpty { null }
                    } else {
                        null
                    }

                CALENDAR -> {
                    val list =
                        declared(
                            arrayOf(
                                Manifest.permission.READ_CALENDAR,
                                Manifest.permission.WRITE_CALENDAR,
                            ),
                        )

                    list.ifEmpty { null }
                }

                CAMERA -> {
                    val list = declared(arrayOf(Manifest.permission.CAMERA))
                    list.ifEmpty { null }
                }

                CONTACTS -> {
                    val list =
                        declared(
                            arrayOf(
                                Manifest.permission.READ_CONTACTS,
                                Manifest.permission.WRITE_CONTACTS,
                            ),
                        )

                    list.ifEmpty { null }
                }

                MEDIA ->
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                        val list =
                            declared(
                                arrayOf(
                                    Manifest.permission.READ_MEDIA_IMAGES,
                                    Manifest.permission.READ_MEDIA_VIDEO,
                                    Manifest.permission.READ_MEDIA_VISUAL_USER_SELECTED,
                                ),
                            )

                        list.ifEmpty { null }
                    } else if (Build.VERSION.SDK_INT == Build.VERSION_CODES.TIRAMISU) {
                        val list =
                            declared(
                                arrayOf(
                                    Manifest.permission.READ_MEDIA_IMAGES,
                                    Manifest.permission.READ_MEDIA_VIDEO,
                                ),
                            )

                        list.ifEmpty { null }
                    } else {
                        val list = declared(arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE))
                        list.ifEmpty { null }
                    }

                RECORD -> {
                    val list = declared(arrayOf(Manifest.permission.RECORD_AUDIO))
                    list.ifEmpty { null }
                }

                LOCATION_FOREGROUND -> {
                    val list =
                        declared(
                            arrayOf(
                                Manifest.permission.ACCESS_COARSE_LOCATION,
                                Manifest.permission.ACCESS_FINE_LOCATION,
                            ),
                        )

                    list.ifEmpty { null }
                }

                LOCATION_BACKGROUND -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val list = declared(arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION))
                        list.ifEmpty { null }
                    } else {
                        val list =
                            declared(
                                arrayOf(
                                    Manifest.permission.ACCESS_COARSE_LOCATION,
                                    Manifest.permission.ACCESS_FINE_LOCATION,
                                ),
                            )

                        list.ifEmpty { null }
                    }
                }
            }
        }

        fun AppPermission.isSupported(context: android.content.Context): Boolean = manifestValues(context) != null
    }
}
