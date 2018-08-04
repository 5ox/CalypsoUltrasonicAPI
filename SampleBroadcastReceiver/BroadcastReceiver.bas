B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=8.3
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Public broadcastIntent As Intent
	Public AWA As Float
	Public AWD As Float
	Public AWS As Float
	Public dataFieldsAPI As List
	Public broadcastReceiverID As String

End Sub

Sub Service_Create
	' Initialize a list of all available Broadcast Intent Extras
	dataFieldsAPI.Initialize2(Array As String("Battery", "Temp", "AWA", "AWD", "AWS", "TWA", "TWD", "TWS", _
			"Pitch", "Roll", "Compass", "COG", "SOG"))

	broadcastReceiverID = "com.calypso.api.ACTION_DATA_AVAILABLE"  ' must match the Manifest entry

End Sub

Sub Service_Start (StartingIntent As Intent)
	Log("Intent Action: "&StartingIntent.Action&" looking for: "&broadcastReceiverID)
	If StartingIntent.Action = broadcastReceiverID Then
		ParseIntentData(StartingIntent)
	End If
	
	Service.StopAutomaticForeground 'Call this when the background task completes (if there is one)
End Sub

Sub Service_Destroy

End Sub

Sub ParseIntentData(apiINTENT As Intent)
	If apiINTENT.HasExtra("AWA") Then
		Dim value() As String
		value = apiINTENT.GetExtra("AWA")
		Log("AWA value: " & value(0))
		If (value.Length>0 And value(0).Length>0) Then
			AWA = value(0)
		Else
			AWA = 0.0
		End If
	End If
	
End Sub