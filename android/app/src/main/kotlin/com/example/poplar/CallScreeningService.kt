package com.example.poplar

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import org.json.JSONArray

class CallScreeningService : CallScreeningService() {

    companion object {
        private const val TAG =
            "PoplarCallScreening"

        private const val PREFS_NAME =
            "poplar_call_screening"

        private const val RESTRICTED_NUMBERS_KEY =
            "restricted_numbers"
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

        if (isRestrictedNumber(normalizedNumber)) {
            Log.e(
                TAG,
                "NUMBER IS RESTRICTED - REJECTING",
            )

            rejectCall(callDetails)

            return
        }

        Log.e(
            TAG,
            "NUMBER IS NOT RESTRICTED - ALLOWING",
        )

        allowCall(callDetails)
    }

    private fun isRestrictedNumber(
        number: String,
    ): Boolean {
        val preferences =
            getSharedPreferences(
                PREFS_NAME,
                MODE_PRIVATE,
            )

        val json =
            preferences.getString(
                RESTRICTED_NUMBERS_KEY,
                "[]",
            ) ?: "[]"

        val numbers =
            JSONArray(json)

        for (index in 0 until numbers.length()) {
            val restrictedNumber =
                numbers.getString(index)

            if (
                normalizeKenyanNumber(
                    restrictedNumber,
                ) == number
            ) {
                return true
            }
        }

        return false
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
}