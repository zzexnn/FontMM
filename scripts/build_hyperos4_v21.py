#!/usr/bin/env python3
"""Build the HyperOS 4 standalone module using a SHA256-pinned official FontMM ZIP."""
import argparse
import hashlib
import shutil
import stat
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UPSTREAM_SHA256 = "77df3e14ec12bae0a76c719453f378808927bd525e88131c4819bd8b2bfe1578"
OUTPUT = ROOT / "dist" / "FontMM_HyperOS4_Standalone_v2.1.zip"
REMOVE_XML = (
    "system/etc/fonts.xml", "system/etc/fonts_base.xml",
    "system/etc/fonts_ule.xml", "system/etc/font_fallback.xml",
    "system/system_ext/etc/fonts_base.xml", "system/system_ext/etc/fonts_ule.xml",
)
REPLACE = {
    "hyperos4/standalone/customize.sh": "customize.sh",
    "hyperos4/v21/module.prop": "module.prop",
    "hyperos4/v21/README.md": "README-HyperOS4.md",
    "hyperos4/module/hyperos-package/apply.sh": "apply.sh",
    "hyperos4/module/hyperos-package/hyperos_apply.sh": "hyperos/hyperos_apply.sh",
    "hyperos4/module/hyperos-package/status.sh": "hyperos/status.sh",
    "hyperos4/module/hyperos-package/action.sh": "action.sh",
    "LICENSE": "LICENSE",
    "src/tools/fontmm-subset": "tools/fontmm-subset",
}
REQUIRED = ["apply.sh", "customize.sh", "module.prop", "FONTS/hans.ttf",
            "webroot/index.html", "zygisk/arm64-v8a.so",
            "tools/fontmm-wght", "tools/fontmm-subset",
            "hyperos/original_apply.sh", "hyperos/hyperos_apply.sh"]

def build(source: Path) -> None:
    h = hashlib.file_digest(source.open("rb"), "sha256").hexdigest()
    if h != UPSTREAM_SHA256:
        raise ValueError(f"Official ZIP SHA256 mismatch: {h}")
    with tempfile.TemporaryDirectory() as d:
        root = Path(d)
        with zipfile.ZipFile(source) as z:
            assert z.testzip() is None, "Corrupt source ZIP"
            for item in z.infolist():
                p = Path(item.filename)
                if p.is_absolute() or ".." in p.parts or (item.external_attr >> 16) & 0o170000 == stat.S_IFLNK:
                    raise ValueError(f"Unsafe archive entry {p}")
                target = root / p
                if item.is_dir():
                    target.mkdir(parents=True, exist_ok=True)
                else:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    with z.open(item) as inp, target.open("wb") as out:
                        shutil.copyfileobj(inp, out)
        assert (root / "apply.sh").is_file(), "Original FontMM apply.sh absent"
        (root / "hyperos").mkdir(exist_ok=True)
        shutil.copy2(root / "apply.sh", root / "hyperos/original_apply.sh")
        for old, new in REPLACE.items():
            target = root / new
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / old, target)
        for name in REMOVE_XML:
            (root / name).unlink(missing_ok=True)
        for name in ("customize.sh", "apply.sh", "action.sh", "hyperos/original_apply.sh",
                     "hyperos/hyperos_apply.sh", "hyperos/status.sh"):
            (root / name).chmod(0o755)
        for name in REQUIRED:
            assert (root / name).is_file() and (root / name).stat().st_size > 0, f"Missing {name}"
        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(OUTPUT, "w", zipfile.ZIP_DEFLATED, compresslevel=7, allowZip64=True) as z:
            for p in sorted(root.rglob("*")):
                if not p.is_file(): continue
                rel = p.relative_to(root).as_posix()
                info = zipfile.ZipInfo(rel, date_time=(2026,11,20,0,0,0))
                info.create_system = 3
                info.external_attr = (0o100755 if rel.endswith(".sh") or rel.endswith("update-binary") else 0o100644) << 16
                info.compress_type = zipfile.ZIP_DEFLATED
                with p.open("rb") as inp, z.open(info, "w", force_zip64=True) as out:
                    shutil.copyfileobj(inp, out, 1024 * 1024)
    with zipfile.ZipFile(OUTPUT) as z:
        assert z.testzip() is None
        assert all(n in z.namelist() for n in REQUIRED)
        assert not any(n in z.namelist() for n in REMOVE_XML)
    digest = hashlib.file_digest(OUTPUT.open("rb"), "sha256").hexdigest()
    OUTPUT.with_suffix(".zip.sha256").write_text(f"{digest}  {OUTPUT.name}\n")
    print(f"Standalone ZIP: {OUTPUT}, {OUTPUT.stat().st_size} bytes, sha256 {digest}")

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("upstream_preplaced_zip",type=Path)
    build(ap.parse_args().upstream_preplaced_zip)
