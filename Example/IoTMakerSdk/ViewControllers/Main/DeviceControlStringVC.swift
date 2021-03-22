//
//  DeviceControlStringVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 15.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceControlStringVC: DeviceControlBaseVC {
    @IBOutlet weak var inputTF: UITextField!
    @IBOutlet weak var titleTop: NSLayoutConstraint!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var stateLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let property = resource.properties[selectedProperty]
        inputTF.text = String(describing: property.logControl ?? "")
        stateLbl.text = inputTF.text
        titleTop.constant = 60
        
        if property.dataType == .INTEGER {
            inputTF.keyboardType = .numberPad
        } else if property.dataType == .DOUBLE {
            inputTF.keyboardType = .decimalPad
        }

        let tapManager = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped))
        self.view.addGestureRecognizer(tapManager)

        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func viewDidTapped() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height == 0.0 {
                return
            }
            
            let targetY = inputContainer.frame.maxY
            let minY = self.view.frame.height - keyboardSize.height
            if targetY - minY > 0 {
                UIView.animate(withDuration: 0.5) {
                    self.titleTop.constant = 60 + minY - targetY
                    self.view.layoutIfNeeded()
                }
            } else {
                return
            }
            
        }
    }
    
    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.5) {
            self.titleTop.constant = 60
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onBtnInputClear(_ sender: Any) {
        inputTF.text = ""
    }
    
    @IBAction func onBtnConfirm(_ sender: Any) {
        sendCtrlMsg(value: inputTF.text!) { success in
            if success {
                self.resource.properties[self.selectedProperty].logControl = self.inputTF.text
                self.stateLbl.text = self.inputTF.text
            }
        }
    }
}
