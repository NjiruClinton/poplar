package com.example.poplar

import android.Manifest
import android.app.role.RoleManager
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.net.Uri
import android.provider.ContactsContract
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
        private const val CHANNEL = "com.example.poplar/call_screening"
        private const val PREFS_NAME = "poplar_call_screening"
        private const val RESTRICTED_NUMBERS_KEY = "restricted_numbers"
        private const val REJECTED_CALLS_KEY = "rejected_calls"
        private const val BLOCK_UNKNOWN_KEY = "block_unknown_callers"
        private const val REJECT_ALL_KEY = "reject_all_calls"
        private const val ALLOW_ONLY_SELECTED_KEY = "allow_only_selected"
        private const val ALLOWED_NUMBERS_KEY = "allowed_numbers"
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
                "getRejectedCalls" -> {
                    val calls = getRejectedCalls()

                    result.success(calls)
                }
                "setBlockingPolicy" -> {
                    val blockUnknown = call.argument<Boolean>("blockUnknownCallers") ?: false
                    val rejectAll = call.argument<Boolean>("rejectAllCalls") ?: false
                    val allowOnly = call.argument<Boolean>("allowOnlySelected") ?: false
                    val allowedNumbers = call.argument<List<String>>("allowedNumbers") ?: emptyList()
                    getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit()
                        .putBoolean(BLOCK_UNKNOWN_KEY, blockUnknown)
                        .putBoolean(REJECT_ALL_KEY, rejectAll)
                        .putBoolean(ALLOW_ONLY_SELECTED_KEY, allowOnly)
                        .putStringSet(ALLOWED_NUMBERS_KEY, allowedNumbers.toSet())
                        .apply()
                    result.success(null)
                }
                "clearRejectedCalls" -> {
                    getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit()
                        .remove(REJECTED_CALLS_KEY)
                        .apply()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getRejectedCalls(): List<Map<String, Any>> {
        val preferences =
            getSharedPreferences(
                PREFS_NAME,
                MODE_PRIVATE,
            )

        val json =
            preferences.getString(
                REJECTED_CALLS_KEY,
                "[]",
            ) ?: "[]"

        val jsonArray = JSONArray(json)

        val calls =
            mutableListOf<Map<String, Any>>()
        val resolvedNames = mutableMapOf<String, String?>()

        for (index in 0 until jsonArray.length()) {
            val call =
                jsonArray.getJSONObject(index)

            val phoneNumber = call.getString("phoneNumber")
            val item = mutableMapOf<String, Any>(
                "phoneNumber" to phoneNumber,
                "timestamp" to call.getLong("timestamp"),
                "action" to call.getString("action"),
            )
            val storedName = call.optString("contactName").takeIf { it.isNotBlank() }
            val resolvedName = storedName ?: resolvedNames.getOrPut(phoneNumber) {
                findContactName(phoneNumber)
            }
            resolvedName?.let {
                item["contactName"] = it
            }
            calls.add(item)
        }

        return calls
    }

    private fun findContactName(number: String): String? {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) !=
            PackageManager.PERMISSION_GRANTED) return null
        val uri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            Uri.encode(number),
        )
        return try {
            contentResolver.query(
                uri,
                arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) cursor.getString(0) else null
            }
        } catch (_: SecurityException) {
            null
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

        preferences.edit()
            .remove(RESTRICTED_NUMBERS_KEY)
            .putStringSet(
                RESTRICTED_NUMBERS_KEY,
                numbers.toSet(),
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
