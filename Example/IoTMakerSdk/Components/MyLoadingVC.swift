//
//  HMAlertVC.swift
//  HelpMeApp
//
//  Created by Coding on 2020/11/11.
//  Copyright © 2020 파디오. All rights reserved.
//

import UIKit

class MyLoadingVC: UIViewController {
    static var shared: MyLoadingVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MyLoadingVC.shared = self

        self.view.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, delay: .zero, options: [.curveEaseOut]) {
            self.view.alpha = 1
        }
    }
    
    static func show() {
        if MyLoadingVC.shared != nil {
            return
        }
        
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        var topVC: UIViewController? = keyWindow?.rootViewController
        if topVC != nil {
            while let presentedVC = topVC?.presentedViewController {
                topVC = presentedVC
            }
        }
        
        shared = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: "MyLoadingVC") as! MyLoadingVC

        shared!.modalPresentationStyle = .overFullScreen
        
        topVC?.present(shared!, animated: false)
    }
    
    static func hide() {
        if MyLoadingVC.shared == nil {
            return
        }
        
        MyLoadingVC.shared?.dismiss(animated: false, completion: {
            MyLoadingVC.shared = nil
        })
    }
}
