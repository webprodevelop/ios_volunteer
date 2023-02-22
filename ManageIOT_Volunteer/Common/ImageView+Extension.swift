import Foundation

extension UIImageView {

    func loadImage(url: URL) -> Bool {
        if let data = try? Data(contentsOf: url) {
            if let img = UIImage(data: data) {
                image = img
                return true
            }
        }
        return false
    }


    func makeRounded() {
        layer.borderWidth = 0 // 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }

}
