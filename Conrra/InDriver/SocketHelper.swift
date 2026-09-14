//
//  SocketHelper.swift
//  InDriver
//
//  Created by Grepix on 03/07/21.
//  Copyright © 2021 Grepixit. All rights reserved.
//

import UIKit

//
//  SocketHelperSwift.swift
//  InDriver
//
//  Created by Grepix on 03/07/21.
//  Copyright © 2021 Grepixit. All rights reserved.
//

import UIKit

@objcMembers open class SocketHelper: NSObject {
    var socketManager:SocketManager?
    var socket:SocketIOClient?
    override init() {
        super.init()
        socketManager = SocketManager(socketURL: URL(string: SOCKET)!, config: [.log(true), .compress])
        socket = socketManager?.defaultSocket
        addObserver()
    }
    
    open func isConnected()->Bool{
        return socket?.status == SocketIOStatus.connected
    }
  open  func addObserver() {
        socket?.on(clientEvent: .connect, callback: { (data, ack) in
//            self.addUser(sid: "")
        })
    }
    func addUser(sid:String){
        if let userDict = UserDefaults.standard.object(forKey: P_USER_DICT) as? NSDictionary{
//            let user_id = userDict.object(forKey: P_USER_ID)as! String
            let fname = userDict.object(forKey: P_FNAME) as! String
            let lname = userDict.object(forKey: P_LNAME)as! String
            let dict = NSMutableDictionary.init()
            dict.setObject("223", forKey: "user_id" as NSCopying)
            dict.setObject("\(fname) \(lname)", forKey: "name" as NSCopying)
            self.socket?.emit("add_user", dict, completion: {
                
            })
        }
    }
        
    
    open  func sendOffer(trip:TripModel, offerAmt:String ,data:NSDictionary) {
        let dict = NSMutableDictionary.init()
        dict.setObject("\(trip.user.userId)", forKey: "user_id" as NSCopying)
        
        
        if let token = trip.user.deviceToken {
            if let deviceType = trip.user.deviceType, deviceType == IOS {
                dict.setObject("\(token)", forKey: IOS_TOKEN as NSCopying)
            }else{
                dict.setObject("\(token)", forKey: ANDROID_TOKEN as NSCopying)
            }
        }else{
            dict.setObject("", forKey: ANDROID_TOKEN as NSCopying)
        }
        
        
        let payload = NSMutableDictionary.init()
        let notification = NSMutableDictionary.init()
        notification.setObject(
            "You received an offer from a driver", forKey: "body" as NSCopying)
        notification.setObject(
            "", forKey: "title" as NSCopying)
        
        //payload.setObject(notification, forKey:"notification" as NSCopying)

        if let token = trip.user.deviceToken {
            payload.setObject("\(token)", forKey: IOS_TOKEN as NSCopying)
        }else {
            payload.setObject("", forKey: IOS_TOKEN as NSCopying)
        }
    
        payload.setObject(
            "You received an offer from a driver", forKey: "message" as NSCopying)
        payload.setObject(
            "\(trip.trip_Id!)", forKey: "trip_id" as NSCopying)
        payload.setObject("offer", forKey:"trip_status" as NSCopying)
        payload.setObject(data, forKey:"data" as NSCopying)
        
        
        dict.setObject(payload, forKey: "payload" as NSCopying)
         print(dict)
        self.socket?.emit("fcm_push_noti", dict, completion: {
            self.socket?.disconnect()
        })
    }
    
    open  func sendOfferStatus(tripOffer:TripOffer,status:String,data:NSDictionary) {
        let dict = NSMutableDictionary.init()
        dict.setObject("\(tripOffer.driver!.driverId!)", forKey: "driver_id" as NSCopying)
        dict.setObject("driver", forKey: "to" as NSCopying)
        
        
        if let token = tripOffer.driver!.deviceToken {
            if let deviceType = tripOffer.driver!.deviceType, deviceType == IOS {
                dict.setObject("\(token)", forKey: IOS_TOKEN as NSCopying)
            }else{
                dict.setObject("\(token)", forKey: ANDROID_TOKEN as NSCopying)
            }
        }else{
            dict.setObject("", forKey: ANDROID_TOKEN as NSCopying)
        }
        
        
        let payload = NSMutableDictionary.init()
        let notification = NSMutableDictionary.init()
        notification.setObject(
            "", forKey: "body" as NSCopying)
        notification.setObject(
            "", forKey: "title" as NSCopying)
        
        //payload.setObject(notification, forKey:"notification" as NSCopying)

        if let token = tripOffer.driver!.deviceToken {
            payload.setObject("\(token)", forKey: IOS_TOKEN as NSCopying)
        }else {
            payload.setObject("", forKey: IOS_TOKEN as NSCopying)
        }
    
        payload.setObject(
            " ", forKey: "message" as NSCopying)
        payload.setObject(
            "\(tripOffer.trip_id!)", forKey: "trip_id" as NSCopying)
        payload.setObject(status, forKey:"trip_status" as NSCopying)
        payload.setObject(data, forKey:"data" as NSCopying)
        dict.setObject(payload, forKey: "payload" as NSCopying)
         print(dict)
        self.socket?.emit("fcm_push_noti", dict, completion: {
//            self.socket?.disconnect()
        })
    }
    
    open  func connect() {
        if !isConnected(){
        socket?.connect()
        }
    }
    open  func disconnect() {
        socket?.disconnect()
    }
    
    deinit {
        socket?.disconnect()
        socketManager = nil
    }
}
