//
//  TripOfferManager.swift
//  InRider
//
//  Created by Grepix on 01/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit

public class TripOfferManager: NSObject {
    var apiCancelTrip:ApiHelperObj?
    var apiUpdateTrip:ApiHelperObj?
    var apiAcceptTrip:ApiHelperObj?
    var apiGetTrip:ApiHelperObj?
    var apiUpdateOfferTrip:ApiHelperObj?
    var apiH:ApiHelperObj?
    
    public func canceTrip(trip:TripModel , completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(TS_USER_CANCEL, forKey: TRIP_STATUS as NSCopying)
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        apiCancelTrip = ApiHelperObj.init()
        apiCancelTrip!.mkwerwus(TRIP_UPDATE, d: data as! [AnyHashable : Any]) { (results, error) in
            UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            if(results==nil){
                completion(results,error as NSError? )
            }else{
                completion(results,nil as NSError? )
            }
        }
    }
    
    public func cancelAssignTrip(trip:TripModel , completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(TS_USER_CANCEL, forKey: TRIP_STATUS as NSCopying)
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        data.setObject(String(format: "%@", "1"), forKey: "is_ride_later" as NSCopying)
        data.setObject(String(format: "%@", "1"), forKey: "is_cancelled" as NSCopying)
        let dictUser =  UserDefaults.standard.object(forKey: P_USER_DICT) as! NSDictionary
        data.setObject(dictUser.object(forKey: "user_id") as! String, forKey: "user_id" as NSCopying)
        
        UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        apiCancelTrip = ApiHelperObj.init()
        apiCancelTrip!.mkwerwus(TRIP_UPDATE, d: data as! [AnyHashable : Any]) { (results, error) in
            UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            if(results==nil){
                completion(results,error as NSError? )
            }else{
                completion(results,nil as NSError? )
            }
        }
    }
    
    public func updateTrip(trip:TripModel ,status:String,isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(status, forKey: TRIP_STATUS as NSCopying)
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        if isShowLoader {
            UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        }
        apiUpdateTrip = ApiHelperObj.init()
        apiUpdateTrip!.mkwerwus( TRIP_UPDATE, d: data as! [AnyHashable : Any]) { (results, error) in
            if isShowLoader {
            UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            if(results==nil){
                completion(results,error as NSError? )
            }else{
                completion(results,nil as NSError? )
            }
        }
    }
    
    
    
    public func acceptTrip(trip:TripModel ,offerAmt:Float,driver_id:String,payment_intent_id:String?,pay_mode:String?,isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(TS_ACCEPTED, forKey: TRIP_STATUS as NSCopying)
        data.setObject(driver_id, forKey: "driver_id" as NSCopying)
        data.setObject(Utilities.getRandomPINString(5)as String, forKey: "otp" as NSCopying)
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        data.setObject(Utilities.formatAmount(offerAmt) as String, forKey: "trip_pay_amount" as NSCopying)
        //            data.setObject(acceptTime, forKey: "tm_acc" as NSCopying)
        if let acceptTime = Utilities.getStringFrom(Date.init()) {
            data.setObject(acceptTime, forKey: "tm_acc" as NSCopying)
        }
        if isShowLoader {
            UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        }
        if let paymentIntentId = payment_intent_id {
            data.setObject(paymentIntentId as String, forKey: "payment_intent_id" as NSCopying)
            data.setObject(pay_mode ?? CASH_PAY  as String, forKey: "trip_pay_mode" as NSCopying)
        }
        apiAcceptTrip=ApiHelperObj.init()
        apiAcceptTrip!.mkwerwus(  trip_accept, d: data as! [AnyHashable : Any]) { (results, error) in
            if isShowLoader {
                UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            if(results==nil){
                completion(results,error as NSError? )
            }else{
                completion(results,nil as NSError? )
            }
        }
    }
    
    
    public func assignedTrip(trip:TripModel ,offerAmt:Float,driver_id:String,payment_intent_id:String?,pay_mode:String?,isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(TS_ASSIGNED, forKey: TRIP_STATUS as NSCopying)
        data.setObject(driver_id, forKey: "driver_id" as NSCopying)
        data.setObject(Utilities.getRandomPINString(5)as String, forKey: "otp" as NSCopying)
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        data.setObject(Utilities.formatAmount(offerAmt) as String, forKey: "trip_pay_amount" as NSCopying)
        //            data.setObject(acceptTime, forKey: "tm_acc" as NSCopying)
        if let acceptTime = Utilities.getStringFrom(Date.init()) {
            data.setObject(acceptTime, forKey: "tm_acc" as NSCopying)
        }
        if isShowLoader {
            UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        }
        if let paymentIntentId = payment_intent_id {
            data.setObject(paymentIntentId as String, forKey: "payment_intent_id" as NSCopying)
            data.setObject(pay_mode ?? CASH_PAY  as String, forKey: "trip_pay_mode" as NSCopying)
        }
        apiAcceptTrip=ApiHelperObj.init()
        apiAcceptTrip!.mkwerwus(  trip_assigned, d: data as! [AnyHashable : Any]) { (results, error) in
            if isShowLoader {
                UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            if(results==nil){
                completion(results,error as NSError? )
            }else{
                completion(results,nil as NSError? )
            }
        }
    }
    
    
    public func  getTripRequestsOffers(trip:TripModel ,isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject("offer", forKey: "status" as NSCopying)
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        if isShowLoader {
            UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        }
        apiGetTrip=ApiHelperObj.init()
        apiGetTrip!.mkwerwus( API_GET_TRIP_OFFERS, d: data as! [AnyHashable : Any]) { (results, error) in
            if isShowLoader {
                UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            if(results==nil){
                completion(results,error as NSError? )
            }else{
                completion(results,nil as NSError? )
            }
        }
    }
    
    public func  getTripRequestsOffers(isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject("offer", forKey: "status" as NSCopying)
        data.setObject("1", forKey: "is_trip" as NSCopying)
        if let dictDriver = UserDefaults.standard.object(forKey: P_USER_DICT) as? NSDictionary{
            if let dId = dictDriver.object(forKey: P_DRIVER_ID) as? String {
                if let d_is_available = dictDriver.object(forKey: "d_is_available") as? Int{
                    if d_is_available == 0{
                        return
                    }
                }
            }else{
                return
            }
            //        @"d_is_available"
            data.setObject(String(format: "%@", dictDriver.object(forKey: P_DRIVER_ID) as! CVarArg), forKey: P_DRIVER_ID as NSCopying)
            if isShowLoader {
                UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            apiH = ApiHelperObj.init()
            apiH!.mkwerwus( API_GET_TRIP_OFFERS, d: data as! [AnyHashable : Any]) { (results, error) in
                if isShowLoader {
                    UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
                }
                if results == nil{
                    completion(results,error as NSError? )
                }else{
                    completion(results,nil as NSError? )
                }
            }
        }
    }
    
    public func updateStateRequestsOffers(trip:TripModel, status:String, driverId:String,isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(status, forKey: "status" as NSCopying)
        data.setObject(driverId, forKey: "driver_id" as NSCopying)
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        if isShowLoader {
            UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        }
        apiUpdateOfferTrip=ApiHelperObj.init()
        apiUpdateOfferTrip!.mkwerwus( API_UPDATE_OFFER, d: data as! [AnyHashable : Any]) { (results, error) in
            if isShowLoader {
                UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            if(results==nil){
                completion(results,error as NSError? )
            }else{
                print("updateStateRequestsOffers \(results)")
                completion(results,nil as NSError? )
            }
        }
    }
    
    
    public func updateRequestsOffersAmount(trip:TripModel, offer_amt:String, driverId:String,isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(offer_amt, forKey: "offer_amt" as NSCopying)
        data.setObject("offer", forKey: "status" as NSCopying)
        data.setObject(driverId, forKey: "driver_id" as NSCopying)
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        if isShowLoader {
            UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        }
        apiH = ApiHelperObj.init()
        apiH!.mkwerwus(API_UPDATE_OFFER, d: data as! [AnyHashable : Any]) { (results, error) in
            if isShowLoader {
                UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            if results == nil{
                completion(results,error as NSError? )
            }else{
                completion(results,nil as NSError? )
            }
        }
    }
    
    public func updateTripPayAmount(trip:TripModel ,status:String,pay_amount:String,isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(String(format: "%@", trip.trip_Id), forKey: TRIP_ID as NSCopying)
        data.setObject(String(format: "%@", pay_amount), forKey: "trip_pay_amount" as NSCopying)
        pay_amount
        if isShowLoader {
            UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        }
        apiUpdateTrip = ApiHelperObj.init()
        apiUpdateTrip!.mkwerwus( TRIP_UPDATE, d: data as! [AnyHashable : Any]) { (results, error) in
            if isShowLoader {
            UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            if(results==nil){
                completion(results,error as NSError? )
            }else{
                completion(results,nil as NSError? )
            }
        }
    }
    
}
