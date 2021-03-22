//
//  MyCircleProgressV.swift
//  IoTSDK Demo
//
//  Created by Coding on 2020/11/11.
//  Copyright © 2020 파디오. All rights reserved.
//

import UIKit

class MyCircleProgressV: UIView {
    var progressLyr = CAShapeLayer()
    var trackLyr = CAShapeLayer()
    var pointerIV: UIImageView? = nil
    var progressValue:CGFloat = 0 {
        didSet {
            progressLyr.strokeEnd = progressValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    @IBInspectable open var pinImg: UIImage? = nil
    @IBInspectable open var progressClr: UIColor? = nil
    @IBInspectable open var trackClr: UIColor? = nil
    @IBInspectable open var pinH: CGFloat = 40
    @IBInspectable open var strokeWidth: CGFloat = 6

    override func layoutSubviews() {
        updateUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
        
        layer.addSublayer(trackLyr)
        layer.addSublayer(progressLyr)
        
        pointerIV = UIImageView()
        pointerIV?.backgroundColor = .clear
        pointerIV?.layer.cornerRadius = pinH/2
        addSubview(pointerIV!)

        updateUI()
    }

    func updateUI() {
        let progressWidth = self.frame.width
        
//        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (progressWidth - strokeWidth - pinH)/2, startAngle: CGFloat(0.5 * .pi), endAngle: CGFloat(2.5 * .pi), clockwise: true)
        
        trackLyr.path = circlePath.cgPath
        trackLyr.fillColor = UIColor.clear.cgColor
        trackLyr.strokeColor = trackClr != nil ? trackClr?.cgColor :  progressClr?.withAlphaComponent(0.4).cgColor
        trackLyr.lineWidth = 1
        trackLyr.strokeEnd = 1.0
        
        progressLyr.path = circlePath.cgPath
        progressLyr.fillColor = UIColor.clear.cgColor
        progressLyr.strokeColor = progressClr?.cgColor
        progressLyr.lineWidth = strokeWidth
        progressLyr.strokeEnd = progressValue
        progressLyr.lineCap = .round
        
        pointerIV?.image = pinImg
        setPointer(value: progressValue)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLyr.strokeEnd = CGFloat(value)
        progressLyr.add(animation, forKey: "animateprogress")
    }
    
    func setPointer( value: CGFloat ) {
        let posX = frame.width/2 + ((frame.width-strokeWidth-pinH)/2) * cos((2*value+0.5)*CGFloat(Double.pi))
        let posY = frame.width/2 + ((frame.width-strokeWidth-pinH)/2) * sin((2*value+0.5)*CGFloat(Double.pi))
        
        pointerIV?.frame = CGRect(x: posX - pinH/2, y: posY - pinH/2, width: pinH, height: pinH)
    }
}
