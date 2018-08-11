B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.3
@EndOfDesignText@
'--------------------------------------------------------------------------------------------------
' Class of various Computation Tool Methods
'
'	- Lowpass Filter for standard and directional (circular) data
'	- 1D Kalman Filter for standard and directional (circular) data
'	- compute AWD, TWA, TWD, TWS from AWA, AWS, and SOG data
'	- convert from True North to Magnetic North and visa versa
' 
' Developed by Volker Petersen (volker.petersen01@gmail.com)
' July 2018
' -------------------------------------------------------------------------------------------------
Sub Class_Globals
	Public alpha As Float 			' Lowpass Filter parameter
	Public precission As Float		' Precission value to check for ZERO
	Public noFilter As List			' List of all data fields that aren't filtered
	Public key As String
	Type tKalman(err_measure As Float, err_estimate As Float, q As Float, current_estimate As Float, last_estimate As Float, kalman_gain As Float)
	Public kX,kY, kS As tKalman
End Sub


'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	precission = 0.000001
	alpha = Starter.prefSmoothing
	Dim i As Int
	
	'Log("Initialize: alpha = "&alpha&"  smoothing: "&Starter.prefSmoothing)
	noFilter.Initialize
	For i=0 To (Starter.dataFields.Size-1)
		key = Starter.dataFields.Get(i)
		If Starter.dataFieldsFilter.IndexOf(key) = - 1 Then
			noFilter.Add(key)
			'Log("no Filter: " & key)
		End If
	Next
	
	' Kalman filter parameters for circular data (kX, kY) and other (kS)
	kX.err_measure = 0.01
	kX.err_estimate =  kX.err_measure*Starter.prefSampleRate   'measue*refresh_hz
	kX.q = 0.01    ' larger values = less filtering
	kX.last_estimate = 0.0 
	
	kY.err_measure = kX.err_measure
	kY.err_estimate = kX.err_estimate
	kY.q = kX.q
	kY.last_estimate = 0.0
	
	kS.err_measure = kX.err_measure
	kS.err_estimate = kX.err_estimate
	kS.q = kX.q
	kS.last_estimate = 0.0

End Sub


Public Sub Process_Sensor_Data
	alpha = Starter.prefSmoothing
	'Log("Battery in Smooth: " & (Starter.dataFields.IndexOf("Battery") <> - 1) )
	'Log("Process_Sensor_Data(): alpha:           : " & alpha )
	Dim sog, awa, awd, aws, twa, twd, tws As Float
	Dim i, sign As Int
	
	If alpha < 1.0 Then
		' apply the appropiate filters to the raw data and store results in the Map "sensorDataProcessed"
		Apply_Filters
		
		' put all non-filtered raw values into the Map sensorDataProcessed
		For i=0 To (noFilter.Size-1)
			key = noFilter.Get(i)
			Starter.sensorDataProcessed.Put(key, Starter.sensorData.Get(key))
		Next
	Else
		' no filter applied. Just copy the raw data from to Map "sensorData" to the Map "sensorDataProcessed"
		For i=0 To (Starter.dataFields.Size-1)
			key = Starter.dataFields.Get(i)
			Starter.sensorDataProcessed.Put(key, Starter.sensorData.Get(key))
		Next
	End If
	
	
	' compute the AWD from the "DIR" apparent wind angle and "COG" values (in True North)
	awd = (Starter.sensorDataProcessed.Get("DIR")+Starter.sensorDataProcessed.Get("COG")) Mod 360.0
	Starter.sensorDataProcessed.Put("AWD", awd)
	
	' use the "DIR" apparent wind angle with range of 0-360 to compute the AWA with a range of -180 to +180 degrees
	awa = Starter.sensorDataProcessed.Get("DIR")
	If awa > 180.0 Then
		awa = awa - 360.0
		sign = -1
	Else
		sign = 1
	End If
	'Log("ComputationTools(): Direction: " & NumberFormat(Starter.sensorDataProcessed.Get("DIR"), 1, 1) & "   AWA: " & NumberFormat(awa, 1, 1))
	Starter.sensorDataProcessed.Put("AWA", awa)
	
	' compute TWA, TWD, and TWS
	aws = Starter.sensorDataProcessed.Get("AWS")
	sog = Starter.sensorDataProcessed.Get("SOG")
	If (aws <= Starter.minSpeed Or sog <= Starter.minSpeed) Then
		Starter.sensorDataProcessed.Put("TWA", awa)
		Starter.sensorDataProcessed.Put("TWD", awd)
		Starter.sensorDataProcessed.Put("TWS", aws)
	Else		
		tws = Sqrt(aws*aws + sog*sog - 2*aws*sog*CosD(awa))
		Starter.sensorDataProcessed.Put("TWS", tws)
		
		twa = ACosD(aws*CosD(awa)-sog/tws) * sign
		Starter.sensorDataProcessed.Put("TWA", twa)
		
		twd = (awd-(awa-twa)) Mod 360

		Starter.sensorDataProcessed.Put("TWA", twa)
		Starter.sensorDataProcessed.Put("TWD", twd)
		Starter.sensorDataProcessed.Put("TWS", tws)
	End If
	
End Sub

Public Sub Apply_Filters
	' fields that needs to be smoothed: dataFieldsFilter
	' fields that hold circular data:   dataFieldsCircular
	' Lowpass Filter is applied to all values in the Map 'sensorData' with key in 'dataFieldsFilter'
	' except for the key values 'AWA' and 'AWS' which will be run thru a Kalman Filter
	
	Dim i As Int
	Dim value As Float
	
	' apply the necessary filter to all data fields specified in 'Starter.dataFieldsFilter'
	For i=0 To (Starter.dataFieldsFilter.Size-1)
		key = Starter.dataFieldsFilter.Get(i)
		If  Starter.dataFieldsCircular.IndexOf(key) <> -1 Then
			' apply the Kalman Filter for circular data (awa Wind Direction, COG, and Compass data)
			value = Kalman_Filter_Circular(Starter.sensorData.Get(key))
			Starter.sensorDataProcessed.Put(key, value)
		Else If (key = "AWS") Then
			' apply AWS Kalman Filter
			value = updateEstimate( Starter.sensorData.Get(key), kS )
			Starter.sensorDataProcessed.Put(key, value)
		Else
			' apply simple Lowpass Filter
			value = alpha*Starter.sensorData.Get(key) + (1-alpha)*Starter.sensorDataProcessed.Get(key)
			Starter.sensorDataProcessed.Put(key, value)
		End If
	
	Next
	
End Sub


Public Sub Lowpass_Filter_Circular(raw As Float, lastFiltered As Float) As Float
	Dim value, rawX, rawY, lastX, lastY As Float
	
	rawX = CosD(raw)
	rawY = SinD(raw)
	lastX = CosD(lastFiltered)
	lastY = SinD(lastFiltered)
	
	rawX = alpha*rawX + (1-alpha)*lastX
	rawY = alpha*rawY + (1-alpha)*lastY
	
	If Abs(rawX)<precission Or Abs(rawY)<precission Then Return 0.0
	
	value = ATan2D(rawY, rawX)
	Return ( (value+360) Mod 360 )
	
End Sub

Public Sub Kalman_Filter_Circular(raw As Float) As Float
	Dim value, rawX, rawY, xe, ye As Float
	
	rawX = CosD(raw)
	rawY = SinD(raw)

	xe = updateEstimate( rawX, kX )
	ye = updateEstimate( rawY, kY )

	If Abs(xe)<precission Or Abs(ye)<precission Then Return 0.0

	value = ATan2D(ye, xe)
	Return ( (value+360) Mod 360 )
	
End Sub

Sub updateEstimate(measurement As Float, k As tKalman) As Float
  
	k.kalman_gain = k.err_estimate/(k.err_estimate + k.err_measure)
	k.current_estimate = k.last_estimate + k.kalman_gain * (measurement - k.last_estimate)
	k.err_estimate =  (1.0 - k.kalman_gain)*k.err_estimate + Abs(k.last_estimate-k.current_estimate)*k.q
	k.last_estimate=k.current_estimate

	Return k.current_estimate
End Sub


Sub TrueToMagneticNorth(trueNorth As Float) As Float
	Dim declination As Float
	If (Starter.sensorData.Get("DECL") > 990) Then
		declination = 0.0
	Else
		declination = Starter.sensorData.Get("DECL")
	End If
	Return ((trueNorth + declination + 360) Mod 360)
End Sub


Sub MagneticToTrueNorth(magneticNorth As Float) As Float
	Dim declination As Float
	If (Starter.sensorData.Get("DECL") > 990) Then
		declination = 0.0
	Else
		declination = Starter.sensorData.Get("DECL")
	End If
	Return ((magneticNorth - declination + 360) Mod 360)
End Sub

Sub test
	' test dataset in Excel 'TWD_raw' / Sheet2 in VariousAppDevelopmentAssets in SailingRace
	Dim i As Int
	Dim lpf, kalman As Float
	Dim data As List
	data.Initialize
	data.AddAll(Array As Float(5, 0, 3, 6, 1, 353, 356, 1, 10, 0, 1, 353, 9, 358, 9, 351, 354, 1,0, 5))
	
	lpf = data.Get(0)
	kalman = Kalman_Filter_Circular(data.Get(0))
	Log("apha = " & alpha & " sample rate = " & Starter.prefSampleRate)
	Log("Kal raw=" & data.Get(0) & " filter=" & kalman)
	alpha = 0.2
	For i=1 To data.Size-1
		lpf = Lowpass_Filter_Circular(data.Get(i), lpf)
		kalman = Kalman_Filter_Circular(data.Get(i))
		Log("raw=" & data.Get(i) & " Kal-filter=" & kalman & " LP-filter=" & lpf)
	Next
	
End Sub
