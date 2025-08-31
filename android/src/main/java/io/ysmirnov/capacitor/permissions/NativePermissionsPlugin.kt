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

    private fun getPermission(call: PluginCall): AppPermission? {
        val permission = call.getString("permission") ?: return null

        return when (permission) {
            "locationForeground" -> AppPermission.LOCATION_FOREGROUND
            "locationBackground" -> AppPermission.LOCATION_BACKGROUND

            else -> AppPermission.entries.firstOrNull { it.name.equals(permission, ignoreCase = true) }
        }
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
