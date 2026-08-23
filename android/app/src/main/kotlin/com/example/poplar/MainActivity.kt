package com.example.poplar

import android.Manifest
import android.app.role.RoleManager
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterActivity() {

    companion object {
        private const val CALL_SCREENING_ROLE_REQUEST = 1001
        private const val CONTACTS_PERMISSION_REQUEST = 1002
        private const val CHANNEL =
            "com.example.poplar/call_screening"

        private const val PREFS_NAME =
            "poplar_call_screening"

        private const val RESTRICTED_NUMBERS_KEY =
            "restricted_numbers"
    }

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {
        super.onCreate(savedInstanceState)

        requestContactsPermission()
        requestCallScreeningRole()
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "setRestrictedNumbers" -> {
                    val numbers =
                        call.argument<List<String>>("numbers")
                            ?: emptyList()

                    saveRestrictedNumbers(numbers)

                    result.success(null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun saveRestrictedNumbers(
        numbers: List<String>
    ) {
        val preferences =
            getSharedPreferences(
                PREFS_NAME,
                MODE_PRIVATE,
            )

        val jsonArray = JSONArray()

        numbers.forEach { number ->
            jsonArray.put(number)
        }

        preferences.edit()
            .putString(
                RESTRICTED_NUMBERS_KEY,
                jsonArray.toString(),
            )
            .apply()
    }

    private fun requestContactsPermission() {
        if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_CONTACTS,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.READ_CONTACTS,
                ),
                CONTACTS_PERMISSION_REQUEST,
            )
        }
    }

    private fun requestCallScreeningRole() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return
        }

        val roleManager = getSystemService(
            RoleManager::class.java,
        )

        if (
            roleManager != null &&
            roleManager.isRoleAvailable(
                RoleManager.ROLE_CALL_SCREENING,
            ) &&
            !roleManager.isRoleHeld(
                RoleManager.ROLE_CALL_SCREENING,
            )
        ) {
            val intent =
                roleManager.createRequestRoleIntent(
                    RoleManager.ROLE_CALL_SCREENING,
                )

            startActivityForResult(
                intent,
                CALL_SCREENING_ROLE_REQUEST,
            )
        }
    }
}