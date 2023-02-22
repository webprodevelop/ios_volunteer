import UIKit
import WebKit

class ViewControllerContact: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtContact1: UITextField!
    @IBOutlet weak var txtContact2: UITextField!
    @IBOutlet weak var txtContact3: UITextField!
    @IBOutlet weak var txtPhone1  : UITextField! {
        didSet {
            txtPhone1!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDonePhone1))
            )
        }
    }
    @IBOutlet weak var txtPhone2  : UITextField! {
        didSet {
            txtPhone2!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDonePhone2))
            )
        }
    }
    @IBOutlet weak var txtPhone3  : UITextField! {
        didSet {
            txtPhone3!.addDoneCancelToolbar(
                onDone: (target: self, action: #selector(onDonePhone3))
            )
        }
    }

    var bClickedConfirm: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        txtContact1.delegate = self
        txtContact2.delegate = self
        txtContact3.delegate = self

        //-- Init
        if Config.id_watch_monitoring > 0 {
            txtContact1.text = Config.modelWatchMonitoring.sSosContactName1
            txtContact2.text = Config.modelWatchMonitoring.sSosContactName2
            txtContact3.text = Config.modelWatchMonitoring.sSosContactName3
            txtPhone1.text = Config.modelWatchMonitoring.sSosContactPhone1
            txtPhone2.text = Config.modelWatchMonitoring.sSosContactPhone2
            txtPhone3.text = Config.modelWatchMonitoring.sSosContactPhone3
        }
    }


    //-- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case txtContact1: txtPhone1.becomeFirstResponder(); break
            case txtContact2: txtPhone2.becomeFirstResponder(); break
            case txtContact3: txtPhone3.becomeFirstResponder(); break
            default: break
        }
        return false
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @objc func onDonePhone1() {
        txtContact2.becomeFirstResponder()
    }


    @objc func onDonePhone2() {
        txtContact3.becomeFirstResponder()
    }


    @objc func onDonePhone3() {
        txtPhone3.resignFirstResponder()
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        if bClickedConfirm { return }
        if Config.id_watch_monitoring <= 0 {
            showToast(message: "There is no smartwatch bound", completion: nil)
            return
        }
        trySetSosContact()
    }


    func trySetSosContact() {
        var stReq: StReqSetSosContact = StReqSetSosContact()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile
        stReq.id        = Config.id_watch_monitoring
        stReq.sos_contact1_name = txtContact1.text ?? ""
        stReq.sos_contact2_name = txtContact2.text ?? ""
        stReq.sos_contact3_name = txtContact3.text ?? ""
        stReq.sos_contact1_phone = txtPhone1.text ?? ""
        stReq.sos_contact2_phone = txtPhone2.text ?? ""
        stReq.sos_contact3_phone = txtPhone3.text ?? ""

        bClickedConfirm = true
        API.instance.setSosContact(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelWatchMonitoring.sSosContactName1 = stReq.sos_contact1_name
                    Config.modelWatchMonitoring.sSosContactName2 = stReq.sos_contact2_name
                    Config.modelWatchMonitoring.sSosContactName3 = stReq.sos_contact3_name
                    Config.modelWatchMonitoring.sSosContactPhone1 = stReq.sos_contact1_phone
                    Config.modelWatchMonitoring.sSosContactPhone2 = stReq.sos_contact2_phone
                    Config.modelWatchMonitoring.sSosContactPhone3 = stReq.sos_contact3_phone

                    DbManager.instance.updateWatch(model: Config.modelWatchMonitoring)
                    self.showToast(message: "Successfully updated!".localized(), completion: {
                        self.dismiss(animated: true, completion: nil)
                    })

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedConfirm = false
        }
    }

}
