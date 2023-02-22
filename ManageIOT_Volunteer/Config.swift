import Foundation


enum DeviceType {
    case SmartWatch
    case FireSensor
    case SmokeSensor
}


class Config {
    //static let URL_BASE    = "http://iot.ddewnt.com/DDFAS/api.html"
    static let URL_BASE    = "http://192.168.10.92:8084/IOTCMS/volunteer_api.do"
    //static let URL_BASE    = "http://192.168.10.84:8084/IOTCMS/volunteer_api.do"
//    static let URL_BASE    = "https://app.shoumengou.com/IOTCMS/volunteer_api.do"
    static let URL_WEATHER = "https://way.jd.com/he/freeweather?city=dandong&appkey=3dc194ba40b2ded0a8286bb42030a231"
    static let URL_GEOCONV = "http://api.map.baidu.com/geoconv/v1/"  /// Must include last slash "/"
//    static let URL_GEOCONV2 = "http://api.map.baidu.com/ag/coord/convert"

    static let BAIDU_MAP_KEY = "91r28kjA9NtgBhjt2X1YDkyAAIkqdlg4"

    static let JUPHOON_SERVER_ADDRESS = "http:cn.router.justalkcloud.com:8080"
    static let JUPHOON_APP_KEY = "70db513068dee6c24d344097"
    static let JUPHOON_CHANNEL_NAME = "manageIot"

    static let JPUSH_APP_KEY = "9a85abff99dc41e133799de3"
    static let JPUSH_CHANNEL = "App Store" /// "developer-default"
    static let JPUSH_FOR_PRODUCT = true

    static let WECHAT_APP_ID = "wx1111111111111111" /// "wx7a58ef5cb07ff9f8"
    static let WECHAT_UNIVERSAL_LINK = "https://app.shoumengouvolunteer.com"
    static let WECHAT_APP_SECRET = "liaoning" /// "liaoningdandongshoumengou2020111"
    static let URL_WECHAT_ACCESS_TOKEN = "https://api.weixin.qq.com/sns/oauth2/access_token"
    static let URL_WECHAT_USER_INFO    = "https://api.weixin.qq.com/sns/userinfo"

    static let DEFAULT_LAT: Double = 39.9075
    static let DEFAULT_LON: Double = 116.3972

    static let HTTP_TYPE_CONTENT = "application/x-www-form-urlencoded;charset=UTF-8"
    static let HTTP_TYPE_ACCEPT  = "application/json"
    static let RET_SUCCESS  = 200
    static let PREFIX_FIRESENSOR  = "YG"
    static let PREFIX_SMOKESENSOR = "QG"

    //-- Health
    static let BLOOD_O  = "O"
    static let BLOOD_A  = "A"
    static let BLOOD_B  = "B"
    static let BLOOD_AB = "AB"
    static let HEART_RATE_MIN = 0
    static let HEART_RATE_MAX = 200

    //-- App Info
    static let PREF_AGREEMENT  : String = "AGREEMENT"
    static let PREF_POLICY     : String = "POLICY"
    static let PREF_FREE_WATCH : String = "FREE_WATCH"
    static let PREF_FREE_YANGAN: String = "FREE_YANGAN"
    static let PREF_FREE_RANQI : String = "FREE_RANQI"
    static let PREF_PAY_WATCH  : String = "PAY_WATCH"
    static let PREF_PAY_YANGAN : String = "PAY_YANGAN"
    static let PREF_PAY_RANQI  : String = "PAY_RANQI"
    static let PREF_BIRTH_DESC : String = "BIRTH_DESC"
    static let PREF_APP_VER_IOS  : String = "APP_VER_IOS"
    static let PREF_STORE_URL_IOS: String = "STORE_URL_IOS"

    //-- JPush ID
    static let PREF_JPUSH: String = "JPUSH"

    //-- User Info
    static let PREF_IS_LOGGED_IN = "LOGGED_IN"
    static let PREF_PHONE: String = "PHONE"
    static let PREF_PSWD : String = "PSWD"
    static let PREF_WILL_SAVE_PHONE: String = "WILL_SAVE_PHONE"
    static let PREF_WILL_SAVE_PSWD : String = "WILL_SAVE_PSWD"
    static let PREF_LOGIN_AGREE_PRIVACY : String = "LOGIN_AGREE_PRIVACY"

    //-- Misc
    static let PREF_ID_WATCH_MONITORING  : String = "ID_WATCH_MONITORING"
    static let PREF_TIME_LAST_HEARTRATE  : String = "TIME_LAST_HEARTRATE"
    static let PREF_HIDE_USER_STATUS_TERM: String = "HIDE_USER_STATUS_TERM"
//    static let PREF_TASK_DETAIL: String = "TASK_DETAIL"

    //-- Payment
    static let PAYMENT_ALIPAY  : Int = 1
    static let PAYMENT_WECHAT  : Int = 2
    static let PAYMENT_BANKCARD: Int = 3

    //-- News
    static let NEWS_BRANCH_HOTSPOT: String = "hot_recommend"
    static let NEWS_BRANCH_SENSE  : String = "common_sense"

    //-- User Status
    static let USER_STATUS_DISABLED: String = "DISABLED"
    static let USER_STATUS_READY   : String = "READY"
    static let USER_STATUS_WORKING : String = "WORKING"
    
    //-- Task Status
    static let TASK_STATUS_NONE: Int = -1
    static let TASK_STATUS_PENDING: Int = 0
    static let TASK_STATUS_WAIT_ALLOC: Int = 2

    //-- Type Alert
    static let TYPE_NOTIFY_TASK: String = "task"
    static let TYPE_NOTIFY_CHAT: String = "chat"
    static let TYPE_NOTIFY_PAY : String = "pay"
    static let TYPE_NOTIFY_NOTICE: String = "notice"

    static let TASK_STATUS_CREATE: String = "create"
    static let TASK_STATUS_CANCEL: String = "cancel"
    static let TASK_STATUS_FINISH: String = "finish"


    //-- Global Variables
    static var is_logged_in: Bool = false
    static var phone: String = ""
    static var pswd : String = ""
    static var login_agree_privacy  : Bool = false

    static var vcMain: ViewControllerMain? = nil

    static var id_watch_monitoring: Int = -1
    static var modelUserInfo: ModelUserInfo = ModelUserInfo()
    static var modelWatchMonitoring: ModelWatch = ModelWatch()
    static var stTaskDetail: StTaskDetail? = nil
    static var juphoon_room_id  : String = ""
    static var juphoon_room_pswd: String = ""
    static var pay_status: String = ""
    static var is_launching_from_notification     : Bool = false
    static var is_launching_from_notification_task: Bool = false
    static var is_launching_from_notification_chat: Bool = false
    static var is_launching_from_notification_pay : Bool = false

    static var current_lat : Double = 0
    static var current_lon : Double = 0
    static var current_addr: String = "丹东"
    static var current_province: String = ""
    static var current_city    : String = ""
    static var current_district: String = ""

    private static var arrUserInfoDelegate: [UserInfoDelegate] = [UserInfoDelegate]()


    //----------------------------------------
    // Manage Delegate
    //----------------------------------------
    static func addUserInfoDelegate(delegate: UserInfoDelegate) {
        if arrUserInfoDelegate.contains(where: { $0 === delegate }) {
            return
        }
        arrUserInfoDelegate.append(delegate)
    }


    static func delUserInfoDelegate(delegate: UserInfoDelegate) {
        let i = arrUserInfoDelegate.firstIndex(where: { $0 === delegate }) ?? -1
        if i >= 0 {
            arrUserInfoDelegate.remove(at: i)
        }
    }


    static func notifyUpdatedUserInfo() {
        for delegate in arrUserInfoDelegate {
            delegate.onUpdatedUserInfo()
        }
    }


    //----------------------------------------
    // Load / Save Values in Config into Defaults
    // Get  / Set  Values from External into Defaults
    //----------------------------------------

    //-- User Info
    static func loadLoginInfo() {
        is_logged_in = UserDefaults.standard.bool(forKey: PREF_IS_LOGGED_IN)
        phone = UserDefaults.standard.string(forKey: PREF_PHONE) ?? ""
        pswd  = UserDefaults.standard.string(forKey: PREF_PSWD ) ?? ""
        login_agree_privacy = UserDefaults.standard.bool(forKey: PREF_LOGIN_AGREE_PRIVACY)
    }


    static func saveLoginInfo() {
        UserDefaults.standard.set(is_logged_in, forKey: PREF_IS_LOGGED_IN)
        UserDefaults.standard.set(phone, forKey: PREF_PHONE)
        UserDefaults.standard.set(pswd , forKey: PREF_PSWD )
        UserDefaults.standard.set(login_agree_privacy, forKey: PREF_LOGIN_AGREE_PRIVACY)
    }


    //-- Will Save Phone
    static func getWillSavePhone() -> Bool {
        let bValue = UserDefaults.standard.bool(forKey: PREF_WILL_SAVE_PHONE)
        return bValue
    }


    static func setWillSavePhone(value: Bool) {
        UserDefaults.standard.set(value, forKey: PREF_WILL_SAVE_PHONE)
    }


    //-- Will Save Pswd
    static func getWillSavePswd() -> Bool {
        let bValue = UserDefaults.standard.bool(forKey: PREF_WILL_SAVE_PSWD)
        return bValue
    }


    static func setWillSavePswd(value: Bool) {
        UserDefaults.standard.set(value, forKey: PREF_WILL_SAVE_PSWD)
    }


    //-- IdWatchMonitoring
    static func loadIdWatchMonitoring() {
        id_watch_monitoring = UserDefaults.standard.integer(forKey: PREF_ID_WATCH_MONITORING)
    }


    static func saveIdWatchMonitoring() {
        UserDefaults.standard.set(id_watch_monitoring, forKey: PREF_ID_WATCH_MONITORING)
    }


    //-- App Info
    static func getAppInfo() -> ModelAppInfo {
        let model = ModelAppInfo()
        model.sAgreement  = UserDefaults.standard.string(forKey: PREF_AGREEMENT  ) ?? ""
        model.sPolicy     = UserDefaults.standard.string(forKey: PREF_POLICY     ) ?? ""
        model.sFreeWatch  = UserDefaults.standard.string(forKey: PREF_FREE_WATCH ) ?? ""
        model.sFreeYanGan = UserDefaults.standard.string(forKey: PREF_FREE_YANGAN) ?? ""
        model.sFreeRanQi  = UserDefaults.standard.string(forKey: PREF_FREE_RANQI ) ?? ""
        model.sPayWatch   = UserDefaults.standard.string(forKey: PREF_PAY_WATCH  ) ?? ""
        model.sPayYanGan  = UserDefaults.standard.string(forKey: PREF_PAY_YANGAN ) ?? ""
        model.sPayRanQi   = UserDefaults.standard.string(forKey: PREF_PAY_RANQI  ) ?? ""
        model.sBirthDesc  = UserDefaults.standard.string(forKey: PREF_BIRTH_DESC ) ?? ""
        model.sAppVerIos   = UserDefaults.standard.string(forKey: PREF_APP_VER_IOS  ) ?? ""
        model.sStoreUrlIos = UserDefaults.standard.string(forKey: PREF_STORE_URL_IOS) ?? ""
        return model
    }


    static func setAppInfo(value: ModelAppInfo) {
        UserDefaults.standard.set(value.sAgreement  , forKey: PREF_AGREEMENT  )
        UserDefaults.standard.set(value.sPolicy     , forKey: PREF_POLICY     )
        UserDefaults.standard.set(value.sFreeWatch  , forKey: PREF_FREE_WATCH )
        UserDefaults.standard.set(value.sFreeYanGan , forKey: PREF_FREE_YANGAN)
        UserDefaults.standard.set(value.sFreeRanQi  , forKey: PREF_FREE_RANQI )
        UserDefaults.standard.set(value.sPayWatch   , forKey: PREF_PAY_WATCH  )
        UserDefaults.standard.set(value.sPayYanGan  , forKey: PREF_PAY_YANGAN )
        UserDefaults.standard.set(value.sPayRanQi   , forKey: PREF_PAY_RANQI  )
        UserDefaults.standard.set(value.sBirthDesc  , forKey: PREF_BIRTH_DESC )
        UserDefaults.standard.set(value.sAppVerIos  , forKey: PREF_APP_VER_IOS  )
        UserDefaults.standard.set(value.sStoreUrlIos, forKey: PREF_STORE_URL_IOS)
    }


    //-- JPUSH
    static func getJPush() -> String {
        let sValue = UserDefaults.standard.string(forKey: PREF_JPUSH) ?? ""
        return sValue
    }


    static func setJPush(value: String) {
        UserDefaults.standard.set(value, forKey: PREF_JPUSH)
    }


    //-- TimeLastHeartRate
    static func getTimeLastHeartRate() -> String {
        let sValue = UserDefaults.standard.string(forKey: PREF_TIME_LAST_HEARTRATE) ?? ""
        return sValue
    }


    static func setTimeLastHeartRate(value: String) {
        UserDefaults.standard.set(value, forKey: PREF_TIME_LAST_HEARTRATE)
    }


    //-- User Status Term
    static func getHideUserStatusTerm() -> Bool {
        let bValue = UserDefaults.standard.bool(forKey: PREF_HIDE_USER_STATUS_TERM)
        return bValue
    }


    static func setHideUserStatusTerm(value: Bool) {
        UserDefaults.standard.set(value, forKey: PREF_HIDE_USER_STATUS_TERM)
    }


}
