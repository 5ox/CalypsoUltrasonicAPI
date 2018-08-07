B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=8.3
@EndOfDesignText@
'--------------------------------------------------------------------------------------------------
' Background Services
'	they will execute every Starter.broadcastFrequency milli-seconds
'	they will be terminated when Starter.runBackgroundTasks is set the False
'	they are started by settin Starter.runBackgroundTasks to True and calling StartService(BackgroundService)
' 
' Developed by Volker Petersen (volker.petersen01@gmail.com)
' July 2018
' -------------------------------------------------------------------------------------------------
' https://www.b4x.com/android/forum/threads/send-data-to-app-by-intent.43570/
'
#Region  Service Attributes 
	#StartAtBoot: False	
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public API As Intent
	'Public intentObject(1) As String Array
End Sub

Sub Service_Create
End Sub

Sub Service_Start (StartingIntent As Intent)
	' Broadcast Intents will transmit the data in 'sensorData' to other Apps
	
	' using a Timer is causing an App shutdown. Not yet fully investigated
	'Public broadcastTimer As Timer
	'broadcastTimer.Initialize("broadcastNow", Starter.broadcastFrequency)
	'broadcastTimer.Enabled = True
	Do While(Starter.runBackgroundTasks)
		If (Starter.bleConnected ) Then
			Send_Broadcast_Intents
		End If
		Sleep(Starter.broadcastFrequency)
	Loop
	'broadcastTimer.Enabled = False
	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
End Sub

Sub Service_Destroy

End Sub


Sub broadcastNow_Click
	If (Starter.bleConnected ) Then
		Send_Broadcast_Intents
	End If
End Sub

Sub Send_Broadcast_Intents
	Dim i As Int
	Dim str As String
	
	API.Initialize("com.calypso.api.ACTION_DATA_AVAILABLE", "")
	For i=0 To Starter.dataFieldsAPI.Size-1
		str = Round2( Starter.sensorDataProcessed.Get(Starter.dataFieldsAPI.Get(i)), 3)
		API.PutExtra(Starter.dataFieldsAPI.Get(i), Array As String(str) )
	Next
	Starter.phoneManager.SendBroadcastIntent(API)

	Starter.ctr_ble = Starter.ctr_ble + 1
	'Log("BackgroundServices->Send_Broadcast_Intents: " & Starter.ctr_ble & ".) send:" & Starter.dataFieldsAPI.Size&" fields")

End Sub