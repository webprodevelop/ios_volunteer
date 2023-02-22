import Foundation
import SwiftyJSON

//-- StReqGeoConv
struct StReqGeoConv: Encodable {
    /// "to" parameter must be same with parameter value of
    /// BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK()
    var coords: String = ""
    var from  : Int = 1     /// 1: WGS84, 3: GCJ02
    var to    : Int = 5     /// 5: BD09LL, 6: BD09MC
    var ak    : String = ""
    var mcode : String = "com.iot.volunteer"
}

struct StRspGeoConvResult: Decodable {
    var x: Double? = 0
    var y: Double? = 0
}

struct StRspGeoConv: Decodable {
    var status: Int? = -1
    var result: [StRspGeoConvResult]? = [StRspGeoConvResult]()
}


//-- Get AppInfo
struct StReqGetAppInfo: Encodable {
    let pAct: String = "getAppInfo"
}

struct StRspGetAppVersionData: Decodable {
    var app_ver_ios : String? = "0"
    var store_url_ios: String? = "0"
}

struct StRspGetAppInfoData: Decodable {
    var agreement       : String? = ""
    var policy          : String? = ""
    var watch_free_days : String? = ""
    var yangan_free_days: String? = ""
    var ranqi_free_days : String? = ""
    var watch_pay       : [String]? = [String]()
    var yangan_pay      : [String]? = [String]()
    var ranqi_pay       : [String]? = [String]()
    var user_birth_desc : String? = ""
    var user_health_desc : String? = ""
    var user_health_phone: String? = ""
    var appVersion: StRspGetAppVersionData? = StRspGetAppVersionData()
}

struct StRspGetAppInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetAppInfoData? = StRspGetAppInfoData()
}


//-- UserInfo
struct StRspUserInfo: Decodable {
    var token          : String? = ""
    var name           : String? = ""
    var mobile         : String? = ""
    var sex            : Int?    = 0
    var birthday       : String? = ""
    var company        : String? = ""
    var job            : String? = ""
    var residence      : String? = ""
    var address        : String? = ""
    var province       : String? = ""
    var city           : String? = ""
    var district       : String? = ""
    var picture        : String? = ""
    var certificate    : String? = ""
    var certificate_pic: String? = ""
    var id_card_num    : String? = ""
    var id_card_front  : String? = ""
    var id_card_back   : String? = ""
    var bank_account_name  : String? = ""
    var bank_account_id    : String? = ""     /// bank_card
    var bank_account_pwd   : String? = ""
    var weixin_account_name: String? = ""
    var weixin_account_id  : String? = ""
    var alipay_account_name: String? = ""
    var alipay_account_id  : String? = ""
    var point      : String? = ""
    var cash       : String? = ""
    var balance    : String? = ""
    var point_level: String? = ""
    var task_id    : Int? = 0
    var status     : String? = ""
}


//-- Login
struct StReqLogin: Encodable {
    let pAct    : String = "login"
    var mobile  : String = ""
    var password: String = ""
    var registration_id: String = ""
}

struct StRspLogin: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}


//-- Code
struct StReqCode: Encodable {
    let pAct  : String = "getVerifyCode"
    var mobile: String = ""
}

struct StRspCodeData: Decodable {
    var verify_code: String? = ""
}

struct StRspCode: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspCodeData? = StRspCodeData()
}


//-- Update User Info Code
struct StReqUpdateUserInfoCode: Encodable {
    let pAct  : String = "getUpdateUserInfoVerifyCode"
    var mobile: String = ""
}

struct StRspUpdateUserInfoCodeData: Decodable {
    var verify_code: String? = ""
}

struct StRspUpdateUserInfoCode: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUpdateUserInfoCodeData? = StRspUpdateUserInfoCodeData()
}


//-- Register
struct StReqRegister: Encodable {
    let pAct       : String = "register"
    var mobile     : String = ""
    var password   : String = ""
    var verify_code: String = ""
}


struct StRspRegister: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}


//-- Forgot
struct StReqForgot: Encodable {
    let pAct       : String = "forgotPassword"
    var mobile     : String = ""
    var password   : String = ""
    var verify_code: String = ""
}

struct StRspForgot: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}


//-- Reset Password
struct StReqResetPassword: Encodable {
    let pAct  : String = "resetPassword"
    var token : String = ""
    var mobile: String = ""
    var old_password: String = ""
    var new_password: String = ""
    var verify_code : String = ""
}

struct StRspResetPassword: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}


//-- Update UserInfo
struct StReqUpdateUserInfo: Encodable {
    let pAct     : String = "updateUserInfo"
    var token    : String = ""
    var mobile   : String = ""
    var name     : String = ""
    var sex      : Int    = 1
    var birthday : String = ""
    var address  : String = ""
    var id_card_num: String = ""
    var residence: String = ""
    var phone    : String = ""
    var company  : String = ""
    var job      : String = ""
//    var weixin_id: String = ""
//    var qq_id    : String = ""
//    var email    : String = ""
    var picture_src: String = ""
    var id_card_front_src: String = ""
    var id_card_back_src : String = ""
    var certificate_src  : String = ""
}

struct StRspUpdateUserInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}


//-- Get UserInfo
struct StReqGetUserInfo: Encodable {
    let pAct  : String = "getUserInfo"
    var token : String = ""
    var mobile: String = ""
}

struct StRspGetUserInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}



//-- News Info
struct StRspNewsInfo: Decodable {
    var id              : Int?      = 0
    var readCnt         : Int?      = 0
    var status          : Bool?     = false
    var statusStr       : String?   = ""
    var newsBranch      : String?   = ""      /// "loop_picture", "hot_recommend", "common_sense"
    var title           : String?   = ""
    var content         : String?   = ""
    var picture         : String?   = ""
    var newsType        : String?   = ""
    var publishTo       : String?   = ""
    var updatedTime     : String?   = ""
    var updatedTimeStr  : String?   = ""
    var releaseTime     : String?   = ""
    var releaseTimeStr  : String?   = ""
    var createTime      : String?   = ""
    var createTimeStr   : String?   = ""
    var createDateStr   : String?   = ""
    var updatedDateStr  : String?   = ""
}


//-- Get News List
struct StReqGetNewsList: Encodable {
    let pAct  : String = "getNewsList"
    var mobile: String = ""
    var token : String = ""
    var last_release_time: String = ""
}

struct StRspGetNewsListData: Decodable {
    var loop_picture : [StRspNewsInfo]? = [StRspNewsInfo]()
    var hot_recommend: [StRspNewsInfo]? = [StRspNewsInfo]()
    var common_sense : [StRspNewsInfo]? = [StRspNewsInfo]()
}

struct StRspGetNewsList: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetNewsListData? = StRspGetNewsListData()
}


//-- Get News Info
struct StReqGetNewsInfo: Encodable {
    let pAct  : String = "getNewsInfo"
    var mobile: String = ""
    var token : String = ""
    var id    : Int = 0
}

struct StRspGetNewsInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspNewsInfo? = StRspNewsInfo()
}


//-- Set SOS Contact
struct StReqSetSosContact: Encodable {
    let pAct  : String = "setSosContacts"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
    var sos_contact1_name : String = ""
    var sos_contact1_phone: String = ""
    var sos_contact2_name : String = ""
    var sos_contact2_phone: String = ""
    var sos_contact3_name : String = ""
    var sos_contact3_phone: String = ""
}

struct StRspSetSosContact: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Get WatchSetInfo
struct StReqGetWatchSetInfo: Encodable {
    let pAct  : String = "getWatchSetInfo"
}

struct StRspGetWatchSetInfoData: Decodable {
    var ill_list: [String]? = []
    var watch_birth_desc: String? = ""
}

struct StRspGetWatchSetInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetWatchSetInfoData? = StRspGetWatchSetInfoData()
}


//-- Register Watch
struct StReqRegisterWatch: Encodable {
    let pAct  : String =  "registerWatch"
    var token : String = ""
    var mobile: String = ""
    var serial: String = ""
}

struct StRspRegisterWatchData: Decodable {
    var is_manager      : Bool?     = false
    var id              : Int?      = 0
    var lat             : String?   = ""
    var lon             : String?   = ""
    var address         : String?   = ""
    var net_status      : Bool?     = false
    var service_start   : String?   = ""
    var service_end     : String?   = ""
    var user_name       : String?   = ""
    var user_phone      : String?   = ""
    var user_sex        : Int?      = 0
    var user_birthday   : String?   = ""
    var user_tall       : Int?      = 0
    var user_weight     : Int?      = 0
    var user_blood      : String?   = ""
    var user_ill_history: String?   = ""
    var charge_status   : Int?      = 0
}

struct StRspRegisterWatch: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspRegisterWatchData? = StRspRegisterWatchData()
}


//-- Register Sensor
struct StReqRegisterSensor: Encodable {
    let pAct  : String = "registerSensor"
    var token : String = ""
    var mobile: String = ""
    var serial: String = ""
    var type  : String = Config.PREFIX_FIRESENSOR
}

struct StRspRegisterSensorData: Decodable {
    var is_manager    : Bool   = false
    var id            : Int    = 0
    var lat           : String = ""
    var lon           : String = ""
    var address       : String = ""
    var service_start : String = ""
    var service_end   : String = ""
    var net_status    : Bool   = false
    var type          : String = ""
    var battery_status: Bool   = false
    var alarm_status  : Bool   = false
    var label         : String = ""
    var contact_name  : String = ""
    var contact_phone : String = ""
}

struct StRspRegisterSensor: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspRegisterSensorData? = StRspRegisterSensorData()
}


//-- Set Watch
struct StReqSetWatchInfo: Encodable {
    let pAct            : String = "updateWatchInfo"
    var token           : String = ""
    var mobile          : String = ""
    var id              : Int = 0
    var user_name       : String = ""
    var user_phone      : String = ""
    var user_sex        : Int = 1
    var user_birthday   : String = ""
    var user_tall       : Int = 0
    var user_weight     : Int = 0
    var user_blood      : String = Config.BLOOD_O
    var user_ill_history: String = ""
    var province        : String = ""
    var city            : String = ""
    var district        : String = ""
    var address         : String = ""
    var lat             : String = ""
    var lon             : String = ""
}

struct StRspSetWatchInfoData: Decodable {
    var is_manager        : Bool?   = false
    var id                : Int?    = 0
    var serial            : String? = ""
    var net_status        : Bool?   = false
    var charge_status     : Int?    = 0
    var user_name         : String? = ""
    var user_phone        : String? = ""
    var user_sex          : Int?    = 1
    var user_birthday     : String? = ""
    var user_tall         : Int?    = 0
    var user_weight       : Int?    = 0
    var user_blood        : String? = ""
    var user_ill_history  : String? = ""
    var lat               : String? = ""
    var lon               : String? = ""
    var address           : String? = ""
    var service_start     : String? = ""
    var service_end       : String? = ""
    var sos_contact1_name : String? = ""
    var sos_contact2_name : String? = ""
    var sos_contact3_name : String? = ""
    var sos_contact1_phone: String? = ""
    var sos_contact2_phone: String? = ""
    var sos_contact3_phone: String? = ""
    var heart_rate_high   : Int?    = 0
    var heart_rate_low    : Int?    = 0
}

struct StRspSetWatchInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspSetWatchInfoData? = StRspSetWatchInfoData()
}


//-- Set Sensor
struct StReqSetSensorInfo: Encodable {
    let pAct         : String = "updateSensorInfo"
    var token        : String = ""
    var mobile       : String = ""
    var id           : Int = 0
    var contact_name : String = ""
    var contact_phone: String = ""
    var label        : String = ""
    var verify_code  : String = ""
    var province     : String = ""
    var city         : String = ""
    var district     : String = ""
    var address      : String = ""
    var lon          : String = ""
    var lat          : String = ""
}

struct StRspSetSensorInfoData: Decodable {
    var is_manager    : Bool?   = false
    var id            : Int?    = 0
    var serial        : String? = ""
    var type          : String? = ""
    var lat           : String? = ""
    var lon           : String? = ""
    var address       : String? = ""
    var service_start : String? = ""
    var service_end   : String? = ""
    var net_status    : Bool?   = false
    var battery_status: Bool?   = false
    var alarm_status  : Bool?   = false
    var label         : String? = ""
    var contact_name  : String? = ""
    var contact_phone : String? = ""
}

struct StRspSetSensorInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspSetSensorInfoData? = StRspSetSensorInfoData()
}


//-- Get Watch List
struct StReqGetWatchList: Encodable {
    let pAct  : String = "getWatchList"
    var token : String = ""
    var mobile: String = ""
}

struct StRspGetWatchListData: Decodable {
    var is_manager        : Bool?   = false
    var id                : Int?    = 0
    var serial            : String? = ""
    var user_name         : String? = ""
    var user_phone        : String? = ""
    var user_sex          : Int?    = 1
    var user_birthday     : String? = ""
    var user_tall         : Int?    = 0
    var user_weight       : Int?    = 0
    var user_blood        : String? = Config.BLOOD_O
    var user_ill_history  : String? = ""
    var lat               : String? = ""
    var lon               : String? = ""
    var address           : String? = ""
    var net_status        : Bool?   = false
    var charge_status     : Int?    = 0
    var service_start     : String? = ""
    var service_end       : String? = ""
    var sos_contact1_name : String? = ""
    var sos_contact2_name : String? = ""
    var sos_contact3_name : String? = ""
    var sos_contact1_phone: String? = ""
    var sos_contact2_phone: String? = ""
    var sos_contact3_phone: String? = ""
    var heart_rate_high   : Int?    = 0
    var heart_rate_low    : Int?    = 0
    var pos_update_mode   : Int?    = 0
}

struct StRspGetWatchList: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : [StRspGetWatchListData]? = [StRspGetWatchListData]()
}


//-- Get Sensor List
struct StReqGetSensorList: Encodable {
    let pAct  : String = "getSensorList"
    var token : String = ""
    var mobile: String = ""
    var type  : String = Config.PREFIX_FIRESENSOR
}

struct StRspGetSensorListData: Decodable {
    var is_manager    : Bool?   = false
    var id            : Int?    = 0
    var type          : String? = Config.PREFIX_FIRESENSOR
    var serial        : String? = ""
    var lat           : String? = ""
    var lon           : String? = ""
    var address       : String? = ""
    var net_status    : Bool?   = false
    var battery_status: Bool?   = false
    var alarm_status  : Bool?   = false
    var label         : String? = ""
    var contact_name  : String? = ""
    var contact_phone : String? = ""
    var service_start : String? = ""
    var service_end   : String? = ""
}

struct StRspGetSensorList: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : [StRspGetSensorListData]? = [StRspGetSensorListData]()
}


//-- Del Watch
struct StReqDelWatch: Encodable {
    let pAct  : String = "deleteWatch"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
}

struct StRspDelWatch: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Del Sensor
struct StReqDelSensor: Encodable {
    let pAct  : String = "deleteSensor"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
}

struct StRspDelSensor: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Set Heart Rate
struct StReqSetHeartRate: Encodable {
    let pAct  : String = "setHeartRatePeriod"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
    var heart_rate_high: Int = 0
    var heart_rate_low : Int = 0
}

struct StRspSetHeartRate: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Update Mobile
struct StReqSetMobile: Encodable {
    let pAct  : String = "updateMobile"
    var token : String = ""
    var mobile: String = ""
    var new_mobile : String = ""
    var verify_code: String = ""
}

struct StRspSetMobile: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Get Recent Heart Rate Info
struct StReqGetHeartRateRecent: Encodable {
    let pAct  : String = "getRecentHeartRateInfo"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
}

struct StRspGetHeartRateRecentData: Decodable {
    var heart_rate  : String? = ""
    var max_rate    : String? = ""
    var min_rate    : String? = ""
    var last_updated: String? = ""
}

struct StRspGetHeartRateRecent: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetHeartRateRecentData? = StRspGetHeartRateRecentData()
}


//-- Get Heart Rate History
struct StReqGetHeartRateHistory: Encodable {
    let pAct  : String = "getHeartRateHistory"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
}

struct StRspGetHeartRateHistoryData: Decodable {
    var heart_rate: String? = ""
    var check_time: String? = ""
}

struct StRspGetHeartRateHistory: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : [StRspGetHeartRateHistoryData]? = [StRspGetHeartRateHistoryData]()
}


//-- Get Alarm Set Info
struct StReqGetAlarmSetInfo: Encodable {
    let pAct  : String = "getAlarmSetInfo"
    var token : String = ""
    var mobile: String = ""
}

struct StRspGetAlarmSetInfoData: Decodable {
    var sos_status           : Bool? = false
    var fire_status          : Bool? = false
    var watch_net_status     : Bool? = false
    var fire_net_status      : Bool? = false
    var heart_rate_status    : Bool? = false
    var watch_battery_status : Bool? = false
    var fire_battery_status  : Bool? = false
    var electron_fence_status: Bool? = false
    var morning_status       : Bool? = false
    var evening_status       : Bool? = false
}

struct StRspGetAlarmSetInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetAlarmSetInfoData? = StRspGetAlarmSetInfoData()
}


//-- Set Alarm Set Info
struct StReqSetAlarmSetInfo: Encodable {
    let pAct  : String = "setAlarmSetInfo"
    var token : String = ""
    var mobile: String = ""
    var sos_status           : String = "false"
    var fire_status          : String = "false"
    var watch_net_status     : String = "false"
    var fire_net_status      : String = "false"
    var heart_rate_status    : String = "false"
    var watch_battery_status : String = "false"
    var fire_battery_status  : String = "false"
    var electron_fence_status: String = "false"
    var morning_status       : String = "false"
    var evening_status       : String = "false"
}

struct StRspSetAlarmSetInfoData: Decodable {
    var sos_status           : Bool? = false
    var fire_status          : Bool? = false
    var watch_net_status     : Bool? = false
    var fire_net_status      : Bool? = false
    var heart_rate_status    : Bool? = false
    var watch_battery_status : Bool? = false
    var fire_battery_status  : Bool? = false
    var electron_fence_status: Bool? = false
    var morning_status       : Bool? = false
    var evening_status       : Bool? = false
}

struct StRspSetAlarmSetInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspSetAlarmSetInfoData? = StRspSetAlarmSetInfoData()
}


//-- Request Paid Service
struct StReqRequestPaidService: Encodable {
    let pAct  : String = "requestPaidService"
    var token : String = ""
    var mobile: String = ""
    var item_type: Int = 0  // 0: SmartWatch, 1: FireSensor, 2: SmokeSensor
    var item_id  : Int = 0  // Device Id
    var service_years: Int = 0  // 1 ~ 5
    var service_start: String = ""
    var service_end  : String = ""
    var amount  : Int = 0
    var pay_type: Int = 0   // 0: Alipay, 1: Wechat
}

struct StRspRequestPaidServiceData: Decodable {
    var order_id: Int? = 0
    var amount  : Int? = 0
    var service_start: String? = ""
    var service_end  : String? = ""
    var service_years: Int? = 0
    var pay_type     : Int? = 0
}

struct StRspRequestPaidService: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspRequestPaidServiceData? = StRspRequestPaidServiceData()
}


//-- Inquire Paid Service
struct StReqInquirePaidService: Encodable {
    let pAct  : String = "inquirePaidService"
    var token : String = ""
    var mobile: String = ""
    var item_type: Int = 0  // 0: SmartWatch, 1: FireSensor, 2: SmokeSensor
    var item_id  : Int = 0  // Device Id
}

struct StRspInquirePaidServiceData: Decodable {
    var order_id: Int? = 0
    var amount  : Int? = 0
    var service_start: String? = ""
    var service_end  : String? = ""
    var service_years: Int? = 0
    var pay_type     : Int? = 0 // 0: Alipay, 1: Wechat
}

struct StRspInquirePaidService: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspInquirePaidServiceData? = StRspInquirePaidServiceData()
}


//-- Cancel Paid Service
struct StReqCancelPaidService: Encodable {
    let pAct  : String = "cancelPaidService"
    var token : String = ""
    var mobile: String = ""
    var item_type: Int = 0  // 0: SmartWatch, 1: FireSensor, 2: SmokeSensor
    var item_id  : Int = 0  // Device Id
    var order_id : Int = 0
}

struct StRspCancelPaidService: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Get Watch Pos
struct StReqGetWatchPos: Encodable {
    let pAct  : String = "getWatchPos"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
}

struct StRspGetWatchPosData: Decodable {
    var lat : String? = ""
    var lon : String? = ""
    var time: String? = ""
}

struct StRspGetWatchPos: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetWatchPosData? = StRspGetWatchPosData()
}


//-- Get Watch Pos List
struct StReqGetWatchPosList: Encodable {
    let pAct  : String = "getWatchPosList"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
}

struct StRspGetWatchPosListData: Decodable {
    var lat : String? = ""
    var lon : String? = ""
    var time: String? = ""
}

struct StRspGetWatchPosList: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : [StRspGetWatchPosListData]? = [StRspGetWatchPosListData]()
}


//-- Elec Fence Info
struct StElecFenceInfoData: Codable {
    var name   : String? = ""
    var address: String? = ""
    var lat    : String? = ""
    var lon    : String? = ""
    var radius : Int? = 0
    var guardtime_list: String? = ""


    mutating func initFrom(json: JSON) {
        self.name    = json["name"].string
        self.address = json["address"].string
        self.lat     = json["lat"].string
        self.lon     = json["lon"].string
        self.radius  = json["radius"].int
        self.guardtime_list = json["guardtime_list"].string
    }


    mutating func initFrom(model: ModelFence) {
        self.name = model.sName
        self.address = model.sAddr
        self.lat     = model.sLat
        self.lon     = model.sLon
        self.radius  = model.iRadius
        self.guardtime_list = model.stringPeriods()
    }
}


//-- Get Elec Fence Info
struct StReqGetElecFenceInfo: Encodable {
    let pAct  : String = "getElecFenceInfo"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
}

struct StRspGetElecFenceInfoData: Decodable {
    var fence_list: String? = "" // [StElecFenceInfoData]
}

struct StRspGetElecFenceInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetElecFenceInfoData? = StRspGetElecFenceInfoData()
}


//-- Set Elec Fence Info
struct StReqSetElecFenceInfo: Encodable {
    let pAct  : String = "setElecFenceInfo"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
    var fence_list: String = "" // [StElecFenceInfoData] = [StElecFenceInfoData]()
}

struct StRspSetElecFenceInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Set Position Update Mode
struct StReqSetPosUpdateMode: Encodable {
    let pAct  : String = "setPosUpdateMode"
    var token : String = ""
    var mobile: String = ""
    var id    : Int    = 0
    var mode  : String = ""
}

struct StRspSetPosUpdateMode: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Task Detail : Below Structures are used in JPush too.
struct StTaskDetailInfo: Codable {
    var create_time: String? = ""
    var place      : String? = ""
    var lat        : String? = ""
    var lon        : String? = ""
    var title      : String? = ""
    var content    : String? = ""
    var illness    : String? = ""
}

struct StTaskDetailContact: Codable {
    var phone: String? = ""
    var name : String? = ""
}

struct StTaskDetailStatus: Codable {
    var volunteer_no: Int? = 0
    var lat: String? = ""
    var lon: String? = ""
    var distance: String? = ""
}

struct StTaskDetail: Codable {
    var task_id: Int? = 0
    var contact: [StTaskDetailContact]? = [StTaskDetailContact]()
    var status : [StTaskDetailStatus]? = [StTaskDetailStatus]()
    var info   : StTaskDetailInfo? = StTaskDetailInfo()
    var task_content: String? = ""
    var task_status: Int? = Config.TASK_STATUS_NONE
}


//-- Get Task Detail
struct StReqGetTaskDetail: Encodable {
    let pAct   : String = "getTaskDetail"
    var token  : String = ""
    var mobile : String = ""
    var task_id: Int    = 0
}

struct StRspGetTaskDetail: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StTaskDetail? = StTaskDetail()
}


//-- Accept Task
struct StReqAcceptTask: Encodable {
    let pAct   : String = "acceptTask"
    var token  : String = ""
    var mobile : String = ""
    var task_id: Int    = 0
}

struct StRspAcceptTask: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Finish Task
struct StReqFinishTask: Encodable {
    let pAct   : String = "finishTask"
    var token  : String = ""
    var mobile : String = ""
    var task_id: Int    = 0
}

struct StRspFinishTask: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Cancel Task
struct StReqCancelTask: Encodable {
    let pAct   : String = "cancelTask"
    var token  : String = ""
    var mobile : String = ""
    var task_id: Int    = 0
}

struct StRspCancelTask: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Get ID Card Front Info
struct StReqGetIdCardFrontInfo: Encodable {
    let pAct  : String = "getIdCardFrontInfo"
    var token : String = ""
    var mobile: String = ""
    var id_card_front_src: String = ""
}

struct StRspGetIdCardFrontInfoData: Decodable {
    var id_card_num: String? = ""
    var name       : String? = ""
    var sex        : Int?    = 0
    var birthday   : String? = ""
    var address    : String? = ""
}

struct StRspGetIdCardFrontInfo: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetIdCardFrontInfoData? = StRspGetIdCardFrontInfoData()
}


//-- Get Point Rule
struct StReqGetPointRule: Encodable {
    let pAct  : String = "getPointRule"
    var token : String = ""
    var mobile: String = ""
}

struct StRspGetPointRuleData: Decodable {
    var v1_exchange_point: String? = ""
    var v2_exchange_point: String? = ""
    var v3_exchange_point: String? = ""
    var v4_exchange_point: String? = ""
    var v1_exchange_price: String? = ""
    var v2_exchange_price: String? = ""
    var v3_exchange_price: String? = ""
    var v4_exchange_price: String? = ""
    var v1_description   : String? = ""
    var v2_description   : String? = ""
    var v3_description   : String? = ""
    var v4_description   : String? = ""
    var v1_limit         : String? = ""
    var v2_limit         : String? = ""
    var v3_limit         : String? = ""
    var v4_limit         : String? = ""
    var v1_equity        : String? = ""
    var v2_equity        : String? = ""
    var v3_equity        : String? = ""
    var v4_equity        : String? = ""
    var point_rule       : String? = ""
}

struct StRspGetPointRule: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetPointRuleData? = StRspGetPointRuleData()
}


//-- Get Financial List
struct StReqGetFinancialList: Encodable {
    let pAct  : String = "getFinancialList"
    var token : String = ""
    var mobile: String = ""
}

struct StRspGetFinancialListData: Decodable {
    var amount: Double? = 0
    var point : Int? = 0
    var time  : String? = ""
    var status: String? = ""
}

struct StRspGetFinancialList: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : [StRspGetFinancialListData]? = [StRspGetFinancialListData]()
}


//-- Get Financial List
struct StReqGetRescueList: Encodable {
    let pAct  : String = "getRescueList"
    var token : String = ""
    var mobile: String = ""
}

struct StRspGetRescueListData: Decodable {
    var task_id      : Int? = 0
    var contactName  : String? = ""
    var contactPhone : String? = ""
    var task_content : String? = ""
    var alarm_content: String? = ""
    var device_type  : String? = ""
    var device_serial: String? = ""
    var point        : Int?    = 0
    var finish_time  : String? = ""
}

struct StRspGetRescueList: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : [StRspGetRescueListData]? = [StRspGetRescueListData]()
}


//-- Get Financial List
struct StReqGetRescueDetail: Encodable {
    let pAct  : String = "getRescueDetail"
    var token : String = ""
    var mobile: String = ""
    var task_id: Int = 0
}

struct StRspGetRescueDetailData: Decodable {
    var task_id                 : Int? = 0
    var alarm_create_time       : String? = ""
    var contactName             : String? = ""
    var contactPhone            : String? = ""
    var task_content            : String? = ""
    var alarm_content           : String? = ""
    var device_type             : String? = ""
    var device_serial           : String? = ""
    var point                   : Int? = 0
    var create_time             : String? = ""
    var finish_time             : String? = ""
}

struct StRspGetRescueDetail: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspGetRescueDetailData? = StRspGetRescueDetailData()
}


//-- Register Bank Card
struct StReqRegisterBankCard: Encodable {
    let pAct  : String = "registerBankCard"
    var token : String = ""
    var mobile: String = ""
    var bank_name: String = ""
    var bank_card: String = ""
    var bank_password: String = ""
}

struct StRspRegisterBankCard: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}


//-- Modify Bank Password
struct StReqModifyBankPassword: Encodable {
    let pAct  : String = "modifyBankPassword"
    var token : String = ""
    var mobile: String = ""
    var old_bank_password: String = ""
    var new_bank_password: String = ""
}

struct StRspModifyBankPassword: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}


//-- Forgot Bank Password
struct StReqForgotBankPassword: Encodable {
    let pAct  : String = "forgotBankPassword"
    var token : String = ""
    var mobile: String = ""
    var bank_password: String = ""
    var verify_code  : String = ""
}

struct StRspForgotBankPassword: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspUserInfo? = StRspUserInfo()
}


//-- Set User Status Ready
struct StReqSetUserStatusReady: Encodable {
    let pAct  : String = "setUserStatusReady"
    var token : String = ""
    var mobile: String = ""
}

struct StRspSetUserStatusReady: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Set User Status Disabled
struct StReqSetUserStatusDisabled: Encodable {
    let pAct  : String = "setUserStatusDisabled"
    var token : String = ""
    var mobile: String = ""
}

struct StRspSetUserStatusDisabled: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Get Volunteer Statistics
struct StReqGetVolunteerStatistics: Encodable {
    let pAct  : String = "getVolunteerStatistics"
    var token : String = ""
    var mobile: String = ""
}

struct StRspGetVolunteerStatisticsData: Decodable {
    var count   : String? = "0"
    var province: String? = ""
    var city    : String? = ""
    var district: String? = ""
    var code    : String? = ""
    var lat     : String? = "40"
    var lon     : String? = "120"
}

struct StRspGetVolunteerStatistics: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : [StRspGetVolunteerStatisticsData]? = [StRspGetVolunteerStatisticsData]()
}


//-- Update Location
struct StReqUpdateLocation: Encodable {
    let pAct  : String = "updateLocation"
    var token : String = ""
    var mobile: String = ""
    var lat   : String = ""
    var lon   : String = ""
    var province: String = ""
    var city    : String = ""
    var district: String = ""
}

struct StRspUpdateLocation: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Request Chat
struct StReqRequestChat: Encodable {
    let pAct  : String = "requestChat"
    var token : String = ""
    var mobile: String = ""
    var task_id: String = ""
}

struct StRspRequestChatData: Decodable {
    var roomId  : String? = ""
    var password: String? = ""
}

struct StRspRequestChat: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspRequestChatData? = StRspRequestChatData()
}


//-- Wechat Access Token
struct StReqWechatAccessToken: Encodable {
    var appid : String = ""
    var secret: String = ""
    var code  : String = ""
    var grant_type: String = ""
}

struct StRspWechatAccessToken: Decodable {
    var access_token : String? = ""
    var expires_in   : Int? = 0
    var refresh_token: String? = ""
    var openid       : String? = ""
    var scope        : String? = ""
    var errcode      : Int? = 0
    var errmsg       : String? = ""
}


//-- Wechat User Info
struct StReqWechatUserInfo: Encodable {
    var access_token : String = ""
    var openid       : String = ""
    var lang         : String = ""
}

struct StRspWechatUserInfo: Decodable {
    var openid       : String? = ""
    var nickname     : String? = ""
    var sex          : Int?    = 1
    var province     : String? = ""
    var city         : String? = ""
    var country      : String? = ""
    var headimgurl   : String? = ""
    var privilege    : [String]? = [String]()
    var unionid      : String? = ""
}


//-- Register Pay Account
struct StReqRegisterPayAccount: Encodable {
    let pAct  : String = "registerPayAccount"
    var token : String = ""
    var mobile: String = ""
    var pay_type: Int = Config.PAYMENT_ALIPAY
    var pay_account_name: String = ""
    var pay_account_id  : String = ""
}

struct StRspRegisterPayAccount: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Remove Pay Account
struct StReqRemovePayAccount: Encodable {
    let pAct    : String = "removePayAccount"
    var token   : String = ""
    var mobile  : String = ""
    var pay_type: Int = Config.PAYMENT_ALIPAY
    var verify_code: String = ""
}

struct StRspRemovePayAccount: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}


//-- Request Transfer Pay
struct StReqRequestTransferPay: Encodable {
    let pAct  : String = "requestTransferPay"
    var token : String = ""
    var mobile: String = ""
    var pay_type: Int = Config.PAYMENT_ALIPAY
    var point   : Int = 0
}

struct StRspRequestTransferPayData: Decodable {
    var point      : String? = ""
    var cash       : String? = ""
    var balance    : String? = ""
    var point_level: String? = ""
}

struct StRspRequestTransferPay: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data : StRspRequestTransferPayData? = StRspRequestTransferPayData()
}


//-- All Notifiation List
struct StReqGetAllNotificationList: Encodable {
    let pAct  : String = "getAllNotificationList"
    var token : String = ""
    var mobile: String = ""
}

struct StRspGetAllNotificationListData: Decodable {
    var readStatus      : Bool? = false
    var msg             : String? = ""
    var updatedDateStr  : String? = ""
    var updatedTime     : String? = ""
    var createTime      : String? = ""
    var customerId      : Int? = 0
    var updatedTimeStr  : String? = ""
    var createDateStr   : String? = ""
    var id              : Int? = 0
    var title           : String? = ""
    var dataJson        : String? = ""
    var createTimeStr   : String? = ""
    var alarmStatus     : Int? = 0
}

struct StRspGetAllNotificationList: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : [StRspGetAllNotificationListData]? = [StRspGetAllNotificationListData]()
}

//-- Read Notification
struct StReqReadNotification: Encodable {
    let pAct  : String = "readNotification"
    var token : String = ""
    var mobile: String = ""
    var id: Int? = 0
}

struct StRspReadNotification: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}

//-- Remove Notification
struct StReqRemoveNotification: Encodable {
    let pAct  : String = "removeNotification"
    var token : String = ""
    var mobile: String = ""
    var id: Int? = 0
}

struct StRspRemoveNotificationData: Decodable {
    var password    : String? = ""
    var roomId      : String? = ""
}

struct StRspRemoveNotification: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
    var data   : StRspRemoveNotificationData? = StRspRemoveNotificationData()
}

//-- Read All Notification
struct StReqReadAllNotification: Encodable {
    let pAct  : String = "readAllNotification"
    var token : String = ""
    var mobile: String = ""
}

struct StRspReadAllNotification: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}

//-- Remove All Notification
struct StReqRemoveAllNotification: Encodable {
    let pAct  : String = "removeAllNotification"
    var token : String = ""
    var mobile: String = ""
}

struct StRspRemoveAllNotification: Decodable {
    var retcode: Int?    = 0
    var msg    : String? = ""
}
