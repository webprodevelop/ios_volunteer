import Foundation
import UIKit


public enum ViewPagerTabType {
    case basic            // Tab contains text only
    case image            // Tab contains images only
    case imageText        // Tab contains image with text
    case imageTextAnchor  // Tab contains image, text, anchor
}


public struct ViewPagerTab {

    public var title  : String
    public var imgSel : UIImage?
    public var imgOff : UIImage?
    public var anchor: Bool? = false


    public init(title: String, imgSel: UIImage?, imgOff: UIImage?) {
        self.title = title
        self.imgSel = imgSel
        self.imgOff = imgOff
        self.anchor = false
    }


    public init(title: String, imgSel: UIImage?, imgOff: UIImage?, anchor: Bool?) {
        self.title = title
        self.imgSel = imgSel
        self.imgOff = imgOff
        self.anchor = anchor
    }
}
