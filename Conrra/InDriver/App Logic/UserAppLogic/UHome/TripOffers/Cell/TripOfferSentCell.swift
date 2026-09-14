//
//  TripOfferCell.swift
//  InRider
//
//  Created by Grepix on 01/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit
protocol TripOfferSentCellDelegate:NSObject {
    func onAcceptSent(cell:TripOfferSentCell,tripOffer:TripOffer, indexPath:IndexPath)
    func onDeclineSent(cell:TripOfferSentCell,tripOffer:TripOffer, indexPath:IndexPath)
    func onCustomizeOffer(cell:TripOfferSentCell,tripOffer:TripOffer, indexPath:IndexPath)
}

public class TripOfferSentCell: UITableViewCell {
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    var tripOffer:TripOffer?
    var indexPath:IndexPath?
   weak var delegate:TripOfferSentCellDelegate?
    
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var viewForBlink: UIView!
    @IBOutlet weak var lblEstimateTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    
    // User Offer
    @IBOutlet weak var lblUserOfferText: UILabel!
    @IBOutlet weak var lblOfferAmt: UILabel!
    //Your Offer
    @IBOutlet weak var lblYourOfferText: UILabel!
    
    @IBOutlet weak var btnCustomizeOffer: UIButton!
    
    
    var observationUserOfferAmount: NSKeyValueObservation?
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.btnAccept.layer.cornerRadius = 18
        self.btnAccept.clipsToBounds = true
        self.lblUserOfferText.text = LanguageHelper.getStringWithKey("k_1_s9_usr_ofr", defaultValue: "")
        self.btnCustomizeOffer.setTitle(LanguageHelper.getStringWithKey("k_1_s9_cstmz_ofr"), for: .normal)
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
        if let  dRating = tripOffer.trip?.user?.rating {
            rating = Double(dRating)
        }
        
        let str1 = String( format: "%@ %@ ", tripOffer.trip?.user?.u_fname ?? "", tripOffer.trip?.user?.u_lname ?? "")
        let str2 = ""
//        self.lblName.attributedText = self.formatName(str1: str1, str2: str2)
        self.lblName.text = str1 
//        self.lblName.text = String( format: "%@ %@ (%.1f)", tripOffer.trip?.user?.u_fname ?? "", tripOffer.trip?.user?.u_lname ?? "",rating)
        self.lblRating.text = String( format: "%.1f ", rating)
        let textString = LanguageHelper.getStringWithKey("k_1_s9_ur_ofr", defaultValue: "Loading")
        if let trip = trip , let amt = Float(tripOffer.offer_amt ?? "0") {
            let city = CityModel.getCityByCityId(Int(trip.city_id))
            let textAmt = Utilities.formatAmountAndCurrency(amt, currency: city.city_cur)
            self.lblYourOfferText.text = "\(textString) (\(textAmt!))"
        }else{
            self.lblYourOfferText.text = "\(textString) (\(tripOffer.offer_amt!))"
        }
      
        if let profile = tripOffer.trip?.user?.u_profile_image_path{
                self.imageProfile.sd_setImage(with: URL(string: String( format: "%@%@",url_base_images,profile)), placeholderImage: UIImage.init(named: "Profile Icon Crop Image"))
            }else{
                self.imageProfile.image=UIImage.init(named: "Profile Icon Crop Image")
            }
        
        self.observationUserOfferAmount = tripOffer.observe(\TripOffer.offerUpated, options: .new, changeHandler: { [self] tOffer, changed in
            if let trip = trip , let amt = Float(tripOffer.user_offer_amt ?? "0") {
                let city = CityModel.getCityByCityId(Int(trip.city_id))
                self.lblOfferAmt.text = Utilities.formatAmountAndCurrency(amt, currency: city.city_cur)
            }else{
                self.lblOfferAmt.text = tripOffer.user_offer_amt
            }
            let  acceptTitle = "\(LanguageHelper.getStringWithKey("k_1_s9_accept")) \(LanguageHelper.getStringWithKey("k_1_s9_with")) (\(self.lblOfferAmt.text!))"
           self.btnAccept.setTitle(acceptTitle, for: .normal)
//            self.viewForBlink.blink()
            tOffer.count = Int(tOffer.countTotal)
            tOffer.isUpdated = true
            self.viewForBlink.isHidden=false
//            self.timerBlink = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(doblink), userInfo: nil, repeats: true)
//            RunLoop.current.add(self.timerBlink!, forMode: .common)
        })
        if let trip = trip , let amt = Float(tripOffer.user_offer_amt ?? "0") {
            let city = CityModel.getCityByCityId(Int(trip.city_id))
            if amt == 0{
                let tripFare = Float(tripOffer.trip?.trip_fare ?? "0")
                self.lblOfferAmt.text = Utilities.formatAmountAndCurrency(tripFare!, currency: city.city_cur)
            }else{
                self.lblOfferAmt.text = Utilities.formatAmountAndCurrency(amt, currency: city.city_cur)
            }
        }else{
            self.lblOfferAmt.text = tripOffer.user_offer_amt
        }
        
        let  acceptTitle = "\(LanguageHelper.getStringWithKey("k_1_s9_accept")) \(LanguageHelper.getStringWithKey("k_1_s9_with")) (\(self.lblOfferAmt.text!))"
       self.btnAccept.setTitle(acceptTitle, for: .normal)
        
        
        if(self.tripOffer?.isUpdated == true){
            self.viewForBlink.isHidden=false
        }else{
            self.viewForBlink.isHidden=true
        }
       
        let dLocation = CLLocation.init(latitude: Double(tripOffer.trip?.user?.lat ?? 0), longitude: Double(tripOffer.trip?.user?.lng  ?? 0))
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
        self.delegate?.onDeclineSent(cell: self, tripOffer: self.tripOffer!, indexPath: self.indexPath!)
    }
    
    
    
    
    @IBAction func onAcceptButtonTap(_ sender: Any) {
        self.delegate?.onAcceptSent(cell: self, tripOffer: self.tripOffer!, indexPath: self.indexPath!)
    }
    
    
    @IBAction func onCustomiseBtnTap(_ sender: Any) {
        self.delegate?.onCustomizeOffer(cell: self, tripOffer: self.tripOffer!, indexPath: self.indexPath!)
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
