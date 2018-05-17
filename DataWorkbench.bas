Attribute VB_Name = "Macros"

Public Function TEXTJOIN(delimiter As String, ignore_empty As Boolean, rng As Range) As String
    Dim compiled As String
    For Each cell In rng
        If ignore_empty And (IsEmpty(cell.Value) Or (Len(cell.Value) = 0)) Then
            'nothing
        Else
            compiled = compiled + IIf(compiled = "", "", delimiter) + CStr(cell.Value)
        End If
    Next
    TEXTJOIN = compiled
End Function

Public Function TEXTJOINARRAY(delimiter As String, ignore_empty As Boolean, rng As Variant) As String
    Dim compiled As String
    Dim L1 As Long: L1 = LBound(rng, 1)
    Dim U1 As Long: U1 = UBound(rng, 1)
    Dim row, col As Long
    Dim Value As String
    For row = L1 To U1
        Value = CStr(rng(row))
        If ignore_empty And Len(Value) = 0 Then
            'nothing
        Else
            compiled = compiled + IIf(compiled = "", "", delimiter) + Value
        End If
    Next
    TEXTJOINARRAY = compiled
End Function

' =OFFSET(DatasetLinks,0,0,,MATCH("Dataset "&R55C,OFFSET(DatasetLinks,0,0,1),0))
Public Function FINDLINKS(LinksTable As Range, Offset As Integer, Filter As String, Table As Range, Index As Integer) As Variant
    FINDLINKS = Empty
    On Error GoTo Catch
    Dim Result() As Variant
    Dim Length As Integer
    Length = 0
    Dim LinksArray
    If IsArray(LinksTable.Value2) Then ' Is it a sLinksgle cell or an array of cells
        LinksArray = LinksTable.Value2
        Dim L1 As Long: L1 = LBound(LinksArray, 1)
        Dim U1 As Long: U1 = UBound(LinksArray, 1)
        Dim L2 As Long: L2 = LBound(LinksArray, 2)
        Dim U2 As Long: U2 = UBound(LinksArray, 2)
        Dim row, col As Long
        Dim Value As String
'        For row = L1 To U1
'            For col = L2 To U2
'                Value = CStr(LinksArray(row, col))
'                If InStr(1, Value, Filter, vbTextCompare) Then
'                    ReDim Preserve Result(Length)
'                    Value = Right(Value, Len(Value) - Len(Filter))
'                    Result(UBound(Result)) = WorksheetFunction.HLookup(Value, Table, Index, False)
'                    Length = Length + 1
'                End If
'            Next
'        Next
        For row = L1 To U1
            Value = CStr(LinksArray(row, Offset))
            If InStr(1, Value, Filter, vbTextCompare) Then
                ReDim Preserve Result(Length)
                Value = Right(Value, Len(Value) - Len(Filter))
                Result(UBound(Result)) = WorksheetFunction.HLookup(Value, Table, Index, False)
                Length = Length + 1
            End If
        Next
    End If
    FINDLINKS = Result
Exit Function
Catch:
    On Error GoTo 0
End Function

Public Sub CreateHLookupRange(Name As String, StartRow As Integer, Optional Height As Integer = 1)
    Dim Item As Range
    Set Item = Range(ActiveSheet.Cells(StartRow, 3), ActiveSheet.Cells(StartRow, Columns.Count).End(xlToLeft).Offset(Height, 1))
    ThisWorkbook.Names.Add Name:=Name, RefersTo:=Item
End Sub

Public Sub CreateHLookupRanges()
    Call CreateHLookupRange("ExperimentalMethodLookup", 37, 0)
    Call CreateHLookupRange("ActivityMethodLookup", 43, 0)
    Call CreateHLookupRange("DatasetLookup", 55)
    Call CreateHLookupRange("FileLookup", 65, 4)
    Call CreateHLookupRange("SubjectLookup", 71)
    Call CreateHLookupRange("BrainStructureLookup", 89)
End Sub

Sub CopyDataWorkbenchWorksheet(SourceWorkbookName As String)
    Dim SourceWorkbook As Workbook
    Set SourceWorkbook = Application.Workbooks(SourceWorkbookName)
    Dim SourceWorksheet As Worksheet
    Set SourceWorksheet = SourceWorkbook.Sheets("DataWorkbench")
    SourceWorksheet.Copy After:=ThisWorkbook.Sheets(1)
    ThisWorkbook.Sheets("DataWorkbench").Cells.Replace What:="'" & SourceWorkbook.Path & "\[" & SourceWorkbook.Name & "]MINDS'", Replacement:="MINDS", LookAt:=xlPart, SearchOrder:=xlByRows, MatchCase:=False, SearchFormat:=False, ReplaceFormat:=False
    ThisWorkbook.Sheets("DataWorkbench").Cells.Replace What:="[" & SourceWorkbook.Name & "]MINDS", Replacement:="MINDS", LookAt:=xlPart, SearchOrder:=xlByRows, MatchCase:=False, SearchFormat:=False, ReplaceFormat:=False
End Sub

Public Sub InsertDataWorkbenchSheet()
    Call CopyDataWorkbenchWorksheet("Infant-template-MINDS_20180508_hack02.xlsm")
End Sub

Sub SelectNameValueRange(Count As Integer, StartRow As Integer, Height As Integer)
    Dim ItemNames As Range
    Dim ItemValues As Range
    Set ItemNames = Range(ActiveSheet.Cells(StartRow, 1), ActiveSheet.Cells(StartRow + Height, 1))
    Set ItemValues = Range(ActiveSheet.Cells(StartRow, (2 * Count) + 1), ActiveSheet.Cells(StartRow + Height, (2 * Count) + 2))
    Union(ItemNames, ItemValues).Select
End Sub

Sub TestSelectNameValueRange()
    Dim i As Integer
    i = 1
    Call SelectNameValueRange(i, 41, 17)
End Sub

Public Sub ExtractRodent()
    ThisWorkbook.Sheets("DataWorkbench").Activate
    Dim ComponentID As Integer
    ComponentID = ThisWorkbook.Sheets("DataWorkbench").Names("ComponentID").RefersToRange.Value
    Dim FileSystem As Object
    Set FileSystem = CreateObject("Scripting.FileSystemObject")
    Dim File As Object
    Set File = FileSystem.CreateTextFile(ThisWorkbook.Path & "\ProcessAll.bat", True, False) ' ASCII for .bat file
    'File.Write("@echo off" & vbCRLF)
    File.Write ("echo %1" & vbCRLF)
    Dim Count As Integer
    Dim i As Integer
    ' Activities
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("ActivityCount").RefersToRange.Value
    i = 1
    Call SelectNameValueRange(i, 3, 6)
    File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ Activity null " & CStr(ComponentID) & vbCRLF)
    Application.Run ("GenerateActivityFile") ' Assume just one for now
    ' Datasets
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("DatasetCount").RefersToRange.Value
    i = 1
    Call SelectNameValueRange(i, 12, 17)
    File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ Dataset null " & CStr(ComponentID) & vbCRLF)
    Application.Run ("GenerateDatasetFile") ' Assume just one for now
    ' SpecimenGroups
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("SpecimenGroupCount").RefersToRange.Value
    i = 1
    Call SelectNameValueRange(i, 32, 1)
    Dim SpecimenGroup As String
    SpecimenGroup = Selection.Areas(2).Cells(1, 1).Value
    File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & SpecimenGroup & """ SpecimenGroup Rodent " & CStr(ComponentID) & vbCRLF)
    Application.Run ("GenerateSubjectFile") ' Assume just one for now
    File.Write ("if ""%1"" == ""Transform.bat"" (" & vbCRLF)
    ' Subjects
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("SubjectCount").RefersToRange.Value
    i = 1
    While Not i > Count
        Call SelectNameValueRange(i, 35, 7)
        File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ SpecimenGroup Rodent " & CStr(ComponentID) & vbCRLF)
        Application.Run ("GenerateSubjectFile")
        i = i + 1
    Wend
    ' Samples
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("SampleCount").RefersToRange.Value
    i = 1
    While Not i > Count
        Call SelectNameValueRange(i, 45, 4)
        File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ SpecimenGroup Rodent " & CStr(ComponentID) & vbCRLF)
        Application.Run ("GenerateSubjectFile")
        i = i + 1
    Wend
    File.Write ("%SystemRoot%\SysWOW64\cscript //nologo Scripts.wsf //job:BuildSpecimenGroup """ & ThisWorkbook.Path & "\DataWorkbench\" & SpecimenGroup & ".json""" & vbCRLF)
    File.Write (")" & vbCRLF)
    File.Close
End Sub

Public Sub ExtractHuman()
    ThisWorkbook.Sheets("DataWorkbench").Activate
    Dim ComponentID As Integer
    ComponentID = ThisWorkbook.Sheets("DataWorkbench").Names("ComponentID").RefersToRange.Value
    Dim FileSystem As Object
    Set FileSystem = CreateObject("Scripting.FileSystemObject")
    Dim File As Object
    Set File = FileSystem.CreateTextFile(ThisWorkbook.Path & "\ProcessAll.bat", True, False) ' ASCII for .bat file
    'File.Write("@echo off" & vbCRLF)
    File.Write ("echo %1" & vbCRLF)
    Dim Count As Integer
    Dim i As Integer
    ' SpecimenGroups
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("SpecimenGroupCount").RefersToRange.Value
    i = 1
    While Not i > Count
        Call SelectNameValueRange(i, 4, 16)
        File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ SpecimenGroup Human " & CStr(ComponentID) & vbCRLF)
        Application.Run ("GenerateSubjectFile")
        i = i + 1
    Wend
    ' Activities - E
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("ActivityCountE").RefersToRange.Value
    i = 1
    While Not i > Count
        Call SelectNameValueRange(i, 23, 6)
        File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ Activity null " & CStr(ComponentID) & vbCRLF)
        Application.Run ("GenerateActivityFile") ' Assume just one for now
        i = i + 1
    Wend
    ' Activities - A
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("ActivityCountA").RefersToRange.Value
    i = 1
    While Not i > Count
        Call SelectNameValueRange(i, 32, 6)
        File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ Activity null " & CStr(ComponentID) & vbCRLF)
        Application.Run ("GenerateActivityFile") ' Assume just one for now
        i = i + 1
    Wend
    ' Datasets
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("DatasetCount").RefersToRange.Value
    i = 1
    While Not i > Count
        Call SelectNameValueRange(i, 41, 17)
        File.Write ("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ Dataset null " & CStr(ComponentID) & vbCRLF)
        Application.Run ("GenerateDatasetFile") ' Assume just one for now
        i = i + 1
    Wend
'    File.Write ("if ""%1"" == ""Transform.bat"" (" & vbCRLF)
'    File.Write ("%SystemRoot%\SysWOW64\cscript //nologo Scripts.wsf //job:BuildSpecimenGroup """ & ThisWorkbook.Path & "\DataWorkbench\" & SpecimenGroup & ".json""" & vbCRLF)
'    File.Write (")" & vbCRLF)
    File.Close
End Sub

