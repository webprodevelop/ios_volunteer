import Foundation

func isWithinOneMonth(date: Date) -> Bool {
    let dateNow = Date()
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.year  = 0
    dateComponents.month = 1
    dateComponents.day   = 0
    let dateLimit = calendar.date(byAdding: dateComponents, to: dateNow) ?? Date()

    if date > dateLimit {
        return false
    }
    return true
}


func isWithinOneMonth(sDate: String) -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let date = formatter.date(from: sDate) ?? Date()

    return isWithinOneMonth(date: date)
}


func isBeforeDay(sDate: String) -> Bool {
    let dateNow = Date()
    let formatter = DateFormatter()

    if sDate.isEmpty {
        return true
    }
    formatter.dateFormat = "yyyy-MM-dd"
    let date = formatter.date(from: sDate) ?? Date()
    if date > dateNow {
        return false
    }
    return true
}


func daysFromNow(sDate: String) -> Int {
    let dateToday = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let date = formatter.date(from: sDate) ?? Date()

    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: dateToday, to: date)
    return components.day ?? 0
}


func searchNearBy(searchPoi: BMKPoiSearch, lat: String, lon: String) {
    let option = BMKPOINearbySearchOption()
    option.pageIndex = 1
    option.pageSize  = 5
    option.location  = CLLocationCoordinate2D(latitude: Double(lat) ?? 0, longitude: Double(lon) ?? 0)
    option.keywords  = ["中国", "北京", "丹东"]
    searchPoi.poiSearchNear(by: option)
}


func searchCity(searchPoi: BMKPoiSearch, keyword: String) {
    let option = BMKPOICitySearchOption()
    option.pageIndex = 1
    option.pageSize  = 10
    option.keyword   = keyword
    option.city      = "Dandong"
    option.isCityLimit = false
    searchPoi.poiSearch(inCity: option)
}


func searchDetail(searchPoi: BMKPoiSearch, mapPoi: BMKMapPoi) {
    let option = BMKPOIDetailSearchOption()
    option.poiUIDs = [mapPoi.uid]
    searchPoi.poiDetailSearch(option)
}


func generateUrlVCard(coordinate: CLLocationCoordinate2D, name: String) -> URL {
    let urlVCardFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("drive.vcf")

    let sVCard = [
        "BEGIN:VCARD",
        "VERSION:4.0",
        "FN:\(name)",
        //"item1.URL;type=pref:http://api.map.baidu.com/direction?origin=latlng:34.264642646862,108.95108518068|name:我家&destination=大雁塔&mode=driving&region=中国&output=html&src=webapp.baidu.openAPIdemo",
        "item1.URL;type=pref:http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)",
        "item1.X-ABLabel:map url",
        "END:VCARD"
    ].joined(separator: "\n")

    do {
        try sVCard.write(toFile: urlVCardFile.path, atomically: true, encoding: .utf8)
    }
    catch let error {
        print("Error, \(error.localizedDescription), saving vCard: \(sVCard) to file path: \(urlVCardFile.path).")
    }

    return urlVCardFile
}
