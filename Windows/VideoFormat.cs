using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows {
    class VideoFormat {
        public readonly static VideoFormat G1 =
            new VideoFormat(1, "G1");
        public readonly static VideoFormat PSP =
            new VideoFormat(2, "PSP");
        public readonly static VideoFormat Theora =
            new VideoFormat(3, "Theora");

        public static readonly VideoFormat[] All = new VideoFormat[] { 
            G1, PSP, Theora
        };

        public static VideoFormat ForId(int id) {
            return All.First(vf => vf.Id == id);
        }

        private int id;
        private string displayName;

        private VideoFormat(int id, string displayName) {
            this.id = id;
            this.displayName = displayName;
        }
        public int Id {
            get { return id; }
        }
        public string DisplayName {
            get { return displayName; }
        }
    }
}
