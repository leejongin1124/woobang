"""src/Repayment.vba(UTF-8)를 엑셀 가져오기용 변제금분류기.bas(CP949, CRLF)로 만든다.
한국어 Windows 엑셀은 .bas 를 CP949 로 읽으므로 UTF-8 그대로 가져오면 한글이 깨진다.
만들기 전에 VBA 내장 함수와 이름이 겹치는 변수를 찾는다 (LibreOffice 시험으로는 못 잡는 컴파일 오류)."""
import re
import sys
from pathlib import Path

# 변수·인수·프로시저 이름으로 쓰면 엑셀 VBA가 구문 오류를 내는 내장 이름
BUILTINS = """CBool CByte CCur CDate CDbl CDec CInt CLng CLngLng CLngPtr CSng CStr CVar CVErr
Abs Asc AscW Chr ChrW Date DateAdd DateDiff DatePart DateSerial DateValue Day Dir Error Exp Fix Format
Hex Hour IIf InStr InStrRev Int IsArray IsDate IsEmpty IsError IsMissing IsNull IsNumeric IsObject
LBound LCase Left Len Log LTrim Mid Minute Month Now Oct Replace Right RTrim Second Sgn Sin Space
Split Sqr Str StrComp String Time Timer Trim TypeName UBound UCase Val VarType Weekday Year
Name Open Close Get Put Print Input Line Kill Reset Stop Type Next Then Else Loop With Each""".split()
BUILTIN_SET = {b.lower() for b in BUILTINS}

here = Path(__file__).parent
text = (here / "src" / "Repayment.vba").read_text(encoding="utf-8")

declared = set()
for line in text.splitlines():
    code = line.split("'", 1)[0]
    m = re.match(r"\s*(?:Private |Public )?(?:Dim|Const|Private|Public)\s+(.*)", code)
    if m and not re.match(r"\s*(?:Private |Public )?(?:Sub|Function)\b", code):
        declared.update(re.findall(r"(?:^|,)\s*([A-Za-z_]\w*)", m.group(1)))
    m = re.match(r"\s*(?:Private |Public )?(?:Sub|Function)\s+(\w+)\s*\((.*)", code)
    if m:
        declared.add(m.group(1))
        declared.update(re.findall(r"(?:ByVal|ByRef|Optional)\s+(\w+)", m.group(2)))
    for p in re.findall(r"(?:ByVal|ByRef)\s+(\w+)", code):
        declared.add(p)

clash = sorted(n for n in declared if n.lower() in BUILTIN_SET)
if clash:
    sys.exit("VBA 내장 이름과 겹치는 이름: " + ", ".join(clash))

out = text.replace("\r\n", "\n").replace("\n", "\r\n")
(here / "변제금분류기.bas").write_bytes(out.encode("cp949"))
print(f"built 변제금분류기.bas (이름 {len(declared)}개 검사)")
