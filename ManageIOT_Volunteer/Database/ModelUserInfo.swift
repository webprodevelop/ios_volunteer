import Foundation

class ModelUserInfo {
    var sToken          : String = ""
    var sName           : String = ""
    var sMobile         : String = ""
    var iSex            : Int    = 0
    var sBirthday       : String = ""
    var sCompany        : String = ""
    var sJob            : String = ""
    var sResidence      : String = ""
    var sAddress        : String = ""
    var sProvince       : String = ""
    var sCity           : String = ""
    var sDistrict       : String = ""
    var sPicture        : String = ""
    var sCertificate    : String = ""
    var sCertificatePic : String = ""
    var sIdCardNum      : String = ""
    var sIdCardFront    : String = ""
    var sIdCardBack     : String = ""
    var sBankName       : String = ""
    var sBankId         : String = ""
    var sBankPwd        : String = ""
    var sWechatName     : String = ""
    var sWechatId       : String = ""
    var sAlipayName     : String = ""
    var sAlipayId       : String = ""
    var iPoint          : Int    = 0
    var fCash           : Float  = 0
    var iBalance        : Int    = 0
    var iPointLevel     : Int    = 0
    var iIdTask         : Int    = 0
    var sStatus         : String = Config.USER_STATUS_READY


    func copyFromApiData(data: StRspUserInfo) {
        sToken          = data.token ?? ""
        sName           = data.name ?? ""
        sMobile         = data.mobile ?? ""
        iSex            = data.sex ?? 0
        sBirthday       = data.birthday ?? ""
        sCompany        = data.company ?? ""
        sJob            = data.job ?? ""
        sResidence      = data.residence ?? ""
        sAddress        = data.address ?? ""
        sProvince       = data.province ?? ""
        sCity           = data.city ?? ""
        sDistrict       = data.district ?? ""
        sPicture        = data.picture ?? ""
        sCertificate    = data.certificate ?? ""
        sCertificatePic = data.certificate_pic ?? ""
        sIdCardNum      = data.id_card_num ?? ""
        sIdCardFront    = data.id_card_front ?? ""
        sIdCardBack     = data.id_card_back ?? ""
        sBankName       = data.bank_account_name ?? ""
        sBankId         = data.bank_account_id ?? ""    /// bank_card
        sBankPwd        = data.bank_account_pwd ?? ""
        sWechatName     = data.weixin_account_name ?? ""
        sWechatId       = data.weixin_account_id ?? ""
        sAlipayName     = data.alipay_account_name ?? ""
        sAlipayId       = data.alipay_account_id ?? ""
        iPoint          = Int(data.point ?? "0") ?? 0
        fCash           = Float(data.cash ?? "0") ?? 0
        iBalance        = Int(data.balance ?? "0") ?? 0
        iPointLevel     = Int(data.point_level ?? "0") ?? 0
        iIdTask         = data.task_id ?? 0
        sStatus         = data.status ?? Config.USER_STATUS_DISABLED

        if iPointLevel < 1 {
            iPointLevel = 1
        }
    }
}
