import Foundation

class ModelNews {
    var iId     : Int = 0
    var sTitle  : String = ""
    var sBranch   : String = ""
    var sPicture: String = ""
    var sContent: String = ""
    var sTime   : String = ""
    var iRead   : Int = 0   // 0: Not read yet, 1: Did read


    init() {
        iId      = 0
        sTitle   = ""
        sBranch  = ""
        sPicture = ""
        sContent = ""
        sTime    = ""
        iRead    = 0
    }


    init(id: Int, title: String, branch: String, picture: String, content: String, time: String, read: Int) {
        iId      = id
        sTitle   = title
        sBranch  = branch
        sPicture = picture
        sContent = content
        sTime    = time
        iRead    = read
    }


    func copyFromApiData(data: StRspNewsInfo) {
        iId      = data.id         ?? 0
        sTitle   = data.title      ?? ""
        sBranch  = data.newsBranch ?? ""
        sPicture = data.picture    ?? ""
        sContent = data.content    ?? ""
        sTime    = data.releaseTimeStr ?? ""
        iRead    = data.readCnt    ?? 0
    }

}
