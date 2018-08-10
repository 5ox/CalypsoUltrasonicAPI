package com.kaiserware.ultrasonicanemometerapidemo;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.widget.TextView;
import android.widget.Toast;

import static com.kaiserware.ultrasonicanemometerapidemo.UltrasonicAPI.LOG_TAG;

public class MainActivity extends Activity {
    private GlobalParameters para;
    private Context appContext;                 // object holding the App Context
    private TextView outputAWA;                 // output Textfield for the AWA value
    private TextView outputAWD;                 // output Textfield for the AWD value
    private TextView outputAWS;                 // output Textfield for the AWS value
    private TextView outputTWA;                 // output Textfield for the TWA value
    private TextView outputTWD;                 // output Textfield for the TWD value
    private TextView outputTWS;                 // output Textfield for the TWS value
    private TextView outputBat;                 // output Textfield for the Battery value
    private TextView outputTemp;                // output Textfield for the Temperature value
    private Double toKnots = 1.943844492;	   // m/s to knots conversion -> 1.943844492 kts per m/s
    private static int screenUpdates=1000;      // screen update frequency in milli-seconds.
    private Handler ScreenUpdate=new Handler(); // Handler to implement the Runnable for the Screen Updates
    private boolean apiBackgroundServices;
    private BroadcastReceiver WindexBroadcastReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        para = GlobalParameters.getInstance();  // initialize our Global Parameter singleton class
        appContext = getApplicationContext();
        setTitle(R.string.app_name_TM);

        outputAWA = (TextView) findViewById(R.id.awa);
        outputAWD = (TextView) findViewById(R.id.awd);
        outputAWS = (TextView) findViewById(R.id.aws);
        outputTWA = (TextView) findViewById(R.id.twa);
        outputTWD = (TextView) findViewById(R.id.twd);
        outputTWS = (TextView) findViewById(R.id.tws);
        outputBat = (TextView) findViewById(R.id.battery);
        outputTemp = (TextView) findViewById(R.id.temp);

        para.API = false;
        apiBackgroundServices = false;

        para.awa = 0.0d;
        para.awd = 0.0d;
        para.aws = 0.0d;
        para.twa = 0.0d;
        para.twd = 0.0d;
        para.tws = 0.0d;
        para.bat = 0.0d;
        para.temp = 0.0d;

    }


    @Override
    protected void onResume() {
        super.onResume();
        ScreenUpdate.post(updateScreenNow);

        // launch the App Background Services to get the data from the Wind Anemometer
        if (!apiBackgroundServices) {
            apiBackgroundServices = true;
            int dataUpdates = 1000;
            try {
                WindexBroadcastReceiver = UltrasonicAPI.getInstance(dataUpdates);
                appContext.registerReceiver(WindexBroadcastReceiver, UltrasonicAPI.WindexBroadcastReceiverIntentFilter());
            } catch (Exception e) {
                String msg = "Error initializing the UltrasonicAPI WindexBroadcastReceiver.";
                msg += "\nMake sure the UltrasonicAPI is running and connected to the Anemometer.";
                Toast.makeText(appContext, msg, Toast.LENGTH_LONG);
                Log.e(LOG_TAG, "Error registering the UltrasonicAPI WindexBroadcastReceiver: " + e.getMessage());
            }
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        ScreenUpdate.removeCallbacks(updateScreenNow);   // stop the ScreenUpdate Handler Runnable
    }


    public Runnable updateScreenNow = new Runnable() {
        public void run() {

            outputAWA.setText(String.format("%03.0f\u00B0", para.awa));
            outputAWD.setText(String.format("%03.0f\u00B0", para.awd));
            outputAWS.setText(String.format("%01.1f", para.aws*toKnots));

            outputTWA.setText(String.format("%03.0f\u00B0", para.twa));
            outputTWD.setText(String.format("%03.0f\u00B0", para.twd));
            outputTWS.setText(String.format("%01.1f", para.tws*toKnots));

            outputBat.setText(String.format("%01.0f", para.bat)+"%");
            outputTemp.setText(String.format("%1.1f\u00B0C", para.temp));

            // set the screen display frequency
            ScreenUpdate.postDelayed(this, (long) (screenUpdates));
        }
    };


    @Override
    protected void onStop() {
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

    }
}
