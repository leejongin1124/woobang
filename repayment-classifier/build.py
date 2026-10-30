"""src/Repayment.vba(UTF-8)를 엑셀 가져오기용 변제금분류기.bas(CP949, CRLF)로 만든다.
한국어 Windows 엑셀은 .bas 를 CP949 로 읽으므로 UTF-8 그대로 가져오면 한글이 깨진다."""
from pathlib import Path

here = Path(__file__).parent
text = (here / "src" / "Repayment.vba").read_text(encoding="utf-8")
text = text.replace("\r\n", "\n").replace("\n", "\r\n")
(here / "변제금분류기.bas").write_bytes(text.encode("cp949"))
print("built 변제금분류기.bas")
