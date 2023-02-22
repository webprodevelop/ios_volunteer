import UIKit
import WebKit


protocol ViewControllerFenceDelegate: AnyObject {
    func onFenceSuccessAdd(model: ModelFence)
    func onFenceSuccessEdit(model: ModelFence)
}


class ViewControllerFence: UIViewController {

    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var lblAddress : UILabel!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var lblAddressSelected: UILabel!
    @IBOutlet weak var lblStatus  : UILabel!
    @IBOutlet weak var btnRadius  : UIButton!
    @IBOutlet weak var tblPeriod: UITableView!

    let RADIUSES: [Int] = [300, 500, 800, 1000, 2000, 3000, 4000, 5000]

    var modelFence: ModelFence = ModelFence()
    var modelPeriodAdding: ModelPeriod = ModelPeriod()
    var delegate: ViewControllerFenceDelegate? = nil

    var viewBmkMap: BMKMapView? = nil
    var circle    : BMKCircle?  = nil
    var searchPoi : BMKPoiSearch = BMKPoiSearch()

    var alertName   : UIAlertController? = nil
    var alertRadius : UIAlertController? = nil
    var pickerRadius: UIPickerView? = nil

    var sName  : String = "Fence Name".localized()
    var sAddr  : String = ""
    var dLat   : Double = 0
    var dLon   : Double = 0
    var iRadius: Int = 300
    var arrPeriod: [ModelPeriod] = [ModelPeriod]()

    var bAdding: Bool = true
    var bSelectingStart: Bool = true


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Tap Gesture
        let tapAddress = UITapGestureRecognizer(target: self, action: #selector(self.onTapAddress(_:)))
        viewAddress.addGestureRecognizer(tapAddress)

        //-- Init Value
        sName = modelFence.sName ?? "Fence Name".localized()
        sAddr = modelFence.sAddr ?? ""
        if (modelFence.sLat ?? "").isEmpty { modelFence.sLat = String(Config.DEFAULT_LAT) }
        if (modelFence.sLon ?? "").isEmpty { modelFence.sLon = String(Config.DEFAULT_LON) }
        dLat = Double(modelFence.sLat!) ?? Config.DEFAULT_LAT
        dLon = Double(modelFence.sLon!) ?? Config.DEFAULT_LON
        iRadius = modelFence.iRadius ?? 300
        arrPeriod = modelFence.periods.map{ $0.copy() }

        //-- Init Map
        viewBmkMap = BMKMapView(frame: viewMap.frame)
        viewBmkMap!.delegate = self
        viewBmkMap!.zoomLevel = 17
        viewBmkMap!.showMapScaleBar = false
        viewBmkMap!.showsUserLocation = true
        viewMap.addSubview(viewBmkMap!)

        searchPoi.delegate = self

        //-- Init View
        drawFence()
        updateBtnRadius()
        lblStatus.isHidden = true
        btnName.setTitle(sName, for: .normal)
        lblAddress.text = sAddr
        lblAddressSelected.text = sAddr
        tblPeriod.reloadData()
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


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpRadius(_ sender: Any) {
        if alertRadius != nil {
            present(alertRadius!, animated: true)
            return
        }

        alertRadius = UIAlertController(
            title  : "Radius".localized(),
            message: nil,
            preferredStyle: .alert
        )
        //-- Picker
        let rectPicker: CGRect = CGRect(x: 100, y: 40, width: 100, height: 120)
        pickerRadius = UIPickerView(frame: rectPicker)
        pickerRadius!.tag = 1
        pickerRadius!.delegate = self
        pickerRadius!.dataSource = self

        alertRadius!.view.addSubview(pickerRadius!)

        //-- Width and Height
        let constraintWidth: NSLayoutConstraint = NSLayoutConstraint(
            item      : alertRadius!.view!,
            attribute : NSLayoutConstraint.Attribute.width,
            relatedBy : NSLayoutConstraint.Relation.equal,
            toItem    : nil,
            attribute : NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant  : 300
        )
        let constraintHeight: NSLayoutConstraint = NSLayoutConstraint(
            item      : alertRadius!.view!,
            attribute : NSLayoutConstraint.Attribute.height,
            relatedBy : NSLayoutConstraint.Relation.equal,
            toItem    : nil,
            attribute : NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant  : 200
        )
        alertRadius!.view.addConstraint(constraintWidth)
        alertRadius!.view.addConstraint(constraintHeight)

        //-- OK, Cancel Button
        let alertActionOk: UIAlertAction = UIAlertAction(
            title  : "OK".localized(),
            style  : UIAlertAction.Style.default,
            handler: onAlertRadiusOk
        )
        let alertActionCancel: UIAlertAction = UIAlertAction(
            title  : "Cancel".localized(),
            style  : UIAlertAction.Style.default,
            handler: onAlertRadiusCancel
        )
        alertRadius!.addAction(alertActionCancel)
        alertRadius!.addAction(alertActionOk)

        present(alertRadius!, animated: true)

        pickerRadius?.selectRow(RADIUSES.firstIndex(of: iRadius) ?? 0, inComponent: 0, animated: true)
    }


    @IBAction func onTouchUpName(_ sender: Any) {
        if alertName != nil {
            present(alertName!, animated: true)
            return
        }

        alertName = UIAlertController(
            title  : "Electric Fence Name".localized(),
            message: nil,
            preferredStyle: .alert
        )

        //-- TextField
        alertName?.addTextField() { (textField: UITextField) in
            textField.placeholder = "Input Electric Fence Name".localized()
            textField.keyboardType = .default
            textField.text = self.sName
        }

        //-- Width and Height
        let constraintWidth: NSLayoutConstraint = NSLayoutConstraint(
            item      : alertName!.view!,
            attribute : NSLayoutConstraint.Attribute.width,
            relatedBy : NSLayoutConstraint.Relation.equal,
            toItem    : nil,
            attribute : NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant  : 300
        )
        let constraintHeight: NSLayoutConstraint = NSLayoutConstraint(
            item      : alertName!.view!,
            attribute : NSLayoutConstraint.Attribute.height,
            relatedBy : NSLayoutConstraint.Relation.equal,
            toItem    : nil,
            attribute : NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant  : 200
        )
        alertName!.view.addConstraint(constraintWidth)
        alertName!.view.addConstraint(constraintHeight)

        //-- OK, Cancel Button
        let alertActionOk: UIAlertAction = UIAlertAction(
            title  : "OK".localized(),
            style  : UIAlertAction.Style.default,
            handler: onAlertNameOk
        )
        let alertActionCancel: UIAlertAction = UIAlertAction(
            title  : "Cancel".localized(),
            style  : UIAlertAction.Style.default,
            handler: onAlertNameCancel
        )
        alertName!.addAction(alertActionCancel)
        alertName!.addAction(alertActionOk)

        present(alertName!, animated: true)
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        if (btnName.title(for: .normal) ?? "").isEmpty {
            showToast(message: "Input Electric Fence Name".localized(), completion: nil)
            return
        }
        modelFence.sName   = sName
        modelFence.sAddr   = sAddr
        modelFence.iRadius = iRadius
        modelFence.sLat    = String(dLat)
        modelFence.sLon    = String(dLon)
        modelFence.periods.removeAll()
        modelFence.periods = arrPeriod.map{ $0.copy() }
        if bAdding {
            delegate?.onFenceSuccessAdd(model: modelFence)
        }
        else {
            delegate?.onFenceSuccessEdit(model: modelFence)
        }
        dismiss(animated: true, completion: nil)
    }


    @objc func onTapAddress(_ sender: UITapGestureRecognizer? = nil) {
        let storyboard = UIStoryboard(name: "Address", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerAddress") as! ViewControllerAddress
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        vc.sAddress = sAddr
        vc.dLat = dLat
        vc.dLon = dLon
        present(vc, animated: false, completion: nil)
    }


    @objc func onAlertRadiusOk(action: UIAlertAction) {
        alertRadius?.dismiss(animated: true, completion: nil)
        updateBtnRadius()
        drawFence()
    }


    @objc func onAlertRadiusCancel(action: UIAlertAction) {
        alertRadius?.dismiss(animated: true, completion: nil)
    }


    @objc func onAlertNameOk(action: UIAlertAction) {
        if let textField = alertName!.textFields?.first {
            btnName.setTitle(textField.text ?? "", for: .normal)
            alertName?.dismiss(animated: true, completion: nil)
        }
    }


    @objc func onAlertNameCancel(action: UIAlertAction) {
        alertName?.dismiss(animated: true, completion: nil)
    }


    func updateBtnRadius() {
        btnRadius.setTitle("Radius".localized() + " " + String(iRadius) + "M".localized(), for: .normal)
    }


    func drawFence() {
        //-- Align Center
        let coord = CLLocationCoordinate2D(latitude: dLat, longitude: dLon)
        viewBmkMap!.setCenter(coord, animated: true)

        //-- Location Mark
        let loc = BMKUserLocation()
        loc.location = CLLocation(latitude: dLat, longitude: dLon)
        viewBmkMap!.updateLocationData(loc)

        let param = BMKLocationViewDisplayParam()
        param.isAccuracyCircleShow = true
        param.locationViewImage = UIImage(named: "img_position_f.png")
        viewBmkMap!.updateLocationView(with: param)

        //-- Circle
        if circle != nil {
            viewBmkMap!.remove(circle)
        }
        circle = BMKCircle(center: coord, radius: Double(iRadius))
        viewBmkMap!.add(circle)
    }

}


extension ViewControllerFence: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPeriod.count + 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellPeriod = tableView.dequeueReusableCell(
            withIdentifier: "rowperiod",
            for           : indexPath
        ) as! CellPeriod

        if indexPath.row == 0 {
            cell.modelPeriod = modelPeriodAdding
            cell.operation = "+"
            cell.delegate = self
        }
        else {
            cell.modelPeriod = arrPeriod[indexPath.row - 1]
            cell.operation = "-"
            cell.delegate = self
        }
        cell.updateView()

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}


extension ViewControllerFence: UIPickerViewDelegate, UIPickerViewDataSource {

    //-- UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RADIUSES.count
    }


    //-- UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(RADIUSES[row])
    }


    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        iRadius = RADIUSES[row]
    }

}


extension ViewControllerFence: CellPeriodDelegate {

    func onPeriodStart(model: ModelPeriod) {
        bSelectingStart = true

        let storyboard = UIStoryboard(name: "DateTime", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerDateTime") as! ViewControllerDateTime
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }


    func onPeriodEnd(model: ModelPeriod) {
        bSelectingStart = false

        let storyboard = UIStoryboard(name: "DateTime", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerDateTime") as! ViewControllerDateTime
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }


    func onPeriodAdd(model: ModelPeriod) {
        arrPeriod.append(model)
        modelPeriodAdding = ModelPeriod()
        modelPeriodAdding.sStart = ""
        modelPeriodAdding.sEnd   = ""
        tblPeriod.reloadData()
    }


    func onPeriodDel(model: ModelPeriod) {
        let index = arrPeriod.firstIndex(where: { $0 == model }) ?? -1
        if index >= 0 {
            arrPeriod.remove(at: index)
        }
        tblPeriod.reloadData()
    }
}


extension ViewControllerFence: ViewControllerDateTimeDelegate {

    func onDateTimeSelected(datetime: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
        if bSelectingStart {
            modelPeriodAdding.sStart = formatter.string(from: datetime)
        }
        else {
            modelPeriodAdding.sEnd = formatter.string(from: datetime)
        }
        tblPeriod.reloadData()
    }

}


extension ViewControllerFence: ViewControllerAddressDelegate {

    func onAddressSuccess(address: String, province: String, city: String, district: String, lat: Double, lon: Double) {
        sAddr = address
        lblAddress.text = sAddr
        lblAddressSelected.text = sAddr
        dLat = lat
        dLon = lon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { self.drawFence() })
    }

}


extension ViewControllerFence: BMKMapViewDelegate {

    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if overlay.isKind(of: BMKCircle.self) {
            //-- Fence Circle
            let viewCircle = BMKCircleView(circle: circle)
            viewCircle?.fillColor   = UIColor(red: 48 / 255.0, green: 144 / 255.0, blue: 255 / 255.0, alpha: 0.5)
            viewCircle?.strokeColor = UIColor(red: 48 / 255.0, green: 144 / 255.0, blue: 255 / 255.0, alpha: 1.0)
            viewCircle?.lineWidth = 1
            return viewCircle
        }
        return nil
    }


    func mapView(_ mapView: BMKMapView!, onClickedBMKOverlayView overlayView : BMKOverlayView!) {
        //-- Click OverlayView
    }


    func mapView(_ mapView: BMKMapView!, onClickedMapPoi mapPoi: BMKMapPoi!) {
        //-- Click Poi
        dLat = mapPoi.pt.latitude
        dLon = mapPoi.pt.longitude
        drawFence()
        sAddr = mapPoi.text
        lblAddress.text = sAddr
        lblAddressSelected.text = sAddr
    }


    func mapView(_ mapView: BMKMapView!, onClickedMapBlank coordinate: CLLocationCoordinate2D) {
        //-- Click Blank
        dLat = coordinate.latitude
        dLon = coordinate.longitude
        drawFence()
        searchNearBy(searchPoi: searchPoi, lat: String(dLat), lon: String(dLon))
    }

}


extension ViewControllerFence: BMKPoiSearchDelegate {

    func onGetPoiResult(_ searcher: BMKPoiSearch!, result: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode != BMK_SEARCH_NO_ERROR { return }
        if result.poiInfoList.count <= 0 { return }

        sAddr = ""
        for poiInfo in result.poiInfoList {
            if poiInfo.address != nil, sAddr.count < poiInfo.address.count {
                sAddr = poiInfo.address
            }
        }
        lblAddress.text = sAddr
        lblAddressSelected.text = sAddr
    }

}
