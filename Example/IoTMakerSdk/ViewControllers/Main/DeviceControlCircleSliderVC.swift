//
//  DeviceControlCircleSliderVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class DeviceControlCircleSliderVC: DeviceControlBaseVC {
    @IBOutlet weak var circleProgressV: MyCircleProgressV!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        circleProgressV.progressValue = 0.33
    }
}
