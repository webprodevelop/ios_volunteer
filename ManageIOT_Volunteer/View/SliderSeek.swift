//--------------------------------------
// - Usage
//  Require Image Asset named
//      img_seekbar_left
//      img_seekbar_right
//      img_seekbar_thumb
//--------------------------------------
import Foundation
import UIKit


protocol SliderSeekDelegate {
    func onSliderSeekChanged(sender: UIView, value: CGFloat)
}


class SliderSeek: UIView {

    /// Views
    private var viewLeft : UIView!
    private var viewRight: UIView!
    private var imgThumb : UIImageView!
    private var lblThumb : UILabel!

    /// Global Variables
    var colorLeft : UIColor = UIColor(patternImage: UIImage(named: "img_seekbar_left")!)
    var colorRight: UIColor = UIColor(patternImage: UIImage(named: "img_seekbar_right")!)

    private var HEIGHT_BAR : CGFloat = 10

    var delegate: SliderSeekDelegate? = nil
    var value: CGFloat = 0

    private var bSlidable : Bool = true
    private var valueStart: CGFloat = 0     /// Saved Value when dragging starts
    private var widthBar  : CGFloat = 0


    //------------------------------------------------
    // Layout
    //------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initUi()
    }


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUi()
    }


    override public func didMoveToWindow() {
        invalidate()
    }


    override public func observeValue(
        forKeyPath keyPath: String?,
        of         object : Any?,
        change : [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "frame" {
            invalidate()
        }
    }


    private func initUi() {
        if imgThumb != nil { return }

        addObserver(self, forKeyPath: "frame", options: .new, context: nil)

        viewLeft  = UIView()
        viewRight = UIView()
        imgThumb  = UIImageView()
        lblThumb  = UILabel()


        viewLeft.backgroundColor = colorLeft
        viewRight.backgroundColor = colorRight

        imgThumb.contentMode = .scaleAspectFit
        imgThumb.image = UIImage(named: "img_seekbar_thumb")!

        lblThumb.textColor = .darkGray
        lblThumb.font = UIFont.boldSystemFont(ofSize: HEIGHT_BAR * 1.2)

        addSubview(viewLeft)
        addSubview(viewRight)
        addSubview(imgThumb)
        addSubview(lblThumb)

        /// Tap Gesture
        imgThumb.isUserInteractionEnabled = true
        let gstPanThumb = UIPanGestureRecognizer(target: self, action: #selector(onPanThumb))
        gstPanThumb.minimumNumberOfTouches = 1
        gstPanThumb.maximumNumberOfTouches = 1
        imgThumb.addGestureRecognizer(gstPanThumb)
    }


    func invalidate() {

        imgThumb.frame.origin.y = 0
        imgThumb.frame.size.width  = HEIGHT_BAR * 4
        imgThumb.frame.size.height = HEIGHT_BAR * 3

        lblThumb.frame.origin.y    = HEIGHT_BAR
        lblThumb.frame.size.width  = HEIGHT_BAR * 2
        lblThumb.frame.size.height = HEIGHT_BAR * 1

        viewLeft.frame.origin.y     = HEIGHT_BAR
        viewRight.frame.origin.y    = HEIGHT_BAR
        viewLeft.frame.size.height  = HEIGHT_BAR
        viewRight.frame.size.height = HEIGHT_BAR

        viewLeft.layer.cornerRadius = HEIGHT_BAR / 2
        viewLeft.layer.masksToBounds = true
        viewLeft.clipsToBounds = true

        viewRight.layer.cornerRadius = HEIGHT_BAR / 2
        viewRight.layer.masksToBounds = true
        viewRight.clipsToBounds = true

        widthBar = bounds.size.width - imgThumb.frame.size.width   /// Consider Width of imgThumb
        if widthBar < 0 { widthBar = 0 }

        updateByValue()
    }


    func setTextThumb(text: String) {
        lblThumb.text = text
    }


    func setSlidable(slidable: Bool) {
        bSlidable = slidable
    }


    func setSeekValue(seekValue: Float) {
        value = CGFloat(seekValue)
        updateByValue()
    }


    //------------------------------------------------
    // Selector
    //------------------------------------------------
    @objc private func onPanThumb(_ recognizer: UIPanGestureRecognizer) {
        if !bSlidable { return }

        if recognizer.state == .began {
            valueStart = value
        }
        let trans = recognizer.translation(in: self)
        value = valueStart + trans.x / widthBar
        updateByValue()
        delegate?.onSliderSeekChanged(sender: self, value: value)
    }


    //------------------------------------------------
    // Function
    //------------------------------------------------
    private func updateByValue() {
        if value < 0 { value = 0 }
        if value > 1 { value = 1 }

        viewLeft.frame.origin.x    = imgThumb.frame.size.width / 2     /// Consider Width of imgThumb
        viewLeft.frame.size.width  = widthBar * value
        viewRight.frame.origin.x   = widthBar * value + imgThumb.frame.size.width / 2      /// Consider Width of imgThumb
        viewRight.frame.size.width = widthBar * (1 - value)

        imgThumb.frame.origin.x = viewRight.frame.origin.x - imgThumb.frame.size.width / 2
        lblThumb.frame.origin.x = imgThumb.frame.origin.x + HEIGHT_BAR * 2
    }

}
