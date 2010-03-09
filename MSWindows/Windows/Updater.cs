using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace Mirosubs.Converter.Windows {
    class Updater {
        internal event EventHandler<EventArgs> NeedsUpdateHandler;
        public void CheckForUpdate(string versionURL) {
            Version v = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;
            string versionString = string.Format("{0}.{1}.{2}.{3}",
                v.Major, v.Minor, v.Build, v.Revision);
            bool needsUpdate = false;
            needsUpdate = NeedsUpdate(versionURL, versionString);
            if (needsUpdate)
                NeedsUpdateHandler(this, new EventArgs());
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
