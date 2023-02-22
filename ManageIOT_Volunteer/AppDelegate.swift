import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import DropDown
import SwiftyJSON
import JuphoonCommon
import JCSDKOC


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = nil             // This variable must be redefined
    var mapManager: BMKMapManager? = nil


    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions  launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        //-- Init
        IQKeyboardManager.shared.enable = true
        DropDown.startListeningToKeyboard()

        DbManager.instance.deleteDb()

        initBaiduMap()
        initNotification()

        /// Juphoon Call
//        let _ = JuphoonCommonManager.shareInstance.startWith(appkey: JuphoonCommonAppKey.Duo, delegate: self)

        let _ = JuphoonCommonManager.shareInstance.startWith(appkey: JuphoonCommonAppKey.Room, delegate: self)
        JCRoom.shared.initialize()

        /// Wechat
//        WXApi.registerApp(Config.WECHAT_APP_ID, universalLink: Config.WECHAT_UNIVERSAL_LINK)
        Thread.sleep(forTimeInterval: 2);

        return true
    }


    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        /// When app launched other app such as Wechat or Alipay, and returns to the app again
        /// Wait until server confirms the payment
        Thread.sleep(forTimeInterval: 2);
        return true
    }


    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        /// When app launched other app such as Wechat or Alipay, and returns to the app again
        /// Wait until server confirms the payment
        Thread.sleep(forTimeInterval: 2);
        return true
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        /// When app launched other app such as Wechat or Alipay, and returns to the app again
        /// Wait until server confirms the payment
        Thread.sleep(forTimeInterval: 2);
        return true
    }


    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken  deviceToken: Data
    ) {
        //-- Register DeviceToken
        JPUSHService.registerDeviceToken(deviceToken)
    }


    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError  error: Error
    ) {
        print("Failed to register Remote Notification: \(error)")
    }


    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification  userInfo: [AnyHashable:Any],
        fetchCompletionHandler  completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("APPNOTIFY : DidReceive")
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }


    func initNotification() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options : [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
        }

        let userSettings = UIUserNotificationSettings(
            types: [.alert, .badge, .sound],
            categories: nil
        )

        if ((UIDevice.current.systemVersion as NSString).floatValue >= 8.0) {
            //-- Self Defined Categories
            JPUSHService.register(
                forRemoteNotificationTypes: userSettings.types.rawValue,
                categories: nil
            )
        }
        else {
            //-- When nil
            JPUSHService.register(
                forRemoteNotificationTypes: userSettings.types.rawValue,
                categories: nil
            )
        }

        //-- JPushSDK
        JPUSHService.setup(
            withOption: nil,
            appKey    : Config.JPUSH_APP_KEY,
            channel   : Config.JPUSH_CHANNEL,
            apsForProduction: Config.JPUSH_FOR_PRODUCT
        )
    }


    func initBaiduMap() {
        print("Baidu Map Version : \(BMKMapManager.version())")
        BMKLocationAuth.sharedInstance()?.checkPermision(withKey: Config.BAIDU_MAP_KEY, authDelegate: self)
        if BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK(BMK_COORD_TYPE.COORDTYPE_BD09LL) {
            print("Latitude and Longitude type set successfully")
        }
        else {
            print("Latitude and Longitude type set failed")
        }

        mapManager = BMKMapManager()
        if !mapManager!.start(Config.BAIDU_MAP_KEY, generalDelegate: self) {
            print("Failed to start the map engine")
        }
    }


    func saveNotifications(notifications: [UNNotification]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        for notification in notifications {
            let date = notification.date
            let sTime = formatter.string(from: date)

            let request = notification.request
            let content = request.content

            //-- Title, SubTitle will be Empty
            //-- Only Category, Body, userInfo is necessary
            let sCategory = content.categoryIdentifier
            //let sTitle    = content.title
            //let sSubTitle = content.subtitle
            let sBody = content.body
            let sData = content.userInfo["iot_data"] as! String

            //-- Save to DB
            let message = ModelMessage()
            message.sCategory = sCategory
            message.sBody     = sBody
            message.sData     = sData
            message.sTime     = sTime

            DbManager.instance.insertMessage(model: message)
        }
    }


    func treatNotification(notification: UNNotification) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = notification.date
        let sTime = formatter.string(from: date)

        let request = notification.request
        let content = request.content

        //-- Title, SubTitle will be Empty
        //-- Only Category, Body, userInfo is necessary
        let sCategory = content.categoryIdentifier
        //let sTitle    = content.title
        //let sSubTitle = content.subtitle
        let sBody = content.body
        let sData = content.userInfo["iot_data"] as! String

        //-- Save to DB
        var message = ModelMessage()
        message.sCategory = sCategory
        message.sBody     = sBody
        message.sData     = sData
        message.sTime     = sTime

        DbManager.instance.insertMessage(model: message)
        message = DbManager.instance.loadMessageLast()      /// After insert, load again to retrieve id

        //-- Analyze Body
        var sType: String = ""
        let jsonBody = JSON(parseJSON: sData)
        sType = jsonBody["type"].string ?? ""

        if sType.isEmpty { return }

        /// Config.VcMain == nil means : app was ultimately closed and launches from notification, VcMain will be launched up later
        /// Config.VcMain != nil means : app was in background and launches from notification

        if sType == Config.TYPE_NOTIFY_TASK {
            var iTaskId: Int = 0
            var sTaskStatus: String = Config.TASK_STATUS_CANCEL

            iTaskId = jsonBody["task_id"].int ?? 0
            sTaskStatus = jsonBody["task_status"].string ?? Config.TASK_STATUS_CANCEL

            if sTaskStatus == Config.TASK_STATUS_CANCEL
            || sTaskStatus == Config.TASK_STATUS_FINISH {
                endTask(taskStatus: sTaskStatus)
                return
            }
            /// When task_status is "create"
            Config.modelUserInfo.iIdTask = iTaskId
            if Config.is_launching_from_notification {
                if Config.vcMain == nil {
                    Config.is_launching_from_notification_task = true
                    return
                }
            }
            tryGetTaskDetail()
        }
        else if sType == Config.TYPE_NOTIFY_CHAT {
            let sRoomId   = jsonBody["roomId"].string ?? ""
            let sPassword = jsonBody["password"].string ?? ""
            Config.juphoon_room_id = sRoomId
            Config.juphoon_room_pswd = sPassword
            if Config.is_launching_from_notification {
                if Config.vcMain == nil {
                    Config.is_launching_from_notification_chat = true
                    return
                }
            }
            juphoonMain()
        }
        else if sType == Config.TYPE_NOTIFY_PAY {
            Config.pay_status = jsonBody["pay_status"].string ?? "fail"

            if Config.is_launching_from_notification {
                if Config.vcMain == nil {
                    Config.is_launching_from_notification_pay = true
                    return
                }
            }
            let vcCurrent = UIViewController.currentViewController()
            if vcCurrent == nil {
                Config.is_launching_from_notification_pay = true
                return
            }

            if Config.pay_status == "success" {
                vcCurrent?.showAlert(title: "Notify".localized(), message: "Payment has been successfully completed.".localized())
                tryGetUserInfo()
            }
            else {
                vcCurrent?.showAlert(title: "Notify".localized(), message: "Payment has been failed.".localized())
            }
        }
        else if sType == Config.TYPE_NOTIFY_NOTICE {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { timer in
                DispatchQueue.main.async {
                    let vcCurrent = UIViewController.currentViewController()
                    if vcCurrent == nil {
                        return
                    }

                    vcCurrent?.showAlert(title: "Notify".localized(), message: sBody)
                }
            })
        }
    }


    func endTask(taskStatus: String) {
        Config.modelUserInfo.iIdTask = 0
        Config.modelUserInfo.sStatus = Config.USER_STATUS_READY
        trySetUserStatusReady()

        DispatchQueue.main.async {
            Config.vcMain?.updateBtnStatus()
            let vcCurrent = UIViewController.currentViewController()
            if vcCurrent == nil { return }
            if vcCurrent!.isKind(of: ViewControllerSplash.self)   { return }
            if vcCurrent!.isKind(of: ViewControllerLogin.self)    { return }
            if vcCurrent!.isKind(of: ViewControllerRegister.self) { return }
            if vcCurrent!.isKind(of: ViewControllerForgot.self)   { return }
            if vcCurrent!.isKind(of: ViewControllerPolicy.self)   { return }
            if vcCurrent!.isKind(of: ViewControllerAgree.self)    { return }

            if vcCurrent!.isKind(of: ViewControllerTaskProgress.self) {
                (vcCurrent as! ViewControllerTaskProgress).dismiss(animated: false, completion: {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                        self.showAlertTaskEnd(taskStatus: taskStatus)
                    })
                })
            }
            else {
                self.showAlertTaskEnd(taskStatus: taskStatus)
            }
        }
    }


    func showAlertTaskEnd(taskStatus: String) {
        DispatchQueue.main.async {
            let vcCurrent = UIViewController.currentViewController()

            if taskStatus == Config.TASK_STATUS_FINISH {
                vcCurrent?.showAlert(title: "Notify".localized(), message: "The task is finished in the service.".localized())
            }
            if taskStatus == Config.TASK_STATUS_CANCEL {
                vcCurrent?.showAlert(title: "Notify".localized(), message: "The task is canceled in the service.".localized())
            }
        }
    }


    func tryGetTaskDetail() {
        //-- Call API : getTaskDetail
        var stReq: StReqGetTaskDetail = StReqGetTaskDetail()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.task_id = Config.modelUserInfo.iIdTask

        API.instance.getTaskDetail(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        Config.modelUserInfo.sStatus = Config.USER_STATUS_READY
                        DispatchQueue.main.async {
                            Config.vcMain?.updateBtnStatus()
                        }
                        return
                    }
                    if stRsp.data == nil { break }
                    Config.stTaskDetail = stRsp.data!
                    Config.modelUserInfo.iIdTask = Config.stTaskDetail?.task_id ?? 0
                    
//                    if Config.modelUserInfo.iIdTask > 0 && (Config.stTaskDetail?.task_status == Config.TASK_STATUS_WAIT_ALLOC || Config.stTaskDetail?.task_status == Config.TASK_STATUS_PENDING) {
//                        DispatchQueue.main.async {
//                            
//                        }
//                    }
                    if let task_status = Config.stTaskDetail?.task_status, task_status == Config.TASK_STATUS_WAIT_ALLOC { // 绑定中
                        /// Here, Timer must be scheduled in Main Thread
                        DispatchQueue.main.async {
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
                                DispatchQueue.main.async {
                                    let vcCurrent = UIViewController.currentViewController()
                                    if vcCurrent == nil { return }
                                    if vcCurrent!.isKind(of: ViewControllerSplash.self)   { return }
                                    if vcCurrent!.isKind(of: ViewControllerLogin.self)    { return }
                                    if vcCurrent!.isKind(of: ViewControllerRegister.self) { return }
                                    if vcCurrent!.isKind(of: ViewControllerForgot.self)   { return }
                                    if vcCurrent!.isKind(of: ViewControllerPolicy.self)   { return }
                                    if vcCurrent!.isKind(of: ViewControllerAgree.self)    { return }
                                    if let vcMain = Config.vcMain {
                                        DispatchQueue.main.async {
                                            vcMain.showViewControllerTaskProgress()
                                        }
                                    }
                                }
                            })
                        }
                    }
                    break

                case .failure(_):
                    return
            }
        }
    }


    private func trySetUserStatusReady() {
        var stReq: StReqSetUserStatusReady = StReqSetUserStatusReady()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile

        API.instance.setUserStatusReady(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        break
                    }
                    break

                case .failure(_):
                    break
            }
            self.tryGetUserInfo()
        }
    }


    func tryGetUserInfo() {
        var stReq: StReqGetUserInfo = StReqGetUserInfo()
        stReq.mobile   = Config.modelUserInfo.sMobile
        stReq.token    = Config.modelUserInfo.sToken

        API.instance.getUserInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        break
                    }
                    if stRsp.data != nil {
                        Config.modelUserInfo.copyFromApiData(data: stRsp.data!)
                        Config.notifyUpdatedUserInfo()
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }


    func juphoonLogin() {
//        DuoRealm.setDefaultRealmForUser(username: "juphoon")
//        let loginEntryVC = JuphoonEntryViewController.controller()
//        let loginEntryNav = JuphoonBaseNavigationViewController(rootViewController: loginEntryVC!)
//        loginEntryNav.view.backgroundColor = .white
//        loginEntryNav.navigationBar.isHidden = true
//        window?.rootViewController = loginEntryNav
//
//        JPUSHService.deleteAlias({ (iResCode, iAlias, seq) in
//        }, seq: 0)

        /// Juphoon Room Login
        JCRoom.shared.client?.displayName = Config.modelUserInfo.sName //JuphoonCommonUserDefault.getNickName()
        JCRoom.shared.client?.login(Config.phone, password: "123", /*serverAddress: "http:cn.router.justalkcloud.com:8080",*/ loginParam: nil)
    }


    public func juphoonMain() {
        /*
        DuoRealm.setDefaultRealmForUser(username: JuphoonCommonUserDefault.getPhone())
        DuoManager.shareInstance.client?.displayName = JuphoonCommonUserDefault.getNickName()
//        DuoManager.shareInstance.client?.login(
//            "duo_" + Config.pswd,
//            password     : Config.GUARDIAN_PASSWORD,
//            serverAddress: Config.JUPHOON_SERVER_ADDRESS,
//            loginParam   : nil
//        )
        DuoManager.shareInstance.client?.login(
            "duo_" + JuphoonCommonUserDefault.getPhone(),
            password     : JuphoonCommonUserDefault.getLoginPassword(),
            serverAddress: Config.JUPHOON_SERVER_ADDRESS,
            loginParam   : nil
        )

        let vcJuphoon: JuphoonMainViewController = UIStoryboard(name: "Home", bundle: nil)
            .instantiateViewController(withIdentifier: "JuphoonMainViewController") as! JuphoonMainViewController
//        let vcNavJuphoon = JuphoonBaseNavigationViewController(rootViewController: vcJuphoon)
//        vcNavJuphoon.view.backgroundColor = .white
//        window?.rootViewController = vcNavJuphoon
        vcJuphoon.modalPresentationStyle = .fullScreen
        UIViewController.currentViewController()?.present(vcJuphoon, animated: false, completion: nil)
        */

        /// JuphoonRoom
//        let vcJoin: JCJoinRoomViewController = UIStoryboard(name: "JCJoinRoom", bundle: nil)
//            .instantiateViewController(withIdentifier: "JCJoinRoomViewController") as! JCJoinRoomViewController
//        vcJoin.modalPresentationStyle = .fullScreen
//        UIViewController.currentViewController()?.present(vcJoin, animated: true, completion: nil)
        DispatchQueue.main.async {
            let vcCurrent = UIViewController.currentViewController()
            if vcCurrent == nil {
                return
            }
            let vcRoom = JCRoomViewController()
            vcRoom.modalPresentationStyle = .fullScreen
            vcRoom.roomId   = Config.juphoon_room_id
            vcRoom.password = Config.juphoon_room_pswd

            vcCurrent?.present(vcRoom, animated: true)
        }
    }

}


extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _            center      : UNUserNotificationCenter,
        willPresent  notification: UNNotification,
        withCompletionHandler  completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        //-- When Notification is arrived while app is running

        //completionHandler([.alert,.sound, .badge])        /// This line shows default popup
        Config.is_launching_from_notification = false
        treatNotification(notification: notification)
    }


    func userNotificationCenter(
        _           center  : UNUserNotificationCenter,
        didReceive  response: UNNotificationResponse,
        withCompletionHandler  completionHandler: @escaping () -> Void
    ) {
        //-- When app launches from Notification
        completionHandler()

        center.getDeliveredNotifications(completionHandler: { notifications in
            self.saveNotifications(notifications: notifications)
        })

        Config.is_launching_from_notification = true
        let notification = response.notification
        treatNotification(notification: notification)
    }


    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification  userInfo: [AnyHashable: Any]
    ) {
    }

}


extension AppDelegate: JPUSHRegisterDelegate {

    func jpushNotificationCenter(
        _ center: UNUserNotificationCenter!,
        openSettingsFor notification: UNNotification!
    ) {
        print("JPUSH : OpenSettingsFor")
    }


    func jpushNotificationAuthorization(
        _        status: JPAuthorizationStatus,
        withInfo info  : [AnyHashable : Any]!
    ) {
        print("JPUSH : StatusWithInfo")
    }


    @available(iOS 10.0, *)
    func jpushNotificationCenter(
        _           center      : UNUserNotificationCenter!,
        willPresent notification: UNNotification!,
        withCompletionHandler completionHandler: ((Int) -> Void)!
    ) {
        print("JPUSH : WillPresentJPush")
    }


    @available(iOS 10.0, *)
    func jpushNotificationCenter(
        _          center  : UNUserNotificationCenter!,
        didReceive response: UNNotificationResponse!,
        withCompletionHandler completionHandler: (() -> Void)!
    ) {
        print("JPUSH : DidReceiveJPush")
    }

}


extension AppDelegate: BMKGeneralDelegate {
    private func onGetNetworkState(_ iError: Int) {
        if iError == 0 {
            print("Baidu Map : Connection is successful")
        }
        else {
            print("Baidu Map : Connection is failed : \(iError)")
        }
    }

    private func onGetPermissionState(_ iError: Int) {
        if iError == 0 {
            print("Baidu Map : Authorization is successful")
        }
        else {
            print("Baidu Map : Authorization is failed :  \(iError)")
        }
    }
}


extension AppDelegate: BMKLocationAuthDelegate {
    func onCheckPermissionState(_ iError: BMKLocationAuthErrorCode) {
        if iError == .success {
            print("Baidu Map : Checking permission is successful")
        }
        else {
            print("Baidu Map : Checking permission is failed")
        }
    }
}


extension AppDelegate: JuphoonCommonDelegate {

    func loginTokenInvalid(error: NSError) {
        guard let nav = self.window?.rootViewController as? UINavigationController else {
            return
        }
        let vc = nav.viewControllers.first as? JuphoonEntryViewController
        if vc == nil {
            commonNeedLogout()
        }
    }


    func modifyNickNameSuccess(nickName: String) {
//        DuoManager.shareInstance.client?.displayName = nickName
    }


    func uploadLog(reason: String) {
        JCLog.uploadLog(reason)
    }


    func commonLoginSuccess() {
        juphoonMain()
    }


    func commonNeedLogout() {
        JuphoonCommonUserDefault.setLoginToken(value:"")
        JuphoonCommonUserDefault.setPhone(value:"")
        JuphoonCommonUserDefault.setNickName(value:"")
        JuphoonCommonUserDefault.setLoginPassword(value:"")
        JuphoonCommonUserDefault.setForgetLastTime(value: 0)
        JuphoonCommonUserDefault.setTempForgetUsername(value:"")
        JuphoonCommonUserDefault.setLastTime(value: 0)
        JuphoonCommonUserDefault.setTempUsername(value:"")

//        DuoManager.shareInstance.client?.logout()
//        juphoonLogin()

        /// Juphoon Room Logout
        JCRoom.shared.client?.logout()
    }


    func commonNet() -> Bool {
        return JCNet.shared()!.hasNet
    }

}
