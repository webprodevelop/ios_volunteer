import UIKit
import WebKit
import SwiftyJSON

class ViewControllerPositionSetting: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var scrlFence  : UIScrollView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnFreq1: UIButton!
    @IBOutlet weak var btnFreq2: UIButton!
    @IBOutlet weak var btnFreq3: UIButton!
    @IBOutlet weak var tblFence: UITableView!

    var fences: [ModelFence] = [ModelFence]()
    var iFreq: Int = 1


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true

        iFreq = Config.modelWatchMonitoring.iPosUpdateMode
        updateBtnFreq()
        tryGetElecFenceInfo()
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpNew(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Fence", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerFence") as! ViewControllerFence
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        vc.bAdding = true
        present(vc, animated:true, completion: nil)
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        trySetElecFenceInfo()
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated:false, completion: nil)
    }


    @IBAction func onTouchUpBtnFreq1(_ sender: Any) {
        iFreq = 1
        updateBtnFreq()
    }


    @IBAction func onTouchUpBtnFreq2(_ sender: Any) {
        iFreq = 2
        updateBtnFreq()
    }


    @IBAction func onTouchUpBtnFreq3(_ sender: Any) {
        iFreq = 3
        updateBtnFreq()
    }


    func updateBtnFreq() {
        switch iFreq {
            case 1:
                btnFreq1.setImage(UIImage(named: "img_check_on"),  for: .normal)
                btnFreq2.setImage(UIImage(named: "img_check_off"), for: .normal)
                btnFreq3.setImage(UIImage(named: "img_check_off"), for: .normal)
                break
            case 2:
                btnFreq1.setImage(UIImage(named: "img_check_off"), for: .normal)
                btnFreq2.setImage(UIImage(named: "img_check_on"),  for: .normal)
                btnFreq3.setImage(UIImage(named: "img_check_off"), for: .normal)
                break
            case 3:
                btnFreq1.setImage(UIImage(named: "img_check_off"), for: .normal)
                btnFreq2.setImage(UIImage(named: "img_check_off"), for: .normal)
                btnFreq3.setImage(UIImage(named: "img_check_on"),  for: .normal)
                break
            default: break
        }
    }


    func updateTblFence() {
        //-- Resize tblFence height to contain all data
        tblFence.reloadData()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            self.tblFence.frame.size.height    = self.tblFence.contentSize.height
            self.viewContent.frame.size.height = self.tblFence.frame.origin.y + self.tblFence.frame.size.height + 20
            self.scrlFence.contentSize.height  = self.viewContent.frame.size.height
        }
    }


    func tryGetElecFenceInfo() {
        var stReq: StReqGetElecFenceInfo = StReqGetElecFenceInfo()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id     = Config.id_watch_monitoring

        API.instance.getElecFenceInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    let jsonFenceList: Array<JSON> = JSON(parseJSON: stRsp.data?.fence_list ?? "[]").arrayValue

                    for jsonFence in jsonFenceList {
                        var stFence = StElecFenceInfoData()
                        stFence.initFrom(json: jsonFence)
                        let modelFence = ModelFence()
                        modelFence.copyFromApiData(data: stFence)
                        self.fences.append(modelFence)
                    }
                    DispatchQueue.main.async {
                        self.updateTblFence()
                    }

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }

    }


    func trySetElecFenceInfo() {
        var stReq: StReqSetElecFenceInfo = StReqSetElecFenceInfo()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id     = Config.id_watch_monitoring
        var arrStFence = Array<StElecFenceInfoData>()
        for modelFence in fences {
            var stFence = StElecFenceInfoData ()
            stFence.initFrom(model: modelFence)
            arrStFence.append(stFence)
        }
        do {
            let jsonFenceList = try JSONEncoder().encode(arrStFence)
            stReq.fence_list = String(data: jsonFenceList, encoding: .utf8)!
        }
        catch {
            print("SetElecFenceInfo : JSON : \(error)")
        }

        API.instance.setElecFenceInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    self.trySetPosUpdateMode()
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }

    }


    func trySetPosUpdateMode() {
        var stReq: StReqSetPosUpdateMode = StReqSetPosUpdateMode()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id     = Config.id_watch_monitoring
        stReq.mode   = String(iFreq)

        API.instance.setPosUpdateMode(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    Config.modelWatchMonitoring.iPosUpdateMode = self.iFreq
                    DbManager.instance.updateWatch(model: Config.modelWatchMonitoring)
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }

    }

}


extension ViewControllerPositionSetting: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fences.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellFence = tableView.dequeueReusableCell(
            withIdentifier: "rowfence",
            for           : indexPath
        ) as! CellFence

        let fence = fences[indexPath.row]
        cell.modelFence = fence
        cell.updateView()
        cell.delegate = self
        return cell
    }

}


extension ViewControllerPositionSetting: CellFenceDelegate {

    func onFenceEdit(model: ModelFence) {
        let storyboard = UIStoryboard(name: "Fence", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerFence") as! ViewControllerFence
        vc.modalPresentationStyle = .fullScreen
        vc.modelFence = model
        vc.delegate = self
        vc.bAdding = false
        present(vc, animated:true, completion: nil)
    }


    func onFenceDel(model: ModelFence) {
        let index = Array(fences).firstIndex(where: { $0 == model }) ?? -1
        if index >= 0 {
            fences.remove(at: index)
            updateTblFence()
        }
    }

}


extension ViewControllerPositionSetting: ViewControllerFenceDelegate {

    func onFenceSuccessAdd(model: ModelFence) {
        fences.append(model)
        updateTblFence()
    }


    func onFenceSuccessEdit(model: ModelFence) {
        updateTblFence()
    }
}
