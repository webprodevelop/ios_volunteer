import Foundation

class ModelFence: Equatable {

    var sName: String? = ""
    var sAddr: String? = ""
    var sLat : String? = String(Config.DEFAULT_LAT)
    var sLon : String? = String(Config.DEFAULT_LON)
    var iRadius: Int? = 300
    var periods: [ModelPeriod] = [ModelPeriod]()


    static func == (lhs: ModelFence, rhs: ModelFence) -> Bool {
        if lhs.sName != rhs.sName { return false }
        if lhs.sAddr != rhs.sAddr { return false }
        if lhs.sLat  != rhs.sLat  { return false }
        if lhs.sLon  != rhs.sLon  { return false }
        if lhs.iRadius != rhs.iRadius { return false }
        return true
    }


    func copyFromApiData(data: StElecFenceInfoData) {
        sName = data.name
        sAddr = data.address
        sLat  = data.lat
        sLon  = data.lon
        iRadius = data.radius
        let sPeriods = data.guardtime_list?.split(separator: ",").map{ String($0) } ?? [String]()
        for sPeriod in sPeriods {
            let period = ModelPeriod()
            period.copyFromString(data: sPeriod)
            periods.append(period)
        }
    }


    func stringPeriods() -> String {
        var sPeriods = ""
        for period in periods {
            sPeriods = sPeriods + period.sStart + "-" + period.sEnd + ","
        }
        if sPeriods.count > 0 {
            sPeriods = String(sPeriods.prefix(sPeriods.count - 1))  // Remove Last Comma
        }
        return sPeriods
    }

}
