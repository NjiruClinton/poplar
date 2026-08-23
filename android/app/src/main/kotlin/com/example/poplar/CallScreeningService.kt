package com.example.poplar

import android.telecom.Call
import android.telecom.CallScreeningService

class CallScreeningService : CallScreeningService() {

    override fun onScreenCall(
        callDetails: Call.Details
    ) {
        val number =
            callDetails.handle?.schemeSpecificPart
                ?: return

        val restricted =
            isRestrictedNumber(number)

        if (!restricted) {
            respondToCall(
                callDetails,
                CallResponse.Builder()
                    .build()
            )

            return
        }

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

    private fun isRestrictedNumber(
        number: String
    ): Boolean {
        return number == "+254110395040"
    }
}