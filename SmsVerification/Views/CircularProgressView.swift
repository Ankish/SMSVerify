//
//  BRCircularProgressView.swift
//  SmsVerification
//
//  Created by Ankish Jain on 3/1/19.
//  Copyright © 2019 Ankish Jain. All rights reserved.
//

import UIKit

protocol ProgressViewProtocol : class {
    func didFinish()
}

class CircularProgressView: UIView {
    
    // progress: Should be between 0 to 1
    var progress: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var circleStrokeWidth: CGFloat = 3
    private var circleStrokeColor: UIColor
    private var circleFillColor: UIColor
    private var progressCircleStrokeColor: UIColor
    private var progressCircleFillColor: UIColor
    
    private var textLabel: UILabel!
    private var textFont: UIFont? = UIFont.boldSystemFont(ofSize: 17)
    private let properties : Properties
    private var remainingSecond : CGFloat
    private var progressTimer = Timer()
    private weak var delegate : ProgressViewProtocol?
    
    // MARK: Initializers
    
    init(properties : Properties,delegate : ProgressViewProtocol?) {
        self.delegate = delegate
        self.properties = properties
        if (properties.timerType == .circle) {
            self.circleStrokeColor = properties.timerCompletedStrokeColor ?? properties.tintColor
            self.circleFillColor = properties.timerCompletedFillColor
            self.progressCircleFillColor = properties.timerUnCompletedCircleFillColor
            self.progressCircleStrokeColor = properties.timerUnCompletedCircleStrokeColor
        } else {
            self.circleStrokeColor = UIColor.white
            self.circleFillColor = UIColor.white
            self.progressCircleFillColor = UIColor.white
            self.progressCircleStrokeColor = UIColor.white
        }
        self.remainingSecond = properties.timeout
        super.init(frame: .zero)
        self.backgroundColor = UIColor.clear
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Public Methods
    
    func setProgressTextFont(_ font: UIFont = UIFont.boldSystemFont(ofSize: 17), color: UIColor = UIColor.black) {
        textLabel.font = font
        textLabel.textColor = color
    }
    
    func startTimer() {
        self.progressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            
            guard let strongSelf = self else {
                return
            }
            
            self?.remainingSecond -= 1
            self?.progress = strongSelf.remainingSecond / strongSelf.properties.timeout
            self?.setProgressText(Int(strongSelf.remainingSecond))
            
            if strongSelf.remainingSecond == 0 { // restart rotation
                timer.invalidate()
                self?.timedOutAction()
            }
        }
    }
    
    // MARK: Private Methods
    
    private func setupView() {
        textLabel = UILabel(frame: self.bounds)
        textLabel.textAlignment = .center
        textLabel.font = textFont
        textLabel.textColor = properties.timerTextColor
        textLabel.numberOfLines = 0
        
        setProgressText(Int(properties.timeout))
        
        self.addSubview(textLabel)
        self.progress = remainingSecond / properties.timeout
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
    }
    
    private func setProgressText(_ time: Int) {
        if (properties.timerType == .circle) {
            textLabel.text = "\(time)"
        } else {
            if time < 10 {
                textLabel.text = "00:0\(time)"
            } else if time < 60 {
                textLabel.text = "00:\(time)"
            } else {
                let minute = time / 60
                let sec = time % 60
                
                var minuteString = "\(minute)"
                var secString = "\(sec)"
                minuteString = minuteString.count == 1 ? "0\(minuteString)" : minuteString
                secString = secString.count == 1 ? "0\(secString)" : secString
                
                textLabel.text = "\(minuteString):\(secString)"
            }
        }
    }
    
    private func timedOutAction() {
        delegate?.didFinish()
    }
    
    // MARK: Core Graphics Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawRect(rect, margin: 0, color: circleStrokeColor, percentage: 1)
        drawRect(rect, margin: circleStrokeWidth, color: circleFillColor, percentage: 1)
        drawRect(rect, margin: circleStrokeWidth, color: progressCircleFillColor, percentage: progress)
        
        drawProgressCircle(rect)
    }
    
    private func drawRect(_ rect: CGRect, margin: CGFloat, color: UIColor, percentage: CGFloat) {
        
        let radius: CGFloat = min(rect.height, rect.width) * 0.5 - margin
        let centerX: CGFloat = rect.width * 0.5
        let centerY: CGFloat = rect.height * 0.5
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        let center: CGPoint = CGPoint(x: centerX, y: centerY)
        context.move(to: center)
        let startAngle: CGFloat = -.pi/2
        let e = .pi * 2 * percentage
        let endAngle: CGFloat = -.pi/2 + e
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context.closePath()
        context.fillPath()
    }
    
    private func drawProgressCircle(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setLineWidth(circleStrokeWidth)
        context.setStrokeColor(progressCircleStrokeColor.cgColor)
        
        let centerX: CGFloat = rect.width * 0.5
        let centerY: CGFloat = rect.height * 0.5
        let radius: CGFloat = min(rect.height, rect.width) * 0.5 - (circleStrokeWidth / 2)
        let startAngle: CGFloat = -.pi/2
        let e = .pi * 2 * progress
        let endAngle: CGFloat = -.pi/2 + e
        let center: CGPoint = CGPoint(x: centerX, y: centerY)
        
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context.strokePath()
    }
}
