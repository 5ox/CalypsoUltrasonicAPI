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
	Public broadcastFrequency As Int	' frequency (in milliseconds) of Broadcast Intent transmissions
	Public javaInline As JavaObject 	' object for Inline Java code imbedded in B4a program Starter()
	Public javaNative As JavaObject 	' object for Native Java object to be called
	Public rp As RuntimePermissions
	Public allowReport As Boolean=True	' allowed error reporting by user / TODO set up as preferences
	Private logs As StringBuilder
	Private logcat As LogCat
	Public appIcon As Bitmap
	
	' User Preferences
	Dim prefManager As PreferenceManager	' User Preference Manager
	Dim prefScreen As PreferenceScreen	' User Preference Screen
	Public prefSmoothing As Float		' data smoothing on (<1.0) / off (=1.0)
	Public prefSampleRate As Int		' data aquisition frequency (sample Rate) 1Hz, 4Hz, 8Hz
	Public prefErrReporting As Boolean	' allow error/crash reporting
	Public prefTrueNorth As Boolean		' True yields True North, False yields Magnetic North
	Public prefBluetoothName As String	' Name of the last connected Bluetooth Device
	Public prefBluetoothMAC As String	' Mac Address of the last connected Bluetooth Device
	Public prefPhoneCompass As Boolean	' when true we use the phone compass data when we don't have valid GPS heading data

	' Phone services
	Public phoneManager As Phone		' get us the Phone device class
	Public phoneSensors As PhoneSensors	' get us the Phone Sensors class.
	Public phoneCompass As Float		' Otherwise we use the Phone magnetic sensor data (phone must be aligned with boat)
	
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
	Public gpsManager As GPS			' get us the phone's Location Services (GPS) class
	Public gpsChanged As Boolean		' true if Location changed
	Public gpsLocation As Location		' holds latest GPS loaction
	Public activeGPS As Boolean			' true if Location Services are enabled
	Public validBearing As Boolean		' true if the Location service yields a valid heading data
	Public gpsStarted As Boolean		' true if the Location Services are running
	Public gpsString As String			' String with GPS status msg
	Public localDeclination As Float	' local Declination data, updated in Location Services
	
	' Anemometer Services
	Public deviceType As Int			' Cups=1, Ultrasonic=2 NMEA=2
	Public compCalMax As Int = 800		' maximun of number of compass calibration datapoint
	Public compCalCtr As Int			' compass calibration datapoint counter
	Public compCalValues As List		' store the compass calibration values
	Public compCalNow As Boolean		' compass calibration runs when True. False stops this process
	Public sensorData As Map			' current datapoint received from the sensors via BLE and GPS
	Public sensorDataProcessed As Map	' processed datapoints after Kalman, Lowpass, or No filter has been applied 
	Public dataFields As List			' data fields in the 'sensorData' & 'sensorDataPrev' dictionaries
	Public dataFieldsFilter As List		' data fields to be smoothed when this feature is enabled in Preference Settings
	Public dataFieldsCircular As List	' data fields that hold a cicular value (i.e., direction ranging from 0-359.999 degree)
	Public dataFieldsAPI As List		' data fields that will be transmitted by the API (using Broadcast Intents)
	
	Type tUltra(Name As String, MacAddress As String, RSSI As Double)
	Public connectedDevice As tUltra	' tUltra data of the actual device connected to this App
	
	Public timeout As Long = 15000		' timeout in milliseconds for the BLE scan
	Public tryTimes As Int = 0

	Public anemometerServiceID As String 	' Service ID of the Data Services for the connected Ultra device
	Dim cNormal, cRate, cSensors, cStatus, cReset, cCalComp As String
	
	Public invalidMAC As String = "??:??"
	Public defaultSensorName As String = "Ultrasonic Anemometer"
	
	Public ctr_ble As Int				' BLE data set transfer counter for debugging only	
	Public deviceInfo As Map
	
	Public offsetAngle As Int = 0		' calibration offset angle
	
	Public calcTools As ComputationTools ' class of various calculation tools & methods
	Public speedToKnots As Float
	
	Public calibrationReset As Boolean	' keep track if a reset has been done as part of the multi step calibration process
	
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
	
	' initialize the phone's GPS, compass, and Bluetooth services
	gpsManager.Initialize("GPS")		' initialize the Location Services	
	validBearing = False
	activeGPS = (gpsManager.GPSEnabled And gpsManager.IsInitialized)
	bleManager.Initialize("BLE")		' initialize the Bluetooth device
	
	' initialize the Sensor data (GPS->Location and BLE->Anemometer) dictionaries and Data Fields
	dataFields.Initialize2(Array As String("Battery", "Temp", "AWA", "AWD", "AWS", "TWA", "TWD", "TWS", _
			"Pitch", "Roll", "Compass", "ALT", "LAT", "LON", "COG", "SOG", "DECL", "STATUS"))
	dataFieldsFilter.Initialize2(Array As String("AWA", "AWS", "Pitch", "Roll", "Compass", "COG", "SOG"))
	dataFieldsCircular.Initialize2(Array As String("AWA", "Compass", "COG"))
	dataFieldsAPI.Initialize2(Array As String("Battery", "Temp", "AWA", "AWD", "AWS", "TWA", "TWD", "TWS", _
			"Pitch", "Roll", "COG", "SOG"))
	sensorData.Initialize
	sensorDataProcessed.Initialize
	bleDevices.Initialize

	Dim i As Int
	For i=0 To dataFields.Size-1
		sensorData.Put(dataFields.Get(i), 0.0)
		sensorDataProcessed.Put(dataFields.Get(i), 0.0)
	Next
		
	bleStateText = "BLE Disconnected"
	ctr_ble = 0
	
	connectedDevice.Initialize
	connectedDevice.Name = "unkown"
	connectedDevice.MacAddress = invalidMAC
	connectedDevice.RSSI = 0.0
	
	appIcon = LoadBitmap(File.DirAssets, "api_icon.png")

	' initialize Native Java code options. The javaInline must be initialized in the Activity that uses it (for us Main())
	javaNative.InitializeStatic("android.hardware.SensorManager")

	calcTools.Initialize
	speedToKnots = 1.943844492		' m/s to knots conversion -> 1.943844492 kts per m/s
	localDeclination = 999.0		' default value that will force update with actual value from phone
	compCalValues.Initialize
	compCalNow = False
	calibrationReset = False
End Sub

Sub Service_Start (StartingIntent As Intent)
	If prefPhoneCompass Then Init_Phone_Compass
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
	Service_Destroy

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
	email.Subject = "App crash report " & connectedDevice.macaddress & " " & phoneManager.Manufacturer
	email.Subject = email.Subject & " " & phoneManager.Model & " " & phoneManager.Product
	email.Body = logs
	StartActivity(email.GetIntent)
	Return True
End Sub

Sub Service_Destroy
	Log("Starter->Service_Destroy(): Shutting App down now...")
	bleManager.Disconnect
	gpsManager.Stop
	phoneSensors.StopListening
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
		gpsManager.Start(250, 10)		' update every 250 milliseconds or 10 meters
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
	If myLocation.SpeedValid Then
		sensorData.Put("SOG", myLocation.Speed)
	Else
		sensorData.Put("SOG", 0.0)
	End If
	If myLocation.BearingValid Then
		sensorData.Put("COG", myLocation.Bearing)
		If (sensorData.Get("SOG") > 0.514444) Then		' need at least 1kt=0.514444 m/s of boat speed before we trust COG data
			sensorData.Put("Compass", myLocation.Bearing)
			validBearing = True
			'Log("Used GPS compass value")
		End If
		phoneCompass = myLocation.Bearing
	Else
		sensorData.Put("COG", 0.0)
		validBearing = False
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
	If localDeclination > 990.0 Then
		' get the magnetic delication at the current location & altitude
		localDeclination = magDeclination
		'Log("Starter->after magDeclination() : localDeclination = " & localDeclination)
	End If
	sensorData.Put("DECL", localDeclination)

End Sub


Sub magDeclination() As Float
	' get the magnetic declination for the current location
	Dim magDec As Float = 0.0  			' default value
	#if B4A
		Dim millis As Long = DateTime.Now
		magDec = javaInline.RunMethod("getDeclinationJava", Array As Object(sensorData.Get("LAT"), sensorData.Get("LON"), sensorData.Get("ALT"), millis))
		'Log("Starter->magDeclination(): mag Declination = " & magDec & " | " & millis)
	#end if
	Return magDec
End Sub

#End Region

#Region Orientation
'--------------------------------------------------------------------------------------------------
' Phone Orientation
'--------------------------------------------------------------------------------------------------
Sub Init_Phone_Compass
	phoneSensors.Initialize2(phoneSensors.TYPE_ORIENTATION, 3)  ' slowest rate of phone's compass data
	phoneSensors.StartListening("orientation")					' data comes to sub "orientation_SensorChanged"
End Sub

Sub orientation_SensorChanged (Values() As Float)
	' only use this value if User Preferences allow it and we don't have a valid Bearing from the GPS
	'Log("Starter->orientation_SensorChanged(): Phone Compass: " & NumberFormat(Values(0), 3, 0) & " | "  & NumberFormat(Values(1), 3, 0) & " | " &NumberFormat(Values(2), 3, 0))
	If validBearing=False And prefPhoneCompass Then
		phoneCompass = Values(0)
		If Not( Main.portrait ) Then
			phoneCompass = (phoneCompass + 90) Mod 360
		End If
		
		' force compass data to True North so that all internal App directional data is True North 
		phoneCompass= calcTools.MagneticToTrueNorth(phoneCompass)
		sensorData.Put("Compass", phoneCompass)
		'Log("Used Phone compass Orientation value: " & NumberFormat(phoneCompass, 3, 0))
	End If
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

	connectedDevice = ultra
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
	Log("Starter->BLE_Connect(): known device " & (prefBluetoothMAC = connectedDevice.MacAddress))
	If (prefBluetoothMAC = connectedDevice.MacAddress) Then
		' for KOWN device, use the name from the User Preference setting
		bleStateText = "BLE '" & prefBluetoothName & "' Connected."
		Log("Starter->BLE_Connect(): to known device " & prefBluetoothName)
	Else
		' for UNKOWN device, use actual Name and update the User Preference "bleMAC" setting
		bleStateText = "BLE '" & connectedDevice.Name & "' Connected."
		prefBluetoothName = connectedDevice.Name
		prefBluetoothMAC = connectedDevice.MacAddress
		prefManager.SetString("bleMAC", connectedDevice.MacAddress)
	End If
	cNormal = ""
	cRate = ""
	For Each s As String In Services
		Log("Starter->BLE_Connect(): Service: " & s)
		If s.StartsWith( "0000180d" ) Then
			bleManager.ReadData(s)					' this service gets the data stream with the sensor data
		Else If s.StartsWith( "0000180a" ) Then
			bleManager.ReadData(s)					' this service yields the Device Information
		End If
	Next
	
	CallSub(Main, "Launch_Background_Services")
End Sub

Sub BLE_Disconnected
	bleConnected = False
	bleConnectTimeout.Enabled = False
	bleScanTimeout.Enabled = False
	bleNotify = False
	'ToastMessageShow( "Disconnected from " & connectedDevice.MacAddress, False )
	If (prefBluetoothMAC = connectedDevice.MacAddress) Then
		bleStateText = "BLE '" & prefBluetoothName & "' Disconnected!"
	Else
		bleStateText = "BLE '" & connectedDevice.Name & "' Disconnected!"
	End If
	
	' set all sensor data fields to zero
	Dim i As Int
	For i=0 To dataFields.Size-1
		sensorData.Put(dataFields.Get(i), 0.0)
	Next
	
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
	Dim value As String
	Dim sr As Short
	'Dim millis As Long = DateTime.Now
	
	If serviceID.StartsWith( "0000180d" ) Then
		' Sensor Data available under this ServiceID
		anemometerServiceID = serviceID
		If Not( bleNotify ) Then
			For Each id As String In Characteristics.Keys
								
				' Device Status (00-sleep mode, 01-Low Power, 02-Normal Mode)
				If id.StartsWith( "0000a001" ) Then
					cStatus = id
					sr = bc.HexFromBytes(Characteristics.Get(cStatus))
					Log( "Starter->BLE_DataAvailable(): BLE Device Status: " & sr)
				End If
				
				' Sample Rate - set it to match the User Preference settings
				If id.StartsWith( "0000a002" ) Then
					cRate = id

					sr = bc.HexFromBytes(Characteristics.Get(cRate))
					Log("Starter->BLE_DataAvailable(): FOUND sample rate: " & sr)
					
					If deviceType=2 Then
						If prefSampleRate = 1 Then
							value = "01"
						Else If prefSampleRate = 8 Then
							value = "08"
						Else
							value = "04"
						End If
						bleManager.WriteData( anemometerServiceID, cRate,  bc.HexToBytes( value ) )
						Log( "Starter->BLE_DataAvailable(): SET the BLE Device Sample Rate: " & value)
						Sleep(250)
						bleManager.ReadData2(anemometerServiceID, cRate)
					End If

				End If

				' Data Service that can also enable the BLE Notification feature
				If id.StartsWith( "00002a39" ) Then					' sensor data feed is on
					cNormal = id
					bleManager.SetNotify( anemometerServiceID, cNormal, True )
					bleNotify = True
				End If
				
				' Firmware Update or Device Reset
				If id.StartsWith( "0000a00a" ) Then
					cReset = id
				End If
				
				' Read calibration mode
				If id.StartsWith( "0000a00b" ) Then
					cCalComp = id
					'sr = bc.HexFromBytes(Characteristics.Get(cCalComp))
					'Log( "Starter->BLE_DataAvailable(): BLE Device Calibration Mode: " & sr)
				End If
				
				' Device Characteristic (Read/Write): Activate Roll/Pitch/Compass (0=Off, 1=On)
				' These services are only available on the Ultrasonic Sensor => deviceType=2
				If (id.StartsWith( "0000a003" ) And deviceType=2) Then
					cSensors = id
					Sleep(250)
					Log( "Switch Roll/Pitch/Compass Sensor on")
					bc.LittleEndian = True
					bleManager.WriteData( anemometerServiceID, cSensors,  bc.HexToBytes( "01" ) )
					Sleep(250)
				End If
			Next			
		End If
		
		If Characteristics.ContainsKey (cRate) Then
			sr = bc.HexFromBytes(Characteristics.Get(cRate))
			Log("Starter->BLE_DataAvailable(): FOUND new sample rate: " & sr)
		End If
		If Characteristics.ContainsKey( cNormal ) Then
			Dim bVars(4) As Byte	' each one of the 4 array elements is 1 byte
			Dim cVars(2) As Byte	' each one of the 2 array elements is 1 byte
			Dim sVars() As Short	' each array element has 2 bytes
			Dim aws, awa, compass As Float

			bc.LittleEndian = True	' The least significant byte (LSB) value is at the lowest address
			' java.lang.RuntimeException: java.lang.NumberFormatException: For input string: "00000000F02B0020F42B0020482C00209C2C"
			
			' Data structure and bytes utilized
			' 0-1: aws
			' 2-3: awa
			' 4:   Battery
			' 5:   Temp
			' 6:   Roll					' only available for deviceType 2=Ultrasonic
			' 7:   Pitch				' only available for deviceType 2=Ultrasonic
			' 8-9: Compass Direction	' only available for deviceType 2=Ultrasonic
			bc.ArrayCopy(Characteristics.Get(cNormal), 0, bVars, 0, 4 ) ' copy first 4 bytes into two signed Ints (2 bytes each)
			sVars = bc.ShortsFromBytes( bVars )

			aws = sVars(0)
			If aws > 0.1 Then			' apparent wind speeds > 0.1m/s or 0.2kts assumed to be
				awa = sVars(1)			' valid data.  If we don't have valid wind speed, it will
			Else						' be rounded to zero and direction is set to zero too.
				awa = 0	
			End If
			sensorData.Put("AWA", awa)
			sensorData.Put("AWS", aws/100.0)

			If deviceType = 2 Then  ' only available for Ultrasonic Sensor, deviceType=2
				bc.ArrayCopy(Characteristics.Get(cNormal), 4, bVars, 0, 4 ) ' copy 4 bytes with offset 4 to 4 unsigned single byte Int
				'Log( "Roll: " & ToUnsigned(bVars(2) ) )
				sensorData.Put("Battery", ToUnsigned(bVars(0))*10)
				sensorData.Put("Temp", ToUnsigned(bVars(1)) - 100)
				sensorData.Put("Roll", ToUnsigned(bVars(2)) - 90)
				sensorData.Put("Pitch", ToUnsigned(bVars(3)) - 90)
				bc.ArrayCopy(Characteristics.Get(cNormal), 8, cVars, 0, 2 ) ' copy 2 bytes with offset 8 into 2 bytes
				sVars = bc.ShortsFromBytes( cVars )
				compass = (360.0-sVars(0) + offsetAngle) Mod 360
				'Log("COMPASS: 1-0 = " & ToUnsigned(cVars(1)) & " : " & ToUnsigned(cVars(0)) & "   sVars= " & sVars(0) & "  comp=" & compass)

				' save raw compass readings into List 'compCalValues'
				If compCalNow Then
					compCalValues.Add(compass)
					compCalCtr = compCalCtr + 1
					If compCalCtr >= compCalMax Then 
						compCalNow = False
						CallSub(actCalibration, "Save_Calibration_Data")
					Else
						CallSub(actCalibration, "UI_Update")
					End If
				End If
				
				If validBearing = False And prefPhoneCompass = False Then
					' force compass data to True North so that all internal App directional data is True North
					compass = calcTools.MagneticToTrueNorth(compass)
					
					sensorData.Put("Compass", compass)
					'Log("Used Anemometer compass value raw: " & NumberFormat(compass, 3, 0))
				End If
			End If
			
			' process the raw sensor data and put results into 'sensorDataPrcessed'
			calcTools.Process_Sensor_Data
			
		End If
		
	Else If serviceID.StartsWith( "0000180a" ) Then
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
	
	'millis = DateTime.Now - millis
	'Log("Sensor data fetch took (millis): " & millis)
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


