//
//  ViewController.swift
//  Runloop Monitor
//
//  Created by Sailer Guo on 2020/12/29.
//

import UIKit

class ViewController: UIViewController {

    var tableView: UITableView {
        get {
            let tab = UITableView(frame: self.view.bounds, style: .grouped )
            tab.delegate = self
            tab.dataSource = self
            tab.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
            return tab
        }
    }
    
    var dataArr:[String] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        RunloopMonitor.shared.beginMonitor()
        
        self.view.addSubview(self.tableView)
        
        var i = 0
        while i < 100 {
            i += 1
            self.dataArr.append("\(i) cell")
        }
        self.tableView.reloadData()
    }


}

extension ViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = self.dataArr[indexPath.row]
        return cell
    }
    
}
