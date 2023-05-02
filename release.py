
# This script will simply make a zip file to publish on new releases.

print("[build start]");

print(". importing");

import os, shutil, zipfile;

print(". building");

CWD = os.getcwd();
OUT_DIR = os.path.join(CWD, "_release");

if not os.path.isdir(OUT_DIR):
	os.mkdir(OUT_DIR);

fail = False;

with zipfile.ZipFile(os.path.join(OUT_DIR, "api_be2een.zip"), "w", zipfile.ZIP_DEFLATED) as file:
	
	for item in ("readme.md", "LICENSE", "mod.conf", "init.lua", "screenshot.png"):
		path = os.path.join(CWD, item);
		
		if not os.path.isfile(path):
			print(f"[error: file '{path}' not found, release aborted.]");
			fail = True;
			break;

		print(f". add item '{item}'");
		file.write(path, item);

if fail:
	shutil.rmtree(OUT_DIR);
else:
	print(f"[build finished: output in {OUT_DIR}]");
