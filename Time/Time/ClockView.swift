//
//  ClockView.swift
//  Time
//
//  Created by Gabriel Robinson on 1/23/19.
//  Copyright © 2019 CS4530. All rights reserved.
//
import UIKit

class ClockView: UIView {
    // Length of the clock hands.
    let hourHandLength: CGFloat = 50
    let minuteHandLength: CGFloat = 75
    let secondHandLength: CGFloat = 65
    // Hours from GMT time
    var hoursFromGMT = 0
    // Timer to initiate the redrawing of various elements within the clockface
    let redrawTimer: Timer = Timer()
    // End of hour hand
    var currentHourHandVector: CGPoint?
    //  x and y coordinates for the center of the clock face
    var faceCenter: CGPoint?
    // Label for displaying the current timezone
    var timeZoneLabel = UILabel()
    
    // Touches began event that allows the user to drag the hour hand, thereby changing the timezone
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch: UITouch = touches.first!
        let touchPoint = touch.location(in: self)
        if let center = faceCenter, let currentVec = currentHourHandVector {
            var angleBetween = getAngleBetweenTwoVectors(aStart: center, aEnd: touchPoint, bStart: center, bEnd: CGPoint(x: center.x + currentVec.x, y: center.y + currentVec.y))
            angleBetween = round(angleBetween)
            if abs(Int(angleBetween)) % 30 == 0 {
                if angleBetween > 0.0 {
                    hoursFromGMT -= 1
                } else if angleBetween < 0.0 {
                    hoursFromGMT += 1
                }
                if hoursFromGMT < 0 {
                    hoursFromGMT += 24
                } else if hoursFromGMT >= 24 {
                    hoursFromGMT -= 24
                }
            }
        }
    }

    // Overloaded UIView constructors, that call startRedrawClock()
    override init(frame: CGRect) {
        super.init(frame: frame)
        startRedrawClock()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        startRedrawClock()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not implemented")
    }
    
    // Function that starts the timer that updates the display with the correct time. A redraw occurs every .025 seconds.
    func startRedrawClock() {
        Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true, block: {
            (redrawTimer) in self.setNeedsDisplay()
        })
    }
    
    // Draw the tick marks
    fileprivate func drawTickMarks(_ faceRect: CGRect, _ context: CGContext) {
        context.setLineCap(CGLineCap(rawValue: 1)!)
        var tickMarkCoords = [(CGPoint, CGPoint)]()
        tickMarkCoords.append((CGPoint(x: faceRect.midX, y: faceRect.midY + 90), CGPoint(x: faceRect.midX, y: faceRect.midY + 120)))
        tickMarkCoords.append((CGPoint(x: faceRect.midX, y: faceRect.midY - 90), CGPoint(x: faceRect.midX, y: faceRect.midY - 120)))
        tickMarkCoords.append((CGPoint(x: faceRect.midX + 90, y: faceRect.midY), CGPoint(x: faceRect.midX + 120, y: faceRect.midY)))
        tickMarkCoords.append((CGPoint(x: faceRect.midX - 90, y: faceRect.midY), CGPoint(x: faceRect.midX - 120, y: faceRect.midY)))
        tickMarkCoords.append((CGPoint(x: faceRect.midX + 63.64, y: faceRect.midY +  63.64), CGPoint(x: faceRect.midX + 84.85, y: faceRect.midY + 84.85)))
        tickMarkCoords.append((CGPoint(x: faceRect.midX -  63.64, y: faceRect.midY +  63.64), CGPoint(x: faceRect.midX - 84.85, y: faceRect.midY + 84.85)))
        tickMarkCoords.append((CGPoint(x: faceRect.midX +  63.64, y: faceRect.midY -  63.64), CGPoint(x: faceRect.midX + 84.85, y: faceRect.midY - 84.85)))
        tickMarkCoords.append((CGPoint(x: faceRect.midX -  63.64, y: faceRect.midY -  63.64), CGPoint(x: faceRect.midX - 84.85, y: faceRect.midY - 84.85)))
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(3.0)
        for el in tickMarkCoords {
            context.move(to: el.0)
            context.addLine(to: el.1)
            context.strokePath()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Format the date GMT
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.timeStyle = .medium
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        let dateStringElements = dateString.split(separator: ":")
        // Get the current time in GMT
        let currentHourGMT =  Int(dateStringElements[0])
        let currentMinuteGMT = Int(dateStringElements[1])
        let currentSecondGMT = Int(dateStringElements[2])
        
        // Creating the face fo the clock
        let context: CGContext = UIGraphicsGetCurrentContext()!
        let faceRect: CGRect = CGRect(x: 10.0, y: 10 + bounds.height * 0.5 - bounds.width * 0.5, width: bounds.width - 20, height: bounds.width - 20)
        context.addEllipse(in: faceRect)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setFillColor(UIColor.white.cgColor)
        context.setLineWidth(10.0)
        context.drawPath(using: .fillStroke)
        //Creating the center of the clock face, and draw tick marks
        faceCenter = CGPoint(x: faceRect.midX, y: faceRect.midY)
        drawTickMarks(faceRect, context)
        
        if let hour = currentHourGMT, let minute = currentMinuteGMT, let second = currentSecondGMT {
            // Drawing the hour hand
            context.setStrokeColor(UIColor.green.cgColor)
            context.setLineWidth(3.0)
            context.beginPath()
            context.move(to: faceCenter!)
            let currentHourHandAngle = calculateHourAngle(hours: hour + hoursFromGMT)
            currentHourHandVector = CGPoint(x: CGFloat(hourHandLength * cos(currentHourHandAngle)), y: CGFloat(hourHandLength * sin(currentHourHandAngle)))
            let hourHand: CGPoint = CGPoint(x: faceCenter!.x + currentHourHandVector!.x, y: faceCenter!.y + currentHourHandVector!.y)
            context.addLine(to: hourHand)
            context.strokePath()

            // Drawing the minute hand
            context.setStrokeColor(UIColor.black.cgColor)
            context.beginPath()
            context.move(to: faceCenter!)
            let currentMinuteHandAngle = calculateMinuteAngle(minutes: minute)
            var transformationX = CGFloat(minuteHandLength * cos(currentMinuteHandAngle))
            var transformationY = CGFloat(minuteHandLength * sin(currentMinuteHandAngle))
            let minuteHand: CGPoint = CGPoint(x: faceCenter!.x + transformationX, y: faceCenter!.y + transformationY)
            context.addLine(to: minuteHand)
            context.strokePath()
        
            // Drawing the second hand
            context.setStrokeColor(UIColor.red.cgColor)
            context.beginPath()
            context.move(to: faceCenter!)
            let currentSecondHandAngle = calculateSecondAngle(seconds: second % 60)
            transformationX = CGFloat(secondHandLength * cos(currentSecondHandAngle))
            transformationY = CGFloat(secondHandLength * sin(currentSecondHandAngle))
            let secondHand: CGPoint = CGPoint(x: faceRect.midX + transformationX, y: faceRect.midY + transformationY)
            context.addLine(to: secondHand)
            context.strokePath()
        }
        
        // Put circular cap on clock hands
        let capRect: CGRect = CGRect(x: faceCenter!.x - 4.0, y: faceCenter!.y - 4.0, width: 8.0, height: 8.0)
        context.addEllipse(in: capRect)
        context.setFillColor(UIColor.black.cgColor)
        context.setLineWidth(10.0)
        context.drawPath(using: .fill)

        // Draw the text for the time zone with the correct timezone
        timeZoneLabel.textColor = UIColor.green
        timeZoneLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20.0)
        if hoursFromGMT < 10{
            timeZoneLabel.text = "GMT+0\(String(hoursFromGMT))"
        } else {
            timeZoneLabel.text = "GMT+\(String(hoursFromGMT))"
        }
        self.addSubview(timeZoneLabel)
        timeZoneLabel.drawText(in: CGRect(x: faceRect.minX + 95, y: faceRect.maxY + 20, width: 200, height: 15))
    }

    // Calculate the angle of the second hand based upon the  current time
    func calculateSecondAngle(seconds: Int)->CGFloat {
        return radiansFrom(degrees: CGFloat(seconds) / 60.0 * 360.0)
    }

    // Calculate the angle of the minute hand based upon the current time
    func calculateMinuteAngle(minutes: Int)->CGFloat {
        return radiansFrom(degrees: CGFloat(minutes) / 60 * 360)
    }
    
    // Calculate the angle of the hour hand based upon the current time
    func calculateHourAngle(hours: Int)->CGFloat {
        return radiansFrom(degrees: CGFloat(hours % 12) / 12.0 * 360.0)
    }

    // Get radians from degrees
    func radiansFrom(degrees: CGFloat)->CGFloat {
        return (degrees - 90) * CGFloat.pi / 180.0
    }
    
    // Get degrees from radians
    func degreesFrom(radians: CGFloat)->CGFloat {
        return radians * 180.0 / CGFloat.pi
    }
    
    // Get the length of a vector
    func magnitude(vector: CGPoint)->CGFloat {
        return sqrt(vector.x * vector.x + vector.y * vector.y)
    }
    
    // Normalize vector stored as a CGPoint
    func normalize(vector: CGPoint)->CGPoint {
        let mag = magnitude(vector: vector)
        return CGPoint(x: vector.x / mag, y: vector.y / mag)
    }

    // Find the angle between two vectors
    func getAngleBetweenTwoVectors(aStart: CGPoint, aEnd: CGPoint, bStart: CGPoint,  bEnd: CGPoint)->CGFloat {
        let aCompX: CGFloat = aEnd.x - aStart.x
        let aCompY: CGFloat = aEnd.y - aStart.y
        let firstAngle = atan2(aCompX, aCompY)
        let bCompX: CGFloat = bEnd.x - bStart.x
        let bCompY: CGFloat = bEnd.y - bStart.y
        let secondAngle = atan2(bCompX, bCompY)
        var angleBetween = (firstAngle - secondAngle) * 180 / CGFloat.pi
        if angleBetween <= -180.0 {
            angleBetween += 360.0
        } else if angleBetween >= 180.0 {
            angleBetween -= 360.0
        }
        return angleBetween
    }
}

