package com.mvbcast.crosswalk.helper;


import android.content.Context;
import android.os.Handler;

import com.viewsonic.vsapi.VSStatusCallback;
import com.viewsonic.vsapicompat.VSContext;
import com.viewsonic.vsapicompat.VSPowerManager;
import com.viewsonic.vsapicompat.VSServiceManagerCompat;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class SleepStatus implements VSStatusCallback.ISleepStatusChangedCallback {
    Context _context;
    VSPowerManager _vsPowerManager;
    BinaryMessenger _binaryMessenger;
    MethodChannel _sleepStatusChanged;

    public SleepStatus(Context context, BinaryMessenger messenger) {
        this._context = context;
        this._binaryMessenger = messenger;
        _vsPowerManager = (VSPowerManager) VSServiceManagerCompat.getService(_context, VSContext.VS_POWER_SERVICE);
        _vsPowerManager.registerOnSleepStatusChanged(new Handler(), this);
        _sleepStatusChanged = new MethodChannel(_binaryMessenger, "com.mvbcast.crosswalk/sleep_status");
    }

    @Override
    public void onSleepStatusChanged(boolean b) {
        if (_sleepStatusChanged != null && !b) {
            _sleepStatusChanged.invokeMethod("onSleepStatusChanged", null);
        }
    }

    public void onDestroy() {
        if (_context != null) {
            VSPowerManager.getInstance(_context).unregisterOnSleepStatusChanged(this);
        }
    }
}
