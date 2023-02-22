import UIKit


protocol CellFenceDelegate: AnyObject {
    func onFenceEdit(model: ModelFence)
    func onFenceDel(model: ModelFence)
}


class CellFence: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtAddr: UITextView!

    var delegate: CellFenceDelegate?
    var modelFence: ModelFence = ModelFence()


    override func prepareForReuse() {
        super.prepareForReuse()
    }


    @IBAction func onTouchUpEdit(_ sender: Any) {
        delegate?.onFenceEdit(model: modelFence)
    }


    @IBAction func onTouchUpDel(_ sender: Any) {
        delegate?.onFenceDel(model: modelFence)
    }


    func updateView() {
        lblName.text = modelFence.sName
        txtAddr.text = modelFence.sAddr
    }
}
