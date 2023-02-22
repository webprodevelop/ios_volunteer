import UIKit
import WebKit


protocol ViewControllerInfoMoreDelegate: AnyObject {
    func onInfoMoreSuccess(model: ModelWatch)
}


class ViewControllerInfoMore: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblBloodType  : UILabel!
    @IBOutlet weak var txtAddress    : UITextField!
    @IBOutlet weak var txtDetailAddr1: UITextField!
    @IBOutlet weak var txtDetailAddr2: UITextField!
    @IBOutlet weak var tblDisease    : UITableView!

    var delegate: ViewControllerInfoMoreDelegate?
    var illList : [String] = []     // This comes from parent
    var diseases: [Bool] = []
    var modelWatch: ModelWatch = ModelWatch()
    var bClickedConfirm: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Init
        //txtAddress.delegate = self
        //txtDetailAddr1.delegate = self
        //txtDetailAddr2.delegate = self

        let tapAddress = UITapGestureRecognizer(target: self, action: #selector(onTapAddress(_:)))
        txtAddress.addGestureRecognizer(tapAddress)

        let tapBlood = UITapGestureRecognizer(target: self, action: #selector(self.onTapBlood(_:)))
        lblBloodType.addGestureRecognizer(tapBlood)

        if modelWatch.sUserBlood.isEmpty {
            lblBloodType.text = Config.BLOOD_O
        }
        else {
            lblBloodType.text = modelWatch.sUserBlood
        }
        updateTxtAddress()

        for _ in illList {
            diseases.append(false)
        }
        let illHistory = modelWatch.sUserIllHistory.split(separator: ",")
        for illItem in illHistory {
            let index = illList.firstIndex(of: String(illItem)) ?? -1
            if index >= 0 {
                diseases[index] = true
            }
        }
    }


    //-- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            //case txtAddress: txtAddress.resignFirstResponder(); /*txtDetailAddr1.becomeFirstResponder();*/ break
            //case txtDetailAddr1: txtDetailAddr2.becomeFirstResponder(); break
            //case txtDetailAddr2: txtDetailAddr2.resignFirstResponder(); break
            default: break
        }
        return false
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpMap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerMap") as! ViewControllerMap
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        vc.dLat = Double(modelWatch.sLat) ?? Config.DEFAULT_LAT
        vc.dLon = Double(modelWatch.sLon) ?? Config.DEFAULT_LON
        vc.sAddress  = modelWatch.sAddress
        vc.sProvince = modelWatch.sProvince
        vc.sCity     = modelWatch.sCity
        vc.sDistrict = modelWatch.sDistrict

        present(vc, animated: true, completion: nil)
    }


    @IBAction func onTouchUpContinue(_ sender: Any) {
        var sIllHistory: String = ""
        var sHistory: String = ""

        if !modelWatch.bIsManager {
            dismiss(animated: true, completion: nil)
            return
        }

        if bClickedConfirm { return }

        for i in 0..<illList.count {
            if diseases[i] { sIllHistory += illList[i] + "," }
        }
        if sIllHistory.count > 0 {
            sHistory = String(sIllHistory.prefix(sIllHistory.count - 1))
        }
        modelWatch.sUserBlood = lblBloodType.text ?? Config.BLOOD_O
        modelWatch.sAddress   = txtAddress.text ?? ""
        modelWatch.sUserIllHistory = sHistory
        trySetWatchInfo()
    }


    @IBAction func onEditBeginAddress(_ sender: Any) {
        txtAddress.resignFirstResponder()
    }


    @objc func onTapAddress(_ sender: UITapGestureRecognizer? = nil) {
        onTouchUpMap(sender!)
    }


    @objc func onTapBlood(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(
            title: "Blood Type".localized(),
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Config.BLOOD_O, style: .destructive, handler: { action in
            self.lblBloodType.text = Config.BLOOD_O
        }))
        alert.addAction(UIAlertAction(title: Config.BLOOD_A, style: .destructive, handler: { action in
            self.lblBloodType.text = Config.BLOOD_A
        }))
        alert.addAction(UIAlertAction(title: Config.BLOOD_B, style: .destructive, handler: { action in
            self.lblBloodType.text = Config.BLOOD_B
        }))
        alert.addAction(UIAlertAction(title: Config.BLOOD_AB, style: .destructive, handler: { action in
            self.lblBloodType.text = Config.BLOOD_AB
        }))
        present(alert, animated: true)
    }


    func updateTxtAddress() {
        txtAddress.text = modelWatch.sAddress
        if modelWatch.sProvince == modelWatch.sCity {
            //-- When both are same as like : Province = "Beijing City", City = "Beijing City"
            txtDetailAddr1.text = modelWatch.sProvince
        }
        else {
            txtDetailAddr1.text = modelWatch.sProvince + " " + modelWatch.sCity
        }
        txtDetailAddr2.text = modelWatch.sDistrict
    }


    func trySetWatchInfo() {
        var stReq: StReqSetWatchInfo = StReqSetWatchInfo()
        stReq.token            = Config.modelUserInfo.sToken
        stReq.mobile           = Config.modelUserInfo.sMobile
        stReq.id               = modelWatch.iId
        stReq.user_name        = modelWatch.sUserName
        stReq.user_phone       = modelWatch.sUserPhone
        stReq.user_sex         = modelWatch.iUserSex
        stReq.user_birthday    = modelWatch.sUserBirth
        stReq.user_tall        = modelWatch.iUserTall
        stReq.user_weight      = modelWatch.iUserWeight
        stReq.user_blood       = modelWatch.sUserBlood
        stReq.user_ill_history = modelWatch.sUserIllHistory
        stReq.province         = modelWatch.sProvince
        stReq.city             = modelWatch.sCity
        stReq.district         = modelWatch.sDistrict
        stReq.address          = modelWatch.sAddress
        stReq.lat              = modelWatch.sLat
        stReq.lon              = modelWatch.sLon

        bClickedConfirm = true
        API.instance.setWatchInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    self.modelWatch.iChargeStatus = stRsp.data?.charge_status ?? 0
                    self.modelWatch.sServiceStart = stRsp.data?.service_start ?? ""
                    self.modelWatch.sServiceEnd   = stRsp.data?.service_end   ?? ""
                    DbManager.instance.updateWatch(model: self.modelWatch)
                    DispatchQueue.main.async {
                        self.dismiss(animated:false, completion: {
                            self.delegate?.onInfoMoreSuccess(model: self.modelWatch)
                        })
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedConfirm = false
        }
    }

}


extension ViewControllerInfoMore: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return illList.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellDisease = tableView.dequeueReusableCell(
            withIdentifier: "rowdisease",
            for           : indexPath
        ) as! CellDisease

        cell.index = indexPath.row
        cell.setStatus(checked: diseases[indexPath.row])
        cell.lblTitle.text = illList[indexPath.row]

        cell.delegate = self

        return cell
    }
}


extension ViewControllerInfoMore: CellDiseaseDelegate {

    func onDiseaseSelected(index: Int, checked: Bool) {
        diseases[index] = checked
    }
}


extension ViewControllerInfoMore: ViewControllerMapDelegate {

    func onMapSuccess(address: String, province: String, city: String, district: String, lat: Double, lon: Double) {
        modelWatch.sAddress  = address
        modelWatch.sProvince = province
        modelWatch.sCity     = city
        modelWatch.sDistrict = district
        modelWatch.sLat = String(lat)
        modelWatch.sLon = String(lon)

        updateTxtAddress()
    }

}
