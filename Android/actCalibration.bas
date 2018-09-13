B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.3
@EndOfDesignText@
'--------------------------------------------------------------------------------------------------
' Calibration Activity
' 
' Developed by Volker Petersen (volker.petersen01@gmail.com)
' July 2018
' -------------------------------------------------------------------------------------------------
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
	Activity.Title = "Anemometer Compass Calibration"
	btnCalibrate.Text = "Start Calibration"
	btnCalibrate.Tag = "Cal"
	fileName = Starter.calibrationDataFile
		
End Sub

Sub Activity_Resume
	Dim str As String
	Dim answer As Int
	instructions1 = "Calibration Process requires an Anemometer Reset."
	instructions2 = "To calibrate the Anemometer compass execute 2 complete clockwise turns at a rate of 150-200 data points per turn. Hit the button when you are ready to start...."
	lblRevCtr.Text = ""
	
	If Starter.compCalNow = False Then
		If Starter.calibrationReset Then
			btnCalibrate.Enabled = True
			lblMESSAGE.Text = instructions2
		Else
			btnCalibrate.Enabled = False
			lblMESSAGE.Text = instructions1
			str = "Calibration Process requires an Anemometer Reset. If that has been done, hit 'OK'. If not, hit 'Reset Now' and then goto the Menu option"
			str = str & " 'Anemometer Reset' and reconnect the Bluetooth connection before returning to this Calibration screen."
			answer = Msgbox2(str, "Anemometer Reset", "OK", "", "Anemometer Reset", Starter.appIcon)
			If answer = DialogResponse.NEGATIVE Then
				Activity.Finish
			End If
			btnCalibrate.Enabled = True
			lblMESSAGE.Text = instructions2
		End If
	End If
	
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub btnCalibrate_Click
	Dim feedback As Int
	Dim str As String
	
	If btnCalibrate.Tag = "Cal" Then
		Starter.compCalValues.Initialize
		Starter.compCalCtr = 0
		Starter.compCalNow = True
		btnCalibrate.Text = "Stop Cal"
		btnCalibrate.Tag = "Stop"
		lblMESSAGE.Text = instructions2
		lblRevCtr.Text = "0 turns"

	Else If btnCalibrate.Tag = "Stop" Then
		Starter.compCalNow = False
		feedback = Msgbox2("Do you want to Stop&Save or Restart this calibration process?", _
		"Calibration Process Status", "Stop&Save", "", "Restart", Starter.appIcon )
		If (feedback = DialogResponse.POSITIVE) Then
			Starter.calcTools.CompassCalibrationMatrix
			If Save_Calibration_Data Then
				str = "Saved "& Starter.compCalValues.Size &" calibration data points to the file '" & File.DirDefaultExternal
				str = str & "/" & fileName & "'. Calibration Process complete." & CRLF
				str = str & "Hard Iron: x=" & NumberFormat(Starter.calibrationMatrix(0,2),1,5) & "  y=" & NumberFormat(Starter.calibrationMatrix(1,2),1,5) & CRLF
				str = str & "Hard Iron: z=" & NumberFormat(Starter.zHardIron,1,5) & CRLF
				str = str & "Soft Iron: (0,0)=" & NumberFormat(Starter.calibrationMatrix(0,0),1,5) & "  (0,1)=" & NumberFormat(Starter.calibrationMatrix(0,1),1,5) & CRLF
				str = str & "Soft Iron: (1,0)=" & NumberFormat(Starter.calibrationMatrix(1,0),1,5) & "  (1,1)=" & NumberFormat(Starter.calibrationMatrix(1,1),1,5 )
			Else
				str = "Couldn't save the calibration data to file '" & File.DirDefaultExternal & "/" & fileName & "'. Calibration Process failed."
			End If
			Msgbox2(str, "Calibration Process", "OK", "", "", Starter.appIcon)
			Activity.Finish
		Else
			lblMESSAGE.Text = "Canceled last calibration process. Hit the button when you are ready to start again...."
			btnCalibrate.Text = "Start Calibration"
			btnCalibrate.Tag = "Cal"
		End If
	Else
		' pass
	End If	
End Sub


Sub UI_Update
	lblRevCtr.Text = Starter.compCalCtr & " data points.  Value read: " & Starter.compCalValues.Get(Starter.compCalCtr-1)
End Sub

Sub Save_Calibration_Data As Boolean		
	File.WriteList(File.DirDefaultExternal, fileName, Starter.compCalValues)
	Log("Calibration data written to: " & File.DirDefaultExternal & "/" & fileName)
	Return File.Exists(File.DirDefaultExternal, fileName)
End Sub
