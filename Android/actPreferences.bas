B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8.3
@EndOfDesignText@
'--------------------------------------------------------------------------------------------------
' Preference Activity
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

End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	'Activity.LoadLayout("Layout1")
	If FirstTime Then
		'If Starter.prefManager.GetAll.Size = 0 Then SetDefaults
		'CreatePreferenceScreen
		'StartActivity(Starter.prefScreen.CreateIntent)
	End If
End Sub

Sub Activity_Resume
	HandleSettings
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub
