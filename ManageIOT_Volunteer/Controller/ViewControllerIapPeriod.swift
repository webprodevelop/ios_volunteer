import UIKit
import WebKit

class ViewControllerIapPeriod: UIViewController {

    @IBOutlet weak var txtLen1: UITextField!
    @IBOutlet weak var txtLen2: UITextField!
    @IBOutlet weak var txtLen3: UITextField!
    @IBOutlet weak var txtLen4: UITextField!
    @IBOutlet weak var txtLen5: UITextField!

    @IBOutlet weak var lblPeriod: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var btnWechat: UIButton!
    @IBOutlet weak var btnAlipay: UIButton!
    @IBOutlet weak var lblResult: UILabel!

    var type : DeviceType = .SmartWatch
    var model: Any? = nil
    var iItemType: Int = 0   // 0: SmartWatch, 1: FireSensor, 2: SmokeSensor
    var iItemId  : Int = 0
    var iPeriod  : Int = 1
    var iPayType : Int = 1   // 1: Wechat, 0: Alipay
    var sCost    : String = "0"
    var sDateStart: String = ""
    var sDateEnd  : String = ""
    var dateStart: Date = Date()
    var dateEnd  : Date = Date()

    let formatter: DateFormatter = DateFormatter()

    var arrCostWatch : [String] = [String]()
    var arrCostYangan: [String] = [String]()
    var arrCostRanqi : [String] = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()

        lblResult.isHidden = true

        formatter.dateFormat = "yyyy-MM-dd"

        //-- Init UI
        let tapLen1 = UITapGestureRecognizer(target: self, action: #selector(onTapLen1(_:)))
        let tapLen2 = UITapGestureRecognizer(target: self, action: #selector(onTapLen2(_:)))
        let tapLen3 = UITapGestureRecognizer(target: self, action: #selector(onTapLen3(_:)))
        let tapLen4 = UITapGestureRecognizer(target: self, action: #selector(onTapLen4(_:)))
        let tapLen5 = UITapGestureRecognizer(target: self, action: #selector(onTapLen5(_:)))
        txtLen1.addGestureRecognizer(tapLen1)
        txtLen2.addGestureRecognizer(tapLen2)
        txtLen3.addGestureRecognizer(tapLen3)
        txtLen4.addGestureRecognizer(tapLen4)
        txtLen5.addGestureRecognizer(tapLen5)

        //-- Init
        let appInfo = Config.getAppInfo()
        arrCostWatch  = appInfo.sPayWatch .split(separator: ",").map{ String($0) }
        arrCostYangan = appInfo.sPayYanGan.split(separator: ",").map{ String($0) }
        arrCostRanqi  = appInfo.sPayRanQi .split(separator: ",").map{ String($0) }

        switch type {
            case .SmartWatch:
                let modelWatch = model as! ModelWatch
                sDateStart = modelWatch.sServiceStart
                sDateEnd   = modelWatch.sServiceEnd
                iItemType = 0
                iItemId   = modelWatch.iId
                break
            case .FireSensor:
                let modelSensor = model as! ModelSensor
                sDateStart = modelSensor.sServiceStart
                sDateEnd   = modelSensor.sServiceEnd
                iItemType = 1
                iItemId   = modelSensor.iId
                break
            case .SmokeSensor:
                let modelSensor = model as! ModelSensor
                sDateStart = modelSensor.sServiceStart
                sDateEnd   = modelSensor.sServiceEnd
                iItemType = 2
                iItemId   = modelSensor.iId
                break
        }

        if isBeforeDay(sDate: sDateEnd) {
            let date = Date()
            sDateStart = formatter.string(from: date)
        }
        dateStart = formatter.date(from: sDateStart) ?? Date()
        updateDateEnd(period: 1)
        lblPeriod.text = sDateStart + " ~ " + sDateEnd
        updateLblAmount(period: 1)
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpContinue(_ sender: Any) {
        launchIapComplete()         // TODO : Delete later
        //tryRequirePaidService()   // TODO : Uncomment later
    }


    @IBAction func onTouchUpWechat(_ sender: Any) {
        DispatchQueue.main.async {
            self.btnWechat.setImage(UIImage(named: "img_check_on"), for: .normal)
            self.btnAlipay.setImage(UIImage(named: "img_check_off"), for: .normal)
        }
        iPayType = 1
    }


    @IBAction func onTouchUpAlipay(_ sender: Any) {
        DispatchQueue.main.async {
            self.btnWechat.setImage(UIImage(named: "img_check_off"), for: .normal)
            self.btnAlipay.setImage(UIImage(named: "img_check_on"), for: .normal)
        }
        iPayType = 0
    }


    @IBAction func onEditBeginLen1(_ sender: Any) {
        txtLen1.resignFirstResponder()
    }


    @IBAction func onEditBeginLen2(_ sender: Any) {
        txtLen2.resignFirstResponder()
    }


    @IBAction func onEditBeginLen3(_ sender: Any) {
        txtLen3.resignFirstResponder()
    }


    @IBAction func onEditBeginLen4(_ sender: Any) {
        txtLen4.resignFirstResponder()
    }


    @IBAction func onEditBeginLen5(_ sender: Any) {
        txtLen5.resignFirstResponder()
    }


    @objc func onTapLen1(_ sender: UITapGestureRecognizer? = nil) {
        setViewSelected(textField: txtLen1)
        setViewUnselect(textField: txtLen2)
        setViewUnselect(textField: txtLen3)
        setViewUnselect(textField: txtLen4)
        setViewUnselect(textField: txtLen5)
        txtLen1.resignFirstResponder()

        updateLblAmount(period: 1)
        updateDateEnd(period: 1)
        iPeriod = 1
    }


    @objc func onTapLen2(_ sender: UITapGestureRecognizer? = nil) {
        setViewUnselect(textField: txtLen1)
        setViewSelected(textField: txtLen2)
        setViewUnselect(textField: txtLen3)
        setViewUnselect(textField: txtLen4)
        setViewUnselect(textField: txtLen5)
        txtLen2.resignFirstResponder()

        updateLblAmount(period: 2)
        updateDateEnd(period: 2)
        iPeriod = 2
    }


    @objc func onTapLen3(_ sender: UITapGestureRecognizer? = nil) {
        setViewUnselect(textField: txtLen1)
        setViewUnselect(textField: txtLen2)
        setViewSelected(textField: txtLen3)
        setViewUnselect(textField: txtLen4)
        setViewUnselect(textField: txtLen5)
        txtLen3.resignFirstResponder()

        updateLblAmount(period: 3)
        updateDateEnd(period: 3)
        iPeriod = 3
    }


    @objc func onTapLen4(_ sender: UITapGestureRecognizer? = nil) {
        setViewUnselect(textField: txtLen1)
        setViewUnselect(textField: txtLen2)
        setViewUnselect(textField: txtLen3)
        setViewSelected(textField: txtLen4)
        setViewUnselect(textField: txtLen5)
        txtLen4.resignFirstResponder()

        updateLblAmount(period: 4)
        updateDateEnd(period: 4)
        iPeriod = 4
    }


    @objc func onTapLen5(_ sender: UITapGestureRecognizer? = nil) {
        setViewUnselect(textField: txtLen1)
        setViewUnselect(textField: txtLen2)
        setViewUnselect(textField: txtLen3)
        setViewUnselect(textField: txtLen4)
        setViewSelected(textField: txtLen5)
        txtLen5.resignFirstResponder()

        updateLblAmount(period: 5)
        updateDateEnd(period: 5)
        iPeriod = 5
    }


    func setViewSelected(textField: UITextField) {
        DispatchQueue.main.async {
            textField.backgroundColor = UIColor(red: 39/255.0, green: 177/255.0, blue: 72/255.0, alpha: 1.0)
            textField.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }


    func setViewUnselect(textField: UITextField) {
        DispatchQueue.main.async {
            textField.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            textField.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        }
    }

    func launchIapComplete() {
        let storyboard = UIStoryboard(name: "IapComplete", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerIapComplete")
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: false)
    }


    func updateLblAmount(period: Int) {
        switch type {
            case .SmartWatch:
                if arrCostWatch.count == 0 { break }
                if period > arrCostWatch.count {
                    sCost = arrCostWatch[arrCostWatch.count - 1]
                }
                else {
                    sCost = arrCostWatch[period - 1]
                }
                break
            case .FireSensor:
                if arrCostYangan.count == 0 { break }
                if period > arrCostYangan.count {
                    sCost = arrCostYangan[arrCostYangan.count - 1]
                }
                else {
                    sCost = arrCostYangan[period - 1]
                }
                break
            case .SmokeSensor:
                if arrCostRanqi.count == 0 { break }
                if period > arrCostRanqi.count {
                    sCost = arrCostRanqi[arrCostRanqi.count - 1]
                }
                else {
                    sCost = arrCostRanqi[period - 1]
                }
                break
        }
        lblAmount.text = sCost + " " + "RMB".localized()
    }


    func updateDateEnd(period: Int) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year  = period
        dateComponents.month = 0
        dateComponents.day   = 0
        dateEnd = calendar.date(byAdding: dateComponents, to: dateStart) ?? Date()
        sDateEnd = formatter.string(from: dateEnd)

        lblPeriod.text = sDateStart + " ~ " + sDateEnd
    }


    func tryRequirePaidService() {
        var stReq = StReqRequestPaidService()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile
        stReq.item_type = iItemType
        stReq.item_id   = iItemId
        stReq.service_years = iPeriod
        stReq.service_start = sDateStart
        stReq.service_end   = sDateEnd
        stReq.amount    = Int(sCost) ?? 0
        stReq.pay_type  = iPayType

        API.instance.requestPaidService(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    self.launchIapComplete()
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }

}
