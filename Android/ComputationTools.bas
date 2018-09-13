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
'	- compute compass claibration matrix (Soft- and Hard-Iron)
' 
' Developed by Volker Petersen (volker.petersen01@gmail.com)
' July 2018
' -------------------------------------------------------------------------------------------------

Sub Class_Globals
	'--------------------------------------------------------------------------------------------------
	' define the Global variables
	'--------------------------------------------------------------------------------------------------
	Public alpha As Float 			' Lowpass Filter parameter
	Public precission As Float		' Precission value to check for ZERO
	Public noFilter As List			' List of all data fields that aren't filtered
	Public key As String
	Type tKalman(err_measure As Float, err_estimate As Float, q As Float, current_estimate As Float, last_estimate As Float, kalman_gain As Float)
	Public kX,kY, kS As tKalman
	Public calibrationData As List
End Sub


Public Sub Initialize
	'--------------------------------------------------------------------------------------------------
	' Initializes the object with the Kalman Filter parameters. 
	' You can add parameters to this method if needed.
	'--------------------------------------------------------------------------------------------------
	calibrationData.Initialize
	precission = 0.0000001
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
	'--------------------------------------------------------------------------------------------------
	' Function to process the raw sensor data by
	' a) applying either a Kalman- or Lowpass-Filter
	' b) computing the AWD, TWA, TWD, TWS values from the raw inputs AWA, COG, and SOG 
	'--------------------------------------------------------------------------------------------------
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
	
	'Log("Comp = " & NumberFormat(Starter.sensorData.Get("Compass"), 1, 2) & "  filter = " & NumberFormat(Starter.sensorDataProcessed.Get("Compass"), 1, 2) )
	
	
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
	If (aws < Starter.minSpeed Or sog < Starter.minSpeed) Then
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
	'--------------------------------------------------------------------------------------------------
	' Apply Kalman- and lowpass-Filter to the values in "Starter.sensorData" identified by the keys 
	' stored in the list "Starter.dataFieldsFilter"
	' fields that needs to be smoothed: dataFieldsFilter
	' fields that hold circular data:   dataFieldsCircular
	' Lowpass Filter is applied to all values in the Map 'sensorData' with key in 'dataFieldsFilter'
	' except for the key values 'AWA' and 'AWS' which will be run thru a Kalman Filter
	'--------------------------------------------------------------------------------------------------
	
	Dim i As Int
	Dim value As Float
	
	' apply the necessary filter to all data fields specified in 'Starter.dataFieldsFilter'
	For i=0 To (Starter.dataFieldsFilter.Size-1)
		key = Starter.dataFieldsFilter.Get(i)
		If  Starter.dataFieldsCircular.IndexOf(key) <> -1 Then
			' apply the Kalman Filter for circular data (awa Wind Direction, COG, and Compass data)
			'value = Kalman_Filter_Circular(Starter.sensorData.Get(key))
			value = Lowpass_Filter_Circular(Starter.sensorData.Get(key), Starter.sensorDataProcessed.Get(key))
			Starter.sensorDataProcessed.Put(key, value)
		Else If (key = "AWS") Then
			' apply AWS Kalman Filter
			'value = updateEstimate( Starter.sensorData.Get(key), kS )
			value = alpha*Starter.sensorData.Get(key) + (1-alpha)*Starter.sensorDataProcessed.Get(key)
			Starter.sensorDataProcessed.Put(key, value)
		Else
			' apply simple Lowpass Filter
			value = alpha*Starter.sensorData.Get(key) + (1-alpha)*Starter.sensorDataProcessed.Get(key)
			Starter.sensorDataProcessed.Put(key, value)
		End If
	
	Next
	
End Sub


Public Sub Lowpass_Filter_Circular(raw As Float, lastFiltered As Float) As Float
	'--------------------------------------------------------------------------------------------------
	' Compute the Lowpass Filter for Circular data
	'--------------------------------------------------------------------------------------------------
	Dim rawX, rawY, lastX, lastY As Float
	
	rawX = CosD(raw)
	rawY = SinD(raw)
	lastX = CosD(lastFiltered)
	lastY = SinD(lastFiltered)
	
	rawX = alpha*rawX + (1-alpha)*lastX
	rawY = alpha*rawY + (1-alpha)*lastY
		
	Return arctan2D(rawY, rawX)
	
End Sub

Public Sub Kalman_Filter_Circular(raw As Float) As Float
	'--------------------------------------------------------------------------------------------------
	' Compute the Kalman Filter for Circular data
	'--------------------------------------------------------------------------------------------------
	Dim rawX, rawY, xe, ye As Float
	
	rawX = CosD(raw)
	rawY = SinD(raw)

	xe = updateEstimate( rawX, kX )
	ye = updateEstimate( rawY, kY )

	Return arctan2D(ye, xe)
	
End Sub

Sub updateEstimate(measurement As Float, k As tKalman) As Float
	'--------------------------------------------------------------------------------------------------
	' Update the Kalman-Filter Estimate	
	'--------------------------------------------------------------------------------------------------

	k.kalman_gain = k.err_estimate/(k.err_estimate + k.err_measure)
	k.current_estimate = k.last_estimate + k.kalman_gain * (measurement - k.last_estimate)
	k.err_estimate =  (1.0 - k.kalman_gain)*k.err_estimate + Abs(k.last_estimate-k.current_estimate)*k.q
	k.last_estimate=k.current_estimate

	Return k.current_estimate
End Sub


Sub TrueToMagneticNorth(trueNorth As Float) As Float
	'--------------------------------------------------------------------------------------------------
	' Convert a direction from True North to Magnetic North
	'--------------------------------------------------------------------------------------------------
	Dim declination As Float
	If (Starter.sensorData.Get("DECL") > 990) Then
		declination = 0.0
	Else
		declination = Starter.sensorData.Get("DECL")
	End If
	Return ((trueNorth + declination + 360) Mod 360)
End Sub


Sub MagneticToTrueNorth(magneticNorth As Float) As Float
	'--------------------------------------------------------------------------------------------------
	' Convert a direction from Magnetic North to True North
	'--------------------------------------------------------------------------------------------------
	Dim declination As Float
	If (Starter.sensorData.Get("DECL") > 990) Then
		declination = 0.0
	Else
		declination = Starter.sensorData.Get("DECL")
	End If
	Return ((magneticNorth - declination + 360) Mod 360)
End Sub


Sub arctan2D(y As Float, x As Float) As Float
	'--------------------------------------------------------------------------------------------------
	' compute the ATAN2 in degrees ranging from 0-360 degrees and prevent division by zero
	'--------------------------------------------------------------------------------------------------
	Dim value As Float
	Dim sign As Int
	
	If x > 0.0 Then
		sign = 1
	Else
		sign = -1
	End If
	
	If Abs(x)<precission Then
		x = precission * sign
	End If
	
	If y > 0.0 Then
		sign = 1
	Else
		sign = -1
	End If
	
	If Abs(y)<precission Then
		y = precission * sign
	End If

	value = ATan2D(y, x)
	Return ( (value+360) Mod 360 )

End Sub


Sub getCompassDirection(mX As Float, mY As Float, mZ As Float, pitch As Float, roll As Float) As Float
	'--------------------------------------------------------------------------------------------------
	' Compute the Compass Direction from the raw magnetic values in the X-Y-Z cooredinate system after
	' compensating for tilt and applying the Hard- and Soft-Iron correction to the mX, mY, and mZ values
	'
	' Input Parameters:
	' mX from the eCompass sensor (North)
	' mY from the eCompass sensor (East)
	' mZ from the eCompass sensor (Down)
	' pitch = Theta θ (rotation around the device Y-axis - East) from the Anemometer Accelerometer
	' roll  = Phi Φ (rotation around the device X-axis - North) from the Anemometer Accelerometer
	'
	' Return Parameter:
	' float Compass Direction
	'--------------------------------------------------------------------------------------------------
	Dim ironX, ironY, ironZ, tiltX, tiltY, tiltZ, Ax, Ay, compass, maxHeel As Float
	Dim values As String
	
	maxHeel = 60.0
		
	' Tilt compensation as long as roll and pitch are less than "maxHeel" degrees
	Log("Pitch="&NumberFormat(pitch, 1, 2) & "   Roll="&NumberFormat(roll, 1, 2))
	If (Abs(pitch) < maxHeel And Abs(roll) < maxHeel) Then
		' YouTube Video formula - not working
		'tiltY = mX*SinD(pitch)*SinD(roll) + mY*CosD(roll) - mZ*SinD(roll)*CosD(pitch)
		'tiltX = mX*CosD(pitch) + mZ*SinD(pitch)
		
		' Implementing Tilt-Compensation as per Evernote - Eqn. 22
		'tiltX = ironX*CosD(pitch) + ironY*SinD(pitch)*SinD(roll) + ironZ*SinD(pitch)*CosD(roll)
		'tiltY = ironZ*SinD(roll) - ironY*CosD(roll)
		
		' Implementing Eqn 12 & 13 plus 18 & 19 from http://www.avcs-au.com/library/files/fusion/compassTiltCompensation.pdf
		' this article uses the same coordinate system but calls Roll = Theta θ and Pitch = Phi Φ (opposite from above)
		Ax = -SinD(pitch)
		Ay = SinD(roll)*CosD(pitch)
		tiltX = mX*(1.0-Ax*Ax) - mY*Ax*Ay - mZ*Ax*Sqrt(1.0-Ax*Ax-Ay*Ay)
		tiltY = mY*Sqrt(1.0-Ax*Ax-Ay*Ay) - mZ*Ay
		tiltZ = mZ
		Log("Tilt correction done")
	Else
		tiltX = mX
		tiltY = mY
		tiltZ = mZ
		Log("No Tilt correction performed!")
	End If

	' Hard- and Soft-Iron calibration - 2x3 calibration matrix (2x2 soft iron plus 1x2 hard iron components)
	ironX = (tiltX+Starter.calibrationMatrix(0,2))*Starter.calibrationMatrix(0,0)+(tiltY+Starter.calibrationMatrix(1,2))*Starter.calibrationMatrix(0,1)
	ironY = (tiltY+Starter.calibrationMatrix(1,2))*Starter.calibrationMatrix(1,1)+(tiltX +Starter.calibrationMatrix(0,2))*Starter.calibrationMatrix(1,0)
	ironZ = -(tiltZ - Starter.zHardIron)
	
	' compute the tilt and solf/hard iron corrected direction from the ironX and ironY values
	compass = (Starter.compassOffset + arctan2D(ironY, ironX)) Mod 360
	Log("Anemometer_compass_raw: x=" & NumberFormat(mX, 1, 4) & "  y=" & NumberFormat(mY, 1, 4) & "  z=" & NumberFormat(mZ, 1, 4))
	Log("Anem_Comp_Tilt_correct: x=" & NumberFormat(tiltX, 1, 4) & "  y=" & NumberFormat(tiltY, 1, 4) & "  z=" & NumberFormat(tiltZ, 1, 4))
	Log("Anem_Comp_Iron_correct: x=" & NumberFormat(ironX, 1, 4) & "  y=" & NumberFormat(ironY, 1, 4) & "  Dir=" & NumberFormat(compass, 3, 1))

' test code to write data to file
'	If Starter.compCalCtr = 0 Then
'		Starter.compCalValues.Initialize
'	End If
'	If Starter.compCalCtr < 150 Then
'		values = mX & "; " & mY & "; " & mZ & "; " & pitch & "; " & roll & "; "
'		values = values & NumberFormat(tiltX, 1, 5) & "; " & NumberFormat(tiltY, 1, 5) & "; " & NumberFormat(tiltZ, 1, 5) & "; "
'		values = values & NumberFormat(ironX, 1, 5) & "; " & NumberFormat(ironY, 1, 5) & "; " & NumberFormat(compass, 1, 1)
'		Starter.compCalValues.Add(values)
'		Starter.compCalCtr = Starter.compCalCtr + 1
'	End If
'	If Starter.compCalCtr = 150 Then
'		File.WriteList(File.DirDefaultExternal, "TiltCompensation.txt", Starter.compCalValues)
'		Log("Tilt Compensation data written to: " & File.DirDefaultExternal & "/" & "TiltCompensation.txt")
'		Starter.compCalCtr = Starter.compCalCtr + 100
'	End If
' end of test code

	Return compass
End Sub


Sub CompassCalibrationMatrix
	'--------------------------------------------------------------------------------------------------
	' The math is implemented in CompassCalibrationMath.xls and came from https://ez.analog.com/docs/DOC-2544
	'--------------------------------------------------------------------------------------------------

	Dim sumX=0.0, sumY=0.0, sumZ=0.0, minX=999.9, minY=999.0, minZ=999.0, maxX=-999.9, maxY=-999.9, maxZ=-999.9 As Float
	Dim x(Starter.compCalMax), y(Starter.compCalMax) As Float
	Dim B11(Starter.compCalMax), B12(Starter.compCalMax), B21(Starter.compCalMax), B22(Starter.compCalMax) As Float
	Dim sumB(2,2) As Float
	Dim trB, detB, eigenX, eigenY, scale, phaseX, phaseY, eigenVector(2, 2), R(2) As Float
	Dim compensationMatrix(2,3) As Float
	Dim i, j, sign1, sign2, sign3 As Int
	
	For i = 0 To 2
		compensationMatrix(0,i) = 0.0
		compensationMatrix(1,i) = 0.0		
	Next
		
	' Step 1: parse the string into mX, mY, and Mz and compute the Hard Iron compensation
	For i=0 To (Starter.compCalCtr - 1)

		sumX = sumX + Starter.mX(i)
		sumY = sumY + Starter.mY(i)
		sumZ = sumZ + Starter.mZ(i)

		If (Starter.mX(i) > maxX) Then
			maxX = Starter.mX(i)
		End If
		If (Starter.mY(i) > maxY) Then
			maxY = Starter.mY(i)
		End If
		If (Starter.mZ(i) > maxZ) Then
			maxZ = Starter.mZ(i)
		End If
		
		If (Starter.mX(i) < minX) Then
			minX = Starter.mX(i)
		End If
		If (Starter.mY(i) < minY) Then
			minY = Starter.mY(i)
		End If
		If (Starter.mZ(i) < minZ) Then
			minZ = Starter.mZ(i)
		End If
	Next
	
	' store the Hard Iron values in our Compansation Matrix
	compensationMatrix(0,2) = -(minX+maxX) / 2.0
	compensationMatrix(1,2) = -(minY+maxY) / 2.0
	Starter.zHardIron = -(minZ+maxZ) / 2.0
	
	' Step 2: remove the offset and compute the matrix B(2,2) and its Determinant det(B)
	For i = 0 To 1
		sumB(0,i) = 0.0
		sumB(1,i) = 0.0
	Next
	For i=0 To (Starter.compCalCtr - 1)
		x(i) = Starter.mX(i) + compensationMatrix(0,2)
		y(i) = Starter.mY(i) + compensationMatrix(1,2)
		B11(i) = x(i) * x(i)
		B12(i) = x(i) * y(i)
		B21(i) = B12(i)
		B22(i) = y(i) * y(i)
		sumB(0,0) = sumB(0,0) + B11(i)
		sumB(0,1) = sumB(0,1) + B12(i)
		sumB(1,0) = sumB(1,0) + B21(i)
		sumB(1,1) = sumB(1,1) + B22(i)
	Next
	
	trB = -(sumB(0,0) + sumB(1,1))
	detB = sumB(0,0)*sumB(1,1) - sumB(0,1)*sumB(1,0)
	
	' Step 3: compute the Eigen Vector
	If 4.0*detB > trB*trB Then
		eigenX = 0.0
		eigenY = 0.0
	Else
		eigenX = ( Sqrt(trB*trB-4.0*detB) -trB) / 2.0
		eigenY = ( -Sqrt(trB*trB-4.0*detB) -trB) / 2.0
	End If
	
	If (Abs(eigenY) < precission) Then
		 scale = 1.0 / precission
	Else
		scale = Sqrt(eigenX/eigenY)
	End If
	'Log("trB = " & NumberFormat(trB,1,5) & "  detB=" & NumberFormat(detB,1,5) & "  Scale = " & NumberFormat(scale, 1, 5) )
	
	eigenX = eigenX - sumB(0,0)
	'eigenY = eigenX - sumB(1,1)
	eigenY = eigenY - sumB(0,0)
	sumB(0,0) = 0.0
	sumB(1,1) = 0.0
	
	If Abs(eigenX) < precission Then
		eigenVector(0,0) = 1.0 / precission
	Else
		eigenVector(0,0) = sumB(0,1) / (eigenX)
	End If
	
	If Abs(eigenY) < precission Then
		eigenVector(1,0) = 1.0 / precission
	Else
		eigenVector(1,0) = sumB(0,1) / (eigenY)
	End If
	
	eigenVector(0,1) = 1.0
	eigenVector(1,1) = 1.0
	
	'Log("eigenVector X= " & NumberFormat(eigenVector(0,0),1,5) & "  eigenVector Y=" & NumberFormat(eigenVector(1,0),1,5)  )
	
	' Step 4: compute phaseX and phaseY
	If eigenX > 0.0 Then
		sign1 = 1
	Else
		sign1 = -1
	End If
	If sumB(0,1) > 0.0 Then
		sign2 = 1
	Else
		sign2 = -1
	End If
	If eigenY > 0.0 Then
		sign3 = 1
	Else
		sign3 = -1
	End If
	
	If sign1 = sign2 Then
		phaseX = arctan2D(eigenVector(0,1), eigenVector(0,0))
	Else
		phaseX = arctan2D(eigenVector(0,1), eigenVector(0,0)) - 180.0
	End If
	
	If sign3 = sign2 Then
		phaseY = arctan2D(eigenVector(1,1), eigenVector(1,0))
	Else
		phaseY = arctan2D(eigenVector(1,1), eigenVector(1,0)) - 180.0
	End If
	
	i = 0
	j = i+18
	If j > (Starter.compCalCtr - 1) Then
		j = (Starter.compCalCtr - 1)
	End If
	
	R(0) = Sqrt( (x(i)-x(j))*(x(i)-x(j)) + (y(i)-y(j))*(y(i)-y(j)) )

	i = 9
	j = i+18
	If j > (Starter.compCalCtr - 1) Then
		j = (Starter.compCalCtr - 1)
		i = 1
	End If
	
	R(1) = Sqrt( (x(i)-x(j))*(x(i)-x(j)) + (y(i)-y(j))*(y(i)-y(j)) )
		
	' Step 5: compute the Soft Iron Compensation Matrix
	If R(0) > R(1) Then
		compensationMatrix(0,0) = CosD(phaseX)
		compensationMatrix(0,1) = SinD(phaseX)
		compensationMatrix(1,0) = -SinD(phaseX)*scale
		compensationMatrix(1,1) = CosD(phaseX)*scale
		Log("Rx= " & NumberFormat(R(0),1,5) & "  Ry=" & NumberFormat(R(1),1,5) & "  final=" & NumberFormat(phaseX,1,5)  )
	Else
		compensationMatrix(0,0) = CosD(phaseY)*scale
		compensationMatrix(0,1) = SinD(phaseY)*scale
		compensationMatrix(1,0) = -SinD(phaseY)
		compensationMatrix(1,1) = CosD(phaseY)
		Log("Rx= " & NumberFormat(R(0),1,5) & "  Ry=" & NumberFormat(R(1),1,5) & "  final=" & NumberFormat(phaseY,1,5)  )
	End If

	' Save the Compenstaion Matrix in our Preferences
	Starter.prefManager.SetString("Matrix00", compensationMatrix(0,0))
	Starter.prefManager.SetString("Matrix01", compensationMatrix(0,1))
	Starter.prefManager.SetString("Matrix02", compensationMatrix(0,2))
	Starter.prefManager.SetString("Matrix10", compensationMatrix(1,0))
	Starter.prefManager.SetString("Matrix11", compensationMatrix(1,1))
	Starter.prefManager.SetString("Matrix12", compensationMatrix(1,2))
	Starter.prefManager.SetString("zHardIron", Starter.zHardIron)
	
	Starter.calibrationMatrix = compensationMatrix

	Log(" Hard Iron: x=" & NumberFormat(Starter.calibrationMatrix(0,2),1,5) & "  y=" & NumberFormat(Starter.calibrationMatrix(1,2),1,5))
	Log(" Hard Iron: z=" & NumberFormat(Starter.zHardIron,1,5))
	Log(" Soft Iron: (0,0)=" & NumberFormat(Starter.calibrationMatrix(0,0),1,5) & "  (0,1)=" & NumberFormat(Starter.calibrationMatrix(0,1),1,5))
	Log(" Soft Iron: (1,0)=" & NumberFormat(Starter.calibrationMatrix(1,0),1,5) & "  (1,1)=" & NumberFormat(Starter.calibrationMatrix(1,1),1,5 ))

End Sub


Sub LoadCalibrationData As Int
	'--------------------------------------------------------------------------------------------------
	' Load calibration data from a text file (for testing purposes only)
	'--------------------------------------------------------------------------------------------------
	Dim tmp As String
	Dim i As Int

	If (File.ExternalWritable=False) Then
		Msgbox2("Missing Storage Access Permission. Can not perform this test", "Storage Access Permission", "OK", "", "", Starter.appIcon)
		Return 0
	End If
	
	If File.Exists(File.DirDefaultExternal, Starter.calibrationDataFile) = False Then
		tmp = "Compass calibration data file '" & Starter.calibrationDataFile & "' not found at '" & File.DirDefaultExternal & "'. Can not compute calibration matrix."
		Msgbox2(tmp, "Calibration Error", "OK", "", "", Starter.appIcon)
		Return 0
	End If

	calibrationData.Initialize
	calibrationData = File.ReadList(File.DirDefaultExternal, Starter.calibrationDataFile)
	
	If calibrationData.Size = 0 Then
		Log("Error reading the calibration data file")
		Return 0
	Else
		Log("Read " & calibrationData.Size & " records from the calibration data file.")

		For i=0 To (calibrationData.Size-1)
			tmp = calibrationData.Get(i)
			Dim numbers() As String = Regex.Split("\, ", tmp)
			'Log("Regex Split = " & numbers(0) & " | " & numbers(1) & " | " & numbers(2))
			Starter.mX(i) = numbers(0)
			Starter.mY(i) = numbers(1)
			Starter.mZ(i) = numbers(2)
		Next
		
		Return calibrationData.Size
	End If
End Sub

Sub test
	'--------------------------------------------------------------------------------------------------
	' test dataset in Excel 'TWD_raw' / Sheet2 in VariousAppDevelopmentAssets in SailingRace
	'--------------------------------------------------------------------------------------------------
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

	data.Initialize
	data.AddAll(Array As Float(255, 250, 253, 256, 251, 243, 246, 251, 260, 250, 251, 243, 259, 248, 259, 241, 354, 251, 250, 255))
	
	lpf = data.Get(0)
	kalman = Kalman_Filter_Circular(data.Get(0))
	Log("======================================================")
	Log("apha = " & alpha & " sample rate = " & Starter.prefSampleRate)
	Log("Kal raw=" & data.Get(0) & " filter=" & kalman)
	alpha = 0.2
	For i=1 To data.Size-1
		lpf = Lowpass_Filter_Circular(data.Get(i), lpf)
		kalman = Kalman_Filter_Circular(data.Get(i))
		Log("raw=" & data.Get(i) & " Kal-filter=" & kalman & " LP-filter=" & lpf)
	Next

	
End Sub
