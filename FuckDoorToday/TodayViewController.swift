//
//  TodayViewController.swift
//  FuckDoorToday
//
//  Created by Wolf on 15/9/5.
//  Copyright (c) 2015年 Wolf. All rights reserved.
//

import UIKit
import NotificationCenter

enum Door{

    case Front
    case Back
    case Lobby
    case Underground
    
    var doorID:String{
        get {
            switch self{
            case .Front:
                return "01"
            case .Back:
                return "02"
            case .Lobby:
                return "0550"
            case .Underground:
                return "0551"
            }
        }
    }
    
    var doorDescription:String{
        get {
            switch self{
            case .Front:
                return "正门"
            case .Back:
                return "后门"
            case .Lobby:
                return "大堂"
            case .Underground:
                return "负一"
            }
        }
    
    }
}

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var token:String?
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var frontDoorButton: UIButton!
    @IBOutlet var backDoorButton: UIButton!
    @IBOutlet var lobbyButton: UIButton!
    @IBOutlet var undergroundButton: UIButton!
    
    
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
                
                print(jsonDict)
                
                if let data = jsonDict["data"] as? NSDictionary{
                    if let token = data["accessToken"] as? String {
                        print("token:"+token)
                        self.token = token
                        self.statusLabel.text = "登录成功"

                        todo()
                    }
                    
                }
                
            }
            
            }) { (operation, error) -> () in
                print("error:\(error.description)")
                self.statusLabel.text = "登录失败:\(error.description)"
        }
        //
    }
    
    
    
    @IBAction func openDoorButtonPressed(sender: UIButton) {
        
        var door:Door?
        
        switch sender{
        case self.frontDoorButton:
            door = Door.Front
        case self.backDoorButton:
            door = Door.Back
        case self.lobbyButton:
            door = Door.Lobby
        case self.undergroundButton:
            door = Door.Underground
        default:
            door = nil
        }
        
        if (door != nil){
            if (self.token != nil){
                self.fuckDoor(door!, token: token!)
            }
            else{
                self.login({ () -> () in
                    self.fuckDoor(door!, token: self.token!)
                })
            }
        }
    }
    
    
    func fuckAll(token:String){
        
        
        self.fuckDoor(Door.Front, token: token)
        self.fuckDoor(Door.Back, token: token)
        self.fuckDoor(Door.Lobby, token: token)
        self.fuckDoor(Door.Underground, token: token)        
    
    }
    
    
    func fuckDoor(door:Door,token:String){
        
        let manager = AFHTTPRequestOperationManager()
        let serializer = AFJSONResponseSerializer()
        serializer.removesKeysWithNullValues = true
        manager.responseSerializer = serializer;
        manager.requestSerializer=AFHTTPRequestSerializer();
        manager.requestSerializer.setValue(token, forHTTPHeaderField: "token")

        let doorID = door.doorID
        let doorDescription = door.doorDescription
        
        manager.POST("http://www.uhomecp.com/door/openDoor.json?", parameters: ["communityId":"385","doorIdStr":doorID], success: { (operation, responseObject) -> Void in
            
            print("open \(doorDescription) successfully")

            
            self.statusLabel.text = "打开\(doorDescription)大门成功"
            
            }) { (operation:AFHTTPRequestOperation, error:NSError) -> Void in
                
                print("open \(door.doorDescription) failurefully")
                self.statusLabel.text = "打开大门失败,尝试重新登录"
    
                self.login({ () -> () in
                    self.statusLabel.text = "重新登录成功,请重新操作"
                })
        }

        
        
    }
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
