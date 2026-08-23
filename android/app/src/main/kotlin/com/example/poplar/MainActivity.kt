package com.example.poplar

import android.Manifest
import android.app.role.RoleManager
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    companion object {
        private const val CALL_SCREENING_ROLE_REQUEST = 1001
        private const val CONTACTS_PERMISSION_REQUEST = 1002
    }

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {
        super.onCreate(savedInstanceState)

        requestContactsPermission()
        requestCallScreeningRole()
    }

    private fun requestContactsPermission() {
        if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_CONTACTS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.READ_CONTACTS
                ),
                CONTACTS_PERMISSION_REQUEST
            )
        }
    }

    private fun requestCallScreeningRole() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            return
        }

        val roleManager = getSystemService(
            RoleManager::class.java
        )

        if (
            roleManager != null &&
            roleManager.isRoleAvailable(
                RoleManager.ROLE_CALL_SCREENING
            ) &&
            !roleManager.isRoleHeld(
                RoleManager.ROLE_CALL_SCREENING
            )
        ) {
            val intent = roleManager.createRequestRoleIntent(
                RoleManager.ROLE_CALL_SCREENING
            )

            startActivityForResult(
                intent,
                CALL_SCREENING_ROLE_REQUEST
            )
        }
    }
}