import Foundation
import UIKit

extension UIView {

    static var LAYER_SHADOW = 11

    var layerShadow: CALayer? {
        get {
            guard let value = objc_getAssociatedObject(self, &UIView.LAYER_SHADOW) as? CALayer else {
                return nil
            }
            return value
        }
        set(value) {
            objc_setAssociatedObject(self, &UIView.LAYER_SHADOW, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }


    func setCornerRadius(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = false
        clipsToBounds = true
    }

    
    func setShadowSelf(color: UIColor, opacityShadow: Float, radiusShadow: CGFloat, distance: CGSize) {
        layer.shadowColor   = color.cgColor
        layer.shadowRadius  = radiusShadow
        layer.shadowOpacity = opacityShadow
        layer.shadowOffset  = distance
        layer.masksToBounds = false
    }


    func setShadowDiagonal(color: UIColor, radiusShadow: CGFloat, distance: CGFloat) {
        layerShadow?.removeFromSuperlayer()
        layerShadow = CALayer()
        layerShadow!.frame = CGRect(
            x: frame.minX + distance * 1.5,
            y: frame.minY + distance * 2,
            width : frame.width  - distance,
            height: frame.height - distance
        )
        layerShadow!.shadowPath  = UIBezierPath(rect: layerShadow!.bounds).cgPath
        layerShadow!.shadowColor = color.cgColor
        layerShadow!.shadowOpacity = 1
        layerShadow!.shadowRadius = radiusShadow

        superview?.layer.insertSublayer(layerShadow!, below: layer)
        layerShadow?.isHidden = isHidden
    }
}
