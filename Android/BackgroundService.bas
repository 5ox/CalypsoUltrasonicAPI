B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=8.3
@EndOfDesignText@
'--------------------------------------------------------------------------------------------------
' Background Services
'	they will execute every Starter.uiUpdateFrequency milli-seconds
'	they will be terminated when Starter.runBackgroundTasks is set the False
'	they are started by settin Starter.runBackgroundTasks to True and calling StartService(BackgroundService)
' 
' Developed by Volker Petersen (volker.petersen01@gmail.com)
' July 2018
' -------------------------------------------------------------------------------------------------
#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
End Sub

Sub Service_Create

End Sub

Sub Service_Start (StartingIntent As Intent)
	' TODO add Broadcast Intents to send out Anemometer data to other Apps
	Do While(Starter.runBackgroundTasks)
		If (Starter.bleConnected And Not(Starter.mainPaused) ) Then
			CallSub(Main, "update_UI")  ' calls sub in main to update the display
		End If
		Sleep(Starter.uiUpdateFrequency)
	Loop
	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
End Sub

Sub Service_Destroy

End Sub
