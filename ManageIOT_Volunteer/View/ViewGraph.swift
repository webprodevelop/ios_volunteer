import Foundation

class ViewGraph: UIView {

    var dicValues: [Int:Float] = [Int:Float]()
//    var marksH: [String] = [String]()
    var marksH: [String] = [
        "", "", "", "",
        "", "", "", "",
        "", "", "", "",
        ""
    ]
//    var marksH: [String] = [
//        "", "02:00", "", "06:00",
//        "", "10:00", "", "14:00",
//        "", "18:00", "", "22:00",
//        ""
//    ]
    var marksV: [String] = [
        "", "", "", "", "40", "", "60", "", "80", "", "100", "", "120"
    ]
    var divideH: Int = 12   // Horizontal Dots Count
    var divideV: Int = 14   // Vertical Dots Count
    var limitLower: CGFloat = 60    // Heart Rate Lower Limit
    var limitUpper: CGFloat = 100   // Heart Rate Upper Limit
    var gapKey  : CGFloat = 7200 // Gap of keys per Dot : 2 Hours
    var gapValue: CGFloat = 10   // Gap of values per Dot
    var originValue: CGFloat = 0
    var radiusDot: CGFloat = 2

    var colorLine : UIColor = UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)  // Light Blue
    var colorLimit: UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)  // Light Gray
    var colorGraph: UIColor = UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)  // Light Blue
    var colorValue: UIColor = UIColor(red: 0.0, green: 0.7, blue: 0.4, alpha: 1.0)  // Green
    var colorAlarmBack: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)  // Red
    var colorAlarmText: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)  // White


    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(bounds)
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(bounds)
        
        let axisL: CGFloat = rect.origin.x + 30
        let axisT: CGFloat = rect.origin.y + 10
        let axisR: CGFloat = rect.origin.x + rect.size.width - 20
        let axisB: CGFloat = rect.origin.y + rect.size.height - 30
        let axisW: CGFloat = axisR - axisL   // Width
        let axisH: CGFloat = axisB - axisT   // Height
        let unitH: CGFloat = axisW / CGFloat(divideH) // Horizontal
        let unitV: CGFloat = axisH / CGFloat(divideV) // Vertical

        var path: UIBezierPath

        var x: CGFloat = 0
        var y: CGFloat = 0
        var count: Int = 0
        let keys   = dicValues.sorted{ $0.0 < $1.0 }.map{ $0.0 }
        let values = dicValues.sorted{ $0.0 < $1.0 }.map{ $0.1 }

        //-- Draw Axis
        path = UIBezierPath()
        path.lineWidth = 0.5
        colorLine.set()
        path.move(to: CGPoint(x: axisL, y: axisT))
        path.addLine(to: CGPoint(x: axisL, y: axisB))
        path.addLine(to: CGPoint(x: axisR, y: axisB))
        path.stroke()

        //-- Horizontal Dots
        path = UIBezierPath()
        path.lineWidth = 0.5
        colorLine.set()

        for i in 1...divideH {
            x = axisL + CGFloat(i) * unitH
            drawDot(point: CGPoint(x: x, y: axisB - radiusDot))
        }

        //-- Vertical Dots
        path = UIBezierPath()
        path.lineWidth = 0.5
        colorLine.set()

        for i in 1...divideV {
            y = axisB - CGFloat(i) * unitV
            drawDot(point: CGPoint(x: axisL - radiusDot, y: y - radiusDot))
        }

        //-- Horizontal Marks
        count = marksH.count < (divideH + 1) ? marksH.count : divideH + 1
        if count > 0 {
            for i in 0...count - 1 {
                if i >= marksH.count { return }
                if marksH[i] == "" { continue }
                x = axisL + unitH * CGFloat(i) - 10
                y = axisB + 10
                marksH[i].htmlAttributed?.draw(at: CGPoint(x: x, y: y))
            }
        }

        //-- Veritical Marks
        count = marksV.count < (divideV + 1) ? marksV.count : divideV + 1
        if count > 0 {
            for i in 0...count - 1 {
                if i >= marksV.count { return }
                if marksV[i] == "" { continue }
                x = axisL - 25
                y = axisB - unitV * CGFloat(i) - 10
                marksV[i].htmlAttributed?.draw(at: CGPoint(x: x, y: y))
            }
        }

        //-- Lower Limit Line
        path = UIBezierPath()
        path.lineWidth = 0.5
        colorLimit.set()
        x = axisL
        y = axisB - (limitLower - originValue) * unitV / gapValue
        while x <= axisR {
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + 3, y: y))
            path.stroke()
            x = x + 6
        }

        //-- Upper Limit Line
        path = UIBezierPath()
        path.lineWidth = 0.5
        colorLimit.set()
        x = axisL
        y = axisB - (limitUpper - originValue) * unitV / gapValue
        while x <= axisR {
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + 3, y: y))
            path.stroke()
            x = x + 6
        }

        //-- Graph
        count = keys.count

        path = UIBezierPath()
        path.lineWidth = 0.5
        colorGraph.set()

        if count > 1 {
            x = axisL + CGFloat(keys[0]) * unitH / gapKey
            y = axisB - (CGFloat(values[0]) - originValue) * unitV / gapValue
            path.move(to: CGPoint(x: x, y: y))
            for i in 1...count - 1 {
                if CGFloat(values[i]) < originValue { continue }
                x = axisL + CGFloat(keys[i]) * unitH / gapKey
                y = axisB - (CGFloat(values[i]) - originValue) * unitV / gapValue
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.stroke()
        }

        //-- Graph Dots
        if count > 0 {
            for i in 0...count - 1 {
                if i >= values.count { return }
                if CGFloat(values[i]) < originValue { continue }
                x = axisL + CGFloat(keys[i]) * unitH / gapKey
                y = axisB - (CGFloat(values[i]) - originValue) * unitV / gapValue
                drawDot(point: CGPoint(x: x - radiusDot, y: y - radiusDot))
            }
        }

        //-- Values Text
        if count > 1 {
            for i in 1...count - 1 {
                if i >= values.count { return }
                if CGFloat(values[i]) < originValue { continue }
                x = axisL + CGFloat(keys[i])   * unitH / gapKey
                y = axisB - (CGFloat(values[i]) - originValue) * unitV / gapValue

                x = x - 10
                if CGFloat(values[i]) < limitLower { y = y + 5 }
                else { y = y - 20 }

                let rect = CGRect(x: x - 1, y: y - 1, width: 35, height: 15)
                if CGFloat(values[i]) < limitLower || CGFloat(values[i]) > limitUpper {
                    drawRect(rect: rect, color: colorAlarmBack)
                    drawText(string: String(values[i]), color: colorAlarmText, rect: rect)
                }
                else {
                    drawText(string: String(values[i]), color: colorValue, rect: rect)
                }
            }
        }

    }


    func drawDot(point: CGPoint) {
        let pathDot = UIBezierPath(ovalIn: CGRect(
            origin: point,
            size  : CGSize(width: radiusDot * 2, height: radiusDot * 2)
        ))
        pathDot.fill()
    }


    func drawRect(rect: CGRect, color: UIColor) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 2.0)
        color.setFill()
        path.fill()
    }


    func drawText(string: String, color: UIColor, rect: CGRect) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributes = [
            NSAttributedString.Key.paragraphStyle : paragraph,
            NSAttributedString.Key.font           : UIFont.systemFont(ofSize: 12.0),
            NSAttributedString.Key.foregroundColor: color
        ]

        let attributed = NSAttributedString(string: string, attributes: attributes)
        attributed.draw(in: rect)
    }
}
