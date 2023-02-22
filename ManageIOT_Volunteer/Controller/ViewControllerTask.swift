import Foundation
import UIKit
import JuphoonCommon


protocol ViewControllerTaskDelegate {
    
}


class ViewControllerTask: UIViewController {

    @IBOutlet weak var viewMap  : UIView!

    private let ANNOT_ME = "annot_me"


    var delegate: ViewControllerTaskDelegate? = nil

    private var viewBmkMap: BMKMapView? = nil
    private var annotMe: BMKPointAnnotation? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Init Map
        viewBmkMap = BMKMapView(frame: viewMap.frame)
        viewBmkMap!.delegate = self
        viewBmkMap!.zoomLevel = 17
        viewBmkMap!.showMapScaleBar = false
        viewBmkMap!.mapType = .standard // .satellite
        viewBmkMap!.showsUserLocation = true
        viewMap.addSubview(viewBmkMap!)

        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(
            latitude: Config.current_lat,
            longitude: Config.current_lon
        )
        viewBmkMap!.setCenter(coordinate, animated: false)

        addAnnotMe()

        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewBmkMap?.viewWillAppear()
        
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewBmkMap?.viewWillDisappear()
    }


    @IBAction func onTouchUpBtnContact(_ sender: Any) {
        tryRequestChat()
    }


    func onBack() {
    }


    func dismissChildren() {
    }


    private func tryRequestChat() {
        var stReq: StReqRequestChat = StReqRequestChat()
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.token  = Config.modelUserInfo.sToken
        stReq.task_id = ""

        API.instance.requestChat(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.juphoon_room_id = stRsp.data?.roomId ?? ""
                    Config.juphoon_room_pswd = stRsp.data?.password ?? ""
                    DispatchQueue.main.async {
                        let app = UIApplication.shared.delegate as? AppDelegate
                        app?.juphoonMain()
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }


    private func addAnnotMe() {
        annotMe = BMKPointAnnotation()
        annotMe!.coordinate.latitude  = Config.current_lat
        annotMe!.coordinate.longitude = Config.current_lon
        viewBmkMap!.addAnnotation(annotMe)
    }
}


//-- For BMKMap
extension ViewControllerTask: BMKMapViewDelegate {

    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        var viewAnnot: BMKPinAnnotationView? = nil

        if (annotation as! BMKPointAnnotation) == annotMe {
            viewAnnot = mapView.dequeueReusableAnnotationView(
                withIdentifier: ANNOT_ME
            ) as? BMKPinAnnotationView
            if viewAnnot == nil {
                viewAnnot = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: ANNOT_ME)
            }
            viewAnnot!.image = UIImage(named: "img_annot_me")
        }

        return viewAnnot
    }
    


}

