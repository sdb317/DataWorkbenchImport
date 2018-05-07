Attribute VB_Name = "Utilities"
Enum FormatType
  JSON
  XML
End Enum

Const OutputFormatType = FormatType.XML

'Public Function ParseSubjectAsJSON()
'    Dim JSON As String
'    JSON = ParseSelection()
'    JSON = "{""name"": ""Subject"", ""value"": """", ""children"": [" & JSON & "]}"
'    Debug.Print JSON
'    ParseSubjectAsJSON = JSON
'End Function

'Public Function ParseSubjectAsXML()
'    Dim XML As String
'    XML = ParseSelection()
'    XML = "<item><name>Subject</name><value></value><children>" & XML & "</children></item>"
'    Debug.Print XML
'    ParseSubjectAsXML = XML
'End Function

Public Function ParseAsJSON(ItemType As String)
    Dim JSON As String
    JSON = ParseSelection()
    JSON = "{""name"": """ & ItemType & """, ""value"": """", ""children"": [" & JSON & "]}"
    Debug.Print JSON
    ParseAsJSON = JSON
End Function

Public Function ParseAsXML(ItemType As String)
    Dim XML As String
    XML = ParseSelection()
    XML = "<?xml version='1.0' encoding='utf-8'?><item><name>" & ItemType & "</name><value></value><children>" & XML & "</children></item>"
    Debug.Print XML
    ParseAsXML = XML
End Function

Public Function ParseSelection() As String
    Dim Results As String
    Results = ""
    Dim TargetArray As Variant
    TargetArray = GetSelectionAsContiguousRange()
    Dim i As Integer
    For i = LBound(TargetArray, 1) To UBound(TargetArray, 1)
        Results = Results + NameValue(TargetArray, i)
    Next i
'    Debug.Print Results
    ParseSelection = Results
End Function

Public Function NameValue(TargetArray As Variant, Row As Integer) As String
    Dim ItemName As String
    ItemName = ""
    Dim ItemValue As String
    ItemValue = ""
    Dim j As Integer
    j = LBound(TargetArray, 2)
    ItemName = TargetArray(Row, j)
    For j = (LBound(TargetArray, 2) + 1) To UBound(TargetArray, 2)
        If Not IsEmpty(TargetArray(Row, j)) Then
            ItemValue = ItemValue + CStr(TargetArray(Row, j))
        End If
    Next j
    Dim ItemNameValue As String
    ItemNameValue = FormatNameValue(ItemName, ItemValue)
'    Debug.Print ItemNameValue
    NameValue = ItemNameValue
End Function

Public Function FormatNameValue(ItemName As String, ItemValue As String) As String
    Select Case OutputFormatType
        Case FormatType.JSON
            FormatNameValue = FormatNameValueJSON(ItemName, ItemValue)
        Case FormatType.XML
            FormatNameValue = FormatNameValueXML(ItemName, ItemValue)
    End Select
End Function

Public Function FormatNameValueJSON(ItemName As String, ItemValue As String) As String
    Dim ItemNameValue As String
'    ItemNameValue = """" & ItemName & """: """ & ItemValue & """"
    ItemNameValue = "{""name"": """ & ItemName & """, ""value"": """ & ItemValue & """},"
'    Debug.Print ItemNameValue
    FormatNameValueJSON = ItemNameValue
End Function

Public Function FormatNameValueXML(ItemName As String, ItemValue As String) As String
    Dim ItemNameValue As String
    ItemNameValue = "<item><name>" & ItemName & "</name><value>" & ItemValue & "</value></item>"
'    Debug.Print ItemNameValue
    FormatNameValueXML = ItemNameValue
End Function

Public Function GetSelectionAsContiguousRange() As Variant
    Dim TargetArray As Variant
    TargetArray = Selection.Areas(1)
    If Selection.Areas.Count > 1 Then
        Dim i As Integer
        For i = 2 To Selection.Areas.Count
            ReDim Preserve TargetArray(LBound(TargetArray, 1) To UBound(TargetArray, 1), LBound(TargetArray, 2) To UBound(TargetArray, 2) + Selection.Areas(i).Columns.Count)
            Dim j As Integer
            For j = 1 To Selection.Areas(i).Rows.Count
                Dim l As Integer
                l = (UBound(TargetArray, 2) - LBound(TargetArray, 2)) - (Selection.Areas(i).Columns.Count - 1)
                Dim k As Integer
                For k = 1 To Selection.Areas(i).Columns.Count
                    TargetArray(j, l + k) = Selection.Areas(i).Cells(j, k).Value
                Next k
            Next j
        Next i
    End If
    GetSelectionAsContiguousRange = TargetArray
End Function

Public Function GetFilePath(FileName As String) As String
    Dim FileSystem As Object
    Set FileSystem = CreateObject("Scripting.FileSystemObject")
    Select Case OutputFormatType
        Case FormatType.JSON
            GetFilePath = FileSystem.BuildPath(ActiveSheet.Parent.Path & "\" & RTrim(ActiveSheet.Name), FileName & ".json")
        Case FormatType.XML
            GetFilePath = FileSystem.BuildPath(ActiveSheet.Parent.Path & "\" & RTrim(ActiveSheet.Name), FileName & ".xml")
    End Select
End Function

Function FormatXML(ByVal Source, Optional ByVal EmitXMLDeclaration As Boolean) As String
    Dim Writer As Object
    Set Writer = CreateObject("Msxml2.MXXMLWriter.6.0")
    Writer.indent = True
    Writer.Encoding = "utf-8"
    Writer.omitXMLDeclaration = EmitXMLDeclaration
    Dim Reader As Object
    Set Reader = CreateObject("Msxml2.SAXXMLReader.6.0")
    Set Reader.contentHandler = Writer
    Reader.Parse Source
    FormatXML = "<?xml version=""1.0"" encoding=""utf-8"" standalone=""no""?>" & vbNewLine & Writer.Output
End Function

Public Sub GenerateFile(ItemType As String)
    Dim FileName As String
'    FileName = GetFilePath(Application.InputBox("Enter file name"))
    FileName = GetFilePath(Selection.Areas(2).Cells(1, 1).Value)
    Dim Results As String
'    Results = ParseAsJSON(ItemType)
    Results = FormatXML(ParseAsXML(ItemType), True)
    Dim Stream As Object
    Set Stream = CreateObject("ADODB.Stream")
    Stream.Open
    Stream.Charset = "UTF-8"
    Stream.WriteText Results
    Stream.SaveToFile FileName, 2
    Stream.Close
End Sub

Public Sub GenerateSubjectFile()
    Call GenerateFile("Subject")
'    Call Shell("cmd /k C:\Users\sbell\Dev\Projects\DataWorkbench\_testing\Import\Upload.bat " & ActiveSheet.Parent.Path & "\" & RTrim(ActiveSheet.Name) & "\" & Selection.Areas(2).Cells(1, 1).Value & " SpecimenGroup Human", vbNormalNoFocus)
End Sub

Public Sub GenerateActivityFile()
    Call GenerateFile("Activity")
End Sub

Public Sub GenerateDatasetFile()
    Call GenerateFile("Dataset")
End Sub

