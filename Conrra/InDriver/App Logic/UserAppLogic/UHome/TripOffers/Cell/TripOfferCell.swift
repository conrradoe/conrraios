//
//  TripOfferCell.swift
//  InRider
//
//  Created by Grepix on 01/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit
protocol TripOfferCellDelegate:NSObjectProtocol {
    func onAccept(cell:TripOfferCell,tripOffer:TripOffer, indexPath:IndexPath)
    func onDecline(cell:TripOfferCell,tripOffer:TripOffer, indexPath:IndexPath)
    func onCustomizeOffer(cell:TripOfferCell,tripOffer:TripOffer, indexPath:IndexPath)
    func onLocateDriver(cell:TripOfferCell,tripOffer:TripOffer, indexPath:IndexPath)
}

public class TripOfferCell: UITableViewCell {
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    var tripOffer:TripOffer?
    var indexPath:IndexPath?
    weak var delegate:TripOfferCellDelegate?
    
    @IBOutlet weak var lblLocateDriver: UILabel!
    
    @IBOutlet weak var lblTripsCount: UILabel!
    
    @IBOutlet weak var lblCarDetails: UILabel!
    @IBOutlet weak var viewForBlink: UIView!
    @IBOutlet weak var lblEstimateTime: UILabel!
    @IBOutlet weak var lblTImerProgress: UIProgressView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    
    // Driver Offer
    @IBOutlet weak var lblDriverAmtText: UILabel!
    @IBOutlet weak var lblOfferAmt: UILabel!
    
    @IBOutlet weak var lblYouOffered: UILabel!
    
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var btnCustomizeOffer: UIButton!
    var observationUserOfferAmount: NSKeyValueObservation?
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.lblLocateDriver.text = LanguageHelper.getStringWithKey("k_1_s9_lct_drvr")
        self.btnAccept.layer.cornerRadius = 18
        self.btnAccept.clipsToBounds = true
        self.btnCustomizeOffer.setTitle(LanguageHelper.getStringWithKey("k_1_s9_cstmz_ofr"), for: .normal)
        self.lblDriverAmtText.text = LanguageHelper.getStringWithKey("k_1_s9_drvr_ofr")
//        self.btnAccept.layer.borderWidth = 1
//        self.btnAccept.layer.borderColor = UIColor.init(named: "color_cat_border")?.cgColor
        
//        self.btnDecline.layer.cornerRadius = 18
//        self.btnDecline.clipsToBounds = true
//        self.btnDecline.layer.borderWidth = 1
//        self.btnDecline.layer.borderColor = UIColor.init(named: "Color_Red")?.cgColor
        // Initialization code
    }

    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func formatName(str1:String,str2:String)->NSMutableAttributedString
    {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "ic_star") // Replace with your image name

        let imageSize = CGSize(width: 20, height: 20)
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: imageSize.width, height: imageSize.height)

        // Create an attributed string with the image attachment
        let imageString = NSAttributedString(attachment: imageAttachment)

        // Create a text string and combine with the image
        let textBefore = NSAttributedString(string: str1)
        let textAfter = NSAttributedString(string: str2)

        // Combine all parts into a mutable attributed string
        let attributedString = NSMutableAttributedString()
        attributedString.append(textBefore)
        attributedString.append(imageString)
        attributedString.append(textAfter)
        return attributedString;
    }
    
    public  func populateData(tripOffer:TripOffer ,indexPath:IndexPath, trip:TripModel?){
        self.tripOffer=tripOffer
        self.indexPath=indexPath
        var rating = 0.0
        if let  dRating = tripOffer.driver?.rating {
            rating = Double(dRating)
        }
        let carInfo = "\(tripOffer.driver?.car_name ?? "") \(tripOffer.driver?.car_model ?? "") \(tripOffer.driver?.car_make ?? "")"
        let trimmedcarInfo = carInfo.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lblCarDetails.text = trimmedcarInfo
        
        self.lblRating.text = String( format: "%.1f",rating)
        let str1 = String( format: "%@ %@", tripOffer.driver?.d_fname ?? "", tripOffer.driver?.d_lname ?? "")
//        let str2 = String( format: " %d",tripOffer.driver?.num_trip ?? 0 ,"Trips"/*LanguageHelper.getStringWithKey("k_8_s11_trips")*/)
//        self.lblName.attributedText = self.formatName(str1: str1, str2: str2)
        self.lblName.text = str1
        self.lblTripsCount.text = String( format: "%d %@",tripOffer.driver?.num_trip ?? 0 ,LanguageHelper.getStringWithKey("k_8_s11_trips"))
//        self.lblName.text = String( format: "%@ %@ (%.1f) %d Trip(s)", tripOffer.driver?.d_fname ?? "", tripOffer.driver?.d_lname ?? "",rating,tripOffer.driver?.num_trip ?? 0)
        if let trip = trip , let amt = Float(tripOffer.offer_amt ?? "0") {
            let city = CityModel.getCityByCityId(Int(trip.city_id))
            self.lblOfferAmt.text = Utilities.formatAmountAndCurrency(amt, currency: city.city_cur)
        }else{
            self.lblOfferAmt.text = tripOffer.offer_amt
        }
        
        
        self.observationUserOfferAmount = tripOffer.observe(\TripOffer.offerUpated, options: .new, changeHandler: { [self] tOffer, changed in
            if let trip = trip , let amt = Float(tripOffer.offer_amt ?? "0") {
                let city = CityModel.getCityByCityId(Int(trip.city_id))
//                self.lblCurrencyName.text = city.city_cur
                self.lblOfferAmt.text = Utilities.formatAmountAndCurrency(amt, currency: city.city_cur)
            }else{
//                self.lblCurrencyName.text = ""
                self.lblOfferAmt.text = tripOffer.offer_amt
            }
            let  acceptTitle = "\(LanguageHelper.getStringWithKey("k_1_s9_accept")) \(LanguageHelper.getStringWithKey("k_1_s9_with")) (\(self.lblOfferAmt.text!))"
           self.btnAccept.setTitle(acceptTitle, for: .normal)
//            self.viewForBlink.blink()
//            if ((self.timerBlink) != nil)  {
//                self.timerBlink?.invalidate()
//                self.timerBlink=nil;
//            }
            tOffer.count = Int(tOffer.countTotal)
            self.viewForBlink.isHidden=false
            tOffer.isUpdated = true
          
//            self.timerBlink = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(doblink), userInfo: nil, repeats: true)
//            RunLoop.current.add(self.timerBlink!, forMode: .common)
        })
        
        if(self.tripOffer?.isUpdated == true){
            self.viewForBlink.isHidden=false
        }else{
            self.viewForBlink.isHidden=true
        }
        
        let textString = LanguageHelper.getStringWithKey("k_1_s9_ur_ofr", defaultValue: "")
        if let trip = trip , let amt = Float(tripOffer.user_offer_amt ?? "0") {
            let city = CityModel.getCityByCityId(Int(trip.city_id))
            if tripOffer.user_offer_amt == "0"{
                tripOffer.user_offer_amt = trip.trip_fare
            }else{
                self.lblYouOffered.text = "\(textString) (\(city.city_cur)\(tripOffer.user_offer_amt!))"
            }
        }else{
            if tripOffer.user_offer_amt == "0"{
                tripOffer.user_offer_amt = trip!.trip_fare
            }
//            self.lblCurrencyName.text = ""
            self.lblYouOffered.text = "\(textString) (\(tripOffer.user_offer_amt!)))"
        }
        
        let  acceptTitle = "\(LanguageHelper.getStringWithKey("k_1_s9_accept")) \(LanguageHelper.getStringWithKey("k_1_s9_with")) (\(self.lblOfferAmt.text!))"
       self.btnAccept.setTitle(acceptTitle, for: .normal)
        
        if let profile = tripOffer.driver?.d_car_image_path {
            self.imageProfile.sd_setImage(with: URL(string: String( format: "%@%@",url_base_images,profile)), placeholderImage: UIImage.init(named: "Profile Icon Crop Image"))
        }else{
            if let profile = tripOffer.driver?.d_profile_image_path{
                self.imageProfile.sd_setImage(with: URL(string: String( format: "%@%@",url_base_images,profile)), placeholderImage: UIImage.init(named: "Profile Icon Crop Image"))
            }else{
                self.imageProfile.image=UIImage.init(named: "Profile Icon Crop Image")
            }
        }
        let progress = Float(tripOffer.count)/tripOffer.countTotal
        self.lblTImerProgress.progress = progress
         
//        self.lblCarModel.text = tripOffer.driver?.car_model ?? ""
        let dLocation = CLLocation.init(latitude: Double(tripOffer.driver?.lat ?? 0), longitude: Double(tripOffer.driver?.lng  ?? 0))
        let dLocationPickup = CLLocation.init(latitude: Double(trip?.trip_pick_lat ?? "0") ?? 0, longitude: Double(trip?.trip_pick_long ?? "0")  ?? 0)
        let distance = dLocationPickup.distance(from: dLocation)
        let distanceInKm = distance/1000.0
        let timeInHrs = distanceInKm/15.0
        var timeInMin = timeInHrs * 60
        if timeInMin < 1 {
            timeInMin = 1
        }
//        let distanceInKm = distance/1000.0;
        self.lblEstimateTime.text = String( format: "%.2f km (%d min)",distanceInKm,Int(timeInMin))
    }
    
    
    
    @IBAction func onDeclineButtonTap(_ sender: Any) {
        self.delegate?.onDecline(cell: self, tripOffer: self.tripOffer!, indexPath: self.indexPath!)
    }
    
    
    
    
    @IBAction func onAcceptButtonTap(_ sender: Any) {
        self.delegate?.onAccept(cell: self, tripOffer: self.tripOffer!, indexPath: self.indexPath!)
    }
    
    
    @IBAction func onCustomizeBtnTap(_ sender: Any) {
        self.delegate?.onCustomizeOffer(cell: self, tripOffer: self.tripOffer!, indexPath: self.indexPath!)
    }
    
    
    
    @IBAction func onLocateDriverButtonTap(_ sender: Any) {
        self.delegate?.onLocateDriver(cell: self, tripOffer: self.tripOffer!, indexPath: self.indexPath!)
    }
    
    // In UICollectionViewCell
    public override func removeFromSuperview() {
        print("removeFromSuperview called")
        observationUserOfferAmount?.invalidate()
    }
    
    deinit {
        print("deinit called")
        observationUserOfferAmount?.invalidate()
    }
}

