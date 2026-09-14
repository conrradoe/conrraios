//
//  TripOffer.swift
//  InRider
//
//  Created by Grepix on 01/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let tripOffer = try? newJSONDecoder().decode(TripOffer.self, from: jsonData)

import Foundation


@objcMembers public class TripOffer : NSObject{
    public override init() {
        
    }
    var status:String?
    var trip_request_id:String!
    var offer_amt:String?
    @objc var trip_id:String?
//    dynamic
    var user_offer_amt:String?
    
    var driver:DriverModel?
    var trip:TripModel?
    var offer_edited_amt:String?
    var isEdited:Bool = false
    open var isUpdated:Bool = false
    @objc dynamic let countTotal:Float=60*2
    @objc dynamic var count:Int=60*2
    @objc dynamic var offerUpated:String=""
    @objc var dictOffer:NSDictionary?
    init(dict:NSDictionary) {
        dictOffer=dict
        self.trip_id=dict.object(forKey: "trip_id") as? String
        self.status=dict.object(forKey: "status") as? String
        self.trip_request_id=dict.object(forKey: "trip_request_id") as? String
        self.offer_amt=dict.object(forKey: "offer_amt") as? String
        self.user_offer_amt=dict.object(forKey: "user_offer_amt") as? String
        
        self.offer_edited_amt=dict.object(forKey: "offer_amt") as? String
        if let driver = dict.object(forKey: "Driver") as? [AnyHashable : Any]{
            self.driver = DriverModel.init(itemWithDict: driver )
        }
        if let trip = dict.object(forKey: "Trip") as? [AnyHashable : Any]{
            self.trip = TripModel.init(itemWithDict: trip   )
        }
    }
    
    func getRemainingTimeForTrip( _ dict:NSDictionary) -> Int {
        if let trip_date_create = dict.object(forKey: "modified") as? String{
            if let startStr = Utilities.getGMTDatetoLocalTZ(trip_date_create, "yyyy-MM-dd HH:mm:ss"){
                if let date = Utilities.convertString(toDate: startStr, fromFormat: "yyyy-MM-dd HH:mm:ss"){
                    let timeInterval = Date.init().timeIntervalSince(date)
                    if  timeInterval < 2*60 {
                        if timeInterval > -1 {
                            return Int(2*60-timeInterval)
                        }
                    }else{
                        // mark as expire afte 5 min
                        return -1
                    }
                }
            }
        }
        return 2*60
    }
}
//struct TripOfferElement: Codable {
//    var tripRequestID, tripID, driverID, offerAmt: String
//    var status, isDelete, created, modified: String
//    var driver: [String: String?]
//    var trip: Trip
//
//    enum CodingKeys: String, CodingKey {
//        case tripRequestID
//        case tripID
//        case driverID
//        case offerAmt
//        case status
//        case isDelete
//        case created, modified
//        case driver
//        case trip
//    }
//}
//
//// MARK: - Trip
//struct Trip: Codable {
//    var tripID, mTripID, storeID, compID: String
//    var userID, receiverID, driverID, categoryID: String
//    var subCatID, countryID, cityID: String
//    var imageID: JSONNull?
//    var tripDate: String
//    var tripCustomerDetails: JSONNull?
//    var tripFromLOC, tripToLOC: String
//    var actualToLOC, actualFromLOC: JSONNull?
//    var tripDunit, tripDistance, tripHrs, tripDeliveryFee: String
//    var tripWaitTime, tripPickupTime, tripDropTime, tripReason: JSONNull?
//    var tripValidity, tripFeedback: JSONNull?
//    var tripStatus: String
//    var tripRating, userRating, userFeedback: JSONNull?
//    var tripScheduledPickLat, pickupNotes, tripScheduledPickLng: String
//    var tripActualPickLat, tripActualPickLng: JSONNull?
//    var tripScheduledDropLat, tripScheduledDropLng: String
//    var tripActualDropLat, tripActualDropLng, tripSearchedAddr: JSONNull?
//    var tripSearchResultAddr, tripQuote: String
//    var tripPayMode: JSONNull?
//    var tripCurrency, tripBaseFare, tripShareDiscount, tripPayAmount: String
//    var tripPayDate, tripPayStatus, payURL, tripDriverCommision: JSONNull?
//    var tripCompCommision, tripTotalTime, waitDuration: String
//    var tripTip: JSONNull?
//    var promoID: String
//    var tripPromoCode: JSONNull?
//    var tripPromoAmt, taxAmt, adjustAmt, subCat: String
//    var tripCategoryJSON, isDelivery, seats, isDispatch: String
//    var otp, uDeviceType, uDeviceToken: JSONNull?
//    var deliveryNotes, deliveryRemarks, deliveryOrder: String
//    var deliveryTime: JSONNull?
//    var isPrepaid, isManual, isReminderSent, isDrvFare: String
//    var isRideLater, isShare, isSendNotification, isCancelled: String
//    var isOneway, isUserEnterprise: String
//    var isDelete: JSONNull?
//    var tripCreated, tripModified: String
//    var imgType, imgName, imgDescription, imgPath: JSONNull?
//    var videoPath, imgCreated, imgModified, tripImagePath: JSONNull?
//    var driver: JSONNull?
//    var user: [String: String?]
//    var mTrip: JSONNull?
//
//    enum CodingKeys: String, CodingKey {
//        case tripID
//        case mTripID
//        case storeID
//        case compID
//        case userID
//        case receiverID
//        case driverID
//        case categoryID
//        case subCatID
//        case countryID
//        case cityID
//        case imageID
//        case tripDate
//        case tripCustomerDetails
//        case tripFromLOC
//        case tripToLOC
//        case actualToLOC
//        case actualFromLOC
//        case tripDunit
//        case tripDistance
//        case tripHrs
//        case tripDeliveryFee
//        case tripWaitTime
//        case tripPickupTime
//        case tripDropTime
//        case tripReason
//        case tripValidity
//        case tripFeedback
//        case tripStatus
//        case tripRating
//        case userRating
//        case userFeedback
//        case tripScheduledPickLat
//        case pickupNotes
//        case tripScheduledPickLng
//        case tripActualPickLat
//        case tripActualPickLng
//        case tripScheduledDropLat
//        case tripScheduledDropLng
//        case tripActualDropLat
//        case tripActualDropLng
//        case tripSearchedAddr
//        case tripSearchResultAddr
//        case tripQuote
//        case tripPayMode
//        case tripCurrency
//        case tripBaseFare
//        case tripShareDiscount
//        case tripPayAmount
//        case tripPayDate
//        case tripPayStatus
//        case payURL
//        case tripDriverCommision
//        case tripCompCommision
//        case tripTotalTime
//        case waitDuration
//        case tripTip
//        case promoID
//        case tripPromoCode
//        case tripPromoAmt
//        case taxAmt
//        case adjustAmt
//        case subCat
//        case tripCategoryJSON
//        case isDelivery
//        case seats
//        case isDispatch
//        case otp
//        case uDeviceType
//        case uDeviceToken
//        case deliveryNotes
//        case deliveryRemarks
//        case deliveryOrder
//        case deliveryTime
//        case isPrepaid
//        case isManual
//        case isReminderSent
//        case isDrvFare
//        case isRideLater
//        case isShare
//        case isSendNotification
//        case isCancelled
//        case isOneway
//        case isUserEnterprise
//        case isDelete
//        case tripCreated
//        case tripModified
//        case imgType
//        case imgName
//        case imgDescription
//        case imgPath
//        case videoPath
//        case imgCreated
//        case imgModified
//        case tripImagePath
//        case driver
//        case user
//        case mTrip
//    }
//}
//
//typealias TripOffer = [TripOfferElement]
//
//// MARK: - Encode/decode helpers
//
//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    public var hashValue: Int {
//        return 0
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
//}
