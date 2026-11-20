#!/usr/bin/env python3
from pathlib import Path
import subprocess, zipfile
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'hyperos4'/'module'
NEEDED=['customize.sh','module.prop','META-INF/com/google/android/updater-script','hyperos-package/apply.sh','hyperos-package/hyperos_apply.sh','hyperos-package/status.sh','LICENSE']
for p in NEEDED: assert (SRC/p).is_file(),p
for sh in SRC.rglob('*.sh'): subprocess.run(['/bin/sh','-n',str(sh)],check=True)
assert 'id=FontMM' in (SRC/'module.prop').read_text()
assert 'Android 17' in (SRC/'hyperos-package'/'README.md').read_text()
zip_path=ROOT/'dist'/'FontMM_HyperOS4_Update_v1.zip'
assert zip_path.is_file()
with zipfile.ZipFile(zip_path) as z:
    assert z.testzip() is None
    assert all(p in z.namelist() for p in NEEDED)
    assert not any(p.lower().endswith(('.ttf','.otf','.ttc')) for p in z.namelist())
print('OK: source, scripts and package')
