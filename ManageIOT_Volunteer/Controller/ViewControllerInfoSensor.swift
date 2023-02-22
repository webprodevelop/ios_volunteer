import UIKit
import WebKit


protocol ViewControllerInfoSensorDelegate: AnyObject {
    func onInfoSensorSuccess(model: ModelSensor)
}


class ViewControllerInfoSensor: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtContact    : UITextField!
    @IBOutlet weak var txtPhone      : UITextField!
    @IBOutlet weak var txtAuthCode   : UITextField!
    @IBOutlet weak var txtPosition   : UITextField!
    @IBOutlet weak var txtAddress    : UITextField!
    @IBOutlet weak var txtDetailAddr1: UITextField!
    @IBOutlet weak var txtDetailAddr2: UITextField!
    @IBOutlet weak var viewAddress: UIView!

    var delegate: ViewControllerInfoSensorDelegate?
    var modelSensor: ModelSensor = ModelSensor()
    var bClickedConfirm: Bool = false
    var sLat: String = ""
    var sLon: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        txtContact.delegate     = self
        txtPhone.delegate       = self
        txtAuthCode.delegate    = self
        txtPosition.delegate    = self
        //txtAddress.delegate     = self
        //txtDetailAddr1.delegate = self
        //txtDetailAddr2.delegate = self

        let tapAddress = UITapGestureRecognizer(target: self, action: #selector(onTapAddress(_:)))
        txtAddress.addGestureRecognizer(tapAddress)

        //-- Init
        txtContact.text  = modelSensor.sContactName
        txtPhone.text    = modelSensor.sContactPhone
        txtPosition.text = modelSensor.sLabel
        updateTxtAddress()
    }


    //-- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case txtContact:     txtPhone.becomeFirstResponder();    break
            case txtPhone:       txtAuthCode.becomeFirstResponder(); break
            case txtAuthCode:    txtPosition.becomeFirstResponder(); break
            case txtPosition:    txtPosition.resignFirstResponder(); break
            //case txtAddress:     txtAddress.resignFirstResponder(); /*txtDetailAddr1.becomeFirstResponder();*/ break
            //case txtDetailAddr1: txtDetailAddr2.becomeFirstResponder(); break
            //case txtDetailAddr2: txtDetailAddr2.resignFirstResponder(); break
            default: break
        }
        return false
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpGetCode(_ sender: Any) {
        if txtPhone.text!.isEmpty {
            return
        }
        tryGetCode()
    }


    @IBAction func onTouchUpMap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerMap") as! ViewControllerMap
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        vc.dLat = Double(modelSensor.sLat) ?? Config.DEFAULT_LAT
        vc.dLon = Double(modelSensor.sLon) ?? Config.DEFAULT_LON
        vc.sAddress  = modelSensor.sAddress
        vc.sProvince = modelSensor.sProvince
        vc.sCity     = modelSensor.sCity
        vc.sDistrict = modelSensor.sDistrict
        present(vc, animated: false, completion: nil)
    }


    @IBAction func onTouchUpContinue(_ sender: Any) {
        if !modelSensor.bIsManager {
            dismiss(animated: true, completion: nil)
            return
        }
        if txtAuthCode.text!.isEmpty {
            return
        }
        if bClickedConfirm { return }

        modelSensor.sContactName  = txtContact.text  ?? ""
        modelSensor.sContactPhone = txtPhone.text    ?? ""
        modelSensor.sLabel        = txtPosition.text ?? ""
        modelSensor.sAddress      = txtAddress.text  ?? ""

        trySetSensorInfo()
    }


    @IBAction func onEditBeginAddress(_ sender: Any) {
        txtAddress.resignFirstResponder()
    }


    @objc func onTapAddress(_ sender: UITapGestureRecognizer? = nil) {
        onTouchUpMap(sender!)
    }


    func updateTxtAddress() {
        txtAddress.text = modelSensor.sAddress
        if modelSensor.sProvince == modelSensor.sCity {
            //-- When both are same as like : Province = "Beijing City", City = "Beijing City"
            txtDetailAddr1.text = modelSensor.sProvince
        }
        else {
            txtDetailAddr1.text = modelSensor.sProvince + " " + modelSensor.sCity
        }
        txtDetailAddr2.text = modelSensor.sDistrict
    }


    func tryGetCode() {
        var stReq: StReqCode = StReqCode()
        stReq.mobile   = txtPhone.text!

        API.instance.getCode(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    print(stRsp.data?.verify_code ?? "verify_code")

                    break
                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    func trySetSensorInfo() {
        var stReq: StReqSetSensorInfo = StReqSetSensorInfo()
        stReq.verify_code = txtAuthCode.text ?? ""

        stReq.token         = Config.modelUserInfo.sToken
        stReq.mobile        = Config.modelUserInfo.sMobile
        stReq.id            = modelSensor.iId
        stReq.contact_name  = modelSensor.sContactName
        stReq.contact_phone = modelSensor.sContactPhone
        stReq.label         = modelSensor.sLabel
        stReq.province      = modelSensor.sProvince
        stReq.city          = modelSensor.sCity
        stReq.district      = modelSensor.sDistrict
        stReq.address       = modelSensor.sAddress
        stReq.lat           = modelSensor.sLat
        stReq.lon           = modelSensor.sLon

        bClickedConfirm = true
        API.instance.setSensorInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    self.modelSensor.sContactName   = stRsp.data?.contact_name   ?? ""
                    self.modelSensor.sContactPhone  = stRsp.data?.contact_phone  ?? ""
                    self.modelSensor.sLabel         = stRsp.data?.label          ?? ""
                    self.modelSensor.bNetStatus     = stRsp.data?.net_status     ?? false
                    self.modelSensor.bBatteryStatus = stRsp.data?.battery_status ?? false
                    self.modelSensor.bAlarmStatus   = stRsp.data?.alarm_status   ?? false
                    self.modelSensor.sLat           = stRsp.data?.lat            ?? ""
                    self.modelSensor.sLon           = stRsp.data?.lon            ?? ""
                    self.modelSensor.sAddress       = stRsp.data?.address        ?? ""
                    self.modelSensor.sServiceStart  = stRsp.data?.service_start  ?? ""
                    self.modelSensor.sServiceEnd    = stRsp.data?.service_end    ?? ""

                    DbManager.instance.updateSensor(model: self.modelSensor)
                    self.dismiss(animated:false, completion: {
                        self.delegate?.onInfoSensorSuccess(model: self.modelSensor)
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


extension ViewControllerInfoSensor: ViewControllerMapDelegate {

    func onMapSuccess(address: String, province: String, city: String, district: String, lat: Double, lon: Double) {
        modelSensor.sAddress  = address
        modelSensor.sProvince = province
        modelSensor.sCity     = city
        modelSensor.sDistrict = district
        modelSensor.sLat = String(lat)
        modelSensor.sLon = String(lon)

        updateTxtAddress()
    }

}
