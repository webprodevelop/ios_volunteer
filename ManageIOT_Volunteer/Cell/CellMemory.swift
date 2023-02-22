import UIKit


protocol CellMemoryDelegate: AnyObject {
    func onMemorySwitch(memory: ModelMemory, isOn: Bool)
    func onMemoryEdit(memory: ModelMemory)
    func onMemoryDelete(memory: ModelMemory)
}


class CellMemory: UITableViewCell {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var swtOnOff: UISwitch!
    @IBOutlet weak var lblTips: UILabel!
    @IBOutlet weak var lblDays: UILabel!

    var delegate: CellMemoryDelegate?
    var memory: ModelMemory?


    override func prepareForReuse() {
        super.prepareForReuse()
        lblTime.text = ""
        lblName.text = ""
        swtOnOff.isOn = false
        lblTips.text = ""
        lblDays.text = ""
        memory = ModelMemory()
    }


    @IBAction func onChangedSwitch(_ sender: Any) {
        let bTurn = (sender as! UISwitch).isOn
        if bTurn { memory!.iTurn = 1 } else { memory!.iTurn = 0 }
        delegate?.onMemorySwitch(memory: memory!, isOn: bTurn)
    }


    @IBAction func onTouchUpEdit(_ sender: Any) {
        delegate?.onMemoryEdit(memory: memory!)
    }


    @IBAction func onTouchUpDelete(_ sender: Any) {
        delegate?.onMemoryDelete(memory: memory!)
    }


    func updateView() {
        if memory!.iTurn == 1 { swtOnOff.isOn = true } else { swtOnOff.isOn = false }
        lblName.text = memory!.sName
        lblTips.text = memory!.sTips
        lblTime.text = memory!.sTime
        var sDays = ""
        if memory!.wdays[0] == "1" { sDays += "Mon".localized() + "," }
        if memory!.wdays[1] == "1" { sDays += "Tue".localized() + "," }
        if memory!.wdays[2] == "1" { sDays += "Wed".localized() + "," }
        if memory!.wdays[3] == "1" { sDays += "Thu".localized() + "," }
        if memory!.wdays[4] == "1" { sDays += "Fri".localized() + "," }
        if memory!.wdays[5] == "1" { sDays += "Sat".localized() + "," }
        if memory!.wdays[6] == "1" { sDays += "Sun".localized() + "," }
        if sDays.count == 0 {
            sDays = "No repeat".localized()
        }
        else {
            sDays = String(sDays.prefix(sDays.count - 1)) // Remove Last Comma
        }
        lblDays.text = sDays
    }
}
