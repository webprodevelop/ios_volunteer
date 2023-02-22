import UIKit


protocol CellDiseaseDelegate: AnyObject {
    func onDiseaseSelected(index: Int, checked: Bool)
}


class CellDisease: UITableViewCell {

    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTitle: UILabel!

    var delegate: CellDiseaseDelegate? = nil
    var index   : Int = -1
    var bChecked: Bool = false


    override func prepareForReuse() {
        super.prepareForReuse()

        btnCheck.setImage(UIImage(named: "img_check_off"), for: .normal)
        lblTitle.text = ""
        bChecked = false
    }


    @IBAction func onTouchUpCheck(_ sender: Any) {
        bChecked = !bChecked
        updateBtnCheck()
        delegate?.onDiseaseSelected(index: index, checked: bChecked)
    }


    func setStatus(checked: Bool) {
        bChecked = checked
        updateBtnCheck()
    }


    func updateBtnCheck() {
        if bChecked {
            btnCheck.setImage(UIImage(named: "img_check_on"), for: .normal)
        }
        else {
            btnCheck.setImage(UIImage(named: "img_check_off"), for: .normal)
        }
    }

}
