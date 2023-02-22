import UIKit

class ViewControllerDevice: UIViewController {

    @IBOutlet weak var cltDevices: UICollectionView!

    var smartwatches: [ModelWatch]  = [ModelWatch]()
    var firesensors : [ModelSensor] = [ModelSensor]()
    var smokesensors: [ModelSensor] = [ModelSensor]()


    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDevices()
    }


    func reloadDevices() {
        smartwatches.removeAll()
        firesensors.removeAll()
        smokesensors.removeAll()

        smartwatches = DbManager.instance.loadWatches()
        firesensors  = DbManager.instance.loadSensors(type: .FireSensor)
        smokesensors = DbManager.instance.loadSensors(type: .SmokeSensor)

        cltDevices.reloadData()
    }


    func initCellSmartWatch(cell: CellDevice, index: Int) {
        if index >= smartwatches.count { return }
        let model: ModelWatch = smartwatches[index]
        cell.updateForSmartWatch(modelWatch: model)
    }


    func initCellFireSensor(cell: CellDevice, index: Int) {
        if index >= firesensors.count { return }
        let model: ModelSensor = firesensors[index]
        cell.updateForFireSensor(modelSensor: model)
    }


    func initCellSmokeSensor(cell: CellDevice, index: Int) {
        if index >= smokesensors.count { return }
        let model: ModelSensor = smokesensors[index]
        cell.updateForSmokeSensor(modelSensor: model)
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
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerBindComplete") as! ViewControllerBindComplete
        vc.modalPresentationStyle = .fullScreen
        vc.type  = typeDevice
        vc.model = modelWatch
        present(vc, animated: false, completion: nil)
        reloadDevices()
    }


    func onQrCodeScanned(typeDevice: DeviceType, modelSensor: ModelSensor) {
        //-- When user is Manager
        if modelSensor.bIsManager && modelSensor.sContactPhone.isEmpty {
            let storyboard = UIStoryboard(name: "InfoSensor", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerInfoSensor") as! ViewControllerInfoSensor
            vc.modalPresentationStyle = .fullScreen
            vc.modelSensor = modelSensor
            vc.delegate = self
            present(vc, animated: false, completion: nil)
        }
        //-- When user is not Manager
        let storyboard = UIStoryboard(name: "BindComplete", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerBindComplete") as! ViewControllerBindComplete
        vc.modalPresentationStyle = .fullScreen
        vc.type  = typeDevice
        vc.model = modelSensor
        present(vc, animated: false, completion: nil)
        reloadDevices()
    }


    func launchQrCode(type: DeviceType) {
        let storyboard = UIStoryboard(name: "QrCode", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerQrCode") as! ViewControllerQrCode
        vc.modalPresentationStyle = .fullScreen
        vc.typeDevice = type
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }


    func launchIapPeriod(type: DeviceType, model: Any) {
        let storyboard = UIStoryboard(name: "IapPeriod", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerIapPeriod") as! ViewControllerIapPeriod
        vc.modalPresentationStyle = .fullScreen
        vc.type = type
        vc.model = model
        let nc = UINavigationController(rootViewController: vc)
        nc.isNavigationBarHidden = true
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }


    func launchIapDetail(type: DeviceType, model: Any) {
        let storyboard = UIStoryboard(name: "IapDetail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerIapDetail") as! ViewControllerIapDetail
        vc.modalPresentationStyle = .fullScreen
        vc.type = type
        vc.model = model
        present(vc, animated: false, completion: nil)
    }
}


extension ViewControllerDevice: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }


    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        switch section {
            case 0: if smartwatches.count == 0 { return 1 }; return smartwatches.count
            case 1: if firesensors.count  == 0 { return 1 }; return firesensors.count
            case 2: if smokesensors.count == 0 { return 1 }; return smokesensors.count
            default: break
        }
        return 0
    }


    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        switch indexPath.section {
            case 0:
                if smartwatches.count == 0 {
                    let cell: CellDeviceEmpty = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "rowdeviceempty",
                        for                : indexPath
                    ) as! CellDeviceEmpty
                    cell.delegate = self
                    cell.type = .SmartWatch
                    return cell
                }

                let cell: CellDevice = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "rowdevice",
                    for                : indexPath
                ) as! CellDevice
                cell.delegate = self
                initCellSmartWatch(cell: cell, index: indexPath.item)
                return cell

            case 1:
                if firesensors.count == 0 {
                    let cell: CellDeviceEmpty = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "rowdeviceempty",
                        for                : indexPath
                    ) as! CellDeviceEmpty
                    cell.delegate = self
                    cell.type = .FireSensor
                    return cell
                }

                let cell: CellDevice = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "rowdevice",
                    for                : indexPath
                ) as! CellDevice
                cell.delegate = self
                initCellFireSensor(cell: cell, index: indexPath.item)
                return cell

            case 2:
                if smokesensors.count == 0 {
                    let cell: CellDeviceEmpty = collectionView.dequeueReusableCell(
                        withReuseIdentifier: "rowdeviceempty",
                        for                : indexPath
                    ) as! CellDeviceEmpty
                    cell.delegate = self
                    cell.type = .SmokeSensor
                    return cell
                }

                let cell: CellDevice = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "rowdevice",
                    for                : indexPath
                ) as! CellDevice
                cell.delegate = self
                initCellSmokeSensor(cell: cell, index: indexPath.item)
                return cell

            default: break
        }

        return UICollectionViewCell()
    }


    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        var header: CellHeader?
        if kind == UICollectionView.elementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryView(
                ofKind             : kind,
                withReuseIdentifier: "rowheader",
                for                : indexPath
            ) as? CellHeader

            header?.delegate = self

            if indexPath.section == 0 {
                header?.typeDevice = .SmartWatch
                header?.lblTitle.text = "Group SmartWatch".localized()
            }
            if indexPath.section == 1 {
                header?.typeDevice = .FireSensor
                header?.lblTitle.text = "Group FireSensor".localized()
            }
            if indexPath.section == 2 {
                header?.typeDevice = .SmokeSensor
                header?.lblTitle.text = "Group SmokeSensor".localized()
            }
        }
        return header ?? CellHeader()
    }


    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        print("cell \(indexPath.row) selected")
    }
}


extension ViewControllerDevice: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath    : IndexPath
    ) -> CGSize {
        return CGSize(width: 380, height: 200)
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 20
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
        return UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
    }
}


extension ViewControllerDevice: CellHeaderDelegate, CellDeviceDelegate, CellDeviceEmptyDelegate {

    func onHeaderAddDevice(type: DeviceType) {
        launchQrCode(type: type)
    }


    func onDeviceTouchUpSetting(type: DeviceType, model: Any?) {
        if type == .SmartWatch {
            let modelWatch = model as! ModelWatch

            if !modelWatch.bIsManager {
                showAlert(message: "You have no permission".localized())
                return
            }
            let storyboard = UIStoryboard(name: "InfoWatch", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerInfoWatch") as! ViewControllerInfoWatch
            vc.modalPresentationStyle = .fullScreen
            vc.modelWatch = modelWatch
            vc.delegate = self
            present(vc, animated: false, completion: nil)
            return
        }

        let modelSensor = model as! ModelSensor
        let storyboard = UIStoryboard(name: "InfoSensor", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerInfoSensor") as! ViewControllerInfoSensor
        vc.modalPresentationStyle = .fullScreen
        vc.modelSensor = modelSensor
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }


    func onDeviceTouchUpDelete(type: DeviceType, model: Any?) {
        let storyboard = UIStoryboard(name: "Unbind", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerUnbind") as! ViewControllerUnbind
        vc.modalPresentationStyle = .overCurrentContext
        vc.type = type
        vc.model = model
        vc.delegate = self
        present(vc, animated:true, completion: nil)
    }


    func onDeviceTouchUpDefer(type: DeviceType, model: Any?) {
        switch type {
            case .SmartWatch:
                let modelWatch = model as! ModelWatch
                if !isWithinOneMonth(sDate: modelWatch.sServiceEnd) {       // TODO : Invert later
                    launchIapPeriod(type: type, model: model!)
                }
                else {
                    launchIapDetail(type: type, model: model!)
                }
                break
            case .FireSensor, .SmokeSensor:
                let modelSensor = model as! ModelSensor
                if isWithinOneMonth(sDate: modelSensor.sServiceEnd) {
                    launchIapPeriod(type: type, model: model!)
                }
                else {
                    launchIapDetail(type: type, model: model!)
                }
                break
        }
    }


    func onDeviceEmptyTouchUpAdd(type: DeviceType) {
        launchQrCode(type: type)
    }

}


extension ViewControllerDevice: ViewControllerQrCodeDelegate {

    func onQrCodeContinue(typeDevice: DeviceType, modelWatch: ModelWatch) {
        onQrCodeScanned(typeDevice: typeDevice, modelWatch: modelWatch)
    }


    func onQrCodeContinue(typeDevice: DeviceType, modelSensor: ModelSensor) {
        onQrCodeScanned(typeDevice: typeDevice, modelSensor: modelSensor)
    }


    func onQrCodeManual(typeDevice: DeviceType) {
        let storyboard = UIStoryboard(name: "Manual", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerManual") as! ViewControllerManual
        vc.modalPresentationStyle = .fullScreen
        vc.typeDevice = typeDevice
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
}


extension ViewControllerDevice: ViewControllerManualDelegate {

    func onManualContinue(typeDevice: DeviceType, modelWatch: ModelWatch) {
        onQrCodeScanned(typeDevice: typeDevice, modelWatch: modelWatch)
    }


    func onManualContinue(typeDevice: DeviceType, modelSensor: ModelSensor) {
        onQrCodeScanned(typeDevice: typeDevice, modelSensor: modelSensor)
    }

}


extension ViewControllerDevice: ViewControllerInfoWatchDelegate {
    func onInfoWatchSuccess(model: ModelWatch) {
        let storyboard = UIStoryboard(name: "BindComplete", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerBindComplete") as! ViewControllerBindComplete
        vc.modalPresentationStyle = .fullScreen
        vc.type  = .SmartWatch
        vc.model = model
        present(vc, animated: false, completion: nil)

        reloadDevices()
    }
}


extension ViewControllerDevice: ViewControllerInfoSensorDelegate {
    func onInfoSensorSuccess(model: ModelSensor) {
        let storyboard = UIStoryboard(name: "BindComplete", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerBindComplete") as! ViewControllerBindComplete
        vc.modalPresentationStyle = .fullScreen
        vc.type  = .FireSensor
        vc.model = model
        present(vc, animated: false, completion: nil)

        reloadDevices()
    }
}


extension ViewControllerDevice: ViewControllerUnbindDelegate {
    func onUnbindSuccess() {
        reloadDevices()
    }
}
