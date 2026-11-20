#!/usr/bin/env python3
"""Create installable HyperOS4 upgrade zip from publicly editable sources."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'hyperos4'/'module'
OUT=ROOT/'dist'/'FontMM_HyperOS4_Update_v1.zip'
OUT.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(OUT,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
    for item in sorted(SRC.rglob('*')):
        if not item.is_file(): continue
        rel=item.relative_to(SRC).as_posix()
        zi=zipfile.ZipInfo(rel,date_time=(2026,11,20,0,0,0))
        zi.create_system=3
        zi.external_attr=(0o100755 if rel.endswith('.sh') or rel.endswith('update-binary') else 0o100644)<<16
        zi.compress_type=zipfile.ZIP_DEFLATED
        archive.writestr(zi,item.read_bytes(),compress_type=zipfile.ZIP_DEFLATED,compresslevel=9)
print(OUT)
