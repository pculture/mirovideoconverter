using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.Threading;

namespace Mirosubs.Converter.Windows {
    // for raison d'etre, see http://social.msdn.microsoft.com/forums/en-US/netfxbcl/thread/e1c7ef92-3af9-457e-bd7f-73613864ddbf
    // need output more frequently than once every 1024 bytes
    class ProcessOutputHandler {
        private Process process;
        public ProcessOutputHandler(Process process) {
            this.process = process;
            
        }
        public void ReadStdErr() {
            try {
                string line;
                while (!process.HasExited) { 
                    process.StandardError.BaseStream.Flush();
                    line = process.StandardError.ReadLine();
                    if (line != null)
                        Debug.Print(line);
                }
            }
            catch (InvalidOperationException) {
                // The process has exited or StandardError hasn't been redirected.
            }
        }
        public void ReadStdOut() {
            try {
                string line;
                while (!process.HasExited && (line = process.StandardOutput.ReadLine()) != null)
                    Debug.Print(line);
            }
            catch (InvalidOperationException) {
                // The process has exited or StandardError hasn't been redirected.
            }
        }
        public static void RunProcess(string fileName, string arguments) {
            ProcessStartInfo psi = new ProcessStartInfo(fileName, arguments);
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;
            psi.RedirectStandardError = true;
            psi.RedirectStandardOutput = true;
            using (Process process = new Process()) {
                process.StartInfo = psi;
                ProcessOutputHandler outputHandler = 
                    new ProcessOutputHandler(process);
                Thread stdOutReader = new Thread(new ThreadStart(outputHandler.ReadStdOut));
                Thread stdErrReader = new Thread(new ThreadStart(outputHandler.ReadStdErr));
                process.Start();
                stdOutReader.Start();
                stdErrReader.Start();
                process.WaitForExit();
            }
        }
    }
}
