//
//  ViewController.swift
//  CustomRefreshControl
//
//  Created by huangxu on 2017/8/30.
//  Copyright © 2017年 huangxu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: HXRefreshControl = HXRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)

        loadData()
    }
    
    func loadData() {
        print("loadData()开始刷新")
        
        refreshControl.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
            self.refreshControl.endRefreshing()
            self.refreshControl.endRefreshing()
            print("oadData()结束刷新")
        }
    }
}

