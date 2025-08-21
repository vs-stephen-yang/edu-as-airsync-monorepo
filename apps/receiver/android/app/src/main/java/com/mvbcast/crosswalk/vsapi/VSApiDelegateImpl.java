package com.mvbcast.crosswalk.vsapi;

import android.content.Context;
import android.os.Build;

import androidx.annotation.RequiresApi;

import com.viewsonic.vsapicompat.VSContext;
import com.viewsonic.vsapicompat.VSNetworkManager;
import com.viewsonic.vsapicompat.VSServiceManagerCompat;
import com.viewsonic.vsapicompat.VSSystemManager;

@RequiresApi(api = Build.VERSION_CODES.O)
public class VSApiDelegateImpl implements VSApiDelegate {
    private VSSystemManager vsSystemManager = null;
    private VSNetworkManager vsNetworkManager = null;

    public VSApiDelegateImpl(Context context) {
        try {
            this.vsSystemManager = (VSSystemManager) VSServiceManagerCompat.getService(context, VSContext.VS_SYSTEM_SERVICE);
            this.vsNetworkManager = (VSNetworkManager) VSServiceManagerCompat.getService(context, VSContext.VS_NETWORK_SERVICE);
        } catch (java.lang.NoClassDefFoundError | Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public String getSerialNumber() throws Exception {
        return vsSystemManager != null ? vsSystemManager.getSerialNumber() : "";
    }

    @Override
    public String getEthernetMacAddress() throws Exception {
        return vsNetworkManager != null ? vsNetworkManager.getEthernetMacAddress() : "";
    }
}
