import UIKit


protocol ViewControllerDashboardDelegate {
    func onDashboardPresent()

    func onDashboardPresentHotspot()
    func onDashboardPresentSense()
    func onDashboardPresentPetbite()
    func onDashboardPresentRecommend()

    func onDashboardPresentRescueQuery()
    func onDashboardPresentRescueDetail()
    func onDashboardPresentRescueProcess()

    func onDashboardTouchUpBtnTask()
}


class ViewControllerDashboard: UIViewController {

    @IBOutlet weak var tblHotspot: UITableView!
    @IBOutlet weak var cltSense: UICollectionView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var btnTasks: UIButton!
    @IBOutlet weak var btnHistory: UIButton!
    
    //-- Variables
    var delegate: ViewControllerDashboardDelegate? = nil

    private let VC_NONE     : Int = 0
    private let VC_HOTSPOT  : Int = 1
    private let VC_SENSE    : Int = 2
    private let VC_RECOMMEND: Int = 3
    private let VC_PETBITE  : Int = 4
    private let VC_RESCUEQUERY: Int = 5

    private let ANNOT_COUNT = "annot_count"

    private var vcHotspot  : ViewControllerHotspot?   = nil
    private var vcSense    : ViewControllerSense?     = nil
    private var vcRecommend: ViewControllerRecommend? = nil
    private var vcPetbite  : ViewControllerPetbite?   = nil
    private var vcRescueQuery: ViewControllerRescueQuery?   = nil

    private var iVcCurrent: Int = 0  /// VC_NONE
    private var bUserLocationUpdated: Bool = false
    private var viewBmkMap: BMKMapView? = nil
    private var vAnnotCount: [BMKPointAnnotation] = [BMKPointAnnotation]()
    private var vStRspStatisticsData: [StRspGetVolunteerStatisticsData] = [StRspGetVolunteerStatisticsData]()

    private var vModelNewsHotspot: [ModelNews] = [ModelNews]()
    private var vModelNewsSense  : [ModelNews] = [ModelNews]()


    //-- Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        viewBmkMap = BMKMapView(frame: viewMap.frame)
        viewBmkMap!.delegate = self
        viewBmkMap!.zoomLevel = 10
        viewBmkMap!.showMapScaleBar = false
        viewBmkMap!.showsUserLocation = true

        viewMap.addSubview(viewBmkMap!)

        setShadowText()
        tryGetVolunteerStatistics()
    }

    func setShadowText(){
        //btnTasks.titleLabel?.textColor = UIColor.white
        btnTasks.setTitleColor(UIColor.white, for: .normal)
        btnTasks.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        btnTasks.titleLabel?.layer.shadowOffset = CGSize(width: 1, height: 1)
        btnTasks.titleLabel?.layer.shadowOpacity = 1.0
        btnTasks.titleLabel?.layer.shadowRadius = 3
        //btnTasks.titleLabel?.layer.masksToBounds = false
        
        btnHistory.setTitleColor(UIColor.white, for: .normal)
        btnHistory.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        btnHistory.titleLabel?.layer.shadowOffset = CGSize(width: 1, height: 1)
        btnHistory.titleLabel?.layer.shadowOpacity = 1.0
        btnHistory.titleLabel?.layer.shadowRadius = 3
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewBmkMap?.viewWillDisappear()
    }


    @IBAction func onTouchUpBtnTask(_ sender: Any) {
        delegate?.onDashboardTouchUpBtnTask()
    }


    @IBAction func onTouchUpBtnHistory(_ sender: Any) {
        if vcRescueQuery == nil {
            let storyboard = UIStoryboard(name: "RescueQuery", bundle: nil)
            vcRescueQuery = storyboard.instantiateViewController(withIdentifier: "ViewControllerRescueQuery") as? ViewControllerRescueQuery
        }
        vcRescueQuery!.delegate = self
        addChildViewController(child: vcRescueQuery!, container: view, frame: view.bounds)
        iVcCurrent = VC_RESCUEQUERY
        delegate?.onDashboardPresentRescueQuery()
    }


    @IBAction func onTouchUpBtnHotspotDetail(_ sender: Any) {
        showViewControllerHotspot()
        delegate?.onDashboardPresentHotspot()
    }


    @IBAction func onTouchUpBtnSenseDetail(_ sender: Any) {
        showViewControllerSense()
        delegate?.onDashboardPresentSense()
    }


    func onBack() {
        vcHotspot?.onBack()
        vcSense?.onBack()
        vcRecommend?.onBack()
        vcPetbite?.onBack()
        vcRescueQuery?.onBack()
    }

    
    func dismissChildren() {
        vcHotspot?.dismissChildren()
        vcSense?.dismissChildren()
        vcRescueQuery?.dismissChildren()

        vcHotspot?.dismissFromParent()
        vcSense?.dismissFromParent()
        vcRecommend?.dismissFromParent()
        vcPetbite?.dismissFromParent()
        vcRescueQuery?.dismissFromParent()

        vcHotspot = nil
        vcSense = nil
        vcRecommend = nil
        vcPetbite = nil
        vcRescueQuery = nil
    }


    func updateUserLocation() {
        if bUserLocationUpdated { return }
        bUserLocationUpdated = true
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude : Config.current_lat,
            longitude: Config.current_lon
        )
        self.viewBmkMap?.setCenter(coordinate, animated: false)
    }


    func updateData() {
        /// News
        vModelNewsHotspot = DbManager.instance.loadNews(branch: Config.NEWS_BRANCH_HOTSPOT)
        vModelNewsSense   = DbManager.instance.loadNews(branch: Config.NEWS_BRANCH_SENSE)

        tblHotspot.reloadData()
        cltSense.reloadData()
    }


    private func addAnnotCount(lat: String, lon: String) {
        let annotCount = BMKPointAnnotation()
        annotCount.coordinate.latitude  = Double(lat) ?? 0
        annotCount.coordinate.longitude = Double(lon) ?? 0
        vAnnotCount.append(annotCount)
        viewBmkMap!.addAnnotation(annotCount)
        if vAnnotCount.count == 1 {
            viewBmkMap!.setCenter(annotCount.coordinate, animated: false)
        }
    }


    private func showViewControllerHotspot() {
        iVcCurrent = VC_HOTSPOT

        if vcHotspot == nil {
            let storyboard = UIStoryboard(name: "Hotspot", bundle: nil)
            vcHotspot = storyboard.instantiateViewController(withIdentifier: "ViewControllerHotspot") as? ViewControllerHotspot
        }
        vcHotspot!.delegate = self
        addChildViewController(child: vcHotspot!, container: view, frame: view.bounds)
        vcHotspot!.setModelNewsList(models: vModelNewsHotspot)
    }


    private func showViewControllerSense() {
        iVcCurrent = VC_SENSE

        if vcSense == nil {
            let storyboard = UIStoryboard(name: "Sense", bundle: nil)
            vcSense = storyboard.instantiateViewController(withIdentifier: "ViewControllerSense") as? ViewControllerSense
        }
        vcSense!.delegate = self
        addChildViewController(child: vcSense!, container: view, frame: view.bounds)
        vcSense!.setModelNewsList(models: vModelNewsSense)
    }


    private func showViewControllerRecommend(model: ModelNews) {
        iVcCurrent = VC_RECOMMEND

        if vcRecommend == nil {
            let storyboard = UIStoryboard(name: "Recommend", bundle: nil)
            vcRecommend = storyboard.instantiateViewController(withIdentifier: "ViewControllerRecommend") as? ViewControllerRecommend
        }
        vcRecommend?.delegate = self
        addChildViewController(child: vcRecommend!, container: view, frame: view.bounds)
        /// setModelNews must be called after present
        vcRecommend!.setModelNews(model: model)
    }


    private func showViewControllerPetbite(model: ModelNews) {
        iVcCurrent = VC_PETBITE

        if vcPetbite == nil {
            let storyboard = UIStoryboard(name: "Petbite", bundle: nil)
            vcPetbite = storyboard.instantiateViewController(withIdentifier: "ViewControllerPetbite") as? ViewControllerPetbite
        }
        vcPetbite?.delegate = self
        addChildViewController(child: vcPetbite!, container: view, frame: view.bounds)
        /// setModelNews must be called after present
        vcPetbite!.setModelNews(model: model)
    }


    private func tryGetVolunteerStatistics() {
        var stReq: StReqGetVolunteerStatistics = StReqGetVolunteerStatistics()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile

        API.instance.getVolunteerStatistics(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        /// When fails, show current position in the map
                        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(
                            latitude : Config.current_lat,
                            longitude: Config.current_lon
                        )
                        self.viewBmkMap?.setCenter(coordinate, animated: false)
                        break
                    }
                    if stRsp.data == nil { break }
                    self.vStRspStatisticsData = stRsp.data!

                    DispatchQueue.main.async {
                        self.vAnnotCount.removeAll()
                        for stRspData in stRsp.data! {
                            self.addAnnotCount(lat: stRspData.lat!, lon: stRspData.lon!)
                        }
                    }
                    break

                case .failure(_):
                    /// When fails, show current position in the map
                    if Config.current_lat == 0 { return }
                    if Config.current_lon == 0 { return }
                    let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(
                        latitude : Config.current_lat,
                        longitude: Config.current_lon
                    )
                    self.viewBmkMap?.setCenter(coordinate, animated: false)
                    break
            }
        }
    }


}

//-- For UITableView : tblHotspot
extension ViewControllerDashboard: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vModelNewsHotspot.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellHotspot = tableView.dequeueReusableCell(
            withIdentifier: "rowhotspot",
            for           : indexPath
        ) as! CellHotspot

        let model = vModelNewsHotspot[indexPath.row]
        cell.updateView(model: model)

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: CellHotspot = tableView.cellForRow(at: indexPath) as! CellHotspot
        let model = vModelNewsHotspot[indexPath.row]
        cell.updateView(model: model)

        showViewControllerRecommend(model: model)
        delegate?.onDashboardPresentRecommend()
    }

}


//-- For UICollectionView : cltSense
extension ViewControllerDashboard: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return vModelNewsSense.count
    }


    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CellSense = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cellsense",
            for                : indexPath
        ) as! CellSense

        let modelSense = vModelNewsSense[indexPath.row]
        cell.updateView(model: modelSense)

        return cell
    }


    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        return UICollectionReusableView()
    }


    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let model = vModelNewsSense[indexPath.row]
        showViewControllerPetbite(model: model)
        delegate?.onDashboardPresentPetbite()
    }
}


extension ViewControllerDashboard: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath    : IndexPath
    ) -> CGSize {
        return CGSize(width: 126, height: 126)
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section  : Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
}


//-- For BMKMap
extension ViewControllerDashboard: BMKMapViewDelegate {

    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        print("MAPVIEW : View For Annotation")
        let index = vAnnotCount.firstIndex(of: annotation as! BMKPointAnnotation) ?? -1
        if index < 0 { return nil }

        if index >= vStRspStatisticsData.count {
            return nil
        }

        let stRspGetVolunteerStatisticsData = vStRspStatisticsData[index]
        if (stRspGetVolunteerStatisticsData.count?.isEmpty ?? true) {
            return nil
        }

        var viewAnnot: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(
            withIdentifier: ANNOT_COUNT + "\(index)"
        ) as? BMKPinAnnotationView

        if viewAnnot == nil {
            viewAnnot = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOT_COUNT + "\(index)")
        }
        //viewAnnot?.image = UIImage(named: "img_annotation.png")
        viewAnnot?.image = nil

        let txtCount: UITextField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        txtCount.text = stRspGetVolunteerStatisticsData.count!
        txtCount.textColor = UIColor.red
        viewAnnot?.addSubview(txtCount)
        return viewAnnot
    }

}


//-- ViewControllerHotspotDelegate
extension ViewControllerDashboard: ViewControllerHotspotDelegate {

    func onHotspotDismiss() {
        delegate?.onDashboardPresent()
        vcHotspot = nil
    }


    func onHotspotPresent() {
        delegate?.onDashboardPresentHotspot()
    }


    func onHotspotPresentRecommend() {
        delegate?.onDashboardPresentRecommend()
    }

}


//-- ViewControllerSenseDelegate
extension ViewControllerDashboard: ViewControllerSenseDelegate {

    func onSenseDismiss() {
        delegate?.onDashboardPresent()
        vcSense = nil
    }


    func onSensePresent() {
        delegate?.onDashboardPresentSense()
    }


    func onSensePresentPetbite() {
        delegate?.onDashboardPresentPetbite()
    }

}


//-- ViewControllerRecommendDelegate
extension ViewControllerDashboard: ViewControllerRecommendDelegate {

    func onRecommendDismiss() {
        delegate?.onDashboardPresent()
        vcRecommend = nil
    }

}


//-- ViewControllerPetbiteDelegate
extension ViewControllerDashboard: ViewControllerPetbiteDelegate {

    func onPetbiteDismiss() {
        delegate?.onDashboardPresent()
        vcPetbite = nil
    }

}

//-- ViewControllerRescueQueryDelegate
extension ViewControllerDashboard: ViewControllerRescueQueryDelegate {

    func onRescueQueryDismiss() {
        vcRescueQuery = nil
        iVcCurrent = VC_NONE
        delegate?.onDashboardPresent()
    }


    func onRescueQueryPresent() {
        delegate?.onDashboardPresentRescueQuery()
    }


    func onRescueQueryPresentRescueDetail() {
        delegate?.onDashboardPresentRescueDetail()
    }


    func onRescueQueryPresentRescueProcess() {
        delegate?.onDashboardPresentRescueProcess()
    }

}
