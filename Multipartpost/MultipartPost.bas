Type=StaticCode
Version=5.18
ModulesStructureVersion=1
B4A=true
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	Type FileData (Dir As String, FileName As String, KeyName As String, ContentType As String)
End Sub

Sub CreatePostRequest(URL As String, NameValues As Map, Files As List) As OkHttpRequest
	Dim boundary As String
	boundary = "---------------------------1461124740692"
	Dim stream As OutputStream
	stream.InitializeToBytesArray(20)
	Dim EOL As String
	EOL = Chr(13) & Chr(10) 'CRLF constant matches Android end of line character which is chr(10).
	Dim b() As Byte
	If NameValues <> Null And NameValues.IsInitialized Then
		'Write the name/value pairs
		Dim key, value As String
		For i = 0 To NameValues.Size - 1
			key = NameValues.GetKeyAt(i)
			value = NameValues.GetValueAt(i)
			b = ("--" & boundary & EOL & "Content-Disposition: form-data; name=" _ 
				& QUOTE & key & QUOTE & EOL & EOL & value & EOL).GetBytes("UTF8")
			stream.WriteBytes(b, 0, b.Length)
		Next
	End If
	If Files <> Null And Files.IsInitialized Then
		'write the files
		Dim FD As FileData
		For i = 0 To Files.Size - 1
			FD = Files.Get(i)
			b = ("--" & boundary & EOL & "Content-Disposition: form-data; name=" _ 
				& QUOTE & FD.KeyName & QUOTE & "; filename=" & QUOTE & FD.FileName & QUOTE _
				& EOL & "Content-Type: "  & FD.ContentType & EOL & EOL).GetBytes("UTF8")
			stream.WriteBytes(b, 0, b.Length)
			Dim In As InputStream
			In = File.OpenInput(FD.Dir, FD.FileName)
			File.Copy2(In, stream) 'read the file and write it to the stream
			b = EOL.GetBytes("UTF8")
			stream.WriteBytes(b, 0, b.Length)
		Next
	End If
	b = (EOL & "--" & boundary & "--" & EOL).GetBytes("UTF8")
	stream.WriteBytes(b, 0, b.Length)
	b = stream.ToBytesArray
	'msgbox(b.Length, "")
	Dim request As okHttpRequest
	request.InitializePost2(URL, b)
	request.SetContentType("multipart/form-data; boundary=" & boundary)
	request.SetContentEncoding("UTF8")
	Return request
End Sub