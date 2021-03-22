//
//  ViewController.swift
//  demoapp
//
//  Created by Coding on 03.03.21.
//

import UIKit
import IoTMakerSdk

class LoginVC: UIViewController {
    @IBOutlet weak var idTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var idCancelBtn: UIButton!
    @IBOutlet weak var passwordCancelBtn: UIButton!
    @IBOutlet weak var inputStackTop: NSLayoutConstraint!
    @IBOutlet weak var inputStackV: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let tapManager = UITapGestureRecognizer(target: self, action: #selector(viewDidTapped))
        self.view.addGestureRecognizer(tapManager)
        
        idTF.delegate = self
        passwordTF.delegate = self
        
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func viewDidTapped() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if keyboardSize.height == 0.0 {
                return
            }
            
            let targetY = inputStackV.frame.maxY
            let minY = self.view.frame.height - keyboardSize.height - 10
            if targetY - minY > 0 {
                UIView.animate(withDuration: 0.5) {
                    self.inputStackTop.constant = minY - targetY - 20
                    self.view.layoutIfNeeded()
                }
            } else {
                return
            }
            
        }
    }
    
    @objc func keyboardWillHide() {
        UIView.animate(withDuration: 0.5) {
            self.inputStackTop.constant = -20
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onBtnLogin(_ sender: Any) {
        let username = idTF.text!
        let password = passwordTF.text!
        if username.isEmpty {
            MyAlertVC.show(message: "아이디를 입력해주세요", isConfirm: false) {
                self.idTF.becomeFirstResponder()
            }
            return
        }
        if password.isEmpty {
            MyAlertVC.show(message: "비밀번호를 입력해주세요", isConfirm: false) {
                self.passwordTF.becomeFirstResponder()
            }
            return
        }
        
//        MyLoadingVC.show()
        IoTMakerSdk.gigaIotOAuth(username: username, password: password) { (responds, error) in
            if let access_token = responds?["access_token"] as? String {
                Global.token = access_token
                Global.username = username
                IoTMakerSdk.getMemberInfo(token: access_token, memberId: username) { (member, error) in
                    if let member = member {
                        Global.member = member
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    } else {
                        MyAlertVC.show(message: error ?? "로그인이 실패하였습니다. 입력정보나 네트워크를 다시 확인해보세요", isConfirm: false) {
//                            MyLoadingVC.hide()
                        }
                    }
                }
            } else {
                MyAlertVC.show(message: error ?? "로그인이 실패하였습니다. 입력정보나 네트워크를 다시 확인해보세요", isConfirm: false) {
//                    MyLoadingVC.hide()
                }
            }
        }
    }
    
    @IBAction func onBtnIdClear(_ sender: Any) {
        idTF.text = ""
    }
    
    @IBAction func onBtnPasswordClear(_ sender: Any) {
        passwordTF.text = ""
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == idTF {
            idTF.backgroundColor = #colorLiteral(red: 0.5107161999, green: 0.4370320439, blue: 0.3643667102, alpha: 1)
            idCancelBtn.isHidden = false
            passwordTF.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            passwordCancelBtn.isHidden = true
            idTF.borderWidth = 0
            passwordTF.borderWidth = 1
        } else {
            idTF.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            idCancelBtn.isHidden = true
            passwordTF.backgroundColor = #colorLiteral(red: 0.5107161999, green: 0.4370320439, blue: 0.3643667102, alpha: 1)
            passwordCancelBtn.isHidden = false
            idTF.borderWidth = 1
            passwordTF.borderWidth = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == idTF {
            idTF.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            idCancelBtn.isHidden = true
            idTF.borderWidth = 1
        } else {
            passwordTF.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            passwordCancelBtn.isHidden = true
            passwordTF.borderWidth = 1
       }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == idTF {
            passwordTF.becomeFirstResponder()
        } else if textField == passwordTF {
            self.view.endEditing(true)
        }
        return false
    }
}

