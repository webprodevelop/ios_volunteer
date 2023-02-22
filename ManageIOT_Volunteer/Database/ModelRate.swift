import Foundation

class ModelRate {
    var sUid       : String = "" // DATE + " " + Time + " " + iWatch
    var iWatch     : Int    = 0
    var sDate      : String = ""
    var sTime      : String = ""
    var iValue     : Int    = 0


    func copyFromApiData(data: StRspGetHeartRateHistoryData) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: data.check_time ?? "") ?? Date()
        formatter.dateFormat = "yyyy-MM-dd"
        sDate  = formatter.string(from: date)
        formatter.dateFormat = "HH:mm:ss"
        sTime  = formatter.string(from: date)
        iValue = Int(data.heart_rate ?? "0") ?? 0

        iWatch = Config.id_watch_monitoring
        sUid = "\(sDate) \(sTime) \(iWatch)"
    }
}
