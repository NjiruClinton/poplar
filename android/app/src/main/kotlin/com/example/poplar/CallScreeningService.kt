package com.example.poplar

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import android.net.Uri
import android.provider.ContactsContract
import org.json.JSONArray

class CallScreeningService : CallScreeningService() {

    companion object {
        private const val TAG = "PoplarCallScreening"
        private const val PREFS_NAME = "poplar_call_screening"
        private const val RESTRICTED_NUMBERS_KEY = "restricted_numbers"
        private const val REJECTED_CALLS_KEY = "rejected_calls"
        private const val BLOCK_UNKNOWN_KEY = "block_unknown_callers"
        private const val MAX_LOG_ENTRIES = 500
    }

    override fun onCreate() {
        super.onCreate()

        Log.e(
            TAG,
            "CallScreeningService CREATED",
        )
    }

    override fun onScreenCall(
        callDetails: Call.Details,
    ) {
        Log.e(
            TAG,
            "onScreenCall() INVOKED",
        )

        val number =
            callDetails.handle
                ?.schemeSpecificPart
                ?: run {
                    Log.e(
                        TAG,
                        "No phone number available",
                    )

                    allowCall(callDetails)

                    return
                }

        Log.e(
            TAG,
            "Incoming call from: $number",
        )

        val normalizedNumber =
            normalizeKenyanNumber(number)

        Log.e(
            TAG,
            "Normalized number: $normalizedNumber",
        )

        if (isRestrictedNumber(normalizedNumber) || shouldBlockUnknown(number)) {
            Log.e(
                TAG,
                "NUMBER IS RESTRICTED - REJECTING",
            )

            rejectCall(callDetails)

            logRejectedCall(
                normalizedNumber,
            )

            return
        }

        Log.e(
            TAG,
            "NUMBER IS NOT RESTRICTED - ALLOWING",
        )

        allowCall(callDetails)
    }

    private fun shouldBlockUnknown(number: String): Boolean {
        val enabled = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
            .getBoolean(BLOCK_UNKNOWN_KEY, false)
        if (!enabled) return false

        val lookupUri = Uri.withAppendedPath(
            ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
            Uri.encode(number),
        )
        return try {
            contentResolver.query(
                lookupUri,
                arrayOf(ContactsContract.PhoneLookup._ID),
                null,
                null,
                null,
            )?.use { cursor -> !cursor.moveToFirst() } ?: true
        } catch (error: SecurityException) {
            Log.w(TAG, "Cannot check contacts; allowing call", error)
            false
        }
    }

    private fun isRestrictedNumber(
        number: String,
    ): Boolean {
        val preferences =
            getSharedPreferences(
                PREFS_NAME,
                MODE_PRIVATE,
            )

        return try {
            preferences.getStringSet(RESTRICTED_NUMBERS_KEY, emptySet())
                ?.contains(number) == true
        } catch (_: ClassCastException) {
            // Supports data written by versions that stored this value as JSON.
            val legacy = JSONArray(preferences.getString(RESTRICTED_NUMBERS_KEY, "[]"))
            (0 until legacy.length()).any {
                normalizeKenyanNumber(legacy.getString(it)) == number
            }
        }
    }

    private fun normalizeKenyanNumber(
        number: String,
    ): String {
        val value = number
            .trim()
            .replace(" ", "")
            .replace("-", "")
            .replace("(", "")
            .replace(")", "")

        return when {
            value.startsWith("+254") -> {
                value
            }

            value.startsWith("254") -> {
                "+$value"
            }

            value.startsWith("0") -> {
                "+254${value.substring(1)}"
            }

            else -> {
                value
            }
        }
    }

    private fun rejectCall(
        callDetails: Call.Details,
    ) {
        val response =
            CallResponse.Builder()
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSkipCallLog(false)
                .setSkipNotification(true)
                .build()

        respondToCall(
            callDetails,
            response,
        )
    }

    private fun allowCall(
        callDetails: Call.Details,
    ) {
        respondToCall(
            callDetails,
            CallResponse.Builder()
                .build(),
        )
    }

    private fun logRejectedCall(
        number: String,
    ) {
        val preferences =
            getSharedPreferences(
                PREFS_NAME,
                MODE_PRIVATE,
            )

        val existingJson =
            preferences.getString(
                REJECTED_CALLS_KEY,
                "[]",
            ) ?: "[]"

        val existingCalls =
            JSONArray(existingJson)

        val call = org.json.JSONObject()

        call.put(
            "phoneNumber",
            number,
        )

        call.put(
            "timestamp",
            System.currentTimeMillis(),
        )

        call.put(
            "action",
            "rejected",
        )

        val cappedCalls = JSONArray()
        val start = maxOf(0, existingCalls.length() - MAX_LOG_ENTRIES + 1)
        for (index in start until existingCalls.length()) {
            cappedCalls.put(existingCalls.get(index))
        }
        cappedCalls.put(call)

        preferences.edit()
            .putString(
                REJECTED_CALLS_KEY,
                cappedCalls.toString(),
            )
            .apply()
    }
}
