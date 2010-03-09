using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace Mirosubs.Converter.Windows {
    class Updater {
        public static void CheckForUpdate(string versionURL, string msiURL) {
            Version v = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;
            string versionString = string.Format("{0}.{1}.{2}.{3}",
                v.Major, v.Minor, v.Build, v.Revision);
            bool needsUpdate = false;
            try {
                needsUpdate = NeedsUpdate(versionURL, versionString);
            }
            catch (Exception) {
                // just eat it
            }
            if (needsUpdate) {
                UpdateNotification updateNotification =
                    new UpdateNotification();
                updateNotification.MSIURL = msiURL;
                updateNotification.ShowDialog();
            }
        }
        private static bool NeedsUpdate(string versionURL, string versionString) {
            using (XmlTextReader reader = new XmlTextReader(versionURL)) {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(reader);
                string newestVersion = xmlDoc.ChildNodes[1].ChildNodes[0].Value;
                return newestVersion != versionString;
            }
        }
    }
}
