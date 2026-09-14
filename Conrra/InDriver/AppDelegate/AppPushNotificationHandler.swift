//
//  PushNotificationHandler.swift
//  UberAppsDriver
//
//  Created by Grepix Infotech on 23/11/22.
//

import UIKit

@objcMembers class AppPushNotificationHandler: NSObject,AutoHideAlertDelegate {
    private var autoHideChat:AutoHideAlert?
    private var autoHideNotification:AutoHideAlert?
     
    
    /**
     handle Notification when send from admin
     */
    func handleChatNotification(message:String,tripId:String){
        guard let navController = self.navController() else{
            return
        }
    
        guard navController.topViewController!.isKind(of: ChatViewController.self) else {
            let alert = alertMessage(title: LanguageHelper.getStringWithKey("k_97_s4_msg_revd"), msg: message, btTtile: LanguageHelper.getStringWithKey("k_18_s4_vw_cht")) { action in
                self.autoHideChat?.performAction()
                let vc = StoryBoardUtiles.viewContollerInMain(identifier: StoryBoardUtiles.CHAT_VC) as! ChatViewController
                vc.tripID = tripId
                self.openViewViewController(vc: vc)
                
            }
            autoHideChat = AutoHideAlert.init()
            autoHideChat?.handle(alert)
            autoHideChat?.delegate = self
            return
        }
    }
    
    /**
     handle Notification when send from admin
     */
    func handleSideNotification(message:String){
        guard let navController = self.navController() else{
            return
        }
        guard navController.topViewController!.isKind(of: NotificationViewController.self) else {
            let alert = alertMessage(title: LanguageHelper.getStringWithKey("k_r1_s11_notification"), msg: message, btTtile: LanguageHelper.getStringWithKey("k_97_s4_view")) { action in
                self.autoHideNotification?.performAction()
                    self.openViewViewController(vc: StoryBoardUtiles.viewContollerInMain(identifier: "NotificationViewController")!)
            }
            autoHideNotification = AutoHideAlert.init()
            autoHideNotification?.handle(alert)
            autoHideNotification?.delegate = self
            return
        }
    }
    
    
    
    private func openViewViewController(vc:UIViewController){
        self.navController()?.pushViewController(vc, animated: true)
    }
    
    func alertMessage(title:String,msg:String,btTtile:String,handler:((UIAlertAction) -> Void)? = nil) -> UIAlertController{
        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LanguageHelper.getStringWithKey("k_30_s6_cancel_j"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: btTtile, style: .default, handler: handler))
//        self.navController()?.present(alert, animated: true)
        self.presentViewControllerCustom(alert: alert)
        return alert
    }
    
    
    func presentViewControllerCustom(alert:UIAlertController){
        guard let navController = self.navController() else{
            return
        }
        guard navController.topViewController!.isKind(of: UIAlertController.self) else{
            navController.present(alert, animated: true)
            return
        }
        navController.topViewController!.dismiss(animated: false) {
            navController.present(alert, animated: true)
        }
    }
    
    private func navController()->UINavigationController?{
        let app = UIApplication.shared.delegate as! AppDelegate
        return app.navigationController
    }
    
    
    func onAutoHide(_ autoHideAlertHelper: AutoHideAlert!) {
        
    }
}
