using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows.VideoFormats {
    abstract class VideoFormat {
        public static readonly VideoFormat[] All = new VideoFormat[] { 
            AndroidVideoFormat.G1, 
            PSPVideoFormat.PSP, 
            TheoraVideoFormat.Theora, 
            AndroidVideoFormat.NexusOne, 
            AndroidVideoFormat.MagicMyTouch, 
            AndroidVideoFormat.Droid, 
            AndroidVideoFormat.ErisDesire,
            AndroidVideoFormat.Hero, 
            AndroidVideoFormat.CliqDEXT, 
            AndroidVideoFormat.BeholdII, 
            AppleVideoFormat.iPhone, 
            AppleVideoFormat.iPodTouch, 
            AppleVideoFormat.iPodNano, 
            AppleVideoFormat.iPodClassic
        };

        private string displayName;
        private string filePart;
        private string fileExtension;
        private VideoFormatGroup group;

        protected VideoFormat(string displayName, string filePart, string fileExtension, VideoFormatGroup group) {
            this.displayName = displayName;
            this.filePart = filePart;
            this.fileExtension = fileExtension;
            this.group = group;
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
        public int GroupOrder {
            get { return group.Order; }
        }
        public override string ToString() {
            return displayName;
        }
        public string OutputFileExtension {
            get {
                return string.Format(".{0}.{1}",
                    filePart, fileExtension);
            }
        }
        public abstract string GetArguments(string inputFileName, string outputFileName);
        public abstract VideoConverter MakeConverter(string fileName);
    }
}
