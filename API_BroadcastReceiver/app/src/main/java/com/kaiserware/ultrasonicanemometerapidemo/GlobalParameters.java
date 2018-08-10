package com.kaiserware.ultrasonicanemometerapidemo;

public class GlobalParameters {
    private static GlobalParameters mInstance = null;
    public double awa, awd, aws, twa, twd, tws, bat, temp;
    public boolean API;

    private GlobalParameters() {
        aws = 0.0d;
    }

    public static synchronized GlobalParameters getInstance() {
        if (mInstance == null) {
            mInstance = new GlobalParameters();
        }
        return mInstance;
    }

}
