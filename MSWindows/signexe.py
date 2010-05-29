import sys, os, re
import getopt
import yaml

def get_pfx_password():
    f = open(os.path.join(os.path.dirname(__file__), 'pcfpfxpassword.yaml'))
    map = yaml.load(f)
    f.close()
    return map['pcfpfxpassword']

password = get_pfx_password()
pfx_file = os.path.join(os.path.dirname(__file__), 
    'pcf.pfx')

opts, args = getopt.getopt(sys.argv[1:], "m", ["msi"])
if len(opts) > 0 and opts[0][0] in ("-m", "--msi"):
    description_option = "/d \"Miro Video Converter\""
    target_file = os.path.join(os.path.dirname(__file__), 
        "WindowsSetup\\Release\\MiroConverterSetup.msi")
else:
    description_option = ""
    target_file = os.path.join(os.path.dirname(__file__), 
        "Windows\\bin\\Release\\MiroConverter.exe")
command = ("signtool sign /f {0} /p {1} {2} {3}").format(
    pfx_file, password, description_option, target_file)
for line in os.popen(command).readlines():
    print(line)
