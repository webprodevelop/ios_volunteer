import Foundation

class ModelAppInfo {
    var sAgreement : String = ""
    var sPolicy    : String = ""
    var sFreeWatch : String = ""
    var sFreeYanGan: String = ""
    var sFreeRanQi : String = ""
    var sPayWatch  : String = ""
    var sPayYanGan : String = ""
    var sPayRanQi  : String = ""
    var sBirthDesc : String = ""
    var sAppVerIos  : String = "0"
    var sStoreUrlIos: String = ""


    func copyFromApiData(data: StRspGetAppInfoData) {
        sAgreement  = data.agreement        ?? ""
        sPolicy     = data.policy           ?? ""
        sFreeWatch  = data.watch_free_days  ?? ""
        sFreeYanGan = data.yangan_free_days ?? ""
        sFreeRanQi  = data.ranqi_free_days  ?? ""
        sPayWatch   = data.watch_pay?.joined( separator: ",") ?? ""
        sPayYanGan  = data.yangan_pay?.joined(separator: ",") ?? ""
        sPayRanQi   = data.ranqi_pay?.joined( separator: ",") ?? ""
        sBirthDesc  = data.user_birth_desc  ?? ""
        sAppVerIos   = data.appVersion?.app_ver_ios ?? "0"
        sStoreUrlIos = data.appVersion?.store_url_ios ?? ""
    }

}
