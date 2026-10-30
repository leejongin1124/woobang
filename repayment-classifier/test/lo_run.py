"""LibreOffice(VBA 호환 모드)로 Repayment.vba 를 돌려 보는 시험 도구. 엑셀 대신 쓰는 근사 시험이다."""
import os, re, subprocess, sys, time
import uno
from com.sun.star.beans import PropertyValue

bas, sample, outdir = sys.argv[1], sys.argv[2], sys.argv[3]

def prop(n, v):
    p = PropertyValue(); p.Name = n; p.Value = v; return p

code = open(bas, encoding="utf-8").read()
code = re.sub(r"^Attribute .*\n", "", code, flags=re.M)
# 대화상자 없이 돌리기 위해 MsgBox 를 기록용 함수로 바꾼다
code = code.replace('"(" & Err.Description & ")"', '"(" & Err.Description & ") line " & PREV_LINE')
# LibreOffice 에는 양식 단추(Buttons)가 없어 시험에서는 단추 만들기를 건너뛴다
code = re.sub(r"    Set b = ws\.Buttons\.Add.*\n.*\n.*OnAction = macro\n", "", code)
code = re.sub(r"\bMsgBox\(", "TMsgF(", code)
code = re.sub(r"\bMsgBox ", "TMsg ", code)
lines = code.split("\n"); out=[]; prev_cont=False
for i,l in enumerate(lines):
    st=l.strip()
    inbody = st and not prev_cont and not re.match(r"(Private |Public |End |Sub |Function |Option |Dim |Const |Else|ElseIf|Case|'|[A-Za-z_]+:$)", st) and l.startswith("    ")
    if inbody: out.append(f"PREV_LINE = TRACE_LINE: TRACE_LINE = {i+2}")
    out.append(l); prev_cont = l.rstrip().endswith(" _")
code = "\n".join(out)
code = "Option VBASupport 1\nPublic TRACE_LINE As Long\nPublic PREV_LINE As Long\n" + code + f'''
Private Sub TMsg(ByVal s As String, Optional ByVal b As Long, Optional ByVal t As String)
    ThisWorkbook.Worksheets("사용법").Range("C1").Value = s
End Sub
Private Function TMsgF(ByVal s As String, Optional ByVal b As Long, Optional ByVal t As String) As Long
    TMsgF = 6
End Function
Public Sub ShowTrace()
    ThisWorkbook.Worksheets(1).Range("Z1").Value = TRACE_LINE
End Sub
Public Sub TestRun()
    Dim r As String
    r = ProcessFile("{sample}", True)
    ThisWorkbook.Worksheets("사용법").Range("C2").Value = "RESULT=" & r
    If r = "" Then
        WriteResults CalcSheet(), "{sample}"
        ThisWorkbook.Worksheets("사용법").Range("C3").Value = SummaryText(CalcSheet())
    End If
    ThisWorkbook.Worksheets("사용법").Range("C4").Value = "EXIST_CHECK=" & ProcessFile("{sample}", False)
    ThisWorkbook.Worksheets("사용법").Range("C5").Value = "WRONG_FILE=" & ProcessFile(Replace("{sample}", "변제금상환내역조회", "일반_20261030"), False)
    ThisWorkbook.Worksheets("사용법").Range("C6").Value = "BAD=" & ProcessFile(Replace("{sample}", "변제금상환내역조회", "bad"), False) & "|" & mWarn
End Sub
'''

proc = subprocess.Popen(["soffice", "--headless", "--invisible", "--norestore",
                         '--accept=socket,host=localhost,port=2099;urp;'])
ctx = None
for _ in range(60):
    try:
        local = uno.getComponentContext()
        resolver = local.ServiceManager.createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", local)
        ctx = resolver.resolve("uno:socket,host=localhost,port=2099;urp;StarOffice.ComponentContext")
        break
    except Exception:
        time.sleep(0.5)
desktop = ctx.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)
doc = desktop.loadComponentFromURL("private:factory/scalc", "_blank", 0, (prop("Hidden", True),))
libs = doc.BasicLibraries
libs.VBACompatibilityMode = True
std = libs.getByName("Standard")
std.insertByName("Repayment", code)

def run(name):
    sp = doc.getScriptProvider()
    s = sp.getScript(f"vnd.sun.star.script:Standard.Repayment.{name}?language=Basic&location=document")
    try:
        s.invoke((), (), ())
        print(f"[{name}] ok")
    except Exception as e:
        print(f"[{name}] ERROR: {e}")

try:
    run("SetupWorkbook")
    run("ShowTrace"); print("trace after setup:", doc.Sheets.getByIndex(0).getCellRangeByName("Z1").String)
    run("TestRun")
    run("ShowTrace"); print("trace after test:", doc.Sheets.getByIndex(0).getCellRangeByName("Z1").String)
    sheets = doc.Sheets
    print("sheets:", sheets.ElementNames)
    g = sheets.getByName("사용법")
    for a in ("C1", "C2", "C4", "C5", "C6"):
        print(a, "=>", g.getCellRangeByName(a).String)
    ws = sheets.getByName("수수료계산")
    for r in range(3, 15):
        row = [ws.getCellByPosition(c, r - 1).String for c in range(10)]
        print(r, row)
    doc.storeToURL(uno.systemPathToFileUrl(os.path.join(outdir, "calc_result.ods")), ())
finally:
    doc.close(True)
    try: desktop.terminate()
    except Exception: pass
    proc.wait(timeout=30)
