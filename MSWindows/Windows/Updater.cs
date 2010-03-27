//  MiroVideoConverter -- a super simple way to convert almost any video to MP4, 
//  Ogg Theora, or a specific phone or iPod.
//
//  Copyright 2010 Participatory Culture Foundation
//
//  This file is part of MiroVideoConverter.
//
//  MiroVideoConverter is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  MiroVideoConverter is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with MiroVideoConverter.  If not, see http://www.gnu.org/licenses/.

﻿using System;
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
