package com.example.poplar

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log

class CallScreeningService : CallScreeningService() {

    companion object {
        private const val TAG = "PoplarCallScreening"
    }

    override fun onCreate() {
        super.onCreate()

        Log.e(
            TAG,
            "CallScreeningService CREATED"
        )
    }

    override fun onScreenCall(
        callDetails: Call.Details
    ) {
        Log.e(
            TAG,
            "onScreenCall() INVOKED"
        )

        val number = callDetails.handle
            ?.schemeSpecificPart
            ?: run {
                Log.e(
                    TAG,
                    "No phone number available"
                )

                allowCall(callDetails)

                return
            }

        Log.e(
            TAG,
            "Incoming call from: $number"
        )

        if (isRestrictedNumber(number)) {
            Log.e(
                TAG,
                "NUMBER IS RESTRICTED - REJECTING"
            )

            rejectCall(callDetails)

            return
        }

        Log.e(
            TAG,
            "NUMBER IS NOT RESTRICTED - ALLOWING"
        )

        allowCall(callDetails)
    }

    private fun isRestrictedNumber(
        number: String
    ): Boolean {
        val normalizedNumber = normalizeKenyanNumber(number)

        return normalizedNumber == "+254110395040"
    }

    private fun normalizeKenyanNumber(
        number: String
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
        callDetails: Call.Details
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
            response
        )
    }

    private fun allowCall(
        callDetails: Call.Details
    ) {
        respondToCall(
            callDetails,
            CallResponse.Builder()
                .build()
        )
    }
}