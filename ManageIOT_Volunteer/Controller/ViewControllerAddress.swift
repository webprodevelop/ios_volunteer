import UIKit
import WebKit


protocol ViewControllerAddressDelegate: AnyObject {
    func onAddressSuccess(address: String, province: String, city: String, district: String, lat: Double, lon: Double)
}


class ViewControllerAddress: UIViewController {

    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var tblAddress: UITableView!

    var delegate: ViewControllerAddressDelegate? = nil

    var searchPoi  : BMKPoiSearch = BMKPoiSearch()
    var poiInfoList: Array<BMKPoiInfo> = Array<BMKPoiInfo>()

    var timer: Timer? = nil

    var sAddress : String = ""
    var sProvince: String = ""
    var sCity    : String = ""
    var sDistrict: String = ""

    var dLat: Double = Config.DEFAULT_LAT
    var dLon: Double = Config.DEFAULT_LON


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Init View
        searchPoi.delegate = self
        txtAddress.text = sAddress

        let keyword = String(sAddress.prefix(5))
        searchCity(searchPoi: searchPoi, keyword: keyword)
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.onAddressSuccess(
            address : sAddress,
            province: sProvince,
            city    : sCity,
            district: sDistrict,
            lat     : dLat,
            lon     : dLon
        )
    }


    @IBAction func onChangedAddress(_ sender: Any) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            self.sAddress = self.txtAddress.text ?? ""
            let keyword = String(self.sAddress.prefix(5))
            searchCity(searchPoi: self.searchPoi, keyword: keyword)
        }
    }

}


extension ViewControllerAddress: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiInfoList.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellAddress = tableView.dequeueReusableCell(
            withIdentifier: "rowaddress",
            for           : indexPath
        ) as! CellAddress

        let poiInfo = poiInfoList[indexPath.row]
        cell.lblName.text    = poiInfo.name
        cell.lblAddress.text = poiInfo.address

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poiInfo = poiInfoList[indexPath.row]
        sProvince = poiInfo.province ?? ""
        sCity     = poiInfo.city ?? ""
        sDistrict = poiInfo.area ?? ""

        dLat = poiInfo.pt.latitude
        dLon = poiInfo.pt.longitude

        if poiInfo.address == nil || poiInfo.address.isEmpty {
            sAddress = poiInfo.name
        }
        else {
            sAddress = poiInfo.address
        }
        txtAddress.text = sAddress
    }

}


extension ViewControllerAddress: BMKPoiSearchDelegate {

    func onGetPoiResult(_ searcher: BMKPoiSearch!, result: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode != BMK_SEARCH_NO_ERROR { return }
        if result.poiInfoList.count <= 0 { return }
        poiInfoList = result.poiInfoList
        for poiInfo in poiInfoList {
            if poiInfo.name.isEmpty {
                let index = poiInfoList.firstIndex(where: { $0 == poiInfo }) ?? -1
                if index >= 0 {
                    poiInfoList.remove(at: index)
                }
            }
        }
        tblAddress.reloadData()
    }

}
