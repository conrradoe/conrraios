//
//  UpdateTripOfferViewController.swift
//  InDriver
//
//  Created by Grepix Infotech on 05/04/22.
//

import UIKit
@objc protocol UpdateTripOfferViewControllerDelegate
{
    func handleOfferSentBtnTap(viewController:UpdateTripOfferViewController)
    func handleSkipBtnTap(viewController:UpdateTripOfferViewController)
}


class UpdateTripOfferViewController: BaseViewControllerSwift,UITextFieldDelegate {

    @IBOutlet weak var btnSendOffer: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var txtOfferAmount: TextFieldPadding!
    @IBOutlet weak var lblYourOfferText: UILabel!
    
    @IBOutlet weak var lblMinMaxOffer: UILabel!
    weak var delegate:UpdateTripOfferViewControllerDelegate?
    var tripOffer:TripOffer?
    var isAsDriver:Bool=false
    var cell:UITableViewCell?
    
    var apiH:ApiHelperObj?
    var socketHelperSwift:SocketHelperSwift?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ConstantModel.getConstantsObject().max_decimal_allowed > 0 {
            self.txtOfferAmount.keyboardType = .decimalPad
        }else{
            self.txtOfferAmount.keyboardType = .numberPad
        }
        self.txtOfferAmount.delegate = self
        self.txtOfferAmount.becomeFirstResponder()
        if self.isAsDriver {
            self.txtOfferAmount.text = self.tripOffer!.offer_amt
            if let category_id = Int32( self.tripOffer!.trip!.category_id ),let cityId = self.tripOffer?.trip?.city_id ,let base_est_amt = Float( self.tripOffer!.trip!.base_est_amt ){
                if let category = CategoryModel.getCategoryByid(category_id){
                    if(category.isAllowToCheckMaxMin()){
                        let city = CityModel.getCityByCityId(Int(cityId))
                        let minfare = base_est_amt - ( base_est_amt * category.min_offer_perc )/100.0;
                        let maxfare = base_est_amt + ( base_est_amt * category.max_offer_perc )/100.0;
                        self.lblMinMaxOffer.text = "\(LanguageHelper.getStringWithKey("k_r1_s6_max_bid_amt")): \(Utilities.formatAmountAndCurrency(maxfare, currency: city.city_cur)!)"
                    }else{
                        self.lblMinMaxOffer.text = ""
                    }
                }else{
                    self.lblMinMaxOffer.text = ""
                }
            }else{
                self.lblMinMaxOffer.text = ""
            }
        }else{
            if let category_id = Int32( self.tripOffer!.trip!.category_id ),let cityId = self.tripOffer?.trip?.city_id ,let base_est_amt = Float( self.tripOffer!.trip!.base_est_amt ){
                if let category = CategoryModel.getCategoryByid(category_id){
                    if(category.isAllowToCheckMaxMin()){
                        let city = CityModel.getCityByCityId(Int(cityId))
                        let minfare = base_est_amt - ( base_est_amt * category.min_offer_perc )/100.0;
                        let maxfare = base_est_amt + ( base_est_amt * category.max_offer_perc )/100.0;
                        self.lblMinMaxOffer.text = "\(LanguageHelper.getStringWithKey("k_r1_s6_min_bid_amt")): \(Utilities.formatAmountAndCurrency(minfare, currency: city.city_cur)!)"
                    }else{
                        self.lblMinMaxOffer.text = ""
                    }
                }else{
                    self.lblMinMaxOffer.text = ""
                }
            }else{
                self.lblMinMaxOffer.text = ""
            }
            if  let amt = Float(tripOffer!.user_offer_amt ?? "0") {
                if amt == 0 {
                    tripOffer!.user_offer_amt = tripOffer?.trip!.trip_fare
                }else{
                    self.txtOfferAmount.text = self.tripOffer!.user_offer_amt
                }
            }else{
                self.txtOfferAmount.text = self.tripOffer!.user_offer_amt
            }
        }
        self.lblYourOfferText.text = LanguageHelper.getStringWithKey("k_1_s9_ur_ofr_ttl")
        self.btnSkip.setTitle(LanguageHelper.getStringWithKey("k_22_s8_skip"), for:     .normal)
        self.btnSendOffer.setTitle(LanguageHelper.getStringWithKey("k_63_s4_vw_snd_ofr"), for: .normal)
    }
    

    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
                let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                            with: string)
            let array = updatedText.components(separatedBy: ".")
            if array.count > 1 {
                let lastItem = array.last
                if lastItem!.count > 2{
                    return false
                }
                if(array.count > 2){
                    return false
                }
            }
        }
        
        return true
    }
    
    @IBAction func onSkipBtnTap(_ sender: Any) {
        self.delegate?.handleSkipBtnTap(viewController: self)
        
    }
    
    @IBAction func onSendOfferBtnTap(_ sender: Any) {
        
      
        
        if self.tripOffer!.user_offer_amt ==  self.txtOfferAmount.text {
            return
        }
        
        if let  amt = Float(self.txtOfferAmount.text!) {
            if(amt <= 0){
                self.showAlert(msg: LanguageHelper.getStringWithKey("k_r1_s6_please_enter_amount"))
                return
            }
            if let category_id = Int32( self.tripOffer!.trip!.category_id ),let cityId = self.tripOffer?.trip?.city_id ,let base_est_amt = Float( self.tripOffer!.trip!.base_est_amt ){
                if let category = CategoryModel.getCategoryByid(category_id){
                    if(category.isAllowToCheckMaxMin()){
                        let city = CityModel.getCityByCityId(Int(cityId))
                        let minfare = base_est_amt - ( base_est_amt * category.min_offer_perc )/100.0;
                        let maxfare = base_est_amt + ( base_est_amt * category.max_offer_perc )/100.0;
                        if amt < minfare {
                            self.showAlert(msg: LanguageHelper.getStringWithKey("k_r1_s6_pls_ntr_amnt_grtr_thn_min_fare"))
                            return
                        }
                        if amt > maxfare {
                            self.showAlert(msg: LanguageHelper.getStringWithKey("k_r1_s6_pls_ntr_amnt_less_thn_max_fare"))
                            return
                        }
                    }
                }
            }
            if isAsDriver {
                onUpdateOfferAmount(tripOffer: self.tripOffer!, offerAmount: self.txtOfferAmount.text!, indexPath: (cell as! TripOfferSentCell).indexPath!)
            }else{
                onUpdateOfferAmount(tripOffer: self.tripOffer!, offerAmount: self.txtOfferAmount.text!, indexPath: (cell as! TripOfferCell).indexPath!)
            }
        }else{
            self.showAlert(msg: LanguageHelper.getStringWithKey("k_r1_s6_please_enter_amount"))
        }
        
    }
    
    
    
    func onUpdateOfferAmount(tripOffer: TripOffer, offerAmount: String, indexPath: IndexPath) {
        self.view.endEditing(true)
        let  driverId = String(format: "%@", tripOffer.driver!.driverId)
        self.updateStateRequestsOfferAmount(tripOffer: self.tripOffer!, status: "offer", offer_amt: offerAmount, driverId: driverId, isShowLoader: true) { [self] results, error in
            if let resultsD = results as? [String:AnyObject] {
                if let status = resultsD["status"] as? String{
                    if status.lowercased() == "ok" {
                        if self.isAsDriver {
                            tripOffer.offer_amt = offerAmount
                            if self.socketHelperSwift!.isConnected() {
                                tripOffer.trip?.driver = tripOffer.driver
                                self.socketHelperSwift?.sendOfferToUser(trip: tripOffer.trip!, data: resultsD[P_RESPONSE] as! NSDictionary)
                            }else{
                                TripNotificationHelper.sendNotification(toUser: TS_OFFER, data: (resultsD[P_RESPONSE] as! NSDictionary) as! [AnyHashable : Any], trip: tripOffer.trip!)
                            }
                            tripOffer.offer_edited_amt = offerAmount
                            (self.cell as! TripOfferSentCell).tripOffer?.isEdited = false
                        }else{
                            tripOffer.user_offer_amt = offerAmount
                            tripOffer.count = Int(tripOffer.countTotal)
                            if self.socketHelperSwift!.isConnected() {
                                tripOffer.trip?.driver = tripOffer.driver
                                self.socketHelperSwift?.sendOfferToDriver(trip: tripOffer.trip!, data: resultsD[P_RESPONSE] as! NSDictionary)
                            }else{
                                TripNotificationHelper.sendNotification(TS_OFFER, data: (resultsD[P_RESPONSE] as! NSDictionary) as! [AnyHashable : Any], trip: tripOffer.trip!)
                            }
                            tripOffer.offer_edited_amt = offerAmount
                            (self.cell as! TripOfferCell).tripOffer?.isEdited = false
                        }
                        self.delegate?.handleOfferSentBtnTap(viewController: self)
                        self.showAlert(msg: LanguageHelper.getStringWithKey("k_45_s4_ofr_sent"))
                    }
                }
            }else{
                Utilities.handleError(error, viewController: self, defaultMessage: "")
            }
        }
    }
    
    func showAlert(msg:String){
        let alert = UIAlertController.init(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: LanguageHelper.getStringWithKey("k_r8_s8_ok"), style: .default, handler: { (action) in
            
        }))
        self.present(alert, animated: true) {
            
        }
    }
    
    public func updateStateRequestsOfferAmount(tripOffer:TripOffer, status:String,offer_amt:String, driverId:String,isShowLoader:Bool, completion: @escaping (_ results:Any?,_ error:NSError?) -> Void){
        let data:NSMutableDictionary = NSMutableDictionary.init()
        data.setObject(status, forKey: "status" as NSCopying)
        if self.isAsDriver {
            data.setObject(offer_amt, forKey: "offer_amt" as NSCopying)
        }else{
            data.setObject(offer_amt, forKey: "user_offer_amt" as NSCopying)
        }
        data.setObject(driverId, forKey: "driver_id" as NSCopying)
        data.setObject(String(format: "%@", tripOffer.trip_id!), forKey: TRIP_ID as NSCopying)
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
    
}
