//
//  HMAlertVC.swift
//  HelpMeApp
//
//  Created by Coding on 2020/11/11.
//  Copyright © 2020 파디오. All rights reserved.
//

import UIKit

class MyAlertVC: UIViewController {
    @IBOutlet var messageLbl: UILabel!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var okBtn: UIButton!
    
    var message = ""
    var okTitle = "확인"
    var cancelTitle = "취소"
    var completion: (() -> Void)? = nil
    var isConfirm = false
    
    static var isShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageLbl.text = message
        cancelBtn.isHidden = !isConfirm
        
        okBtn.setTitle(okTitle, for: .normal)
        cancelBtn.setTitle(cancelTitle, for: .normal)
        self.view.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, delay: .zero, options: [.curveEaseOut]) {
            self.view.alpha = 1
        }
    }
    
    static func show(message: String, isConfirm: Bool = true, okTitle: String = "예", cancelTitle: String = "아니요", completion: (() -> Void)? = nil) {
        if MyAlertVC.isShown { return }
        
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        var topVC: UIViewController? = keyWindow?.rootViewController
        if topVC != nil {
            while let presentedVC = topVC?.presentedViewController {
                topVC = presentedVC
            }
        }
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: "MyAlertVC") as! MyAlertVC
        vc.message = message
        vc.isConfirm = isConfirm
        vc.okTitle = okTitle
        vc.cancelTitle = cancelTitle
        vc.completion = completion
        vc.modalPresentationStyle = .overFullScreen
        
        topVC?.present(vc, animated: false)
        MyAlertVC.isShown = true
    }
    
    @IBAction func onBtnConfirm(_ sender: Any) {
        MyAlertVC.isShown = false
        UIView.animate(withDuration: 0.3, delay: .zero, options: [.curveEaseIn]) {
            self.view.alpha = 0
        } completion: { (_) in
            self.dismiss(animated: false) {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    self.completion?()
                }
            }
        }
    }
    
    @IBAction func onBtnCancel(_ sender: Any) {
        MyAlertVC.isShown = false
        UIView.animate(withDuration: 0.3, delay: .zero, options: [.curveEaseIn]) {
            self.view.alpha = 0
        } completion: { (_) in
            self.dismiss(animated: false)
        }
    }
}
