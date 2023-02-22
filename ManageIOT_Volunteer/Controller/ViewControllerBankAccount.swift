import UIKit
import WebKit

protocol ViewControllerBankAccountDelegate: AnyObject {
    func onBankAccountDismiss()
    func onBankAccountPresent()
    func onBankAccountPresentBankCard()
    func onBankAccountPresentBankPassword()
    func onBankAccountPresentBankForgot()
}


class ViewControllerBankAccount: UIViewController {

    @IBOutlet weak var lblBank: UILabel!
    @IBOutlet weak var lblAccount: UILabel!

    private let VC_NONE        : Int = 0
    private let VC_BANKCARD    : Int = 1
    private let VC_BANKPASSWORD: Int = 2
    private let VC_BANKFORGOT  : Int = 3

    var delegate: ViewControllerBankAccountDelegate? = nil

    private var vcBankCard    : ViewControllerBankCard? = nil
    private var vcBankPassword: ViewControllerBankPassword? = nil
    private var vcBankForgot  : ViewControllerBankForgot? = nil

    private var iVcCurrent: Int = 0  /// VC_NONE


    override func viewDidLoad() {
        super.viewDidLoad()

        lblBank.text = Config.modelUserInfo.sBankName
        lblAccount.text = Config.modelUserInfo.sBankId

        if Config.modelUserInfo.sBankName.isEmpty {
            showViewControllerBankCard()
        }
        if Config.modelUserInfo.sBankName.isEmpty {
            showViewControllerBankCard()
        }
    }


    @IBAction func onTouchUpBtnDelete(_ sender: Any) {
        showViewControllerBankCard()
    }


    @IBAction func onTouchUpBtnModify(_ sender: Any) {
        showViewControllerBankPassword()
    }


    @IBAction func onTouchUpBtnForgot(_ sender: Any) {
        showViewControllerBankForgot()
    }


    func onBack() {
        switch iVcCurrent {
            case VC_NONE:
                dismissFromParent()
                delegate?.onBankAccountDismiss()
                break
            case VC_BANKCARD:
                vcBankCard?.onBack()
                break
            case VC_BANKPASSWORD:
                vcBankPassword?.onBack()
                break
            case VC_BANKFORGOT:
                vcBankForgot?.onBack()
                break
            default: break
        }
    }


    func dismissChildren() {
        vcBankCard?.dismissFromParent()
        vcBankPassword?.dismissFromParent()
        vcBankForgot?.dismissFromParent()

        vcBankCard = nil
        vcBankPassword = nil
        vcBankForgot = nil

        iVcCurrent = VC_NONE
    }


    func showViewControllerBankCard() {
        if vcBankCard == nil {
            let storyboard = UIStoryboard(name: "BankCard", bundle: nil)
            vcBankCard = storyboard.instantiateViewController(withIdentifier: "ViewControllerBankCard") as? ViewControllerBankCard
        }
        vcBankCard!.delegate = self
        addChildViewController(child: vcBankCard!, container: view, frame: view.bounds)
        iVcCurrent = VC_BANKCARD
        delegate?.onBankAccountPresentBankCard()
    }


    func showViewControllerBankPassword() {
        if vcBankPassword == nil {
            let storyboard = UIStoryboard(name: "BankPassword", bundle: nil)
            vcBankPassword = storyboard.instantiateViewController(withIdentifier: "ViewControllerBankPassword") as? ViewControllerBankPassword
        }
        vcBankPassword!.delegate = self
        addChildViewController(child: vcBankPassword!, container: view, frame: view.bounds)
        iVcCurrent = VC_BANKPASSWORD
        delegate?.onBankAccountPresentBankPassword()
    }


    func showViewControllerBankForgot() {
        if vcBankForgot == nil {
            let storyboard = UIStoryboard(name: "BankForgot", bundle: nil)
            vcBankForgot = storyboard.instantiateViewController(withIdentifier: "ViewControllerBankForgot") as? ViewControllerBankForgot
        }
        vcBankForgot!.delegate = self
        addChildViewController(child: vcBankForgot!, container: view, frame: view.bounds)
        iVcCurrent = VC_BANKFORGOT
        delegate?.onBankAccountPresentBankForgot()
    }

}


extension ViewControllerBankAccount: ViewControllerBankCardDelegate {

    func onBankCardDismiss() {
        lblBank.text = Config.modelUserInfo.sBankName
        lblAccount.text = Config.modelUserInfo.sBankId

        vcBankCard = nil
        iVcCurrent = VC_NONE
        delegate?.onBankAccountPresent()
    }
}


extension ViewControllerBankAccount: ViewControllerBankPasswordDelegate {

    func onBankPasswordDismiss() {
        vcBankPassword = nil
        iVcCurrent = VC_NONE
        delegate?.onBankAccountPresent()
    }
}


extension ViewControllerBankAccount: ViewControllerBankForgotDelegate {

    func onBankForgotDismiss() {
        vcBankForgot = nil
        iVcCurrent = VC_NONE
        delegate?.onBankAccountPresent()
    }
}
