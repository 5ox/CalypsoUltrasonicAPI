package b4a.example;

import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.pc.*;

public class main_subs_0 {


public static RemoteObject  _activity_create(RemoteObject _firsttime) throws Exception{
try {
		Debug.PushSubsStack("Activity_Create (main) ","main",0,main.mostCurrent.activityBA,main.mostCurrent,67);
if (RapidSub.canDelegate("activity_create")) { return b4a.example.main.remoteMe.runUserSub(false, "main","activity_create", _firsttime);}
Debug.locals.put("FirstTime", _firsttime);
 BA.debugLineNum = 67;BA.debugLine="Sub Activity_Create(FirstTime As Boolean)";
Debug.ShouldStop(4);
 BA.debugLineNum = 69;BA.debugLine="Activity.LoadLayout(\"MainActivity\")";
Debug.ShouldStop(16);
main.mostCurrent._activity.runMethodAndSync(false,"LoadLayout",(Object)(RemoteObject.createImmutable("MainActivity")),main.mostCurrent.activityBA);
 BA.debugLineNum = 70;BA.debugLine="Activity.Title = \"Calypso Ultrasonic API\"";
Debug.ShouldStop(32);
main.mostCurrent._activity.runMethod(false,"setTitle",BA.ObjectToCharSequence("Calypso Ultrasonic API"));
 BA.debugLineNum = 72;BA.debugLine="lblTitle.Text = \"Calypso Ultrasonic API\"";
Debug.ShouldStop(128);
main.mostCurrent._lbltitle.runMethod(true,"setText",BA.ObjectToCharSequence("Calypso Ultrasonic API"));
 BA.debugLineNum = 74;BA.debugLine="End Sub";
Debug.ShouldStop(512);
return RemoteObject.createImmutable("");
}
catch (Exception e) {
			throw Debug.ErrorCaught(e);
		} 
finally {
			Debug.PopSubsStack();
		}}
public static RemoteObject  _activity_pause(RemoteObject _userclosed) throws Exception{
try {
		Debug.PushSubsStack("Activity_Pause (main) ","main",0,main.mostCurrent.activityBA,main.mostCurrent,88);
if (RapidSub.canDelegate("activity_pause")) { return b4a.example.main.remoteMe.runUserSub(false, "main","activity_pause", _userclosed);}
Debug.locals.put("UserClosed", _userclosed);
 BA.debugLineNum = 88;BA.debugLine="Sub Activity_Pause (UserClosed As Boolean)";
Debug.ShouldStop(8388608);
 BA.debugLineNum = 89;BA.debugLine="uiTimer.Enabled = False";
Debug.ShouldStop(16777216);
main._uitimer.runMethod(true,"setEnabled",main.mostCurrent.__c.getField(true,"False"));
 BA.debugLineNum = 90;BA.debugLine="broadcastTimer.Enabled = False";
Debug.ShouldStop(33554432);
main._broadcasttimer.runMethod(true,"setEnabled",main.mostCurrent.__c.getField(true,"False"));
 BA.debugLineNum = 91;BA.debugLine="If UserClosed Then";
Debug.ShouldStop(67108864);
if (_userclosed.<Boolean>get().booleanValue()) { 
 BA.debugLineNum = 92;BA.debugLine="Activity.Finish";
Debug.ShouldStop(134217728);
main.mostCurrent._activity.runVoidMethod ("Finish");
 };
 BA.debugLineNum = 94;BA.debugLine="End Sub";
Debug.ShouldStop(536870912);
return RemoteObject.createImmutable("");
}
catch (Exception e) {
			throw Debug.ErrorCaught(e);
		} 
finally {
			Debug.PopSubsStack();
		}}
public static RemoteObject  _activity_resume() throws Exception{
try {
		Debug.PushSubsStack("Activity_Resume (main) ","main",0,main.mostCurrent.activityBA,main.mostCurrent,76);
if (RapidSub.canDelegate("activity_resume")) { return b4a.example.main.remoteMe.runUserSub(false, "main","activity_resume");}
 BA.debugLineNum = 76;BA.debugLine="Sub Activity_Resume";
Debug.ShouldStop(2048);
 BA.debugLineNum = 77;BA.debugLine="uiTimer.Initialize(\"uiTimer\", 1000)";
Debug.ShouldStop(4096);
main._uitimer.runVoidMethod ("Initialize",main.processBA,(Object)(BA.ObjectToString("uiTimer")),(Object)(BA.numberCast(long.class, 1000)));
 BA.debugLineNum = 78;BA.debugLine="uiTimer.Enabled = True";
Debug.ShouldStop(8192);
main._uitimer.runMethod(true,"setEnabled",main.mostCurrent.__c.getField(true,"True"));
 BA.debugLineNum = 80;BA.debugLine="broadcastTimer.Initialize(\"broadcastTimer\", 800)";
Debug.ShouldStop(32768);
main._broadcasttimer.runVoidMethod ("Initialize",main.processBA,(Object)(BA.ObjectToString("broadcastTimer")),(Object)(BA.numberCast(long.class, 800)));
 BA.debugLineNum = 81;BA.debugLine="broadcastTimer.Enabled = True";
Debug.ShouldStop(65536);
main._broadcasttimer.runMethod(true,"setEnabled",main.mostCurrent.__c.getField(true,"True"));
 BA.debugLineNum = 82;BA.debugLine="Log(\"Initialized the timers.. \")";
Debug.ShouldStop(131072);
main.mostCurrent.__c.runVoidMethod ("Log",(Object)(RemoteObject.createImmutable("Initialized the timers.. ")));
 BA.debugLineNum = 84;BA.debugLine="broadcastIntent.Initialize(broadcastReceiverID, \"";
Debug.ShouldStop(524288);
main._broadcastintent.runVoidMethod ("Initialize",(Object)(main._broadcastreceiverid),(Object)(RemoteObject.createImmutable("")));
 BA.debugLineNum = 86;BA.debugLine="End Sub";
Debug.ShouldStop(2097152);
return RemoteObject.createImmutable("");
}
catch (Exception e) {
			throw Debug.ErrorCaught(e);
		} 
finally {
			Debug.PopSubsStack();
		}}
public static RemoteObject  _broadcasttimer_tick() throws Exception{
try {
		Debug.PushSubsStack("broadcastTimer_Tick (main) ","main",0,main.mostCurrent.activityBA,main.mostCurrent,105);
if (RapidSub.canDelegate("broadcasttimer_tick")) { return b4a.example.main.remoteMe.runUserSub(false, "main","broadcasttimer_tick");}
RemoteObject _value = null;
 BA.debugLineNum = 105;BA.debugLine="Sub broadcastTimer_Tick";
Debug.ShouldStop(256);
 BA.debugLineNum = 107;BA.debugLine="Log(\"Intent Action: \"&broadcastIntent.Action&\" lo";
Debug.ShouldStop(1024);
main.mostCurrent.__c.runVoidMethod ("Log",(Object)(RemoteObject.concat(RemoteObject.createImmutable("Intent Action: "),main._broadcastintent.runMethod(true,"getAction"),RemoteObject.createImmutable(" looking for: "),main._broadcastreceiverid)));
 BA.debugLineNum = 108;BA.debugLine="If broadcastIntent.Action = broadcastReceiverID T";
Debug.ShouldStop(2048);
if (RemoteObject.solveBoolean("=",main._broadcastintent.runMethod(true,"getAction"),main._broadcastreceiverid)) { 
 BA.debugLineNum = 109;BA.debugLine="If broadcastIntent.HasExtra(\"AWA\") Then";
Debug.ShouldStop(4096);
if (main._broadcastintent.runMethod(true,"HasExtra",(Object)(RemoteObject.createImmutable("AWA"))).<Boolean>get().booleanValue()) { 
 BA.debugLineNum = 110;BA.debugLine="Dim value() As String";
Debug.ShouldStop(8192);
_value = RemoteObject.createNewArray ("String", new int[] {0}, new Object[]{});Debug.locals.put("value", _value);
 BA.debugLineNum = 111;BA.debugLine="value = broadcastIntent.GetExtra(\"AWA\")";
Debug.ShouldStop(16384);
_value = (main._broadcastintent.runMethod(false,"GetExtra",(Object)(RemoteObject.createImmutable("AWA"))));Debug.locals.put("value", _value);
 BA.debugLineNum = 112;BA.debugLine="Log(\"AWA value: \" & value(0))";
Debug.ShouldStop(32768);
main.mostCurrent.__c.runVoidMethod ("Log",(Object)(RemoteObject.concat(RemoteObject.createImmutable("AWA value: "),_value.getArrayElement(true,BA.numberCast(int.class, 0)))));
 BA.debugLineNum = 113;BA.debugLine="If (value.Length>0 And value(0).Length>0) Then";
Debug.ShouldStop(65536);
if ((RemoteObject.solveBoolean(">",_value.getField(true,"length"),BA.numberCast(double.class, 0)) && RemoteObject.solveBoolean(">",_value.getArrayElement(true,BA.numberCast(int.class, 0)).runMethod(true,"length"),BA.numberCast(double.class, 0)))) { 
 BA.debugLineNum = 114;BA.debugLine="AWA = value(0)";
Debug.ShouldStop(131072);
main._awa = BA.numberCast(float.class, _value.getArrayElement(true,BA.numberCast(int.class, 0)));
 }else {
 BA.debugLineNum = 116;BA.debugLine="AWA = 0.0";
Debug.ShouldStop(524288);
main._awa = BA.numberCast(float.class, 0.0);
 };
 };
 };
 BA.debugLineNum = 121;BA.debugLine="End Sub";
Debug.ShouldStop(16777216);
return RemoteObject.createImmutable("");
}
catch (Exception e) {
			throw Debug.ErrorCaught(e);
		} 
finally {
			Debug.PopSubsStack();
		}}
public static RemoteObject  _globals() throws Exception{
 //BA.debugLineNum = 53;BA.debugLine="Sub Globals";
 //BA.debugLineNum = 56;BA.debugLine="Public lblTitle As Label";
main.mostCurrent._lbltitle = RemoteObject.createNew ("anywheresoftware.b4a.objects.LabelWrapper");
 //BA.debugLineNum = 57;BA.debugLine="Public ListView1 As ListView";
main.mostCurrent._listview1 = RemoteObject.createNew ("anywheresoftware.b4a.objects.ListViewWrapper");
 //BA.debugLineNum = 60;BA.debugLine="dataFieldsAPI.Initialize2(Array As String(\"Batter";
main._datafieldsapi.runVoidMethod ("Initialize2",(Object)(main.mostCurrent.__c.runMethod(false, "ArrayToList", (Object)(RemoteObject.createNewArray("String",new int[] {13},new Object[] {BA.ObjectToString("Battery"),BA.ObjectToString("Temp"),BA.ObjectToString("AWA"),BA.ObjectToString("AWD"),BA.ObjectToString("AWS"),BA.ObjectToString("TWA"),BA.ObjectToString("TWD"),BA.ObjectToString("TWS"),BA.ObjectToString("Pitch"),BA.ObjectToString("Roll"),BA.ObjectToString("Compass"),BA.ObjectToString("COG"),RemoteObject.createImmutable("SOG")})))));
 //BA.debugLineNum = 63;BA.debugLine="broadcastReceiverID = \"com.calypso.api.ACTION_DAT";
main._broadcastreceiverid = BA.ObjectToString("com.calypso.api.ACTION_DATA_AVAILABLE");
 //BA.debugLineNum = 64;BA.debugLine="ctr = 0";
main._ctr = BA.numberCast(int.class, 0);
 //BA.debugLineNum = 65;BA.debugLine="End Sub";
return RemoteObject.createImmutable("");
}

public static void initializeProcessGlobals() {
    
    if (main.processGlobalsRun == false) {
	    main.processGlobalsRun = true;
		try {
		        main_subs_0._process_globals();
starter_subs_0._process_globals();
main.myClass = BA.getDeviceClass ("b4a.example.main");
starter.myClass = BA.getDeviceClass ("b4a.example.starter");
		
        } catch (Exception e) {
			throw new RuntimeException(e);
		}
    }
}public static RemoteObject  _process_globals() throws Exception{
 //BA.debugLineNum = 39;BA.debugLine="Sub Process_Globals";
 //BA.debugLineNum = 42;BA.debugLine="Public uiTimer As Timer";
main._uitimer = RemoteObject.createNew ("anywheresoftware.b4a.objects.Timer");
 //BA.debugLineNum = 43;BA.debugLine="Public broadcastTimer As Timer";
main._broadcasttimer = RemoteObject.createNew ("anywheresoftware.b4a.objects.Timer");
 //BA.debugLineNum = 44;BA.debugLine="Public ctr As Int";
main._ctr = RemoteObject.createImmutable(0);
 //BA.debugLineNum = 45;BA.debugLine="Public broadcastIntent As Intent";
main._broadcastintent = RemoteObject.createNew ("anywheresoftware.b4a.objects.IntentWrapper");
 //BA.debugLineNum = 46;BA.debugLine="Public AWA As Float";
main._awa = RemoteObject.createImmutable(0f);
 //BA.debugLineNum = 47;BA.debugLine="Public AWD As Float";
main._awd = RemoteObject.createImmutable(0f);
 //BA.debugLineNum = 48;BA.debugLine="Public AWS As Float";
main._aws = RemoteObject.createImmutable(0f);
 //BA.debugLineNum = 49;BA.debugLine="Public dataFieldsAPI As List";
main._datafieldsapi = RemoteObject.createNew ("anywheresoftware.b4a.objects.collections.List");
 //BA.debugLineNum = 50;BA.debugLine="Public broadcastReceiverID As String";
main._broadcastreceiverid = RemoteObject.createImmutable("");
 //BA.debugLineNum = 51;BA.debugLine="End Sub";
return RemoteObject.createImmutable("");
}
public static RemoteObject  _uitimer_tick() throws Exception{
try {
		Debug.PushSubsStack("uiTimer_Tick (main) ","main",0,main.mostCurrent.activityBA,main.mostCurrent,96);
if (RapidSub.canDelegate("uitimer_tick")) { return b4a.example.main.remoteMe.runUserSub(false, "main","uitimer_tick");}
 BA.debugLineNum = 96;BA.debugLine="Sub uiTimer_Tick";
Debug.ShouldStop(-2147483648);
 BA.debugLineNum = 97;BA.debugLine="Log(\"Received AWA = \" & AWA)";
Debug.ShouldStop(1);
main.mostCurrent.__c.runVoidMethod ("Log",(Object)(RemoteObject.concat(RemoteObject.createImmutable("Received AWA = "),main._awa)));
 BA.debugLineNum = 98;BA.debugLine="Log(\"--\")";
Debug.ShouldStop(2);
main.mostCurrent.__c.runVoidMethod ("Log",(Object)(RemoteObject.createImmutable("--")));
 BA.debugLineNum = 99;BA.debugLine="ctr = ctr + 1";
Debug.ShouldStop(4);
main._ctr = RemoteObject.solve(new RemoteObject[] {main._ctr,RemoteObject.createImmutable(1)}, "+",1, 1);
 BA.debugLineNum = 100;BA.debugLine="lblTitle.Text = ctr & \". dataset\"";
Debug.ShouldStop(8);
main.mostCurrent._lbltitle.runMethod(true,"setText",BA.ObjectToCharSequence(RemoteObject.concat(main._ctr,RemoteObject.createImmutable(". dataset"))));
 BA.debugLineNum = 101;BA.debugLine="ListView1.AddSingleLine( ctr & \". AWS record rece";
Debug.ShouldStop(16);
main.mostCurrent._listview1.runVoidMethod ("AddSingleLine",(Object)(BA.ObjectToCharSequence(RemoteObject.concat(main._ctr,RemoteObject.createImmutable(". AWS record received = "),main._aws))));
 BA.debugLineNum = 102;BA.debugLine="ListView1.SingleLineLayout.Label.TextSize = 14";
Debug.ShouldStop(32);
main.mostCurrent._listview1.runMethod(false,"getSingleLineLayout").getField(false,"Label").runMethod(true,"setTextSize",BA.numberCast(float.class, 14));
 BA.debugLineNum = 103;BA.debugLine="End Sub";
Debug.ShouldStop(64);
return RemoteObject.createImmutable("");
}
catch (Exception e) {
			throw Debug.ErrorCaught(e);
		} 
finally {
			Debug.PopSubsStack();
		}}
}