//
//  ShakeTableViewController.swift
//  FuckTheDoor
//
//  Created by Wolf on 15/10/16.
//  Copyright © 2015年 Wolf. All rights reserved.
//

import UIKit

class ShakeTableViewController: UITableViewController,CLLocationManagerDelegate {

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    var token:String?

    @IBOutlet var frontButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var lobbyButton: UIButton!
    @IBOutlet var fontLabel: UILabel!
    @IBOutlet var backLabel: UILabel!
    @IBOutlet var lobbyLabel: UILabel!
    @IBOutlet var toOpenLabel: UILabel!
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var nowLocation:CLLocation?{
    
        didSet{
            self.locationLabel.text = "当前坐标:\(nowLocation!.coordinate.latitude),\(nowLocation!.coordinate.longitude)"
            
            if let door = self.nearestDoor(){
                self.toOpenLabel.text = "会开:\(door.doorDescription)"
            }
            
        }
    }
    
    var frontLocation:[String:Double]? {
        didSet{
            self.fontLabel.text = "已记录"
        }
    }
    
    var backLocation:[String:Double]? {
        didSet{
            self.backLabel.text = "已记录"
        }
    }
    var lobbyLocation:[String:Double]? {
        didSet{
            self.lobbyLabel.text = "已记录"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if self.locationManager.respondsToSelector("requestWhenInUseAuthorization"){
            
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
        

        if let location = NSUserDefaults.standardUserDefaults().objectForKey("\(Door.Front.doorDescription)Loction") as? [String:Double]{
            self.frontLocation = location
        }
        if let location = NSUserDefaults.standardUserDefaults().objectForKey("\(Door.Back.doorDescription)Loction") as? [String:Double]{
            self.backLocation = location
        }
        if let location = NSUserDefaults.standardUserDefaults().objectForKey("\(Door.Lobby.doorDescription)Loction") as? [String:Double]{
            self.lobbyLocation = location
        }
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1)
    }

    @IBAction func saveLocation(sender: UIButton) {
        var door:Door?
        
        switch sender{
        case self.frontButton:
            door = Door.Front
        case self.backButton:
            door = Door.Back
        case self.lobbyButton:
            door = Door.Lobby
        default:
            door = nil
        }
        
        if door != nil && self.nowLocation != nil{
            self.saveDoorLocation(door!)
        }
        
    }
    
    func saveDoorLocation(door:Door){
        
        let dict = ["latitude":nowLocation!.coordinate.latitude,"longtitude":nowLocation!.coordinate.longitude]
        
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "\(door.doorDescription)Loction")
                
        switch door{
        case .Front:
//            self.fontLabel.text = string
            self.frontLocation = dict
        case .Back:
            self.backLocation = dict
        case .Lobby:
            self.lobbyLocation = dict
        default:
            break
        }
    }
    
    
    func nearestDoor()->Door?{
        if self.nowLocation == nil{
            return nil
        }
        if self.frontLocation != nil || self.backLocation != nil || self.lobbyLabel != nil {
        
            var frontDistance = MAXFLOAT
            var backDistance = MAXFLOAT
            var lobbyDistance = MAXFLOAT
            
            let nowLat = nowLocation!.coordinate.latitude
            let nowLong = nowLocation!.coordinate.longitude
            
            if self.frontLocation != nil{
                //["latitude":nowLocation!.coordinate.latitude,"longtitude":nowLocation!.coordinate.longitude]
                let latitude = self.frontLocation!["latitude"]
                let longtitude = self.frontLocation!["longtitude"]

                frontDistance = Float(pow((nowLat - latitude!), 2) + pow((nowLong - longtitude!), 2) )
                
            }
            
            if self.backLocation != nil{
                //["latitude":nowLocation!.coordinate.latitude,"longtitude":nowLocation!.coordinate.longitude]
                let latitude = self.backLocation!["latitude"]
                let longtitude = self.backLocation!["longtitude"]
                
                backDistance = Float(pow((nowLat - latitude!), 2) + pow((nowLong - longtitude!), 2) )
                
            }
            
            if self.lobbyLocation != nil{
                //["latitude":nowLocation!.coordinate.latitude,"longtitude":nowLocation!.coordinate.longitude]
                let latitude = self.lobbyLocation!["latitude"]
                let longtitude = self.lobbyLocation!["longtitude"]
                
                lobbyDistance = Float(pow((nowLat - latitude!), 2) + pow((nowLong - longtitude!), 2) )
            }
            
            if frontDistance <= backDistance && frontDistance <= lobbyDistance{
                return Door.Front
            }
            if backDistance <= frontDistance && backDistance <= lobbyDistance{
                return Door.Back
            }
            if lobbyDistance <= frontDistance && lobbyDistance <= backDistance{
                return Door.Back
            }
        }
        
        return nil
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.resignFirstResponder()
    }


    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake{
            print("shake")
            
            if let door = self.nearestDoor(){
                self.fuckDoor(door)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("update")
        
        if locations.count > 0{
            self.nowLocation = locations[0]
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
    }
 
    
    func fuckDoor(door:Door){
        
        if (self.token != nil){
            self.fuckDoor(door, token: token!)
        }
        else{
            self.login({ () -> () in
                self.fuckDoor(door, token: self.token!)
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

}





















