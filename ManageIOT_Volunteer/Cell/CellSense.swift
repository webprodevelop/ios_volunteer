import UIKit

class CellSense: UICollectionViewCell {

    @IBOutlet weak var imgSense: UIImageView!
    @IBOutlet weak var lblSense: UILabel!


    override func prepareForReuse() {
        super.prepareForReuse()
        imgSense.image = nil
        lblSense.text = ""
    }


    func updateView(model: ModelNews) {
        imgSense.setCornerRadius(radius: 5)
        imgSense.setShadowDiagonal(color: UIColor.gray, radiusShadow: 5, distance: 5)

        if let url = URL(string: model.sPicture) {
            imgSense.loadImage(url: url)
        }
        else {
            imgSense.image = UIImage(named: "img_news")
        }
        lblSense.text = model.sTitle
    }
}
