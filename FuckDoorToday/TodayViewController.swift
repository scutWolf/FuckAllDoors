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
    
    var token:String?
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        self.preferredContentSize = CGSizeMake(200, 125)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func fuckAllTheDoor(sender: AnyObject) {
        
//        println("tap w")
//        
//        TDHTTPRequestOperation.postForJSON("http://www.uhomecp.com/userInfo/login.json", parameters: ["tel":"18520200580","version":"4.0","password":"38213521"], success: { (operation, responseObject) -> () in
//            
//            if let jsonDict = responseObject as? NSDictionary{
//                
//                println(jsonDict)
//                
//                if let data = jsonDict["data"] as? NSDictionary{
//                    if let token = data["accessToken"] as? String {
//                        println("token:"+token)
//                        self.fuckAll(token)
//                    }
//                    
//                }
//                
//            }
//            
//        }) { (operation, error) -> () in
//            println("error:\(error.description)")
//        }
////
        if (self.token != nil){
            self.fuckAll(self.token!)
        }
        else{
            self.login({ () -> () in
                self.fuckAll(self.token!)
            })
        }
        
        
    }
    
    func login(todo:()->()){
        
        self.statusLabel.text = "正在登录"
        
        TDHTTPRequestOperation.postForJSON("http://www.uhomecp.com/userInfo/login.json", parameters: ["tel":"18520200580","version":"4.0","password":"38213521"], success: { (operation, responseObject) -> () in
            
            if let jsonDict = responseObject as? NSDictionary{
                
                println(jsonDict)
                
                if let data = jsonDict["data"] as? NSDictionary{
                    if let token = data["accessToken"] as? String {
                        println("token:"+token)
                        self.token = token
                        self.statusLabel.text = "登录成功"

                        todo()
                    }
                    
                }
                
            }
            
            }) { (operation, error) -> () in
                println("error:\(error.description)")
                self.statusLabel.text = "登录失败:\(error.description)"
        }
        //
    }
    
    @IBAction func openFrontDoor(sender: AnyObject) {
        if (self.token != nil){
            self.fuckDoor("01", token: self.token!)
        }
        else{
            self.login({ () -> () in
                self.fuckDoor("01", token: self.token!)
            })
        }
    }
    
    @IBAction func openBackDoor(sender: AnyObject) {
        if (self.token != nil){
            self.fuckDoor("02", token: self.token!)
        }
        else{
            self.login({ () -> () in
                self.fuckDoor("02", token: self.token!)
            })
        }
    }
    
    @IBAction func openFirstFloor(sender: AnyObject) {
        if (self.token != nil){
            self.fuckDoor("0550", token: self.token!)
        }
        else{
            self.login({ () -> () in
                self.fuckDoor("0550", token: self.token!)
            })
        }
    }
    
    @IBAction func openUndergroundFloor(sender: AnyObject) {
        if (self.token != nil){
            self.fuckDoor("0551", token: token!)
        }
        else{
            self.login({ () -> () in
                self.fuckDoor("0551", token: self.token!)
            })
        }
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

            var doorDescription:String
            
            switch door{
            case "01":
                doorDescription = "正门"
            case "02":
                doorDescription = "后门"
            case "0550":
                doorDescription = "大堂"
            case "0551":
                doorDescription = "负一"
            default:
                doorDescription = ""
            }
            
            
            self.statusLabel.text = "打开\(doorDescription)大门成功"
            
            }) { (operation:AFHTTPRequestOperation, error:NSError) -> Void in
                
                println("open \(door) failurefully")
                self.statusLabel.text = "打开大门失败,尝试重新登录"
    
                self.login({ () -> () in
                    self.statusLabel.text = "重新登录成功,请重新操作"
                })
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
