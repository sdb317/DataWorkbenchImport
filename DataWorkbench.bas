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

Public Sub ExportXML()
    Dim i As Integer
    i = 1
    Call SelectNameValueRange(i, 3, 6)
    Application.Run("GenerateActivityFile")
    i = 1
    Call SelectNameValueRange(i, 12, 17)
    Application.Run("GenerateDatasetFile")
    i = 1
    Call SelectNameValueRange(i, 32, 1)
    Application.Run("GenerateSubjectFile")
    i = 1
    While i < 3
        Call SelectNameValueRange(i, 35, 7)
        Application.Run("GenerateSubjectFile")
        i = i + 1
    Wend
    i = 1
    While i < 8
        Call SelectNameValueRange(i, 45, 4)
        Application.Run("GenerateSubjectFile")
        i = i + 1
    Wend
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

