import glob
import os
import subprocess
import sys

def main():
    os.environ["PYTHONUTF8"] = "1"
    py_files = sorted(glob.glob("notebooks/[0-9]*.py"))
    if py_files:
        subprocess.run([sys.executable, "-m", "jupytext", "--to", "notebook", "--update"] + py_files, check=False)
    
    nb_files = sorted(glob.glob("notebooks/[0-9]*.ipynb"))
    for nb in nb_files:
        print(f"{nb:<42}", end="", flush=True)
        env = dict(os.environ)
        venv_bin = os.path.dirname(sys.executable)
        env["PATH"] = venv_bin + os.pathsep + env.get("PATH", "")
        res = subprocess.run([
            sys.executable, "-m", "jupyter", "nbconvert", "--to", "notebook",
            "--execute", "--inplace", nb, "--ExecutePreprocessor.timeout=900"
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env)
        if res.returncode == 0:
            print("PASS")
        else:
            print("FAIL")

if __name__ == "__main__":
    main()
