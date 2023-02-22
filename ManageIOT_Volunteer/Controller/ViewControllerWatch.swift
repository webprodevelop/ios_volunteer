import UIKit


protocol ViewControllerWatchDelegate: AnyObject {
    func onWatchSuccess()
}


class ViewControllerWatch: UIViewController {

    @IBOutlet weak var tblWatch: UITableView!

    var delegate: ViewControllerWatchDelegate? = nil
    var watches: [ModelWatch] = [ModelWatch]()


    override func viewDidLoad() {
        super.viewDidLoad()
        reloadWatches()
    }


    override func viewWillDisappear(_ animated: Bool) {
        delegate?.onWatchSuccess()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpBind(_ sender: Any) {
        let storyboard = UIStoryboard(name: "QrCode", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerQrCode") as! ViewControllerQrCode
        vc.modalPresentationStyle = .fullScreen
        vc.typeDevice = .SmartWatch
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }


    func reloadWatches() {
        watches = DbManager.instance.loadWatches()
        tblWatch.reloadData()
    }


    func onQrCodeScanned(typeDevice: DeviceType, modelWatch: ModelWatch) {

        //-- When user is Manager
        if modelWatch.bIsManager && modelWatch.sUserPhone.isEmpty {
            let storyboard = UIStoryboard(name: "InfoWatch", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerInfoWatch") as! ViewControllerInfoWatch
            vc.modalPresentationStyle = .fullScreen
            vc.modelWatch = modelWatch
            vc.delegate = self
            present(vc, animated: false, completion: nil)
            return
        }
        //-- When user is not Manager
        let storyboard = UIStoryboard(name: "BindComplete", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerBindComplete")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)

        reloadWatches()
    }

}


extension ViewControllerWatch: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watches.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellWatch = tableView.dequeueReusableCell(
            withIdentifier: "rowwatch",
            for           : indexPath
        ) as! CellWatch

        if indexPath.row >= watches.count { return cell }

        let watch = watches[indexPath.row]
        cell.delegate = self
        cell.model = watch
        cell.updateView()

        return cell
    }
}


extension ViewControllerWatch: CellWatchDelegate {

    func onWatchSetDefault(model: ModelWatch) {
        Config.id_watch_monitoring = model.iId
        Config.saveIdWatchMonitoring()
        Config.modelWatchMonitoring = model
        tblWatch.reloadData()
    }

}


extension ViewControllerWatch: ViewControllerQrCodeDelegate {

    func onQrCodeContinue(typeDevice: DeviceType, modelWatch: ModelWatch) {
        onQrCodeScanned(typeDevice: typeDevice, modelWatch: modelWatch)
    }


    func onQrCodeContinue(typeDevice: DeviceType, modelSensor: ModelSensor) {
    }


    func onQrCodeManual(typeDevice: DeviceType) {
        let storyboard = UIStoryboard(name: "Manual", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerManual") as! ViewControllerManual
        vc.modalPresentationStyle = .fullScreen
        vc.typeDevice = .SmartWatch
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
}


extension ViewControllerWatch: ViewControllerManualDelegate {

    func onManualContinue(typeDevice: DeviceType, modelWatch: ModelWatch) {
        onQrCodeScanned(typeDevice: typeDevice, modelWatch: modelWatch)
    }


    func onManualContinue(typeDevice: DeviceType, modelSensor: ModelSensor) {
    }

}


extension ViewControllerWatch: ViewControllerInfoWatchDelegate {
    func onInfoWatchSuccess(model: ModelWatch) {
        let storyboard = UIStoryboard(name: "BindComplete", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerBindComplete")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)

        reloadWatches()
    }
}

