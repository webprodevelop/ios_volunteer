import Foundation
import UIKit


class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var vc      : UIViewController? = nil
    var alert   : UIAlertController
    var picker  : UIImagePickerController = UIImagePickerController();
    var callback: ((UIImage) -> ())? = nil


    override init() {
        var type: UIAlertController.Style = .actionSheet
        if UIDevice.current.userInterfaceIdiom == .pad {
            type = .alert
        }
        alert = UIAlertController(
            title  : "Choose Image".localized(),
            message: nil,
            preferredStyle: type
        )
        super.init()
    }


    func pickImage(_ vc: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        self.callback = callback;
        self.vc = vc;

        picker.delegate = self

        let actionCamera = UIAlertAction(title: "Camera".localized(), style: .default) { UIAlertAction in
            self.openCamera()
        }
        let actionGallery = UIAlertAction(title: "Gallery".localized(), style: .default) { UIAlertAction in
            self.openGallery()
        }
        let actionCancel = UIAlertAction(title: "Cancel".localized(), style: .cancel) { UIAlertAction in
            self.cancelPicker()
        }

        alert.addAction(actionCamera)
        alert.addAction(actionGallery)
        alert.addAction(actionCancel)

        vc.present(alert, animated: false, completion: nil)
    }


    func openCamera() {
        alert.dismiss(animated: true, completion: nil)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            vc!.present(picker, animated: true, completion: nil)
        }
        else {
            vc?.showToast(message: "Can't access camera!".localized(), completion: nil)
        }
    }


    func openGallery() {
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        self.vc!.present(picker, animated: true, completion: nil)
    }


    func cancelPicker() {
        picker.dismiss(animated: true, completion: nil)
    }


    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        callback?(image)
        picker.dismiss(animated: true, completion: nil)
    }

}
