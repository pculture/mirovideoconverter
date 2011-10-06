import sys, os, re, shutil
import subprocess
import getopt
import uuid

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))
def rel(*x):
    return os.path.join(PROJECT_ROOT, *x)

def run(cmd):
    print("Running {0}".format(" ".join(cmd)))
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    output, err = process.communicate()
    print(output)
    print(err)

def build():
    print("Building\n")
    run(["devenv", "/build", "Release", "FFMPEGWrapper.sln", "/project", "Windows"])

def make_nsis_installer(version):
    NSIS_PATH = "C:\\Program Files (x86)\\NSIS\\makensis.exe"
    dist_dir = rel("distribution")
    if os.path.exists(dist_dir):
        shutil.rmtree(dist_dir)
    shutil.copytree(rel("Windows\\bin\\Release"), dist_dir)
    shutil.copytree(rel("Windows\\lib"), os.path.join(dist_dir, "lib"))
    shutil.copy(rel("Windows\\resources\converter3.ico"), dist_dir)
    shutil.copy(rel("mvc.nsi"), dist_dir)
    shutil.copy(rel("DotNet.nsh"), dist_dir)
    shutil.copy(rel("nsProcess.nsh"), dist_dir)
    os.chdir(dist_dir)
    cmd = [NSIS_PATH, "/DCONFIG_VERSION={1}".format(NSIS_PATH, version), "mvc.nsi"]
    run(cmd)

def find_assembly_version_no():
    with open('Windows\\Properties\\AssemblyInfo.cs', 'r') as f:
        for line in f.readlines():
            assembly_version_match = re.search(
                r"^\[assembly: AssemblyVersion\(\"([\d\.]+)\"\)", 
                line)
            if assembly_version_match is not None:
                return assembly_version_match.groups(1)[0]

def make_version_file():
    print("Making version file\n")
    version_no = find_assembly_version_no()
    print("Detected assembly version %s" % version_no)
    with open('c:\\temp\\miroconverterversion.xml', 'w') as f:
        f.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
        f.write("<version>%s</version>" % version_no)

def upload_to_server(testing_only):
    print("Uploading to server\n")
    target_folder = ("/home/pculture/data/mirovideoconverter"
        "/{0}MiroConverterSetup.exe").format("testing/" if testing_only else "")
    run(["pscp", "-v", "-i", "%USERPROFILE%\\.ssh\\osuosl.ppk", 
        rel("distribution\\MiroConverterSetup.exe"), 
        "pculture@ftp-osl.osuosl.org:{0}".format(target_folder)])
    if not testing_only:
        run(["pscp", "-v", "-i", "%USERPROFILE%\\.ssh\\osuosl.ppk",
            "c:\\temp\miroconverterversion.xml", 
            ("pculture@ftp-osl.osuosl.org:"
             "/home/pculture/data/mirovideoconverter/MiroConverterVersion.xml")])
    run(["plink", "-ssh", "-i", "%USERPROFILE%\\.ssh\\osuosl.ppk",
        "pculture@ftp-osl.osuosl.org", "./run-trigger"])

def main(argv):
    opts, args = getopt.getopt(argv, "v:r", ["version=", "release"])
    testing_only = True
    version = None
    for opt, arg in opts:
        if opt in ("-v", "--version"):
            version = arg
        if opt in ("-r", "--release"):
            testing_only = False
    if version is None:
        raise Exception("The version argument is not optional, homeboy")
    if re.match(r"^[\d\.]+$", version) is None:
        raise Exception("Version must be numeric only")
    print("You are running the {0} deployment.\n".format(
        "testing" if testing_only else "production"))
    build()
    make_nsis_installer(version)
    if not testing_only:
        make_version_file()
    upload_to_server(testing_only)

main(sys.argv[1:])