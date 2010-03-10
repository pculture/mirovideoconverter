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
            bool needsUpdate = false;
            needsUpdate = NeedsUpdate(versionURL, v);
            if (needsUpdate)
                NeedsUpdateHandler(this, new EventArgs());
        }
        private static bool NeedsUpdate(string versionURL, Version runningVersion) {
            using (XmlTextReader reader = new XmlTextReader(versionURL)) {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(reader);
                Version newestVersion = new Version(xmlDoc.ChildNodes[1].ChildNodes[0].Value);
                return newestVersion.CompareTo(runningVersion) > 0;
            }
        }
    }
}
