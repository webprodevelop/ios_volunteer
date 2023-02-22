import Foundation

extension UIImage {

    func resizeImage(dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width   : CGFloat
        var height  : CGFloat
        var newImage: UIImage

        let size = self.size
        let ratio = size.width / size.height

        switch contentMode {
            case .scaleAspectFit:
                if ratio > 1 {
                    // Landscape
                    width  = dimension
                    height = dimension / ratio
                }
                else {
                    // Portrait
                    width  = dimension * ratio
                    height = dimension
                }
                break
            default:
                width  = dimension
                height = dimension
                break
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }


    func rotate(radian: Float) -> UIImage? {
        var sizeNew = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radian))).size
        //-- Trim small float value to prevent core graphics from rounding it up
        sizeNew.width  = floor(sizeNew.width)
        sizeNew.height = floor(sizeNew.height)

        UIGraphicsBeginImageContextWithOptions(sizeNew, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        //-- Move origin to middle
        context.translateBy(x: sizeNew.width / 2, y: sizeNew.height / 2)
        //-- Rotate around middle
        context.rotate(by: CGFloat(radian))
        //-- Draw the image at its center
        self.draw(in: CGRect(
            x: -self.size.width  / 2,
            y: -self.size.height / 2,
            width : self.size.width,
            height: self.size.height
        ))

        let imageNew = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return imageNew
    }


    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.7) else { return nil }
        return imageData.base64EncodedString()
    }

}
