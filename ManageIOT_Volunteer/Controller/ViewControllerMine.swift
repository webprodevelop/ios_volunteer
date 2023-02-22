import Foundation
import UIKit
import JuphoonCommon


protocol ViewControllerMineDelegate: AnyObject {
    func onMinePresent()
    func onMinePresentIntegralGrade()
    func onMinePresentCashInHistory()
    func onMinePresentIntegralRule()
    func onMinePresentRescueQuery()
    func onMinePresentRescueDetail()
    func onMinePresentRescueProcess()
    func onMinePresentPayment()
    func onMinePresentPassword()

    func onMinePresentAccountAlipay()
    func onMinePresentAccountWechat()

    func onMinePresentBankAccount()
    func onMinePresentBankCard()
    func onMinePresentBankPassword()
    func onMinePresentBankForgot()
}


class ViewControllerMine: UIViewController {

    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblPhone: UILabel!

    @IBOutlet weak var viewPersonalData   : UIView!
    @IBOutlet weak var viewIntegralGrade  : UIView!
    @IBOutlet weak var viewRescueHistory  : UIView!
    @IBOutlet weak var viewPayment        : UIView!
    @IBOutlet weak var viewCustomerService: UIView!
    @IBOutlet weak var viewManageAccount  : UIView!
    @IBOutlet weak var viewModifyPassword : UIView!
    @IBOutlet weak var viewAgree          : UIView!
    @IBOutlet weak var viewPolicy         : UIView!
    @IBOutlet weak var viewAppVersion     : UIView!
    @IBOutlet weak var lblAppVersion      : UILabel!
    @IBOutlet weak var btnLogout          : UIButton!

    private let VC_NONE         : Int = 0
    private let VC_INTEGRALGRADE: Int = 1
    private let VC_RESCUEQUERY  : Int = 2
    private let VC_PAYMENT      : Int = 3
    private let VC_PASSWORD     : Int = 4

    private var vcIntegralGrade: ViewControllerIntegralGrade? = nil
    private var vcRescueQuery  : ViewControllerRescueQuery?   = nil
    private var vcPayment      : ViewControllerPayment?       = nil
    private var vcPassword     : ViewControllerPassword?      = nil


    var delegate: ViewControllerMineDelegate? = nil

    var iVcCurrent: Int = 0 // VC_NONE
    var modelAlarm: ModelAlarm = ModelAlarm()


    override func viewDidLoad() {
        super.viewDidLoad()

        let gesturePersonalData    = UITapGestureRecognizer(target: self, action: #selector(onTapPersonalData(_:)))
        let gestureIntegralGrade   = UITapGestureRecognizer(target: self, action: #selector(onTapIntegralGrade(_:)))
        let gestureRescueHistory   = UITapGestureRecognizer(target: self, action: #selector(onTapRescueHistory(_:)))
        let gesturePayment         = UITapGestureRecognizer(target: self, action: #selector(onTapPayment(_:)))
        let gestureCustomerService = UITapGestureRecognizer(target: self, action: #selector(onTapCustomerService(_:)))
        let gestureManageAccount   = UITapGestureRecognizer(target: self, action: #selector(onTapManageAccount(_:)))
        let gestureModifyPassword  = UITapGestureRecognizer(target: self, action: #selector(onTapModifyPassword(_:)))
        let gestureAgree           = UITapGestureRecognizer(target: self, action: #selector(onTapAgree(_:)))
        let gesturePolicy          = UITapGestureRecognizer(target: self, action: #selector(onTapPolicy(_:)))

        viewPersonalData.addGestureRecognizer(gesturePersonalData)
        viewIntegralGrade.addGestureRecognizer(gestureIntegralGrade)
        viewRescueHistory.addGestureRecognizer(gestureRescueHistory)
        viewPayment.addGestureRecognizer(gesturePayment)
        viewCustomerService.addGestureRecognizer(gestureCustomerService)
        viewManageAccount.addGestureRecognizer(gestureManageAccount)
        viewModifyPassword.addGestureRecognizer(gestureModifyPassword)
        viewAgree.addGestureRecognizer(gestureAgree)
        viewPolicy.addGestureRecognizer(gesturePolicy)

        //-- Init
        imgPhoto.makeRounded()
        updateImagePhoto()

        lblName.text  = Config.modelUserInfo.sName
        lblPhone.text = Config.modelUserInfo.sMobile

        lblGrade.text = "v" + String(Config.modelUserInfo.iPointLevel)
        lblGrade.setShadowSelf(
            color: UIColor.gray,
            opacityShadow: 0.8,
            radiusShadow: 1,
            distance: CGSize(width: 1, height: 1)
        )

        btnLogout.layer.cornerRadius = 5
        btnLogout.layer.borderWidth = 1
        btnLogout.layer.borderColor = UIColor.lightGray.cgColor

        //-- App Version
        let oldVersion : String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        lblAppVersion.text = "Current Version".localized() + "  \(oldVersion)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lblPhone.text = Config.modelUserInfo.sMobile
    }


    @objc func onTapPersonalData(_ sender: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Personal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerPersonal") as! ViewControllerPersonal
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }


    @objc func onTapIntegralGrade(_ sender: UIGestureRecognizer) {
        if vcIntegralGrade == nil {
            let storyboard = UIStoryboard(name: "IntegralGrade", bundle: nil)
            vcIntegralGrade = storyboard.instantiateViewController(withIdentifier: "ViewControllerIntegralGrade") as? ViewControllerIntegralGrade
        }
        vcIntegralGrade!.delegate = self
        addChildViewController(child: vcIntegralGrade!, container: view, frame: view.bounds)
        iVcCurrent = VC_INTEGRALGRADE
        delegate?.onMinePresentIntegralGrade()
    }


    @objc func onTapRescueHistory(_ sender: UIGestureRecognizer) {
        if vcRescueQuery == nil {
            let storyboard = UIStoryboard(name: "RescueQuery", bundle: nil)
            vcRescueQuery = storyboard.instantiateViewController(withIdentifier: "ViewControllerRescueQuery") as? ViewControllerRescueQuery
        }
        vcRescueQuery!.delegate = self
        addChildViewController(child: vcRescueQuery!, container: view, frame: view.bounds)
        iVcCurrent = VC_RESCUEQUERY
        delegate?.onMinePresentRescueQuery()
    }


    @objc func onTapPayment(_ sender: UIGestureRecognizer) {
        if vcPayment == nil {
            let storyboard = UIStoryboard(name: "Payment", bundle: nil)
            vcPayment = storyboard.instantiateViewController(withIdentifier: "ViewControllerPayment") as? ViewControllerPayment
        }
        vcPayment!.delegate = self
        addChildViewController(child: vcPayment!, container: view, frame: view.bounds)
        iVcCurrent = VC_PAYMENT
        delegate?.onMinePresentPayment()
    }


    @objc func onTapCustomerService(_ sender: UIGestureRecognizer) {
        tryRequestChat()
    }


    @objc func onTapManageAccount(_ sender: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerAccount") as! ViewControllerAccount
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }


    @objc func onTapModifyPassword(_ sender: UIGestureRecognizer) {
//        if vcPassword == nil {
//            let storyboard = UIStoryboard(name: "Password", bundle: nil)
//            vcPassword = storyboard.instantiateViewController(withIdentifier: "ViewControllerPassword") as? ViewControllerPassword
//        }
//        vcPassword!.delegate = self
//        addChildViewController(child: vcPassword!, container: view, frame: view.bounds)
//        iVcCurrent = VC_PASSWORD
//        delegate?.onMinePresentPassword()
        let storyboard = UIStoryboard(name: "Password", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerPassword") as! ViewControllerPassword
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }


    @objc func onTapAgree(_ sender: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Agree", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerAgree") as! ViewControllerAgree
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }


    @objc func onTapPolicy(_ sender: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Policy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerPolicy") as! ViewControllerPolicy
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }


    @IBAction func onTouchUpBtnLogout(_ sender: Any) {
        showConfirm(
            title  : "Notice".localized(),
            message: "确认退出账号吗",
            handlerOk: { alertActionSD in
                Config.is_logged_in = false
                Config.saveLoginInfo()
                Config.modelUserInfo.iIdTask = 0
                DbManager.instance.deleteDb()
                self.dismiss(animated: true, completion: nil)
            },
            handlerCancel: { alertAction in
            }
        )
    }

    func onBack() {
        vcIntegralGrade?.onBack()
        vcRescueQuery?.onBack()
        vcPayment?.onBack()
        vcPassword?.onBack()
    }


    func dismissChildren() {
        vcIntegralGrade?.dismissChildren()
        vcRescueQuery?.dismissChildren()
        vcPayment?.dismissChildren()

        vcIntegralGrade?.dismissFromParent()
        vcRescueQuery?.dismissFromParent()
        vcPayment?.dismissFromParent()
        vcPassword?.dismissFromParent()

        vcIntegralGrade = nil
        vcRescueQuery   = nil
        vcPayment       = nil
        vcPassword      = nil
    }


    func updateImagePhoto() {
        //-- Init
        if let url = URL(string: Config.modelUserInfo.sPicture) {
            imgPhoto.loadImage(url: url)
        }
        else {
            imgPhoto.image = UIImage(named: "img_photo_empty")
        }
    }


    private func tryRequestChat() {
        var stReq: StReqRequestChat = StReqRequestChat()
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.token  = Config.modelUserInfo.sToken
        stReq.task_id = "0"

        API.instance.requestChat(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "ChatError", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerChatError") as! ViewControllerChatError
                            vc.modalPresentationStyle = .overCurrentContext
                            vc.modalTransitionStyle = .crossDissolve
                            vc.message = stRsp.msg!

                            self.present(vc, animated: true, completion: nil)
                        }
                        break
                    }
                    Config.juphoon_room_id = stRsp.data?.roomId ?? ""
                    Config.juphoon_room_pswd = stRsp.data?.password ?? ""
                    DispatchQueue.main.async {
                        let app = UIApplication.shared.delegate as? AppDelegate
                        app?.juphoonMain()
                    }
                    break

                case .failure(_):
                    break
            }
        }

    }

}


extension ViewControllerMine: ViewControllerPersonalDelegate {

    func onPersonalSuccess() {
        DispatchQueue.main.async {
            self.updateImagePhoto()
        }
    }
}


extension ViewControllerMine: ViewControllerIntegralGradeDelegate {

    func onIntegralGradeDismiss() {
        vcIntegralGrade = nil
        iVcCurrent = VC_NONE
        delegate?.onMinePresent()
    }


    func onIntegralGradePresent() {
        delegate?.onMinePresentIntegralGrade()
    }


    func onIntegralGradePresentCashInHistory() {
        delegate?.onMinePresentCashInHistory()
    }


    func onIntegralGradePresentIntegralRule() {
        delegate?.onMinePresentIntegralRule()
    }

}


extension ViewControllerMine: ViewControllerRescueQueryDelegate {

    func onRescueQueryDismiss() {
        vcRescueQuery = nil
        iVcCurrent = VC_NONE
        delegate?.onMinePresent()
    }


    func onRescueQueryPresent() {
        delegate?.onMinePresentRescueQuery()
    }


    func onRescueQueryPresentRescueDetail() {
        delegate?.onMinePresentRescueDetail()
    }


    func onRescueQueryPresentRescueProcess() {
        delegate?.onMinePresentRescueProcess()
    }

}


extension ViewControllerMine: ViewControllerPaymentDelegate {

    func onPaymentDismiss() {
        vcPayment = nil
        iVcCurrent = VC_NONE
        delegate?.onMinePresent()
    }


    func onPaymentPresent() {
        delegate?.onMinePresentPayment()
    }


    func onPaymentPresentAccountAlipay() {
        delegate?.onMinePresentAccountAlipay()
    }


    func onPaymentPresentAccountWechat() {
        delegate?.onMinePresentAccountWechat()
    }
}


extension ViewControllerMine: ViewControllerPasswordDelegate {

    func onPasswordDismiss() {
        vcPassword = nil
        iVcCurrent = VC_NONE
        delegate?.onMinePresent()
    }

}


extension ViewControllerMine: ViewControllerAccountDelegate {

    func onAccountSuccess() {
        DispatchQueue.main.async {
            self.lblPhone.text = Config.phone
        }
    }
}
