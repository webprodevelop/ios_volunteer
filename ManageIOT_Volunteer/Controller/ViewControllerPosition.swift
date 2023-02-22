import Foundation
import UIKit


protocol ViewControllerPositionDelegate: AnyObject {
    func onPositionTrack()
}


class ViewControllerPosition: UIViewController {

    @IBOutlet weak var viewMap    : UIView!
    @IBOutlet weak var viewInfo   : UIView!
    @IBOutlet weak var viewToolBar: UIView!
    @IBOutlet weak var viewNavBar : UIView!
    @IBOutlet weak var viewSeekBar: UIView!
    @IBOutlet weak var btnPlay    : UIButton!
    @IBOutlet weak var slider     : UISlider!
    @IBOutlet weak var lblOffline : UILabel!
    @IBOutlet weak var lblInfoName: UILabel!
    @IBOutlet weak var lblInfoAddr: UILabel!
    @IBOutlet weak var lblInfoTime: UILabel!
    @IBOutlet weak var lblNavName : UILabel!
    @IBOutlet weak var lblNavAddr : UILabel!

    let ANNOT_CUR = "annot_cur"
    let ANNOT_END = "annot_end"

    var delegate: ViewControllerPositionDelegate? = nil

    var viewBmkMap: BMKMapView? = nil
    var annotCur  : BMKPointAnnotation? = nil
    var annotEnd  : BMKPointAnnotation? = nil
    var polyline  : BMKPolyline? = nil

    var searchPoi  : BMKPoiSearch = BMKPoiSearch()
    var bSearchable: Bool = true

    var track    : [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var iIndexPos: Int = 0
    var dAngle   : Double = 90
    var timer    : Timer? = nil

    var sLat: String = String(Config.DEFAULT_LAT)
    var sLon: String = String(Config.DEFAULT_LON)

    var bPlaying: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Border of views
        viewToolBar.layer.borderColor = UIColor.gray.cgColor
        viewToolBar.layer.borderWidth = 1
        viewInfo.layer.borderColor = UIColor.gray.cgColor
        viewInfo.layer.borderWidth = 1

        if Config.id_watch_monitoring <= 0 { return }
        if isBeforeDay(sDate: Config.modelWatchMonitoring.sServiceEnd) { return }

        //-- Init UI
        if Config.modelWatchMonitoring.bNetStatus {
            lblOffline.isHidden = true
        }
        else {
            lblOffline.isHidden = false
        }
        viewInfo.isHidden = true
        viewSeekBar.isHidden = true

        lblNavName.text  = Config.modelWatchMonitoring.sUserName
        lblNavAddr.text  = Config.modelWatchMonitoring.sAddress
        lblInfoName.text = Config.modelWatchMonitoring.sUserName
        lblInfoAddr.text = ""
        lblInfoTime.text = ""

        //-- Init Map
        viewBmkMap = BMKMapView(frame: viewMap.frame)
        viewBmkMap!.delegate = self
        viewBmkMap!.zoomLevel = 17
        viewBmkMap!.showMapScaleBar = false
        viewBmkMap!.mapType = .standard // .satellite
        viewBmkMap!.showsUserLocation = true
        viewMap.addSubview(viewBmkMap!)

        searchPoi.delegate = self

        //-- Get Watch Pos
        // TODO : Uncomment later
        //if Config.ID_WATCH_MONITORING > 0, Config.modelWatchMonitoring.bNetStatus {
            tryGetWatchPos()
        //}
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewBmkMap?.viewWillAppear()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewBmkMap?.viewWillDisappear()
        searchPoi.delegate = nil
    }


    @IBAction func onTouchUpSetting(_ sender: Any) {
        if Config.id_watch_monitoring <= 0 { return }
        if isBeforeDay(sDate: Config.modelWatchMonitoring.sServiceEnd) { return }

        if !Config.modelWatchMonitoring.bIsManager {
            showToast(message: "You have no permission".localized(), completion: nil)
            //return    // TODO : Uncomment later
        }
        let storyboard = UIStoryboard(name: "PositionSetting", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerPositionSetting")
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated:false, completion: nil)
    }


    @IBAction func onTouchUpTrack(_ sender: Any) {
        if Config.id_watch_monitoring <= 0 { return }
        if isBeforeDay(sDate: Config.modelWatchMonitoring.sServiceEnd) { return }

        delegate?.onPositionTrack()     // Show Back button in Main VC

        viewToolBar.isHidden = true
        viewInfo.isHidden    = false
        viewNavBar.isHidden  = true
        viewSeekBar.isHidden = false
        tryGetWatchPosList()
    }


    @IBAction func onTouchUpShare(_ sender: Any) {
        if Config.id_watch_monitoring <= 0 { return }
        if isBeforeDay(sDate: Config.modelWatchMonitoring.sServiceEnd) { return }

    // {{ Sharing vcf File
//        let coordinate = CLLocationCoordinate2D(
//            latitude : Double(sLat) ?? Config.DEFAULT_LAT,
//            longitude: Double(sLon) ?? Config.DEFAULT_LON
//        )
//        let urlVCard = generateUrlVCard(
//            coordinate: coordinate,
//            name      : Config.modelWatchMonitoring.sUserName
//        )
//        let controller = UIActivityViewController(
//            activityItems: [urlVCard] as[Any],
//            applicationActivities: nil
//        )
//
//        //-- Avoid Crash on iPad
//        if let popover = controller.popoverPresentationController {
//            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
//            popover.sourceView = self.view
//            popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
//        }
//
//        present(controller, animated: true, completion: nil)
    // }} Sharing vcf File

    // {{ Sharing URL String
        var url = "http://api.map.baidu.com/direction?origin=latlng:"
        url = url + String(Config.current_lat) + "," + String(Config.current_lon)
        url = url + "|name:" + Config.current_addr
        url = url + "&destination=" + (lblNavAddr.text ?? "")
        url = url + "&mode=driving"
        url = url + "&region=中国"
        url = url + "&output=html&src=webapp.baidu.openAPIdemo"

        let controller = UIActivityViewController(
            activityItems: [url] as [Any],
            applicationActivities: nil
        )

        //-- Avoid Crash on iPad
        if let popover = controller.popoverPresentationController {
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.sourceView = self.view
            popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        present(controller, animated: true, completion: nil)
    // }} Sharing URL String
    }


    @IBAction func onTouchUpPlay(_ sender: Any) {
        bPlaying = !bPlaying
        if bPlaying {
            btnPlay.setImage(UIImage(named: "img_pause.png"), for: .normal)

            iIndexPos = 0
            slider.setValue(0, animated: false)
            updateAnnotEnd()

            timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { timer in
                self.iIndexPos = self.iIndexPos + 1
                if self.iIndexPos >= self.track.count {
                    self.btnPlay.setImage(UIImage(named: "img_play.png"), for: .normal)
                    self.timer?.invalidate()
                    self.timer = nil
                }
                else {
                    self.slider.setValue(Float(self.iIndexPos), animated: false)
                    self.updateAnnotEnd()
                }
            })
        }
        else {
            btnPlay.setImage(UIImage(named: "img_play.png"), for: .normal)
            timer?.invalidate()
            timer = nil
        }
    }


    @IBAction func onChangedSlider(_ sender: Any) {
        let value = slider.value
        let iPos = Int(value)

        if iPos != iIndexPos {
            iIndexPos = iPos
            slider.setValue(Float(iIndexPos), animated: false)
            updateAnnotEnd()
        }
    }


    func onTouchUpBack() {
        //-- This func is called from Main VC
        viewToolBar.isHidden = false
        viewInfo.isHidden    = true
        viewNavBar.isHidden  = false
        viewSeekBar.isHidden = true

        if polyline != nil {
            viewBmkMap?.remove(polyline!)
            polyline = nil
        }
        if annotEnd != nil {
            viewBmkMap!.removeAnnotation(annotEnd)
            annotEnd = nil
        }
    }


    func updateAnnotCur(lat: String, lon: String) {
        if annotCur == nil {
            annotCur = BMKPointAnnotation()
            viewBmkMap!.addAnnotation(annotCur!)
        }
        annotCur!.coordinate.latitude  = Double(lat) ?? 0
        annotCur!.coordinate.longitude = Double(lon) ?? 0
        viewBmkMap!.setCenter(annotCur!.coordinate, animated: false)
    }


    func updateAnnotEnd() {
        if track.count == 0 { return }
        //-- Calc Angle
        if track.count == 1 {
            dAngle = Double.pi / 2
        }
        else {
            var iPrev = iIndexPos
            if iPrev == track.count - 1 {
                iPrev = track.count - 2
            }
            let iNext = iPrev + 1
            let dX = track[iNext].longitude - track[iPrev].longitude
            let dY = track[iNext].latitude  - track[iPrev].latitude
            dAngle = atan2(dX, dY)
        }

        dAngle = dAngle - Double(viewBmkMap?.rotation ?? 0) / 180.0 * Double.pi

        //-- AnnotEnd
        if annotEnd != nil {
            viewBmkMap!.removeAnnotation(annotEnd!)
            annotEnd = nil
        }
        annotEnd = BMKPointAnnotation()
        viewBmkMap!.addAnnotation(annotEnd!)
        annotEnd!.coordinate = track[iIndexPos]
        viewBmkMap!.setCenter(annotEnd!.coordinate, animated: true)

        //-- Search Poi
        if !bSearchable { return }
        bSearchable = false

        searchNearBy(
            searchPoi: self.searchPoi,
            lat      : String(annotEnd!.coordinate.latitude),
            lon      : String(annotEnd!.coordinate.longitude)
        )
    }


    func updateTrack() {
        if track.count == 0 { return }
        //-- Polyline
        if polyline != nil {
            viewBmkMap?.remove(polyline!)
            polyline = nil
        }
        let textureIndexes: [NSNumber] = [0]
        polyline = BMKPolyline(
            coordinates : &track,
            count       : UInt(track.count),
            textureIndex: textureIndexes
        )
        viewBmkMap!.add(polyline)
    }


    func tryGetWatchPos() {
        var stReq: StReqGetWatchPos = StReqGetWatchPos()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id = Config.id_watch_monitoring

        API.instance.getWatchPos(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    self.sLat = stRsp.data?.lat  ?? ""
                    self.sLon = stRsp.data?.lon  ?? ""
                    let sTime = stRsp.data?.time ?? ""
                    DispatchQueue.main.async {
                        self.lblInfoTime.text = sTime
                        self.updateAnnotCur(lat: self.sLat, lon: self.sLon)
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }


    func tryGetWatchPosList() {
        var stReq: StReqGetWatchPosList = StReqGetWatchPosList()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id = Config.id_watch_monitoring

        track.removeAll()

        API.instance.getWatchPosList(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    let arrStRsp = stRsp.data ?? [StRspGetWatchPosListData]()
                    DispatchQueue.main.async {
                        for stRsp in arrStRsp {
                            self.track.append(CLLocationCoordinate2D(
                                latitude : CLLocationDegrees(stRsp.lat ?? "0")!,
                                longitude: CLLocationDegrees(stRsp.lon ?? "0")!
                            ))
                        }
                        self.track.append(CLLocationCoordinate2D(latitude: 39.20, longitude: 116.60))
                        self.track.append(CLLocationCoordinate2D(latitude: 39.20, longitude: 117.00))
                        self.track.append(CLLocationCoordinate2D(latitude: 39.40, longitude: 117.20))
                        self.track.append(CLLocationCoordinate2D(latitude: 39.60, longitude: 117.10))
                        self.track.append(CLLocationCoordinate2D(latitude: 39.50, longitude: 117.30))

                        //-- SeekBar
                        self.slider.minimumValue = 0
                        self.slider.maximumValue = Float(self.track.count - 1)
                        self.slider.setValue(Float(self.track.count - 1), animated: false)
                        self.iIndexPos = self.track.count - 1

                        self.updateTrack()
                        self.updateAnnotEnd()
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }

}


extension ViewControllerPosition: BMKMapViewDelegate {

    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        print("MAPVIEW : annot")
        if annotation.isEqual(annotCur) {
            var viewAnnot: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(
                withIdentifier: ANNOT_CUR
            ) as? BMKPinAnnotationView

            if viewAnnot == nil {
                viewAnnot = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOT_CUR)
            }
            viewAnnot?.image = UIImage(named: "img_annotation.png")
            return viewAnnot
        }

        if annotation.isEqual(annotEnd) {
            var viewAnnot: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(
                withIdentifier: ANNOT_END
            ) as? BMKPinAnnotationView

            if viewAnnot == nil {
                viewAnnot = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOT_END)
            }
            viewAnnot?.image = UIImage(named: "img_direction.png")?.rotate(radian: Float(dAngle))
            return viewAnnot
        }
        return nil
    }


    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay.isKind(of: BMKPolyline.self) {
            //-- Draw Polyline
            let viewPoly = BMKPolylineView(polyline: overlay as? BMKPolyline)
            viewPoly!.strokeColor = UIColor(red: 48 / 255.0, green: 144 / 255.0, blue: 248 / 255.0, alpha: 1)
            viewPoly!.lineWidth = 10
            viewPoly!.lineCapType = kBMKLineCapRound

            let images = [UIImage(named: "img_track.png")!]
            viewPoly!.loadStrokeTextureImages(images)

            return viewPoly
        }
        return nil
    }

}


extension ViewControllerPosition: BMKPoiSearchDelegate {

    func onGetPoiResult(_ searcher: BMKPoiSearch!, result: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        bSearchable = true
        if errorCode != BMK_SEARCH_NO_ERROR {
            lblInfoAddr.text = Config.modelWatchMonitoring.sAddress
            return
        }
        if result.poiInfoList.count <= 0 {
            lblInfoAddr.text = Config.modelWatchMonitoring.sAddress
            return
        }

        var addr = ""
        for poiInfo in result.poiInfoList {
            if poiInfo.address != nil, addr.count < poiInfo.address.count {
                addr = poiInfo.address
            }
        }
        lblInfoAddr.text = addr
    }

}
