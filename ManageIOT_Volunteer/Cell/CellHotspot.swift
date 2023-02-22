import UIKit

class CellHotspot: UITableViewCell {

    @IBOutlet weak var imgHotspot: UIImageView!
    @IBOutlet weak var lblHotspot: UILabel!


    override func prepareForReuse() {
        super.prepareForReuse()
        imgHotspot.image = nil
        lblHotspot.text  = ""
    }


    func updateView(model: ModelNews) {
        imgHotspot.setCornerRadius(radius: 5)
        imgHotspot.setShadowDiagonal(color: UIColor.gray, radiusShadow: 5, distance: 5)

        if let url =  URL(string: model.sPicture) {
            imgHotspot.loadImage(url: url)
        }
        else {
            imgHotspot.image = UIImage(named: "img_news")
        }
        lblHotspot.text = model.sTitle
    }

}
