B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=7.3
@EndOfDesignText@
'--------------------------------------------------------------------------------------------------
' Bluetooth Activity
' 
' Developed by Volker Petersen (volker.petersen01@gmail.com)
' based on original code by Calypso Marine Instruments 
' July 2018
' -------------------------------------------------------------------------------------------------
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

'#Extends: android.support.v7.app.ActionBarActivity
'#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Dim lDevices As List
	Dim lUltra As tUltra
	
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private clv As ListView
	Private lblHeader As Label
	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("actBleActivity")
	
	lDevices.Initialize
		
End Sub


Sub Activity_Resume
	lblHeader.Text = "Scanning Bluetooth Devices...."
End Sub


Sub Activity_End( mac As String )
	Activity.Finish
	Return
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	'Starter.bleSelect = False 
	'CallSubDelayed( Main, "Disconnect_Bluetooth")
End Sub


Sub addToListRT
	Dim lUltra As tUltra
	Dim i As Int

	lblHeader.Text = "Click on the device to connect..."
	Log("actBLE->addToListRT(): found devices " & (Starter.bleDevices.Size))
		
	' sort the entries in devices by their RSSI key
	'For Each dev In Starter.bleDevices.Values
	lDevices.Clear
	For i=0 To Starter.bleDevices.Size-1
		lDevices.Add( Starter.bleDevices.GetValueAt(i) )
	Next
	lDevices.SortType( "RSSI", False )
			
	clv.Clear
	For i=0 To lDevices.Size-1
		lUltra = lDevices.Get(i)
		If (Starter.prefBluetoothMAC = lUltra.MacAddress) Then
			clv.AddSingleLine2(Starter.prefBluetoothName & " - " & lUltra.MacAddress, lUltra)
		Else
			clv.AddSingleLine2(lUltra.Name & " - " & lUltra.MacAddress, lUltra)
		End If
		Log("actBLE->addToListRT(): Scan found: " & lUltra.Name & "-" & lUltra.MacAddress & _
			"prefMAC: " & Starter.prefBluetoothMAC & " rssi: " & lUltra.RSSI)
		clv.SingleLineLayout.Label.TextColor = Colors.White
		clv.SingleLineLayout.Label.TextSize = 16
	Next
End Sub

Sub displayDiscoveryFinishedStatus
	lblHeader.Text = "Please click on device to connect to"
	Log("actBLE->displayDiscoveryFinishedStatus(): found devices " & (Starter.bleDevices.Size) )
End Sub


Sub clv_ItemClick (Position As Int, ultra As tUltra)
	Log("actBLE->clv_ItemClick(): found devices " & (Starter.bleDevices.Size))
	If Starter.bleConnected Then
		Log("actBLE->clv_ItemClick(): Device is already connected. Terminating")
		Starter.bleManager.StopScan
		Starter.bleScanTimeout.Enabled = False
		Activity.Finish
	Else
		clv.Enabled = False				' stop user from selecting another device to connect to

		If ultra.Name.StartsWith("CUPS") Then
			Starter.deviceType = 1
		else if ultra.Name.StartsWith("ULTRA") Then
			Starter.deviceType = 2
		else if ultra.Name.StartsWith("NMEA") Then
			Starter.deviceType = 3
		End If

		CallSubDelayed2( Starter, "ConnectBle", ultra )
		Log("actBLE->clv_ItemClick(): Terminating after Starter-ConnectBle() call for device type " & Starter.deviceType)

		Activity.Finish
	End If
End Sub
