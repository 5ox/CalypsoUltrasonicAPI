package com.kaiserware.ultrasonicanemometerapidemo;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

public class UltrasonicAPI extends BroadcastReceiver {
    static final String LOG_TAG = UltrasonicAPI.class.getSimpleName();
    public final static String ACTION_DATA_AVAILABLE = "com.calypso.api.ACTION_DATA_AVAILABLE";
    public final static String AWA_DATA = "AWA";
    public final static String AWD_DATA = "AWD";
    public final static String AWS_DATA = "AWS";
    public final static String TWA_DATA = "TWA";
    public final static String TWD_DATA = "TWD";
    public final static String TWS_DATA = "TWS";
    public final static String BAT_DATA = "Battery";
    public final static String TEMP_DATA = "Temp";
    public final static String PITCH_DATA = "Pitch";
    public final static String ROLL_DATA = "Roll";
    public final static String COG_DATA = "COG";
    public final static String SOG_DATA = "SOG";
    private static UltrasonicAPI mInstance = null;
    private static Integer parameter;
    private GlobalParameters para;

    public UltrasonicAPI() {
        para = GlobalParameters.getInstance();  // initialize our Global Parameter singleton class
    }

    public static UltrasonicAPI getInstance(Integer param) {
        if (mInstance == null) {
            mInstance = new UltrasonicAPI();
        }
        parameter = param;
        return mInstance;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        String tmp;

        final String action = intent.getAction();

        if (ACTION_DATA_AVAILABLE.equals(action)) {
            para.API = true;

            if (intent.hasExtra(BAT_DATA)) {
                try {
                    tmp = intent.getStringExtra(BAT_DATA);
                    Log.d(LOG_TAG, "API data - Battery: " + tmp);
                    para.bat = Double.parseDouble(tmp);
                    if (Double.isNaN(para.bat)) {
                        Log.e(LOG_TAG, "onReceive() error for Battery: "+tmp);
                    }
                } catch (Exception e) {
                    Log.d(LOG_TAG, "onReceive() Battery failed: " + e.getMessage());
                }
            }

            if (intent.hasExtra(TEMP_DATA)) {
                try {
                    tmp = intent.getStringExtra(TEMP_DATA);
                    Log.d(LOG_TAG, "API data - Temp: " + tmp);
                    para.temp = Double.parseDouble(tmp);
                    if (Double.isNaN(para.temp)) {
                        Log.e(LOG_TAG, "onReceive() error for AWA: "+tmp);
                    }
                } catch (Exception e) {
                    Log.d(LOG_TAG, "onReceive() awa failed: " + e.getMessage());
                }
            }

            if (intent.hasExtra(AWA_DATA)) {
                try {
                    tmp = intent.getStringExtra(AWA_DATA);
                    Log.d(LOG_TAG, "API data - AWA: " + tmp);
                    para.awa = Double.parseDouble(tmp);
                    if (Double.isNaN(para.awa)) {
                        Log.e(LOG_TAG, "onReceive() error for AWA: "+tmp);
                    }
                } catch (Exception e) {
                    Log.d(LOG_TAG, "onReceive() awa failed: " + e.getMessage());
                }
            }
        }

        if (ACTION_DATA_AVAILABLE.equals(action)) {
            if (intent.hasExtra(AWD_DATA)) {
                try {
                    tmp = intent.getStringExtra(AWD_DATA);
                    Log.d(LOG_TAG, "API data - AWD: " + tmp);
                    para.awd = Double.parseDouble(tmp);
                    if (Double.isNaN(para.awd)) {
                        Log.e(LOG_TAG, "onReceive() error for AWD: "+tmp);
                    }
                } catch (Exception e) {
                    Log.d(LOG_TAG, "onReceive() awd failed: " + e.getMessage());
                }
            }
        }

        if (ACTION_DATA_AVAILABLE.equals(action)) {
            if (intent.hasExtra(AWS_DATA)) {
                try {
                    tmp = intent.getStringExtra(AWS_DATA);
                    Log.d(LOG_TAG, "API data - AWS: " + tmp);
                    para.aws = Double.parseDouble(tmp);
                    if (Double.isNaN(para.aws)) {
                        Log.e(LOG_TAG, "onReceive() error for AWS: "+tmp);
                    }
                } catch (Exception e) {
                    Log.d(LOG_TAG, "onReceive() aws failed: " + e.getMessage());
                }
            }
        }

    }

    public static IntentFilter WindexBroadcastReceiverIntentFilter() {
        final IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(ACTION_DATA_AVAILABLE);
        return intentFilter;
    }



}
