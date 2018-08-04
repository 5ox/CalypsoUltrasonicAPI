package b4a.example;


import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.objects.ServiceHelper;
import anywheresoftware.b4a.debug.*;

public class broadcastreceiverservice extends  android.app.Service{
	public static class broadcastreceiverservice_BR extends android.content.BroadcastReceiver {

		@Override
		public void onReceive(android.content.Context context, android.content.Intent intent) {
            BA.LogInfo("** Receiver (broadcastreceiverservice) OnReceive **");
			android.content.Intent in = new android.content.Intent(context, broadcastreceiverservice.class);
			if (intent != null)
				in.putExtra("b4a_internal_intent", intent);
            ServiceHelper.StarterHelper.startServiceFromReceiver (context, in, false, BA.class);
		}

	}
    static broadcastreceiverservice mostCurrent;
	public static BA processBA;
    private ServiceHelper _service;
    public static Class<?> getObject() {
		return broadcastreceiverservice.class;
	}
	@Override
	public void onCreate() {
        super.onCreate();
        mostCurrent = this;
        if (processBA == null) {
		    processBA = new BA(this, null, null, "b4a.example", "b4a.example.broadcastreceiverservice");
            if (BA.isShellModeRuntimeCheck(processBA)) {
                processBA.raiseEvent2(null, true, "SHELL", false);
		    }
            try {
                Class.forName(BA.applicationContext.getPackageName() + ".main").getMethod("initializeProcessGlobals").invoke(null, null);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
            processBA.loadHtSubs(this.getClass());
            ServiceHelper.init();
        }
        _service = new ServiceHelper(this);
        processBA.service = this;
        
        if (BA.isShellModeRuntimeCheck(processBA)) {
			processBA.raiseEvent2(null, true, "CREATE", true, "b4a.example.broadcastreceiverservice", processBA, _service, anywheresoftware.b4a.keywords.Common.Density);
		}
        if (!false && ServiceHelper.StarterHelper.startFromServiceCreate(processBA, true) == false) {
				
		}
		else {
            processBA.setActivityPaused(false);
            BA.LogInfo("*** Service (broadcastreceiverservice) Create ***");
            processBA.raiseEvent(null, "service_create");
        }
        processBA.runHook("oncreate", this, null);
        if (false) {
			ServiceHelper.StarterHelper.runWaitForLayouts();
		}
    }
		@Override
	public void onStart(android.content.Intent intent, int startId) {
		onStartCommand(intent, 0, 0);
    }
    @Override
    public int onStartCommand(final android.content.Intent intent, int flags, int startId) {
    	if (ServiceHelper.StarterHelper.onStartCommand(processBA, new Runnable() {
            public void run() {
                handleStart(intent);
            }}))
			;
		else {
			ServiceHelper.StarterHelper.addWaitForLayout (new Runnable() {
				public void run() {
                    processBA.setActivityPaused(false);
                    BA.LogInfo("** Service (broadcastreceiverservice) Create **");
                    processBA.raiseEvent(null, "service_create");
					handleStart(intent);
                    ServiceHelper.StarterHelper.removeWaitForLayout();
				}
			});
		}
        processBA.runHook("onstartcommand", this, new Object[] {intent, flags, startId});
		return android.app.Service.START_NOT_STICKY;
    }
    public void onTaskRemoved(android.content.Intent rootIntent) {
        super.onTaskRemoved(rootIntent);
        if (false)
            processBA.raiseEvent(null, "service_taskremoved");
            
    }
    private void handleStart(android.content.Intent intent) {
    	BA.LogInfo("** Service (broadcastreceiverservice) Start **");
    	java.lang.reflect.Method startEvent = processBA.htSubs.get("service_start");
    	if (startEvent != null) {
    		if (startEvent.getParameterTypes().length > 0) {
    			anywheresoftware.b4a.objects.IntentWrapper iw = ServiceHelper.StarterHelper.handleStartIntent(intent, _service, processBA);
    			processBA.raiseEvent(null, "service_start", iw);
    		}
    		else {
    			processBA.raiseEvent(null, "service_start");
    		}
    	}
    }
	
	@Override
	public void onDestroy() {
        super.onDestroy();
        if (false) {
            BA.LogInfo("** Service (broadcastreceiverservice) Destroy (ignored)**");
        }
        else {
            BA.LogInfo("** Service (broadcastreceiverservice) Destroy **");
		    processBA.raiseEvent(null, "service_destroy");
            processBA.service = null;
		    mostCurrent = null;
		    processBA.setActivityPaused(true);
            processBA.runHook("ondestroy", this, null);
        }
	}

@Override
	public android.os.IBinder onBind(android.content.Intent intent) {
		return null;
	}public anywheresoftware.b4a.keywords.Common __c = null;
public static anywheresoftware.b4a.objects.IntentWrapper _broadcastintent = null;
public static float _temp = 0f;
public static float _awd = 0f;
public static anywheresoftware.b4a.objects.collections.List _datafieldsapi = null;
public static String _broadcastreceiverid = "";
public b4a.example.main _main = null;
public static String  _parseintentdata(anywheresoftware.b4a.objects.IntentWrapper _apiintent) throws Exception{
String[] _value = null;
 //BA.debugLineNum = 62;BA.debugLine="Sub ParseIntentData(apiINTENT As Intent)";
 //BA.debugLineNum = 63;BA.debugLine="Dim value() As String";
_value = new String[(int) (0)];
java.util.Arrays.fill(_value,"");
 //BA.debugLineNum = 64;BA.debugLine="If apiINTENT.HasExtra(\"Temp\") Then";
if (_apiintent.HasExtra("Temp")) { 
 //BA.debugLineNum = 65;BA.debugLine="value = apiINTENT.GetExtra(\"Temp\")";
_value = (String[])(_apiintent.GetExtra("Temp"));
 //BA.debugLineNum = 66;BA.debugLine="Log(\"Temp value: \" & value(0))";
anywheresoftware.b4a.keywords.Common.Log("Temp value: "+_value[(int) (0)]);
 //BA.debugLineNum = 67;BA.debugLine="If (value.Length>0 And value(0).Length>0) Then";
if ((_value.length>0 && _value[(int) (0)].length()>0)) { 
 //BA.debugLineNum = 68;BA.debugLine="TEMP = value(0)";
_temp = (float)(Double.parseDouble(_value[(int) (0)]));
 }else {
 //BA.debugLineNum = 70;BA.debugLine="TEMP = 0.0";
_temp = (float) (0.0);
 };
 };
 //BA.debugLineNum = 73;BA.debugLine="If apiINTENT.HasExtra(\"AWD\") Then";
if (_apiintent.HasExtra("AWD")) { 
 //BA.debugLineNum = 74;BA.debugLine="value = apiINTENT.GetExtra(\"AWD\")";
_value = (String[])(_apiintent.GetExtra("AWD"));
 //BA.debugLineNum = 75;BA.debugLine="Log(\"AWD value: \" & value(0))";
anywheresoftware.b4a.keywords.Common.Log("AWD value: "+_value[(int) (0)]);
 //BA.debugLineNum = 76;BA.debugLine="If (value.Length>0 And value(0).Length>0) Then";
if ((_value.length>0 && _value[(int) (0)].length()>0)) { 
 //BA.debugLineNum = 77;BA.debugLine="AWD = value(0)";
_awd = (float)(Double.parseDouble(_value[(int) (0)]));
 }else {
 //BA.debugLineNum = 79;BA.debugLine="AWD = 0.0";
_awd = (float) (0.0);
 };
 };
 //BA.debugLineNum = 83;BA.debugLine="End Sub";
return "";
}
public static String  _process_globals() throws Exception{
 //BA.debugLineNum = 28;BA.debugLine="Sub Process_Globals";
 //BA.debugLineNum = 31;BA.debugLine="Public broadcastIntent As Intent";
_broadcastintent = new anywheresoftware.b4a.objects.IntentWrapper();
 //BA.debugLineNum = 32;BA.debugLine="Public TEMP As Float";
_temp = 0f;
 //BA.debugLineNum = 33;BA.debugLine="Public AWD As Float";
_awd = 0f;
 //BA.debugLineNum = 34;BA.debugLine="Public dataFieldsAPI As List";
_datafieldsapi = new anywheresoftware.b4a.objects.collections.List();
 //BA.debugLineNum = 35;BA.debugLine="Public broadcastReceiverID As String";
_broadcastreceiverid = "";
 //BA.debugLineNum = 36;BA.debugLine="End Sub";
return "";
}
public static String  _service_create() throws Exception{
 //BA.debugLineNum = 38;BA.debugLine="Sub Service_Create";
 //BA.debugLineNum = 40;BA.debugLine="dataFieldsAPI.Initialize2(Array As String(\"Batter";
_datafieldsapi.Initialize2(anywheresoftware.b4a.keywords.Common.ArrayToList(new String[]{"Battery","Temp","AWA","AWD","AWS","TWA","TWD","TWS","Pitch","Roll","COG","SOG"}));
 //BA.debugLineNum = 43;BA.debugLine="broadcastReceiverID = \"com.calypso.api.ACTION_DAT";
_broadcastreceiverid = "com.calypso.api.ACTION_DATA_AVAILABLE";
 //BA.debugLineNum = 45;BA.debugLine="End Sub";
return "";
}
public static String  _service_destroy() throws Exception{
 //BA.debugLineNum = 58;BA.debugLine="Sub Service_Destroy";
 //BA.debugLineNum = 60;BA.debugLine="End Sub";
return "";
}
public static void  _service_start(anywheresoftware.b4a.objects.IntentWrapper _startingintent) throws Exception{
ResumableSub_Service_Start rsub = new ResumableSub_Service_Start(null,_startingintent);
rsub.resume(processBA, null);
}
public static class ResumableSub_Service_Start extends BA.ResumableSub {
public ResumableSub_Service_Start(b4a.example.broadcastreceiverservice parent,anywheresoftware.b4a.objects.IntentWrapper _startingintent) {
this.parent = parent;
this._startingintent = _startingintent;
}
b4a.example.broadcastreceiverservice parent;
anywheresoftware.b4a.objects.IntentWrapper _startingintent;

@Override
public void resume(BA ba, Object[] result) throws Exception{

    while (true) {
        switch (state) {
            case -1:
return;

case 0:
//C
this.state = 1;
 //BA.debugLineNum = 50;BA.debugLine="If StartingIntent.Action = broadcastReceiverID Th";
if (true) break;

case 1:
//if
this.state = 4;
if ((_startingintent.getAction()).equals(parent._broadcastreceiverid)) { 
this.state = 3;
}if (true) break;

case 3:
//C
this.state = 4;
 //BA.debugLineNum = 51;BA.debugLine="ParseIntentData(StartingIntent)";
_parseintentdata(_startingintent);
 if (true) break;

case 4:
//C
this.state = -1;
;
 //BA.debugLineNum = 53;BA.debugLine="Sleep(50)";
anywheresoftware.b4a.keywords.Common.Sleep(processBA,this,(int) (50));
this.state = 5;
return;
case 5:
//C
this.state = -1;
;
 //BA.debugLineNum = 55;BA.debugLine="Service.StopAutomaticForeground 'Call this when t";
parent.mostCurrent._service.StopAutomaticForeground();
 //BA.debugLineNum = 56;BA.debugLine="End Sub";
if (true) break;

            }
        }
    }
}
}
