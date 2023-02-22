import Foundation
import UIKit

extension UITextField {
    @objc func onTappedDone()   { self.resignFirstResponder() }
    @objc func onTappedCancel() { self.resignFirstResponder() }

    func addDoneCancelToolbar(
        onDone  : (target: Any, action: Selector)? = nil,
        onCancel: (target: Any, action: Selector)? = nil
    ) {
        let onDone   = onDone   ?? (target: self, action: #selector(onTappedDone))
        let onCancel = onCancel ?? (target: self, action: #selector(onTappedCancel))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done".localized(),   style: .done,  target: onDone.target,   action: onDone.action)
        ]
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
}
