package com.mvbcast.crosswalk.vsapi;

import android.content.Context;
import android.os.Build;
import androidx.annotation.RequiresApi;
import com.viewsonic.vsapicompat.VSNetworkManager;
import com.viewsonic.vsapicompat.VSSystemManager;

@RequiresApi(api = Build.VERSION_CODES.O)
public class VSApiDelegateImpl implements VSApiDelegate {
    private final VSSystemManager vsSystemManager;
    private final VSNetworkManager vsNetworkManager;

    public VSApiDelegateImpl(Context context) {
        this.vsSystemManager = VSSystemManager.getInstance(context);
        this.vsNetworkManager = VSNetworkManager.getInstance(context);
    }

    @Override
    public String getSerialNumber() throws Exception {
        return vsSystemManager.getSerialNumber();
    }

    @Override
    public String getEthernetMacAddress() throws Exception {
        return vsNetworkManager.getEthernetMacAddress();
    }
}
