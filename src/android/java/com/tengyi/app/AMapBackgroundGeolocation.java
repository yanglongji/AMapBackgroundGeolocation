package com.tengyi.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.telecom.Connection;

import com.amap.api.location.AMapLocation;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by yangl on 2018/3/23.
 */

public class AMapBackgroundGeolocation extends CordovaPlugin {
    public static final String RECEIVER_ACTION = "location_in_background";
    private CallbackContext callbackContext = null;

    @Override
    protected void pluginInitialize() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(RECEIVER_ACTION);
        cordova.getActivity().registerReceiver(locationChangeBroadcastReceiver, intentFilter);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("start")) {
            startLocationService();
        } else if (action.equals("stop")) {
            stopLocationService();
        } else {
            return false;
        }

        this.callbackContext = callbackContext;
        return true;
    }

    @Override
    public void onDestroy() {
        if (locationChangeBroadcastReceiver != null)
            cordova.getActivity().unregisterReceiver(locationChangeBroadcastReceiver);

        super.onDestroy();
    }


    private Connection mLocationServiceConn = null;

    /**
     * 开始定位服务
     */
    private void startLocationService(){
        cordova.getActivity().getApplicationContext().startService(new Intent(cordova.getActivity(), LocationService.class));
        LocationStatusManager.getInstance().resetToInit(cordova.getActivity().getApplicationContext());
    }

    /**
     * 关闭服务
     * 先关闭守护进程，再关闭定位服务
     */
    private void stopLocationService(){
        cordova.getActivity().sendBroadcast(Utils.getCloseBrodecastIntent());
        LocationStatusManager.getInstance().resetToInit(cordova.getActivity().getApplicationContext());
    }

    private BroadcastReceiver locationChangeBroadcastReceiver = new BroadcastReceiver() {

        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(RECEIVER_ACTION)) {
                AMapLocation location = intent.getParcelableExtra("result");
                try {
                    JSONObject obj = new JSONObject();
                    if (null == location) {
                        obj.put("errorInfo", "定位为空");
                        obj.put("errorCode", 1000);
                        sendPluginResult(obj);
                    } else if (location.getErrorCode() == 0) {
                        obj.put("errorCode", 0);
                        obj.put("country", location.getCountry());
                        obj.put("province", location.getProvince());
                        obj.put("city", location.getCity());
                        obj.put("district", location.getDistrict());
                        obj.put("address", location.getAddress());
                        obj.put("lat", location.getLatitude());
                        obj.put("lng", location.getLongitude());
                        sendPluginResult(obj);
                    } else {
                        obj.put("errorInfo", location.getLocationDetail());
                        obj.put("errorCode", location.getErrorCode());
                        sendPluginResult(obj);
                    }
                }catch(JSONException e){

                }
            }
        }
    };

    private void sendPluginResult(JSONObject obj){
        try {
            if(obj.getInt("errorCode") != 0) stopLocationService();
            PluginResult pluginResult = new PluginResult(obj.getInt("errorCode") == 0 ? PluginResult.Status.OK : PluginResult.Status.ERROR, obj);
            pluginResult.setKeepCallback(true);
            this.callbackContext.sendPluginResult(pluginResult);
        }catch(JSONException e){

        }
    }
}
