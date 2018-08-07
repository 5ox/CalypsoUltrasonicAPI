B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.3
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Private btnCalibrate As Button
	Private btnReset As Button
	Private imgLOGO As ImageView
	Private imgULTRA As ImageView
	Private lblMESSAGE As Label
	Private lblRevCtr As Label
	Private instructions1 As String
	Private instructions2 As String
	Public fileName As String
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("actcalcomp")
	btnCalibrate.Text = "Phase II"
	btnCalibrate.Tag = "PhaseII"
	btnReset.Text = "Reset"
	btnReset.Tag = "Reset"
	fileName = "CompassCalibrationData.txt"

	If File.ExternalWritable = False Then
		Msgbox2("Cannot write to the default storage location. Can not start the calibration process", "Storage Access Error", "OK", "", "", Starter.appIcon)
		Activity.Finish
	End If

	Dim str As String = File.DirDefaultExternal&"/calibration"
	Log("file exits DirAssest: " & File.Exists(File.DirAssets, fileName) & " DirDefaultExternal: "&File.Exists(File.DirDefaultExternal, fileName))
	If File.Exists(File.DirDefaultExternal, fileName) = False Then
		File.MakeDir(File.DirDefaultExternal, "calibration")
		Log("test: " & File.IsDirectory(str, ""))
	End If
		
End Sub

Sub Activity_Resume
	Activity.Title = "Compass Calibration - Phase I"
	instructions1 = "Calibration Process Phase I: Device Reset. Hit the 'Reset' button to reset the device. When the reset is completed and the Bluetooth reconnected, hit the 'Phase II' button."
	instructions2 = "To calibrate the compass execute 2 complete clockwise turns at a rate of 50-100 data points per turn. Hit the button when you are ready to start...."
	lblMESSAGE.Text = instructions1
	lblRevCtr.Text = ""
	
	If Starter.calibrationReset Then
		btnCalibrate.Enabled = True
	Else
		btnCalibrate.Enabled = False
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub btnReset_Click
	' Factory reset
	Dim str As String 
	Dim bc As ByteConverter
	
	str = "01"
	bc.LittleEndian = True
	
	If Starter.bleNotify And Starter.cReset.StartsWith( "0000a00a" ) Then
		Starter.bleManager.WriteData(Starter.anemometerServiceID, Starter.cReset, bc.HexToBytes(str))
		Msgbox2("Resetting now. Please wait 3 min to reconnect the Bluetooth connection and then return to this Calibration screen.", _
		"Anemometer reset", "OK", "", "", Starter.appIcon)
		Activity.Title = "Compass Calibration - Phase II"
		lblRevCtr.Text = ""
		Starter.bleConnected = False
		Starter.calibrationReset = True
		Activity.Finish
	Else
		Msgbox2("No Bluetooth connection. Please make sure the phone receives data from the Anemometer", _
		"Reset failed", "OK", "", "", Starter.appIcon)
		Activity.Finish
	End If
End Sub

Sub btnCalibrate_Click
	Dim feedback As Int
	
	If btnCalibrate.Tag = "PhaseII" Then
		Starter.compCalValues.Initialize
		Starter.compCalCtr = 0
		Starter.compCalNow = True
		Starter.offsetAngle = 0
		btnCalibrate.Text = "Stop Cal"
		btnCalibrate.Tag = "Stop"
		lblMESSAGE.Text = instructions2
		lblRevCtr.Text = "0 turns"
	Else If btnCalibrate.Tag = "Stop" Then
		Starter.compCalNow = False
		feedback = Msgbox2("Do you want to Stop&Save or Restart this calibration process?", _
		"Calibration Process Status", "Stop&Save", "", "Restart", Starter.appIcon )
		If (feedback = DialogResponse.POSITIVE) Then
			btnCalibrate.Text = "Phase III"
			btnCalibrate.Tag = "PhaseIII"
			Save_Calibration_Data
			' execute Phase II of the calibration process - set the offset angle
			Activity.Finish
		Else
			lblMESSAGE.Text = "Canceled last calibration process. Hit the button when you are ready to start again...."
			btnCalibrate.Text = "Start Calibration"
			btnCalibrate.Tag = "PhaseII"
		End If
	Else
		' pass
	End If	
End Sub

Sub UI_Update
	lblRevCtr.Text = Starter.compCalCtr & " data points"
End Sub

Sub Save_Calibration_Data
	' writes data to he folder: <storage card>/Android/data/<package>/files/
	
	btnCalibrate.Text = "Start Calibration"
	btnCalibrate.Tag = "Start"

	If File.Exists(File.DirDefaultExternal, fileName) = False Then
		File.WriteString(File.DirInternal, fileName, " ")
		'Log("test written to: " & File.DirInternal & "/" & fileName)
		
		If File.Exists(File.DirInternal, fileName) Then
			File.Copy(File.DirInternal, fileName, File.DirDefaultExternal, fileName)
			'Log("file exits File.DirDefaultExternal: " & File.Exists(File.DirDefaultExternal, fileName))
		End If
		'Log("file exits Internal: " & File.Exists(File.DirInternal, fileName))
	End If
		
	File.WriteList(File.DirDefaultExternal, fileName, Starter.compCalValues)
	Log("Calibration data written to: " & File.DirDefaultExternal & "/" & fileName)
	 
End Sub
