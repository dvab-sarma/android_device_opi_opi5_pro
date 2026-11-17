#!/usr/bin/env python3
"""Assemble a CM5 GPT image using ordinary files, without root or loop devices."""
import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import tempfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('product_out', type=Path)
p.add_argument('--output', type=Path)
p.add_argument('--boot-image', type=Path, help='use a separate boot image variant')
a = p.parse_args()
src = Path(__file__).resolve().parent
out = a.output or a.product_out / 'OrangePi_CM5_Android17_HDMI.img'
if out.exists():
    p.error(f'refusing to overwrite {out}')
parts = [('boot', 32768, 262144), ('system', 303104, 6291456),
         ('vendor', 6596608, 786432), ('metadata', 7385088, 32768),
         ('userdata', 7417856, 16777216 - 34 - 7417856)]
inputs = {name: a.product_out / (name + '.img') for name in ('boot', 'system', 'vendor')}
if a.boot_image is not None:
    inputs['boot'] = a.boot_image
loader = src / 'kernel/u-boot-rockchip.bin'
for name, _, sectors in parts[:3]:
    f = inputs[name]
    if not f.is_file() or not 0 < f.stat().st_size <= sectors * 512:
        p.error(f'missing or oversized {f}')
    if name != 'boot':
        with f.open('rb') as stream:
            stream.seek(1080)
            if stream.read(2) != b'\x53\xef':
                p.error(f'{f} must be a raw ext4 image, not Android sparse format')
if not loader.is_file() or not 0 < loader.stat().st_size <= (32768 - 64) * 512:
    p.error('CM5 U-Boot is missing or overlaps the boot partition')
out.parent.mkdir(parents=True, exist_ok=True)
def run(*args, **kwargs):
    subprocess.run([str(x) for x in args], check=True, **kwargs)
with tempfile.TemporaryDirectory(prefix='cm5-image-', dir=out.parent) as temp:
    temp = Path(temp)
    image = temp / 'disk.img'
    with image.open('wb') as f:
        f.truncate(8 * 1024**3)
    table = 'label: gpt\nunit: sectors\n\n'
    for name, start, sectors in parts:
        kind = 'C12A7328-F81F-11D2-BA4B-00A0C93EC93B' if name == 'boot' else '0FC63DAF-8483-4772-8E79-3D69D8477DE4'
        table += f'start={start}, size={sectors}, type={kind}, name="{name}"\n'
    run('sfdisk', '--no-reread', image, input=table, text=True)
    run('dd', f'if={loader}', f'of={image}', 'bs=512', 'seek=64', 'conv=notrunc', 'status=none')
    for name, start, sectors in parts:
        if name not in inputs:
            f = temp / (name + '.img')
            with f.open('wb') as stream:
                stream.truncate(sectors * 512)
            run('mke2fs', '-q', '-t', 'ext4', '-F', '-m', '0', '-L', name,
                '-O', '^metadata_csum_seed,^orphan_file', f)
            inputs[name] = f
        run('dd', f'if={inputs[name]}', f'of={image}', 'bs=4M', f'seek={start * 512}',
            'oflag=seek_bytes', 'conv=notrunc,sparse', 'status=none')
    run('sfdisk', '--verify', image)
    # Link atomically without replacing an existing image, including in a race.
    os.link(image, out)
h = hashlib.sha256()
with out.open('rb') as stream:
    for chunk in iter(lambda: stream.read(8 * 1024**2), b''):
        h.update(chunk)
out.with_suffix(out.suffix + '.sha256').write_text(f'{h.hexdigest()}  {out.name}\n')
print(out)
