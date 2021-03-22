//
//  HMPickerVC.swift
//  HelpMeApp
//
//  Created by Coding on 2020/11/11.
//  Copyright © 2020 파디오. All rights reserved.
//

import UIKit

class MyPickerVC: UIViewController {
    @IBOutlet var itemTV: UITableView!
    @IBOutlet var itemTVHeight: NSLayoutConstraint!
    @IBOutlet weak var maskV: UIView!
    @IBOutlet weak var selectV: UIView!
    @IBOutlet weak var selectBottom: NSLayoutConstraint!
    
    var items: [String] = []
    var selectedIndex: Int = 0
    var completion: ((Int) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rowHeight = itemTV.rowHeight
        itemTVHeight.constant = rowHeight * CGFloat(min(3, items.count))
        itemTV.dataSource = self
        itemTV.delegate = self
        
        selectV.layer.cornerRadius = 30
        selectV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMaskV))
        self.maskV.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectBottom.constant = -500
        self.maskV.alpha = 0
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, delay: .zero, options: [.curveEaseOut]) {
            self.maskV.alpha = 1
            self.selectBottom.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func didTapMaskV() {
        hidePicker()
    }
    
    static func show(items: [String], selected: Int = -1, completion: ((Int) -> Void)? = nil) {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        var topVC: UIViewController? = keyWindow?.rootViewController
        if topVC != nil {
            while let presentedVC = topVC?.presentedViewController {
                topVC = presentedVC
            }
        }
        
        let vc = UIStoryboard(name: "My", bundle: nil).instantiateViewController(withIdentifier: "MyPickerVC") as! MyPickerVC
        vc.items = items
        vc.completion = completion
        vc.selectedIndex = selected
        vc.modalPresentationStyle = .overFullScreen
        
        topVC?.present(vc, animated: false)
    }
    
    func hidePicker(completion: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: .zero, options: [.curveEaseIn]) {
            self.maskV.alpha = 0
            self.selectBottom.constant = -(self.itemTVHeight.constant + 100)
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.dismiss(animated: false)
            completion?()
        }
    }
}

extension MyPickerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerItemTVC", for: indexPath) as! PickerItemTVC
        cell.nameLbl.text = items[indexPath.row]
        if indexPath.row == selectedIndex {
            cell.nameLbl.backgroundColor = #colorLiteral(red: 0.8823529412, green: 0.2588235294, blue: 0.368627451, alpha: 1)
            cell.nameLbl.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            cell.nameLbl.backgroundColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 0)
            cell.nameLbl.textColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        itemTV.reloadData()

        hidePicker() {
            self.completion?(self.selectedIndex)
        }
    }
}

class PickerItemTVC: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
}
