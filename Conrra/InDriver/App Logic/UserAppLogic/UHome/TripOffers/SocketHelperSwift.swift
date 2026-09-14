//
//  SocketHelperSwift.swift
//  InDriver
//
//  Created by Grepix on 03/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit

@objcMembers class SocketHelperSwift: NSObject {
    var socketManager:SocketManager?
    var socket:SocketIOClient?
    override init() {
        super.init()
//        socketManager = SocketManager(socketURL: URL(string: SOCKET)!, config: [.log(true), .compress])
//        socket = socketManager?.defaultSocket
//        addObserver()
    }
    var mySound: SystemSoundID = 0
    func addObserver() {
        
        socket?.on(clientEvent: .connect, callback: { (data, ack) in
            if data.count > 1{
                if  let sData  = data[1] as?[String:Any] {
                    if let sid = sData["sid"]  {
                        self.addUser(sid: sid as! String)
                    }
                }
            }
        })
        socket?.on("fcm_push_noti", callback: { (data, ack) in
            let userInfo = NSMutableDictionary.init()
            let aps = NSMutableDictionary.init()
            var isHasData = false
            if let payload =  data.first as? [String:Any] {
                if let message =  payload["message"] {
                    isHasData = true
                    aps.setObject(message, forKey: "alert" as NSCopying)
                }
                if let data =  payload["data"] as? NSDictionary {
                    isHasData = true
                    aps.setObject(data, forKey: "data" as NSCopying)
                }
                if let trip_status =  payload["trip_status"] as? NSString {
                    isHasData = true
                    aps.setObject(trip_status, forKey: "trip_status" as NSCopying)
                }
            }
            userInfo.setObject(aps, forKey: "aps" as NSCopying)
            print("User Inf Push  \(userInfo)")
            if isHasData {
                if let soundURL = Bundle.main.url(forResource: "Alert", withExtension: "mp3") {
                    AudioServicesCreateSystemSoundID(soundURL as CFURL, &self.mySound)
                    AudioServicesPlaySystemSound(self.mySound);
                }
                let name = Notification.Name(AppNotificationName.USER_OFFER_NOTIFICATION)
                NotificationCenter.default.post(name:name, object: nil, userInfo: userInfo as! [AnyHashable : Any])
            }
        })
        socket?.onAny({ (event) in
            print(event)
        })
    }
    
    func addUser(sid:String){
        
        let is_user_login = UserDefaults.standard.bool(forKey: P_IS_USER_LOGIN)
        if(is_user_login){
            if let userDict = UserDefaults.standard.object(forKey: P_USER_DICT_LOGGED) as? NSDictionary{
                if let user_id = userDict.object(forKey: P_USER_ID)as? String {
                    let fname = userDict.object(forKey: P_U_FNAME) as! String
                    let lname = userDict.object(forKey: P_U_LNAME)as! String
                    let dict = NSMutableDictionary.init()
                    dict.setObject(user_id, forKey: "user_id" as NSCopying)
                    dict.setObject("\(fname) \(lname)", forKey: "name" as NSCopying)
                    dict.setObject(String.init(format: "%ld", Utilities.getTimeStampGMT()), forKey: "e" as NSCopying)
                    let encrypted = AesEncrypt.aesEncrypt(string: Utilities.dictOrArray(toJosnString: dict))!
                    let dictFinal = NSMutableDictionary.init()
                    dictFinal.setObject(encrypted, forKey: "req" as NSCopying)
                    self.socket?.emit("add_user", dictFinal, completion: {
                        
                    })
                }
            }
        }else{
            if let userDict = UserDefaults.standard.object(forKey: P_USER_DICT) as? NSDictionary{
                if let driver_id = userDict.object(forKey: P_DRIVER_ID)as? String {
                    let fname = userDict.object(forKey: P_FNAME) as! String
                    let lname = userDict.object(forKey: P_LNAME)as! String
                    let dict = NSMutableDictionary.init()
                    dict.setObject(driver_id, forKey: P_DRIVER_ID as NSCopying)
                    dict.setObject("\(fname) \(lname)", forKey: "name" as NSCopying)
                    dict.setObject(String.init(format: "%ld", Utilities.getTimeStampGMT()), forKey: "e" as NSCopying)
                    let encrypted = AesEncrypt.aesEncrypt(string: Utilities.dictOrArray(toJosnString: dict))!
                    let dictFinal = NSMutableDictionary.init()
                    dictFinal.setObject(encrypted, forKey: "req" as NSCopying)
                    self.socket?.emit("add_driver", dictFinal, completion: {
                        
                    })
                }
            }
        }
    }
    
    
    open func connect() {
        if !isConnected() {
            socketManager = SocketManager(socketURL: URL(string: SOCKET)!, config: [.log(true), .compress])
            socket = socketManager?.defaultSocket
            addObserver()
            socket?.connect()
        }
    }
    
    open func disconnect() {
        socket?.disconnect()
        socket = nil
        socketManager=nil
    }
    deinit {
        socket?.disconnect()
        socketManager = nil
    }
    
    open func isConnected()->Bool{
        return socket?.status == SocketIOStatus.connected
    }
    
    open  func sendOfferToDriver(trip:TripModel ,data:NSDictionary) {
        self.sendOfferToDriver(trip: trip, status: nil, data: data)
    }
    
    open  func sendOfferToDriver(trip:TripModel,status:String?,data:NSDictionary) {
        let dict = NSMutableDictionary.init()
        // otter params
        dict.setObject("\(trip.driver!.driverId!)", forKey: "driver_id" as NSCopying)
        
        // driver token
        if let token = trip.driver.deviceToken {
            if let deviceType = trip.driver.deviceType, deviceType == IOS {
                dict.setObject("\(token)", forKey: IOS_TOKEN as NSCopying)
            }else{
                dict.setObject("\(token)", forKey: ANDROID_TOKEN as NSCopying)
            }
        }else{
            dict.setObject("", forKey: ANDROID_TOKEN as NSCopying)
        }
        
        // Payload
        let payload = NSMutableDictionary.init()
        payload.setObject("driver", forKey: "to" as NSCopying)
        // trip id
        payload.setObject(
            "\(trip.trip_Id!)", forKey: "trip_id" as NSCopying)
        // trip status
        // If status is nil then send the default statu "offer" otherwise put the status
        if let statusTemp = status {
            payload.setObject(statusTemp, forKey:"trip_status" as NSCopying)
            payload.setObject(" ", forKey: "message" as NSCopying)
        }else{
            
            payload.setObject("offer", forKey:"trip_status" as NSCopying)
            // message
            payload.setObject(
                LanguageHelper.sharedInstance().getStringWithKey("k_2_s14_trip_offer", currentLanguage: trip.driver!.d_lang ), forKey: "message" as NSCopying)
        }
        // data
        payload.setObject(data, forKey:"data" as NSCopying)
        // payload
        dict.setObject(payload, forKey: "payload" as NSCopying)
        
        dict.setObject(String.init(format: "%ld", Utilities.getTimeStampGMT()), forKey: "e" as NSCopying)
        let encrypted = AesEncrypt.aesEncrypt(string: Utilities.dictOrArray(toJosnString: dict))!
                           let dictFinal = NSMutableDictionary.init()
                           dictFinal.setObject(encrypted, forKey: "req" as NSCopying)
        print("sendOfferToDriver :  \(dict)")
        self.socket?.emit("fcm_push_noti", dictFinal, completion: {
            
        })
    }
    
    open  func sendOfferToDriverTripOffer(tripOffer:TripOffer,status:String?,data:NSDictionary) {
        let dict = NSMutableDictionary.init()
        // otter params
        dict.setObject("\(tripOffer.driver!.driverId!)", forKey: "driver_id" as NSCopying)
        
        // driver token
        if let token = tripOffer.driver!.deviceToken {
            if let deviceType = tripOffer.driver!.deviceType, deviceType == IOS {
                dict.setObject("\(token)", forKey: IOS_TOKEN as NSCopying)
            }else{
                dict.setObject("\(token)", forKey: ANDROID_TOKEN as NSCopying)
            }
        }else{
            dict.setObject("", forKey: ANDROID_TOKEN as NSCopying)
        }
        
        // Payload
        let payload = NSMutableDictionary.init()
        // message
       
        // trip id
        payload.setObject(
            "\(tripOffer.trip_id!)", forKey: "trip_id" as NSCopying)
        payload.setObject("driver", forKey: "to" as NSCopying)
        // trip status
        // If status is nil then send the default statu "offer" otherwise put the status
        if let statusTemp = status {
            payload.setObject(statusTemp, forKey:"trip_status" as NSCopying)
            payload.setObject(" ", forKey: "message" as NSCopying)
        }else{
            
            payload.setObject(
                LanguageHelper.sharedInstance().getStringWithKey("k_2_s14_trip_offer", currentLanguage: tripOffer.driver!.d_lang ), forKey: "message" as NSCopying)
            payload.setObject("offer", forKey:"trip_status" as NSCopying)
        }
        // data
        payload.setObject(data, forKey:"data" as NSCopying)
        // payload
        dict.setObject(payload, forKey: "payload" as NSCopying)
       
        dict.setObject(String.init(format: "%ld", Utilities.getTimeStampGMT()), forKey: "e" as NSCopying)
        let encrypted = AesEncrypt.aesEncrypt(string: Utilities.dictOrArray(toJosnString: dict))!
        let dictFinal = NSMutableDictionary.init()
        dictFinal.setObject(encrypted, forKey: "req" as NSCopying)
        print("sendOfferToDriver :  \(dict)")
        self.socket?.emit("fcm_push_noti", dictFinal, completion: {
            
        })
    }
    
    open  func sendOfferToUser(trip:TripModel ,data:NSDictionary) {
        self.sendOfferToUser(trip: trip, status: nil, data: data)
    }
    
    open  func sendOfferToUser(trip:TripModel, status:String? ,data:NSDictionary) {
        let dict = NSMutableDictionary.init()
        dict.setObject("\(trip.user.userId)", forKey: "user_id" as NSCopying)
        
        // device token
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
        
        payload.setObject("user", forKey: "to" as NSCopying)
        payload.setObject(
            "\(trip.trip_Id!)", forKey: "trip_id" as NSCopying)
        // trip_status
        if let statusTemp = status {
            payload.setObject(statusTemp, forKey:"trip_status" as NSCopying)
            payload.setObject(" ", forKey: "message" as NSCopying)
        }else{
            payload.setObject("offer", forKey:"trip_status" as NSCopying)
            payload.setObject(
                LanguageHelper.getStringWithKey("k_2_s14_trip_offer", defaultValue: ""), forKey: "message" as NSCopying)
        }
        payload.setObject(data, forKey:"data" as NSCopying)
        
        // Payload
        dict.setObject(payload, forKey: "payload" as NSCopying)
        dict.setObject(String.init(format: "%ld", Utilities.getTimeStampGMT()), forKey: "e" as NSCopying)
        let encrypted = AesEncrypt.aesEncrypt(string: Utilities.dictOrArray(toJosnString: dict))!
        let dictFinal = NSMutableDictionary.init()
        dictFinal.setObject(encrypted, forKey: "req" as NSCopying)
        print("sendOfferToUser :  \(dict)")
        self.socket?.emit("fcm_push_noti", dictFinal, completion: {
            
        })
    }
    
    

    
    open  func sendOfferStatus(tripOffer:TripOffer,status:String,data:NSDictionary) {
        let dict = NSMutableDictionary.init()
        dict.setObject("\(tripOffer.driver!.driverId!)", forKey: "driver_id" as NSCopying)
        
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
        payload.setObject("driver", forKey: "to" as NSCopying)
        payload.setObject(
            " ", forKey: "message" as NSCopying)
        payload.setObject(
            "\(tripOffer.trip_id!)", forKey: "trip_id" as NSCopying)
        payload.setObject(status, forKey:"trip_status" as NSCopying)
        
        payload.setObject(data, forKey:"data" as NSCopying)
        dict.setObject(payload, forKey: "payload" as NSCopying)
        dict.setObject(String.init(format: "%ld", Utilities.getTimeStampGMT()), forKey: "e" as NSCopying)
        let encrypted = AesEncrypt.aesEncrypt(string: Utilities.dictOrArray(toJosnString: dict))!
        let dictFinal = NSMutableDictionary.init()
        dictFinal.setObject(encrypted, forKey: "req" as NSCopying)
        print("sendOfferStatus : \(dict)")
        self.socket?.emit("fcm_push_noti", dictFinal, completion: {
            //            self.socket?.disconnect()
        })
    }
    
}

