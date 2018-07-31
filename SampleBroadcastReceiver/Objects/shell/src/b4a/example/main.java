
package b4a.example;

import java.io.IOException;
import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.pc.PCBA;
import anywheresoftware.b4a.pc.RDebug;
import anywheresoftware.b4a.pc.RemoteObject;
import anywheresoftware.b4a.pc.RDebug.IRemote;
import anywheresoftware.b4a.pc.Debug;
import anywheresoftware.b4a.pc.B4XTypes.B4XClass;
import anywheresoftware.b4a.pc.B4XTypes.DeviceClass;

public class main implements IRemote{
	public static main mostCurrent;
	public static RemoteObject processBA;
    public static boolean processGlobalsRun;
    public static RemoteObject myClass;
    public static RemoteObject remoteMe;
	public main() {
		mostCurrent = this;
	}
    public RemoteObject getRemoteMe() {
        return remoteMe;    
    }
    
	public static void main (String[] args) throws Exception {
		new RDebug(args[0], Integer.parseInt(args[1]), Integer.parseInt(args[2]), args[3]);
		RDebug.INSTANCE.waitForTask();

	}
    static {
        anywheresoftware.b4a.pc.RapidSub.moduleToObject.put(new B4XClass("main"), "b4a.example.main");
	}

public boolean isSingleton() {
		return true;
	}
     public static RemoteObject getObject() {
		return myClass;
	 }

	public RemoteObject activityBA;
	public RemoteObject _activity;
    private PCBA pcBA;

	public PCBA create(Object[] args) throws ClassNotFoundException{
		processBA = (RemoteObject) args[1];
		activityBA = (RemoteObject) args[2];
		_activity = (RemoteObject) args[3];
        anywheresoftware.b4a.keywords.Common.Density = (Float)args[4];
        remoteMe = (RemoteObject) args[5];
		pcBA = new PCBA(this, main.class);
        main_subs_0.initializeProcessGlobals();
		return pcBA;
	}
public static RemoteObject __c = RemoteObject.declareNull("anywheresoftware.b4a.keywords.Common");
public static RemoteObject _uitimer = RemoteObject.declareNull("anywheresoftware.b4a.objects.Timer");
public static RemoteObject _broadcasttimer = RemoteObject.declareNull("anywheresoftware.b4a.objects.Timer");
public static RemoteObject _ctr = RemoteObject.createImmutable(0);
public static RemoteObject _broadcastintent = RemoteObject.declareNull("anywheresoftware.b4a.objects.IntentWrapper");
public static RemoteObject _awa = RemoteObject.createImmutable(0f);
public static RemoteObject _awd = RemoteObject.createImmutable(0f);
public static RemoteObject _aws = RemoteObject.createImmutable(0f);
public static RemoteObject _datafieldsapi = RemoteObject.declareNull("anywheresoftware.b4a.objects.collections.List");
public static RemoteObject _broadcastreceiverid = RemoteObject.createImmutable("");
public static RemoteObject _lbltitle = RemoteObject.declareNull("anywheresoftware.b4a.objects.LabelWrapper");
public static RemoteObject _listview1 = RemoteObject.declareNull("anywheresoftware.b4a.objects.ListViewWrapper");
public static b4a.example.starter _starter = null;
  public Object[] GetGlobals() {
		return new Object[] {"Activity",main.mostCurrent._activity,"AWA",main._awa,"AWD",main._awd,"AWS",main._aws,"broadcastIntent",main._broadcastintent,"broadcastReceiverID",main._broadcastreceiverid,"broadcastTimer",main._broadcasttimer,"ctr",main._ctr,"dataFieldsAPI",main._datafieldsapi,"lblTitle",main.mostCurrent._lbltitle,"ListView1",main.mostCurrent._listview1,"Starter",Debug.moduleToString(b4a.example.starter.class),"uiTimer",main._uitimer};
}
}