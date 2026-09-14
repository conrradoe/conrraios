//
//  StoryBoardUtiles.swift
//  InDriver
//
//  Created by Grepix on 07/09/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//


import UIKit


@objcMembers class StoryBoardUtiles: NSObject {
    static let shared = StoryBoardUtiles()
    
    public  enum StoryBoardName : String{
        case MAIN = "Main"
        case SIGNUP = "SignUp"
        case USER = "User"
        case EXTRA_FEATURE = "ExtraFeature"
    }
    
    
    public static func formatAmountValue( amount: String,  maxDecimalsAllowed: Int) -> String {
        let amt = amount.components(separatedBy: ".")
        if amt.count == 2 && maxDecimalsAllowed > 0 {
            let intPart = amt[0]
            let decimalPart = amt[1]
            return String(format:"%@.%@", intPart, self.adjustLength(input: decimalPart, desiredLength: maxDecimalsAllowed))
        } else if amt.count > 0 {
            return amt[0]
        } else {
            return amount
        }
    }
    
    
    public static func adjustLength( input: String,  desiredLength: Int) -> String {
        if input.count > desiredLength {
            return String(input.prefix(desiredLength)) // Truncate to desired length
        } else {
            var result = input
            
            while result.count < desiredLength {
                result += "0" // Append zeros to the end
            }
            
            return result
        }
    }
    
    
    public  enum Contollers : String{
        case EDIT_PROFILE = "EditProfileViewController"
        case UEDIT_PROFILE = "UEditProfileViewController"
        case UPLOAD_DOCUMENT = "UploadDocumentViewController"
        case ABOUT_US = "AboutUsViewController"
        case OTP_SIGNIN = "OtpSignInViewController"
        case SIGNIN = "SignInViewController"
        case OTP_SIGNUP = "OtpSignUpViewController"
        case FORGOT_PASSWORD = "forgotPasswordViewController"
        case OTP_VERIFY = "OTPVerifyViewController"
        case SIGNIN_LANDING = "SignLandingVC"
        case NAV_PHONE = "navcon_phone"
        case NAV_EMAIL = "navcon"
        case HOME_VC = "HomeViewController"
        case HOME_NVAIGATION = "NavigationController"
        case MAIN_VC = "MainViewController"
        case UMAIN_VC = "UMainViewController"
        case FARE_DETAIL_VC = "FareDetailsViewController"
        case CHAT_VC = "ChatViewController"
        case CHANGE_PASSWORD_VC = "ChangePasswordViewController"
        case FARE_AMOUNT_VC = "FareAmmountViewController"
        case RIDER_CANCEL_VC = "RiderCancelTripViewController"
        case HOME_SINGLE_VC = "HomeViewSingleModeController"
        case TRIP_DETAIL_VC = "TripDetailsViewController"
        case UTRIP_DETAIL_VC = "UTripDetailsViewController"
        case PICKUP_DETAIL_VC = "PickupDetailViewController"
        // USer
        case UHOME_VC = "UHomeViewController"
//        case UNOTIFICATION_VC = "UNotificationViewController"
        case NOTIFICATION_DETAIL_VC = "NotificationDetailViewController"
        case UFAREREVIEW_VC = "UFareReviewViewController"
        case UFARE_SUMMERY_VC = "UFareSummeryViewController"
        
        case WALLET_VC = "UWalletViewController"
        case WALLET_ADD_MOENY_VC = "UAddMoneyWalletVC"
        case UCHAT_VC = "UChatViewController"
        case PAYOUT_VC = "PayoutViewController"
        
        
    }
    
    static let STORYBOARD_MAIN = StoryBoardName.MAIN.rawValue
    static let STORYBOARD_SIGNUP = StoryBoardName.SIGNUP.rawValue
    static let STORYBOARD_USER = StoryBoardName.USER.rawValue
    static let STORYBOARD_EXTRA_FEATURE = StoryBoardName.EXTRA_FEATURE.rawValue
    static let EDIT_PROFILE = Contollers.EDIT_PROFILE.rawValue
    static let UEDIT_PROFILE = Contollers.UEDIT_PROFILE.rawValue
    static let UPLOAD_DOCUMENT = Contollers.UPLOAD_DOCUMENT.rawValue
    static let ABOUT_US = Contollers.ABOUT_US.rawValue
    static let OTP_SIGNIN = Contollers.OTP_SIGNIN.rawValue
    static let SIGNIN = Contollers.SIGNIN.rawValue
    static let OTP_SIGNUP = Contollers.OTP_SIGNUP.rawValue
    static let FORGOT_PASSWORD = Contollers.FORGOT_PASSWORD.rawValue
    static let OTP_VERIFY = Contollers.OTP_VERIFY.rawValue
    static let SIGNIN_LANDING = Contollers.SIGNIN_LANDING.rawValue
    static let NAV_PHONE = Contollers.NAV_PHONE.rawValue
    static let HOME_VC = Contollers.HOME_VC.rawValue
    static let HOME_NVAIGATION = Contollers.HOME_NVAIGATION.rawValue
    static let MAIN_VC = Contollers.MAIN_VC.rawValue
    static let UMAIN_VC = Contollers.UMAIN_VC.rawValue
    static let FARE_DETAIL_VC = Contollers.FARE_DETAIL_VC.rawValue
    static let CHAT_VC = Contollers.CHAT_VC.rawValue
    static let CHANGE_PASSWORD_VC = Contollers.CHANGE_PASSWORD_VC.rawValue
    static let FARE_AMOUNT_VC = Contollers.FARE_AMOUNT_VC.rawValue
    static let RIDER_CANCEL_VC = Contollers.RIDER_CANCEL_VC.rawValue
    static let HOME_SINGLE_VC = Contollers.HOME_SINGLE_VC.rawValue
    static let NAV_EMAIL = Contollers.NAV_EMAIL.rawValue
    static let TRIP_DETAIL_VC = Contollers.TRIP_DETAIL_VC.rawValue
    static let UTRIP_DETAIL_VC = Contollers.UTRIP_DETAIL_VC.rawValue
    
    static let PICKUP_DETAIL_VC = Contollers.PICKUP_DETAIL_VC.rawValue
    static let UHOME_VC = Contollers.UHOME_VC.rawValue
//    static let UNOTIFICATION_VC = Contollers.UNOTIFICATION_VC.rawValue
    static let NOTIFICATION_DETAIL_VC = Contollers.NOTIFICATION_DETAIL_VC.rawValue
    static let UFAREREVIEW_VC = Contollers.UFAREREVIEW_VC.rawValue
    static let WALLET_VC = Contollers.WALLET_VC.rawValue
    static let WALLET_ADD_MOENY_VC = Contollers.WALLET_ADD_MOENY_VC.rawValue
    static let UFARE_SUMMERY_VC = Contollers.UFARE_SUMMERY_VC.rawValue
    static let UCHAT_VC = Contollers.UCHAT_VC.rawValue
    static let PAYOUT_VC = Contollers.PAYOUT_VC.rawValue
    
    private static var storyboardCache: [String: UIStoryboard] = [:]
    private static let storyboardCacheQueue = DispatchQueue(label: "com.conrra.storyboardCache")

    static public func storyBoard(name: String) -> UIStoryboard {
        storyboardCacheQueue.sync {
            if storyboardCache[name] == nil {
                storyboardCache[name] = UIStoryboard(name: name, bundle: nil)
            }
            return storyboardCache[name]!
        }
    }

    static  public func storyBoard(name: StoryBoardName ) -> UIStoryboard {
        return storyBoard(name: name.rawValue)
    }
    
    static public func viewContoller(identifier:String,name: String)->UIViewController?{
        let sb = storyBoard(name: name)
        let vc = sb.instantiateViewController(withIdentifier: identifier)
        return vc
    }
    
    static public func navigationPhone()->UINavigationController{
        let sb = storyBoard(name: STORYBOARD_SIGNUP)
        let vc = sb.instantiateViewController(withIdentifier: NAV_PHONE)
        return vc as! UINavigationController
    }
    static public func navigationEmail()->UINavigationController{
        let sb = storyBoard(name: STORYBOARD_SIGNUP)
        let vc = sb.instantiateViewController(withIdentifier: NAV_EMAIL)
        return vc as! UINavigationController
    }
    
    static public func navigationHome()->UINavigationController{
        let sb = storyBoard(name: STORYBOARD_MAIN)
        let vc = sb.instantiateViewController(withIdentifier: HOME_NVAIGATION)
        return vc as! UINavigationController
    }
    static public func navigationHomeInUser()->UINavigationController{
        let sb = storyBoard(name: STORYBOARD_USER)
        let vc = sb.instantiateViewController(withIdentifier: HOME_NVAIGATION)
        return vc as! UINavigationController
    }
    
    static public func viewContollerInMain(identifier:String)->UIViewController?{
        let sb = storyBoard(name: STORYBOARD_MAIN)
        let vc = sb.instantiateViewController(withIdentifier: identifier)
        return vc
    }
    static public func viewContollerInUser(identifier:String)->UIViewController?{
        let sb = storyBoard(name: STORYBOARD_USER)
        let vc = sb.instantiateViewController(withIdentifier: identifier)
        return vc
    }
    static func applyAnimation(view:UIView){
        view.startShimmeringAnimation(animationSpeed: 2.5, direction: UIView.Direction.leftToRight, repeatCount: MAXFLOAT)
    }
}

@objcMembers class AppNotificationName: NSObject{
    static let DRIVER_ACCEPT_NOTIFICATION = "NotificationReceived"
    static let DRIVER_RECEIVEDATFARE_NOTIFICATION = "NotificationReceivedAtFareAmount"
    static let USER_ACCEPT_NOTIFICATION = "User_NotificationReceived"
    static let USER_DECLINED_NOTIFICATION = "User_Declined_NotificationReceived"
    static let USER_OFFER_NOTIFICATION = "NotificationReceivedOnOffer"
    static let USER_ON_ACCEPT_NOTIFICATION = "NotificationReceivedOnAccept"
    static let DRIVER_HIDE_ALERT_NOTIFICATION = "NotificationHideAlert"
    static let USER_OFFER_NOTIFICATION_UPDATE = "NotificationReceivedOnOfferUpdate"
    static let USER_DECLINE_Alert_NOTIFICATION = "NotificationReceivedOnDelinedAlert"
}
@objcMembers class AppKeysName: NSObject{
    static let ERROR_DATA = "com.alamofire.serialization.response.error.data"
    static let ERROR_RESPONSE = "com.alamofire.serialization.response.error.response"
    
    
}

extension UIView {
  
  // ->1
  enum Direction: Int {
    case topToBottom = 0
    case bottomToTop
    case leftToRight
    case rightToLeft
  }
  
  func startShimmeringAnimation(animationSpeed: Float = 1.4,
                                direction: Direction = .leftToRight,
                                repeatCount: Float = MAXFLOAT) {
    
    // Create color  ->2
    let lightColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1).cgColor
    let blackColor = UIColor.white.cgColor
    
    // Create a CAGradientLayer  ->3
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [blackColor, lightColor, blackColor]
    gradientLayer.frame = CGRect(x: -self.bounds.size.width, y: -self.bounds.size.height, width: 3 * self.bounds.size.width, height: 3 * self.bounds.size.height)
    
    switch direction {
    case .topToBottom:
      gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
      gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
      
    case .bottomToTop:
      gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
      gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
      
    case .leftToRight:
      gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
      gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
      
    case .rightToLeft:
      gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
      gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
    }
    
    gradientLayer.locations =  [0.35, 0.50, 0.65] //[0.4, 0.6]
    self.layer.mask = gradientLayer
    
    // Add animation over gradient Layer  ->4
    CATransaction.begin()
    let animation = CABasicAnimation(keyPath: "locations")
    animation.fromValue = [0.0, 0.1, 0.2]
    animation.toValue = [0.8, 0.9, 1.0]
    animation.duration = CFTimeInterval(animationSpeed)
    animation.repeatCount = repeatCount
    CATransaction.setCompletionBlock { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.layer.mask = nil
    }
    gradientLayer.add(animation, forKey: "shimmerAnimation")
    CATransaction.commit()
  }
  
  func stopShimmeringAnimation() {
    self.layer.mask = nil
  }
  
}
