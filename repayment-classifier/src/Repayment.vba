Attribute VB_Name = "Repayment"
Option Explicit

' 변제금상환내역조회 엑셀을 새출발기금 / 일반 두 파일로 나누고
' 신용회복위원회 분담수수료(기본 3.88%, 원 미만 버림)를 계산한다.
' 인터넷, 외부 프로그램, AI를 쓰지 않는다.
' 고객 정보는 이 파일에 저장하지 않고 구분별 합계와 건수만 남긴다.

Private Const CALC_SHEET As String = "수수료계산"
Private Const GUIDE_SHEET As String = "사용법"
Private Const NEW_KEY As String = "새출발"
Private Const DEFAULT_RATE As Double = 0.0388
Private Const AMT_FMT As String = "#,##0;-#,##0;""-"""

' 수수료계산 시트의 행
Private Const R_HDR As Long = 5
Private Const R_MID As Long = 6     ' 중도완제 (수기 입력)
Private Const R_NEW As Long = 7     ' 새출발
Private Const R_GEN As Long = 8     ' 일반
Private Const R_TOT As Long = 9     ' 총계
Private Const R_FILE_NEW As Long = 12
Private Const R_FILE_GEN As Long = 13
Private Const R_NOTE As Long = 14

' 수수료계산 시트의 열
Private Const C_KIND As Long = 1    ' 구분
Private Const C_RATE As Long = 2    ' 수수료율
Private Const C_FEE As Long = 3     ' 수수료
Private Const C_NET As Long = 4     ' 차감입금액 (법인계좌 입금 예정액)
Private Const C_AMT As Long = 5     ' 원금(합계)
Private Const C_ERP As Long = 6     ' sERP금액
Private Const C_DIFF As Long = 7    ' 차이금액
Private Const C_BANK As Long = 8    ' 통장입금액
Private Const C_BDIFF As Long = 9   ' 입금차이
Private Const C_CNT As Long = 10    ' 건수

' ProcessFile 결과
Private mYmd As String
Private mCntNew As Long
Private mCntGen As Long
Private mSumNew As Double
Private mSumGen As Double
Private mPathNew As String
Private mPathGen As String
Private mKinds As String
Private mWarn As String


' ===== 버튼: 파일 불러오기 =====
Public Sub LoadAndSplit()
    Dim ws As Worksheet, f As Variant, msg As String

    Set ws = CalcSheet()
    If ws Is Nothing Then Exit Sub

    If Len(CStr(ws.Cells(R_NEW, C_AMT).Value)) > 0 Or Len(CStr(ws.Cells(R_GEN, C_AMT).Value)) > 0 Then
        If MsgBox("이전 작업 결과가 남아 있습니다." & vbLf & "지우고 새로 불러올까요?", _
                  vbYesNo + vbQuestion, "확인") <> vbYes Then Exit Sub
    End If

    f = Application.GetOpenFilename("엑셀 파일 (*.xlsx;*.xls),*.xlsx;*.xls", , "변제금상환내역조회 원본 파일 선택")
    If VarType(f) = vbBoolean Then Exit Sub

    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    msg = ProcessFile(CStr(f), False)
    If msg = "EXISTS" Then
        Application.ScreenUpdating = True
        If MsgBox("같은 날짜의 결과 파일이 이미 있습니다." & vbLf & vbLf & _
                  JoinPaths() & vbLf & vbLf & "덮어쓸까요?", vbYesNo + vbExclamation, "확인") <> vbYes Then
            Application.DisplayAlerts = True
            Exit Sub
        End If
        Application.ScreenUpdating = False
        msg = ProcessFile(CStr(f), True)
    End If
    Application.DisplayAlerts = True
    Application.ScreenUpdating = True

    If msg <> "" Then
        MsgBox msg, vbCritical, "처리 중단"
        Exit Sub
    End If

    WriteResults ws, CStr(f)
    ws.Activate
    MsgBox SummaryText(ws), vbInformation, "분류 완료"
End Sub


' ===== 버튼: 초기화 =====
Public Sub ResetAll()
    Dim ws As Worksheet
    Set ws = CalcSheet()
    If ws Is Nothing Then Exit Sub
    If MsgBox("오늘 입력한 숫자와 결과를 모두 지울까요?" & vbLf & "(만들어진 엑셀 파일은 지우지 않습니다)", _
              vbYesNo + vbQuestion, "초기화") <> vbYes Then Exit Sub
    ws.Unprotect
    ClearCells ws, True
    ws.Protect
End Sub


' ===== 버튼: 인쇄 =====
Public Sub PrintCalc()
    Dim ws As Worksheet
    Set ws = CalcSheet()
    If ws Is Nothing Then Exit Sub
    ws.PrintPreview
End Sub


' 원본 파일을 읽어 분류하고 결과 파일을 만든다.
' 성공하면 "", 실패하면 이유를 돌려준다.
' 결과 파일이 이미 있고 overwrite = False 이면 "EXISTS" 를 돌려준다.
Public Function ProcessFile(ByVal srcPath As String, ByVal overwrite As Boolean) As String
    Dim src As Workbook, sh As Worksheet
    Dim shIdx As Long, hdrRow As Long, lastRow As Long, lastCol As Long
    Dim cNo As Long, cType As Long, cDate As Long, cPrin As Long, cInt As Long, cEtc As Long, cSum As Long
    Dim r As Long, n As Long, k As Long, ok As Boolean, v As Double, tot As Double
    Dim rowNums() As Long, isNew() As Boolean
    Dim kindNames() As String, kindCnt() As Long, kindIsNew() As Boolean, kindN As Long
    Dim kind As String, d As String, ymd As String, otherDates As String, mismatch As String
    Dim baseName As String, folder As String, ext As String, res As String

    mYmd = "": mCntNew = 0: mCntGen = 0: mSumNew = 0: mSumGen = 0
    mPathNew = "": mPathGen = "": mKinds = "": mWarn = ""

    baseName = Mid$(srcPath, LastSep(srcPath) + 1)
    If Left$(baseName, 4) = "새출발_" Or Left$(baseName, 3) = "일반_" Then
        ProcessFile = "이 프로그램이 만든 결과 파일입니다." & vbLf & "신용회복위원회에서 받은 원본 파일을 고르세요."
        Exit Function
    End If

    On Error GoTo openFail
    Set src = Workbooks.Open(Filename:=srcPath, UpdateLinks:=0, ReadOnly:=True, AddToMru:=False)
    On Error GoTo fail

    For shIdx = 1 To src.Worksheets.Count
        Set sh = src.Worksheets(shIdx)
        hdrRow = FindHeaderRow(sh, cType)
        If hdrRow > 0 Then Exit For
    Next
    If hdrRow = 0 Then
        src.Close SaveChanges:=False
        ProcessFile = "'지원구분' 제목칸을 찾지 못했습니다." & vbLf & "변제금상환내역조회 원본 파일이 맞는지 확인하세요."
        Exit Function
    End If

    lastRow = sh.UsedRange.Row + sh.UsedRange.Rows.Count - 1
    lastCol = sh.UsedRange.Column + sh.UsedRange.Columns.Count - 1
    If lastCol < cType Then lastCol = cType

    cSum = FindCol(sh, hdrRow, lastCol, "합계")
    cNo = FindCol(sh, hdrRow, lastCol, "NO.")
    If cNo = 0 Then cNo = FindCol(sh, hdrRow, lastCol, "NO")
    cDate = FindCol(sh, hdrRow, lastCol, "처리일자")
    cPrin = FindCol(sh, hdrRow, lastCol, "원금")
    cInt = FindCol(sh, hdrRow, lastCol, "이자")
    cEtc = FindCol(sh, hdrRow, lastCol, "기타채무")
    If cSum = 0 Then
        src.Close SaveChanges:=False
        ProcessFile = "'합계' 제목칸을 찾지 못했습니다." & vbLf & "변제금상환내역조회 원본 파일이 맞는지 확인하세요."
        Exit Function
    End If

    ' 지원구분이 있고 합계가 숫자인 행만 상환 내역으로 본다
    For r = hdrRow + 1 To lastRow
        kind = CellText(sh.Cells(r, cType))
        v = ToNum(sh.Cells(r, cSum).Value, ok)
        If kind <> "" And ok Then
            n = n + 1
            ReDim Preserve rowNums(1 To n)
            ReDim Preserve isNew(1 To n)
            rowNums(n) = r
            isNew(n) = (InStr(kind, NEW_KEY) > 0)
            If isNew(n) Then
                mCntNew = mCntNew + 1
                mSumNew = mSumNew + v
            Else
                mCntGen = mCntGen + 1
                mSumGen = mSumGen + v
            End If

            For k = 1 To kindN
                If kindNames(k) = kind Then Exit For
            Next
            If k > kindN Then
                kindN = kindN + 1
                ReDim Preserve kindNames(1 To kindN)
                ReDim Preserve kindCnt(1 To kindN)
                ReDim Preserve kindIsNew(1 To kindN)
                kindNames(kindN) = kind
                kindIsNew(kindN) = isNew(n)
            End If
            kindCnt(k) = kindCnt(k) + 1

            If cPrin > 0 And cInt > 0 And cEtc > 0 Then
                tot = ToNum(sh.Cells(r, cPrin).Value, ok) + ToNum(sh.Cells(r, cInt).Value, ok) _
                    + ToNum(sh.Cells(r, cEtc).Value, ok)
                If Abs(tot - v) > 0.5 Then mismatch = mismatch & " " & r & "행"
            End If

            If cDate > 0 Then
                d = DateKey(sh.Cells(r, cDate).Value)
                If ymd = "" Then
                    ymd = d
                ElseIf d <> "" And d <> ymd And InStr(otherDates, d) = 0 Then
                    otherDates = otherDates & " " & d
                End If
            End If
        End If
    Next

    src.Close SaveChanges:=False
    Set src = Nothing

    If n = 0 Then
        ProcessFile = "상환 내역이 한 건도 없습니다." & vbLf & "다운받은 파일이 맞는지 확인하세요."
        Exit Function
    End If

    If ymd = "" Then ymd = Format(Date, "yyyymmdd")
    mYmd = ymd

    For k = 1 To kindN
        mKinds = mKinds & "  " & IIf(kindIsNew(k), "[새출발] ", "[일반] ") & kindNames(k) & " : " & kindCnt(k) & "건" & vbLf
    Next
    If mismatch <> "" Then mWarn = mWarn & "원금+이자+기타채무가 합계와 다른 행(원본 기준):" & mismatch & vbLf
    If otherDates <> "" Then mWarn = mWarn & "처리일자가 여러 날 섞여 있습니다:" & otherDates & " (파일 이름은 " & ymd & " 기준)" & vbLf

    folder = Left$(srcPath, LastSep(srcPath))
    If InStrRev(baseName, ".") > 0 Then ext = Mid$(baseName, InStrRev(baseName, ".")) Else ext = ".xlsx"
    If mCntNew > 0 Then mPathNew = folder & "새출발_" & ymd & ext
    If mCntGen > 0 Then mPathGen = folder & "일반_" & ymd & ext

    If Not overwrite Then
        If FileExists(mPathNew) Or FileExists(mPathGen) Then
            ProcessFile = "EXISTS"
            Exit Function
        End If
    End If

    If mCntNew > 0 Then
        res = MakeOutput(srcPath, mPathNew, shIdx, hdrRow, cNo, cType, cSum, rowNums, isNew, False, mCntNew)
        If res <> "" Then ProcessFile = res: Exit Function
    End If
    If mCntGen > 0 Then
        res = MakeOutput(srcPath, mPathGen, shIdx, hdrRow, cNo, cType, cSum, rowNums, isNew, True, mCntGen)
        If res <> "" Then ProcessFile = res: Exit Function
    End If
    Exit Function

openFail:
    ProcessFile = "원본 파일을 열지 못했습니다." & vbLf & "(" & Err.Description & ")"
    Exit Function
fail:
    ProcessFile = "원본 파일을 읽는 중 오류가 났습니다." & vbLf & "(" & Err.Description & ")"
    On Error Resume Next
    If Not src Is Nothing Then src.Close SaveChanges:=False
End Function


' 원본을 복사한 뒤 반대쪽 행을 지워 결과 파일을 만든다. 서식과 제목줄은 원본 그대로 둔다.
' dropNew = True 이면 새출발 행을, False 이면 일반 행을 지운다.
Private Function MakeOutput(ByVal srcPath As String, ByVal outPath As String, ByVal shIdx As Long, _
        ByVal hdrRow As Long, ByVal cNo As Long, ByVal cType As Long, ByVal cSum As Long, _
        ByRef rowNums() As Long, ByRef isNew() As Boolean, ByVal dropNew As Boolean, ByVal keepCnt As Long) As String
    Dim wb As Workbook, sh As Worksheet
    Dim i As Long, r As Long, lastRow As Long, ok As Boolean

    On Error GoTo fail
    If FileExists(outPath) Then Kill outPath
    FileCopy srcPath, outPath
    Set wb = Workbooks.Open(Filename:=outPath, UpdateLinks:=0, AddToMru:=False)
    Set sh = wb.Worksheets(shIdx)

    ' 아래 행부터 지워야 위쪽 행 번호가 바뀌지 않는다
    For i = UBound(rowNums) To LBound(rowNums) Step -1
        If isNew(i) = dropNew Then sh.Rows(rowNums(i)).Delete
    Next

    ' No. 를 1부터 다시 매긴다
    If cNo > 0 Then
        i = 0
        lastRow = sh.UsedRange.Row + sh.UsedRange.Rows.Count - 1
        For r = hdrRow + 1 To lastRow
            ToNum sh.Cells(r, cSum).Value, ok
            If ok And CellText(sh.Cells(r, cType)) <> "" Then
                i = i + 1
                ToNum sh.Cells(r, cNo).Value, ok
                If ok Then sh.Cells(r, cNo).Value = i
            End If
        Next
    End If

    UpdateTitleCount sh, hdrRow, keepCnt

    wb.Close SaveChanges:=True
    Exit Function

fail:
    MakeOutput = "결과 파일을 만들지 못했습니다." & vbLf & outPath & vbLf & "(" & Err.Description & ")" & vbLf & _
                 "같은 이름의 파일이 엑셀에 열려 있으면 닫고 다시 하세요."
    On Error Resume Next
    If Not wb Is Nothing Then wb.Close SaveChanges:=False
End Function


' 제목줄의 "(총 18건)" 을 나뉜 건수로 고친다
Private Sub UpdateTitleCount(ByVal sh As Worksheet, ByVal hdrRow As Long, ByVal cnt As Long)
    Dim r As Long, c As Long, lastCol As Long, s As String, p As Long, q As Long, mid_ As String
    lastCol = sh.UsedRange.Column + sh.UsedRange.Columns.Count - 1
    For r = 1 To hdrRow - 1
        For c = 1 To lastCol
            s = CellText(sh.Cells(r, c))
            p = InStr(s, "총")
            If p > 0 Then
                q = InStr(p + 1, s, "건")
                If q > p + 1 Then
                    mid_ = Trim$(Replace(Mid$(s, p + 1, q - p - 1), ",", ""))
                    If mid_ <> "" And IsNumeric(mid_) Then
                        sh.Cells(r, c).Value = Left$(s, p) & " " & cnt & Mid$(s, q)
                        Exit Sub
                    End If
                End If
            End If
        Next
    Next
End Sub


' "지원구분" 제목칸이 있는 행을 찾는다
Private Function FindHeaderRow(ByVal sh As Worksheet, ByRef cType As Long) As Long
    Dim r As Long, c As Long, lastCol As Long
    lastCol = sh.UsedRange.Column + sh.UsedRange.Columns.Count - 1
    If lastCol > 80 Then lastCol = 80
    For r = 1 To 30
        For c = 1 To lastCol
            If Norm(sh.Cells(r, c).Value) = "지원구분" Then
                cType = c
                FindHeaderRow = r
                Exit Function
            End If
        Next
    Next
End Function


' 제목칸은 두 줄일 수 있어 위아래 한 줄씩 더 본다
Private Function FindCol(ByVal sh As Worksheet, ByVal hdrRow As Long, ByVal lastCol As Long, ByVal key As String) As Long
    Dim r As Long, c As Long, r1 As Long
    r1 = hdrRow - 1
    If r1 < 1 Then r1 = 1
    For r = hdrRow To r1 Step -1
        For c = 1 To lastCol
            If Norm(sh.Cells(r, c).Value) = key Then FindCol = c: Exit Function
        Next
    Next
    For c = 1 To lastCol
        If Norm(sh.Cells(hdrRow + 1, c).Value) = key Then FindCol = c: Exit Function
    Next
End Function


' ===== 결과를 수수료계산 시트에 적기 =====
Private Sub WriteResults(ByVal ws As Worksheet, ByVal srcPath As String)
    ws.Unprotect
    ClearCells ws, False
    ws.Range("D3").Value = DateSerial(CLng(Left$(mYmd, 4)), CLng(Mid$(mYmd, 5, 2)), CLng(Right$(mYmd, 2)))
    ws.Range("F3").Value = Mid$(srcPath, LastSep(srcPath) + 1)
    ws.Cells(R_NEW, C_AMT).Value = mSumNew
    ws.Cells(R_GEN, C_AMT).Value = mSumGen
    ws.Cells(R_NEW, C_CNT).Value = mCntNew
    ws.Cells(R_GEN, C_CNT).Value = mCntGen
    If mPathNew = "" Then
        ws.Cells(R_FILE_NEW, 2).Value = "(새출발 0건 - 파일을 만들지 않음)"
    Else
        ws.Cells(R_FILE_NEW, 2).Value = mPathNew
    End If
    If mPathGen = "" Then
        ws.Cells(R_FILE_GEN, 2).Value = "(일반 0건 - 파일을 만들지 않음)"
    Else
        ws.Cells(R_FILE_GEN, 2).Value = mPathGen
    End If
    If mWarn = "" Then
        ws.Cells(R_NOTE, 2).Value = "이상 없음"
    Else
        ws.Cells(R_NOTE, 2).Value = Replace(mWarn, vbLf, " / ")
    End If
    ws.Calculate
    ws.Protect
End Sub


' 시트 보호는 부르는 쪽에서 푼다
' allClear = False : 불러오기 전에 자동 입력칸과 새출발/일반 행의 입력칸만 지운다
' allClear = True  : 초기화. 중도완제, 입금일자까지 모두 지운다 (수수료율은 남김)
Private Sub ClearCells(ByVal ws As Worksheet, ByVal allClear As Boolean)
    ws.Range("D3").ClearContents
    ws.Range("F3").ClearContents
    ws.Range(ws.Cells(R_NEW, C_AMT), ws.Cells(R_GEN, C_ERP)).ClearContents
    ws.Range(ws.Cells(R_NEW, C_BANK), ws.Cells(R_GEN, C_BANK)).ClearContents
    ws.Range(ws.Cells(R_NEW, C_CNT), ws.Cells(R_GEN, C_CNT)).ClearContents
    ws.Range(ws.Cells(R_FILE_NEW, 2), ws.Cells(R_NOTE, 2)).ClearContents
    If allClear Then
        ws.Range("B3").ClearContents
        ws.Cells(R_MID, C_AMT).ClearContents
        ws.Cells(R_MID, C_ERP).ClearContents
        ws.Cells(R_MID, C_BANK).ClearContents
        ws.Cells(R_MID, C_CNT).ClearContents
    End If
End Sub


Private Function SummaryText(ByVal ws As Worksheet) As String
    Dim s As String
    s = "처리일자 " & Format(ws.Range("D3").Value, "yyyy-mm-dd") & ",  총 " & (mCntNew + mCntGen) & "건" & vbLf & vbLf
    s = s & RowText(ws, R_NEW, "새출발") & RowText(ws, R_GEN, "일반") & vbLf
    s = s & "지원구분별 건수" & vbLf & mKinds & vbLf
    s = s & "만든 파일" & vbLf & JoinPaths() & vbLf
    If mWarn <> "" Then s = s & vbLf & "[확인 필요]" & vbLf & mWarn
    s = s & vbLf & "다음: 통장 입금액과 sERP 처리금액을 노란 칸에 입력하세요."
    SummaryText = s
End Function


Private Function RowText(ByVal ws As Worksheet, ByVal r As Long, ByVal nm As String) As String
    RowText = "[" & nm & "] " & ws.Cells(r, C_CNT).Value & "건" & _
              "   상환합계 " & Format(N0(ws.Cells(r, C_AMT).Value), "#,##0") & _
              "   수수료 " & Format(N0(ws.Cells(r, C_FEE).Value), "#,##0") & _
              "   입금예정 " & Format(N0(ws.Cells(r, C_NET).Value), "#,##0") & vbLf
End Function


Private Function JoinPaths() As String
    Dim s As String
    If mPathNew <> "" Then s = "  " & mPathNew & vbLf
    If mPathGen <> "" Then s = s & "  " & mPathGen & vbLf
    JoinPaths = s
End Function


' ===== 처음 한 번: 시트와 버튼 만들기 =====
Public Sub SetupWorkbook()
    Dim wb As Workbook, ws As Worksheet, g As Worksheet, s As Worksheet
    Dim i As Long, r As Long, c As Long, hdr As Variant, lbl As Variant

    Set wb = ThisWorkbook
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False

    Set ws = GetOrAddSheet(CALC_SHEET)
    Set g = GetOrAddSheet(GUIDE_SHEET)
    ws.Move Before:=wb.Worksheets(1)
    g.Move After:=ws

    For i = wb.Worksheets.Count To 1 Step -1
        Set s = wb.Worksheets(i)
        If s.Name <> CALC_SHEET And s.Name <> GUIDE_SHEET Then
            If Application.WorksheetFunction.CountA(s.Cells) = 0 Then s.Delete
        End If
    Next

    ' --- 수수료계산 시트 ---
    ws.Unprotect
    On Error Resume Next
    ws.Buttons.Delete
    On Error GoTo 0
    ws.Cells.Clear
    ws.Cells.Font.Name = "맑은 고딕"
    ws.Cells.Font.Size = 11

    With ws.Range("A1:J1")
        .Merge
        .Value = "변제금 상환내역 수수료 계산기"
        .Font.Size = 16
        .Font.Bold = True
        .HorizontalAlignment = xlCenter
    End With

    ws.Range("A3").Value = "입금일자"
    ws.Range("C3").Value = "처리일자"
    ws.Range("E3").Value = "원본파일"
    ws.Range("F3:J3").Merge
    ws.Range("B3").NumberFormat = "yyyy-mm-dd"
    ws.Range("D3").NumberFormat = "yyyy-mm-dd"
    For Each lbl In Array("A3", "C3", "E3")
        ws.Range(lbl).Font.Bold = True
        ws.Range(lbl).Interior.Color = RGB(242, 242, 242)
    Next
    BoxBorders ws.Range("A3:J3")

    hdr = Array("구분", "수수료율", "수수료", "차감입금액", "원금(합계)", "sERP금액", "차이금액", "통장입금액", "입금차이", "건수")
    For c = 0 To 9
        ws.Cells(R_HDR, c + 1).Value = hdr(c)
    Next
    With ws.Range(ws.Cells(R_HDR, 1), ws.Cells(R_HDR, 10))
        .Font.Bold = True
        .Interior.Color = RGB(217, 225, 242)
        .HorizontalAlignment = xlCenter
    End With

    ws.Cells(R_MID, C_KIND).Value = "중도완제"
    ws.Cells(R_NEW, C_KIND).Value = "새출발"
    ws.Cells(R_GEN, C_KIND).Value = "일반"
    ws.Cells(R_TOT, C_KIND).Value = "총계"
    ws.Range(ws.Cells(R_MID, 1), ws.Cells(R_TOT, 1)).HorizontalAlignment = xlCenter

    For r = R_MID To R_GEN
        ws.Cells(r, C_RATE).Value = DEFAULT_RATE
        ws.Cells(r, C_FEE).Formula = "=IF(" & A(r, C_AMT) & "="""","""",ROUNDDOWN(ROUND(" & A(r, C_AMT) & "*" & A(r, C_RATE) & ",4),0))"
        ws.Cells(r, C_NET).Formula = "=IF(" & A(r, C_AMT) & "="""",""""," & A(r, C_AMT) & "-" & A(r, C_FEE) & ")"
        ws.Cells(r, C_DIFF).Formula = "=IF(" & A(r, C_AMT) & "="""",""""," & A(r, C_AMT) & "-N(" & A(r, C_ERP) & "))"
        ws.Cells(r, C_BDIFF).Formula = "=IF(OR(" & A(r, C_BANK) & "=""""," & A(r, C_NET) & "=""""),""""," & A(r, C_BANK) & "-" & A(r, C_NET) & ")"
    Next
    For c = C_FEE To C_CNT
        If c <> C_RATE Then
            ws.Cells(R_TOT, c).Formula = "=SUM(" & A(R_MID, c) & ":" & A(R_GEN, c) & ")"
        End If
    Next
    ws.Range(ws.Cells(R_TOT, 1), ws.Cells(R_TOT, 10)).Font.Bold = True
    ws.Range(ws.Cells(R_TOT, 1), ws.Cells(R_TOT, 10)).Interior.Color = RGB(242, 242, 242)

    ws.Range(ws.Cells(R_MID, C_RATE), ws.Cells(R_GEN, C_RATE)).NumberFormat = "0.00%"
    ws.Range(ws.Cells(R_MID, C_FEE), ws.Cells(R_TOT, C_CNT)).NumberFormat = AMT_FMT
    ws.Range(ws.Cells(R_MID, C_RATE), ws.Cells(R_TOT, C_CNT)).HorizontalAlignment = xlRight
    BoxBorders ws.Range(ws.Cells(R_HDR, 1), ws.Cells(R_TOT, 10))

    ' 노란칸 = 직접 입력, 파란칸 = 자동 입력
    ws.Range("B3").Interior.Color = RGB(255, 242, 204)
    ws.Range(ws.Cells(R_MID, C_RATE), ws.Cells(R_GEN, C_RATE)).Interior.Color = RGB(255, 242, 204)
    ws.Cells(R_MID, C_AMT).Interior.Color = RGB(255, 242, 204)
    ws.Cells(R_MID, C_CNT).Interior.Color = RGB(255, 242, 204)
    ws.Range(ws.Cells(R_MID, C_ERP), ws.Cells(R_GEN, C_ERP)).Interior.Color = RGB(255, 242, 204)
    ws.Range(ws.Cells(R_MID, C_BANK), ws.Cells(R_GEN, C_BANK)).Interior.Color = RGB(255, 242, 204)
    ws.Range("D3").Interior.Color = RGB(221, 235, 247)
    ws.Range("F3").Interior.Color = RGB(221, 235, 247)
    ws.Range(ws.Cells(R_NEW, C_AMT), ws.Cells(R_GEN, C_AMT)).Interior.Color = RGB(221, 235, 247)
    ws.Range(ws.Cells(R_NEW, C_CNT), ws.Cells(R_GEN, C_CNT)).Interior.Color = RGB(221, 235, 247)

    ' 차이가 0이 아니면 빨간색
    For r = R_MID To R_TOT
        AddRedIfNonZero ws.Cells(r, C_DIFF)
        AddRedIfNonZero ws.Cells(r, C_BDIFF)
    Next

    ws.Cells(R_FILE_NEW - 1, 1).Value = "만든 파일"
    ws.Cells(R_FILE_NEW - 1, 1).Font.Bold = True
    ws.Cells(R_FILE_NEW, 1).Value = "새출발"
    ws.Cells(R_FILE_GEN, 1).Value = "일반"
    ws.Cells(R_NOTE, 1).Value = "확인사항"
    For r = R_FILE_NEW To R_NOTE
        ws.Range(ws.Cells(r, 2), ws.Cells(r, 10)).Merge
        ws.Cells(r, 2).Interior.Color = RGB(221, 235, 247)
    Next
    ws.Range(ws.Cells(R_NOTE, 2), ws.Cells(R_NOTE, 10)).WrapText = True
    ws.Rows(R_NOTE).RowHeight = 33
    BoxBorders ws.Range(ws.Cells(R_FILE_NEW, 1), ws.Cells(R_NOTE, 10))

    ws.Cells(16, 1).Value = "노란 칸 = 직접 입력,  파란 칸 = 자동 입력,  나머지 = 계산식"
    ws.Cells(17, 1).Value = "수수료 = 원금(합계) x 수수료율, 원 미만 버림.  원금(합계) = 상환내역의 합계(원금+이자+기타채무)."
    ws.Cells(18, 1).Value = "차감입금액 = 법인계좌에 들어와야 할 금액.  차이금액/입금차이가 0이 아니면 빨간색."
    ws.Range("A16:A18").Font.Color = RGB(89, 89, 89)
    ws.Range("A16:A18").Font.Size = 10

    ws.Columns("A").ColumnWidth = 11
    ws.Columns("B").ColumnWidth = 12
    ws.Columns("C:J").ColumnWidth = 13
    ws.Columns("J").ColumnWidth = 8
    ws.Columns("K").ColumnWidth = 3
    ws.Columns("L").ColumnWidth = 26

    AddButton ws, "L3", "1. 파일 불러오기 / 분류", "LoadAndSplit", 34
    AddButton ws, "L6", "초기화", "ResetAll", 26
    AddButton ws, "L8", "계산표 인쇄", "PrintCalc", 26

    On Error Resume Next
    With ws.PageSetup
        .PrintArea = "$A$1:$J$18"
        .Orientation = xlLandscape
        .Zoom = False
        .FitToPagesWide = 1
        .FitToPagesTall = 1
    End With
    On Error GoTo 0

    ' 입력칸만 풀고 시트 보호 (암호 없음)
    ws.Cells.Locked = True
    ws.Range("B3").Locked = False
    ws.Range(ws.Cells(R_MID, C_RATE), ws.Cells(R_GEN, C_RATE)).Locked = False
    ws.Cells(R_MID, C_AMT).Locked = False
    ws.Cells(R_MID, C_CNT).Locked = False
    ws.Range(ws.Cells(R_MID, C_ERP), ws.Cells(R_GEN, C_ERP)).Locked = False
    ws.Range(ws.Cells(R_MID, C_BANK), ws.Cells(R_GEN, C_BANK)).Locked = False
    ws.Protect

    ' --- 사용법 시트 ---
    g.Cells.Clear
    g.Cells.Font.Name = "맑은 고딕"
    g.Columns("A").ColumnWidth = 110
    WriteLines g, Array( _
        "변제금 상환내역 분류기 사용법", _
        "", _
        "[매일 하는 일]", _
        "1. 신용회복위원회에서 '변제금상환내역조회' 엑셀을 다운로드한다.", _
        "2. 수수료계산 시트의 [1. 파일 불러오기 / 분류] 버튼을 누르고 다운받은 파일을 고른다.", _
        "3. 다운받은 파일과 같은 폴더에 '새출발_날짜.xlsx', '일반_날짜.xlsx' 두 파일이 생긴다. (원본 서식 그대로)", _
        "4. 계산표의 '차감입금액'이 법인계좌에 들어와야 할 금액이다. 통장 입금액을 '통장입금액' 칸에 넣어 입금차이가 0인지 본다.", _
        "5. sERP 신용회복수납처리에서 파일마다 [엑셀 업로드] > 총 입금금액에 '원금(합계)' 입력 > 자동점검 > 수납처리. (두 번)", _
        "6. sERP 처리금액을 'sERP금액' 칸에 넣어 차이금액이 0인지 본다.", _
        "7. 중도완제가 있으면 중도완제 줄의 원금(합계), 건수를 직접 입력한다.", _
        "8. 필요하면 [계산표 인쇄], 끝나면 [초기화].", _
        "", _
        "[분류 기준]", _
        "- 지원구분에 '새출발'이 들어 있으면 새출발 파일, 나머지는 모두 일반 파일.", _
        "- 수수료 = 원금(합계) x 수수료율, 원 미만 버림. 수수료율은 노란 칸에서 바꿀 수 있다.", _
        "", _
        "[보안]", _
        "- 인터넷, 외부 프로그램을 쓰지 않는다. 고객 정보는 이 파일에 저장하지 않고 합계와 건수만 남는다.", _
        "- 만들어진 새출발/일반 파일과 원본 파일에는 고객 정보가 있으니 업로드 후 회사 규정대로 보관/삭제한다.")
    g.Range("A1").Font.Size = 14
    g.Range("A1").Font.Bold = True

    Application.DisplayAlerts = True
    Application.ScreenUpdating = True
    ws.Activate
    MsgBox "설치가 끝났습니다." & vbLf & vbLf & _
           "F12 > 파일 형식 'Excel 매크로 사용 통합 문서(*.xlsm)'로 저장하세요.", vbInformation, "설치 완료"
End Sub


' ===== 작은 도구들 =====
Private Function CalcSheet() As Worksheet
    On Error Resume Next
    Set CalcSheet = ThisWorkbook.Worksheets(CALC_SHEET)
    On Error GoTo 0
    If CalcSheet Is Nothing Then MsgBox "먼저 SetupWorkbook 을 실행하세요.", vbExclamation
End Function

Private Function GetOrAddSheet(ByVal nm As String) As Worksheet
    On Error Resume Next
    Set GetOrAddSheet = ThisWorkbook.Worksheets(nm)
    On Error GoTo 0
    If GetOrAddSheet Is Nothing Then
        Set GetOrAddSheet = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        GetOrAddSheet.Name = nm
    End If
End Function

Private Sub AddButton(ByVal ws As Worksheet, ByVal anchor As String, ByVal caption As String, _
                      ByVal macro As String, ByVal h As Double)
    Dim b As Object
    Set b = ws.Buttons.Add(ws.Range(anchor).Left, ws.Range(anchor).Top, 170, h)
    b.Caption = caption
    b.OnAction = macro
End Sub

Private Sub AddRedIfNonZero(ByVal c As Range)
    Dim fc As Object, ad As String
    On Error Resume Next    ' 색 표시는 보조 기능이라 실패해도 설치는 계속한다
    ad = c.Address(True, True)
    Set fc = c.FormatConditions.Add(Type:=xlExpression, Formula1:="=AND(ISNUMBER(" & ad & ")," & ad & "<>0)")
    fc.Font.Color = RGB(192, 0, 0)
    fc.Font.Bold = True
    fc.Interior.Color = RGB(255, 220, 220)
End Sub

Private Sub BoxBorders(ByVal rng As Range)
    Dim b As Variant
    For Each b In Array(xlEdgeLeft, xlEdgeTop, xlEdgeBottom, xlEdgeRight, xlInsideVertical, xlInsideHorizontal)
        rng.Borders(b).LineStyle = xlContinuous
        rng.Borders(b).Weight = xlThin
    Next
End Sub

Private Sub WriteLines(ByVal ws As Worksheet, ByVal lines As Variant)
    Dim i As Long
    For i = LBound(lines) To UBound(lines)
        ws.Cells(i - LBound(lines) + 1, 1).Value = lines(i)
    Next
End Sub

' 셀 주소 (예: E7)
Private Function A(ByVal r As Long, ByVal c As Long) As String
    A = Chr$(64 + c) & r
End Function

Private Function Norm(ByVal v As Variant) As String
    Dim s As String
    If IsError(v) Or IsEmpty(v) Then Exit Function
    s = CStr(v)
    s = Replace(s, " ", "")
    s = Replace(s, vbCr, "")
    s = Replace(s, vbLf, "")
    s = Replace(s, vbTab, "")
    s = Replace(s, ChrW(160), "")
    s = Replace(s, ChrW(12288), "")
    Norm = UCase$(s)
End Function

Private Function CellText(ByVal c As Range) As String
    If IsError(c.Value) Or IsEmpty(c.Value) Then Exit Function
    CellText = Trim$(CStr(c.Value))
End Function

Private Function ToNum(ByVal v As Variant, ByRef ok As Boolean) As Double
    Dim s As String
    ok = False
    If IsError(v) Or IsEmpty(v) Then Exit Function
    s = Trim$(Replace(CStr(v), ",", ""))
    If s = "" Then Exit Function
    If IsNumeric(s) Then
        ToNum = CDbl(s)
        ok = True
    End If
End Function

Private Function N0(ByVal v As Variant) As Double
    Dim ok As Boolean
    N0 = ToNum(v, ok)
End Function

' 날짜 칸을 "yyyymmdd" 로
Private Function DateKey(ByVal v As Variant) As String
    Dim s As String, i As Long, ch As String, digits As String
    If IsError(v) Or IsEmpty(v) Then Exit Function
    If VarType(v) = vbDate Then
        DateKey = Format(v, "yyyymmdd")
        Exit Function
    End If
    s = CStr(v)
    For i = 1 To Len(s)
        ch = Mid$(s, i, 1)
        If ch >= "0" And ch <= "9" Then digits = digits & ch
    Next
    If Len(digits) >= 8 Then DateKey = Left$(digits, 8)
End Function

Private Function LastSep(ByVal p As String) As Long
    LastSep = InStrRev(p, "\")
    If InStrRev(p, "/") > LastSep Then LastSep = InStrRev(p, "/")
End Function

Private Function FileExists(ByVal p As String) As Boolean
    If p = "" Then Exit Function
    On Error Resume Next
    FileExists = (Dir(p) <> "")
End Function
