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
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
End Sub

Sub Service_Create
	'This is the program entry point.
	'This is a good place to load resources that are not specific to a single activity.
	

End Sub

Sub Service_Start (startingIntent As Intent)
	
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy

End Sub
