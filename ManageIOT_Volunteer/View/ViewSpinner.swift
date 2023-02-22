//------------------------------------------------
// - Usage
//    viewSpinner.min = 10
//    viewSpinner.max = 40
//    viewSpinner.step = 1.5
//    viewSpinner.current = 20
//------------------------------------------------
import Foundation
import UIKit


protocol ViewSpinnerDelegate {
    func onSpinnerInc()
    func onSpinnerDec()
}


public class ViewSpinner: UIView {

    private var txtValue: UITextField? = nil
    private var btnInc  : UIButton? = nil
    private var btnDec  : UIButton? = nil

    /// Constants
    private let TYPE_INT  : Int = 1
    private let TYPE_FLOAT: Int = 2

    /// Private Value
    private var valueMin: Float = 0
    private var valueMax: Float = 100
    private var valueStep: Float = 1
    private var valueCurrent: Float = 0
    private var type: Int = 1  /// TYPE_INT

    private var colorBtnDisabled: UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)

    /// Public Value
    var delegate: ViewSpinnerDelegate? = nil

    var min: Float {
        get { return valueMin }
        set { valueMin = newValue; checkType(); updateValue() }
    }

    var max: Float {
        get { return valueMax }
        set { valueMax = newValue; checkType(); updateValue() }
    }

    var step: Float {
        get { return valueStep }
        set { valueStep = newValue; checkType(); updateValue() }
    }

    var current: Float {
        get { return valueCurrent }
        set { valueCurrent = newValue; updateValue() }
    }


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


    private func initUi() {
        if txtValue != nil { return }

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        addObserver(self, forKeyPath: "frame", options: .new, context: nil)

        layer.masksToBounds = false
        clipsToBounds = true

        /// ImageView for Brand in center
        txtValue = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        addSubview(txtValue!)
        btnInc = UIButton(type: .system)
        addSubview(btnInc!)
        btnDec = UIButton(type: .system)
        addSubview(btnDec!)

        txtValue?.isEnabled = false
        txtValue?.textColor = UIColor.black
        txtValue?.text = "0"
        /// Padding
        let viewPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        txtValue?.leftView = viewPadding
        txtValue?.leftViewMode = .always


        btnInc?.backgroundColor = nil
        btnInc?.tintColor = UIColor.lightGray
        btnInc?.setImage(UIImage(named: "chevronup"), for: .normal)

        btnDec?.backgroundColor = nil
        btnDec?.tintColor = colorBtnDisabled
        btnDec?.setImage(UIImage(named: "chevrondown"), for: .normal)
        btnInc?.addTarget(self, action: #selector(onTouchUpBtnInc), for: .touchUpInside)
        btnDec?.addTarget(self, action: #selector(onTouchUpBtnDec), for: .touchUpInside)

    }


    func invalidate() {
        layer.cornerRadius = 5

        /// ImageView for Brand in center
        let w: CGFloat = bounds.width
        let h: CGFloat = bounds.height

        let hButton: CGFloat = h / 2
        let wButton: CGFloat = hButton * 1.2
        let hValue: CGFloat = h
        var wValue: CGFloat = w - wButton

        if wValue < 0 { wValue = 0 }

        txtValue!.frame = CGRect(
            x: 0,
            y: 0,
            width : wValue,
            height: hValue
        )

        btnInc!.frame = CGRect(
            x: wValue,
            y: 0,
            width : wButton,
            height: hButton
        )

        btnDec!.frame = CGRect(
            x: wValue,
            y: hButton,
            width : wButton,
            height: hButton
        )

        /// Decoration
        layer.borderWidth = 2
        layer.borderColor = UIColor.lightGray.cgColor

        btnInc?.backgroundColor = nil
        btnInc?.layer.borderWidth = 1
        btnInc?.layer.borderColor = UIColor.lightGray.cgColor
        btnDec?.backgroundColor = nil
        btnDec?.layer.borderWidth = 1
        btnDec?.layer.borderColor = UIColor.lightGray.cgColor
    }


    private func checkType() {
        type = TYPE_INT
        if (Float(Int(valueMin)) != valueMin) { type = TYPE_FLOAT }
        if (Float(Int(valueMax)) != valueMax) { type = TYPE_FLOAT }
        if (Float(Int(valueStep)) != valueStep) { type = TYPE_FLOAT }

    }


    private func updateValue() {
        if (valueCurrent <= valueMin) {
            valueCurrent = valueMin
            btnDec?.isEnabled = false
            btnDec?.tintColor = colorBtnDisabled
        }
        else {
            btnDec?.isEnabled = true
            btnDec?.tintColor = UIColor.lightGray
        }

        if (valueCurrent >= valueMax) {
            valueCurrent = valueMax
            btnInc?.isEnabled = false
            btnInc?.tintColor = colorBtnDisabled
        }
        else {
            btnInc?.isEnabled = true
            btnInc?.tintColor = UIColor.lightGray
        }

        if (type == TYPE_INT) {
            txtValue?.text = String(Int(valueCurrent))
        }
        else {
            txtValue?.text = String(valueCurrent)
        }
    }


    @objc func onTouchUpBtnInc(_ sender: UIButton) {
        valueCurrent += valueStep
        updateValue()
        if delegate == nil { return }
        delegate!.onSpinnerInc()
    }


    @objc func onTouchUpBtnDec(_ sender: UIButton) {
        valueCurrent -= valueStep
        updateValue()
        if delegate == nil { return }
        delegate!.onSpinnerDec()
    }
}

//------------------------------------------------------------------------------
