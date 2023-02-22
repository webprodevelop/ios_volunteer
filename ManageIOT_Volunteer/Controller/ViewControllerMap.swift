import UIKit
import WebKit


protocol ViewControllerMapDelegate: AnyObject {
    func onMapSuccess(address: String, province: String, city: String, district: String, lat: Double, lon: Double)
}


class ViewControllerMap: UIViewController {

    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDetail : UILabel!

    var delegate: ViewControllerMapDelegate? = nil

    var viewBmkMap: BMKMapView? = nil
    var searchPoi : BMKPoiSearch = BMKPoiSearch()

    var sAddress : String = ""
    var sProvince: String = ""
    var sCity    : String = ""
    var sDistrict: String = ""

    var dLat: Double = Config.DEFAULT_LAT
    var dLon: Double = Config.DEFAULT_LON


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Tap Gesture
        let tapAddress = UITapGestureRecognizer(target: self, action: #selector(self.onTapAddress(_:)))
        viewAddress.addGestureRecognizer(tapAddress)

        //-- Init Map
        viewBmkMap = BMKMapView(frame: viewMap.frame)
        viewBmkMap!.delegate = self
        viewBmkMap!.zoomLevel = 17
        viewBmkMap!.showMapScaleBar = false
        viewBmkMap!.showsUserLocation = true

        viewMap.addSubview(viewBmkMap!)

        searchPoi.delegate = self

        //-- Init View
        lblAddress.text = sAddress
        lblDetail.text  = sAddress

        setPosition()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewBmkMap?.viewWillAppear()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewBmkMap?.viewWillDisappear()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.onMapSuccess(address: sAddress, province: sProvince, city: sCity, district: sDistrict, lat: dLat, lon: dLon)
    }


    @objc func onTapAddress(_ sender: UITapGestureRecognizer? = nil) {
        let storyboard = UIStoryboard(name: "Address", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerAddress") as! ViewControllerAddress
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        vc.sAddress  = sAddress
        vc.sProvince = sProvince
        vc.sCity     = sCity
        vc.sDistrict = sDistrict
        vc.dLon = dLon
        vc.dLat = dLat
        present(vc, animated: false, completion: nil)
    }


    func setPosition() {
        //-- Align Center
        let coord = CLLocationCoordinate2D(latitude: dLat, longitude: dLon)
        viewBmkMap!.setCenter(coord, animated: true)

        //-- Location Mark
        let loc = BMKUserLocation()
        loc.location = CLLocation(latitude: dLat, longitude: dLon)
        viewBmkMap!.updateLocationData(loc)

        let param = BMKLocationViewDisplayParam()
        param.isAccuracyCircleShow = true
        param.locationViewImage = UIImage(named: "img_position_r.png")
        viewBmkMap!.updateLocationView(with: param)
    }
}


extension ViewControllerMap: ViewControllerAddressDelegate {
    func onAddressSuccess(address: String, province: String, city: String, district: String, lat: Double, lon: Double) {
        sAddress  = address
        sProvince = province
        sCity     = city
        sDistrict = district
        dLat      = lat
        dLon      = lon

        lblAddress.text = sAddress
        lblDetail.text  = sAddress
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { self.setPosition() })
    }
}


extension ViewControllerMap: BMKMapViewDelegate {

    func mapView(_ mapView: BMKMapView!, onClickedBMKOverlayView overlayView : BMKOverlayView!) {
        //-- Click OverlayView
    }


    func mapView(_ mapView: BMKMapView!, onClickedMapPoi mapPoi: BMKMapPoi!) {
        //-- Click Poi
        dLat = mapPoi.pt.latitude
        dLon = mapPoi.pt.longitude
        setPosition()
        sAddress = mapPoi.text
        lblAddress.text = sAddress
        lblDetail.text  = sAddress

        searchDetail(searchPoi: searchPoi, mapPoi: mapPoi)
    }


    func mapView(_ mapView: BMKMapView!, onClickedMapBlank coordinate: CLLocationCoordinate2D) {
        //-- Click Blank
        dLat = coordinate.latitude
        dLon = coordinate.longitude
        setPosition()
        searchNearBy(searchPoi: searchPoi, lat: String(dLat), lon: String(dLon))
    }

}


extension ViewControllerMap: BMKPoiSearchDelegate {

    func onGetPoiResult(_ searcher: BMKPoiSearch!, result: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode != BMK_SEARCH_NO_ERROR { return }
        if result.poiInfoList.count <= 0 { return }

        sAddress = ""
        for poiInfo in result.poiInfoList {
            if poiInfo.address != nil, sAddress.count < poiInfo.address.count {
                sAddress  = poiInfo.address
                sProvince = poiInfo.province ?? ""
                sCity     = poiInfo.city ?? ""
                sDistrict = poiInfo.area ?? ""
            }
        }
        lblAddress.text = sAddress
        lblDetail.text  = sAddress
    }


    func onGetPoiDetailResult(_ searcher: BMKPoiSearch!, result: BMKPOIDetailSearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode != BMK_SEARCH_NO_ERROR { return }
        if result.poiInfoList.count <= 0 { return }

        let poiInfo = result.poiInfoList[0]
        sProvince = poiInfo.province ?? ""
        sCity     = poiInfo.city ?? ""
        sDistrict = poiInfo.area ?? ""
    }

}
