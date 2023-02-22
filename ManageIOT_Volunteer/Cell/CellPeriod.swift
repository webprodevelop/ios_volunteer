import UIKit


protocol CellPeriodDelegate: AnyObject {
    func onPeriodStart(model: ModelPeriod)
    func onPeriodEnd(model: ModelPeriod)
    func onPeriodAdd(model: ModelPeriod)
    func onPeriodDel(model: ModelPeriod)
}


class CellPeriod: UITableViewCell {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnEnd  : UIButton!
    @IBOutlet weak var btnEdit : UIButton!

    var delegate: CellPeriodDelegate? = nil
    var modelPeriod: ModelPeriod = ModelPeriod()
    var operation: String = "-"


    override func prepareForReuse() {
        super.prepareForReuse()
        btnStart.setTitle("", for: .normal)
        btnEnd.setTitle("", for: .normal)
        btnEdit.setTitle("-", for: .normal)
    }


    @IBAction func onTouchupStart(_ sender: Any) {
        if operation == "-" {
            return
        }
        delegate?.onPeriodStart(model: modelPeriod)
    }


    @IBAction func onTouchupEnd(_ sender: Any) {
        if operation == "-" {
            return
        }
        delegate?.onPeriodEnd(model: modelPeriod)
    }


    @IBAction func onTouchUpEdit(_ sender: Any) {
        if operation == "+" {
            if (btnStart.title(for: .normal) ?? "").isEmpty {
                return
            }
            if (btnEnd.title(for: .normal) ?? "").isEmpty {
                return
            }
            if modelPeriod.sStart > modelPeriod.sEnd {
                let sTemp = modelPeriod.sStart
                modelPeriod.sStart = modelPeriod.sEnd
                modelPeriod.sEnd = sTemp
            }
            delegate?.onPeriodAdd(model: modelPeriod)
        }
        else {
            delegate?.onPeriodDel(model: modelPeriod)
        }
    }


    func updateView() {
        btnEdit.setTitle(operation, for: .normal)
        if modelPeriod.sStart.isEmpty {
            btnStart.setTitle("Start Time".localized(), for: .normal)
        }
        else {
            btnStart.setTitle(modelPeriod.sStart, for: .normal)
        }
        if modelPeriod.sEnd.isEmpty {
            btnEnd.setTitle("End Time".localized(), for: .normal)
        }
        else {
            btnEnd.setTitle(modelPeriod.sEnd, for: .normal)
        }

        if operation == "+" {
            btnStart.setTitleColor(UIColor.lightGray, for: .normal)
            btnEnd.setTitleColor(UIColor.lightGray, for: .normal)
        }
        else {
            btnStart.setTitleColor(UIColor.darkGray, for: .normal)
            btnEnd.setTitleColor(UIColor.darkGray, for: .normal)
        }
    }
}
