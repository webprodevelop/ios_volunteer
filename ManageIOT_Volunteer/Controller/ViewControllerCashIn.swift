import UIKit
import WebKit

protocol ViewControllerCashInDelegate: AnyObject {
    func onCashInSuccess()
}

class ViewControllerCashIn: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var btnWechat: UIButton!
    @IBOutlet weak var btnAlipay: UIButton!
    @IBOutlet weak var btnBankCard: UIButton!
    
    weak var delegeate:ViewControllerCashInDelegate?

    private var iMode: Int = 1      /// Config.PAYMENT_ALIPAY = 1
    private var bIsTrying: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        onTouchUpBtnWechat(btnWechat!)

        let cash = String(format: "%.1f", Config.modelUserInfo.fCash)
        lblAmount.text = "CashIn amount is ".localized().appending(cash).appending("RMB".localized())

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
    }

    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onTouchUpOk(_ sender: Any) {
        if bIsTrying { return }
        

        if iMode == Config.PAYMENT_ALIPAY {
            if Config.modelUserInfo.sAlipayName.isEmpty
            || Config.modelUserInfo.sAlipayId.isEmpty {
                showAlert(message: "Alipay account has not been set.".localized())
                return
            }
        }
        if iMode == Config.PAYMENT_WECHAT {
            if Config.modelUserInfo.sWechatName.isEmpty
            || Config.modelUserInfo.sWechatId.isEmpty {
                showAlert(message: "Wechat account has not been set.".localized())
                return
            }
        }
        if iMode == Config.PAYMENT_BANKCARD {
            if Config.modelUserInfo.sBankName.isEmpty
            || Config.modelUserInfo.sBankId.isEmpty {
                showAlert(message: "Bank account has not been set.".localized())
                return
            }
        }
        tryRequestTransferPay()
//        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpBtnWechat(_ sender: Any) {
        btnWechat.tintColor = UIColor.gray
        btnWechat.setImage(UIImage(named: "img_check_on"), for: .normal)
        btnAlipay.tintColor = UIColor.lightGray
        btnAlipay.setImage(UIImage(named: "img_check_off"), for: .normal)
        btnBankCard.tintColor = UIColor.lightGray
        btnBankCard.setImage(UIImage(named: "img_check_off"), for: .normal)

        iMode = Config.PAYMENT_WECHAT
    }


    @IBAction func onTouchUpBtnAlipay(_ sender: Any) {
        btnWechat.tintColor = UIColor.lightGray
        btnWechat.setImage(UIImage(named: "img_check_off"), for: .normal)
        btnAlipay.tintColor = UIColor.gray
        btnAlipay.setImage(UIImage(named: "img_check_on"), for: .normal)
        btnBankCard.tintColor = UIColor.lightGray
        btnBankCard.setImage(UIImage(named: "img_check_off"), for: .normal)

        iMode = Config.PAYMENT_ALIPAY
    }


    @IBAction func onTouchUpBtnBankCard(_ sender: Any) {
        btnWechat.tintColor = UIColor.lightGray
        btnWechat.setImage(UIImage(named: "img_check_off"), for: .normal)
        btnAlipay.tintColor = UIColor.lightGray
        btnAlipay.setImage(UIImage(named: "img_check_off"), for: .normal)
        btnBankCard.tintColor = UIColor.gray
        btnBankCard.setImage(UIImage(named: "img_check_on"), for: .normal)

        iMode = Config.PAYMENT_BANKCARD
    }


    private func tryRequestTransferPay() {
        bIsTrying = true
        var stReq: StReqRequestTransferPay = StReqRequestTransferPay()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile
        stReq.pay_type  = iMode
        stReq.point     = Config.modelUserInfo.iBalance

        API.instance.requestTransferPay(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        DispatchQueue.main.async {
                            self.showAlert(message: stRsp.msg!, handler: { (UIAlertAction) in
                                self.dismiss(animated: false, completion: nil)
                            })
                        }
                        break;
                    }
                    if stRsp.data == nil { break }
                    
                    Config.modelUserInfo.iPoint          = Int(stRsp.data!.point ?? "0") ?? 0
                    Config.modelUserInfo.fCash           = Float(stRsp.data!.cash ?? "0") ?? 0
                    Config.modelUserInfo.iBalance        = Int(stRsp.data!.balance ?? "0") ?? 0
                    Config.modelUserInfo.iPointLevel     = Int(stRsp.data!.point_level ?? "0") ?? 0
                    self.showAlert(message: "提现成功", handler: { (UIAlertAction) in
                        self.dismiss(animated: false, completion: nil)
                        self.delegeate?.onCashInSuccess()
                    })
                    break

                case .failure(_):
                    DispatchQueue.main.async {
                        self.showAlert(message: "提现失败", handler: { (UIAlertAction) in
                            self.dismiss(animated: false, completion: nil)
                        })
                    }
                    break
            }
            self.bIsTrying = false
        }

    }
}
