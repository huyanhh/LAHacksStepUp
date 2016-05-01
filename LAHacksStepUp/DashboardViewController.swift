//
//  ProgressViewController.swift
//  LAHacksStepUp
//
//  Created by Huyanh Hoang on 2016. 4. 30..
//  Copyright © 2016년 LAHacksTeam. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var stepCount: UILabel!
    
    var jsonDict: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("________________")

        stepCount.text = "\((jsonDict["summary"]!!["steps"]!)!)"
        
    }
}
