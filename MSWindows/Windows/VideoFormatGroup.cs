using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Mirosubs.Converter.Windows {
    class VideoFormatGroup {
        public readonly static VideoFormatGroup Formats =
            new VideoFormatGroup("Formats", 1);
        public readonly static VideoFormatGroup Android =
            new VideoFormatGroup("Devices: Android", 2);
        public readonly static VideoFormatGroup Apple =
            new VideoFormatGroup("Devices: Apple", 3);
        public readonly static VideoFormatGroup Other =
            new VideoFormatGroup("Devices: Other", 4);

        private string displayName;
        private int order;
        private VideoFormatGroup(string displayName, int order) {
            this.displayName = displayName;
            this.order = order;
        }
        public string DisplayName {
            get { return displayName; }
        }
        public int Order {
            get { return order; }
        }
    }
}
