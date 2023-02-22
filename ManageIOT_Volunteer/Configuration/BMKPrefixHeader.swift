//
//  BMKPrefixHeader.swift
//  BMKSwiftDemo
//
//  Created by baidu RD on 2018/7/23.
//  Copyright © 2018年 Baidu. All rights reserved.
//

import UIKit
import Foundation

let widthScale: CGFloat = UIScreen.main.bounds.size.width/375
let heightScale: CGFloat = UIScreen.main.bounds.size.height/667
let BMKMapVersion = "百度地图iOS SDK " + BMKGetMapApiVersion()

let KScreenWidth: CGFloat = UIScreen.main.bounds.size.width
let KScreenHeight: CGFloat = UIScreen.main.bounds.size.height

let KStatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
let KNavigationBarHeight: CGFloat = 44
let kViewTopHeight = KStatusBarHeight + CGFloat(KNavigationBarHeight)

let KiPhoneXSafeAreaDValue: CGFloat = UIApplication.shared.statusBarFrame.size.height > 20 ? 34.0 : 0.0

func COLOR(_ rgbValue: UInt) -> UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
    let blue = CGFloat(rgbValue & 0xFF) / 255.0
    return UIColor.init(red: red, green: green, blue: blue, alpha: 1.0)
}



