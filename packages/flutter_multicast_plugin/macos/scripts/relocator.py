#!/usr/bin/env python3
import os
import sys
import subprocess

def run(cmd):
    print("🔧", " ".join(cmd))
    subprocess.run(cmd, check=True)

def get_dependencies(path):
    output = subprocess.check_output(["otool", "-L", path], text=True)
    return [
        line.split()[0].strip()
        for line in output.splitlines()[1:]
        if line.strip().startswith("@rpath") or line.strip().startswith("@loader_path")
    ]

def join_rpath(loader_path, relative_path):
    if relative_path in (".", "./"):
        return loader_path
    return f"{loader_path}/{relative_path.strip('/')}"

def rewrite(path, loader_path, relative_lib_path):
    deps = get_dependencies(path)
    new_id = f"{join_rpath(loader_path, relative_lib_path)}/{os.path.basename(path)}"
    run(["install_name_tool", "-id", new_id, path])
    for dep in deps:
        libname = os.path.basename(dep)
        new_dep = f"{join_rpath(loader_path, relative_lib_path)}/{libname}"
        run(["install_name_tool", "-change", dep, new_dep, path])

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: relocator.py <target_dir_or_file> <@loader_path or @rpath> <relative_lib_path>")
        print("Example: relocator.py gstreamer-frameworks/lib @loader_path lib")
        sys.exit(1)

    target = sys.argv[1]
    loader_path = sys.argv[2]
    relative_lib_path = sys.argv[3]

    if os.path.isfile(target):
        rewrite(target, loader_path, relative_lib_path)
    else:
        for root, dirs, files in os.walk(target):
            for file in files:
                if file.endswith(".dylib") or file == "gst-plugin-scanner":
                    full_path = os.path.join(root, file)
                    rewrite(full_path, loader_path, relative_lib_path)