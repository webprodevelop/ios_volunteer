import UIKit
import WebKit


protocol ViewControllerNotificationDelegate: AnyObject {
    func onNotificationSuccess(model: ModelAlarm)
}


class ViewControllerNotification: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var swtWatchSos   : UISwitch!
    @IBOutlet weak var swtSensorAlarm: UISwitch!
    @IBOutlet weak var swtWatchNet   : UISwitch!
    @IBOutlet weak var swtSensorNet  : UISwitch!
    @IBOutlet weak var swtHeart      : UISwitch!
    @IBOutlet weak var swtWatchPower : UISwitch!
    @IBOutlet weak var swtSensorPower: UISwitch!
    @IBOutlet weak var swtFence      : UISwitch!
    @IBOutlet weak var swtMorning    : UISwitch!
    @IBOutlet weak var swtEvening    : UISwitch!

    var delegate: ViewControllerNotificationDelegate? = nil
    var modelAlarm: ModelAlarm = ModelAlarm()

    override func viewDidLoad() {
        super.viewDidLoad()

        swtWatchSos.isOn    = modelAlarm.bWatchSos
        swtSensorAlarm.isOn = modelAlarm.bSensorAlarm
        swtWatchNet.isOn    = modelAlarm.bWatchNet
        swtSensorNet.isOn   = modelAlarm.bSensorNet
        swtHeart.isOn       = modelAlarm.bHeart
        swtWatchPower.isOn  = modelAlarm.bWatchPower
        swtSensorPower.isOn = modelAlarm.bSensorPower
        swtFence.isOn       = modelAlarm.bFence
        swtMorning.isOn     = modelAlarm.bMorning
        swtEvening.isOn     = modelAlarm.bEvening
    }


    override func viewWillDisappear(_ animated: Bool) {
        trySetAlarmSetInfo()
        delegate?.onNotificationSuccess(model: modelAlarm)
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpAuthorize(_ sender: Any) {
        DispatchQueue.main.async {
            guard let urlSettings = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(urlSettings) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlSettings, completionHandler: { (success) in
                    })
                }
                else {
                    UIApplication.shared.openURL(urlSettings as URL)
                }
            }
        }
    }


    @IBAction func onTouchUpTone(_ sender: Any) {
        DispatchQueue.main.async {
            guard let urlSettings = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(urlSettings) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(urlSettings, completionHandler: { (success) in
                    })
                }
                else {
                    UIApplication.shared.openURL(urlSettings as URL)
                }
            }
        }
    }


    @IBAction func onValueChangedWatchSos(_ sender: Any) {
        if swtWatchSos.isOn {
            modelAlarm.bWatchSos = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtWatchSos.isOn = false
                self.modelAlarm.bWatchSos = false
            },
            handlerCancel: { alertAction in
                self.swtWatchSos.isOn = true
                self.modelAlarm.bWatchSos = true
            }
        )
    }


    @IBAction func onValueChangedSensorAlarm(_ sender: Any) {
        if swtSensorAlarm.isOn {
            modelAlarm.bSensorAlarm = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtSensorAlarm.isOn = false
                self.modelAlarm.bSensorAlarm = false
            },
            handlerCancel: { alertAction in
                self.swtSensorAlarm.isOn = true
                self.modelAlarm.bSensorAlarm = true
            }
        )
    }


    @IBAction func onValueChangedWatchNet(_ sender: Any) {
        if swtWatchNet.isOn {
            modelAlarm.bWatchNet = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtWatchNet.isOn = false
                self.modelAlarm.bWatchNet = false
            },
            handlerCancel: { alertAction in
                self.swtWatchNet.isOn = true
                self.modelAlarm.bWatchNet = true
            }
        )
    }


    @IBAction func onValueChangedSensorNet(_ sender: Any) {
        if swtSensorNet.isOn {
            modelAlarm.bSensorNet = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtSensorNet.isOn = false
                self.modelAlarm.bSensorNet = false
            },
            handlerCancel: { alertAction in
                self.swtSensorNet.isOn = true
                self.modelAlarm.bSensorNet = true
            }
        )
    }


    @IBAction func onValueChangedHeart(_ sender: Any) {
        if swtHeart.isOn {
            modelAlarm.bHeart = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtHeart.isOn = false
                self.modelAlarm.bHeart = false
            },
            handlerCancel: { alertAction in
                self.swtHeart.isOn = true
                self.modelAlarm.bHeart = true
            }
        )
    }


    @IBAction func onValueChangedWatchPower(_ sender: Any) {
        if swtWatchPower.isOn {
            modelAlarm.bWatchPower = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtWatchPower.isOn = false
                self.modelAlarm.bWatchPower = false
            },
            handlerCancel: { alertAction in
                self.swtWatchPower.isOn = true
                self.modelAlarm.bWatchPower = true
            }
        )
    }


    @IBAction func onValueChangedSensorPower(_ sender: Any) {
        if swtSensorPower.isOn {
            modelAlarm.bSensorPower = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtSensorPower.isOn = false
                self.modelAlarm.bSensorPower = false
            },
            handlerCancel: { alertAction in
                self.swtSensorPower.isOn = true
                self.modelAlarm.bSensorPower = true
            }
        )
    }


    @IBAction func onValueChangedFence(_ sender: Any) {
        if swtFence.isOn {
            modelAlarm.bFence = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtFence.isOn = false
                self.modelAlarm.bFence = false
            },
            handlerCancel: { alertAction in
                self.swtFence.isOn = true
                self.modelAlarm.bFence = true
            }
        )
    }


    @IBAction func onValueChangedMorning(_ sender: Any) {
        if swtMorning.isOn {
            modelAlarm.bMorning = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtMorning.isOn = false
                self.modelAlarm.bMorning = false
            },
            handlerCancel: { alertAction in
                self.swtMorning.isOn = true
                self.modelAlarm.bMorning = true
            }
        )
    }


    @IBAction func onValueChangedEvening(_ sender: Any) {
        if swtEvening.isOn {
            modelAlarm.bEvening = true
            return
        }
        showConfirmDialog(
            handlerOk: { alertAction in
                self.swtEvening.isOn = false
                self.modelAlarm.bEvening = false
            },
            handlerCancel: { alertAction in
                self.swtEvening.isOn = true
                self.modelAlarm.bEvening = true
            }
        )
    }


    func showConfirmDialog(handlerOk: ((UIAlertAction) -> Void)?, handlerCancel: ((UIAlertAction) -> Void)?) {
        showConfirm(
            title  : "Notice".localized(),
            message: "Strongly recommend that you turn on full alert authorisation! Do you really want to turn off alert?".localized(),
            handlerOk    : handlerOk,
            handlerCancel: handlerCancel
        )
    }


    func trySetAlarmSetInfo() {
        var stReq: StReqSetAlarmSetInfo = StReqSetAlarmSetInfo()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.sos_status            = modelAlarm.bWatchSos    ? "true" : "false"
        stReq.fire_status           = modelAlarm.bSensorAlarm ? "true" : "false"
        stReq.watch_net_status      = modelAlarm.bWatchNet    ? "true" : "false"
        stReq.fire_net_status       = modelAlarm.bSensorNet   ? "true" : "false"
        stReq.heart_rate_status     = modelAlarm.bHeart       ? "true" : "false"
        stReq.watch_battery_status  = modelAlarm.bWatchPower  ? "true" : "false"
        stReq.fire_battery_status   = modelAlarm.bSensorPower ? "true" : "false"
        stReq.electron_fence_status = modelAlarm.bFence       ? "true" : "false"
        stReq.morning_status        = modelAlarm.bMorning     ? "true" : "false"
        stReq.evening_status        = modelAlarm.bEvening     ? "true" : "false"

        API.instance.setAlarmSetInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }

}
