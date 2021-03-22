//
//  DeviceControlSliderVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceControlSliderVC: DeviceControlBaseVC {
    @IBOutlet weak var sliderV: MySlider!
    @IBOutlet weak var stateLbl: UILabel!
    
    var uiValues: [UIValueModel]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderV.setValue(value: 0)
        sliderV.setLimit(min: 0, max: 100)
        sliderV.setStep(step: 1)
        
        let property = resource.properties[selectedProperty]
        uiValues = Global.devices[selectedDevice].model.uiCapability?[resource.id]?[property.id]?.uiValues
        stateLbl.text = "0"
        if let uiValues = uiValues, uiValues.count > 0 {
            if let min = NumberFormatter().number(from: uiValues[0].min),
               let max = NumberFormatter().number(from: uiValues[0].max) {
                sliderV.setLimit(min: CGFloat(truncating: min), max: CGFloat(truncating: max))
            }

            if let step = NumberFormatter().number(from: uiValues[0].step) {
                sliderV.setStep(step: CGFloat(truncating: step))
            }
                
            if property.dataType == .DOUBLE {
                self.sliderV.setStep(step: 0.1)
            } else {
                self.sliderV.setStep(step: 1)
            }
            
            stateLbl.text = String(describing: property.logControl ?? "0") 
            if let log = NumberFormatter().number(from: String(describing: property.logControl ?? "")) {
                self.sliderV.setValue(value: CGFloat(log))
            }
        }

        sliderV.delegate = self
    }
}

extension DeviceControlSliderVC: MySliderDelegate {
    func didEndSliding(slider: MySlider, val: CGFloat) {
        let property = resource.properties[selectedProperty]
        if property.dataType == .INTEGER {
            stateLbl.text = "\(Int(val))"
        } else {
            stateLbl.text = "\(val)"
        }

        sendCtrlMsg(value: property.dataType == .INTEGER ? "\(Int(val))" : "\(val)") { (success) in
            if success {
                self.resource.properties[self.selectedProperty].logControl = property.dataType == .INTEGER ? "\(Int(val))" : "\(val)"
            }
            print(success)
        }
    }
    
    func sliderValueChanged(slider: MySlider, val: CGFloat) {
        let property = resource.properties[selectedProperty]
        if property.dataType == .INTEGER {
            stateLbl.text = "\(Int(val))"
        } else {
            stateLbl.text = "\(val)"
        }
    }
}
