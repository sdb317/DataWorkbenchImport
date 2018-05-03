Attribute VB_Name = "Macros"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True

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
    Call CopyDataWorkbenchWorksheet("DataWorkbench.xlsm")
End Sub

Sub SelectNameValueRange(Count As Integer, StartRow As Integer, Height As Integer)
    Dim ItemNames As Range
    Dim ItemValues As Range
    Set ItemNames = Range(ActiveSheet.Cells(StartRow, 1), ActiveSheet.Cells(StartRow + Height, 1))
    Set ItemValues = Range(ActiveSheet.Cells(StartRow, (2 * Count) + 1), ActiveSheet.Cells(StartRow + Height, (2 * Count) + 2))
    Union(ItemNames, ItemValues).Select
End Sub

Public Sub Extract()
    Dim ComponentID As Integer
    ComponentID = ThisWorkbook.Sheets("DataWorkbench").Names("ComponentID").RefersToRange.Value
    Dim FileSystem As Object
    Set FileSystem = CreateObject("Scripting.FileSystemObject")
    Dim File As Object
    Set File = FileSystem.CreateTextFile(ThisWorkbook.Path & "\ProcessAll.bat", True, False) ' ASCII for .bat file
    Dim Count As Integer
    Dim i As Integer
    ' Activities
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("ActivityCount").RefersToRange.Value
    i = 1
    Call SelectNameValueRange(i, 3, 6)
    File.Write("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ Activity null " & CStr(ComponentID) & vbCRLF)
    Application.Run("GenerateActivityFile") ' Assume just one for now
    ' Datasets
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("DatasetCount").RefersToRange.Value
    i = 1
    Call SelectNameValueRange(i, 12, 17)
    File.Write("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ Dataset null " & CStr(ComponentID) & vbCRLF)
    Application.Run("GenerateDatasetFile") ' Assume just one for now
    ' SpecimenGroups
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("SpecimenGroupCount").RefersToRange.Value
    i = 1
    Call SelectNameValueRange(i, 32, 1)
    Dim SpecimenGroup As String
    SpecimenGroup = Selection.Areas(2).Cells(1, 1).Value
    File.Write("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & SpecimenGroup & """ SpecimenGroup Rodent " & CStr(ComponentID) & vbCRLF)
    Application.Run("GenerateSubjectFile") ' Assume just one for now
    ' Subjects
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("SubjectCount").RefersToRange.Value
    i = 1
    While Not i > Count
        Call SelectNameValueRange(i, 35, 7)
        File.Write("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ SpecimenGroup Rodent " & CStr(ComponentID) & vbCRLF)
        Application.Run("GenerateSubjectFile")
        i = i + 1
    Wend
    ' Samples
    Count = ThisWorkbook.Sheets("DataWorkbench").Names("SampleCount").RefersToRange.Value
    i = 1
    While Not i > Count
        Call SelectNameValueRange(i, 45, 4)
        File.Write("call %1 """ & ThisWorkbook.Path & "\DataWorkbench\" & Selection.Areas(2).Cells(1, 1).Value & """ SpecimenGroup Rodent " & CStr(ComponentID) & vbCRLF)
        Application.Run("GenerateSubjectFile")
        i = i + 1
    Wend
    File.Write("%SystemRoot%\SysWOW64\cscript //nologo Scripts.wsf //job:BuildSpecimenGroup """ & ThisWorkbook.Path & "\DataWorkbench\" & SpecimenGroup & ".json""" & vbCRLF)
    File.Close
End Sub

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

