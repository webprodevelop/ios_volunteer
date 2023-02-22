import UIKit

class CellPetbite: UITableViewCell {

    @IBOutlet weak var lblTitle  : UILabel!
    @IBOutlet weak var btnShare  : UIButton!
    @IBOutlet weak var txtContent: UITextView!

    override func prepareForReuse() {
        super.prepareForReuse()
        lblTitle.text = ""
        txtContent.text = ""
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func updateView() {
        btnShare.backgroundColor = .clear
        btnShare.layer.cornerRadius = 5
        btnShare.layer.borderWidth = 2
        btnShare.layer.borderColor = UIColor.brown.cgColor

        lblTitle.text   = "Petbite"
        txtContent.text = "Da jia hao"
    }

}
