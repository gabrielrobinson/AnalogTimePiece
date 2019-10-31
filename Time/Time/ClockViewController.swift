//
//  ViewController.swift
//  Time
//
//  Created by Gabriel Robinson on 1/23/19.
//  Copyright © 2019 CS4530. All rights reserved.
//

import UIKit

class ClockViewController: UIViewController {
    weak var clockView: ClockView!

    override func loadView() {
        super.loadView()
        let clockView: ClockView = ClockView()
        clockView.frame = CGRect(x: 20.0, y: 20.0, width: 500, height: 550.0)
        self.view.addSubview(clockView)
        clockView.translatesAutoresizingMaskIntoConstraints = false
        let views: [String:Any] = ["view": self.view, "subview": clockView]
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:[view]-(<=1)-[subview(==400)]",
                                                      options: .alignAllCenterX,
                                                      metrics: nil,
                                                      views: views)

        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-(<=1)-[subview(==300)]",
                                                      options: .alignAllCenterY,
                                                      metrics: nil,
                                                      views: views)
        self.view.addConstraints(vertical)
        self.view.addConstraints(horizontal)
        self.clockView = clockView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clockView.backgroundColor = UIColor.black
    }
}

