#!/usr/bin/env python3
"""Smoke-tests v2.2 local diagnostic export and retained font application logs."""
import os, subprocess, tempfile, zipfile
from pathlib import Path

base=Path(__file__).resolve().parents[1]
zpath=base/'dist/FontMM_HyperOS4_Standalone_v2.2.zip'
with zipfile.ZipFile(zpath) as z:
    assert z.testzip() is None, 'Corrupt ZIP'
    for name in ('customize.sh','apply.sh','hyperos/diagnostics.sh','hyperos/hyperos_apply.sh',
                 'FONTS/hans.ttf','tools/fontmm-subset','webroot/index.html','module.prop'):
        assert name in z.namelist() and z.getinfo(name).file_size>0,name
    html=z.read('webroot/index.html').decode()
    assert 'diagnostics-basic' in html and 'diagnostics-extended' in html
    js=b' '.join(z.read(f) for f in z.namelist() if f.startswith('webroot/assets/') and f.endswith('.js'))
    assert b'/hyperos/diagnostics.sh' in js, 'Export action missing in compiled UI'
    for name in ('customize.sh','apply.sh','hyperos/diagnostics.sh'):
        with tempfile.NamedTemporaryFile(suffix='.sh') as f:
            f.write(z.read(name)); f.flush()
            subprocess.run(['sh','-n',f.name],check=True)
    with tempfile.TemporaryDirectory() as d:
        t=Path(d); mod=t/'module'; fonts=mod/'FONTS';h=mod/'hyperos'; dest=t/'Download'/'FontMM'
        fonts.mkdir(parents=True); h.mkdir()
        (mod/'module.prop').write_text('id=FontMM\nversion=hos4.2.2\n')
        (fonts/'hans.ttf').write_bytes(b'PRIVATE_FONT_BINARY_NEVER_EXPORT')
        (fonts/'en.ttf').write_bytes(b'PRIVATE_ENGLISH_BINARY_NEVER_EXPORT')
        (h/'apply-status.txt').write_text('en system Roboto-Regular.ttf\ntotal=2\nenglish=1\n')
        (h/'last-apply.log').write_text('[HOS4] last apply\napply_exit=0\n')
        script=t/'diagnostics.sh';script.write_bytes(z.read('hyperos/diagnostics.sh'))
        env={**os.environ,'FONTMM_DIAG_MODULE_DIR':str(mod),'FONTMM_DIAG_OUTPUT_DIR':str(dest)}
        for mode in ('basic','extended'):
            run=subprocess.run(['sh',str(script),mode],env=env,text=True,capture_output=True)
            assert run.returncode==0,(run.stdout,run.stderr)
            assert run.stdout.startswith('DIAG_FILE='),run.stdout
            report=Path(run.stdout.strip().split('DIAG_FILE=')[1])
            content=report.read_text()
            assert 'FontMM HyperOS 4 diagnostic report' in content
            assert 'en system Roboto-Regular.ttf' in content
            assert 'PRIVATE_FONT_BINARY_NEVER_EXPORT' not in content
            assert 'PRIVATE_ENGLISH_BINARY_NEVER_EXPORT' not in content
            if mode=='basic': assert 'Not collected in basic mode' in content
            else: assert 'Optional font-related logcat' in content
        app=t/'apply-module'; (app/'FONTS').mkdir(parents=True)
        (app/'FONTS/hans.ttf').write_bytes(b'HAN')
        (app/'hyperos').mkdir()
        (app/'hyperos/original_apply.sh').write_text('#!/bin/sh\necho "Original font processor success"\n')
        (app/'hyperos/hyperos_apply.sh').write_text('#!/bin/sh\necho "HyperOS overlay success"\n')
        wrapper=t/'apply.sh'; wrapper.write_bytes(z.read('apply.sh'))
        for i in range(2):
            run=subprocess.run(['sh',str(wrapper),str(app)],text=True,capture_output=True)
            assert run.returncode==0,(run.stdout,run.stderr)
        assert 'apply_exit=0' in (app/'hyperos/last-apply.log').read_text()
        assert 'Original font processor success' in (app/'hyperos/previous-apply.log').read_text()
print('PASS: v2.2 UI, ZIP, diagnostics privacy, and persistent apply logs')
