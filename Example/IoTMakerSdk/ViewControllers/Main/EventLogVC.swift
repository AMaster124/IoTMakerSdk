//
//  EventLogVC.swift
//  demoapp
//
//  Created by Coding on 06.03.21.
//

import UIKit
import IoTMakerSdk

class EventLogVC: UIViewController {
    @IBOutlet weak var logTV: UITableView!
    
    var events = [EventModel]()
    var logs = [(String, String, String?)]()

    var groupedLogs = [(String, [(String, String, String?)])]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logTV.delegate = self
        logTV.dataSource = self
        
        DispatchQueue.main.async {
            MyLoadingVC.show()
            self.loadEvents {
                self.logs = []
                self.loadEventLog(index: 0) {
                    MyLoadingVC.hide()
                    self.groupingLogs()
                }
            }
        }
    }
    
    func loadEvents(completion: @escaping(()->Void)) {
        let device = Global.devices[0]
        IoTMakerSdk.getEventList(token: Global.token, targetId: device.target.id) { (list, error) in
            if let list = list {
                self.events = list
            } else {
                MyAlertVC.show(message: error ?? "Server Error", isConfirm: false) {
                    MyLoadingVC.hide()
                }
            }
            completion()
        }
    }
    
    func loadEventLog(index: Int, completion: @escaping(()->Void)) {
        if events.count < 1 || index >= events.count {
            completion()
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let to = formatter.string(from: Date())
        
        let device = Global.devices[0]
        

        IoTMakerSdk.getEventLogList(token: Global.token, targetId: device.target.id, eventId: events[index].eventId, to: to, offset: 0, limit: 50) { (logList, error) in
            if let logList = logList {
                for i in 0 ..< logList.count {
                    let event = self.events[index]
                    if event.deviceExtensions.count > 0 {
                        self.logs.append((event.eventName, logList[i].occurrenceDate, event.deviceExtensions[0].deviceId))
                    } else {
                        self.logs.append((self.events[index].eventName, logList[i].occurrenceDate, nil))
                    }
                }
            }
            
            self.loadEventLog(index: index+1, completion: completion)
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
                groupedLogs.append((key, [(log.0, time, log.2)]))
            } else {
                groupedLogs[groupedLogs.count-1].1.append((log.0, time, log.2))
            }
        }
        
        self.logTV.reloadData()
    }
    
    @IBAction func onBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EventLogVC: UITableViewDelegate, UITableViewDataSource {
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
        
        if let deviceId = log.2 {
            let device = Global.devices.first { (d) -> Bool in
                return d.id == deviceId
            }
            
            if let resId = device!.resIndex {
                cell.iconIV.image = UIImage(named: Global.ICON_LIST[resId])
            } else if let img = device!.icon {
                cell.iconIV.image = img
            } else {
                cell.iconIV.image = UIImage(named:"ic_device_default")
            }
        } else {
            cell.iconIV.image = UIImage(named:"ic_device_default")
        }
        
        if indexPath.row == groupedLogs[indexPath.section].1.count-1 {
            cell.seperatorLeading.constant = 0
        } else {
            cell.seperatorLeading.constant = 44
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
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

class EventLogCVC: UITableViewCell {
    @IBOutlet weak var iconIV: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var seperatorLeading: NSLayoutConstraint!
}
