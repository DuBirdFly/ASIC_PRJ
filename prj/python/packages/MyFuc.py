import subprocess, os, sys


def run_cmd(cmd):
    # cmd可以是str, 也可以是list

    process = subprocess.run(cmd, capture_output=True)

    if process.stdout:
        sys.stdout.write("stdout: \n")
        sys.stdout.write(process.stdout.decode('utf-8'))
    else: print("stdout: None")

    if process.stderr:
        sys.stderr.write("stderr: \n")
        sys.stderr.write(process.stderr.decode('utf-8'))
        raise Exception("cmd 指令执行失败")