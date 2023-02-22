import UIKit
import WebKit

extension UIViewController {


    static func findBestViewController(vc: UIViewController?) -> UIViewController? {
        if vc == nil { return nil }
        if vc!.presentedViewController != nil {
            return findBestViewController(vc: vc!.presentedViewController)
        }

        if vc!.isKind(of: UISplitViewController.self) {
            let svc = vc as! UISplitViewController
            if svc.viewControllers.count > 0 {
                return findBestViewController(vc: svc.viewControllers.last)
            }
            return vc
        }
        else if vc!.isKind(of: UINavigationController.self) {
            let svc = vc as! UINavigationController
            if svc.viewControllers.count > 0 {
                return findBestViewController(vc: svc.topViewController)
            }
            return vc
        }
        else if vc!.isKind(of: UITabBarController.self) {
            let svc = vc as! UITabBarController
            if (svc.viewControllers?.count ?? 0) > 0 {
                return findBestViewController(vc: svc.selectedViewController)
            }
            return vc;
        }

        return vc
    }


    static func currentViewController() -> UIViewController? {
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        return findBestViewController(vc: viewController)
    }


    func showConfirm(title: String, message: String, handlerOk: ((UIAlertAction) -> Void)?, handlerCancel: ((UIAlertAction) -> Void)?) {
        DispatchQueue.main.async {
            let alertController: UIAlertController = UIAlertController(
                title  : title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            let alertActionOk: UIAlertAction = UIAlertAction(
                title  : "OK".localized(),
                style  : UIAlertAction.Style.default,
                handler: handlerOk
            )
            let alertActionCancel: UIAlertAction = UIAlertAction(
                title  : "Cancel".localized(),
                style  : UIAlertAction.Style.default,
                handler: handlerCancel
            )
            alertController.addAction(alertActionOk)
            alertController.addAction(alertActionCancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alertController: UIAlertController = UIAlertController(
                title  : nil,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            let alertAction: UIAlertAction = UIAlertAction(
                title  : "OK".localized(),
                style  : UIAlertAction.Style.default,
                handler: nil
            )
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    typealias AlertRetFunc = () -> Void
    
    func showAlert(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController: UIAlertController = UIAlertController(
                title  : nil,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            let alertAction: UIAlertAction = UIAlertAction(
                title  : "OK".localized(),
                style  : UIAlertAction.Style.default,
                handler: handler
            )
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func showAlert(title:String, message: String) {
        DispatchQueue.main.async {
            let alertController: UIAlertController = UIAlertController(
                title  : title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            let alertAction: UIAlertAction = UIAlertAction(
                title  : "OK".localized(),
                style  : UIAlertAction.Style.default,
                handler: nil
            )
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }


    func showToast(message: String, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let lblToast = UILabel(frame: CGRect(
                x: self.view.frame.size.width / 2 - 100,
                y: self.view.frame.size.height - 100,
                width : 200,
                height: 40
            ))
            lblToast.text = " " + message + " "
            lblToast.font = lblToast.font.withSize(17)
            lblToast.textColor = UIColor.white
            lblToast.textAlignment = .center
            lblToast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            lblToast.alpha = 1.0
            lblToast.layer.cornerRadius = 20
            lblToast.clipsToBounds  =  true
            self.view.addSubview(lblToast)
            UIView.animate(
                withDuration: 2.0,
                delay       : 1.0,
                options     : .curveEaseOut,
                animations  : {
                     lblToast.alpha = 0.0
                },
                completion  : { (bCompleted) in
                    DispatchQueue.main.async {
                        lblToast.removeFromSuperview()
                        completion?()
                    }
                }
            )
        }
    }


    //------------------------------------------------
    // For Child ViewController
    //------------------------------------------------
    func addChildViewController(child: UIViewController, container: UIView, frame: CGRect) {
        addChild(child)
        child.view.frame = frame
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }


    func dismissFromParent() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

}
