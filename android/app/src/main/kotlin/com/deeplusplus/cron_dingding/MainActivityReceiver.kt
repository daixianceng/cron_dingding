package com.deeplusplus.cron_dingding

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.app.KeyguardManager;
import android.os.PowerManager;

class MainActivityReceiver: BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    if (intent.action == Intent.ACTION_BOOT_COMPLETED) {

      val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
      val mWakeLock = powerManager.newWakeLock(PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or
              PowerManager.ON_AFTER_RELEASE, MainActivity::class.java.simpleName) as PowerManager.WakeLock
      mWakeLock.acquire()

      // 屏幕解锁
      val km = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
      val kl = km.newKeyguardLock(MainActivity::class.java.simpleName) as KeyguardManager.KeyguardLock
      kl.disableKeyguard()

      // 自启动
      val i = Intent(context, MainActivity::class.java)
      i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      context.startActivity(i)
    }
  }
}
