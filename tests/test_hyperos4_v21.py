#!/usr/bin/env python3
"""Regression tests for HyperOS 4 Latin-fallback fix. Runs on Linux CI."""
from pathlib import Path
import os, subprocess, tempfile, zipfile

root=Path(__file__).resolve().parents[1]
bundle=root/"dist/FontMM_HyperOS4_Standalone_v2.1.zip"
with zipfile.ZipFile(bundle) as z:
    assert z.testzip() is None
    names=set(z.namelist())
    for n in ("webroot/index.html","FONTS/hans.ttf","tools/fontmm-subset","hyperos/original_apply.sh",
              "hyperos/hyperos_apply.sh","apply.sh","module.prop"):
        assert n in names and z.getinfo(n).file_size>0,n
    for n in ("customize.sh","apply.sh","hyperos/hyperos_apply.sh"):
        with tempfile.NamedTemporaryFile(suffix=".sh") as f:
            f.write(z.read(n));f.flush()
            subprocess.run(["sh","-n",f.name],check=True)
    assert b"-strip-latin" in z.read("tools/fontmm-subset"),"New ARM64 font subsetting tool is missing"
    def setup(t,english=True,english_target=True):
        mod=t/"mod"; (mod/"FONTS").mkdir(parents=True)
        (mod/"hyperos").mkdir()
        (mod/"tools").mkdir()
        (mod/"FONTS"/"hans.ttf").write_bytes(b"CHINESE+ABC")
        if english: (mod/"FONTS"/"en.ttf").write_bytes(b"LATIN123")
        (mod/"hyperos"/"original_apply.sh").write_text("#!/bin/sh\nexit 0\n")
        (mod/"hyperos"/"hyperos_apply.sh").write_bytes(z.read("hyperos/hyperos_apply.sh"))
        (mod/"apply.sh").write_bytes(z.read("apply.sh"))
        mock=mod/"tools"/"fontmm-subset"
        mock.write_text('#!/bin/sh\n[ "$5" = "-strip-latin" ] || exit 3\nprintf "HAN_ONLY" > "$4"\n')
        mock.chmod(0o755)
        rom=t/"rom"
        for path in (["product/fonts/MiSansVF.ttf"]+
                     (["system/fonts/Roboto-Regular.ttf"] if english_target else [])):
            file=rom/path;file.parent.mkdir(parents=True,exist_ok=True);file.write_bytes(b"ROM")
        env={**os.environ,"FONTMM_TEST_SYSTEM_ROOT":str(rom)}
        return mod,env
    with tempfile.TemporaryDirectory() as td:
        mod,env=setup(Path(td))
        for _ in range(2):
            r=subprocess.run(["sh",str(mod/"apply.sh"),str(mod)],env=env,capture_output=True,text=True)
            assert r.returncode==0,(r.stdout,r.stderr)
        assert (mod/"system/product/fonts/MiSansVF.ttf").read_bytes()==b"HAN_ONLY"
        assert (mod/"system/fonts/Roboto-Regular.ttf").read_bytes()==b"LATIN123"
        status=(mod/"hyperos"/"apply-status.txt").read_text()
        assert "independent_en=1" in status and "english=1" in status,status
    with tempfile.TemporaryDirectory() as td:
        mod,env=setup(Path(td),english=True,english_target=False)
        r=subprocess.run(["sh",str(mod/"apply.sh"),str(mod)],env=env,capture_output=True,text=True)
        assert r.returncode!=0
        assert "英数字体" in r.stderr
        assert not (mod/"system/product/fonts/MiSansVF.ttf").exists(),"Must fail before touching overlays"
    with tempfile.TemporaryDirectory() as td:
        mod,env=setup(Path(td),english=False,english_target=True)
        r=subprocess.run(["sh",str(mod/"apply.sh"),str(mod)],env=env,capture_output=True,text=True)
        assert r.returncode==0,(r.stdout,r.stderr)
        assert (mod/"system/product/fonts/MiSansVF.ttf").read_bytes()==b"CHINESE+ABC"
        assert (mod/"system/fonts/Roboto-Regular.ttf").read_bytes()==b"CHINESE+ABC"
print("PASS: v2.1 standalone, en priority, missing-en error and regular fallback")
