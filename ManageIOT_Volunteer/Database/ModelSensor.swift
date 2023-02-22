import Foundation

class ModelSensor {
    var bIsManager    : Bool   = false
    var iId           : Int    = 0
    var sType         : String = Config.PREFIX_FIRESENSOR
    var sSerial       : String = ""
    var bNetStatus    : Bool   = false
    var bBatteryStatus: Bool   = false
    var bAlarmStatus  : Bool   = false
    var sLabel        : String = ""
    var sContactName  : String = ""
    var sContactPhone : String = ""
    var sLat          : String = ""
    var sLon          : String = ""
    var sProvince     : String = ""
    var sCity         : String = ""
    var sDistrict     : String = ""
    var sAddress      : String = ""
    var sServiceStart : String = ""
    var sServiceEnd   : String = ""


    func copyFromApiData(data: StRspGetSensorListData) {
        bIsManager     = data.is_manager     ?? false
        iId            = data.id             ?? 0
        sType          = data.type           ?? Config.PREFIX_FIRESENSOR
        sSerial        = data.serial         ?? ""
        bNetStatus     = data.net_status     ?? false
        bBatteryStatus = data.battery_status ?? false
        bAlarmStatus   = data.alarm_status   ?? false
        sLabel         = data.label          ?? ""
        sContactName   = data.contact_name   ?? ""
        sContactPhone  = data.contact_phone  ?? ""
        sLat           = data.lat            ?? ""
        sLon           = data.lon            ?? ""
        sProvince      = ""
        sCity          = ""
        sDistrict      = ""
        sAddress       = data.address        ?? ""
        sServiceStart  = data.service_start  ?? ""
        sServiceEnd    = data.service_end    ?? ""
    }

}
