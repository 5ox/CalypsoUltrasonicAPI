B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=8.3
@EndOfDesignText@
'--------------------------------------------------------------------------------------------------
' Starter program to initialize all global variables / objects
' 
' Developed by Volker Petersen (volker.petersen01@gmail.com)
' July 2018
' -------------------------------------------------------------------------------------------------
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public runBackgroundTasks As Boolean
	Public broadcastFrequency As Int		' frequency (in milliseconds) of Broadcast Intent transmissions
	Public javaInline As JavaObject 		' object for Inline Java code imbedded in B4a program Starter()
	Public javaNative As JavaObject 		' object for Native Java object to be called
	Public rp As RuntimePermissions
	Public allowReport As Boolean = True	' allowed error reporting by user / TODO set up as preferences
	Private logs As StringBuilder
	Private logcat As LogCat
	Public appIcon As Bitmap
	
	' User Preferences
	Dim prefManager As PreferenceManager	' User Preference Manager
	Dim prefScreen As PreferenceScreen		' User Preference Screen
	Public prefSmoothing As Float			' data smoothing on (<1.0) / off (=1.0)
	Public prefSampleRate As Int			' data aquisition frequency (sample Rate) 1Hz, 4Hz, 8Hz
	Public prefErrReporting As Boolean		' allow error/crash reporting
	Public prefTrueNorth As Boolean			' True yields True North, False yields Magnetic North
	Public prefBluetoothName As String		' Name of the last connected Bluetooth Device
	Public prefBluetoothMAC As String		' Mac Address of the last connected Bluetooth Device

	' Phone services
	Public phoneManager As Phone
	Public phoneAccelerometer As PhoneSensors
	Public phoneMagnetic As PhoneSensors
	Public activeCompass As Boolean = False
	
	' Bluetooth variables
	Public bleEnabled As Boolean		' true if Bluetooth is turned on and enabled by user
	Public bleConnected As Boolean		' true if we have an active connection
	Public bleSelect = False As Boolean ' if true we display the device list in real time throughtout the scan process 
	Public bleNotify = False As Boolean	' enable Bluetooth to receive data thru BLE_DataAvailable() service
	Public bleManager As BleManager2
	Public bleStateText As String		' store the current State of the BLE device
	Public bleDevices As Map
	Public bleScanTimeout As Timer		' timeout timer for the Bluetooth device scan process
	Public bleConnectTimeout As Timer	' timeout timer for the Bluetooth device connection process
	
	' Location Services
	Public gpsManager As GPS
	Public gpsChanged As Boolean		' true if Location changed
	Public gpsLocation As Location		' holds latest GPS loaction
	Public activeGPS As Boolean			' true if Location Services are enabled
	Public gpsStarted As Boolean		' true if the Location Services are running
	Public gpsString As String			' String with GPS status msg
	Public localDeclination As Int=999	' local Declination data, updated in Location Services
	
	Public deviceType As Int			' Cups=1, Ultrasonic=2 NMEA=2
	
	Public sensorData As Map			' current datapoint received from the sensors via BLE and GPS
	Public sensorDataPrev As Map		' last datapoint received from the sensor via BLE and GPS
	Public dataFields As List			' data fields in the 'sensorData' & 'sensorDataPrev' dictionaries
	Public dataFieldsSmooth As List		' data fields to be smoothed when this feature is enabled in Preference Settings
	Public dataFieldsCircular As List	' data fields that hold a cicular value (i.e., direction ranging from 0-359.999 degree)
	Public dataFieldsAPI As List		' data fields that will be transmitted by the API (using Broadcast Intents)
	
	Type tUltra(Name As String, MacAddress As String, RSSI As Double)
	Public actual_ultra As tUltra		' tUltra data of the actual device connected to this App
	
	Public timeout As Long = 15000		' timeout in milliseconds for the BLE scan
	Public tryTimes As Int = 0

	Dim sUltra As String 				' Services of the connected Ultra device
	Dim cNormal, cRate, cSensors, cStatus, cNmea, cCalComp As String
	
	Public invalidMAC As String = "??:??"
	Public defaultSensorName As String = "Ultrasonic Anemometer"
	
	Public ctr_ble As Int				' BLE data set transfer counter for debugging only	
	Public deviceInfo As Map
	
	Public offsetAngle As Int = 0		' calibration offset angle
	Public lpfAlpha As Float = 0.2		' Alpha parameter for the Low Pass Filter
	
	Public calcTools As ComputationTools ' class of various calculation tools & methods
	
End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	'
	' All speed data is stored in 'm/s'
	' All directional data is stored in true degrees
	'
	
	runBackgroundTasks = True
	broadcastFrequency = 1000   		' time between transmissions in milliseconds
	
	gpsManager.Initialize("GPS")		' initialize the Location Services
	activeGPS = gpsManager.GPSEnabled
	bleManager.Initialize("BLE")		' initialize the Bluetooth device
	
	' initialize the Sensor data (GPS->Location and BLE->Anemometer) dictionaries and Data Fields
	dataFields.Initialize2(Array As String("Battery", "Temp", "AWA", "AWD", "AWS", "TWA", "TWD", "TWS", _
			"Pitch", "Roll", "Compass", "ALT", "LAT", "LON", "COG", "SOG", "MAG", "DEC", "STATUS"))
	dataFieldsSmooth.Initialize2(Array As String("AWA", "AWD", "AWS", "Pitch", "Roll", "Compass", "COG", "SOG", "MAG"))
	dataFieldsCircular.Initialize2(Array As String("AWA", "AWD", "AWS", "Compass", "COG", "MAG"))
	dataFieldsAPI.Initialize2(Array As String("Battery", "Temp", "AWA", "AWD", "AWS", "TWA", "TWD", "TWS", _
			"Pitch", "Roll", "Compass", "COG", "SOG"))
	sensorData.Initialize
	bleDevices.Initialize

	Dim i As Int
	For i=0 To dataFields.Size-1
		sensorData.Put(dataFields.Get(i), 0.0)
	Next
	
	' testing only
	'For i=0 To dataFields.Size-1
	'	Log("Starter->Service_Create() data field " & dataFields.Get(i) & " = " &sensorData.Get(dataFields.Get(i)))
	'Next
	
	bleStateText = "BLE Disconnected"
	ctr_ble = 0
	
	actual_ultra.Initialize
	actual_ultra.Name = "unkown"
	actual_ultra.MacAddress = invalidMAC
	actual_ultra.RSSI = 0.0
	
	appIcon = LoadBitmap(File.DirAssets, "icon.png")

	' initialize Native Java code options. The javaInline must be initialized in the Activity that uses it (for us Main())
	javaNative.InitializeStatic("android.hardware.SensorManager")

End Sub

Sub Service_Start (StartingIntent As Intent)
	
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
	bleManager.Disconnect
	Sleep(500)
	Service_Destroy
	ExitApplication
End Sub


'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	If allowReport = False Then Return True
	
	'wait for 500ms to allow the logs to be updated.
	Dim jo As JavaObject
	Dim l As Long = 500
	jo.InitializeStatic("java.lang.Thread").RunMethod("sleep", Array(l))
	logcat.LogCatStop
	logs.Append(StackTrace)
	Dim email As Email
	'email.To.Add("anemotrackerdev@gmail.com")
	email.To.Add("volker.petersen01@gmail.com")
	email.Subject = "App crash report " & actual_ultra.macaddress & " " & phoneManager.Manufacturer
	email.Subject = email.Subject & " " & phoneManager.Model & " " & phoneManager.Product
	email.Body = logs
	StartActivity(email.GetIntent)
	Return True
End Sub

Sub Service_Destroy
	gpsManager.Stop
End Sub


Private Sub logcat_LogCatData (Buffer() As Byte, Length As Int)
	logs.Append(BytesToString(Buffer, 0, Length, "utf8"))
	If logs.Length > 5000 Then
		logs.Remove(0, logs.Length - 4000)
	End If
End Sub


#Region GPS
'--------------------------------------------------------------------------------------------------
' Location Services
'--------------------------------------------------------------------------------------------------
Public Sub StartGPS
	If activeGPS  And gpsStarted = False Then
		gpsManager.Start(450, 25)		' update every 450 milliseconds or 25 meters
		gpsStarted = True
		
	End If
End Sub

Public Sub StopGPS
	If activeGPS And gpsStarted Then
		gpsManager.Stop
		gpsStarted = False 
	End If
End Sub

Sub GPS_LocationChanged(myLocation As Location)
	' store the current location data in the global dictionary 'sensorData'
	sensorData.Put("LAT", myLocation.Latitude)
	sensorData.Put("LON", myLocation.Longitude)
	If myLocation.BearingValid Then
		sensorData.Put("COG", myLocation.Speed)
	Else
		sensorData.Put("COG", 0.0)
	End If
	If myLocation.SpeedValid Then
		sensorData.Put("SOG", myLocation.Bearing)
	Else
		sensorData.Put("SOG", 0.0)
	End If
	If myLocation.AccuracyValid Then
		sensorData.Put("STATUS", myLocation.Accuracy)
	Else
		sensorData.Put("STATUS", 0.0)
	End If
	If myLocation.AltitudeValid Then
		sensorData.Put("ALT", myLocation.Altitude)
	Else
		sensorData.Put("ALT", 10.0)
	End If
	If localDeclination = 999 Then
		localDeclination = magDeclination ' get the magnetic delication at the current location & altitude
	End If
	sensorData.Put("DEC", localDeclination)	
End Sub


Sub magDeclination() As Float
	' get the magnetic declination for the current location
	Dim magDec As Float = 0.0  			' default value
	#if B4A
		Dim millis As Long = DateTime.Now		
		'magDec = javaInline.RunMethod("getDeclination", Array As Object(sensorData.Get("LAT"), sensorData.Get("LON"), sensorData.Get("ALT"), millis))
		Log("Starter->magDeclination(): mag Declination = " & magDec)
	#end if
	Return magDec
End Sub
#End Region

#Region BLE
'--------------------------------------------------------------------------------------------------
' Bluetooth connection stuff
'--------------------------------------------------------------------------------------------------
Sub BLE_Scan
	'bleManager.StopScan
	bleSelect = True					' add to device list in real time, don't wait til scan is completed
	bleDevices.Clear
	bleManager.Disconnect
	Sleep(100)
	Log("Starter->BLE_Scan(): supported device: " & bleManager.State)
	bleManager.Scan2( Null, False )     ' no UUID device list, don't allow duplicates
	bleScanTimeout.Initialize("bleScanTimeout", timeout)
	bleScanTimeout.Enabled = True
	Log("Starter->BLE_Scan(): Scan2 launched")
End Sub


Sub BLE_DeviceFound (name As String, MacAddress As String, AdvertisingData As Map, RSSI As Double)
	Log( "Starter->BLE_DeviceFoundDetected(): name: " & name & " " & MacAddress & " RSSI: "& RSSI )
	Dim device As tUltra
	device.Name = name
	device.MacAddress = MacAddress
	device.RSSI = RSSI
	bleDevices.Put( MacAddress, device )
	If bleSelect = True Then CallSubDelayed( actBLE, "addToListRT") 'add to list in real time
End Sub

Sub ConnectBle( ultra As tUltra )
	bleManager.StopScan
	bleScanTimeout.Enabled = False

	actual_ultra = ultra
	CallSubDelayed(Main, "Connecting_Bluetooth")				' update the UI to the current action
	Log("Starter->ConnectBLE(): starting connection process for Mac: "&ultra.MacAddress)
	bleConnectTimeout.Initialize("bleConnectTimeout", timeout)
	bleConnectTimeout.Enabled = True
	bleManager.Connect2(ultra.MacAddress, False)
End Sub

Sub BLE_Connected (Services As List)
	bleConnectTimeout.Enabled = False
	bleNotify = False
	bleConnected = True
	Log("Starter->BLE_Connect(): known device " & (prefBluetoothMAC = actual_ultra.MacAddress))
	If (prefBluetoothMAC = actual_ultra.MacAddress) Then
		' for KOWN device, use the name from the User Preference setting
		bleStateText = "BLE connected to " & prefBluetoothName
		Log("Starter->BLE_Connect(): to known device " & prefBluetoothName)
	Else
		' for UNKOWN device, use actual Name and update the User Preference "bleMAC" setting
		bleStateText = "BLE connected to " & actual_ultra.Name
		prefBluetoothName = actual_ultra.Name
		prefBluetoothMAC = actual_ultra.MacAddress
		prefManager.SetString("bleMAC", actual_ultra.MacAddress)
	End If
	cNormal = ""
	cRate = ""
	For Each s As String In Services
		Log("Starter->BLE_Connect(): Service: " & s)
		If s.StartsWith( "0000180d" ) Then
			bleManager.ReadData(s)
		Else If s.StartsWith( "0000180a" ) Then
			bleManager.ReadData(s)
		End If
	Next
	CallSub(Main, "Launch_Background_Services")
End Sub

Sub BLE_Disconnected
	bleConnected = False
	bleConnectTimeout.Enabled = False
	bleScanTimeout.Enabled = False
	bleNotify = False
	'ToastMessageShow( "Disconnected from " & actual_ultra.MacAddress, False )
	If (prefBluetoothMAC = actual_ultra.MacAddress) Then
		bleStateText = "BLE disconnected from " & prefBluetoothName
	Else
		bleStateText = "BLE disconnected from " & actual_ultra.Name
	End If
	CallSub(Main, "Launch_Background_Services")
End Sub

Sub BLE_DiscoveryFinished
	'Do nothing if we use add in real time
	bleManager.StopScan 					' Important, speeds up the process....
	If bleSelect = False Then
		CallSubDelayed( actBLE, "displayDiscoveryFinishedStatus")
		Log("Starter->BLE_DiscoveryFinished(): Searching for last ultra connected")
	End If
	
End Sub


Sub bleScanTimeout_Tick
	'Msgbox("Bluetooth Device Scan timed out w/o finding an active Bluetooth device.", "Bluetooth Scan Timeout")
	ToastMessageShow("Bluetooth Device Scan timed out w/o finding an active Bluetooth device.", True)
	bleScanTimeout.Enabled = False
	BLE_DiscoveryFinished
End Sub


Sub bleConnectTimeout_tick( )						' This timer ends the device connection after Timeout
	'Msgbox("Bluetooth connection attempt timed out. No Bluetooth device connected.", "Bluetooth Connect Timeout")
	ToastMessageShow("Bluetooth connection attempt timed out. No Bluetooth device connected.", True)
	bleConnectTimeout.Enabled = False
End Sub


Sub BLE_DataAvailable (ServiceId As String, Characteristics As Map)
	Dim bc As ByteConverter
	If ServiceId.StartsWith( "0000180d" ) Then
		' Sensor Data available under this ServiceID
		sUltra = ServiceId
		If Not( bleNotify ) Then
			For Each id As String In Characteristics.Keys
				If id.StartsWith( "00002a39" ) Then
					cNormal = id
					bleManager.SetNotify( sUltra, cNormal, True )
					bleNotify = True
				End If
				
				' Sample Rate
				If id.StartsWith( "0000a002" ) Then
					cRate = id 					' 1 -> 1Hz 4-> 4Hz 8->8Hz
				End If
				
				' Satus of Temperature and eCompass sensors
				If id.StartsWith( "0000a003" ) Then
					cSensors = id
				End If
				
				' Device Status (00-sleep mode, 01-Low Power, 02-Normal Mode)
				If id.StartsWith( "0000a001" ) Then
					cStatus = id
				End If
				If id.StartsWith( "0000b001" ) Then
					cNmea = id
				End If
				If id.StartsWith( "0000a00b" ) Then
					cCalComp = id
				End If
				
				'If id.StartsWith( "0000a003" ) Then
				'	Sleep(500)
				'	Log( "Sensors")
				'	bc.LittleEndian = True
				'	Dim str = "02" As String
				'	ble1.WriteData( sUltra, id,  bc.HexToBytes( str ) )
				'End If
			Next			
		End If
		

		If Characteristics.ContainsKey( cNormal ) Then
			bc.LittleEndian = True
			'Log(bc.HexFromBytes( Characteristics.Get(cNormal)))
			Dim bVars(4) As Byte
			Dim sVars() As Short
			bc.ArrayCopy(Characteristics.Get(cNormal), 0, bVars, 0, 4 )
			sVars = bc.ShortsFromBytes( bVars )
			Dim velocity, direction As Float
			velocity = sVars(0)
			direction = sVars(1)
			sensorData.Put("AWA", direction)
			sensorData.Put("AWS", velocity/100)

			If deviceType = 2 Then  ' only available for Ultra device
				bc.ArrayCopy(Characteristics.Get(cNormal), 4, bVars, 0, 4 )
				'Log( bc.HexFromBytes( bVars ) )
				sensorData.Put("Battery", ToUnsigned(bVars(0))*10)
				sensorData.Put("Temp", ToUnsigned(bVars(1)) - 100)
				sensorData.Put("Roll", ToUnsigned(bVars(2)) - 90)
				sensorData.Put("Pitch", ToUnsigned(bVars(3)) - 90)
				bc.ArrayCopy(Characteristics.Get(cNormal), 8, bVars, 0, 2 )
				sVars = bc.ShortsFromBytes( bVars )
				sensorData.Put("Compass", 360-sVars(0) + offsetAngle)
			End If

		End If
		If Characteristics.ContainsKey(cRate) Then
			Dim sr As Int
			Dim str As String
			bc.LittleEndian = True
			sr = bc.HexFromBytes(Characteristics.Get(cRate))
			Log( "Starter->BLE_DataAvailable(): BLE Sample Rate from the Device: " & sr)
			If Not(sr = prefSampleRate) Then
				Sleep(125)
				str = NumberFormat(prefSampleRate, 2, 0)
				Log("Starter->BLE_DataAvailable(): Got SR " & sr & " but user prefs are "& prefSampleRate & " setting to: " & str)
				bleManager.WriteData( sUltra, cRate,  bc.HexToBytes( str ) )
			End If
		End If
		
	Else If ServiceId.StartsWith( "0000180a" ) Then
		' Factory Device Information
		bc.LittleEndian = True
		deviceInfo.Initialize
		For Each id As String In Characteristics.Keys
			If id.StartsWith("00002a29") Then 'Manufacturer name
				deviceInfo.Put("Manufacturer Name", bc.StringFromBytes(Characteristics.Get(id),"ASCII"))
			else if id.StartsWith("00002a24") Then 'Model number name
				deviceInfo.Put("Model Number", bc.StringFromBytes(Characteristics.Get(id),"ASCII"))
			else if id.StartsWith("00002a25") Then 'Serial number name
				deviceInfo.Put("Serial Number", bc.StringFromBytes(Characteristics.Get(id),"ASCII"))
			else if id.StartsWith("00002a27") Then 'HW revision
				deviceInfo.Put("Hardware Revision", bc.StringFromBytes(Characteristics.Get(id),"ASCII"))
			else if id.StartsWith("00002a26") Then 'FW revision
				deviceInfo.Put("Firmware Revision", bc.StringFromBytes(Characteristics.Get(id),"ASCII"))
			else if id.StartsWith("00002a28") Then 'SW revision
				deviceInfo.Put("Software Revision", bc.StringFromBytes(Characteristics.Get(id),"ASCII"))
			End If
		Next		
	End If
	
End Sub


Sub ToUnsigned(b As Byte) As Int
	Return Bit.And(0xFF, b)
End Sub


Sub BLE_StateChanged(state As Int)
	If state = bleManager.STATE_POWERED_ON Then
		ToastMessageShow("Bluetooth power on", True)
		bleEnabled = True
	Else If state = bleManager.STATE_POWERED_OFF Then
		ToastMessageShow("Bluetooth power off", True)
		bleEnabled = False
	End If
End Sub
#End Region


