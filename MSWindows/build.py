import sys, os, re
import getopt
import uuid

def update_msi_version():
    print "Updating vdproj file\n"
    product_code = str(uuid.uuid4()).upper()
    package_code = str(uuid.uuid4()).upper()
    lines = []
    with open('WindowsSetup\\WindowsSetup.vdproj', 'r') as f:
        for line in f.readlines():
            old_line = line
            if re.search(r"ProductCode\" = \"8:\{", line) is not None:
                line = re.sub("8:\{[A-Z0-9\-]+\}", "8:{%s}" % product_code, line)
            if re.search(r"PackageCode\" = \"8:\{", line) is not None:
                line = re.sub("8:\{[A-Z0-9\-]+\}", "8:{%s}" % package_code, line)
            product_version_match = re.search(
                r"ProductVersion\" = \"8:(\d+\.\d+\.\d+)", line)
            if product_version_match is not None:
                old_product_version = product_version_match.groups(1)[0]
                new_product_version = \
                    '.'.join(`int(old_product_version.replace('.','')) + 1`)
                line = re.sub(old_product_version, new_product_version, line)
            if line != old_line:
                print "Replacing %s\nwith      %s\n" % (old_line, line)
            lines.append(line)
    with open('WindowsSetup\\WindowsSetup.vdproj', 'w') as f:
        for line in lines:
            f.write("%s" % line)

def build():
    print "Building\n"
    for line in os.popen(("devenv /build Release FFMPEGWrapper.sln "
        "/project WindowsSetup")).readlines():
        print line

def find_assembly_version_no():
    with open('Windows\\Properties\\AssemblyInfo.cs', 'r') as f:
        for line in f.readlines():
            assembly_version_match = re.search(
                r"^\[assembly: AssemblyVersion\(\"([\d\.]+)\"\)", 
                line)
            if assembly_version_match is not None:
                return assembly_version_match.groups(1)[0]

def make_version_file():
    print "Making version file\n"
    version_no = find_assembly_version_no()
    print "Detected assembly version %s" % version_no
    with open('c:\\temp\\miroconverterversion.xml', 'w') as f:
        f.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
        f.write("<version>%s</version>" % version_no)

def upload_to_server(testing_only):
    print "Uploading to server\n"
    target_folder = "/home/pculture/data/mirovideoconverter"
        "/{0}MiroConverterSetup.msi".format("testing/" if testing_only else "")
    for line in os.popen(("pscp -v -i %USERPROFILE%\\.ssh\\osuosl.ppk " 
        ".\\WindowsSetup\\Release\MiroConverterSetup.msi " 
        "pculture@ftp-osl.osuosl.org:{0}".format(target_folder)).readlines():
        print line
    if not testing_only:
        for line in os.popen(("pscp -v -i %USERPROFILE%\\.ssh\\osuosl.ppk " 
            "c:\\temp\miroconverterversion.xml " 
            "pculture@ftp-osl.osuosl.org:"
            "/home/pculture/data/mirovideoconverter/MiroConverterVersion.xml")).readlines():
            print line
        for line in os.popen(("plink -ssh -i %USERPROFILE%\.ssh\osuosl.ppk "
            "pculture@ftp-osl.osuosl.org ./run-trigger")).readlines():
            print line



def main(argv):
    opts, args = getopt.getopt(argv, "r", ["release"])
    testing_only = (len(opts) == 0 or opts[0][0] not in ("-r", "--release"))
    print "You are running the {0} deployment.\n".format(
        "testing" if testing_only else "production")
    update_msi_version()
    build()
    make_version_file()
    upload_to_server(testing_only)

main(sys.argv[1:])