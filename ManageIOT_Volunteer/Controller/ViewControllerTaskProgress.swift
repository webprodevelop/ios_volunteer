import Foundation
import MarqueeLabel
import UIKit
import JuphoonCommon


protocol ViewControllerTaskProgressDelegate {
    func onTaskProgressTaskFinished()
    func onTaskProgressTaskCanceled()
}


class ViewControllerTaskProgress: UIViewController {

    @IBOutlet weak var viewMap    : UIView!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblType: MarqueeLabel!
    @IBOutlet weak var lblState: MarqueeLabel!
    @IBOutlet weak var lblLocation: MarqueeLabel!
    @IBOutlet weak var lblTime: MarqueeLabel!
    @IBOutlet weak var lblContact1: UILabel!
    @IBOutlet weak var lblContact2: UILabel!
    @IBOutlet weak var lblContact3: UILabel!
    @IBOutlet weak var btnPhone1: UIButton!
    @IBOutlet weak var btnPhone2: UIButton!
    @IBOutlet weak var btnPhone3: UIButton!

    private let ANNOT_VOLUNTEER = "annot_volunteer"
    private let ANNOT_SOS       = "annot_sos"

    var delegate: ViewControllerTaskProgressDelegate? = nil

    private var viewBmkMap: BMKMapView? = nil
    private var alertComplete: UIAlertController? = nil
    private var alertAbandon : UIAlertController? = nil
    private var actionCompleteOk   : UIAlertAction? = nil
    private var actionCompleteDoubt: UIAlertAction? = nil
    private var actionAbandonOk    : UIAlertAction? = nil
    private var actionAbandonCancel: UIAlertAction? = nil
    private var timerComplete: Timer? = nil
    private var timerAbandon : Timer? = nil

    private var iCountTimer: Int = 20


    private var vAnnotVolunteer: [BMKPointAnnotation] = [BMKPointAnnotation]()
    private var annotSos: BMKPointAnnotation? = nil
    
    private var routeSearch: BMKRouteSearch = BMKRouteSearch()
    private var polyline: BMKPolyline? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Init Map
        viewBmkMap = BMKMapView(frame: viewMap.frame)
        viewBmkMap!.delegate = self
        viewBmkMap!.zoomLevel = 13
        viewBmkMap!.showMapScaleBar = false
        viewBmkMap!.mapType = .standard // .satellite
        viewBmkMap!.showsUserLocation = true
        viewMap.addSubview(viewBmkMap!)

        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude : Double(Config.stTaskDetail?.info?.lat ?? "\(Config.current_lat)") ?? 0,
            longitude: Double(Config.stTaskDetail?.info?.lon ?? "\(Config.current_lon)") ?? 0
        )
        viewBmkMap!.setCenter(coordinate, animated: false)

        //-- Init Route
        routeSearch.delegate = self
//        let nodeStart: BMKPlanNode = BMKPlanNode()
//        let nodeEnd  : BMKPlanNode = BMKPlanNode()
//        nodeStart.pt = CLLocationCoordinate2D(
//            latitude : Config.current_lat,
//            longitude: Config.current_lon
//        )
//        nodeEnd.pt = CLLocationCoordinate2D(
//            latitude : Double(Config.stTaskDetail?.info?.lat ?? "124") ?? 124,
//            longitude: Double(Config.stTaskDetail?.info?.lon ?? "40") ?? 40
//        )
//        planOption = BMKWalkingRoutePlanOption()
//        planOption!.from = nodeStart
//        planOption!.to   = nodeEnd

        //-- Init Value
        if Config.stTaskDetail == nil { return }

        txtDescription.text = "任务内容："
        if let task_content = Config.stTaskDetail!.task_content {
            txtDescription.text = "任务内容：" + task_content
        }
        var status: String = ""
        for item in (Config.stTaskDetail!.status ?? []) {
            if item.volunteer_no == 0 {
                /// My Info
                status = status + "您"
            }
            else {
                /// Volunteer Info
                status = status + "志愿者" + String(item.volunteer_no!)
            }
            status += "距离救援点"
            var dDistance = Double(item.distance ?? "0") ?? 0
            var sDistance = ""
            if (dDistance >= 1){
                sDistance = String(format: "%.1f", dDistance) + "公里"
            } else {
                dDistance *= 1000
                sDistance = String(format: "%.1f", dDistance) + "米"
            }
            status += sDistance + "\n"
            addAnnotVolunteer(lat: item.lat!, lon: item.lon!)
        }
        lblStatus.text = status

        lblType.text     = Config.stTaskDetail?.info?.title       ?? ""
        lblState.text    = Config.stTaskDetail?.info?.content     ?? ""
        lblLocation.text = Config.stTaskDetail?.info?.place       ?? ""
        lblTime.text     = Config.stTaskDetail?.info?.create_time ?? ""

        addAnnotSos(
            lat: Config.stTaskDetail?.info?.lat ?? "0",
            lon: Config.stTaskDetail?.info?.lon ?? "0"
        )

        lblContact1.text = ""
        lblContact2.text = ""
        lblContact3.text = ""
        btnPhone1.setTitle("", for: .normal)
        btnPhone2.setTitle("", for: .normal)
        btnPhone3.setTitle("", for: .normal)

        if (Config.stTaskDetail!.contact?.count ?? 0) > 0 {
            lblContact1.text = Config.stTaskDetail?.contact?[0].name ?? ""
            btnPhone1.setTitle(Config.stTaskDetail?.contact?[0].phone ?? "", for: .normal)
        }
        if (Config.stTaskDetail!.contact?.count ?? 0) > 1 {
            lblContact2.text = Config.stTaskDetail?.contact?[1].name ?? ""
            btnPhone2.setTitle(Config.stTaskDetail?.contact?[1].phone ?? "", for: .normal)
        }
        if (Config.stTaskDetail!.contact?.count ?? 0) > 2 {
            lblContact3.text = Config.stTaskDetail?.contact?[2].name ?? ""
            btnPhone3.setTitle(Config.stTaskDetail?.contact?[2].phone ?? "", for: .normal)
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewBmkMap?.viewWillAppear()
        let nodeStart: BMKPlanNode = BMKPlanNode()
        let nodeEnd  : BMKPlanNode = BMKPlanNode()
        
        nodeStart.pt = CLLocationCoordinate2D(
            latitude : Config.current_lat,
            longitude: Config.current_lon
        )
        nodeEnd.pt = CLLocationCoordinate2D(
            latitude : Double(Config.stTaskDetail?.info?.lat ?? "124") ?? 124,
            longitude: Double(Config.stTaskDetail?.info?.lon ?? "40") ?? 40
        )
        let planOption: BMKDrivingRoutePlanOption = BMKDrivingRoutePlanOption()
//        planOption?.drivingPolicy = BMKDrivingPolicy.BMK_DRIVING_TIME_FIRST
        planOption.from = nodeStart
        planOption.to   = nodeEnd
        routeSearch.drivingSearch(planOption)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if polyline != nil {
            viewBmkMap?.remove(polyline!)
            polyline = nil
        }

        viewBmkMap?.viewWillDisappear()
        timerComplete?.invalidate()
        timerComplete = nil
        timerAbandon?.invalidate()
        timerAbandon = nil
    }


    @IBAction func onTouchUpBtnBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpBtnComplete(_ sender: Any) {
        if alertComplete == nil {
            alertComplete = UIAlertController(
                title  : "Your rescue mission has been completed.Thank you for your help. I wish you a happy life.".localized(),
                message: "",
                preferredStyle: UIAlertController.Style.alert
            )
            actionCompleteOk = UIAlertAction(
                title  : "Confirm".localized() + " (20s)",
                style  : UIAlertAction.Style.default,
                handler: { action in
                    self.timerComplete?.invalidate()
                    self.timerComplete = nil
                    self.tryFinishTask()
                }
            )
            actionCompleteDoubt = UIAlertAction(
                title  : "Cancel".localized(),
                style  : UIAlertAction.Style.default,
                handler: { action in
                    self.timerComplete?.invalidate()
                    self.timerComplete = nil
                }
            )
            alertComplete!.addAction(actionCompleteOk!)
            alertComplete!.addAction(actionCompleteDoubt!)
        }
        self.present(alertComplete!, animated: true, completion: nil)

        //-- Timer
        iCountTimer = 20
        timerComplete?.invalidate()
        timerComplete = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.iCountTimer -= 1
            if self.iCountTimer <= 0 {
                self.alertComplete?.dismiss(animated: false, completion: nil)
                self.timerComplete?.invalidate()
                self.timerComplete = nil
                //self.tryFinishTask()
            }
            self.actionCompleteOk?.setValue("Confirm".localized() + " (\(self.iCountTimer)s)", forKey: "title")
        })
    }


    @IBAction func onTouchUpBtnGiveup(_ sender: Any) {
        if alertAbandon == nil {
            alertAbandon = UIAlertController(
                title  : "Are you sure you want to abandon this mission?".localized(),
                message: "Tip: Quitting task ahead of time for no reason, it affects the safety of rescuer and also the individual grade.".localized(),
                preferredStyle: UIAlertController.Style.alert
            )
            actionAbandonOk = UIAlertAction(
                title  : "Confirm".localized() + " (15s)",
                style  : UIAlertAction.Style.default,
                handler: { action in
                    self.timerAbandon?.invalidate()
                    self.timerAbandon = nil
                    //self.tryCancelTask()
                }
            )
            actionAbandonCancel = UIAlertAction(
                title  : "Cancel".localized(),
                style  : UIAlertAction.Style.default,
                handler: { action in
                    self.timerAbandon?.invalidate()
                    self.timerAbandon = nil
                }
            )
            alertAbandon!.addAction(actionAbandonOk!)
            alertAbandon!.addAction(actionAbandonCancel!)
        }
        self.present(alertAbandon!, animated: true, completion: nil)

        //-- Timer
        iCountTimer = 15
        timerAbandon?.invalidate()
        timerAbandon = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.iCountTimer -= 1
            if self.iCountTimer <= 0 {
                self.alertAbandon?.dismiss(animated: false, completion: nil)
                self.timerAbandon?.invalidate()
                self.timerAbandon = nil
                self.tryCancelTask()
            }
            self.actionAbandonOk?.setValue("Confirm".localized() + " (\(self.iCountTimer)s)", forKey: "title")
        })

    }


    @IBAction func onTouchUpBtnContact(_ sender: Any) {
        tryRequestChat()
    }

    
    private func tryFinishTask() {
        var stReq: StReqFinishTask = StReqFinishTask()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.task_id = Config.modelUserInfo.iIdTask

        API.instance.finishTask(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    Config.stTaskDetail = nil
                    Config.modelUserInfo.iIdTask = 0
                    Config.modelUserInfo.sStatus = Config.USER_STATUS_READY

                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: {
                            self.delegate?.onTaskProgressTaskFinished()
                        })
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    private func tryCancelTask() {
        var stReq: StReqCancelTask = StReqCancelTask()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.task_id = Config.modelUserInfo.iIdTask

        API.instance.cancelTask(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.stTaskDetail = nil
                    Config.modelUserInfo.iIdTask = 0
                    Config.modelUserInfo.sStatus = Config.USER_STATUS_READY

                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: {
                            self.delegate?.onTaskProgressTaskCanceled()
                        })
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    private func tryRequestChat() {
        var stReq: StReqRequestChat = StReqRequestChat()
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.token  = Config.modelUserInfo.sToken
        stReq.task_id = String(Config.modelUserInfo.iIdTask)

        API.instance.requestChat(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.juphoon_room_id = stRsp.data?.roomId ?? ""
                    Config.juphoon_room_pswd = stRsp.data?.password ?? ""
                    DispatchQueue.main.async {
                        let app = UIApplication.shared.delegate as? AppDelegate
                        app?.juphoonMain()
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }


    private func addAnnotSos(lat: String, lon: String) {
        annotSos = BMKPointAnnotation()
        annotSos!.coordinate.latitude  = Double(lat) ?? 0
        annotSos!.coordinate.longitude = Double(lon) ?? 0
        viewBmkMap!.addAnnotation(annotSos)
    }


    private func addAnnotVolunteer(lat: String, lon: String) {
        let annotVolunteer = BMKPointAnnotation()
        annotVolunteer.coordinate.latitude  = Double(lat) ?? 0
        annotVolunteer.coordinate.longitude = Double(lon) ?? 0
        vAnnotVolunteer.append(annotVolunteer)
        viewBmkMap!.addAnnotation(annotVolunteer)
    }
}


//-- For BMKMap
extension ViewControllerTaskProgress: BMKMapViewDelegate {

    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        var viewAnnot: BMKPinAnnotationView? = nil

        if Config.stTaskDetail == nil {
            return nil
        }
        if Config.stTaskDetail!.status == nil {
            return nil
        }

        if (annotation as! BMKPointAnnotation) == annotSos {
            viewAnnot = mapView.dequeueReusableAnnotationView(
                withIdentifier: ANNOT_SOS
            ) as? BMKPinAnnotationView
            if viewAnnot == nil {
                viewAnnot = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOT_SOS)
            }
            viewAnnot!.image = UIImage(named: "img_annot_sos")
        }
        else {
            let index = vAnnotVolunteer.firstIndex(of: annotation as! BMKPointAnnotation) ?? -1
            if index < 0 { return nil }

            if index >= Config.stTaskDetail!.status!.count {
                return nil
            }

            let stTaskDetailStatus = Config.stTaskDetail!.status![index]

            viewAnnot = mapView.dequeueReusableAnnotationView(
                withIdentifier: ANNOT_VOLUNTEER + "\(stTaskDetailStatus.volunteer_no ?? 0)"
            ) as? BMKPinAnnotationView
            if viewAnnot == nil {
                viewAnnot = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOT_VOLUNTEER + "\(stTaskDetailStatus.volunteer_no ?? 0)")
            }

            switch stTaskDetailStatus.volunteer_no {
                case 0:
                    viewAnnot?.image = UIImage(named: "img_annot_me")
                    break
                case 1:
                    viewAnnot?.image = UIImage(named: "img_annot_volunteer_1")
                    break
                case 2:
                    viewAnnot?.image = UIImage(named: "img_annot_volunteer_2")
                    break
                case 3:
                    viewAnnot?.image = UIImage(named: "img_annot_volunteer_3")
                    break
                default: break
            }
        }

        return viewAnnot
    }


    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay.isKind(of: BMKPolyline.self) {
            //-- Draw Polyline
            let viewPoly = BMKPolylineView(polyline: overlay as? BMKPolyline)
            viewPoly!.strokeColor = UIColor(red: 48 / 255.0, green: 144 / 255.0, blue: 248 / 255.0, alpha: 1)
            viewPoly!.lineWidth = 5
            viewPoly!.lineCapType = kBMKLineCapRound

            let images = [UIImage(named: "img_track.png")!]
            viewPoly!.loadStrokeTextureImages(images)

            return viewPoly
        }
        return nil
    }
}


extension ViewControllerTaskProgress: BMKRouteSearchDelegate {

    func onGetDrivingRouteResult(_ searcher: BMKRouteSearch!, result: BMKDrivingRouteResult!, errorCode error: BMKSearchErrorCode) {
        if polyline != nil {
            viewBmkMap?.remove(polyline!)
            polyline = nil
        }

        if result == nil || result.routes.first == nil {
            return
        }

        var points: [BMKMapPoint] = [BMKMapPoint]()

        let route: BMKDrivingRouteLine = result.routes.first!
        let steps = route.steps as! [BMKDrivingStep]
        for step in steps {
            for i in 0..<step.pointsCount {
                points.append(step.points[Int(i)])
            }
        }
        let textureIndexes: [NSNumber] = [0]
        polyline = BMKPolyline(
            points: &points,
            count: UInt(points.count),
            textureIndex: textureIndexes
        )
        viewBmkMap!.add(polyline)
    }
    
    func onGetWalkingRouteResult(_ searcher: BMKRouteSearch!, result: BMKWalkingRouteResult!, errorCode error: BMKSearchErrorCode) {
        if polyline != nil {
            viewBmkMap?.remove(polyline!)
            polyline = nil
        }

        if result == nil || result.routes.first == nil {
            return
        }

        var points: [BMKMapPoint] = [BMKMapPoint]()

        let route: BMKWalkingRouteLine = result.routes.first!
        let steps = route.steps as! [BMKWalkingStep]
        for step in steps {
            for i in 0..<step.pointsCount {
                points.append(step.points[Int(i)])
            }
        }
        let textureIndexes: [NSNumber] = [0]
        polyline = BMKPolyline(
            points: &points,
            count: UInt(points.count),
            textureIndex: textureIndexes
        )
        viewBmkMap!.add(polyline)
    }

}
