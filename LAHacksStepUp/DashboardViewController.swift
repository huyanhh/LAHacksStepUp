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
    
    var urlString: String!
    
    var crapDictionary: [[String:String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlString = "https://api.fitbit.com/1/user/-/activities/steps/date/today/1m.json"
        
        if let url = NSURL(string: urlString) {
            if let data = try? NSData(contentsOfURL: url, options: []) {
                let json = JSON(data: data)
                print(json)
                //parseJSON(json)
            }
        }
        
    }

    func parseJSON(json: JSON) {
        for result in json["activities"].arrayValue {
            let distance = result["distance"].stringValue
            let logid = result["logId"].stringValue
            let steps = result["steps"].stringValue
            let obj = ["distance": distance, "logid": logid, "steps": steps]
            crapDictionary.append(obj)
        }
        print(crapDictionary)
        
        //stepCount.text = crapDictionary
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
