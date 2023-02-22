import UIKit


protocol CellDeviceDelegate: AnyObject {
    func onDeviceTouchUpSetting(type: DeviceType, model: Any?)
    func onDeviceTouchUpDelete(type: DeviceType, model: Any?)
    func onDeviceTouchUpDefer(type: DeviceType, model: Any?)
}


class CellDevice: UICollectionViewCell {

    @IBOutlet weak var lblName   : UILabel!
    @IBOutlet weak var lblSerial : UILabel!
    @IBOutlet weak var lblPhone  : UILabel!
    @IBOutlet weak var lblStatus1: UILabel!
    @IBOutlet weak var lblStatus2: UILabel!
    @IBOutlet weak var lblExpiry : UILabel!
    @IBOutlet weak var lblTitleStatus1: UILabel!
    @IBOutlet weak var lblTitleStatus2: UILabel!
    @IBOutlet weak var imgDevice : UIImageView!
    @IBOutlet weak var btnDefer  : UIButton!

    var type : DeviceType = .SmartWatch
    var model: Any? = nil
    var delegate: CellDeviceDelegate? = nil


    func updateForSmartWatch(modelWatch: ModelWatch) {
        type  = .SmartWatch
        model = modelWatch
        lblTitleStatus1.text = "Network :".localized()
        lblTitleStatus2.text = "Battery :".localized()
        lblName.text    = modelWatch.sUserName
        lblSerial.text  = modelWatch.sSerial
        lblPhone.text   = modelWatch.sUserPhone
        lblStatus1.text = modelWatch.bNetStatus ? "Normal".localized() : "Offline".localized()
        lblStatus1.textColor = modelWatch.bNetStatus ? UIColor.green : UIColor.red
        lblStatus2.text = "\(modelWatch.iChargeStatus)%"
        if modelWatch.bNetStatus {
            if modelWatch.iChargeStatus > 50 {
                lblStatus2.textColor = UIColor.green
            }
            else if modelWatch.iChargeStatus > 30 {
                lblStatus2.textColor = UIColor.orange
            }
            else {
                lblStatus2.textColor = UIColor.red
            }
        }
        else {
            lblStatus2.textColor = UIColor.black
        }
        lblExpiry.text  = modelWatch.sServiceStart + "~" + modelWatch.sServiceEnd
        imgDevice.image = UIImage(named: "img_smartwatch")
        updateBtnDefer(sDateEnd: modelWatch.sServiceEnd)
    }


    func updateForFireSensor(modelSensor: ModelSensor) {
        type  = .FireSensor
        model = modelSensor
        lblTitleStatus1.text = "Power :".localized()
        lblTitleStatus2.text = "Alarm :".localized()
        lblName.text   = modelSensor.sContactName
        lblSerial.text = modelSensor.sSerial
        lblPhone.text  = modelSensor.sContactPhone
        if modelSensor.bNetStatus {
            lblStatus1.text = modelSensor.bBatteryStatus ? "Normal".localized() : "Low power".localized()
            lblStatus2.text = modelSensor.bAlarmStatus ? "Alarmed".localized() : "Not alarmed".localized()
            lblStatus1.textColor = modelSensor.bBatteryStatus ? UIColor.green : UIColor.orange
            lblStatus2.textColor = modelSensor.bAlarmStatus ? UIColor.red : UIColor.green
        }
        else {
            lblStatus1.text = "Offline".localized()
            lblStatus2.text = "Unknown".localized()
            lblStatus1.textColor = UIColor.red
            lblStatus2.textColor = UIColor.black
        }
        lblExpiry.text  = modelSensor.sServiceStart + "~" + modelSensor.sServiceEnd
        imgDevice.image = UIImage(named: "img_firesensor2")
        updateBtnDefer(sDateEnd: modelSensor.sServiceEnd)
    }


    func updateForSmokeSensor(modelSensor: ModelSensor) {
        type  = .SmokeSensor
        model = modelSensor
        lblTitleStatus1.text = "Power :".localized()
        lblTitleStatus2.text = "Alarm :".localized()
        lblName.text   = modelSensor.sContactName
        lblSerial.text = modelSensor.sSerial
        lblPhone.text  = modelSensor.sContactPhone
        if modelSensor.bNetStatus {
            lblStatus1.text = modelSensor.bBatteryStatus ? "Normal".localized() : "Low power".localized()
            lblStatus2.text = modelSensor.bAlarmStatus ? "Alarmed".localized() : "Not alarmed".localized()
            lblStatus1.textColor = modelSensor.bBatteryStatus ? UIColor.green : UIColor.orange
            lblStatus2.textColor = modelSensor.bAlarmStatus ? UIColor.red : UIColor.green
        }
        else {
            lblStatus1.text = "Offline".localized()
            lblStatus2.text = "Unknown".localized()
            lblStatus1.textColor = UIColor.red
            lblStatus2.textColor = UIColor.black
        }
        lblExpiry.text  = modelSensor.sServiceStart + "~" + modelSensor.sServiceEnd
        imgDevice.image = UIImage(named: "img_smokesensor")
        updateBtnDefer(sDateEnd: modelSensor.sServiceEnd)
    }


    @IBAction func onTouchUpSetting(_ sender: Any) {
        delegate?.onDeviceTouchUpSetting(type: type, model: model)
    }


    @IBAction func onTouchUpDelete(_ sender: Any) {
        delegate?.onDeviceTouchUpDelete(type: type, model: model)
    }


    @IBAction func onTouchUpDefer(_ sender: Any) {
        delegate?.onDeviceTouchUpDefer(type: type, model: model)
    }


    func updateBtnDefer(sDateEnd: String) {
        if isWithinOneMonth(sDate: sDateEnd) {
            btnDefer.setTitle("Defer".localized(), for: .normal)
        }
        else {
            btnDefer.setTitle("Detail".localized(), for: .normal)
        }
    }
}
