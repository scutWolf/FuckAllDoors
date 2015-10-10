//
//  ViewController.swift
//  FuckTheDoor
//
//  Created by Wolf on 15/9/5.
//  Copyright (c) 2015年 Wolf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var token:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.token = nil
        self.login()
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(){
        
        TDHTTPRequestOperation.postForJSON("http://www.uhomecp.com/userInfo/login.json", parameters: ["tel":"18520200580","version":"4.0","password":"38213521"], success: { (operation, responseObject) -> () in
            
            if let jsonDict = responseObject as? NSDictionary{
                
                print(jsonDict)
                
                if let data = jsonDict["data"] as? NSDictionary{
                    if let token = data["accessToken"] as? String {
                        print("token:"+token)
                        self.token = token
                        
                    }
                    
                }
                
            }
            
            }) { (operation, error) -> () in
                print("error:\(error.description)")
        }
        //
    }
    
    @IBAction func openFrontDoor(sender: AnyObject) {
        if (self.token != nil){
            self.fuckDoor("01", token: token!)
        }
    }
    
    @IBAction func openBackDoor(sender: AnyObject) {
        if (self.token != nil){
            self.fuckDoor("02", token: token!)
        }
    }
    
    @IBAction func openFirstFloor(sender: AnyObject) {
        if (self.token != nil){
            self.fuckDoor("0550", token: token!)
        }
    }

    @IBAction func openUndergroundFloor(sender: AnyObject) {
        if (self.token != nil){
            self.fuckDoor("0551", token: token!)
        }
    }
    
    
    func fuckDoor(door:String,token:String){
        
        let manager = AFHTTPRequestOperationManager()
        let serializer = AFJSONResponseSerializer()
        serializer.removesKeysWithNullValues = true
        manager.responseSerializer = serializer;
        manager.requestSerializer=AFHTTPRequestSerializer();
        manager.requestSerializer.setValue(token, forHTTPHeaderField: "token")
        
        
        
        manager.POST("http://www.uhomecp.com/door/openDoor.json?", parameters: ["communityId":"385","doorIdStr":door], success: { (operation, responseObject) -> Void in
            
            print("open \(door) successfully")
            
            }) { (operation:AFHTTPRequestOperation, error:NSError) -> Void in
                
                print("open \(door) failurefully")
                
        }
        
        
        
    }

}

