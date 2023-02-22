import UIKit

class ViewControllerSos: UIViewController {

    @IBOutlet weak var viewMap   : UIView!
    @IBOutlet weak var lblWatch  : UILabel!
    @IBOutlet weak var lblDate   : UILabel!
    @IBOutlet weak var lblName   : UILabel!
    @IBOutlet weak var lblAddress: UILabel!

    let ANNOT_CUR = "annot_cur"

    var viewBmkMap: BMKMapView? = nil
    var annotCur  : BMKPointAnnotation = BMKPointAnnotation()

    var dLat: Double = Config.DEFAULT_LAT
    var dLon: Double = Config.DEFAULT_LON


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Init Map
        viewBmkMap = BMKMapView(frame: viewMap.frame)
        viewBmkMap!.delegate = self
        viewBmkMap!.zoomLevel = 17
        viewBmkMap!.showMapScaleBar = false
        viewMap.addSubview(viewBmkMap!)

        updateAnnot()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewBmkMap?.viewWillAppear()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewBmkMap?.viewWillDisappear()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpShare(_ sender: Any) {
    // {{ Sharing vcf File
//        let coordinate = CLLocationCoordinate2D(
//            latitude : dLat,
//            longitude: dLon
//        )
//        let urlVCard = generateUrlVCard(
//            coordinate: coordinate,
//            name      : "SOS"
//        )
//        let controller = UIActivityViewController(activityItems: [urlVCard], applicationActivities: nil)
//        present(controller, animated: true, completion: nil)
    // }} Sharing vcf File

    // {{ Sharing URL String
        var url = "http://api.map.baidu.com/direction?origin=latlng:"
        url = url + String(Config.current_lat) + "," + String(Config.current_lon)
        url = url + "|name:" + Config.current_addr
        url = url + "&destination=" + (lblAddress.text ?? "")
        url = url + "&mode=driving"
        url = url + "&region=中国"
        url = url + "&output=html&src=webapp.baidu.openAPIdemo"

        let controller = UIActivityViewController(
            activityItems: [url] as [Any],
            applicationActivities: nil
        )

        //-- Avoid Crash on iPad
        if let popover = controller.popoverPresentationController {
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.sourceView = self.view
            popover.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        present(controller, animated: true, completion: nil)
    // }} Sharing URL String
    }


    func updateAnnot() {
        annotCur.coordinate = CLLocationCoordinate2D(latitude: dLat, longitude: dLon)
        viewBmkMap!.addAnnotation(annotCur)
        viewBmkMap!.setCenter(annotCur.coordinate, animated: false)
    }
}


extension ViewControllerSos: BMKMapViewDelegate {

    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if annotation.isEqual(annotCur) {
            var viewAnnot: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(
                withIdentifier: ANNOT_CUR
            ) as? BMKPinAnnotationView

            if viewAnnot == nil {
                viewAnnot = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOT_CUR)
            }
            viewAnnot?.image = UIImage(named: "img_annotation.png")
            return viewAnnot
        }

        return nil
    }

}
