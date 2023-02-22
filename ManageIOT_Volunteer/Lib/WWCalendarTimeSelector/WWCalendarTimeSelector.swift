import UIKit


private extension CGFloat {
    var doubleValue:      Double  { return Double(self) }
    var degreesToRadians: CGFloat { return CGFloat(doubleValue * .pi / 180) }
    var radiansToDegrees: CGFloat { return CGFloat(doubleValue * 180 / .pi) }
}


private extension Int {
    var doubleValue:      Double  { return Double(self) }
    var degreesToRadians: CGFloat { return CGFloat(doubleValue * .pi / 180) }
    var radiansToDegrees: CGFloat { return CGFloat(doubleValue * 180 / .pi) }
}


@objc public enum WWCalendarTimeSelectorSelection: Int {
    case single   // Single Selection.
    case multiple // Multiple Selection. Year and Time interface not available.
    case range    // Range Selection. Year and Time interface not available.
}


@objc public enum WWCalendarTimeSelectorMultipleSelectionGrouping: Int {
    case simple      // Displayed as individual circular selection
    case pill        // Rounded rectangular grouping
    case linkedBalls // Individual circular selection with a bar between adjacent dates
}


@objc public enum WWCalendarTimeSelectorMultipleDateOutputFormat: Int {
    case english  // English format
    case japanese // Japanese format
}


@objc public enum WWCalendarTimeSelectorTimeStep: Int {
    case oneMinute      = 1  // 1  Minute  interval, but clock will display intervals of 5 minutes.
    case fiveMinutes    = 5  // 5  Minutes interval.
    case tenMinutes     = 10 // 10 Minutes interval.
    case fifteenMinutes = 15 // 15 Minutes interval.
    case thirtyMinutes  = 30 // 30 Minutes interval.
    case sixtyMinutes   = 60 // Disables the selection of minutes.
}


@objc internal enum WWCalendarRowType: Int {
    case month, day, date
}


internal protocol WWClockProtocol: NSObjectProtocol {
    func WWClockGetTime() -> Date
    func WWClockSwitchAMPM(isAM: Bool, isPM: Bool)
    func WWClockSetHourMilitary(_ hour: Int)
    func WWClockSetMinute(_ minute: Int)
}


internal protocol WWCalendarRowProtocol: NSObjectProtocol {
    func WWCalendarRowDateIsEnable(_ date: Date) -> Bool
    func WWCalendarRowGetDetails(_ row: Int) -> (type: WWCalendarRowType, dateStart: Date)
    func WWCalendarRowDidSelect(_ date: Date)
}


@objc public protocol WWCalendarTimeSelectorProtocol {

    // Method called before the selector is dismissed, and when user is Done with the selector.
    // This method is only called when optionMultipleSelection is true.
    // - See Also:
    //  WWCalendarTimeSelectorDone:selector:date:
    // - Parameters:
    //  selector: The selector that will be dismissed.
    //  dates   : Selected dates.
    @objc optional func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, dates: [Date])

    // Method called before the selector is dismissed, and when user is Done with the selector.
    // This method is only called when optionMultipleSelection is false.
    // - See Also:
    //  WWCalendarTimeSelectorDone:selector:dates:
    // - Parameters:
    //  selector: The selector that will be dismissed.
    //  date    : Selected date.
    @objc optional func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date)

    // Method called before the selector is dismissed, and when user Cancel the selector.
    // This method is only called when optionMultipleSelection is true.
    // - SeeAlso:
    //  WWCalendarTimeSelectorCancel:selector:date:
    // - Parameters:
    //  selector: The selector that will be dismissed.
    //  dates   : Selected dates.
    @objc optional func WWCalendarTimeSelectorCancel(_ selector: WWCalendarTimeSelector, dates: [Date])

    // Method called before the selector is dismissed, and when user Cancel the selector.
    // This method is only called when optionMultipleSelection is false.
    // - SeeAlso:
    //  WWCalendarTimeSelectorCancel:selector:dates:
    // - Parameters:
    //  selector: The selector that will be dismissed.
    //  date    : Selected date.
    @objc optional func WWCalendarTimeSelectorCancel(_ selector: WWCalendarTimeSelector, date: Date)

    // Method called before the selector is dismissed.
    // - SeeAlso:
    //  WWCalendarTimeSelectorDidDismiss:selector:
    // - Parameters:
    //  selector: The selector that will be dismissed.
    @objc optional func WWCalendarTimeSelectorWillDismiss(_ selector: WWCalendarTimeSelector)

    // Method called after the selector is dismissed.
    // - SeeAlso:
    //  WWCalendarTimeSelectorWillDismiss:selector:
    // - Parameters:
    //  selector: The selector that has been dismissed.
    @objc optional func WWCalendarTimeSelectorDidDismiss(_ selector: WWCalendarTimeSelector)

    // Method if implemented, will be used to determine if a particular date should be selected.
    // - Parameters:
    //  selector: The selector that is checking for selectablity of date.
    //  date    : The date that user tapped, but have not yet given feedback to determine if should be selected.
    @objc optional func WWCalendarTimeSelectorShouldSelectDate(_ selector: WWCalendarTimeSelector, date: Date) -> Bool
}


@objc public final class WWCalendarTimeSelectorStyle: NSObject {
    fileprivate(set) public var bShowDateMonth: Bool = true
    fileprivate(set) public var bShowMonth: Bool = false
    fileprivate(set) public var bShowYear : Bool = true
    fileprivate(set) public var bShowTime : Bool = true
    fileprivate var bSingular = false


    public func showDateMonth(_ show: Bool) {
        bShowDateMonth = show
        bShowMonth = show ? false : bShowMonth
        if show && bSingular {
            bShowMonth = false
            bShowYear = false
            bShowTime = false
        }
    }


    public func showMonth(_ show: Bool) {
        bShowMonth = show
        bShowDateMonth = show ? false : bShowDateMonth
        if show && bSingular {
            bShowDateMonth = false
            bShowYear = false
            bShowTime = false
        }
    }


    public func showYear(_ show: Bool) {
        bShowYear = show
        if show && bSingular {
            bShowDateMonth = false
            bShowMonth = false
            bShowTime = false
        }
    }


    public func showTime(_ show: Bool) {
        bShowTime = show
        if show && bSingular {
            bShowDateMonth = false
            bShowMonth = false
            bShowYear = false
        }
    }


    fileprivate func countComponents() -> Int {
        return (bShowDateMonth ? 1 : 0) +
            (bShowMonth ? 1 : 0) +
            (bShowYear ? 1 : 0) +
            (bShowTime ? 1 : 0)
    }


    fileprivate convenience init(isSingular: Bool) {
        self.init()
        self.bSingular = isSingular
        bShowDateMonth = true
        bShowMonth = false
        bShowYear = false
        bShowTime = false
    }
}


@objc open class WWCalendarTimeSelectorDateRange: NSObject {

    fileprivate(set) open var start: Date = Date().beginningOfDay
    fileprivate(set) open var end  : Date = Date().beginningOfDay

    open var array: [Date] {
        var dates: [Date] = []
        var i = start.beginningOfDay
        let j = end.beginningOfDay
        while i.compare(j) != .orderedDescending {
            dates.append(i)
            i = i + 1.day
        }
        return dates
    }


    open func setStartDate(_ date: Date) {
        start = date.beginningOfDay
        if start.compare(end) == .orderedDescending {
            end = start
        }
    }


    open func setEndDate(_ date: Date) {
        end = date.beginningOfDay
        if start.compare(end) == .orderedDescending {
            start = end
        }
    }
}


@objc open class WWCalendarTimeSelectorDateRangeEnabled: NSObject {
    
    public static let past: WWCalendarTimeSelectorDateRangeEnabled = {
        let dateRange = WWCalendarTimeSelectorDateRangeEnabled()
        dateRange.end = Date().endOfDay
        return dateRange
    } ()
    
    public static let future: WWCalendarTimeSelectorDateRangeEnabled = {
        let dateRange = WWCalendarTimeSelectorDateRangeEnabled()
        dateRange.start = Date().beginningOfDay
        return dateRange
    } ()
    
    fileprivate(set) open var start: Date? = nil
    fileprivate(set) open var end  : Date? = nil


    open func setStartDate(_ date: Date?) {
        start = date
        if let endTmp = end, start?.compare(endTmp) == .orderedDescending {
            end = start
        }
    }


    open func setEndDate(_ date: Date?) {
        end = date
        if let endTmp = end, start?.compare(endTmp) == .orderedDescending {
            start = end
        }
    }
}


internal class WWClock: UIView {

    internal weak var delegate: WWClockProtocol!

    internal var colorBgClockFace: UIColor!
    internal var colorBgClockFaceCenter: UIColor!

    internal var colorFontAmPm         : UIColor!
    internal var colorFontAmPmHighlight: UIColor!
    internal var colorFontHour         : UIColor!
    internal var colorFontHourHighlight: UIColor!
    internal var colorFontMinute         : UIColor!
    internal var colorFontMinuteHighlight: UIColor!

    internal var colorBgAmPmHighlight: UIColor!
    internal var colorBgHourHighlight      : UIColor!
    internal var colorBgHourHighlightNeedle: UIColor!
    internal var colorBgMinuteHighlight      : UIColor!
    internal var colorBgMinuteHighlightNeedle: UIColor!

    internal var fontAMPM: UIFont!
    internal var fontAMPMHighlight: UIFont!
    internal var fontHour: UIFont!
    internal var fontHourHighlight: UIFont!
    internal var fontMinute: UIFont!
    internal var fontMinuteHighlight: UIFont!

    internal var bShowingHour = true
    internal var stepMinute: WWCalendarTimeSelectorTimeStep! {
        didSet {
            minutes = []
            let iter = 60 / stepMinute.rawValue
            for i in 0..<iter {
                minutes.append(i * stepMinute.rawValue)
            }
        }
    }

    fileprivate let border: CGFloat = 8
    fileprivate let ampmSize: CGFloat = 52
    fileprivate var faceSize: CGFloat = 0
    fileprivate var faceX: CGFloat = 0
    fileprivate let faceY: CGFloat = 8
    fileprivate let amX: CGFloat = 8
    fileprivate var pmX: CGFloat = 0
    fileprivate var ampmY: CGFloat = 0
    fileprivate let numberCircleBorder: CGFloat = 12
    fileprivate let centerPieceSize = 4
    fileprivate let hours = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    fileprivate var minutes: [Int] = []


    internal override func draw(_ rect: CGRect) {
        // update frames
        faceSize = min(rect.width - border * 2, rect.height - border * 2 - ampmSize / 3 * 2)
        faceX = (rect.width - faceSize) / 2
        pmX = rect.width - border - ampmSize
        ampmY = rect.height - border - ampmSize

        let time = delegate.WWClockGetTime()
        let ctx = UIGraphicsGetCurrentContext()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center

        ctx?.setFillColor(colorBgClockFace.cgColor)
        ctx?.fillEllipse(in: CGRect(x: faceX, y: faceY, width: faceSize, height: faceSize))

        ctx?.setFillColor(colorBgAmPmHighlight.cgColor)
        if time.hour < 12 {
            ctx?.fillEllipse(in: CGRect(x: amX, y: ampmY, width: ampmSize, height: ampmSize))
            var str = NSAttributedString(
                string: "AM",
                attributes: [
                    NSAttributedString.Key.font: fontAMPMHighlight!,
                    NSAttributedString.Key.foregroundColor: colorFontAmPmHighlight!,
                    NSAttributedString.Key.paragraphStyle: paragraph
                ]
            )
            var ampmHeight = fontAMPMHighlight.lineHeight
            str.draw(in: CGRect(x: amX, y: ampmY + (ampmSize - ampmHeight) / 2, width: ampmSize, height: ampmHeight))
            str = NSAttributedString(
                string: "PM",
                attributes: [
                    NSAttributedString.Key.font: fontAMPM!,
                    NSAttributedString.Key.foregroundColor: colorFontAmPm!,
                    NSAttributedString.Key.paragraphStyle: paragraph
                ]
            )
            ampmHeight = fontAMPM.lineHeight
            str.draw(in: CGRect(x: pmX, y: ampmY + (ampmSize - ampmHeight) / 2, width: ampmSize, height: ampmHeight))
        }
        else {
            ctx?.fillEllipse(in: CGRect(x: pmX, y: ampmY, width: ampmSize, height: ampmSize))
            var str = NSAttributedString(
                string: "AM",
                attributes: [
                    NSAttributedString.Key.font: fontAMPM!,
                    NSAttributedString.Key.foregroundColor: colorFontAmPm!,
                    NSAttributedString.Key.paragraphStyle: paragraph
                ]
            )
            var ampmHeight = fontAMPM.lineHeight
            str.draw(in: CGRect(x: amX, y: ampmY + (ampmSize - ampmHeight) / 2, width: ampmSize, height: ampmHeight))
            str = NSAttributedString(
                string: "PM",
                attributes: [
                    NSAttributedString.Key.font: fontAMPMHighlight!,
                    NSAttributedString.Key.foregroundColor: colorFontAmPmHighlight!,
                    NSAttributedString.Key.paragraphStyle: paragraph
                ]
            )
            ampmHeight = fontAMPMHighlight.lineHeight
            str.draw(in: CGRect(x: pmX, y: ampmY + (ampmSize - ampmHeight) / 2, width: ampmSize, height: ampmHeight))
        }

        if bShowingHour {
            let textAttr: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: fontHour!,
                NSAttributedString.Key.foregroundColor: colorFontHour!,
                NSAttributedString.Key.paragraphStyle: paragraph
            ]
            let textAttrHighlight: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: fontHourHighlight!,
                NSAttributedString.Key.foregroundColor: colorFontHourHighlight!,
                NSAttributedString.Key.paragraphStyle: paragraph
            ]

            let templateSize = NSAttributedString(string: "12", attributes: textAttr).size()
            let templateSizeHighlight = NSAttributedString(string: "12", attributes: textAttrHighlight).size()
            let maxSize = max(templateSize.width, templateSize.height)
            let maxSizeHighlight = max(templateSizeHighlight.width, templateSizeHighlight.height)
            let highlightCircleSize = maxSizeHighlight + numberCircleBorder
            let radius = faceSize / 2 - maxSize
            let radiusHighlight = faceSize / 2 - maxSizeHighlight

            ctx?.saveGState()
            ctx?.translateBy(x: faceX + faceSize / 2, y: faceY + faceSize / 2) // everything starts at clock face center

            let degreeIncrement = 360 / CGFloat(hours.count)
            let currentHour = get12Hour(time)

            for (index, element) in hours.enumerated() {
                let angle = getClockRad(CGFloat(index) * degreeIncrement)

                if element == currentHour {
                    // needle
                    ctx?.saveGState()
                    ctx?.setStrokeColor(colorBgHourHighlightNeedle.cgColor)
                    ctx?.setLineWidth(1)
                    ctx?.move(to: CGPoint(x: 0, y: 0))
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.addLine(to: CGPoint(x: (radiusHighlight - highlightCircleSize / 2) * cos(angle), y: -((radiusHighlight - highlightCircleSize / 2) * sin(angle))))
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.strokePath()
                    ctx?.restoreGState()

                    // highlight
                    ctx?.saveGState()
                    ctx?.setFillColor(colorBgHourHighlight.cgColor)
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.translateBy(x: radiusHighlight * cos(angle), y: -(radiusHighlight * sin(angle)))
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.fillEllipse(in: CGRect(x: -highlightCircleSize / 2, y: -highlightCircleSize / 2, width: highlightCircleSize, height: highlightCircleSize))
                    ctx?.restoreGState()

                    // numbers
                    let hour = NSAttributedString(string: "\(element)", attributes: textAttrHighlight)
                    ctx?.saveGState()
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.translateBy(x: radiusHighlight * cos(angle), y: -(radiusHighlight * sin(angle)))
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.translateBy(x: -hour.size().width / 2, y: -hour.size().height / 2)
                    hour.draw(at: CGPoint.zero)
                    ctx?.restoreGState()
                }
                else {
                    // numbers
                    let hour = NSAttributedString(string: "\(element)", attributes: textAttr)
                    ctx?.saveGState()
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.translateBy(x: radius * cos(angle), y: -(radius * sin(angle)))
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.translateBy(x: -hour.size().width / 2, y: -hour.size().height / 2)
                    hour.draw(at: CGPoint.zero)
                    ctx?.restoreGState()
                }
            }
        }
        else {
            let textAttr: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: fontMinute!,
                NSAttributedString.Key.foregroundColor: colorFontMinute!,
                NSAttributedString.Key.paragraphStyle: paragraph
            ]
            let textAttrHighlight: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: fontMinuteHighlight!,
                NSAttributedString.Key.foregroundColor: colorFontMinuteHighlight!,
                NSAttributedString.Key.paragraphStyle: paragraph
            ]
            let templateSize = NSAttributedString(string: "60", attributes: textAttr).size()
            let templateSizeHighlight = NSAttributedString(string: "60", attributes: textAttrHighlight).size()
            let maxSize = max(templateSize.width, templateSize.height)
            let maxSizeHighlight = max(templateSizeHighlight.width, templateSizeHighlight.height)
            let minSize: CGFloat = 0
            let highlightCircleMaxSize = maxSizeHighlight + numberCircleBorder
            let highlightCircleMinSize = minSize + numberCircleBorder
            let radius = faceSize / 2 - maxSize
            let radiusHighlight = faceSize / 2 - maxSizeHighlight

            ctx?.saveGState()
            ctx?.translateBy(x: faceX + faceSize / 2, y: faceY + faceSize / 2) // everything starts at clock face center

            let degreeIncrement = 360 / CGFloat(minutes.count)
            let currentMinute = get60Minute(time)

            for (index, element) in minutes.enumerated() {
                let angle = getClockRad(CGFloat(index) * degreeIncrement)

                if element == currentMinute {
                    // needle
                    ctx?.saveGState()
                    ctx?.setStrokeColor(colorBgMinuteHighlightNeedle.cgColor)
                    ctx?.setLineWidth(1)
                    ctx?.move(to: CGPoint(x: 0, y: 0))
                    ctx?.scaleBy(x: -1, y: 1)
                    if stepMinute.rawValue < 5 && element % 5 != 0 {
                        ctx?.addLine(to: CGPoint(
                            x: (radiusHighlight - highlightCircleMinSize / 2) * cos(angle),
                            y: -((radiusHighlight - highlightCircleMinSize / 2) * sin(angle))
                        ))
                    }
                    else {
                        ctx?.addLine(to: CGPoint(
                            x: (radiusHighlight - highlightCircleMaxSize / 2) * cos(angle),
                            y: -((radiusHighlight - highlightCircleMaxSize / 2) * sin(angle))
                        ))
                    }
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.strokePath()
                    ctx?.restoreGState()

                    // highlight
                    ctx?.saveGState()
                    ctx?.setFillColor(colorBgMinuteHighlight.cgColor)
                    ctx?.scaleBy(x: -1, y: 1)
                    ctx?.translateBy(x: radiusHighlight * cos(angle), y: -(radiusHighlight * sin(angle)))
                    ctx?.scaleBy(x: -1, y: 1)
                    if stepMinute.rawValue < 5 && element % 5 != 0 {
                        ctx?.fillEllipse(in: CGRect(
                            x: -highlightCircleMinSize / 2,
                            y: -highlightCircleMinSize / 2,
                            width : highlightCircleMinSize,
                            height: highlightCircleMinSize
                        ))
                    }
                    else {
                        ctx?.fillEllipse(in: CGRect(
                            x: -highlightCircleMaxSize / 2,
                            y: -highlightCircleMaxSize / 2,
                            width : highlightCircleMaxSize,
                            height: highlightCircleMaxSize
                        ))
                    }
                    ctx?.restoreGState()

                    // numbers
                    if stepMinute.rawValue < 5 {
                        if element % 5 == 0 {
                            let min = NSAttributedString(string: "\(element)", attributes: textAttrHighlight)
                            ctx?.saveGState()
                            ctx?.scaleBy(x: -1, y: 1)
                            ctx?.translateBy(x: radiusHighlight * cos(angle), y: -(radiusHighlight * sin(angle)))
                            ctx?.scaleBy(x: -1, y: 1)
                            ctx?.translateBy(x: -min.size().width / 2, y: -min.size().height / 2)
                            min.draw(at: CGPoint.zero)
                            ctx?.restoreGState()
                        }
                    }
                    else {
                        let min = NSAttributedString(string: "\(element)", attributes: textAttrHighlight)
                        ctx?.saveGState()
                        ctx?.scaleBy(x: -1, y: 1)
                        ctx?.translateBy(x: radiusHighlight * cos(angle), y: -(radiusHighlight * sin(angle)))
                        ctx?.scaleBy(x: -1, y: 1)
                        ctx?.translateBy(x: -min.size().width / 2, y: -min.size().height / 2)
                        min.draw(at: CGPoint.zero)
                        ctx?.restoreGState()
                    }
                }
                else {
                    // numbers
                    if stepMinute.rawValue < 5 {
                        if element % 5 == 0 {
                            let min = NSAttributedString(string: "\(element)", attributes: textAttr)
                            ctx?.saveGState()
                            ctx?.scaleBy(x: -1, y: 1)
                            ctx?.translateBy(x: radius * cos(angle), y: -(radius * sin(angle)))
                            ctx?.scaleBy(x: -1, y: 1)
                            ctx?.translateBy(x: -min.size().width / 2, y: -min.size().height / 2)
                            min.draw(at: CGPoint.zero)
                            ctx?.restoreGState()
                        }
                    }
                    else {
                        let min = NSAttributedString(string: "\(element)", attributes: textAttr)
                        ctx?.saveGState()
                        ctx?.scaleBy(x: -1, y: 1)
                        ctx?.translateBy(x: radius * cos(angle), y: -(radius * sin(angle)))
                        ctx?.scaleBy(x: -1, y: 1)
                        ctx?.translateBy(x: -min.size().width / 2, y: -min.size().height / 2)
                        min.draw(at: CGPoint.zero)
                        ctx?.restoreGState()
                    }
                }
            }
        }

        // center piece
        ctx?.setFillColor(colorBgClockFaceCenter.cgColor)
        ctx?.fillEllipse(in: CGRect(x: -centerPieceSize / 2, y: -centerPieceSize / 2, width: centerPieceSize, height: centerPieceSize))
        ctx?.restoreGState()
    }


    fileprivate func get60Minute(_ date: Date) -> Int {
        return date.minute
    }


    fileprivate func get12Hour(_ date: Date) -> Int {
        let hr = date.hour
        return hr == 0 || hr == 12 ? 12 : hr < 12 ? hr : hr - 12
    }


    fileprivate func getClockRad(_ degrees: CGFloat) -> CGFloat {
        let radOffset = 90.degreesToRadians // add this number to get 12 at top, 3 at right
        return degrees.degreesToRadians + radOffset
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.sorted(by: { $0.timestamp < $1.timestamp }).last {
            let pt = touch.location(in: self)

            // see if tap on AM or PM, making the boundary bigger
            let amRect = CGRect(x: 0, y: ampmY, width: ampmSize + border * 2, height: ampmSize + border)
            let pmRect = CGRect(x: bounds.width - ampmSize - border, y: ampmY, width: ampmSize + border * 2, height: ampmSize + border)

            if amRect.contains(pt) {
                delegate.WWClockSwitchAMPM(isAM: true, isPM: false)
            }
            else if pmRect.contains(pt) {
                delegate.WWClockSwitchAMPM(isAM: false, isPM: true)
            }
            else {
                touchClock(pt: pt)
            }
        }
    }


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.sorted(by: { $0.timestamp < $1.timestamp }).last {
            let pt = touch.location(in: self)
            touchClock(pt: pt)
        }
    }


    fileprivate func touchClock(pt: CGPoint) {
        let touchPoint = CGPoint(x: pt.x - faceX - faceSize / 2, y: pt.y - faceY - faceSize / 2) // this means centerpoint will be 0, 0

        if bShowingHour {
            let degreeIncrement = 360 / CGFloat(hours.count)

            var angle = 180 - atan2(touchPoint.x, touchPoint.y).radiansToDegrees // with respect that 12 o'clock position is 0 degrees, and 3 o'clock position is 90 degrees
            if angle < 0 {
                angle = 0
            }
            angle = angle - degreeIncrement / 2
            var index = Int(floor(angle / degreeIncrement)) + 1

            if index < 0 || index > (hours.count - 1) {
                index = 0
            }

            let hour = hours[index]
            let time = delegate.WWClockGetTime()
            if hour == 12 {
                delegate.WWClockSetHourMilitary(time.hour < 12 ? 0 : 12)
            }
            else {
                delegate.WWClockSetHourMilitary(time.hour < 12 ? hour : 12 + hour)
            }
        }
        else {
            let degreeIncrement = 360 / CGFloat(minutes.count)

            var angle = 180 - atan2(touchPoint.x, touchPoint.y).radiansToDegrees // with respect that 12 o'clock position is 0 degrees, and 3 o'clock position is 90 degrees
            if angle < 0 {
                angle = 0
            }
            angle = angle - degreeIncrement / 2
            var index = Int(floor(angle / degreeIncrement)) + 1

            if index < 0 || index > (minutes.count - 1) {
                index = 0
            }

            let minute = minutes[index]
            delegate.WWClockSetMinute(minute)
        }
    }
}


internal class WWCalendarRow: UIView {

    internal weak var delegate: WWCalendarRowProtocol!
    internal var fontMonth: UIFont!
    internal var fontDay  : UIFont!
    internal var fontDatePast         : UIFont!
    internal var fontDatePastHighlight: UIFont!
    internal var fontDateToday         : UIFont!
    internal var fontDateTodayHighlight: UIFont!
    internal var fontDateFuture         : UIFont!
    internal var fontDateFutureHighlight: UIFont!
    internal var fontDateDisable: UIFont!

    internal var colorFontMonth: UIColor!
    internal var colorFontDay  : UIColor!
    internal var colorFontDatePast: UIColor!
    internal var colorFontDatePastHighlight: UIColor!
    internal var colorFontDateToday: UIColor!
    internal var colorFontDateTodayHighlight: UIColor!
    internal var colorFontDateFuture: UIColor!
    internal var colorFontDateFutureHighlight: UIColor!
    internal var colorFontDateDisable: UIColor!

    internal var colorBgDatePastHighlight: UIColor!
    internal var colorBgDatePastFlash    : UIColor!
    internal var colorBgDateTodayHighlight: UIColor!
    internal var colorBgDateTodayFlash    : UIColor!
    internal var colorBgDateFutureHighlight: UIColor!
    internal var colorBgDateFutureFlash    : UIColor!
    internal var colorBgDateUnderlined: UIColor!

    internal var dDurationFlash: TimeInterval!
    internal var multipleSelectionGrouping: WWCalendarTimeSelectorMultipleSelectionGrouping = .pill
    internal var bEnableMultipleSelection : Bool = false

    internal var datesOriginal  : Set<Date> = []
    internal var datesComparison: Set<Date> = []
    internal var datesSelected: Set<Date> {
        set {
            datesOriginal = newValue
            datesComparison = []
            for date in newValue {
                datesComparison.insert(date.beginningOfDay)
            }
        }
        get {
            return datesOriginal
        }
    }

    internal var datesUnderlined: Set<Date> {
        set {
            datesUnderlinedOriginal = newValue
            datesUnderlinedComparison = []
            for date in newValue {
                datesUnderlinedComparison.insert(date.beginningOfDay)
            }
        }
        get {
            return datesUnderlinedOriginal
        }
    }
    fileprivate var datesUnderlinedOriginal: Set<Date> = []
    fileprivate var datesUnderlinedComparison: Set<Date> = []

    //fileprivate let days = ["S", "M", "T", "W", "T", "F", "S"]
    fileprivate let fMultipleSelectionBorder: CGFloat = 12
    fileprivate let fMultipleSelectionBar: CGFloat = 8


    internal override func draw(_ rect: CGRect) {
        let detail = delegate.WWCalendarRowGetDetails(tag)
        let startDate = detail.dateStart.beginningOfDay

        let ctx = UIGraphicsGetCurrentContext()
        let boxHeight = rect.height
        let boxWidth = rect.width / 7
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center

        if detail.type == .month {
            let monthName = startDate.stringFromFormat("MMMM yyyy").capitalized
            let monthHeight = ceil(fontMonth.lineHeight)

            let str = NSAttributedString(
                string: monthName,
                attributes: [
                    NSAttributedString.Key.font: fontMonth!,
                    NSAttributedString.Key.foregroundColor: colorFontMonth!,
                    NSAttributedString.Key.paragraphStyle: paragraph
                ]
            )
            str.draw(in: CGRect(x: 0, y: boxHeight - monthHeight, width: rect.width, height: monthHeight))
        }
        else if detail.type == .day {
            let dayHeight = ceil(fontDay.lineHeight)
            let y = (boxHeight - dayHeight) / 2
            let formatter = DateFormatter()
            formatter.locale = Locale.autoupdatingCurrent
            formatter.calendar = Calendar.autoupdatingCurrent
            let days = formatter.veryShortWeekdaySymbols ?? ["S", "M", "T", "W", "T", "F", "S"]
            for (index, element) in days.enumerated() {
                let str = NSAttributedString(
                    string: element,
                    attributes: [
                        NSAttributedString.Key.font: fontDay!,
                        NSAttributedString.Key.foregroundColor: colorFontDay!,
                        NSAttributedString.Key.paragraphStyle: paragraph
                    ]
                )
                let i = (index + 6) % 7 // When first weekday is Monday=2 (not Sunday=1)
                str.draw(in: CGRect(x: CGFloat(i) * boxWidth, y: y, width: boxWidth, height: dayHeight))
            }
        }
        else {
            let today = Date().beginningOfDay
            var date = startDate
            var str: NSMutableAttributedString

            for i in 1...7 {
                let j = i % 7 + 1   // When first weekday is Money=2 (not Sunday=1)
                if date.weekday == j {
                    var font = datesComparison.contains(date) ? fontDateFutureHighlight : fontDateFuture
                    var fontColor = colorFontDateFuture
                    var fontHighlightColor = colorFontDateFutureHighlight
                    var backgroundHighlightColor = colorBgDateFutureHighlight.cgColor
                    let underlinedBackgroundColor = colorBgDateUnderlined.cgColor
                    if !delegate.WWCalendarRowDateIsEnable(date) {
                        font = fontDateDisable
                        fontColor = colorFontDateDisable
                    }
                    else if date == today {
                        font = datesComparison.contains(date) ? fontDateTodayHighlight : fontDateToday
                        fontColor = colorFontDateToday
                        fontHighlightColor = colorFontDateTodayHighlight
                        backgroundHighlightColor = colorBgDateTodayHighlight.cgColor
                    }
                    else if date.compare(today) == ComparisonResult.orderedAscending {
                        font = datesComparison.contains(date) ? fontDatePastHighlight : fontDatePast
                        fontColor = colorFontDatePast
                        fontHighlightColor = colorFontDatePastHighlight
                        backgroundHighlightColor = colorBgDatePastHighlight.cgColor
                    }

                    let dateHeight = ceil(font!.lineHeight) as CGFloat
                    let y = (boxHeight - dateHeight) / 2

                    if datesComparison.contains(date) {
                        ctx?.setFillColor(backgroundHighlightColor)

                        if bEnableMultipleSelection {
                            var testStringSize = NSAttributedString(
                                string: "00",
                                attributes: [
                                    NSAttributedString.Key.font: fontDateTodayHighlight!,
                                    NSAttributedString.Key.paragraphStyle: paragraph
                                ]
                            ).size()
                            var dateMaxWidth = testStringSize.width
                            var dateMaxHeight = testStringSize.height
                            if fontDateFutureHighlight.lineHeight > fontDateTodayHighlight.lineHeight {
                                testStringSize = NSAttributedString(
                                    string: "00",
                                    attributes: [
                                        NSAttributedString.Key.font: fontDateFutureHighlight!,
                                        NSAttributedString.Key.paragraphStyle: paragraph
                                    ]
                                ).size()
                                dateMaxWidth = testStringSize.width
                                dateMaxHeight = testStringSize.height
                            }
                            if fontDatePastHighlight.lineHeight > fontDateFutureHighlight.lineHeight {
                                testStringSize = NSAttributedString(
                                    string: "00",
                                    attributes: [
                                        NSAttributedString.Key.font: fontDatePastHighlight!,
                                        NSAttributedString.Key.paragraphStyle: paragraph
                                    ]
                                ).size()
                                dateMaxWidth = testStringSize.width
                                dateMaxHeight = testStringSize.height
                            }

                            let size = min(max(dateHeight, dateMaxWidth) + fMultipleSelectionBorder, min(boxHeight, boxWidth))
                            let maxConnectorSize = min(max(dateMaxHeight, dateMaxWidth) + fMultipleSelectionBorder, min(boxHeight, boxWidth))
                            let x = CGFloat(i - 1) * boxWidth + (boxWidth - size) / 2
                            let y = (boxHeight - size) / 2

                            // connector
                            switch multipleSelectionGrouping {
                                case .simple:
                                    break
                                case .pill:
                                    if datesComparison.contains(date - 1.day) {
                                        ctx?.fill(CGRect(x: CGFloat(i - 1) * boxWidth, y: y, width: boxWidth / 2 + 1, height: maxConnectorSize))
                                    }
                                    if datesComparison.contains(date + 1.day) {
                                        ctx?.fill(CGRect(x: CGFloat(i - 1) * boxWidth + boxWidth / 2, y: y, width: boxWidth / 2 + 1, height: maxConnectorSize))
                                    }
                                    break
                                case .linkedBalls:
                                    if datesComparison.contains(date - 1.day) {
                                        ctx?.fill(CGRect(
                                            x: CGFloat(i - 1) * boxWidth,
                                            y: (boxHeight - fMultipleSelectionBar) / 2,
                                            width: boxWidth / 2 + 1,
                                            height: fMultipleSelectionBar
                                        ))
                                    }
                                    if datesComparison.contains(date + 1.day) {
                                        ctx?.fill(CGRect(
                                            x: CGFloat(i - 1) * boxWidth + boxWidth / 2,
                                            y: (boxHeight - fMultipleSelectionBar) / 2,
                                            width : boxWidth / 2 + 1,
                                            height: fMultipleSelectionBar
                                        ))
                                    }
                                    break
                            }

                            // Ball
                            //ctx?.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
                            ctx?.fill(CGRect(x: x, y: y, width: size, height: size))
                        }
                        else {
                            let size = min(boxHeight, boxWidth)
                            let x = CGFloat(i - 1) * boxWidth + (boxWidth - size) / 2
                            let y = (boxHeight - size) / 2
                            //ctx?.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
                            ctx?.fill(CGRect(x: x, y: y, width: size, height: size))
                        }

                        str = NSMutableAttributedString(
                            string: "\(date.day)",
                            attributes: [
                                NSAttributedString.Key.font: font!,
                                NSAttributedString.Key.foregroundColor: fontHighlightColor!,
                                NSAttributedString.Key.paragraphStyle: paragraph
                            ]
                        )
                    }
                    else {
                        str = NSMutableAttributedString(
                            string: "\(date.day)",
                            attributes: [
                                NSAttributedString.Key.font: font!,
                                NSAttributedString.Key.foregroundColor: fontColor!,
                                NSAttributedString.Key.paragraphStyle: paragraph
                            ]
                        )
                    }
                    // underlined rect
                    if datesUnderlinedComparison.contains(date) {
                        ctx?.setFillColor(underlinedBackgroundColor)
                        let size = min(boxHeight, boxWidth)
                        let x = CGFloat(i - 1) * boxWidth + (boxWidth - size) / 2
                        let dx = CGFloat(12.0)
                        let h = CGFloat(3.0)
                        ctx?.fill(CGRect(x: x + dx, y: boxHeight - h, width: size - 2 * dx, height: h))
                    }
                    str.draw(in: CGRect(x: CGFloat(i - 1) * boxWidth, y: y, width: boxWidth, height: dateHeight))
                    date = date + 1.day
                    if date.month != startDate.month {
                        break
                    }
                }
            }
        }
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let detail = delegate.WWCalendarRowGetDetails(tag)
        if detail.type == .date {
            let boxWidth = bounds.width / 7
            if let touch = touches.sorted(by: { $0.timestamp < $1.timestamp }).last {
                let boxIndex = Int(floor(touch.location(in: self).x / boxWidth))
                //let dateTapped = detail.dateStart + boxIndex.days - (detail.dateStart.weekday - 1).days
                let dateTapped = detail.dateStart + boxIndex.days // When first weekday is Monday=2 not Sunday=1
                if dateTapped.month == detail.dateStart.month && delegate.WWCalendarRowDateIsEnable(dateTapped){
                    delegate.WWCalendarRowDidSelect(dateTapped)
                }
            }
        }
    }


    fileprivate func flashDate(_ date: Date) -> Bool {
        let detail = delegate.WWCalendarRowGetDetails(tag)

        if detail.type == .date {
            let today = Date().beginningOfDay
            let startDate = detail.dateStart.beginningOfDay
            let flashDate = date.beginningOfDay
            let boxHeight = bounds.height
            let boxWidth = bounds.width / 7
            var date = startDate

            for i in 1...7 {
                let j = i % 7 + 1 // When first weekday is Monday=2 (not Sunday=1)
                if date.weekday == j {
                    if date == flashDate {
                        var flashColor = colorBgDateFutureFlash
                        if flashDate == today {
                            flashColor = colorBgDateTodayFlash
                        }
                        else if flashDate.compare(today) == ComparisonResult.orderedAscending {
                            flashColor = colorBgDatePastFlash
                        }

                        let flashView = UIView(frame: CGRect(x: CGFloat(i - 1) * boxWidth, y: 0, width: boxWidth, height: boxHeight))
                        flashView.backgroundColor = flashColor
                        flashView.alpha = 0
                        addSubview(flashView)
                        UIView.animate(
                            withDuration: dDurationFlash / 2,
                            delay: 0,
                            options: [
                                UIView.AnimationOptions.allowAnimatedContent,
                                UIView.AnimationOptions.allowUserInteraction,
                                UIView.AnimationOptions.beginFromCurrentState,
                                UIView.AnimationOptions.curveEaseOut
                            ],
                            animations: {
                                flashView.alpha = 0.75
                            },
                            completion: { _ in
                                UIView.animate(
                                    withDuration: self.dDurationFlash / 2,
                                    delay: 0,
                                    options: [
                                        UIView.AnimationOptions.allowAnimatedContent,
                                        UIView.AnimationOptions.allowUserInteraction,
                                        UIView.AnimationOptions.beginFromCurrentState,
                                        UIView.AnimationOptions.curveEaseIn
                                    ],
                                    animations: {
                                        flashView.alpha = 0
                                    },
                                    completion: { _ in
                                        flashView.removeFromSuperview()
                                    }
                                )
                            }
                        )
                        return true
                    }
                    date = date + 1.day
                    if date.month != startDate.month {
                        break
                    }
                }
            }
        }
        return false
    }
}


open class WWCalendarTimeSelector: UIViewController, WWCalendarRowProtocol, WWClockProtocol {

    // A convenient identifier object. Not used by WWCalendarTimeSelector.
    open var optionIdentifier: AnyObject?

    // The delegate of WWCalendarTimeSelector can adopt the WWCalendarTimeSelectorProtocol optional methods. The following Optional methods are available:
    //  WWCalendarTimeSelectorDone:selector:dates:
    //  WWCalendarTimeSelectorDone:selector:date:
    //  WWCalendarTimeSelectorCancel:selector:dates:
    //  WWCalendarTimeSelectorCancel:selector:date:
    //  WWCalendarTimeSelectorWillDismiss:selector:
    //  WWCalendarTimeSelectorDidDismiss:selector:
    open weak var delegate: WWCalendarTimeSelectorProtocol?

    // Set optionPickerStyle with one or more of the following:
    //  DateMonth: This shows the the date and month.
    //  Year     : This shows the year.
    //  Time     : This shows the clock, users will be able to select hour and minutes as well as am or pm.
    // - Note:
    //  optionPickerStyle should contain at least 1 of the following style. It will default to all styles should there be none in the option specified.
    // - Note:
    //  Defaults to all styles.
    open var optionStyles: WWCalendarTimeSelectorStyle = WWCalendarTimeSelectorStyle()

    // Set optionTimeStep to customise the period of time which the users will be able to choose. The step will show the user the available minutes to select (with exception of OneMinute step, see *Note*).
    // - Note:
    //  Setting optionTimeStep to OneMinute will show the clock face with minutes on intervals of 5 minutes.
    //  In between the intervals will be empty space. Users will however be able to adjust the minute hand into the intervals of those 5 minutes.
    // - Note:
    //  Setting optionTimeStep to SixtyMinutes will disable the minutes selection entirely.
    open var optionTimeStep: WWCalendarTimeSelectorTimeStep = .oneMinute

    // Set optionSelectionType with one of the following:
    //  Single  : This will only allow the selection of a single date. If applicable, this also allows selection of year and time.
    //  Multiple: This will allow the selection of multiple dates. This automatically ignores the attribute of optionPickerStyle, hence selection of multiple year and time is currently not available.
    //  Range   : This will allow the selection of a range of dates. This automatically ignores the attribute of optionPickerStyle, hence selection of multiple year and time is currently not available.
    // - Note:
    //  Selection styles will only affect date selection. It is currently not possible to select multiple/range
    open var optionSelectionType: WWCalendarTimeSelectorSelection = .single

    // Set optionMultipleSelectionGrouping with one of the following:
    //  Simple     : No grouping for multiple selection. Selected dates are displayed as individual circles.
    //  Pill       : This is the default. Pill-like grouping where dates are grouped only if they are adjacent to each other (+- 1 day).
    //  LinkedBalls: Smaller circular selection, with a bar connecting adjacent dates.
    open var optionMultipleSelectionGrouping: WWCalendarTimeSelectorMultipleSelectionGrouping = .pill

    // Set optionMultipleDateOutputFormat with one of the following:
    //  English : Displayed as "EEE, d MMM yyyy": for example, Tue, 17 Jul 2018
    //  Japanese: "yyyy, MMM d EEE": for example, 2018, 7月 13 火
    open var optionMultipleDateOutputFormat: WWCalendarTimeSelectorMultipleDateOutputFormat = .english

    // Set the default dates when selector is presented.
    // - Note:
    //  Selector will show the earliest selected date's month by default.
    open var optionDateRangeCurrent: WWCalendarTimeSelectorDateRange        = WWCalendarTimeSelectorDateRange()
    open var optionDateRangeEnabled: WWCalendarTimeSelectorDateRangeEnabled = WWCalendarTimeSelectorDateRangeEnabled()

    open var colorFontCalendarMonth = UIColor.black
    open var colorFontCalendarDays  = UIColor.black
    open var colorFontCalendarDisabledDays = UIColor.lightGray
    open var colorFontCalendarToday          = UIColor.darkGray
    open var colorFontCalendarTodayHighlight = UIColor.white
    open var colorFontCalendarPastDates          = UIColor.darkGray
    open var colorFontCalendarPastDatesHighlight = UIColor.white
    open var colorFontCalendarFutureDates          = UIColor.darkGray
    open var colorFontCalendarFutureDatesHighlight = UIColor.white

    open var colorFontCalendarCurrentYear          = UIColor.darkGray
    open var colorFontCalendarCurrentYearHighlight = UIColor.black
    open var colorFontCalendarPastYears          = UIColor.darkGray
    open var colorFontCalendarPastYearsHighlight = UIColor.black
    open var colorFontCalendarFutureYears          = UIColor.darkGray
    open var colorFontCalendarFutureYearsHighlight = UIColor.black

    open var colorFontClockAmPm          = UIColor.black
    open var colorFontClockAmpmHighlight = UIColor.white
    open var colorFontClockHour = UIColor.black
    open var colorFontClockHourHighlight = UIColor.white
    open var colorFontClockMinute = UIColor.black
    open var colorFontClockMinuteHighlight = UIColor.white

    open var colorFontBtnCancel = UIColor.black // UIColor.brown
    open var colorFontBtnDone   = UIColor.black // UIColor.brown
    open var colorFontBtnCancelHighlight = UIColor.brown.withAlphaComponent(0.25)
    open var colorFontBtnDoneHighlight   = UIColor.brown.withAlphaComponent(0.25)

    open var colorFontPanelSelectorYear           = UIColor(white: 1, alpha: 1.0)
    open var colorFontPanelSelectorYearHighlight  = UIColor.white
    open var colorFontPanelSelectorMonth          = UIColor(white: 1, alpha: 1.0)
    open var colorFontPanelSelectorMonthHighlight = UIColor.white
    open var colorFontPanelSelectorDate           = UIColor(white: 1, alpha: 1.0)
    open var colorFontPanelSelectorDateHighlight  = UIColor.white
    open var colorFontPanelSelectorTime           = UIColor(white: 1, alpha: 1.0)
    open var colorFontPanelSelectorTimeHighlight  = UIColor.white
    open var colorFontPanelSelectorMultipleSelection          = UIColor.white
    open var colorFontPanelSelectorMultipleSelectionHighlight = UIColor.white
    open var colorFontPanelTop = UIColor.white

    open var colorBgCalendarTodayHighlight = UIColor(red: 0, green: 199 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    open var colorBgCalendarTodayFlash     = UIColor.white
    open var colorBgCalendarPastDatesHighlight = UIColor(red: 0, green: 199 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    open var colorBgCalendarPastDatesFlash     = UIColor.white
    open var colorBgCalendarFutureDatesHighlight = UIColor(red: 0, green: 199 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    open var colorBgCalendarFutureDatesFlash     = UIColor.white
    open var colorBgCalendarUnderlined = UIColor.brown
    
    open var colorBgClockAmPmHighlight = UIColor.brown
    open var colorBgClockHourHighlight       = UIColor.brown
    open var colorBgClockHourHighlightNeedle = UIColor.brown
    open var colorBgClockMinuteHighlight       = UIColor.brown
    open var colorBgClockMinuteHighlightNeedle = UIColor.brown
    open var colorBgClockFace   = UIColor(white: 0.9, alpha: 1)
    open var colorBgClockCenter = UIColor.black

    open var colorBgBtnCancel = UIColor.clear
    open var colorBgBtnDone   = UIColor.clear

    open var colorBgPanelSelector = UIColor(red: 0, green: 199 / 255.0, blue: 255 / 255.0, alpha: 1.0) // UIColor.brown.withAlphaComponent(0.9)
    open var colorBgPanelMain     = UIColor.white
    open var colorBgPanelBottom   = UIColor.white

    open var fontCalendarMonth          = UIFont.systemFont(ofSize: 14)
    open var fontCalendarDays           = UIFont.systemFont(ofSize: 13)
    open var fontCalendarDisabledDays   = UIFont.systemFont(ofSize: 13)
    open var fontCalendarToday          = UIFont.boldSystemFont(ofSize: 13)
    open var fontCalendarTodayHighlight = UIFont.boldSystemFont(ofSize: 14)
    open var fontCalendarPastDates          = UIFont.systemFont(ofSize: 12)
    open var fontCalendarPastDatesHighlight = UIFont.systemFont(ofSize: 13)
    open var fontCalendarFutureDates          = UIFont.systemFont(ofSize: 12)
    open var fontCalendarFutureDatesHighlight = UIFont.systemFont(ofSize: 13)

    open var fontCalendarCurrentYear          = UIFont.boldSystemFont(ofSize: 18)
    open var fontCalendarCurrentYearHighlight = UIFont.boldSystemFont(ofSize: 20)
    open var fontCalendarPastYears          = UIFont.boldSystemFont(ofSize: 18)
    open var fontCalendarPastYearsHighlight = UIFont.boldSystemFont(ofSize: 20)
    open var fontCalendarFutureYears          = UIFont.boldSystemFont(ofSize: 18)
    open var fontCalendarFutureYearsHighlight = UIFont.boldSystemFont(ofSize: 20)

    open var fontClockAmPm          = UIFont.systemFont(ofSize: 18)
    open var fontClockAmPmHighlight = UIFont.systemFont(ofSize: 20)
    open var fontClockHour          = UIFont.systemFont(ofSize: 16)
    open var fontClockHourHighlight = UIFont.systemFont(ofSize: 18)
    open var fontClockMinute          = UIFont.systemFont(ofSize: 12)
    open var fontClockMinuteHighlight = UIFont.systemFont(ofSize: 14)

    open var fontBtnCancel = UIFont.systemFont(ofSize: 16)
    open var fontBtnDone   = UIFont.boldSystemFont(ofSize: 16)

    open var fontPanelSelectorYear  = UIFont.systemFont(ofSize: 16)
    open var fontPanelSelectorMonth = UIFont.systemFont(ofSize: 16)
    open var fontPanelSelectorDate  = UIFont.systemFont(ofSize: 16)
    open var fontPanelSelectorTime  = UIFont.systemFont(ofSize: 16)

    open var fontPanelSelectorMultipleSelection          = UIFont.systemFont(ofSize: 16)
    open var fontPanelSelectorMultipleSelectionHighlight = UIFont.systemFont(ofSize: 17)
    open var fontPanelTop = UIFont.systemFont(ofSize: 16)


    // Set to true will show the entire selector at the top. If you only wish to hide the *title bar*, see bShowPanelTop. Set to false will hide the entire top container.
    open var bShowTopContainer: Bool = true
    // Set to true to show the weekday name *or* sTitlePanelTop if specified at the top of the selector. Set to false will hide the entire panel.
    open var bShowPanelTop: Bool = true
    open var bShowBtnCancel : Bool = true

    // Set to nil to show default title. Depending on privateOptionStyles, default titles are either **Select Multiple Dates**, **(Capitalized Weekday Full Name)** or **(Capitalized Month Full Name)**.
    open var sTitlePanelTop: String? = nil
    open var sTitleBtnDone  : String = "Done".localized()
    open var sTitleBtnCancel: String = "Cancel".localized()
    open var sTextLblRangeTo: String = "To"


    // Set to default date when selector is presented.
    // - Note:
    //  Defaults to current date and time, with time rounded off to the nearest hour.
    open var dateCurrent = Date().minute < 30 ? Date().beginningOfHour : Date().beginningOfHour + 1.hour

    // Set the default dates when selector is presented.
    // - Note:
    //  Selector will show the earliest selected date's month by default.
    open var datesCurrent: Set<Date> = []

    // Set the default dates when selector is presented.
    // - Note:
    //  Selector will show the earliest selected date's month by default.
    open var datesUnderlined: Set<Date> = []

    // Set the background blur effect, where background is a UIVisualEffectView. Available options are as UIBlurEffectStyle:
    //  Dark, Light, ExtraLight
    open var optionStyleBlurEffect: UIBlurEffect.Style = .dark


    // This is the month's offset when user is in selection of dates mode. A positive number will adjusts the month higher, while a negative number will adjust the month lower.
    // - Note:
    //  Defaults to 30.
    open var fPanelSelectorOffsetHighlightMonth: CGFloat = 30

    // This is the date's offset when user is in selection of dates mode. A positive number will adjusts the date lower, while a negative number will adjust the date higher.
    // - Note:
    //  Defaults to 24.
    open var fPanelSelectorOffsetHighlightDate: CGFloat = 24

    // This is the scale of the month when it is in active view.
    open var fPanelSelectorScaleYear : CGFloat = 4
    open var fPanelSelectorScaleMonth: CGFloat = 2.5
    open var fPanelSelectorScaleDate : CGFloat = 4.5
    open var fPanelSelectorScaleTime : CGFloat = 2.75

    // This is the height calendar's title bar. If you wish to hide the Top Panel, consider bShowPanelTop
    // - SeeAlso:
    //  bShowPanelTop
    open var fLayoutPanelTopHeight: CGFloat = 28

    // The width / height of the calendar in portrait mode. This will be translated automatically into the height /width in landscape mode.
    open var fLayoutWidth : CGFloat?
    open var fLayoutHeight: CGFloat?

    // If fLayoutWidth / fLayoutHeight is not defined, this ratio is used on the screen's width / height.
    open var fLayoutRatioWidth : CGFloat = 0.85
    open var fLayoutRatioHeight: CGFloat = 0.9

    // When calendar is in portrait / landscape mode, the ratio of *Top Container* to *Bottom Container*.
    open var fLayoutRatioPortrait : CGFloat = 7/20
    open var fLayoutRatioLandscape: CGFloat = 3/8

    // All Views
    @IBOutlet fileprivate weak var viewContainerTop   : UIView!
    @IBOutlet fileprivate weak var viewContainerBottom: UIView!
    @IBOutlet fileprivate weak var viewBgSel: UIView!
    @IBOutlet fileprivate weak var viewBgRange: UIView!
    @IBOutlet fileprivate weak var viewBgContent: UIView!
    @IBOutlet fileprivate weak var viewBgButtons: UIView!
    @IBOutlet fileprivate weak var viewSelYear: UIView!
    @IBOutlet fileprivate weak var viewSelDate: UIView!
    @IBOutlet fileprivate weak var viewSelTime: UIView!
    @IBOutlet fileprivate weak var btnCancel: UIButton!
    @IBOutlet fileprivate weak var btnDone  : UIButton!
    @IBOutlet fileprivate weak var lblYear : UILabel!
    @IBOutlet fileprivate weak var lblMonth: UILabel!
    @IBOutlet fileprivate weak var lblDay  : UILabel!
    @IBOutlet fileprivate weak var lblDate : UILabel!
    @IBOutlet fileprivate weak var lblTime : UILabel!
    @IBOutlet fileprivate weak var lblRangeStart: UILabel!
    @IBOutlet fileprivate weak var lblRangeTo   : UILabel!
    @IBOutlet fileprivate weak var lblRangeEnd  : UILabel!
    @IBOutlet fileprivate weak var tblSelMultipleDates: UITableView!
    @IBOutlet fileprivate weak var tblCalendar: UITableView!
    @IBOutlet fileprivate weak var tblYear: UITableView!
    @IBOutlet fileprivate weak var viewClock: WWClock!
    @IBOutlet fileprivate weak var viewMonths: UIView!
    @IBOutlet fileprivate var arrBtnMonth: [UIButton]!
    
    // All Constraints
    @IBOutlet fileprivate weak var bottomContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomContainerHeightConstraint: NSLayoutConstraint!

    // Private Variables
    fileprivate let dDurationSelAnimation: TimeInterval = 0.4


    fileprivate var fWidthViewBounds: CGFloat {
        return view.bounds.width
    }
    fileprivate var fWidthSelInactive: CGFloat {
        return viewBgSel.frame.width / 2
    }
    fileprivate var fWidthPortrait: CGFloat {
        return min(fHeightViewBounds, fWidthViewBounds)
    }
    fileprivate var fWidthContainerPortrait: CGFloat {
        return fLayoutWidth ?? fLayoutRatioWidth * fWidthPortrait
    }
    fileprivate var fWidthContainerTopLandscape: CGFloat {
        return bShowTopContainer ? (fLayoutHeight ?? fLayoutRatioHeight * fHeightPortrait) * fLayoutRatioLandscape : 0
    }
    fileprivate var fWidthContainerBottomLandscape: CGFloat {
        return (fLayoutHeight ?? fLayoutRatioHeight * fHeightPortrait) - fWidthContainerTopLandscape
    }


    fileprivate var fHeightViewBounds: CGFloat {
        return view.bounds.height - topLayoutGuide.length - bottomLayoutGuide.length
    }
    fileprivate var fHeightSelActive: CGFloat {
        return viewBgSel.frame.height - fHeightSelInactive
    }
    fileprivate let fHeightSelInactive: CGFloat = 48
    fileprivate var fHeightPortrait: CGFloat {
        return max(fHeightViewBounds, fWidthViewBounds)
    }
    fileprivate var fHeightContainerLandscape: CGFloat {
        return fLayoutWidth ?? fLayoutRatioWidth * fWidthPortrait
    }
    fileprivate var fHeightContainerTopPortrait: CGFloat {
        return bShowTopContainer ? (fLayoutHeight ?? fLayoutRatioHeight * fHeightPortrait) * fLayoutRatioPortrait : 0
    }
    fileprivate var fHeightContainerBottomPortrait: CGFloat {
        return (fLayoutHeight ?? fLayoutRatioHeight * fHeightPortrait) - fHeightContainerTopPortrait
    }


    fileprivate var styleSelCurrent: WWCalendarTimeSelectorStyle = WWCalendarTimeSelectorStyle(isSingular: true)
    fileprivate var bIsFirstLoad = false
    fileprivate var bSelTimeStateHour = true
    fileprivate var typeCalRow1: WWCalendarRowType = WWCalendarRowType.date
    fileprivate var typeCalRow2: WWCalendarRowType = WWCalendarRowType.date
    fileprivate var typeCalRow3: WWCalendarRowType = WWCalendarRowType.date
    fileprivate var dateStartCalRow1: Date = Date()
    fileprivate var dateStartCalRow2: Date = Date()
    fileprivate var dateStartCalRow3: Date = Date()
    fileprivate var iYearRow1: Int = 2016
    fileprivate var arrDateMultiple: [Date] {
        return datesCurrent.sorted(by: { $0.compare($1) == ComparisonResult.orderedAscending })
    }
    fileprivate var dateLastAdded: Date?
    fileprivate var dateFlash: Date?
    fileprivate let sTitlePanelTopDefaultForMultipleDates = "Select Multiple Dates"


    fileprivate var bSelectingRangeStart: Bool = true {
        didSet {
            lblRangeStart.textColor = bSelectingRangeStart
                ? colorFontPanelSelectorDateHighlight
                : colorFontPanelSelectorDate
            lblRangeEnd.textColor = bSelectingRangeStart
                ? colorFontPanelSelectorDate
                : colorFontPanelSelectorDateHighlight
        }
    }
    fileprivate var bShouldResetRange: Bool = true


    // Only use this method to instantiate the selector. All customization should be done before presenting the selector to the user.
    // To receive callbacks from selector, set the delegate of selector and implement WWCalendarTimeSelectorProtocol.
    //
    //  let selector = WWCalendarTimeSelector.instantiate()
    //  selector.delegate = self
    //  presentViewController(selector, animated: true, completion: nil)
    public static func instantiate() -> WWCalendarTimeSelector {
        let podBundle = Bundle(for: self.classForCoder())
        let bundleURL = podBundle.url(forResource: "WWCalendarTimeSelectorStoryboardBundle", withExtension: "bundle")
        var bundle: Bundle?
        if let bundleURL = bundleURL {
            bundle = Bundle(url: bundleURL)
        }
        return UIStoryboard(name: "WWCalendarTimeSelector", bundle: bundle).instantiateInitialViewController() as! WWCalendarTimeSelector
    }


    open override func awakeFromNib() {
        super.awakeFromNib()
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    }


    open override func viewDidLoad() {
        super.viewDidLoad()

        //-- Take up the whole view when pushed from a navigation controller
        if navigationController != nil {
            fLayoutRatioWidth = 1
            fLayoutRatioHeight = 1
        }

        //-- Add Background View
        let background: UIView
        if navigationController != nil {
            background = UIView()
            background.backgroundColor = UIColor.white
        }
        else {
            background = UIVisualEffectView(effect: UIBlurEffect(style: optionStyleBlurEffect))
        }
        background.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(background, at: 0)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bg]|", options: [], metrics: nil, views: ["bg": background]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bg]|", options: [], metrics: nil, views: ["bg": background]))

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        background.addGestureRecognizer(gestureOutside)
        background.isUserInteractionEnabled = true

        //-- Init UI
        let seventhRowStartDate = dateCurrent.beginningOfMonth
        dateStartCalRow3 = ((seventhRowStartDate - 1.day).beginningOfWeek - 1.day).beginningOfWeek
        dateStartCalRow2 = (dateStartCalRow3 - 1.day).beginningOfWeek
        dateStartCalRow1 = (dateStartCalRow2 - 1.day).beginningOfWeek

        iYearRow1 = dateCurrent.year - 5

        tblSelMultipleDates.isHidden = optionSelectionType != .multiple
        viewBgSel.isHidden = optionSelectionType != .single
        viewBgRange.isHidden = optionSelectionType != .range

        view.layoutIfNeeded()

        //UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        //NotificationCenter.default.addObserver(
        //    self,
        //    selector: #selector(WWCalendarTimeSelector.didRotateOrNot),
        //    name: UIDevice.orientationDidChangeNotification,
        //    object: nil
        //)

        viewBgSel.backgroundColor     = colorBgPanelSelector
        viewBgRange.backgroundColor   = colorBgPanelSelector
        viewBgContent.backgroundColor = colorBgPanelMain
        viewBgButtons.backgroundColor = colorBgPanelBottom
        tblSelMultipleDates.backgroundColor = colorBgPanelSelector

        btnDone.backgroundColor   = colorBgBtnDone
        btnCancel.backgroundColor = colorBgBtnCancel
        btnDone.setAttributedTitle(
            NSAttributedString(
                string: sTitleBtnDone,
                attributes: [
                    NSAttributedString.Key.font: fontBtnDone,
                    NSAttributedString.Key.foregroundColor: colorFontBtnDone
                ]
            ),
            for: UIControl.State()
        )
        btnCancel.setAttributedTitle(
            NSAttributedString(
                string: sTitleBtnCancel,
                attributes: [
                    NSAttributedString.Key.font: fontBtnCancel,
                    NSAttributedString.Key.foregroundColor: colorFontBtnCancel
                ]
            ),
            for: UIControl.State()
        )
        btnDone.setAttributedTitle(
            NSAttributedString(
                string: sTitleBtnDone,
                attributes: [
                    NSAttributedString.Key.font: fontBtnDone,
                    NSAttributedString.Key.foregroundColor: colorFontBtnDoneHighlight
                ]
            ),
            for: UIControl.State.highlighted
        )
        btnCancel.setAttributedTitle(
            NSAttributedString(
                string: sTitleBtnCancel,
                attributes: [
                    NSAttributedString.Key.font: fontBtnCancel,
                    NSAttributedString.Key.foregroundColor: colorFontBtnCancelHighlight
                ]
            ),
            for: UIControl.State.highlighted
        )

        lblRangeTo.text = sTextLblRangeTo

        if !bShowBtnCancel {
            btnCancel.isHidden = true
        }

        lblDay.textColor   = colorFontPanelTop
        lblDay.font        = fontPanelTop
        lblYear.font       = fontPanelSelectorYear
        lblRangeStart.font = fontPanelSelectorDate
        lblRangeEnd.font   = fontPanelSelectorDate
        lblRangeTo.font    = fontPanelSelectorDate

        let firstMonth = Date().beginningOfYear
        for button in arrBtnMonth {
            button.setTitle((firstMonth + button.tag.month).stringFromFormat("MMM"), for: UIControl.State())
            button.titleLabel?.font = fontCalendarMonth
            button.tintColor = colorFontCalendarMonth
        }

        viewClock.delegate = self
        viewClock.stepMinute = optionTimeStep
        viewClock.colorBgClockFace = colorBgClockFace
        viewClock.colorBgClockFaceCenter = colorBgClockCenter
        viewClock.fontAMPM = fontClockAmPm
        viewClock.fontAMPMHighlight = fontClockAmPmHighlight
        viewClock.colorFontAmPm = colorFontClockAmPm
        viewClock.colorFontAmPmHighlight = colorFontClockAmpmHighlight
        viewClock.colorBgAmPmHighlight = colorBgClockAmPmHighlight
        viewClock.fontHour = fontClockHour
        viewClock.fontHourHighlight = fontClockHourHighlight
        viewClock.colorFontHour = colorFontClockHour
        viewClock.colorFontHourHighlight = colorFontClockHourHighlight
        viewClock.colorBgHourHighlight = colorBgClockHourHighlight
        viewClock.colorBgHourHighlightNeedle = colorBgClockHourHighlightNeedle
        viewClock.fontMinute = fontClockMinute
        viewClock.fontMinuteHighlight = fontClockMinuteHighlight
        viewClock.colorFontMinute = colorFontClockMinute
        viewClock.colorFontMinuteHighlight = colorFontClockMinuteHighlight
        viewClock.colorBgMinuteHighlight = colorBgClockMinuteHighlight
        viewClock.colorBgMinuteHighlightNeedle = colorBgClockMinuteHighlightNeedle

        updateDate()

        bIsFirstLoad = true
    }


    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if bIsFirstLoad {
            bIsFirstLoad = false // Temp fix for i6s+ bug?
            tblCalendar.reloadData()
            tblYear.reloadData()
            viewClock.setNeedsDisplay()
            tblSelMultipleDates.reloadData()
            //self.didRotateOrNot(animated: false)
            
            if optionStyles.bShowDateMonth {
                showDate(true, animated: false)
            }
            else if optionStyles.bShowMonth {
                showMonth(true, animated: false)
            }
            else if optionStyles.bShowYear {
                showYear(true, animated: false)
            }
            else if optionStyles.bShowTime {
                showTime(true, animated: false)
            }
        }
    }


    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bIsFirstLoad = false
    }


    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    /*
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    */

    open override var shouldAutorotate: Bool {
        return false
    }


    @IBAction func selectMonth(_ sender: UIButton) {
        let date = (dateCurrent.beginningOfYear + sender.tag.months).beginningOfDay
        if delegate?.WWCalendarTimeSelectorShouldSelectDate?(self, date: date) ?? true {
            dateCurrent = dateCurrent.change(year: date.year, month: date.month, day: date.day).beginningOfDay
            updateDate()
        }
    }


    @IBAction func selectStartRange() {
        if bSelectingRangeStart == true {
            let date = optionDateRangeCurrent.start
            
            let seventhRowStartDate = date.beginningOfMonth
            dateStartCalRow3 = ((seventhRowStartDate - 1.day).beginningOfWeek - 1.day).beginningOfWeek
            dateStartCalRow2 = (dateStartCalRow3 - 1.day).beginningOfWeek
            dateStartCalRow1 = (dateStartCalRow2 - 1.day).beginningOfWeek
            
            dateFlash = date
            tblCalendar.reloadData()
            tblCalendar.scrollToRow(at: IndexPath(row: 4, section: 0), at: UITableView.ScrollPosition.top, animated: true)
        }
        else {
            bSelectingRangeStart = true
        }
        bShouldResetRange = false
        updateDate()
    }


    @IBAction func selectEndRange() {
        if bSelectingRangeStart == false {
            let date = optionDateRangeCurrent.end
            
            let seventhRowStartDate = date.beginningOfMonth
            dateStartCalRow3 = ((seventhRowStartDate - 1.day).beginningOfWeek - 1.day).beginningOfWeek
            dateStartCalRow2 = (dateStartCalRow3 - 1.day).beginningOfWeek
            dateStartCalRow1 = (dateStartCalRow2 - 1.day).beginningOfWeek
            
            dateFlash = date
            tblCalendar.reloadData()
            tblCalendar.scrollToRow(at: IndexPath(row: 4, section: 0), at: UITableView.ScrollPosition.top, animated: true)
        }
        else {
            bSelectingRangeStart = false
        }
        bShouldResetRange = false
        updateDate()
    }


    @IBAction func showDate() {
        if optionStyles.bShowDateMonth {
            showDate(true)
        }
        else {
            showMonth(true)
        }
    }


    @IBAction func showYear() {
        showYear(true)
    }


    @IBAction func showTime() {
        showTime(true)
    }


    @IBAction func cancel() {
        let picker = self
        let del = delegate
        if optionSelectionType == .single {
            del?.WWCalendarTimeSelectorCancel?(picker, date: dateCurrent)
        }
        else {
            del?.WWCalendarTimeSelectorCancel?(picker, dates: arrDateMultiple)
        }
        dismiss()
    }


    @IBAction func done() {
        let picker = self
        let del = delegate
        switch optionSelectionType {
            case .single:
                del?.WWCalendarTimeSelectorDone?(picker, date: dateCurrent)
            case .multiple:
                del?.WWCalendarTimeSelectorDone?(picker, dates: arrDateMultiple)
            case .range:
                del?.WWCalendarTimeSelectorDone?(picker, dates: optionDateRangeCurrent.array)
        }
        dismiss()
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }


    fileprivate func dismiss() {
        let picker = self
        let del = delegate
        del?.WWCalendarTimeSelectorWillDismiss?(picker)
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
            del?.WWCalendarTimeSelectorDidDismiss?(picker)
        }
        else if presentingViewController != nil {
            dismiss(animated: true) {
                del?.WWCalendarTimeSelectorDidDismiss?(picker)
            }
        }
    }


    fileprivate func showDate(_ userTap: Bool, animated: Bool = true) {
        changeSelDate(animated: animated)

        if userTap {
            let seventhRowStartDate = dateCurrent.beginningOfMonth
            dateStartCalRow3 = ((seventhRowStartDate - 1.day).beginningOfWeek - 1.day).beginningOfWeek
            dateStartCalRow2 = (dateStartCalRow3 - 1.day).beginningOfWeek
            dateStartCalRow1 = (dateStartCalRow2 - 1.day).beginningOfWeek
            tblCalendar.reloadData()
            tblCalendar.scrollToRow(at: IndexPath(row: 4, section: 0), at: UITableView.ScrollPosition.top, animated: animated)
        }
        else {
            tblCalendar.reloadData()
        }
        
        let animations = {
            self.tblCalendar.alpha = 1
            self.viewMonths.alpha = 0
            self.tblYear.alpha = 0
            self.viewClock.alpha = 0
        }
        if animated {
            UIView.animate(
                withDuration: dDurationSelAnimation,
                delay: 0,
                options: [
                    UIView.AnimationOptions.allowAnimatedContent,
                    UIView.AnimationOptions.beginFromCurrentState,
                    UIView.AnimationOptions.allowUserInteraction,
                    UIView.AnimationOptions.curveEaseOut
                ],
                animations: animations,
                completion: nil
            )
        }
        else {
            animations()
        }
    }


    fileprivate func showMonth(_ userTap: Bool, animated: Bool = true) {
        changeSelMonth(animated: animated)

        let animations = {
            self.tblCalendar.alpha = 0
            self.viewMonths.alpha = 1
            self.tblYear.alpha = 0
            self.viewClock.alpha = 0
        }
        if animated {
            UIView.animate(
                withDuration: dDurationSelAnimation,
                delay: 0,
                options: [
                    UIView.AnimationOptions.allowAnimatedContent,
                    UIView.AnimationOptions.beginFromCurrentState,
                    UIView.AnimationOptions.allowUserInteraction,
                    UIView.AnimationOptions.curveEaseOut
                ],
                animations: animations,
                completion: nil
            )
        }
        else {
            animations()
        }
    }


    fileprivate func showYear(_ userTap: Bool, animated: Bool = true) {
        changeSelYear(animated: animated)
        
        if userTap {
            iYearRow1 = dateCurrent.year - 5
            tblYear.reloadData()
            tblYear.scrollToRow(at: IndexPath(row: 3, section: 0), at: UITableView.ScrollPosition.top, animated: animated)
        }
        else {
            tblYear.reloadData()
        }
        
        let animations = {
            self.tblCalendar.alpha = 0
            self.viewMonths.alpha = 0
            self.tblYear.alpha = 1
            self.viewClock.alpha = 0
        }
        if animated {
            UIView.animate(
                withDuration: dDurationSelAnimation,
                delay: 0,
                options: [
                    UIView.AnimationOptions.allowAnimatedContent,
                    UIView.AnimationOptions.beginFromCurrentState,
                    UIView.AnimationOptions.allowUserInteraction,
                    UIView.AnimationOptions.curveEaseOut
                ],
                animations: animations,
                completion: nil
            )
        }
        else {
            animations()
        }
    }


    fileprivate func showTime(_ userTap: Bool, animated: Bool = true) {
        if userTap {
            if styleSelCurrent.bShowTime {
                bSelTimeStateHour = !bSelTimeStateHour
            }
            else {
                bSelTimeStateHour = true
            }
        }
        
        if optionTimeStep == .sixtyMinutes {
            bSelTimeStateHour = true
        }
        
        changeSelTime(animated: animated)
        
        if userTap {
            viewClock.bShowingHour = bSelTimeStateHour
        }
        viewClock.setNeedsDisplay()
        
        if animated {
            UIView.transition(
                with: viewClock,
                duration: dDurationSelAnimation / 2,
                options: [UIView.AnimationOptions.transitionCrossDissolve],
                animations: {
                    self.viewClock.layer.displayIfNeeded()
                },
                completion: nil
            )
        }
        else {
            viewClock.layer.displayIfNeeded()
        }

        let animations = {
            self.tblCalendar.alpha = 0
            self.viewMonths.alpha = 0
            self.tblYear.alpha = 0
            self.viewClock.alpha = 1
        }
        if animated {
            UIView.animate(
                withDuration: dDurationSelAnimation,
                delay: 0,
                options: [
                    UIView.AnimationOptions.allowAnimatedContent,
                    UIView.AnimationOptions.beginFromCurrentState,
                    UIView.AnimationOptions.allowUserInteraction,
                    UIView.AnimationOptions.curveEaseOut
                ],
                animations: animations,
                completion: nil
            )
        }
        else {
            animations()
        }
    }


    fileprivate func updateDate() {
        if let titlePanelTop = sTitlePanelTop {
            lblDay.text = titlePanelTop
        }
        else {
            if optionSelectionType == .single {
                if optionStyles.bShowMonth {
                    lblDay.text = dateCurrent.stringFromFormat("MMMM")
                }
                else {
                    lblDay.text = dateCurrent.stringFromFormat("EEEE")
                }
            }
            else {
                lblDay.text = sTitlePanelTopDefaultForMultipleDates
            }
        }
        
        lblMonth.text = dateCurrent.stringFromFormat("MMM")
        lblDate.text = optionStyles.bShowDateMonth ? dateCurrent.stringFromFormat("d") + "日".localized() : nil
        lblYear.text = dateCurrent.stringFromFormat("yyyy") + "年".localized()
        lblRangeStart.text = optionDateRangeCurrent.start.stringFromFormat("d' 'MMM' 'yyyy")
        lblRangeEnd.text = optionDateRangeCurrent.end.stringFromFormat("d' 'MMM' 'yyyy")
        lblRangeTo.textColor = colorFontPanelSelectorDate
        if bShouldResetRange {
            lblRangeStart.textColor = colorFontPanelSelectorDateHighlight
            lblRangeEnd.textColor = colorFontPanelSelectorDateHighlight
        }
        else {
            lblRangeStart.textColor = bSelectingRangeStart ? colorFontPanelSelectorDateHighlight : colorFontPanelSelectorDate
            lblRangeEnd.textColor = bSelectingRangeStart ? colorFontPanelSelectorDate : colorFontPanelSelectorDateHighlight
        }
        
        let timeText = dateCurrent.stringFromFormat("h':'mma").lowercased()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        let attrText = NSMutableAttributedString(
            string: timeText,
            attributes: [
                NSAttributedString.Key.font           : fontPanelSelectorTime,
                NSAttributedString.Key.foregroundColor: colorFontPanelSelectorTime,
                NSAttributedString.Key.paragraphStyle : paragraph
            ]
        )
        
        if styleSelCurrent.bShowDateMonth {
            lblMonth.textColor = colorFontPanelSelectorMonthHighlight
            lblDate.textColor = colorFontPanelSelectorDateHighlight
            lblYear.textColor = colorFontPanelSelectorYear
        }
        else if styleSelCurrent.bShowMonth {
            lblMonth.textColor = colorFontPanelSelectorMonthHighlight
            lblDate.textColor = colorFontPanelSelectorDateHighlight
            lblYear.textColor = colorFontPanelSelectorYear
        }
        else if styleSelCurrent.bShowYear {
            lblMonth.textColor = colorFontPanelSelectorMonth
            lblDate.textColor = colorFontPanelSelectorDate
            lblYear.textColor = colorFontPanelSelectorYearHighlight
        }
        else if styleSelCurrent.bShowTime {
            lblMonth.textColor = colorFontPanelSelectorMonth
            lblDate.textColor = colorFontPanelSelectorDate
            lblYear.textColor = colorFontPanelSelectorYear

            //let colonIndex2 = timeText.characters.distance(from: timeText.startIndex, to: timeText.range(of: ":")!.lowerBound)
            let colonIndex = Substring(timeText).distance(from: timeText.startIndex, to: timeText.range(of: ":")!.lowerBound)
            let hourRange = NSRange(location: 0, length: colonIndex)
            let minuteRange = NSRange(location: colonIndex + 1, length: 2)
            
            if bSelTimeStateHour {
                attrText.addAttributes([NSAttributedString.Key.foregroundColor: colorFontPanelSelectorTimeHighlight], range: hourRange)
            }
            else {
                attrText.addAttributes([NSAttributedString.Key.foregroundColor: colorFontPanelSelectorTimeHighlight], range: minuteRange)
            }
        }
        lblTime.attributedText = attrText
    }


    fileprivate func changeSelDate(animated: Bool = true) {
        let animations = {
            self.view.layoutIfNeeded()
        }
        let completion = { (_: Bool) in
            if self.styleSelCurrent.bShowDateMonth {
                self.lblYear.contentScaleFactor = UIScreen.main.scale
                self.lblTime.contentScaleFactor = UIScreen.main.scale
            }
        }
        if animated {
            UIView.animate(
                withDuration: dDurationSelAnimation,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [
                    UIView.AnimationOptions.allowAnimatedContent,
                    UIView.AnimationOptions.allowUserInteraction
                ],
                animations: animations,
                completion: completion
            )
        }
        else {
            animations()
            completion(true)
        }
        styleSelCurrent.showDateMonth(true)
        updateDate()
    }


    fileprivate func changeSelMonth(animated: Bool = true) {
        lblMonth.contentScaleFactor = UIScreen.main.scale * fPanelSelectorScaleMonth
        lblDate.contentScaleFactor = UIScreen.main.scale * fPanelSelectorScaleDate
        let animations = {
            self.view.layoutIfNeeded()
        }
        let completion = { (_: Bool) in
            if self.styleSelCurrent.bShowMonth {
                self.lblYear.contentScaleFactor = UIScreen.main.scale
                self.lblTime.contentScaleFactor = UIScreen.main.scale
            }
        }
        if animated {
            UIView.animate(
                withDuration: dDurationSelAnimation,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [
                    UIView.AnimationOptions.allowAnimatedContent,
                    UIView.AnimationOptions.allowUserInteraction
                ],
                animations: animations,
                completion: completion
            )
        }
        else {
            animations()
            completion(true)
        }
        styleSelCurrent.showDateMonth(true)
        updateDate()
    }


    fileprivate func changeSelYear(animated: Bool = true) {
        lblYear.contentScaleFactor = UIScreen.main.scale * fPanelSelectorScaleYear
        let animations = {
            self.view.layoutIfNeeded()
        }
        let completion = { (_: Bool) in
            if self.styleSelCurrent.bShowYear {
                self.lblMonth.contentScaleFactor = UIScreen.main.scale
                self.lblDate.contentScaleFactor = UIScreen.main.scale
                self.lblTime.contentScaleFactor = UIScreen.main.scale
            }
        }
        if animated {
            UIView.animate(
                withDuration: dDurationSelAnimation,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [
                    UIView.AnimationOptions.allowAnimatedContent,
                    UIView.AnimationOptions.allowUserInteraction
                ],
                animations: animations,
                completion: completion
            )
        }
        else {
            animations()
            completion(true)
        }
        styleSelCurrent.showYear(true)
        updateDate()
    }


    fileprivate func changeSelTime(animated: Bool = true) {
        lblTime.contentScaleFactor = UIScreen.main.scale * fPanelSelectorScaleTime
        let animations = {
            self.view.layoutIfNeeded()
        }
        let completion = { (_: Bool) in
            if self.styleSelCurrent.bShowTime {
                self.lblMonth.contentScaleFactor = UIScreen.main.scale
                self.lblDate.contentScaleFactor = UIScreen.main.scale
                self.lblYear.contentScaleFactor = UIScreen.main.scale
            }
        }
        if animated {
            UIView.animate(
                withDuration: dDurationSelAnimation,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [
                    UIView.AnimationOptions.allowAnimatedContent,
                    UIView.AnimationOptions.allowUserInteraction
                ],
                animations: animations,
                completion: completion
            )
        }
        else {
            animations()
            completion(true)
        }
        styleSelCurrent.showTime(true)
        updateDate()
    }


    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        if scrollView == tblCalendar {
            let twoRow = viewBgContent.frame.height / 4
            if offsetY < twoRow {
                // Every row shift by 4 to the back, recalculate top 3 towards earlier dates
                let detail1 = WWCalendarRowGetDetails(-3)
                let detail2 = WWCalendarRowGetDetails(-2)
                let detail3 = WWCalendarRowGetDetails(-1)
                typeCalRow1 = detail1.type
                typeCalRow2 = detail2.type
                typeCalRow3 = detail3.type
                dateStartCalRow1 = detail1.dateStart
                dateStartCalRow2 = detail2.dateStart
                dateStartCalRow3 = detail3.dateStart
                
                scrollView.contentOffset = CGPoint(x: 0, y: offsetY + twoRow * 2)
                tblCalendar.reloadData()
            }
            else if offsetY > twoRow * 3 {
                // Every row shift by 4 to the front, recalculate top 3 towards later dates
                let detail1 = WWCalendarRowGetDetails(5)
                let detail2 = WWCalendarRowGetDetails(6)
                let detail3 = WWCalendarRowGetDetails(7)
                typeCalRow1 = detail1.type
                typeCalRow2 = detail2.type
                typeCalRow3 = detail3.type
                dateStartCalRow1 = detail1.dateStart
                dateStartCalRow2 = detail2.dateStart
                dateStartCalRow3 = detail3.dateStart
                
                scrollView.contentOffset = CGPoint(x: 0, y: offsetY - twoRow * 2)
                tblCalendar.reloadData()
            }
        }
        else if scrollView == tblYear {
            let triggerPoint = viewBgContent.frame.height / 10 * 3
            if offsetY < triggerPoint {
                iYearRow1 = iYearRow1 - 3
                
                scrollView.contentOffset = CGPoint(x: 0, y: offsetY + triggerPoint * 2)
                tblYear.reloadData()
            }
            else if offsetY > triggerPoint * 3 {
                iYearRow1 = iYearRow1 + 3
                
                scrollView.contentOffset = CGPoint(x: 0, y: offsetY - triggerPoint * 2)
                tblYear.reloadData()
            }
        }
    }


    internal func WWCalendarRowDateIsEnable(_ date: Date) -> Bool {
        if let fromDate = optionDateRangeEnabled.start,
            date.compare(fromDate) == .orderedAscending {
            return false
        }
        if let toDate = optionDateRangeEnabled.end,
            date.compare(toDate) == .orderedDescending {
            return false
        }
        return true
    }


    // CAN DO BETTER! TOO MANY LOOPS!
    internal func WWCalendarRowGetDetails(_ row: Int) -> (type: WWCalendarRowType, dateStart: Date) {
        if row == 1 {
            return (typeCalRow1, dateStartCalRow1)
        }
        else if row == 2 {
            return (typeCalRow2, dateStartCalRow2)
        }
        else if row == 3 {
            return (typeCalRow3, dateStartCalRow3)
        }
        else if row > 3 {
            var startRow : Int
            var startDate: Date
            var rowType: WWCalendarRowType
            if typeCalRow3 == .date {
                startRow = 3
                startDate = dateStartCalRow3
                rowType = typeCalRow3
            }
            else if typeCalRow2 == .date {
                startRow = 2
                startDate = dateStartCalRow2
                rowType = typeCalRow2
            }
            else {
                startRow = 1
                startDate = dateStartCalRow1
                rowType = typeCalRow1
            }

            for _ in startRow..<row {
                if rowType == .month {
                    rowType = .day
                }
                else if rowType == .day {
                    rowType = .date
                    startDate = startDate.beginningOfMonth
                }
                else {
                    let newStartDate = startDate.endOfWeek + 1.day
                    if newStartDate.month != startDate.month {
                        rowType = .month
                    }
                    startDate = newStartDate
                }
            }
            return (rowType, startDate)
        }
        else {
            // row <= 0
            var startRow : Int
            var startDate: Date
            var rowType: WWCalendarRowType
            if typeCalRow1 == .date {
                startRow = 1
                startDate = dateStartCalRow1
                rowType = typeCalRow1
            }
            else if typeCalRow2 == .date {
                startRow = 2
                startDate = dateStartCalRow2
                rowType = typeCalRow2
            }
            else {
                startRow = 3
                startDate = dateStartCalRow3
                rowType = typeCalRow3
            }

            for _ in row..<startRow {
                if rowType == .date {
                    if startDate.day == 1 {
                        rowType = .day
                    }
                    else {
                        let newStartDate = (startDate - 1.day).beginningOfWeek
                        if newStartDate.month != startDate.month {
                            startDate = startDate.beginningOfMonth
                        }
                        else {
                            startDate = newStartDate
                        }
                    }
                }
                else if rowType == .day {
                    rowType = .month
                }
                else {
                    rowType = .date
                    startDate = (startDate - 1.day).beginningOfWeek
                }
            }
            return (rowType, startDate)
        }
    }


    internal func WWCalendarRowDidSelect(_ date: Date) {
        if delegate?.WWCalendarTimeSelectorShouldSelectDate?(self, date: date) ?? true {
            switch optionSelectionType {
                case .single:
                    dateCurrent = dateCurrent.change(year: date.year, month: date.month, day: date.day)
                    updateDate()

                case .multiple:
                    var indexPath: IndexPath
                    var indexPathToReload: IndexPath? = nil

                    if let d = dateLastAdded {
                        let indexToReload = arrDateMultiple.firstIndex(of: d)!
                        indexPathToReload = IndexPath(row: indexToReload, section: 0)
                    }

                    if let indexToDelete = arrDateMultiple.firstIndex(of: date) {
                        // delete...
                        indexPath = IndexPath(row: indexToDelete, section: 0)
                        datesCurrent.remove(date)

                        tblSelMultipleDates.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)

                        dateLastAdded = nil
                        tblSelMultipleDates.beginUpdates()
                        tblSelMultipleDates.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                        if let ip = indexPathToReload , ip != indexPath {
                            tblSelMultipleDates.reloadRows(at: [ip], with: UITableView.RowAnimation.fade)
                        }
                        tblSelMultipleDates.endUpdates()
                    }
                    else {
                        // insert...
                        var shouldScroll = false

                        datesCurrent.insert(date)
                        let indexToAdd = arrDateMultiple.firstIndex(of: date)!
                        indexPath = IndexPath(row: indexToAdd, section: 0)

                        if indexPath.row < datesCurrent.count - 1 {
                            tblSelMultipleDates.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
                        }
                        else {
                            shouldScroll = true
                        }

                        dateLastAdded = date
                        tblSelMultipleDates.beginUpdates()
                        tblSelMultipleDates.insertRows(at: [indexPath], with: UITableView.RowAnimation.right)
                        if let ip = indexPathToReload {
                            tblSelMultipleDates.reloadRows(at: [ip], with: UITableView.RowAnimation.fade)
                        }
                        tblSelMultipleDates.endUpdates()

                        if shouldScroll {
                            tblSelMultipleDates.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
                        }
                    }

                case .range:

                    let rangeDate = date.beginningOfDay
                    if bShouldResetRange {
                        optionDateRangeCurrent.setStartDate(rangeDate)
                        optionDateRangeCurrent.setEndDate(rangeDate)
                        bSelectingRangeStart = false
                        bShouldResetRange = false
                    }
                    else {
                        if bSelectingRangeStart {
                            optionDateRangeCurrent.setStartDate(rangeDate)
                            bSelectingRangeStart = false
                        }
                        else {
                            let date0 : Date = rangeDate
                            let date1 : Date = optionDateRangeCurrent.start
                            optionDateRangeCurrent.setStartDate(min(date0, date1))
                            optionDateRangeCurrent.setEndDate(max(date0, date1))
                            bShouldResetRange = true
                        }
                    }
                    updateDate()
            }
            tblCalendar.reloadData()
        }
    }


    internal func WWClockGetTime() -> Date {
        return dateCurrent
    }


    internal func WWClockSwitchAMPM(isAM: Bool, isPM: Bool) {
        var newHour = dateCurrent.hour
        if isAM && newHour >= 12 {
            newHour = newHour - 12
        }
        if isPM && newHour < 12 {
            newHour = newHour + 12
        }

        dateCurrent = dateCurrent.change(hour: newHour)
        updateDate()
        viewClock.setNeedsDisplay()
        UIView.transition(
            with: viewClock,
            duration: dDurationSelAnimation / 2,
            options: [
                UIView.AnimationOptions.transitionCrossDissolve,
                UIView.AnimationOptions.allowUserInteraction,
                UIView.AnimationOptions.beginFromCurrentState
            ],
            animations: {
                self.viewClock.layer.displayIfNeeded()
            },
            completion: nil
        )
    }


    internal func WWClockSetHourMilitary(_ hour: Int) {
        dateCurrent = dateCurrent.change(hour: hour)
        updateDate()
        viewClock.setNeedsDisplay()
    }


    internal func WWClockSetMinute(_ minute: Int) {
        dateCurrent = dateCurrent.change(minute: minute)
        updateDate()
        viewClock.setNeedsDisplay()
    }
}


extension WWCalendarTimeSelector: UITableViewDelegate, UITableViewDataSource {

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblCalendar {
            return tableView.frame.height / 8
        }
        else if tableView == tblYear {
            return tableView.frame.height / 5
        }
        return tableView.frame.height / 5
    }


    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblCalendar {
            return 16
        }
        else if tableView == tblYear {
            return 11
        }
        return arrDateMultiple.count
    }


    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell

        if tableView == tblCalendar {
            if let c = tableView.dequeueReusableCell(withIdentifier: "cell") {
                cell = c
            }
            else {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
                let calRow = WWCalendarRow()
                calRow.translatesAutoresizingMaskIntoConstraints = false
                calRow.delegate = self
                calRow.backgroundColor = UIColor.clear

                calRow.fontMonth = fontCalendarMonth
                calRow.fontDay   = fontCalendarDays
                calRow.fontDateDisable = fontCalendarDisabledDays
                calRow.fontDatePast          = fontCalendarPastDates
                calRow.fontDatePastHighlight = fontCalendarPastDatesHighlight
                calRow.fontDateToday          = fontCalendarToday
                calRow.fontDateTodayHighlight = fontCalendarTodayHighlight
                calRow.fontDateFuture          = fontCalendarFutureDates
                calRow.fontDateFutureHighlight = fontCalendarFutureDatesHighlight

                calRow.colorFontMonth = colorFontCalendarMonth
                calRow.colorFontDay   = colorFontCalendarDays
                calRow.colorFontDateDisable = colorFontCalendarDisabledDays
                calRow.colorFontDatePast          = colorFontCalendarPastDates
                calRow.colorFontDatePastHighlight = colorFontCalendarPastDatesHighlight
                calRow.colorFontDateToday          = colorFontCalendarToday
                calRow.colorFontDateTodayHighlight = colorFontCalendarTodayHighlight
                calRow.colorFontDateFuture          = colorFontCalendarFutureDates
                calRow.colorFontDateFutureHighlight = colorFontCalendarFutureDatesHighlight

                calRow.colorBgDatePastHighlight = colorBgCalendarPastDatesHighlight
                calRow.colorBgDatePastFlash     = colorBgCalendarPastDatesFlash
                calRow.colorBgDateTodayHighlight = colorBgCalendarTodayHighlight
                calRow.colorBgDateTodayFlash     = colorBgCalendarTodayFlash
                calRow.colorBgDateFutureHighlight = colorBgCalendarFutureDatesHighlight
                calRow.colorBgDateFutureFlash     = colorBgCalendarFutureDatesFlash
                calRow.colorBgDateUnderlined = colorBgCalendarUnderlined

                calRow.dDurationFlash = dDurationSelAnimation
                calRow.multipleSelectionGrouping = optionMultipleSelectionGrouping
                calRow.bEnableMultipleSelection = optionSelectionType != .single
                cell.contentView.addSubview(calRow)
                cell.backgroundColor = UIColor.clear
                cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cr]|", options: [], metrics: nil, views: ["cr": calRow]))
                cell.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cr]|", options: [], metrics: nil, views: ["cr": calRow]))
            }

            for sv in cell.contentView.subviews {
                if let calRow = sv as? WWCalendarRow {
                    calRow.tag = (indexPath as NSIndexPath).row + 1
                    switch optionSelectionType {
                        case .single:
                            calRow.datesSelected = [dateCurrent]
                        case .multiple:
                            calRow.datesSelected = datesCurrent
                        case .range:
                            calRow.datesSelected = Set(optionDateRangeCurrent.array)
                    }

                    calRow.datesUnderlined = datesUnderlined

                    calRow.setNeedsDisplay()
                    if let fd = dateFlash {
                        if calRow.flashDate(fd) {
                            dateFlash = nil
                        }
                    }
                }
            }
        }
        else if tableView == tblYear {
            if let c = tableView.dequeueReusableCell(withIdentifier: "cell") {
                cell = c
            }
            else {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
                cell.backgroundColor = UIColor.clear
                cell.textLabel?.textAlignment = NSTextAlignment.center
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }

            let currentYear = Date().year
            let displayYear = iYearRow1 + (indexPath as NSIndexPath).row
            if displayYear > currentYear {
                cell.textLabel?.font = dateCurrent.year == displayYear ? fontCalendarFutureYearsHighlight : fontCalendarFutureYears
                cell.textLabel?.textColor = dateCurrent.year == displayYear ? colorFontCalendarFutureYearsHighlight : colorFontCalendarFutureYears
            }
            else if displayYear < currentYear {
                cell.textLabel?.font = dateCurrent.year == displayYear ? fontCalendarPastYearsHighlight : fontCalendarPastYears
                cell.textLabel?.textColor = dateCurrent.year == displayYear ? colorFontCalendarPastYearsHighlight : colorFontCalendarPastYears
            }
            else {
                cell.textLabel?.font = dateCurrent.year == displayYear ? fontCalendarCurrentYearHighlight : fontCalendarCurrentYear
                cell.textLabel?.textColor = dateCurrent.year == displayYear ? colorFontCalendarCurrentYearHighlight : colorFontCalendarCurrentYear
            }
            cell.textLabel?.text = "\(displayYear)"
        }
        else { // multiple dates table
            if let c = tableView.dequeueReusableCell(withIdentifier: "cell") {
                cell = c
            }
            else {
                cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
                cell.textLabel?.textAlignment = NSTextAlignment.center
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = UIColor.clear
            }

            let date = arrDateMultiple[(indexPath as NSIndexPath).row]
            cell.textLabel?.font = date == dateLastAdded ? fontPanelSelectorMultipleSelectionHighlight : fontPanelSelectorMultipleSelection
            cell.textLabel?.textColor = date == dateLastAdded ? colorFontPanelSelectorMultipleSelectionHighlight : colorFontPanelSelectorMultipleSelection

            // output date format
            switch optionMultipleDateOutputFormat {
                case .english:
                    cell.textLabel?.text = date.stringFromFormat("EEE', 'd' 'MMM' 'yyyy")
                case .japanese:
                    cell.textLabel?.text = date.stringFromFormat("yyyy'年 'MMM' 'd'日 'EEE")
            }

        }

        return cell
    }


    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblYear {
            let displayYear = iYearRow1 + (indexPath as NSIndexPath).row
            if let newDate = dateCurrent.change(year: displayYear),
                WWCalendarRowDateIsEnable(newDate),
                delegate?.WWCalendarTimeSelectorShouldSelectDate?(self, date: newDate) ?? true {
                dateCurrent = newDate
                updateDate()
                tableView.reloadData()
            }
        }
        else if tableView == tblSelMultipleDates {
            let date = arrDateMultiple[(indexPath as NSIndexPath).row]
            dateLastAdded = date
            tblSelMultipleDates.reloadData()
            let seventhRowStartDate = date.beginningOfMonth
            dateStartCalRow3 = ((seventhRowStartDate - 1.day).beginningOfWeek - 1.day).beginningOfWeek
            dateStartCalRow2 = (dateStartCalRow3 - 1.day).beginningOfWeek
            dateStartCalRow1 = (dateStartCalRow2 - 1.day).beginningOfWeek

            dateFlash = date
            tblCalendar.reloadData()
            tblCalendar.scrollToRow(at: IndexPath(row: 4, section: 0), at: UITableView.ScrollPosition.top, animated: true)
        }
    }


}

