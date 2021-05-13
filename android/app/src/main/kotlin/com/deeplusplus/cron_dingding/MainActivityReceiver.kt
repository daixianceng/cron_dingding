package com.deeplusplus.cron_dingding

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MainActivityReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
      // 自启动
      val i = Intent(context, MainActivity::class.java)
      i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      context.startActivity(i)
    }
  }
}
