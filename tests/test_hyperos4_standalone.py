#!/usr/bin/env python3
"""Verify standalone release and simulate repeated font application."""
import os
from pathlib import Path
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
archive = ROOT / "dist/FontMM_HyperOS4_Standalone_v2.zip"
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    for name in ("FONTS/hans.ttf","webroot/index.html","zygisk/arm64-v8a.so","tools/fontmm-subset","hyperos/original_apply.sh","hyperos/hyperos_apply.sh","customize.sh"):
        assert name in z.namelist() and z.getinfo(name).file_size > 0
    for name in ("customize.sh","apply.sh","hyperos/original_apply.sh","hyperos/hyperos_apply.sh"):
        with tempfile.NamedTemporaryFile(suffix=".sh") as f:
            f.write(z.read(name)); f.flush()
            subprocess.run(["sh","-n",f.name],check=True)
    with tempfile.TemporaryDirectory() as d:
        tmp = Path(d)
        mod = tmp / "module"
        (mod/"FONTS").mkdir(parents=True)
        (mod/"FONTS/hans.ttf").write_bytes(b"CHINESE")
        (mod/"FONTS/en.ttf").write_bytes(b"LATIN")
        (mod/"hyperos").mkdir()
        (mod/"hyperos/original_apply.sh").write_text("#!/bin/sh\nexit 0\n")
        (mod/"hyperos/hyperos_apply.sh").write_bytes(z.read("hyperos/hyperos_apply.sh"))
        (mod/"apply.sh").write_bytes(z.read("apply.sh"))
        rom = tmp/"rom"
        for rel in ("product/fonts/MiSansVF.ttf","system/fonts/Roboto-Regular.ttf"):
            file=rom/rel; file.parent.mkdir(parents=True,exist_ok=True);file.write_bytes(b"ORIGINAL")
        env={**os.environ,"FONTMM_TEST_SYSTEM_ROOT":str(rom)}
        for _ in range(2):
            subprocess.run(["sh",str(mod/"apply.sh"),str(mod)],env=env,check=True)
        assert (mod/"system/product/fonts/MiSansVF.ttf").read_bytes()==b"CHINESE"
        assert (mod/"system/fonts/Roboto-Regular.ttf").read_bytes()==b"LATIN"
print("PASS: standalone components, shell syntax and repeated application")
