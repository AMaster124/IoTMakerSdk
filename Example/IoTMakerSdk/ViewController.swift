//
//  ViewController.swift
//  IoTMakerSdk
//
//  Created by AMaster124 on 03/10/2021.
//  Copyright (c) 2021 AMaster124. All rights reserved.
//

import UIKit
import IoTMakerSdk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IoTMakerSdk.gigaIotOAuth(username: "portaluser", password: "ks123!@#") { (responds, error) in
            if let error = error {
                print(error)
            } else {
                print(responds)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

