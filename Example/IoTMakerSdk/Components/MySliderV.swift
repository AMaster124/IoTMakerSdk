//
//  MySlider.swift
//  IoTSDK Demo
//
//  Created by Coding on 2020/11/11.
//  Copyright © 2020 파디오. All rights reserved.
//

import UIKit
public protocol MySliderDelegate: class {
    /// slider value changed
    func sliderValueChanged(slider: MySlider, val: CGFloat)
    func didEndSliding(slider: MySlider, val: CGFloat)
}

class CustomTrackControl: UIControl {
    var slider: MySlider!
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        slider.trackValue(touch: touch)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        slider.trackValue(touch: touch)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if touch != nil {
//            slider.trackValue(touch: touch!)
            if let touch = touch {
                slider.didEndSliding(touch: touch)
            }
        }
    }
}

public class MySlider: UIView {
    open var delegate: MySliderDelegate? = nil

    var trackView: UIView!
    var pinImageView: UIImageView!
    var trackHighlightView: UIView!
    var trackControl: CustomTrackControl!
    
    @IBInspectable open var pinImage: UIImage? {
        didSet {
        }
    }
    
    @IBInspectable open var trackHighlightColor: UIColor? {
        didSet {
            
        }
    }
    
    @IBInspectable open var minimumValue: CGFloat = 0.0 {
        didSet {
            
        }
    }
    
    /// max value
    @IBInspectable open var maximumValue: CGFloat = 100.0 {
        didSet {
            
        }
    }
    
    /// value for upper thumb
    @IBInspectable open var currentValue: CGFloat = 100.0 {
        didSet {
            
        }
    }
    
    /// stepValue. If set, will snap to discrete step points along the slider . Default to nil
    @IBInspectable open var stepValue: CGFloat = 0.1 {
        didSet {
            
        }
    }
    
    /// minimum distance between the upper and lower thumbs.
    open var gapBetweenThumbs: CGFloat = 2.0 {
        didSet {
            
        }
    }
    
    /// tint color for track between 2 thumbs
    @IBInspectable open var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        updateUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
        
        trackView = UIView(frame: CGRect(x: 0, y: frame.height/4, width: frame.width, height: frame.height/2))
        trackView.clipsToBounds = true
        trackView.backgroundColor = trackTintColor
        trackView.cornerRadius = 0.5
        addSubview(trackView!)

        trackHighlightView = UIView()
        trackHighlightView.cornerRadius = 3
        addSubview(trackHighlightView!)

        pinImageView = UIImageView(image: pinImage)
        pinImageView.contentMode = .scaleToFill
        addSubview(pinImageView)
        
        trackControl = CustomTrackControl()
        trackControl.slider = self
        addSubview(trackControl)
        
        updateUI()
    }

    func updateUI() {
        let pinH: CGFloat = 40
        trackView.frame = CGRect(x: pinH/2, y: frame.height/2-0.5, width: frame.width - pinH, height: 1)
        let trackFrame  = trackView.frame
        let currWidth   = trackFrame.width * (currentValue - minimumValue)/(maximumValue - minimumValue)
        
        trackHighlightView.frame = CGRect(x: pinH/2, y: frame.height/2-3, width: currWidth, height: 6)
        trackHighlightView.backgroundColor = trackHighlightColor
        
        pinImageView.image = pinImage
        pinImageView.frame = CGRect(x: trackFrame.minX + currWidth - pinH/2, y: frame.height/2 - pinH/2, width: pinH, height: pinH)
        
        trackControl.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        trackView.backgroundColor = trackTintColor
    }
    
    func trackValue(touch: UITouch) {
        calculateValue(touch: touch)
        delegate?.sliderValueChanged(slider: self, val: currentValue)
        updateUI()
    }
    
    func didEndSliding(touch: UITouch) {
        calculateValue(touch: touch)
        delegate?.didEndSliding(slider: self, val: currentValue)
        updateUI()
    }
    
    func calculateValue(touch: UITouch) {
        let loc = touch.location(in: self)
        let trackFrame = trackView.frame
        let val = minimumValue + (maximumValue-minimumValue) * (loc.x  - trackFrame.minX) / trackFrame.width
        currentValue = boundValue(round( val / stepValue ) * stepValue)
    }
    
    func boundValue(_ value: CGFloat) -> CGFloat {
        return min(max(value, minimumValue), maximumValue)
    }
    
    func setValue( value: CGFloat ) {
        currentValue = value
        updateUI()
    }
    
    func setLimit( min: CGFloat, max: CGFloat ) {
        minimumValue = min
        maximumValue = max
        updateUI()
    }
    
    func setStep( step: CGFloat ) {
        stepValue = step
    }
    
    func setGapBetweenThumbs( val: CGFloat ) {
        gapBetweenThumbs = val
    }
    
}
