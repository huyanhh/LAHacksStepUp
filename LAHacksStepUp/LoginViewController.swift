//
//  ViewController.swift
//  LAHacksStepUp
//
//  Created by Huyanh Hoang on 2016. 4. 30..
//  Copyright © 2016년 LAHacksTeam. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import Bolts
import OAuthSwift

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBAction func fitbitPressed() {
        doAuthService("Fitbit2")
    }
    
    var jsonDict: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserverForName("Authenticated", object: nil, queue: nil) { (NSNotification) in
            self.performSegueWithIdentifier("Authenticated", sender: self)
        }
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in, do work such as go to next view controller.
        } else {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            //self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        
        initConf()
        
        // init now
        get_url_handler()
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil) {
            // Process error
        } else if result.isCancelled {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? DashboardViewController {
            vc.jsonDict = jsonDict
        }
    }
}

extension LoginViewController {
    
    func doAuthService(service: String) {
        
        guard var parameters = services[service] else {
            showAlertView("Miss configuration", message: "\(service) not configured")
            return
        }
        
        if Services.parametersEmpty(parameters) { // no value to set
            let message = "\(service) seems to have not weel configured. \nPlease fill consumer key and secret into configuration file \(self.confPath)"
            print(message)
            showAlertView("Miss configuration", message: message)
            // TODO here ask for parameters instead
        }
        
        parameters["name"] = service
        
        switch service {
        
        case "Fitbit2":
            doOAuthFitbit2(parameters)
        
        default:
            print("\(service) not implemented")
        }
    }
    
    func doOAuthFitbit2(serviceParameters: [String:String]) {
        let oauthswift = OAuth2Swift(
            consumerKey:    serviceParameters["consumerKey"]!,
            consumerSecret: serviceParameters["consumerSecret"]!,
            authorizeUrl:   "https://www.fitbit.com/oauth2/authorize",
            accessTokenUrl: "https://api.fitbit.com/oauth2/token",
            responseType:   "code"
        )
        oauthswift.authorize_url_handler = SafariURLHandler(viewController: self)
        oauthswift.accessTokenBasicAuthentification = true
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: "paso://oauth-callback")!, scope: "profile activity", state: state, success: {
            credential, response, parameters in
            //self.showTokenAlert(serviceParameters["name"], credential: credential)
            self.testFitbit2(oauthswift)
            
            }, failure: { error in
                print(error.localizedDescription)
        })
    }
    
    func testFitbit2(oauthswift: OAuth2Swift) {
        oauthswift.client.get("https://api.fitbit.com/1/user/-/activities/date/today.json", parameters: [:], success: {
                                data, response in
                                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                                self.jsonDict = jsonDict
                                print("viewController json", self.jsonDict)
                                self.performSegueWithIdentifier("Authenticated", sender: self)

            }, failure: { error in
                print(error.localizedDescription)
        })
    }
}

let services = Services()
let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
let FileManager: NSFileManager = NSFileManager.defaultManager()

extension LoginViewController {
    // MARK: utility methods
    
    var confPath: String {
        let appPath = "\(DocumentDirectory)/.oauth/"
        if !FileManager.fileExistsAtPath(appPath) {
            do {
                try FileManager.createDirectoryAtPath(appPath, withIntermediateDirectories: false, attributes: nil)
            }catch {
                print("Failed to create \(appPath)")
            }
        }
        return "\(appPath)Services.plist"
    }
    
    func initConf() {
        initConfOld()
        print("Load configuration from \n\(self.confPath)")
        
        // Load config from model file
        if let path = NSBundle.mainBundle().pathForResource("Services", ofType: "plist") {
            services.loadFromFile(path)
            
            if !FileManager.fileExistsAtPath(confPath) {
                do {
                    try FileManager.copyItemAtPath(path, toPath: confPath)
                }catch {
                    print("Failed to copy empty conf to\(confPath)")
                }
            }
        }
        services.loadFromFile(confPath)
    }
    
    func initConfOld() {

        services["Fitbit"] = Fitbit

    }
    
    func snapshot() -> NSData {

            UIGraphicsBeginImageContext(self.view.frame.size)
            self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let fullScreenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(fullScreenshot, nil, nil, nil)
            return  UIImageJPEGRepresentation(fullScreenshot, 0.5)!

    }
    
    func showAlertView(title: String, message: String) {

            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauth_token)"
        if !credential.oauth_token_secret.isEmpty {
            message += "\n\noauth_toke_secret:\(credential.oauth_token_secret)"
        }
        self.showAlertView(name ?? "Service", message: message)
        
        if let service = name {
            services.updateService(service, dico: ["authentified":"1"])
            // TODO refresh graphic
        }
    }
    
    // MARK: create an optionnal internal web view to handle connection
    func createWebViewController() -> WebViewController {
        let controller = WebViewController()
        return controller
    }
    
    func get_url_handler() -> OAuthSwiftURLHandlerType {
        // Create a WebViewController with default behaviour from OAuthWebViewController
        let url_handler = createWebViewController()

        return url_handler
        
    }
}
