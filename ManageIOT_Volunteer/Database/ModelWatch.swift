import Foundation

class ModelWatch {
    var bIsManager       : Bool   = false
    var iId              : Int    = 0
    var sSerial          : String = ""
    var sUserName        : String = ""
    var sUserPhone       : String = ""
    var iUserSex         : Int    = 1
    var sUserBirth       : String = ""
    var iUserTall        : Int    = 0
    var iUserWeight      : Int    = 0
    var sUserBlood       : String = Config.BLOOD_O
    var sUserIllHistory  : String = ""
    var sLat             : String = "0"
    var sLon             : String = "0"
    var sProvince        : String = ""
    var sCity            : String = ""
    var sDistrict        : String = ""
    var sAddress         : String = ""
    var sServiceStart    : String = ""
    var sServiceEnd      : String = ""
    var bNetStatus       : Bool   = false
    var iChargeStatus    : Int    = 0
    var sSosContactName1 : String = ""
    var sSosContactName2 : String = ""
    var sSosContactName3 : String = ""
    var sSosContactPhone1: String = ""
    var sSosContactPhone2: String = ""
    var sSosContactPhone3: String = ""
    var iHeartRateHigh   : Int    = 100
    var iHeartRateLow    : Int    = 60
    var iPosUpdateMode   : Int    = 1


    func copyFromApiData(data: StRspGetWatchListData) {
        bIsManager        = data.is_manager         ?? false
        iId               = data.id                 ?? 0
        sSerial           = data.serial             ?? ""
        sUserName         = data.user_name          ?? ""
        sUserPhone        = data.user_phone         ?? ""
        iUserSex          = data.user_sex           ?? 1
        sUserBirth        = data.user_birthday      ?? ""
        iUserTall         = data.user_tall          ?? 0
        iUserWeight       = data.user_weight        ?? 0
        sUserBlood        = data.user_blood         ?? ""
        sUserIllHistory   = data.user_ill_history   ?? ""
        sLat              = data.lat                ?? ""
        sLon              = data.lon                ?? ""
        sProvince         = ""
        sCity             = ""
        sDistrict         = ""
        sAddress          = data.address            ?? ""
        sServiceStart     = data.service_start      ?? ""
        sServiceEnd       = data.service_end        ?? ""
        bNetStatus        = data.net_status         ?? false
        iChargeStatus     = data.charge_status      ?? 0
        sSosContactName1  = data.sos_contact1_name  ?? ""
        sSosContactName2  = data.sos_contact2_name  ?? ""
        sSosContactName3  = data.sos_contact3_name  ?? ""
        sSosContactPhone1 = data.sos_contact1_phone ?? ""
        sSosContactPhone2 = data.sos_contact2_phone ?? ""
        sSosContactPhone3 = data.sos_contact3_phone ?? ""
        iHeartRateHigh    = data.heart_rate_high    ?? 0
        iHeartRateLow     = data.heart_rate_low     ?? 0
        iPosUpdateMode    = data.pos_update_mode    ?? 0

        if iUserSex < 0 { iUserSex = 1 } // Default Value in Backend is -1
    }
}
