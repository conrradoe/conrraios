//
//  TripOfferViewModel.swift
//  InRider
//
//  Created by Grepix on 01/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit
class TripOfferViewModel: NSObject {
    
    private var tripOfferManager: TripOfferManager?
    var tripOffer:Observable<[TripOffer]> = Observable([])
    var trip: TripModel?
    var tripDriver: TripModel?
    var isTripUpdated:Observable<Bool> = Observable(false)
    var isAppEnteredForGround:Observable<Bool> = Observable(false)
    var isAnyOfferRemoved:Observable<Bool> = Observable(false)
    var isRsetTimers:Observable<Bool> = Observable(false)
    var error:Observable<NSError?> = Observable(nil)
    var dataOffer:Observable<NSDictionary?> = Observable(nil)
    private var observer: NSObjectProtocol?
    private var observerBackground: NSObjectProtocol?
    
    private var observerOfferNotifcation: NSObjectProtocol?
    private var observerOfferAcceptNotifcation: NSObjectProtocol?
    private var isCalling=false
    private var pendingDriverOffersRefresh=false
    var isAsDriver=false
    var refreshTimer:Timer?
//    var refreshTripDetails:Timer?
    var isTripCanncelErrorUpdated:Observable<Bool> = Observable(false)
    var apiGetOfferTrip:ApiHelperObj?
    
    
    init(tripOfferManager: TripOfferManager) {
        super.init()
        self.tripOfferManager = tripOfferManager
        // reload data when app enter in forgoround
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
       
            if isAsDriver {
                    self.getDriverTripOffers(isShowLoader:false)
            }else{
                let timeRemaing = getRemainingTimeForTrip()
                if timeRemaing > 0{
                    setTimerForExpireTrip(timeInterval: timeRemaing)
                    self.getTripOffers(isShowLoader:false)
                }else{
                    runTimedCode()
                }
                self.getTripDetailsWithId(tripId: self.trip!.trip_Id! as NSString, isShowLoader: true)
            }
            if socektManger().isConnected() ==  false{
                socektManger().connect()
            }
            self.isAppEnteredForGround.value = true
//            self.startGetTripDetailsTimer()
        }
//        self.startGetTripDetailsTimer()
        observerBackground = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [unowned self] notification in
            socektManger().disconnect()
        }
        
        
        observerOfferAcceptNotifcation = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppNotificationName.USER_ON_ACCEPT_NOTIFICATION), object: nil, queue: .main) { [unowned self] notification in
            if let userinfo = notification.userInfo as? [String:Any]{
                if let aps = userinfo["aps"] as? [String:Any]{
                    print("Data \(aps)");
                    let tripStatus = aps["trip_status"] as? String ?? ""
                    if tripStatus ==  TS_ACCEPTED {
                        self.getTripDetails(dictNoti: aps as NSDictionary, isShowLoader: true)
                    }
                }
            }
        }
        
        
        observerOfferNotifcation = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppNotificationName.USER_OFFER_NOTIFICATION), object: nil, queue: .main) { [unowned self] notification in
            if let userinfo = notification.userInfo as? [String:Any]{
                if let aps = userinfo["aps"] as? [String:Any]{
                    print("Data \(aps)");
                    let tripStatus = aps["trip_status"] as? String ?? ""
                    let tripTripId = aps["trip_id"] as? String ?? ""
                    if tripStatus ==  "declined" {
                        if let data =  aps["data"] as? NSDictionary {
                            let tripOffer = TripOffer.init(dict: data)
                            if isAlreadyAdded(id_request: tripOffer.trip_request_id) == true{
                                let index = self.indexAlreadyAdded(id_request:tripOffer.trip_request_id)
                                if index >= 0{
                                    self.tripOffer.value.remove(at: index)
                                    self.isAnyOfferRemoved.value = true
                                }else{
                                    if self.isAsDriver {
                                        self.getDriverTripOffers(isShowLoader:false)
                                    }else{
                                        self.getTripOffers(isShowLoader:false)
                                    }
                                }
                            }else{
                                if self.isAsDriver {
                                    self.getDriverTripOffers(isShowLoader:false)
                                }else{
                                    self.getTripOffers(isShowLoader:false)
                                }
                            }
                        }else{
                            if self.isAsDriver {
                                self.getDriverTripOffers(isShowLoader:false)
                            }else{
                                self.getTripOffers(isShowLoader:false)
                            }
                        }
                    }else  if tripStatus ==  TS_ACCEPTED {
                    // accept trip with offer then received data form notification
                        self.trip?.trip_Status = TS_ACCEPTED
                        self.isTripUpdated.value = true
                        
                    }else{
                        self.dataOffer.value = aps as NSDictionary;
                        if let data =  aps["data"] as? NSDictionary {
                            let tripOffer = TripOffer.init(dict: data)
                            if isAlreadyAdded(id_request: tripOffer.trip_request_id) == false{
                                self.tripOffer.value.append(tripOffer)
                            }else{
                                let index = self.indexAlreadyAdded(id_request:tripOffer.trip_request_id)
                                if index >= 0{
                                    let offer = self.tripOffer.value[index];
                                    tripOffer.trip = offer.trip
                                    if self.isAsDriver {
                                        if(offer.user_offer_amt != tripOffer.user_offer_amt){
                                            self.tripOffer.value.remove(at: index)
                                            self.tripOffer.value.insert(offer, at: 0)
                                            offer.user_offer_amt = tripOffer.user_offer_amt
                                            offer.offerUpated = "dd"
                                            let name = Notification.Name(AppNotificationName.USER_OFFER_NOTIFICATION_UPDATE)
                                            NotificationCenter.default.post(name:name, object: nil, userInfo: userinfo )
                                        }
                                    }else{
                                        if(offer.offer_amt != tripOffer.offer_amt){
                                            self.tripOffer.value.remove(at: index)
                                            self.tripOffer.value.insert(offer, at: 0)
                                            offer.offer_amt = tripOffer.offer_amt
                                            offer.offerUpated = "dd"
                                        }
                                    }
                                }
                            }
                        }else{
                            if self.isAsDriver {
                                self.getDriverTripOffers(isShowLoader:false)
                            }else{
                                self.getTripOffers(isShowLoader:false)
                            }
                        }
                    }
                }else{
                    if self.isAsDriver {
                        self.getDriverTripOffers(isShowLoader:false)
                    }else{
                        self.getTripOffers(isShowLoader:false)
                    }
                }
            }else{
                if self.isAsDriver {
                    self.getDriverTripOffers(isShowLoader:false)
                }else{
                    self.getTripOffers(isShowLoader:false)
                }
            }
        }
        setTimerForExpireTrip(timeInterval: getRemainingTimeForTrip())
        // timer for update exipire trip
        
        socektManger().connect()
    }
    
    func setTimerForExpireTrip(timeInterval :Int){
         
//        if(self.trip!.is_ride_later  == false){
            if timeInterval >= 0 {
                if let refreshTimer = refreshTimer {
                    refreshTimer.invalidate()
                }
                refreshTimer = Timer.scheduledTimer(timeInterval:TimeInterval(timeInterval) , target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
                RunLoop.current.add(refreshTimer!, forMode: .common)
            }
//        }
    }
    
    func  getTripDetails(dictNoti:NSDictionary,isShowLoader:Bool){
        self.getTripDetailsWithId(tripId: dictNoti.object(forKey: "trip_id") as! NSString, isShowLoader: isShowLoader)
    }
    func  getTripDetailsWithId(tripId:NSString,isShowLoader:Bool){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(String(format: "%@", tripId as CVarArg), forKey: TRIP_ID as NSCopying)
        if isShowLoader {
            UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
        }
        apiGetOfferTrip=ApiHelperObj.init()
        apiGetOfferTrip!.mkwerwus( TRIP_GETTRIP, d: data as! [AnyHashable : Any]) { [self] (results, error) in
            if isShowLoader {
                UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            if let resultsD = results as? NSDictionary {
                if let res = resultsD["response"] as? NSArray {
                     print("getTripDetails \(res)")
                    if res.count > 0{
                        if let response = res.object(at: 0) as? [AnyHashable : Any]{
                            self.tripDriver = TripModel.init(itemWithDict: response  )
                            if self.isAsDriver {
                            }else{
                                self.trip?.trip_Status = self.tripDriver!.trip_Status
                            }
                        }
                        self.isTripUpdated.value = true
                    }
                }
            }else{
//                self.error.value =  error
            }
        }
    }
    
    func checkAnyAcceptedOffer(isShowLoader:Bool){
        if isAsDriver == false{
            return
        }
        let data:NSMutableDictionary = NSMutableDictionary.init()
        if let dictDriver = UserDefaults.standard.object(forKey: P_USER_DICT) as? NSDictionary {
            data.setObject(dictDriver.object(forKey: P_DRIVER_ID), forKey: P_DRIVER_ID as NSCopying)
            if isShowLoader {
                UtilityClass.setLH(false, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
            }
            apiGetOfferTrip=ApiHelperObj.init()
            apiGetOfferTrip!.mkwerwus( GET_PENDING_TRIP, d: data as! [AnyHashable : Any]) { [self] (results, error) in
                if isShowLoader {
                    UtilityClass.setLH(true, wt: LanguageHelper.getStringWithKey("k_r30_s3_loading", defaultValue: "Loading"))
                }
                if let resultsD = results as? NSDictionary {
                    if let res = resultsD["response"] as? NSArray {
                        print("getTripDetails \(res)")
                        if res.count > 0{
                            if let response = res.object(at: 0) as? [AnyHashable : Any]{
                                self.tripDriver = TripModel.init(itemWithDict: response  )
                                self.isTripUpdated.value = true
                            }
                            
                        }
                    }else{
                    }
                }else{
                    print("results getTripDetails \(results)")
                    //                self.error.value =  error
                }
            }
        }else{
            
        }
    }
    

    
    
    func getRemainingTimeForTrip() -> Int {
        let  maxTime = ConstantModel.getConstantsObject().exp_time
        if let trip_date_create = UserDefaults.standard.string(forKey: "trip_date_create"){
            if let startStr = Utilities.getGMTDatetoLocalTZ(trip_date_create, "yyyy-MM-dd HH:mm:ss"){
                if let date = Utilities.convertString(toDate: startStr, fromFormat: "yyyy-MM-dd HH:mm:ss"){
                    let timeInterval = Date.init().timeIntervalSince(date)
                    if  Int(timeInterval) < maxTime*60 {
                        if timeInterval > -1 {
                            return Int(Double(Int(maxTime)*60)-timeInterval)
                        }
                    }else{
                        // mark as expire afte 5 min
                        return -1
                    }
                }
            }
        }
        return Int(maxTime*60)
    }
    
    
    @objc func runTimedCode() {
        expireTrip()
        // mark as expire afte 5 min
        
    }
    
    
    
    deinit {
        self.removeAllObserver()
        
    }
    
    
    public func removeAllObserver(){
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = observerBackground {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observerOfferNotifcation = observerOfferNotifcation {
            NotificationCenter.default.removeObserver(observerOfferNotifcation)
        }
        if let observerOfferAcceptNotifcation = observerOfferAcceptNotifcation {
            NotificationCenter.default.removeObserver(observerOfferAcceptNotifcation)
        }
        
        if let refreshTimer = refreshTimer {
            refreshTimer.invalidate()
        }
//        stopGteTripDetails()
        
        socektManger().disconnect()
    }
    
//    func stopGteTripDetails(){
//        if let refreshTripDetails = refreshTimer {
//            refreshTripDetails.invalidate()
//        }
//    }
    
//    func startGetTripDetailsTimer(){
//        stopGteTripDetails()
//        refreshTripDetails = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(refresTripDetails), userInfo: nil, repeats: true)
//        RunLoop.current.add(refreshTripDetails!, forMode: .common)
//    }
    
//    @objc func refresTripDetails() {
//        if isAsDriver {
//            self.getDriverTripOffers(isShowLoader:false)
//        }else{
//            self.getTripDetailsWithId(tripId: self.trip!.trip_Id! as NSString, isShowLoader: false)
//        }
//    }
    
    
    public func addOffer(){
        
    }
    
    
    
    func isAlreadyAddedWithTrip(trip_id:String)->Bool{
        for offer in self.tripOffer.value {
            if trip_id == offer.trip?.trip_Id {
                return true
            }
        }
        return false
    }
    
    /**
     Cancel trip
     */
    
    public func cancelTrip(){
        tripOfferManager?.canceTrip(trip: trip!) { [self] (results, error) in
            if let results = results {
                print(results)
                self.trip!.trip_Status = TS_USER_CANCEL
                for offer in self.tripOffer.value {
                    sendToDecliend(tripOfferAccepted: offer)
                }
                self.isTripUpdated.value = true
            }else{
                self.error.value =  error!
            }
        }
    }
    public func cancelAssignTrip(){
        tripOfferManager?.cancelAssignTrip(trip: trip!) { [self] (results, error) in
            if let results = results {
                print(results)
                self.trip!.trip_Status = TS_USER_CANCEL
                self.isTripUpdated.value = true
            }else{
                self.error.value =  error!
            }
        }
    }
    
    /**
     Accept Trip
     */
    
    public func acceptTrip(tripOffer:TripOffer,payment_intent_id: String?,pay_mode:String?){
        let  driverId = String(format: "%@", tripOffer.driver!.driverId)
        var offerAmt:Float=0.0;
        if let offerAmtString = tripOffer.offer_amt {
            offerAmt = Float(offerAmtString)!
        }
        tripOfferManager?.acceptTrip(trip: trip!,offerAmt: offerAmt, driver_id:driverId,payment_intent_id: payment_intent_id,pay_mode: pay_mode,isShowLoader:true) { [self] (results, error) in
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            if let results = results {
                print(results)
                self.trip!.trip_Status = TS_ACCEPTED
                self.isTripUpdated.value = true
                self.trip?.driver=tripOffer.driver
                self.trip?.sendNotificationAccepted()
//                self.sendToDecliend(tripOfferAccepted: tripOffer)
            }else{
                self.error.value =  error!
            }
        }
    }
    
    public func assignTrip(tripOffer:TripOffer,payment_intent_id: String?,pay_mode:String?){
        let  driverId = String(format: "%@", tripOffer.driver!.driverId)
        var offerAmt:Float=0.0;
        if let offerAmtString = tripOffer.offer_amt {
            offerAmt = Float(offerAmtString)!
        }
        tripOfferManager?.assignedTrip(trip: trip!,offerAmt: offerAmt, driver_id:driverId,payment_intent_id: payment_intent_id,pay_mode: pay_mode,isShowLoader:true) { [self] (results, error) in
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            if let results = results {
                print(results)
                self.trip!.trip_Status = TS_ASSIGNED
                self.isTripUpdated.value = true
                self.trip?.driver=tripOffer.driver
                self.trip?.sendNotificationAssigned()
//                self.sendToDecliend(tripOfferAccepted: tripOffer)
            }else{
                self.error.value =  error!
            }
        }
    }
    
    func sendToDecliend(tripOfferAccepted:TripOffer){
        for offer in self.tripOffer.value {
            if tripOfferAccepted.driver?.driverId != offer.driver?.driverId {
                if socektManger().isConnected() {
                    socektManger().sendOfferStatus(tripOffer: offer, status: "declined", data: offer.dictOffer!)
                }else{
                    TripNotificationHelper.sendNotification(toDeclinedOffer: "declined", data: offer.dictOffer! as! [AnyHashable : Any], tripId: offer.trip_id!, driver: offer.driver!)
                }
            }
        }
    }
    
    public func expireTrip(){
        if let tr  = self.trip{
            if(tr.is_ride_later  == true){
                return
            }
        }
        
        if self.isAsDriver {
            
        }else{
            
            if let trip1 = trip{
                tripOfferManager?.updateTrip(trip: trip! , status: TS_EXPIRED,isShowLoader:false) { [self] (results, error) in
                    if let results = results {
                        print(results)
                        self.trip!.trip_Status = TS_EXPIRED
                        self.isTripUpdated.value = true
                    }else{
                        self.error.value =  error!
                    }
                }
            }
        }
        
    }
    
    
    public func getTripOffers(isShowLoader:Bool){
        if isCalling {
            return
        }
        isCalling = true
        tripOfferManager?.getTripRequestsOffers(trip: trip!,isShowLoader: isShowLoader) { [self] (results, error) in
            isCalling = false
            if let resultsD = results as? [String:AnyObject] {
                if let res = resultsD["response"] as? [AnyObject] {
                    for offer in res {
                        if let offerDict = offer as? NSDictionary{
                            let off = TripOffer.init(dict: offerDict)
                            if isAlreadyAdded(id_request: off.trip_request_id) ==  false{
                                self.tripOffer.value.append(off)
                            }else{
                                if off.status == "expired"{
                                    self.tripOffer.value.removeAll { t in
                                        t.trip_request_id == off.trip_request_id
                                    }
                                }
                            }
                        }
                    }
                }else{
                    self.tripOffer.value.removeAll()
                }
            }else{
                self.error.value =  error!
            }
        }
    }
    
    public func getDriverTripOffers(isShowLoader:Bool){
        if isCalling {
            // Mark that another refresh is needed; it will run once the current call finishes.
            pendingDriverOffersRefresh = true
            return
        }
        pendingDriverOffersRefresh = false
        isCalling = true
        tripOfferManager?.getTripRequestsOffers(isShowLoader: isShowLoader) { [self] (results, error) in
            isCalling = false
            if let resultsD = results as? [String:AnyObject] {
                if let res = resultsD["response"] as? [AnyObject] {
                    for offer in res {
                        if let offerDict = offer as? NSDictionary{
                            let off = TripOffer.init(dict: offerDict)
                            if off.trip?.trip_Status == TS_REQUEST{
                                if isAlreadyAdded(id_request: off.trip_request_id) ==  false{
                                    self.tripOffer.value.append(off)
                                }else{
                                    let index = self.indexAlreadyAdded(id_request:off.trip_request_id)
                                    if index >= 0{
                                        let offer = self.tripOffer.value[index];
                                        if(offer.user_offer_amt != off.user_offer_amt){
                                            self.tripOffer.value.remove(at: index)
                                            self.tripOffer.value.insert(off, at: 0)
                                        }
                                    }
                                }
                            }else{
                                let index = self.indexAlreadyAdded(id_request:off.trip_request_id)
                                if index >= 0{
                                    let offer = self.tripOffer.value[index];
//                                    if(offer.user_offer_amt != off.user_offer_amt){
//                                        self.tripOffer.value.remove(at: index)
                                    self.tripDriver=off.trip
                                    self.isTripUpdated.value = true
//                                        self.tripOffer.value.insert(off, at: 0)
//                                    }
                                }
                            }
                        }
                    }
                }else{
                    self.tripOffer.value.removeAll()
                    checkAnyAcceptedOffer(isShowLoader: isShowLoader)
                }
                // Trigger bind: Observable only fires on assignment, not on array mutation
                self.tripOffer.value = self.tripOffer.value
                
            }else{
                self.error.value =  error!
            }
            isRsetTimers.value=true
            // If another refresh was requested while this call was in flight, run it now.
            if pendingDriverOffersRefresh {
                getDriverTripOffers(isShowLoader: false)
            }
        }
    }


    func offerAccepted(){
        
    }
    
    /**
     update  trip offer status
     stats="declined"  if user tap on decline button on offer cell  ,
     stats="missed"   missed status update when  timer  60 sec finsihed the mark as missed
     
     
     by default show loader when api call called
     */
    
    
    public func updateTripOffer(tripOffer:TripOffer,status:String){
        self.updateTripOffer(tripOffer: tripOffer, status: status, isShowLoader: true)
    }
    
    public func updateTripOfferDriver(tripOffer:TripOffer,status:String, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let  driverId = String(format: "%@", tripOffer.driver!.driverId)
        self.tripOfferManager?.updateStateRequestsOffers(trip: tripOffer.trip!, status: status, driverId: driverId, isShowLoader: true) { [self] (results, error) in
            if let resultsD = results as? [String:AnyObject] {
                if let status = resultsD["status"] as? String{
                    if status.lowercased() == "ok" {
                        let index = self.indexAlreadyAdded(id_request:tripOffer.trip_request_id)
                        if index >= 0{
                            self.tripOffer.value.remove(at: index)
                        }
                       
                    }
                }
            }else{
                self.error.value = error
            }
            completion(results,nil as NSError? )
        }
    }
    /**
     update  trip offer status
     stats="declined"  if user tap on decline button on offer cell  ,
     stats="missed"   missed status update when  timer  60 sec finsihed the mark as missed
     isShowLoader =  true when need to show loader otherwaise it should be false
     */
    public func updateTripOffer(tripOffer:TripOffer,status:String,isShowLoader:Bool){
        let  driverId = String(format: "%@", tripOffer.driver!.driverId)
        if let tripTemp = trip {
            self.tripOfferManager?.updateStateRequestsOffers(trip: tripTemp, status: status, driverId: driverId, isShowLoader: isShowLoader) { [self] (results, error) in
                if let resultsD = results as? [String:AnyObject] {
                    if let status = resultsD["status"] as? String{
                        if status.lowercased() == "ok" {
                            let index = self.indexAlreadyAdded(id_request:tripOffer.trip_request_id)
                            if index >= 0{
                                self.tripOffer.value.remove(at: index)
                            }
                            self.sendDeclinedDataToDriver(tripOffer:tripOffer)
                        }
                    }
                }else{
                    if isShowLoader {
                        self.error.value = error
                    }
                }
            }
        }
    }
    
    func sendDeclinedDataToDriver(tripOffer : TripOffer){
        if socektManger().isConnected() {
            socektManger().sendOfferToDriverTripOffer(tripOffer: tripOffer, status: "declined", data: tripOffer.dictOffer!)
        }else{
            TripNotificationHelper.sendNotification(toDeclinedOffer: "declined", data: tripOffer.dictOffer as! [AnyHashable : Any], tripId: tripOffer.trip_id!, driver: tripOffer.driver!)
        }
    }
    
    func isAlreadyAdded(id_request:String)->Bool{
        for offer in self.tripOffer.value {
            if id_request == offer.trip_request_id {
                return true
            }
        }
        return false
    }
    
    func socektManger() -> SocketHelperSwift{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.getSockethelperSwift() as! SocketHelperSwift
    }
    
    public  func indexAlreadyAdded(id_request:String)->Int{
        var count = 0
        for offer in self.tripOffer.value {
            if id_request == offer.trip_request_id {
                return count
            }
            count = count + 1
        }
        return -1
    }
    
    public  func indexAlreadyAddedWithTrip(trip_id:String)->Int{
        var count = 0
        for offer in self.tripOffer.value {
            if trip_id == offer.trip?.trip_Id {
                return count
            }
            count = count + 1
        }
        return -1
    }
    
    public func updateTripOfferAmount(tripOffer:TripOffer,offer_amt:String,completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        
        let  dictDriver = UserDefaults.standard.object(forKey: P_USER_DICT) as! NSDictionary
        let  driverId = dictDriver.object(forKey: P_DRIVER_ID) as! String
        
        self.tripOfferManager?.updateRequestsOffersAmount(trip: tripOffer.trip!, offer_amt: offer_amt, driverId: driverId, isShowLoader: true, completion: { (results, error) in
            completion(results,error)
            //            if let resultsD = results as? [String:AnyObject] {
            //                if let status = resultsD["status"] as? String{
            //                    if status.lowercased() == "ok" {
            ////                        let index = self.indexAlreadyAdded(id_request:tripOffer.trip_request_id)
            ////                        if index >= 0{
            ////                            self.tripOffer.value.remove(at: index)
            ////                        }
            //                    }
            //                }
            //            }else{
            ////                if isShowLoader {
            //////                    self.error.value = error
            ////                }
            //            }
        })
    }
    
    
    
    public func acceptTrip(tripOffer:TripOffer,offerAmt:String,payment_intent_id:String?,pay_mode:String?, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let  driverId = String(format: "%@", tripOffer.driver!.driverId)
        var offerAmt:Float=0.0;
        if let offerAmtString = tripOffer.user_offer_amt {
            offerAmt = Float(offerAmtString)!
        }
        tripOfferManager?.acceptTrip(trip: tripOffer.trip!,offerAmt: offerAmt, driver_id:driverId,payment_intent_id: payment_intent_id,pay_mode: pay_mode,isShowLoader:true) { [self] (results, error) in
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            //            if let results = results {
            //                print(results)
            //
            ////                self.trip!.trip_Status = TS_ACCEPTED
            ////                self.isTripUpdated.value = true
            ////                self.trip?.driver=tripOffer.driver
            ////                self.trip?.sendNotificationAccepted()
            //                UserDefaults.standard.removeObject(forKey: TRIP_ID);
            //            }else{
            //                self.error.value =  error!
            //            }
            completion(results,error)
        }
    }
}
