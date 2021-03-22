//
//  DeviceCollectVC.swift
//  IoTMakerSdk_Example
//
//  Created by Coding on 16.03.21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IoTMakerSdk

class DeviceCollectVC: UIViewController {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var logTV: UITableView!
    @IBOutlet weak var chatV: UIView!
    @IBOutlet weak var tabLineLeading: NSLayoutConstraint!
    @IBOutlet weak var contentScrollV: UIScrollView!
    @IBOutlet weak var tabListBtn: UIButton!
    @IBOutlet weak var tabChartBtn: UIButton!
    @IBOutlet weak var chartV: UIView!
    @IBOutlet weak var emptyV: UIView!
    
    var deviceImg: UIImage!
    
    var selectedDevice = 0
    var resource = ResourceModel()
    var selectedProperty = 0
    
    var logs = [(String, String)]()

    var groupedLogs = [(String, [(String, String)])]()
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.emptyV.isHidden = true
        self.tabLineLeading.constant = 0
        
        contentScrollV.delegate = self
        
        initUI()
        
        MyLoadingVC.show()
        loadCollectionValue {
            MyLoadingVC.hide()
            self.setChartData()
            self.logTV.reloadData()
        }
        
        logTV.delegate = self
        logTV.dataSource = self
        
        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(reloadData), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func initUI() {
        let device = Global.devices[selectedDevice]
        let property = resource.properties[selectedProperty]

        nameLbl.text = "\(resource.name)-\(property.name)"
        
        if let resId = device.resIndex {
            deviceImg = UIImage(named: Global.ICON_LIST[resId])!
        } else if let img = device.icon {
            deviceImg = img
        } else {
            deviceImg = UIImage(named:"img_device_default")!
        }

    }
    
    @objc func reloadData() {
        loadCollectionValue {
            self.setChartData()
            self.logTV.reloadData()
        }
    }
    
    func setChartData() {
        if logs.count < 1 {
            emptyV.isHidden = false
            contentScrollV.isHidden = true
            return
        } else {
            emptyV.isHidden = true
            contentScrollV.isHidden = false
        }
        
        let cnt = min(logs.count, 7)
        
        var xLabels = [String]()
        var data = [CGFloat]()
        for i in 0 ..< cnt {
            let log = logs[i]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let date = formatter.date(from: log.1)!
            formatter.dateFormat = "HH:mm:ss"
            let aLabel = formatter.string(from: date)
            
            guard let val = Double(log.0) else {
                continue
            }
            
            xLabels.insert(aLabel, at: 0)
            data.insert(CGFloat(val), at: 0)
        }
        
        let lineChart = LineChart()
        
        lineChart.animation.enabled = true
        lineChart.area = true
        lineChart.x.labels.visible = true
        lineChart.x.grid.count = CGFloat(xLabels.count)
        lineChart.y.grid.count = CGFloat(xLabels.count)
        lineChart.x.labels.values = xLabels
        lineChart.y.labels.visible = true
        lineChart.addLine(data)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.delegate = self
        
        for subview in self.chartV.subviews {
            subview.removeFromSuperview()
        }
        self.chartV.addSubview(lineChart)
        
        lineChart.topAnchor.constraint(equalTo: chartV.topAnchor).isActive = true
        lineChart.bottomAnchor.constraint(equalTo: chartV.bottomAnchor).isActive = true
        lineChart.leadingAnchor.constraint(equalTo: chartV.leadingAnchor).isActive = true
        lineChart.trailingAnchor.constraint(equalTo: chartV.trailingAnchor).isActive = true

    }
    
    func loadCollectionValue(completion: @escaping(()->Void)) {
        
        let to = Date()
        let from = Calendar.current.date(byAdding: .day, value: -100, to: to)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let logTo = formatter.string(from: to)
        let logFrom = formatter.string(from: from!)

    
        let device = Global.devices[selectedDevice]
        let property = resource.properties[selectedProperty]

        IoTMakerSdk.getResourceLogCollect(token: Global.token, targetId: device.target.id, deviceId: device.id, resourceId: resource.id, createdFrom: logFrom, createdTo: logTo, serviceCode: device.model.serviceCode, offset: 0, limit: 100) { (response, error) in
            if let response = response {
                self.logs = []
                for i in 0 ..< response.count {
                    guard let occurrenceDate = response[i]["occurrenceDate"] as? String else {
                        continue
                    }
                    
                    if let properties = response[i]["properties"] as? [String: Any] {
                        print(properties)
                        guard let value = properties[property.id] else {
                            continue
                        }
                        
                        self.logs.append((String(describing: value), occurrenceDate))
                    }
                }
                
                self.groupingLogs()
                completion()
            } else {
                completion()
           }
        }
    }
    
    func getDateKey(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KO")
        formatter.dateFormat = "yyyy-MM-dd(EEEE)"
        let key = formatter.string(from: date)
        return key
    }
    
    func groupingLogs() {
        logs.sort { (log1, log2) -> Bool in
            return log1.1 > log2.1
        }
        
        groupedLogs = []
        
        for i in 0 ..< logs.count {
            let log = logs[i]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let date = formatter.date(from: log.1)!
            
            let key = getDateKey(date: date)
            
            let strs = log.1.split(separator: " ")
            if strs.count != 2 {
                continue
            }
            
            let time = String(strs[1])
            
            if !groupedLogs.contains(where: { (g) -> Bool in
                return key == g.0
            }) {
                groupedLogs.append((key, [(log.0, time)]))
            } else {
                groupedLogs[groupedLogs.count-1].1.append((log.0, time))
            }
        }
        
        self.logTV.reloadData()
    }
    
    @IBAction func onBtnTab(_ sender: UIButton) {
        let tag = sender.tag
        UIView.animate(withDuration: 0.3) {
            self.contentScrollV.contentOffset = CGPoint(x: self.view.frame.width * CGFloat(tag), y: 0)
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DeviceCollectVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedLogs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedLogs[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventLogCVC", for: indexPath) as! EventLogCVC
        let log = groupedLogs[indexPath.section].1[indexPath.row]
        cell.nameLbl.text = log.0
        cell.timeLbl.text = log.1
        
        cell.iconIV.image = deviceImg
        if indexPath.row == groupedLogs[indexPath.section].1.count-1 {
            cell.seperatorLeading.constant = 0
        } else {
            cell.seperatorLeading.constant = 44
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 55))
        headerView.backgroundColor = #colorLiteral(red: 0.3411764706, green: 0.2666666667, blue: 0.2156862745, alpha: 1)
                
        let label = UILabel()
        headerView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        label.text = groupedLogs[section].0
        label.font = .systemFont(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.9960784314, green: 0.9725490196, blue: 0.8784313725, alpha: 1)
        
        return headerView
    }
}

extension DeviceCollectVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        self.tabLineLeading.constant = offset.x/2
        if round(offset.x/self.view.frame.width) == 0 {
            tabListBtn.titleLabel?.font = UIFont(name: "NotoSansKR-Bold", size: 22)
            tabChartBtn.titleLabel?.font = UIFont(name: "NotoSansKR-Regular", size: 22)
        } else {
            tabChartBtn.titleLabel?.font = UIFont(name: "NotoSansKR-Bold", size: 22)
            tabListBtn.titleLabel?.font = UIFont(name: "NotoSansKR-Regular", size: 22)
        }
        self.view.layoutIfNeeded()
    }
}

extension DeviceCollectVC: LineChartDelegate {
    func didSelectDataPoint(_ x: CGFloat, yValues: [CGFloat]) {
        print(x, yValues)
    }
}
