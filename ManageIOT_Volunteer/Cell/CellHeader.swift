import UIKit


protocol CellHeaderDelegate: AnyObject {
    func onHeaderAddDevice(type: DeviceType)
}


class CellHeader: UICollectionReusableView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!

    var typeDevice: DeviceType = .SmartWatch
    var delegate: CellHeaderDelegate?


    @IBAction func onTouchUpAdd(_ sender: Any) {
        delegate?.onHeaderAddDevice(type: typeDevice)
    }

}
