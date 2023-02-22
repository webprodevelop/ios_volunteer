import UIKit
import SwiftyJSON


class ViewControllerMain: UIViewController {

    @IBOutlet weak var lblTitle   : UILabel!
    @IBOutlet weak var btnBack    : UIButton!
    @IBOutlet weak var btnMessage : UIButton!
    @IBOutlet weak var viewAnchorMessage: UIView!
    @IBOutlet weak var viewContent: UIView!

    @IBOutlet weak var viewProfileBar: UIView!
    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var imgStar1: UIImageView!
    @IBOutlet weak var imgStar2: UIImageView!
    @IBOutlet weak var imgStar3: UIImageView!
    @IBOutlet weak var imgStar4: UIImageView!
    @IBOutlet weak var imgStar5: UIImageView!
    @IBOutlet weak var btnMessageProfile: UIButton!
    @IBOutlet weak var viewAnchorMessageProfile: UIView!

    @IBOutlet weak var btnMain: UIButton!
    @IBOutlet weak var btnMine: UIButton!
    @IBOutlet weak var btnStatusCircle: UIButton!
    @IBOutlet weak var btnStatus: UIButton!

    @IBOutlet weak var viewMask: UIView!
    @IBOutlet weak var indicatorProgress: UIActivityIndicatorView!


    //-- Constants
    private var API_COUNT = 2

    private let VC_NONE         = 0
    private let VC_DASHBOARD    = 1
    private let VC_MINE         = 2
    private let VC_TASK         = 3

    //-- ViewControllers : Main
    private var vcDashboard: ViewControllerDashboard? = nil
    private var vcMine     : ViewControllerMine?      = nil
    private var vcTask     : ViewControllerTask?      = nil

    //-- ViewControllers : Individual
    private var vcUserStatusTerm: ViewControllerUserStatusTerm? = nil
    private var vcTaskAlert     : ViewControllerTaskAlert?      = nil
    private var vcTaskProgress  : ViewControllerTaskProgress?   = nil
//    private var vcPersonal      : ViewControllerPersonal?       = nil

    //-- ViewControllers : Misc
    private var vcHealth   : ViewControllerHealth?    = nil
    private var vcPosition : ViewControllerPosition?  = nil
    private var vcNews     : ViewControllerNews?      = nil
    private var vcDevice   : ViewControllerDevice?    = nil

    //-- Variables
    private var iVcCurrent: Int = 0     /// VC_NONE
    private var iApiReceived: Int = 0
    private var iCountWatch : Int = 0
    private var sDateUpdated: String = ""
    private var modelAlarm: ModelAlarm = ModelAlarm()
    private var searchPoi : BMKPoiSearch = BMKPoiSearch()
//    private let locManager: CLLocationManager = CLLocationManager()
    private let locManager: BMKLocationManager = BMKLocationManager()
    private var bUpdatedLocation: Bool = false
    private var timerUpdateLocation: Timer? = nil

    //-- Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        Config.vcMain = self
        DbManager.instance.createDb()
        //-- Juphoon Client Login
        let app = UIApplication.shared.delegate as? AppDelegate
        app?.juphoonLogin()

        //-- Alipay
        AlipaySDK.defaultService()

        //-- Init UI
        btnBack.isHidden = true
        viewAnchorMessage.isHidden = true
        viewAnchorMessageProfile.isHidden = true

        updateBtnStatus()
        updateUserInfo()

        showViewControllerDashboard()

        showProgressBar()

        //-- Location Manager
        searchPoi.delegate = self

//        locManager.requestAlwaysAuthorization()
//        locManager.requestWhenInUseAuthorization()
        locManager.requestNetworkState()

        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locManager.startUpdatingLocation()

        //-- Timer UpdateLocation
        timerUpdateLocation = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { timer in
            self.tryUpdateLocation()
        }

        //-- Call Initial APIs, count = API_COUNT
        tryGetNewsList()

        checkIsLaunchingFromNotification()
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Config.addUserInfoDelegate(delegate: self)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Config.delUserInfoDelegate(delegate: self)
    }


    @IBAction func onTouchUpBtnBack(_ sender: Any) {
        switch iVcCurrent {
            case VC_DASHBOARD:
                vcDashboard?.onBack()
                break
            case VC_MINE:
                vcMine?.onBack()
                break
            case VC_TASK:
                vcTask?.onBack()
            default: break
        }
    }


    @IBAction func onTouchUpMessage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Message", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerMessage") as! ViewControllerMessage
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }


    @IBAction func onTouchUpBtnMain(_ sender: Any) {
        if iVcCurrent == VC_DASHBOARD {
            return
        }
        btnMain.setBackgroundImage(UIImage(named: "img_main_f"), for: .normal)
        btnMine.setBackgroundImage(UIImage(named: "img_mine_e"), for: .normal)
        showViewControllerDashboard()
    }


    @IBAction func onTouchUpBtnMine(_ sender: Any) {
        if iVcCurrent == VC_MINE {
            return
        }
        btnMain.setBackgroundImage(UIImage(named: "img_main_e"), for: .normal)
        btnMine.setBackgroundImage(UIImage(named: "img_mine_f"), for: .normal)
        showViewControllerMine()
    }


    @IBAction func onTouchUpBtnStatus(_ sender: Any) {
        if iVcCurrent == VC_TASK {
            if Config.modelUserInfo.sStatus == Config.USER_STATUS_DISABLED {
                trySetUserStatusReady()
            }
            if Config.modelUserInfo.sStatus == Config.USER_STATUS_READY {
                trySetUserStatusDisabled()
            }
            if Config.modelUserInfo.sStatus == Config.USER_STATUS_WORKING {
            }
        }
        else {
            if Config.modelUserInfo.iIdTask <= 0 {
                showViewControllerTask()
                if !Config.getHideUserStatusTerm() {
                    showViewControllerUserStatusTerm()
                }
            }
            else {
                showViewControllerTaskProgress()
            }
        }
    }


    private func clearFlagIsLaunchingFromNotification() {
        Config.is_launching_from_notification          = false
        Config.is_launching_from_notification_task     = false
        Config.is_launching_from_notification_chat     = false
        Config.is_launching_from_notification_pay      = false
    }


    private func checkIsLaunchingFromNotification() {
        if Config.is_launching_from_notification {
            if Config.is_launching_from_notification_task {
                tryGetTaskDetail(taskId: Config.modelUserInfo.iIdTask)
            }
            else if Config.is_launching_from_notification_chat {
                /// Wait some until juphoonLogin finishes
                Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { timer in
                    let app = UIApplication.shared.delegate as? AppDelegate
                    app?.juphoonMain()
                })
                clearFlagIsLaunchingFromNotification()
            }
            else if Config.is_launching_from_notification_pay {
                if Config.pay_status == "success" {
                    showAlert(title: "Notify".localized(), message: "Payment has been successfully completed.".localized())
                }
                else {
                    showAlert(title: "Notify".localized(), message: "Payment has been failed.".localized())
                }
                clearFlagIsLaunchingFromNotification()
            }
        }
        else {
            if Config.modelUserInfo.iIdTask > 0 {
                tryGetTaskDetail(taskId: Config.modelUserInfo.iIdTask)
            }
        }
    }


    private func updateUserInfo() {
        imgPhoto.makeRounded()
        if let url = URL(string: Config.modelUserInfo.sPicture) {
            if !imgPhoto.loadImage(url: url) {
                imgPhoto.image = UIImage(named: "img_photo_empty")
            }
        }
        else {
            imgPhoto.image = UIImage(named: "img_photo_empty")
        }
        lblName.text = Config.modelUserInfo.sName
        lblGrade.text = "V\(Config.modelUserInfo.iPointLevel)"

        imgStar1.isHidden = true
        imgStar2.isHidden = true
        imgStar3.isHidden = true
        imgStar4.isHidden = true
        imgStar5.isHidden = true
        if Config.modelUserInfo.iPointLevel > 0 { imgStar1.isHidden = false }
        if Config.modelUserInfo.iPointLevel > 1 { imgStar2.isHidden = false }
        if Config.modelUserInfo.iPointLevel > 2 { imgStar3.isHidden = false }
        if Config.modelUserInfo.iPointLevel > 3 { imgStar4.isHidden = false }
        if Config.modelUserInfo.iPointLevel > 4 { imgStar5.isHidden = false }
    }


    private func showMessageMark() {
        btnMessage.isHidden = false
        btnMessageProfile.isHidden = false
        viewAnchorMessage.isHidden = false
        viewAnchorMessageProfile.isHidden = false
    }


    private func hideMessageMark() {
        btnMessage.isHidden = true
        btnMessageProfile.isHidden = true
        viewAnchorMessage.isHidden = true
        viewAnchorMessageProfile.isHidden = true
    }


    public func updateBtnStatus() {
        var sImageStatus: String = "img_status_disabled"
        if Config.modelUserInfo.sStatus == Config.USER_STATUS_DISABLED {
            sImageStatus = "img_status_disabled"
        }
        else if Config.modelUserInfo.sStatus == Config.USER_STATUS_READY {
            sImageStatus = "img_status_ready"
        }
        else if Config.modelUserInfo.sStatus == Config.USER_STATUS_WORKING {
            sImageStatus = "img_status_working"
        }
        btnStatus.setBackgroundImage(UIImage(named: sImageStatus), for: .normal)
    }


    public func showProgressBar() {
        DispatchQueue.main.async {
            self.viewMask.isHidden = false
            self.indicatorProgress.startAnimating()
            self.indicatorProgress.isHidden = false
        }
    }


    public func hideProgressBar() {
        DispatchQueue.main.async {
            self.viewMask.isHidden = true
            self.indicatorProgress.stopAnimating()
            self.indicatorProgress.isHidden = true
        }
    }


    public func isProgressing() -> Bool {
        return indicatorProgress.isAnimating
    }


    private func showViewControllerDashboard() {
        viewProfileBar.isHidden = false
        lblTitle.text = "DoorKeeper".localized()
        btnBack.isHidden = true
        iVcCurrent = VC_DASHBOARD
        vcMine?.dismissChildren()
        vcMine?.dismissFromParent()
        vcTask?.dismissChildren()
        vcTask?.dismissFromParent()

        if vcDashboard == nil {
            let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
            vcDashboard = storyboard.instantiateViewController(withIdentifier: "ViewControllerDashboard") as? ViewControllerDashboard
        }
        vcDashboard?.delegate = self
        addChildViewController(child: vcDashboard!, container: viewContent, frame: viewContent.bounds)
    }


    private func showViewControllerMine() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Mine".localized()
        btnBack.isHidden = true
        iVcCurrent = VC_MINE
        vcDashboard?.dismissChildren()
        vcDashboard?.dismissFromParent()
        vcTask?.dismissChildren()
        vcTask?.dismissFromParent()

        if vcMine == nil {
            let storyboard = UIStoryboard(name: "Mine", bundle: nil)
            vcMine = storyboard.instantiateViewController(withIdentifier: "ViewControllerMine") as? ViewControllerMine
        }
        vcMine!.delegate = self
        addChildViewController(child: vcMine!, container: viewContent, frame: viewContent.bounds)
    }


    private func showViewControllerTask() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Wait for Task".localized()
        btnBack.isHidden = true
        iVcCurrent = VC_TASK
        vcDashboard?.dismissChildren()
        vcDashboard?.dismissFromParent()
        vcMine?.dismissChildren()
        vcMine?.dismissFromParent()
        
        if vcTask == nil {
            let storyboard = UIStoryboard(name: "Task", bundle: nil)
            vcTask = storyboard.instantiateViewController(withIdentifier: "ViewControllerTask") as? ViewControllerTask
        }
        vcTask!.delegate = self
        addChildViewController(child: vcTask!, container: viewContent, frame: viewContent.bounds)
        // show alert
        if Config.modelUserInfo.iIdTask > 0 && Config.stTaskDetail?.task_status == Config.TASK_STATUS_WAIT_ALLOC {
            if let vcMain = Config.vcMain {
               vcMain.showViewControllerTaskAlert()
            }
        }
    }

    private func showViewControllerUserStatusTerm() {
        if vcUserStatusTerm == nil {
            let storyboard = UIStoryboard(name: "UserStatusTerm", bundle: nil)
            vcUserStatusTerm = storyboard.instantiateViewController(withIdentifier: "ViewControllerUserStatusTerm") as? ViewControllerUserStatusTerm
            vcUserStatusTerm!.modalPresentationStyle = .overCurrentContext
        }
        present(vcUserStatusTerm!, animated: false, completion: nil)
    }


    public func showViewControllerTaskAlert() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Confirm Rescue".localized()
        btnBack.isHidden = false

        if let vcPresent = self.presentedViewController {
            vcPresent.dismiss(animated: false, completion: {
//                if self.vcTaskAlert == nil {
                    let storyboard = UIStoryboard(name: "TaskAlert", bundle: nil)
                    self.vcTaskAlert = storyboard.instantiateViewController(withIdentifier: "ViewControllerTaskAlert") as? ViewControllerTaskAlert
                    self.vcTaskAlert!.modalPresentationStyle = .overCurrentContext
//                }
                self.vcTaskAlert!.delegate = self
                self.present(self.vcTaskAlert!, animated: false, completion: nil)
            })
        }
        else {
//            if vcTaskAlert == nil {
                let storyboard = UIStoryboard(name: "TaskAlert", bundle: nil)
                vcTaskAlert = storyboard.instantiateViewController(withIdentifier: "ViewControllerTaskAlert") as? ViewControllerTaskAlert
                vcTaskAlert!.modalPresentationStyle = .overCurrentContext
//            }
            vcTaskAlert!.delegate = self
            present(vcTaskAlert!, animated: false, completion: nil)
        }
    }
    
    public func showViewControllerTaskProgress() {
        if Config.modelUserInfo.iIdTask > 0 && Config.stTaskDetail?.task_status == Config.TASK_STATUS_PENDING {
            if let vcPresent = self.presentedViewController {
                vcPresent.dismiss(animated: false, completion: {
//                    if self.vcTaskProgress == nil {
                        let storyboard = UIStoryboard(name: "TaskProgress", bundle: nil)
                        self.vcTaskProgress = storyboard.instantiateViewController(withIdentifier: "ViewControllerTaskProgress") as? ViewControllerTaskProgress
                        self.vcTaskProgress!.modalPresentationStyle = .fullScreen
//                    }
                    self.vcTaskProgress!.delegate = self
                    self.present(self.vcTaskProgress!, animated: false, completion: nil)
                })
            }
            else {
//                if vcTaskProgress == nil {
                    let storyboard = UIStoryboard(name: "TaskProgress", bundle: nil)
                    vcTaskProgress = storyboard.instantiateViewController(withIdentifier: "ViewControllerTaskProgress") as? ViewControllerTaskProgress
                    vcTaskProgress!.modalPresentationStyle = .fullScreen
//                }
                vcTaskProgress!.delegate = self
                present(vcTaskProgress!, animated: false, completion: nil)
            }
        }else{
            showViewControllerTask()
        }
    }

/*
    private func showViewControllerPersonal() {
        if vcPersonal == nil {
            let storyboard = UIStoryboard(name: "Personal", bundle: nil)
            vcPersonal = storyboard.instantiateViewController(withIdentifier: "ViewControllerPersonal")
            vcPersonal!.modalPresentationStyle = .fullScreen
        }
        vcPersonal!.delegate = self
        present(vcPersonal!, animated: false, completion: nil)
    }
*/

    func stopTimer() {
        if timerUpdateLocation == nil { return }
        timerUpdateLocation?.invalidate()
        timerUpdateLocation = nil
    }


    private func tryGeoConv(x: Double, y: Double) {
        var stReq: StReqGeoConv = StReqGeoConv()

        stReq.coords = "\(x),\(y)"
        stReq.ak     = Config.BAIDU_MAP_KEY

        API.instance.geoConv(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.status != 0 {
                        break
                    }
                    Config.current_lat = stRsp.result?[0].x ?? Config.DEFAULT_LAT
                    Config.current_lon = stRsp.result?[0].y ?? Config.DEFAULT_LON
                    searchNearBy(
                        searchPoi: self.searchPoi,
                        lat: String(Config.current_lat),
                        lon: String(Config.current_lon)
                    )
                    self.vcDashboard?.updateUserLocation()
                    break

                case .failure(_):
                    break
            }
        }
    }


    private func tryGetNewsList() {
        var stReq: StReqGetNewsList = StReqGetNewsList()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.last_release_time = ""

        API.instance.getNewsList(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    if stRsp.data == nil { break }
                    if stRsp.data!.hot_recommend != nil {
                        for stRspSubData in stRsp.data!.hot_recommend! {
                            let model = ModelNews()
                            model.copyFromApiData(data: stRspSubData)
                            // When insert fails, don't call update, keep read flag remains in db
                            DbManager.instance.insertNews(model: model)
                        }
                    }
                    if stRsp.data!.common_sense != nil {
                        for stRspSubData in stRsp.data!.common_sense! {
                            let model = ModelNews()
                            model.copyFromApiData(data: stRspSubData)
                            // When insert fails, don't call update, keep read flag remains in db
                            DbManager.instance.insertNews(model: model)
                        }
                    }

                    DispatchQueue.main.async {
                        self.vcDashboard?.updateData()
                    }
                    break

                case .failure(_):
                    break
            }
            //-- Check Api Received Count
            self.iApiReceived = self.iApiReceived + 1
            if self.iApiReceived == self.API_COUNT {
                self.hideProgressBar()
            }

            self.tryGetAllNotificationList()
        }
    }

    func tryGetAllNotificationList() {
        var stReq: StReqGetAllNotificationList = StReqGetAllNotificationList()
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.token  = Config.modelUserInfo.sToken

        API.instance.getAllNotificationList(stReq: stReq) { [self] result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    for data in stRsp.data ?? [] {
                        let message = ModelMessage()

                        message.iId = data.id!
                        message.iRead = data.readStatus! ? 1 : 0

                        let sDate     = data.updatedTimeStr!
                        let sCategory = data.title!
                        let sBody     = data.msg!

                        let dataJson = data.dataJson!
                        do {
                            message.sCategory = sCategory
                            message.sBody = sBody
                            message.sData = dataJson
                            message.sTime = sDate

                            DbManager.instance.insertMessage(model: message)
                        }
                        catch {
                        }
                    }

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }

            //-- Check Api Received Count
            self.iApiReceived = self.iApiReceived + 1
            if self.iApiReceived == self.API_COUNT {
                self.hideProgressBar()
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
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.sStatus = Config.USER_STATUS_READY
                    DispatchQueue.main.async {
                        self.updateBtnStatus()
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }


    private func trySetUserStatusDisabled() {
        var stReq: StReqSetUserStatusDisabled = StReqSetUserStatusDisabled()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile

        API.instance.setUserStatusDisabled(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.sStatus = Config.USER_STATUS_DISABLED
                    DispatchQueue.main.async {
                        self.updateBtnStatus()
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }


    private func tryGetTaskDetail(taskId: Int) {
        var stReq: StReqGetTaskDetail = StReqGetTaskDetail()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.task_id = taskId

        API.instance.getTaskDetail(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg ?? "")
                        break
                    }
                    if stRsp.data == nil { break }
                    Config.stTaskDetail = stRsp.data!
                    Config.modelUserInfo.iIdTask = Config.stTaskDetail?.task_id ?? 0
                    
                    if Config.modelUserInfo.iIdTask > 0 && (Config.stTaskDetail?.task_status == Config.TASK_STATUS_WAIT_ALLOC || Config.stTaskDetail?.task_status == Config.TASK_STATUS_PENDING) {
                        DispatchQueue.main.async {
                            self.showViewControllerTaskProgress()
                        }
                    }
                    self.clearFlagIsLaunchingFromNotification()

                    break

                case .failure(_):
                    break
            }
        }
    }


    private func tryUpdateLocation() {
        if Config.current_lat == 0, Config.current_lon == 0 {
            return
        }
        if Config.modelUserInfo.sStatus != Config.USER_STATUS_READY,
           Config.modelUserInfo.sStatus != Config.USER_STATUS_WORKING {
            return
        }

        var stReq: StReqUpdateLocation = StReqUpdateLocation()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.lat    = String(Config.current_lat)
        stReq.lon    = String(Config.current_lon)
        stReq.province = Config.current_province
        stReq.city     = Config.current_city
        stReq.district = Config.current_district

        API.instance.updateLocation(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }

}


//-- BMKPoiSearchDelegate
extension ViewControllerMain: BMKPoiSearchDelegate {

    func onGetPoiResult(_ searcher: BMKPoiSearch!, result: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode != BMK_SEARCH_NO_ERROR { return }
        if result.poiInfoList.count <= 0 { return }

        for poiInfo in result.poiInfoList {
            if !poiInfo.name.isEmpty {
                Config.current_addr = poiInfo.name
                Config.current_province = poiInfo.province
                Config.current_city     = poiInfo.city
                Config.current_district = poiInfo.area

                if !bUpdatedLocation {
                    tryUpdateLocation()
                    bUpdatedLocation = true
                }
                break
            }
        }
    }

}


//-- BMKLocationManagerDelegate
extension ViewControllerMain: BMKLocationManagerDelegate {

    func bmkLocationManager(
        _ manager: BMKLocationManager,
        didUpdate location: BMKLocation?,
        orError error: Error?
    ) {
        /// Convert GCJ02 to BMK09LL
        /// Must be set BMK09LL in BMKMapManager.setCoordinateTypeUsedInBaiduMapSDK()
        let coord = BMKLocationManager.bmkLocationCoordinateConvert(
            location!.location!.coordinate,
            srcType: .GCJ02,
            desType: .BMK09LL
        )
        Config.current_lat = coord.latitude
        Config.current_lon = coord.longitude
        searchNearBy(searchPoi: searchPoi, lat: String(Config.current_lat), lon: String(Config.current_lon))
        vcDashboard?.updateUserLocation()
    }
}

//-- CLLocationManagerDelegate
extension ViewControllerMain: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = manager.location?.coordinate else { return }
        tryGeoConv(x: coord.latitude, y: coord.longitude)
    }

}


//-- ViewControllerDashboardDelegate
extension ViewControllerMain: ViewControllerDashboardDelegate {

    func onDashboardPresent() {
        viewProfileBar.isHidden = false
        lblTitle.text = "DoorKeeper".localized()
        btnBack.isHidden = true
    }


    func onDashboardPresentHotspot() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Hotspot".localized()
        btnBack.isHidden = false
    }


    func onDashboardPresentSense() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Sense".localized()
        btnBack.isHidden = false
    }


    func onDashboardPresentRecommend() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Hotspot".localized()
        btnBack.isHidden = false
    }


    func onDashboardPresentPetbite() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Petbite".localized()
        btnBack.isHidden = false
    }


    func onDashboardPresentRescueQuery() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Rescue Query".localized()
        btnBack.isHidden = false
    }


    func onDashboardPresentRescueDetail() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Rescue Detail".localized()
        btnBack.isHidden = false
    }


    func onDashboardPresentRescueProcess() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Rescue Process".localized()
        btnBack.isHidden = false
    }


    func onDashboardTouchUpBtnTask() {
        if Config.modelUserInfo.iIdTask <= 0 {
            showViewControllerTask()
        }
        else {
            
                showViewControllerTaskProgress()
            
        }
    }

}


//-- ViewControllerTaskDelegate
extension ViewControllerMain: ViewControllerTaskDelegate {
}


//-- ViewControllerTaskAlertDelegate
extension ViewControllerMain: ViewControllerTaskAlertDelegate {

    func onTaskAlertDismiss(isConfirmed: Bool) {
        viewProfileBar.isHidden = true
        lblTitle.text = "Wait for Task".localized()
        btnBack.isHidden = true
        
        updateBtnStatus()
        if isConfirmed {
            showViewControllerTaskProgress()
        }
    }
}


//-- ViewControllerTaskProgressDelegate
extension ViewControllerMain: ViewControllerTaskProgressDelegate {

    func onTaskProgressTaskFinished() {
        updateBtnStatus()
    }


    func onTaskProgressTaskCanceled() {
        updateBtnStatus()
    }
}


//-- ViewControllerMessageDelegate
extension ViewControllerMain: ViewControllerMessageDelegate {

    func onMessageClicked() {
        showViewControllerTaskProgress()
    }

}


//-- ViewControllerMineDelegate
extension ViewControllerMain: ViewControllerMineDelegate {

    func onMinePresent() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Mine".localized()
        btnBack.isHidden = true
    }


    func onMinePresentIntegralGrade() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Integral Degree".localized()
        btnBack.isHidden = false
    }


    func onMinePresentCashInHistory() {
        viewProfileBar.isHidden = true
        lblTitle.text = "CashIn History".localized()
        btnBack.isHidden = false
    }


    func onMinePresentIntegralRule() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Integral Rule".localized()
        btnBack.isHidden = false
    }


    func onMinePresentRescueQuery() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Rescue Query".localized()
        btnBack.isHidden = false
    }


    func onMinePresentRescueDetail() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Rescue Detail".localized()
        btnBack.isHidden = false
    }


    func onMinePresentRescueProcess() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Rescue Process".localized()
        btnBack.isHidden = false
    }


    func onMinePresentPayment() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Payment".localized()
        btnBack.isHidden = false
    }


    func onMinePresentBankAccount() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Bank Account".localized()
        btnBack.isHidden = false
    }


    func onMinePresentBankCard() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Bank Account".localized()
        btnBack.isHidden = false
    }


    func onMinePresentBankPassword() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Modify Password".localized()
        btnBack.isHidden = false
    }


    func onMinePresentBankForgot() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Modify Password".localized()
        btnBack.isHidden = false
    }


    func onMinePresentAccountAlipay() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Alipay Account".localized()
        btnBack.isHidden = false
    }


    func onMinePresentAccountWechat() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Wechat Account".localized()
        btnBack.isHidden = false
    }


    func onMinePresentPassword() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Modify Password".localized()
        btnBack.isHidden = false
    }


    func onMinePresentAgree() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Agreement".localized()
        btnBack.isHidden = false
    }


    func onMinePresentPolicy() {
        viewProfileBar.isHidden = true
        lblTitle.text = "Policy".localized()
        btnBack.isHidden = false
    }

}

/*
//-- ViewControllerPersonalDelegate
extension ViewControllerMain: ViewControllerPersonalDelegate {

    func onPersonalSuccess() {

    }
}
*/

//-- UserInfoDelegate
extension ViewControllerMain: UserInfoDelegate {

    func onUpdatedUserInfo() {
        DispatchQueue.main.async {
            self.updateUserInfo()
        }
    }
}
