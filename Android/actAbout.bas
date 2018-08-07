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

	Private btnOK As Button
	Private lblText As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("actAboutActivity")
	Activity.Title = "Calypso Ultrasonic API - Info"
End Sub

Sub Activity_Resume
	Dim str As String
	str = "This API app will establish a Bluetooth connection to the Calypso Ultrasonic Anemometer"
	str = str & " and broadcast a data stream via Intents to other Apps. 3rd party App utilize"
	str = str & " Broadcast Receivers to receive the data stream./n"
	str = str & "Please see more at 'https://calypsoinstruments.com'."
	lblText.Text = str
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then
		Activity.Finish
	End If
End Sub


Sub btnOK_Click
	Activity.Finish
End Sub