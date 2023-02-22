//
//  BMKSecondaryCataloguePage.swift
//  BMKSwiftDemo
//
//  Created by Baidu RD on 2018/7/23.
//  Copyright © 2018年 Baidu. All rights reserved.
//

import UIKit

class BMKSecondaryCataloguePage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var catalogueDatas: [Dictionary<NSString, NSString>]?
    var currentTitle: String?
    let cellIdentifier = "com.Baidu.BMKCatalogueTableViewCell"
    
    //MARK:View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    //MARK: - Config UI
    func configUI() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = COLOR(0xFFFFFF)
        view.backgroundColor = COLOR(0xFFFFFF)
        title = currentTitle
        view.addSubview(tableView)
    }
    
    //MARK:UITableViewDataSource & UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalogueDatas!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BMKCatalogueTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BMKCatalogueTableViewCell
        let emptyArray: NSArray = NSArray()
        cell .refreshUIWithData(catalogueDatas! as NSArray, emptyArray, indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dictionary: NSDictionary = catalogueDatas![indexPath.row] as NSDictionary
        let array: NSArray = dictionary.allValues as NSArray
        let namespace: String = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        let string: String = array.firstObject as! String
        let className: AnyClass = NSClassFromString(namespace + "." + string)!
        let page = className as! UIViewController.Type
        navigationItem.backBarButtonItem = UIBarButtonItem()
        navigationItem.backBarButtonItem?.title = ""
        navigationController?.pushViewController(page.init(), animated: true)
    }
    
    //MARK:Lazy loading
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y:0, width: KScreenWidth, height: KScreenHeight - kViewTopHeight - KiPhoneXSafeAreaDValue), style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BMKCatalogueTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return tableView
    }()
}

