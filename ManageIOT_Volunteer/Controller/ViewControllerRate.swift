import UIKit

class ViewControllerRate: UIViewController {

    @IBOutlet weak var tblRate: UITableView!
    @IBOutlet weak var btnAbnormal: UIButton!
    @IBOutlet weak var btnNormal  : UIButton!
    @IBOutlet weak var viewUnderlineAbnormal: UIView!
    @IBOutlet weak var viewUnderlineNormal  : UIView!

    var bAbnormal: Bool = true
    var ratesAbnormal: [ModelRate] = [ModelRate]()
    var ratesNormal  : [ModelRate] = [ModelRate]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Color of Abnormal and Normal Button
        btnAbnormal.setTitleColor(UIColor(red: 50/255.0, green: 145/255.0, blue: 248/255.0, alpha: 1.0), for: .normal)
        btnNormal.setTitleColor(UIColor(red: 138/255.0, green: 138/255.0, blue: 138/255.0, alpha: 1.0), for: .normal)
        viewUnderlineAbnormal.isHidden = false
        viewUnderlineNormal.isHidden   = true

        Timer.scheduledTimer(
            timeInterval: 0.2,
            target      : self,
            selector    : #selector(launchCall),
            userInfo    : nil,
            repeats     : false
        )
        //-- Init
        bAbnormal = true
        loadData()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpAbnormal(_ sender: Any) {
        //-- Color of Abnormal and Normal Button
        btnAbnormal.setTitleColor(UIColor(red: 50/255.0, green: 145/255.0, blue: 248/255.0, alpha: 1.0), for: .normal)
        btnNormal.setTitleColor(UIColor(red: 138/255.0, green: 138/255.0, blue: 138/255.0, alpha: 1.0), for: .normal)
        viewUnderlineAbnormal.isHidden = false
        viewUnderlineNormal.isHidden   = true
        bAbnormal = true
        tblRate.reloadData()
    }


    @IBAction func onTouchUpNormal(_ sender: Any) {
        //-- Color of Abnormal and Normal Button
        btnAbnormal.setTitleColor(UIColor(red: 138/255.0, green: 138/255.0, blue: 138/255.0, alpha: 1.0), for: .normal)
        btnNormal.setTitleColor(UIColor(red: 50/255.0, green: 145/255.0, blue: 248/255.0, alpha: 1.0), for: .normal)
        viewUnderlineAbnormal.isHidden   = true
        viewUnderlineNormal.isHidden = false
        bAbnormal = true
        tblRate.reloadData()
    }

    
    @objc func launchCall() {
        DispatchQueue.main.async {
            //-- Launch ViewControllerCall first
            let storyboard = UIStoryboard(name: "Call", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerCall")
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    

    func loadData() {
        let rates = DbManager.instance.loadRates()
        for rate in rates {
            if rate.iValue > Config.HEART_RATE_MAX {
                ratesAbnormal.append(rate)
            }
            else if rate.iValue < Config.HEART_RATE_MIN {
                ratesAbnormal.append(rate)
            }

            ratesNormal.append(rate)
        }
    }
}


extension ViewControllerRate: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bAbnormal {
            return ratesAbnormal.count + 1
        }
        return ratesNormal.count + 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellRate = tableView.dequeueReusableCell(
            withIdentifier: "rowrate",
            for           : indexPath
        ) as! CellRate

        if indexPath.row == 0 {
            cell.lblDate.text = "Record Date".localized()
            cell.lblTime.text = "Record Time".localized()
            cell.lblRate.text = "Rate".localized()
            cell.lblDate.textColor = UIColor.black
            cell.lblTime.textColor = UIColor.black
            cell.lblRate.textColor = UIColor.black
            cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            return cell
        }

        var rate: ModelRate
        if bAbnormal {
            rate = ratesAbnormal[indexPath.row]
        }
        else {
            rate = ratesAbnormal[indexPath.row]
        }
        cell.lblDate.text = rate.sDate
        cell.lblTime.text = rate.sTime
        cell.lblRate.text = String(rate.iValue)
        cell.lblDate.textColor = UIColor.darkGray
        cell.lblTime.textColor = UIColor.darkGray
        
        if rate.iValue > Config.HEART_RATE_MAX {
            cell.lblRate.textColor = UIColor.red
        }
        else if rate.iValue < Config.HEART_RATE_MIN {
            cell.lblRate.textColor = UIColor.red
        }
        else {
            cell.lblRate.textColor = UIColor.darkGray
        }
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        }
        else {
            cell.contentView.backgroundColor = UIColor.white
        }

        return cell
    }
}

