import UIKit
import WebKit


protocol ViewControllerInputDelegate: AnyObject {
    func onInputSuccess(mode: Int, value: String)
}


class ViewControllerInput: UIViewController, UITextViewDelegate {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtValue: UITextView!

    //-- Constant
    public static let INPUT_MODE_NONE     : Int = 0
    public static let INPUT_MODE_BIRTHDAY : Int = 1
    public static let INPUT_MODE_RESIDENCE: Int = 2
    public static let INPUT_MODE_COMPANY  : Int = 3
    public static let INPUT_MODE_PHONE    : Int = 4


    //-- Variable
    var delegate: ViewControllerInputDelegate? = nil

    private var bClickedConfirm: Bool = false
    private var iMode: Int = 0  /// INPUT_MODE_NONE
    private var sTitle: String = ""
    private var sValue: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        txtValue.text = ""
        bClickedConfirm = false

        //-- Gesture : viewOutside
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true

        //-- Decoration
        viewContent.backgroundColor = .white
        viewContent.layer.cornerRadius = 10
        viewContent.layer.borderWidth = 1
        viewContent.layer.borderColor = UIColor.gray.cgColor

        txtValue.backgroundColor = .clear
        txtValue.layer.borderWidth = 1
        txtValue.layer.borderColor = UIColor.gray.cgColor

        btnClose.backgroundColor = .clear
        btnClose.layer.cornerRadius = 4
        btnClose.layer.borderWidth = 2
        btnClose.layer.borderColor = UIColor.gray.cgColor

        btnSave.backgroundColor = .clear
        btnSave.layer.cornerRadius = 4
        btnSave.layer.borderWidth = 1
        btnSave.layer.borderColor = UIColor.gray.cgColor

        lblTitle.text = sTitle

        txtValue.delegate = self
        txtValue.text = sValue
        switch iMode {
            case ViewControllerInput.INPUT_MODE_BIRTHDAY:
                txtValue.keyboardType = .numberPad
                break
            case ViewControllerInput.INPUT_MODE_RESIDENCE:
                txtValue.keyboardType = .default
                break
            case ViewControllerInput.INPUT_MODE_COMPANY:
                txtValue.keyboardType = .default
                 break
            case ViewControllerInput.INPUT_MODE_PHONE:
                txtValue.keyboardType = .phonePad
                break
            default: break
        }
    }


    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch iMode {
            case ViewControllerInput.INPUT_MODE_BIRTHDAY:
                let setAllow = CharacterSet(charactersIn: "0123456789-")
                let setCurrent = CharacterSet(charactersIn: text)
                return setAllow.isSuperset(of: setCurrent)
            case ViewControllerInput.INPUT_MODE_RESIDENCE:
                break
            case ViewControllerInput.INPUT_MODE_COMPANY:
                 break
            case ViewControllerInput.INPUT_MODE_PHONE:
                let setAllow = CharacterSet(charactersIn: "0123456789")
                let setCurrent = CharacterSet(charactersIn: text)
                return setAllow.isSuperset(of: setCurrent)
            default: break
        }

        return true
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpSave(_ sender: Any) {
        if bClickedConfirm { return }
        bClickedConfirm = true

        let value: String = txtValue.text ?? ""
        if value.isEmpty {
            bClickedConfirm = false
            return
        }
        dismiss(animated: true, completion: {
            self.bClickedConfirm = false
            self.delegate?.onInputSuccess(mode: self.iMode, value: value)
        })
    }


    func setInputMode(mode: Int) {
        iMode = mode

        switch iMode {
            case ViewControllerInput.INPUT_MODE_BIRTHDAY:
                sTitle = "Birthday".localized()
                break
            case ViewControllerInput.INPUT_MODE_RESIDENCE:
                sTitle = "Residence".localized()
                break
            case ViewControllerInput.INPUT_MODE_COMPANY:
                sTitle = "Company".localized()
                break
            case ViewControllerInput.INPUT_MODE_PHONE:
                sTitle = "Phone Number".localized()
                break
            default: break
        }
    }


    func setInitValue(value: String) {
        sValue = value
    }
}
