#!/bin/sh
# 가짜 데이터로 LibreOffice 시험을 돌린다. 결과 파일은 임시 폴더에 생기고 저장소에는 남지 않는다.
set -e
cd "$(dirname "$0")"
T=$(mktemp -d)
python3 make_sample.py "$T/변제금상환내역조회.xlsx"
python3 -c "
import sys; from openpyxl import load_workbook
wb=load_workbook(sys.argv[1]); ws=wb.active
ws.cell(6,16).value=99999; ws.cell(7,4).value='2026-10-29'; wb.save(sys.argv[2])" "$T/변제금상환내역조회.xlsx" "$T/bad.xlsx"
timeout 180 python3 lo_run.py ../src/Repayment.vba "$T/변제금상환내역조회.xlsx" "$T" 2>&1 | grep -v javaldx
python3 -c "
import sys
from openpyxl import load_workbook
for name, n, tot in (('새출발_20261030.xlsx', 2, 103921), ('일반_20261030.xlsx', 16, 597178)):
    ws = load_workbook(sys.argv[1] + '/' + name).active
    rows = [r for r in ws.iter_rows(min_row=4, values_only=True) if r[7]]
    assert ws['A1'].value == f'변제금상환내역조회(총 {n}건)', ws['A1'].value
    assert len(rows) == n and sum(r[15] for r in rows) == tot, name
    assert [r[0] for r in rows] == list(range(1, n + 1)), name
    print('PASS', name, n, '건', tot)
" "$T"
rm -rf "$T"
