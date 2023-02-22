import UIKit
import WebKit


protocol ViewControllerBankCardDelegate: AnyObject {
    func onBankCardDismiss()
}


class ViewControllerBankCard: UIViewController {

    @IBOutlet weak var viewBankCard: UIView!
    @IBOutlet weak var imgBankCard: UIImageView!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var btnManual: UIButton!

    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var txtBank: UITextField!
    @IBOutlet weak var txtNumber: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirm: UITextField!

    private let MODE_UPLOAD: Int = 0
    private let MODE_MANUAL: Int = 1
    private let MODE_PARSED: Int = 2

    weak var delegate: ViewControllerBankCardDelegate?

    private var iMode: Int = 0  /// MODE_UPLOAD


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Border of viewBankCard
        viewBankCard.backgroundColor = .clear
        viewBankCard.layer.cornerRadius = 5
        viewBankCard.layer.borderWidth = 1
        viewBankCard.layer.borderColor = UIColor.gray.cgColor

        let gestureBankCard = UITapGestureRecognizer(target: self, action: #selector(onTapBankCard(_:)))
        imgBankCard.addGestureRecognizer(gestureBankCard)

        //-- Underline of btnManual text
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let sManual = NSMutableAttributedString(string: "Manually".localized(), attributes: attrs)
        btnManual.setAttributedTitle(sManual, for: .normal)


        setMode(mode: MODE_UPLOAD)
    }


    func setMode(mode: Int) {
        switch mode {
            case MODE_UPLOAD:
                viewBankCard.isHidden = false
                btnManual.isHidden = false
                viewInfo.isHidden = true
                viewInfo.frame.origin.y = 280
                break
            case MODE_MANUAL:
                viewBankCard.isHidden = true
                btnManual.isHidden = true
                viewInfo.isHidden = false
                viewInfo.frame.origin.y = 45
                break
            case MODE_PARSED:
                viewBankCard.isHidden = false
                btnManual.isHidden = true
                viewInfo.isHidden = false
                viewInfo.frame.origin.y = 280
                break
            default: break
        }
    }


    @IBAction func onTouchUpBtnUpload(_ sender: Any) {
        ImagePickerManager().pickImage(self) { image in
            let imageResized = image.resizeImage(dimension: 768, opaque: true, contentMode: .scaleToFill)
            self.imgBankCard.image = imageResized

            self.tryGetIdCardFrontInfo()
        }
    }


    @IBAction func onTouchUpBtnManual(_ sender: Any) {
        setMode(mode: MODE_MANUAL)
    }


    @IBAction func onTouchUpBtnSave(_ sender: Any) {
        var bFilled: Bool = true
        if txtBank.text     == nil { bFilled = false }
        if txtNumber.text   == nil { bFilled = false }
        if txtPassword.text == nil { bFilled = false }
        if txtConfirm.text  == nil { bFilled = false }

        if !bFilled {
            showToast(message: "Please fill in the contents".localized(), completion: nil)
            return
        }

        if txtBank.text!.isEmpty     { bFilled = false }
        if txtNumber.text!.isEmpty   { bFilled = false }
        if txtPassword.text!.isEmpty { bFilled = false }
        if txtConfirm.text!.isEmpty  { bFilled = false }

        if !bFilled {
            showToast(message: "Please fill in the contents".localized(), completion: nil)
            return
        }

        if txtPassword.text! != txtConfirm.text! {
            showToast(message: "Confirm password is incorrect".localized(), completion: nil)
            return
        }

        tryRegisterBankCard()
    }


    @objc func onTapBankCard(_ sender: UIGestureRecognizer) {
        ImagePickerManager().pickImage(self) { image in
            let imageResized = image.resizeImage(dimension: 768, opaque: true, contentMode: .scaleToFill)
            self.imgBankCard.image = imageResized

            self.tryGetIdCardFrontInfo()
        }
    }


    func onBack() {
        dismissFromParent()
        delegate?.onBankCardDismiss()
    }


    func tryGetIdCardFrontInfo() {
        var stReq: StReqGetIdCardFrontInfo = StReqGetIdCardFrontInfo()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile

        if imgBankCard.image != nil {
            stReq.id_card_front_src = imgBankCard.image!.toBase64() ?? ""
        }

        API.instance.getIdCardFrontInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    DispatchQueue.main.async {
                        self.txtBank.text = stRsp.data!.id_card_num
                        self.txtNumber.text = stRsp.data!.address
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }

            DispatchQueue.main.async {
                self.setMode(mode: self.MODE_PARSED)
            }
        }
    }


    func tryRegisterBankCard() {
        var stReq: StReqRegisterBankCard = StReqRegisterBankCard()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile

        stReq.bank_name = txtBank.text ?? ""
        stReq.bank_card = txtNumber.text ?? ""
        stReq.bank_password = txtPassword.text ?? ""


        API.instance.registerBankCard(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.copyFromApiData(data: stRsp.data!)
                    DispatchQueue.main.async {
                        self.dismissFromParent()
                        self.delegate?.onBankCardDismiss()
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }

    }
}
