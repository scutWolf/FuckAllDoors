//
//  XDHTTPRequestOperation.swift
//  FuckTheDoor
//
//  Created by Wolf on 15/9/5.
//  Copyright (c) 2015年 Wolf. All rights reserved.
//

import UIKit

class TDHTTPRequestOperation: NSObject {
    class func postForJSON(url:String,parameters:AnyObject?,success:(operation: AFHTTPRequestOperation,responseObject: AnyObject!)->(),failure:(operation:AFHTTPRequestOperation, error:NSError)->())->(AFHTTPRequestOperation)
    {
        
        let manager = AFHTTPRequestOperationManager()
        let serializer = AFJSONResponseSerializer()
        serializer.removesKeysWithNullValues = true
        manager.responseSerializer = serializer;
        manager.requestSerializer=AFHTTPRequestSerializer();
        
        let post:AFHTTPRequestOperation = manager.POST(url, parameters: parameters, success: success , failure: failure)!;
        
        return post
        
    }
}
