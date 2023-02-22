import UIKit
import WebKit


protocol ViewControllerManualDelegate: AnyObject {
    func onManualContinue(typeDevice: DeviceType, modelWatch: ModelWatch)
    func onManualContinue(typeDevice: DeviceType, modelSensor: ModelSensor)
}


class ViewControllerManual: UIViewController {

    @IBOutlet weak var txtSerial: UITextField!

    var delegate: ViewControllerManualDelegate?
    var typeDevice: DeviceType = .SmartWatch
    var serial: String = ""
    var bClickedConfirm: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpContinue(_ sender: Any) {
        serial = txtSerial.text ?? ""
        if serial.isEmpty { return }
        if typeDevice == .SmartWatch {
            tryRegisterWatch()
        }
        else {
            tryRegisterSensor()
        }
    }


    func tryRegisterWatch() {
        var stReq: StReqRegisterWatch = StReqRegisterWatch()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.serial = serial

        bClickedConfirm = true
        API.instance.registerWatch(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    let modelWatch: ModelWatch = ModelWatch()
                    modelWatch.sSerial         = self.serial

                    modelWatch.bIsManager      = stRsp.data?.is_manager          ?? false
                    modelWatch.iId             = stRsp.data?.id                  ?? 0
                    modelWatch.bNetStatus      = stRsp.data?.net_status          ?? false
                    modelWatch.sUserName       = stRsp.data?.user_name           ?? ""
                    modelWatch.sUserPhone      = stRsp.data?.user_phone          ?? ""
                    modelWatch.iUserSex        = stRsp.data?.user_sex            ?? 1
                    modelWatch.sUserBirth      = stRsp.data?.user_birthday       ?? ""
                    modelWatch.iUserTall       = stRsp.data?.user_tall           ?? 0
                    modelWatch.iUserWeight     = stRsp.data?.user_weight         ?? 0
                    modelWatch.sUserBlood      = stRsp.data?.user_blood          ?? ""
                    modelWatch.sUserIllHistory = stRsp.data?.user_ill_history    ?? ""
                    modelWatch.sLat            = stRsp.data?.lat                 ?? ""
                    modelWatch.sLon            = stRsp.data?.lon                 ?? ""
                    modelWatch.sAddress        = stRsp.data?.address             ?? ""
                    modelWatch.sServiceStart   = stRsp.data?.service_start       ?? ""
                    modelWatch.sServiceEnd     = stRsp.data?.service_end         ?? ""
                    modelWatch.iChargeStatus   = stRsp.data?.charge_status       ?? 0
                    //modelWatch.sSosContactName1  = ""
                    //modelWatch.sSosContactName2  = ""
                    //modelWatch.sSosContactName3  = ""
                    //modelWatch.sSosContactPhone1 = ""
                    //modelWatch.sSosContactPhone2 = ""
                    //modelWatch.sSosContactPhone3 = ""
                    //modelWatch.iHeartRateHigh    = 100
                    //modelWatch.iHeartRateLow     = 60

                    DispatchQueue.main.async {
                        self.dismiss(animated:false, completion: {
                            if DbManager.instance.insertWatch(model: modelWatch) {
                                self.delegate?.onManualContinue(typeDevice: self.typeDevice, modelWatch: modelWatch)
                            }
                        })
                    }
                    break
                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedConfirm = false
        }
    }


    func tryRegisterSensor() {
        var stReq: StReqRegisterSensor = StReqRegisterSensor()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.serial = serial
        stReq.type = (typeDevice == .FireSensor) ? Config.PREFIX_FIRESENSOR : Config.PREFIX_SMOKESENSOR

        bClickedConfirm = true
        API.instance.registerSensor(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    let modelSensor: ModelSensor = ModelSensor()
                    modelSensor.sSerial        = self.serial

                    modelSensor.bIsManager     = stRsp.data?.is_manager     ?? false
                    modelSensor.iId            = stRsp.data?.id             ?? 0
                    modelSensor.sType          = stRsp.data?.type           ?? ""
                    modelSensor.bNetStatus     = stRsp.data?.net_status     ?? false
                    modelSensor.bBatteryStatus = stRsp.data?.battery_status ?? false
                    modelSensor.bAlarmStatus   = stRsp.data?.alarm_status   ?? false
                    modelSensor.sLabel         = stRsp.data?.label          ?? ""
                    modelSensor.sContactName   = stRsp.data?.contact_name   ?? ""
                    modelSensor.sContactPhone  = stRsp.data?.contact_phone  ?? ""
                    modelSensor.sLat           = stRsp.data?.lat            ?? ""
                    modelSensor.sLon           = stRsp.data?.lon            ?? ""
                    modelSensor.sAddress       = stRsp.data?.address        ?? ""
                    modelSensor.sServiceStart  = stRsp.data?.service_start  ?? ""
                    modelSensor.sServiceEnd    = stRsp.data?.service_end    ?? ""

                    self.dismiss(animated:false, completion: {
                        if DbManager.instance.insertSensor(model: modelSensor) {
                            self.delegate?.onManualContinue(typeDevice: self.typeDevice, modelSensor: modelSensor)
                        }
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
