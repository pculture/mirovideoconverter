using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows {
    class VideoFormat {
        public readonly static VideoFormat G1 =
            new VideoFormat(1, "G1", "g1", VideoFormatGroup.Android);
        public readonly static VideoFormat PSP =
            new VideoFormat(2, "PSP", "psp", VideoFormatGroup.Other);
        public readonly static VideoFormat Theora =
            new VideoFormat(3, "Theora", "theora", VideoFormatGroup.Formats);
        public readonly static VideoFormat NexusOne =
            new VideoFormat(4, "Nexus One", "nexusone", VideoFormatGroup.Android);
        public readonly static VideoFormat MagicMyTouch =
            new VideoFormat(5, "Magic / myTouch", "magic", VideoFormatGroup.Android);
        public readonly static VideoFormat Droid =
            new VideoFormat(6, "Droid", "droid", VideoFormatGroup.Android);
        public readonly static VideoFormat ErisDesire =
            new VideoFormat(7, "Eris / Desire", "eris", VideoFormatGroup.Android);
        public readonly static VideoFormat Hero =
            new VideoFormat(8, "Hero", "hero", VideoFormatGroup.Android);
        public readonly static VideoFormat CliqDEXT =
            new VideoFormat(9, "Cliq / DEXT", "cliq", VideoFormatGroup.Android);
        public readonly static VideoFormat BeholdII =
            new VideoFormat(10, "Behold II", "behold", VideoFormatGroup.Android);
        public readonly static VideoFormat iPhone =
            new VideoFormat(11, "iPhone", "iphone", VideoFormatGroup.Apple);
        public readonly static VideoFormat iPodTouch =
            new VideoFormat(12, "iPod Touch", "ipodtouch", VideoFormatGroup.Apple);
        public readonly static VideoFormat iPodNano =
            new VideoFormat(13, "iPod Nano", "ipodnano", VideoFormatGroup.Apple);
        public readonly static VideoFormat iPodClassic =
            new VideoFormat(14, "iPod Classic", "ipodclassic", VideoFormatGroup.Apple);

        public static readonly VideoFormat[] All = new VideoFormat[] { 
            G1, PSP, Theora, NexusOne, MagicMyTouch, Droid, ErisDesire,
            Hero, CliqDEXT, BeholdII, iPhone, iPodTouch, iPodNano, iPodClassic
        };

        public static VideoFormat ForId(int id) {
            return All.First(vf => vf.Id == id);
        }

        private int id;
        private string displayName;
        private string filePart;
        private VideoFormatGroup group;

        private VideoFormat(int id, string displayName, string filePart, VideoFormatGroup group) {
            this.id = id;
            this.displayName = displayName;
            this.filePart = filePart;
            this.group = group;
        }
        public int Id {
            get { return id; }
        }
        public string DisplayName {
            get { return displayName; }
        }
        public string GroupName {
            get { return group.DisplayName; }
        }
        public VideoFormatGroup Group {
            get { return group; }
        }
        public string FilePart {
            get { return filePart; }
        }
        public int GroupOrder {
            get { return group.Order; }
        }
        public override string ToString() {
            return displayName;
        }
    }
}
