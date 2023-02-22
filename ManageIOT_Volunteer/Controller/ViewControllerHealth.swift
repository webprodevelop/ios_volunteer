import Foundation
import UIKit

class ViewControllerHealth: UIViewController {

    @IBOutlet weak var btnWatch: UIButton!
    @IBOutlet weak var btnDate : UIButton!
    @IBOutlet weak var btnPrev : UIButton!
    @IBOutlet weak var btnNext : UIButton!
    @IBOutlet weak var lblRateRecent : UILabel!
    @IBOutlet weak var lblRateMax    : UILabel!
    @IBOutlet weak var lblRateMin    : UILabel!
    @IBOutlet weak var lblDateUpdated: UILabel!
    @IBOutlet weak var lblRateNormal : UILabel!
    @IBOutlet weak var lblNoData     : UILabel!
    @IBOutlet weak var btnAbnormal: UIButton!
    @IBOutlet weak var viewGraph: ViewGraph!

    var iRateRecent  : Int = 0
    var iRateMax     : Int = 0
    var iRateMin     : Int = 0
    var sDateUpdated : String = ""
    var sDateSelected: String = ""
    var dateToday    : Date = Date()
    var dateSelected : Date = Date()
    var dicRates = [Int: Float]()  // TimeInterval since Begining of the Day : Heart Rate Value
    var iCountUnreadRates: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Init Values
        dateToday    = dateSelected.beginningOfDay
        dateSelected = dateSelected.beginningOfDay

        if Config.id_watch_monitoring <= 0 { return }
        if isBeforeDay(sDate: Config.modelWatchMonitoring.sServiceEnd) { return }

        tryGetHeartRateHistory()
    }


    func updateUi() {
        var sRateNormal: String = "Normal Rate".localized() + ": "
        sRateNormal = sRateNormal + String(Config.modelWatchMonitoring.iHeartRateLow) + "~"
        sRateNormal = sRateNormal + String(Config.modelWatchMonitoring.iHeartRateHigh) + " " + "t/m".localized()
        lblRateNormal.text  = sRateNormal
        if iRateRecent <= 0 {
            lblRateRecent.text = "-"
        }
        else {
            lblRateRecent.text  = String(iRateRecent)
        }
        lblDateUpdated.text = "Updated".localized() + ": " + sDateUpdated
        btnWatch.setTitle(Config.modelWatchMonitoring.sUserName + " >", for: .normal)

        if iCountUnreadRates == 0 {
            btnAbnormal.isHidden = true
        }
        else {
            btnAbnormal.isHidden = false
            btnAbnormal.setTitle(String(iCountUnreadRates), for: .normal)
        }
        updateBtnDate()
        updateData()
        updateGraph()
    }


    @IBAction func onTouchUpWatch(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Watch", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerWatch") as! ViewControllerWatch
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }


    @IBAction func onTouchUpWeather(_ sender: Any) {
        API.instance.getWeatherInfo(completion: { result in
            switch result {
                case let .success(data):
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                        let code = jsonData["code"] as! String

                        var temperCurrent = ""
                        var temperMax = ""
                        var temperMin = ""
                        var condition = ""
                        var district  = ""
                        var datetime  = ""
                        var qlty = ""
                        var aqi  = ""
                        var condCode = ""
                        var msg  = ""

                        if code != "10000" {
                            msg = jsonData["msg"] as! String
                        }
                        else {
                            let dicResult  = jsonData["result"]      as! [String:Any]
                            let dicWeather = dicResult["HeWeather5"] as! [[String:Any]]
                            let dicNow     = dicWeather[0]["now"]    as! [String:Any]
                            let dicAqi     = dicWeather[0]["aqi"]    as! [String:Any]
                            let dicBasic   = dicWeather[0]["basic"]  as! [String:Any]
                            let dicDaily   = dicWeather[0]["daily_forecast"] as! [[String:Any]]
                            let dicCond    = dicNow["cond"]     as! [String:String]
                            let dicCity    = dicAqi["city"]     as! [String:String]
                            let dicUpdate  = dicBasic["update"] as! [String:String]
                            let dicToday   = dicDaily[0]["tmp"] as! [String:String]

                            temperCurrent = dicNow["tmp"]    as! String
                            temperMax     = dicToday["max"]!
                            temperMin     = dicToday["min"]!
                            condition     = dicCond["txt"]!
                            condCode      = dicCond["code"]!
                            aqi           = dicCity["aqi"]!
                            qlty          = dicCity["qlty"]!
                            district      = dicBasic["city"] as! String
                            datetime      = dicUpdate["loc"]!
                        }
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Weather", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerWeather") as! ViewControllerWeather
                            vc.modalPresentationStyle = .overCurrentContext
                            vc.temperCurrent = temperCurrent
                            vc.temperMax     = temperMax
                            vc.temperMin     = temperMin
                            vc.condition     = condition
                            vc.condCode      = condCode
                            vc.aqi           = aqi
                            vc.qlty          = qlty
                            vc.district      = district
                            vc.datetime      = datetime
                            vc.msg           = msg
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    catch {
                    }

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        })
    }


    @IBAction func onTouchUpDate(_ sender: Any) {
        //let selector = WWCalendarTimeSelector.instantiate()
        let selector = UIStoryboard(
            name  : "WWCalendarTimeSelector",
            bundle: nil
        ).instantiateInitialViewController() as! WWCalendarTimeSelector
        selector.delegate = self
        present(selector, animated: true, completion: nil)
    }


    @IBAction func onTouchUpPrev(_ sender: Any) {
        dateSelected.addTimeInterval(-86400)
        updateBtnDate()
        updateData()
        updateGraph()
    }


    @IBAction func onTouchUpNext(_ sender: Any) {
        dateSelected.addTimeInterval(86400)
        updateBtnDate()
        updateData()
        updateGraph()
    }


    @IBAction func onTouchUpAdvice(_ sender: Any) {
        Config.setTimeLastHeartRate(value: sDateUpdated)
        DispatchQueue.main.async {
            self.btnAbnormal.isHidden = true
        }
        let storyboard = UIStoryboard(name: "Rate", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerRate")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }


    func updateBtnDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        sDateSelected = formatter.string(from: dateSelected)
        btnDate.setTitle(sDateSelected, for: .normal)
        if dateSelected >= dateToday {
            btnNext.isEnabled = false
        }
        else {
            btnNext.isEnabled = true
        }
    }


    func updateData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        iRateMax = 0
        iRateMin = 0
        dicRates.removeAll()
        let modelRates = DbManager.instance.loadRates(date: sDateSelected)
        for modelRate in modelRates {
            let sDateTime = modelRate.sDate + " " + modelRate.sTime
            let date = formatter.date(from: sDateTime) ?? Date()
            let interval = Int(date.timeIntervalSince(dateSelected))
            dicRates[interval] = Float(modelRate.iValue)
            if iRateMax == 0 { iRateMax = modelRate.iValue }
            if iRateMin == 0 { iRateMin = modelRate.iValue }
            if iRateMax < modelRate.iValue { iRateMax = modelRate.iValue }
            if iRateMin > modelRate.iValue { iRateMin = modelRate.iValue }
        }
        DispatchQueue.main.async {
            var rate = "-"
            if self.iRateMax > 0 { rate = String(self.iRateMax) }
            self.lblRateMax.text = rate + " " + "t/m".localized()
            rate = "-"
            if self.iRateMin > 0 { rate = String(self.iRateMin) }
            self.lblRateMin.text = rate + " " + "t/m".localized()
        }
    }


    func updateGraph() {
        DispatchQueue.main.async {
            if self.dicRates.count <= 0 {
                self.lblNoData.isHidden = false
            }
            else {
                self.lblNoData.isHidden = true
            }
        }
        viewGraph.dicValues = dicRates
        viewGraph.limitLower = CGFloat(Config.modelWatchMonitoring.iHeartRateLow)
        viewGraph.limitUpper = CGFloat(Config.modelWatchMonitoring.iHeartRateHigh)
        viewGraph.setNeedsDisplay()
    }


    func tryGetHeartRateHistory() {
        var stReq: StReqGetHeartRateHistory = StReqGetHeartRateHistory()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id     = Config.id_watch_monitoring
        _ = DbManager.instance.deleteRates()
        API.instance.getHeartRateHistory(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    let sTimeLastHeartRate = Config.getTimeLastHeartRate()
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    for data in stRsp.data ?? [] {
                        let modelRate = ModelRate()
                        modelRate.copyFromApiData(data: data)
                        if !DbManager.instance.insertRate(model: modelRate) {
                            DbManager.instance.updateRate(model: modelRate)
                        }
                        let sDateTime = "\(modelRate.sDate) \(modelRate.sTime)"
                        if self.sDateUpdated < sDateTime {
                            self.sDateUpdated = sDateTime
                            self.iRateRecent = modelRate.iValue
                        }
                        if sTimeLastHeartRate < sDateTime {
                            self.iCountUnreadRates = self.iCountUnreadRates + 1
                        }
                    }

                    DispatchQueue.main.async {
                        self.updateUi()
                    }

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }

}


extension ViewControllerHealth: WWCalendarTimeSelectorProtocol {
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
        if date > dateToday {
            dateSelected = dateToday
        }
        else {
            dateSelected = date
        }
        updateBtnDate()
        updateData()
        updateGraph()

    }
}


extension ViewControllerHealth: ViewControllerWatchDelegate {
    func onWatchSuccess() {
        updateUi()
    }
}


extension ViewControllerHealth: ViewControllerRangeDelegate {
    func onRangeSuccess() {
        updateGraph()
    }
}
