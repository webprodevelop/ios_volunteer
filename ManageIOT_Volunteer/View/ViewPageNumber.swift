//------------------------------------------------
// - Usage
//    viewPageNumber.delegate = self
//    viewPageNumber.setMaxCountPageButton(countPageButton: 5)
//    viewPageNumber.setCountPage(count: 7)
//    viewPageNumber.setCurrentPage(page: 3)
//------------------------------------------------
import Foundation
import UIKit


protocol ViewPageNumberDelegate {
    func onPageNumberSelected(pageNumber: Int)
}


public class ViewPageNumber: UIView {

    private var MAX_COUNT_BUTTON: Int = 5

    /// UI
    private var vBtnPage: [UIButton] = [UIButton]()
    private var btnPrev: UIButton? = nil
    private var btnNext: UIButton? = nil

    /// Public Value
    var delegate: ViewPageNumberDelegate? = nil

    /// Private Value
    private var iCountPage: Int = 1
    private var iCountButton: Int = 1
    private var iPageCurrent: Int = 0
    private var iPageForFirstButton: Int = 0


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


    convenience public init(frame:CGRect, colors: [UIColor]) {
        self.init(frame: frame)
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


    private func clear() {
        /// Remove Buttons
        btnPrev?.removeFromSuperview()
        btnNext?.removeFromSuperview()
        for btn in vBtnPage {
            btn.removeFromSuperview()
        }
        btnPrev = nil
        btnNext = nil
        vBtnPage.removeAll()
    }


    private func initUi() {
        if btnPrev != nil { return }

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)

        layer.masksToBounds = false
        clipsToBounds = true

        /// Init Value
        iPageCurrent = 0
        iPageForFirstButton = 0
        iCountButton = iCountPage
        if iCountButton > MAX_COUNT_BUTTON {
            iCountButton = MAX_COUNT_BUTTON
        }

        /// Update UI
        btnPrev = UIButton(type: .system)
        addSubview(btnPrev!)
        btnPrev!.addTarget(self, action: #selector(onTouchUpBtnPrev), for: .touchUpInside)

        btnNext = UIButton(type: .system)
        addSubview(btnNext!)
        btnNext!.addTarget(self, action: #selector(onTouchUpBtnNext), for: .touchUpInside)

        for _ in 0...MAX_COUNT_BUTTON - 1 {
            let btn = UIButton(type: .system)
            vBtnPage.append(btn)
            addSubview(btn)
            btn.addTarget(self, action: #selector(onTouchUpBtnPage), for: .touchUpInside)
        }
    }


    func invalidate() {
        /// ImageView for Brand in center
        let w: CGFloat = bounds.width
        let h: CGFloat = bounds.height

        let sButton: CGFloat = (w > h) ? h : w  /// Size of Each Button

        btnPrev!.frame = CGRect(x: 0, y: 0, width: sButton, height: sButton)
        btnPrev!.backgroundColor = .clear
        btnPrev!.tintColor = UIColor.lightGray
        btnPrev!.setImage(UIImage(named: "backwardend"), for: .normal)
        centerImageTitleInUIButton(button: btnPrev!)

        var lNext: CGFloat = w - sButton
        if lNext < 0 { lNext = 0 }
        btnNext!.frame = CGRect(x: lNext, y: 0, width: sButton, height: sButton)
        btnNext!.backgroundColor = .clear
        btnNext!.tintColor = UIColor.lightGray
        btnNext!.setImage(UIImage(named: "forwardend"), for: .normal)
        centerImageTitleInUIButton(button: btnNext!)

        var wButtons: CGFloat = w - sButton * 2     /// Whole Width of Page Buttons
        if wButtons < 0 { wButtons = 0 }
        var gap = wButtons - sButton * CGFloat(iCountButton)
        gap = gap / CGFloat(iCountButton + 1)
        if gap < 0 { gap = 0 }

        for i in 0...iCountButton - 1 {
            let btn = vBtnPage[i]
            btn.frame = CGRect(
                x: (sButton + gap) * CGFloat(i + 1),
                y: 0,
                width : sButton,
                height: sButton
            )
            btn.backgroundColor = .clear
            btn.setTitle(String(iPageForFirstButton + i + 1), for: .normal)
            if i == iPageCurrent - iPageForFirstButton {
                /// For Currently Selected Button
                btn.setTitleColor(UIColor.black, for: .normal)
                btn.tintColor = UIColor.darkGray
                btn.setImage(UIImage(named: "img_circle")?.resizeImage(dimension: sButton, opaque: false), for: .normal)
            }
            else {
                /// For Not Selected Button
                btn.setTitleColor(UIColor.lightGray, for: .normal)
                btn.tintColor = UIColor.lightGray
                btn.setImage(UIImage(named: "img_circle")?.resizeImage(dimension: sButton - 8, opaque: false), for: .normal)
            }
            centerImageTitleInUIButton(button: btn)

        }

        /// When Page Count is less than MAX_COUNT_PAGE_BUTTON, Hide Rest Buttons
        if iCountButton < MAX_COUNT_BUTTON {
            for i in iCountButton...MAX_COUNT_BUTTON - 1 {
                let btn = vBtnPage[i]
                btn.frame = CGRect(x: 0, y: 0, width : 0, height: 0)
            }
        }
    }


    private func updateCurrentPage() {
        iPageForFirstButton = iPageCurrent - iCountButton / 2
        if iPageForFirstButton + iCountButton > iCountPage {
            iPageForFirstButton = iCountPage - iCountButton
        }
        if iPageForFirstButton < 0 {
            iPageForFirstButton = 0
        }
        invalidate()
    }


    private func centerImageTitleInUIButton(button: UIButton) {
        let sizeImage: CGSize = button.imageView?.frame.size ?? CGSize()
        button.titleEdgeInsets = UIEdgeInsets(
            top   : 0,
            left  : sizeImage.width * -1,
            bottom: 0,
            right : 0
        )
        let sizeTitle: CGSize = button.titleLabel?.bounds.size ?? CGSize()
        button.imageEdgeInsets = UIEdgeInsets(
            top   : 0,
            left  : 0,
            bottom: 0,
            right : sizeTitle.width * -1
        )
    }


    @objc func onTouchUpBtnPrev(_ sender: UIButton) {
        if iPageCurrent == 0 { return }
        iPageCurrent = iPageCurrent - 1
        if iPageCurrent < 0 {
            iPageCurrent = 0
        }
        updateCurrentPage()
        delegate?.onPageNumberSelected(pageNumber: iPageCurrent)
    }


    @objc func onTouchUpBtnNext(_ sender: UIButton) {
        if iPageCurrent == iCountPage - 1 { return }
        iPageCurrent = iPageCurrent + 1
        if iPageCurrent >= iCountPage {
            iPageCurrent = iCountPage - 1
        }
        updateCurrentPage()
        delegate?.onPageNumberSelected(pageNumber: iPageCurrent)
    }


    @objc func onTouchUpBtnPage(_ sender: UIButton) {
        for i in 0...iCountButton {
            let btn = vBtnPage[i]
            if btn == sender {
                iPageCurrent = iPageForFirstButton + i
                updateCurrentPage()
                delegate?.onPageNumberSelected(pageNumber: iPageCurrent)
                break
            }
        }
    }


    public func setMaxCountPageButton(countPageButton: Int) {
        clear()

        /// Init again
        MAX_COUNT_BUTTON = countPageButton
        if MAX_COUNT_BUTTON < 1 {
            MAX_COUNT_BUTTON = 1
        }

        initUi()
    }


    public func setCountPage(count: Int) {
        clear()

        iCountPage = count
        if iCountPage < 1 {
            iCountPage = 1
        }

        initUi()
    }


    public func setCurrentPage(page: Int) {
        iPageCurrent = page
        if iPageCurrent < 0 {
            iPageCurrent = 0
        }
        if iPageCurrent >= iCountPage {
            iPageCurrent = iCountPage - 1
        }
        updateCurrentPage()
    }
}


//------------------------------------------------------------------------------
