import UIKit


protocol CellMessageDelegate: AnyObject {
    func onMessageDelete(model: ModelMessage)
}


class CellMessage: UITableViewCell {

    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle  : UILabel!
    @IBOutlet weak var lblDate   : UILabel!
    @IBOutlet weak var txtContent: UITextView!

    var delegate: CellMessageDelegate? = nil
    var message : ModelMessage? = nil


    override func prepareForReuse() {
        super.prepareForReuse()
        imgIcon.image = UIImage()
        lblTitle.text = ""
        lblDate.text  = ""
        txtContent.text = ""

        lblTitle.textColor   = UIColor.black
        txtContent.textColor = UIColor.black
        lblDate.textColor    = UIColor.black
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1.0)
            lblTitle.backgroundColor    = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1.0)
            txtContent.backgroundColor  = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1.0)
            lblDate.backgroundColor     = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1.0)
        }
        else {
            contentView.backgroundColor = UIColor.white
            lblTitle.backgroundColor    = UIColor.white
            txtContent.backgroundColor  = UIColor.white
            lblDate.backgroundColor     = UIColor.white
        }
    }


    @IBAction func onTouchUpDelete(_ sender: Any) {
        delegate?.onMessageDelete(model: message ?? ModelMessage())
    }


    func updateView() {
        lblTitle.text   = message?.sCategory
        txtContent.text = message?.sBody
        lblDate.text    = message?.sTime

        if (message?.sCategory == "新任务") {
            if (message?.iRead ?? 0) > 0 {
                imgIcon.image = UIImage(named: "img_sos_saw")
            }
            else {
                imgIcon.image = UIImage(named: "img_sos_new")
            }
        }
        else {
            if (message?.iRead ?? 0) > 0 {
                imgIcon.image = UIImage(named: "img_msg_saw")
            }
            else {
                imgIcon.image = UIImage(named: "img_msg_new")
            }
        }

        if (message?.iRead ?? 0) > 0 {
            lblTitle.textColor   = UIColor.lightGray
            txtContent.textColor = UIColor.lightGray
            lblDate.textColor    = UIColor.lightGray
        }
        else {
            lblTitle.textColor   = UIColor.black
            txtContent.textColor = UIColor.black
            lblDate.textColor    = UIColor.black
        }
    }
}
