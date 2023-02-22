import UIKit


protocol CellDeviceEmptyDelegate: AnyObject {
    func onDeviceEmptyTouchUpAdd(type: DeviceType)
}


class CellDeviceEmpty: UICollectionViewCell {

    @IBOutlet weak var btnNoDevice: UIButton!

    var delegate: CellDeviceEmptyDelegate? = nil
    var type: DeviceType = .SmartWatch


    override func prepareForReuse() {
        super.prepareForReuse()
        btnNoDevice.setTitle("No device, please add".localized(), for: .normal)
    }


    @IBAction func onTouchUpNoDevice(_ sender: Any) {
        delegate?.onDeviceEmptyTouchUpAdd(type: type)
    }

}
