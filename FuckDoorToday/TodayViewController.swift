//
//  TodayViewController.swift
//  FuckDoorToday
//
//  Created by Wolf on 15/9/5.
//  Copyright (c) 2015年 Wolf. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.preferredContentSize = CGSizeMake(200, 60)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func fuckAllTheDoor(sender: AnyObject) {
        
        println("tap w")
        
        TDHTTPRequestOperation.postForJSON("http://www.uhomecp.com/userInfo/login.json", parameters: ["tel":"18520200580","version":"4.0","password":"38213521"], success: { (operation, responseObject) -> () in
            
            if let jsonDict = responseObject as? NSDictionary{
                
                println(jsonDict)
                
                if let data = jsonDict["data"] as? NSDictionary{
                    if let token = data["accessToken"] as? String {
                        println("token:"+token)
                        self.fuckAll(token)
                    }
                    
                }
                
            }
            
        }) { (operation, error) -> () in
            println("error:\(error.description)")
        }
//
    }
    
    func fuckAll(token:String){
        
        
        self.fuckDoor("01", token: token)
        self.fuckDoor("02", token: token)
        self.fuckDoor("0551", token: token)
        self.fuckDoor("0550", token: token)

    
    }
    
    func fuckDoor(door:String,token:String){
        
        var manager = AFHTTPRequestOperationManager()
        var serializer = AFJSONResponseSerializer()
        serializer.removesKeysWithNullValues = true
        manager.responseSerializer = serializer;
        manager.requestSerializer=AFHTTPRequestSerializer();
        manager.requestSerializer.setValue(token, forHTTPHeaderField: "token")

        
        
        manager.POST("http://www.uhomecp.com/door/openDoor.json?", parameters: ["communityId":"385","doorIdStr":door], success: { (operation, responseObject) -> Void in
            
            println("open \(door) successfully")
            
            }) { (operation:AFHTTPRequestOperation, error:NSError) -> Void in
                
            println("open \(door) failurefully")

        }

        
        
    }
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
