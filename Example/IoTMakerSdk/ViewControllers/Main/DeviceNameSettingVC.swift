//
//  DeviceNameSettingVC.swift
//  demoapp
//
//  Created by Coding on 06.03.21.
//

import UIKit
import IoTMakerSdk

class DeviceNameSettingVC: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var btnV: UIView!
    @IBOutlet weak var btnVBottom: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    
    var selectedDevice = 0

    var updated = false {
        didSet {
            if updated {
                saveBtn.isEnabled = true
                saveBtn.alpha = 1
            } else {
                saveBtn.isEnabled = false
                saveBtn.alpha = 0.5
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTF.text = Global.devices[selectedDevice].name
        nameTF.delegate = self

        btnV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let tapManager = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped))
        self.view.addGestureRecognizer(tapManager)
        
        updated = false
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height == 0.0 {
                return
            }
            
            UIView.animate(withDuration: 0.5) {
                self.btnVBottom.constant = keyboardSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.5) {
            self.btnVBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func viewDidTapped() {
        self.view.endEditing(true)
    }
    
    func updateDeviceName() {
        let device = Global.devices[selectedDevice]
        if nameTF.text!.count < 0 {
            MyAlertVC.show(message: "디바이스 명을 입력해주세요", isConfirm: false)
            return
        }

        let params = [
            "name": nameTF.text!,
            "used": device.used
        ] as [String : Any]

        let contentType = "application/json;charset=utf-8"
        
        MyLoadingVC.show()
        IoTMakerSdk.postDeviceModify(token: Global.token, contentType: contentType, targetId: device.target.id, deviceId: device.id, memberId: Global.member.id, params: params) { (name, error) in
            if let name = name {
                Global.devices[self.selectedDevice].name = name
                MyLoadingVC.hide()
                self.navigationController?.popViewController(animated: true)
            } else {
                MyAlertVC.show(message: error ?? "Unknown Error", isConfirm: false) {
                    MyLoadingVC.hide()
                }
            }
        }
    }
    
    @IBAction func onBtnInputClear(_ sender: Any) {
        updated = true
        nameTF.text = ""
    }
    
    @IBAction func nameTextFieldChanged(_ sender: UITextField) {
        updated = true
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "디바이스 명 수정을\n취소 하시겠습니까?",isConfirm: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        if updated {
            MyAlertVC.show(message: "디바이스 명 수정을\n취소 하시겠습니까?",isConfirm: true) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onBtnSave(_ sender: Any) {
        updateDeviceName()
    }
}

extension DeviceNameSettingVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
