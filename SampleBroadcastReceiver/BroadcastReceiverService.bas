B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=8.3
@EndOfDesignText@
'--------------------------------------------------------------------------------------------------
' Sample Broadcast Receiver
' 
' Example of a 3rd Party App that accepts data from the CalypsoUltrasonicAPI app that manages
' the data connection with Calypso Ultrasonic Anemometer.
'
' Developed by Volker Petersen (volker.petersen01@gmail.com)
' July 2018
' -------------------------------------------------------------------------------------------------
'
' https://www.b4x.com/android/forum/threads/intent-filters-intercepting-sms-messages-in-the-background.20103/#content
'
' You need to add this code into the manifest file: 
'	AddPermission(android.permission.RECEIVE_ULTRASONIC_API)
'	AddReceiverText(Starter,
'	<intent-filter>
'	    <action android:name="com.calypso.api.ACTION_DATA_AVAILABLE" />
'	</intent-filter>)
'
' in this example the Starter service module was specified that the intent will be delegated to
' (any other service module will do).  You also need to add the RECEIVE_ULTRASONIC_API permission.
'
#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public broadcastIntent As Intent
	Public TEMP As Float
	Public AWD As Float
	Public dataFieldsAPI As List
	Public broadcastReceiverID As String
End Sub

Sub Service_Create
	' Initialize a list of all available Broadcast Intent Extras
	dataFieldsAPI.Initialize2(Array As String("Battery", "Temp", "AWA", "AWD", "AWS", "TWA", "TWD", "TWS", _
			"Pitch", "Roll", "COG", "SOG"))

	broadcastReceiverID = "com.calypso.api.ACTION_DATA_AVAILABLE"  ' must match the Manifest entry

End Sub

Sub Service_Start (StartingIntent As Intent)

	'Log("Intent Action: "&StartingIntent.Action&" looking for: "&broadcastReceiverID)
	If StartingIntent.Action = broadcastReceiverID Then
		ParseIntentData(StartingIntent)
	End If
	Sleep(50)
	
	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
End Sub

Sub Service_Destroy

End Sub

Sub ParseIntentData(apiINTENT As Intent)
	Dim value() As String
	If apiINTENT.HasExtra("Temp") Then
		value = apiINTENT.GetExtra("Temp")
		Log("Temp value: " & value(0))
		If (value.Length>0 And value(0).Length>0) Then
			TEMP = value(0)
		Else
			TEMP = 0.0
		End If
	End If
	If apiINTENT.HasExtra("AWD") Then
		value = apiINTENT.GetExtra("AWD")
		Log("AWD value: " & value(0))
		If (value.Length>0 And value(0).Length>0) Then
			AWD = value(0)
		Else
			AWD = 0.0
		End If
	End If

End Sub