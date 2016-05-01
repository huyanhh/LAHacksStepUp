//
//  ProgressViewController.swift
//  LAHacksStepUp
//
//  Created by Huyanh Hoang on 2016. 4. 30..
//  Copyright © 2016년 LAHacksTeam. All rights reserved.
//

import UIKit
import OAuthSwift

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var stepCount: UILabel!
    
    @IBAction func goalReached() {
        stepCount.text = "10,000!!!!!!!!!!"
        stepCount.textColor = UIColor(red: 93/255.0, green: 188/255.0, blue: 210/255.0, alpha: 1)
        
        let alert = UIAlertController(title: "Congratulations!", message: "You've reached your goal! 50 cents was donated to the charity of your choice.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Yay!", style: .Cancel) { UIAlertAction in
            self.stepCount.text = self.currentSteps})
        presentViewController(alert, animated: true, completion: nil)
    }
    
    var jsonDict: AnyObject!
    var currentSteps: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sponsors = storyboard!.instantiateViewControllerWithIdentifier("Sponsors") as! SponsorViewController
        sponsors.view.backgroundColor = UIColor.clearColor()
        sponsors.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        presentViewController(sponsors, animated: true, completion: nil)

        currentSteps = "\((jsonDict["summary"]!!["steps"]!)!)"
        stepCount.text = currentSteps
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesBackButton = true

        // Tint colors
        navigationController?.navigationBar.barTintColor = UIColor(red: 93/255.0, green: 188/255.0, blue: 210/255.0, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        // Shadow
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
    }
    
    func retrieveData(oauthswift: OAuth2Swift) {
        oauthswift.client.get("https://api.fitbit.com/1/user/-/activities/date/today.json", parameters: [:], success: {
            data, response in
            let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            self.jsonDict = jsonDict
            
            }, failure: { error in
                print(error.localizedDescription)
        })
    }
}
