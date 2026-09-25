//
//  TripOffersViewContoller.swift
//  InRider
//
//  Created by Grepix on 01/07/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit

@objc protocol DTripOffersViewContollerDelegate {
    func handleAfterTripRequestExpiredOrCancel(isShowAlert:Bool)
    func onTripOfferAcceptedByRider(trip:TripModel)
    func onTripOfferAcceptedByRiderApi(trip:TripModel)
    
    func openOfferTripDetail1(tripOffer:TripOffer)
    func replaceWithOfferTripDetail1(tripOffer:TripOffer)
    func menuButtonTaped()
    func updateSentOfferCounter(count:Int)
    func canShowAlertForOffer(dict:NSDictionary)->Bool
    
}

@objcMembers class DTripOffersViewContoller: BaseViewControllerSwift,UITableViewDelegate,UITableViewDataSource,TripOfferSentCellDelegate,UpdateTripOfferViewControllerDelegate,AutoHideAlertDelegate {
    func onAutoHide(_ autoHideAlertHelper: AutoHideAlert) {
        
    }
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblWatingForOffer: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    var tripOfferViewModel:TripOfferViewModel!
    let tripOfferManager = TripOfferManager()
    public weak var delegate:DTripOffersViewContollerDelegate?
    var refreshTimer:Timer?
    var refreshTimerForGetTripOffers:Timer?
    var observerAcceptNotifcation:NSObjectProtocol?
    var observerOfferNotifcation:NSObjectProtocol?
    
    var tripAcceptHelper:TripOfferAcceptHelper?
    private var autoHideOfferNotification:AutoHideAlert?
    private var observerForgound: NSObjectProtocol?
    private var observerBackground: NSObjectProtocol?
    var onDriverOffersFetched: (([TripOffer]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblWatingForOffer.isHidden=true
        self.lblHeader.text=LanguageHelper.getStringWithKey("k_63_s4_opn_ofrs")
        self.lblWatingForOffer.text=LanguageHelper.getStringWithKey("k_10_s3_no_offrs")
        self.tableView.tableFooterView=UIView.init()
        self.tripOfferViewModel = TripOfferViewModel(tripOfferManager: tripOfferManager)
        self.tripOfferViewModel.isAsDriver = true
        self.tableView.register(UINib.init(nibName: "TripOfferSentCell", bundle: nil), forCellReuseIdentifier: "TripOfferSentCell")
        self.bindData()
        self.delegate?.updateSentOfferCounter(count: 0)
        let ima = UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate)
        self.btnMenu.tintColor = UIColor(named: "app_theame")
        self.btnMenu.setImage(ima, for: .normal)
//        @"NotificationAcceptedReceived"
        observerAcceptNotifcation = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "NotificationAcceptedReceived"), object: nil, queue: .main) { [unowned self] notification in
            print("Data \(notification.userInfo )");
            if let userinfo = notification.userInfo as? [String:Any]{
                if let aps = userinfo["aps"] as? [String:Any]{
                    print("Data \(aps)");
                    let tripStatus = aps["trip_status"] as? String ?? ""
                    let trip_id = aps["trip_id"] as? String ?? ""
                    let alert = aps["alert"] as? String ?? ""
                    if tripStatus ==  "declined" {
                        let index = self.tripOfferViewModel.indexAlreadyAddedWithTrip(trip_id:trip_id)
                        if index >= 0{
                            self.tripOfferViewModel.tripOffer.value.remove(at: index)
                            self.tableView.reloadData()
                        }
                    }
                    else if tripStatus ==  TS_ACCEPTED {
                        if self.tripOfferViewModel.isAlreadyAddedWithTrip(trip_id: trip_id) == true{
                            let index = self.tripOfferViewModel.indexAlreadyAddedWithTrip(trip_id:trip_id)
                            if index >= 0{
                                self.showAlertGoBack(msg: alert, tripOffer: self.tripOfferViewModel.tripOffer.value[index])
                            }else{
                                self.tripOfferViewModel.getDriverTripOffers(isShowLoader:false)
                            }
                        }else{
                            let delegate = UIApplication.shared.delegate as! AppDelegate
//                            delegate.handleAcceptNotification(trip_id, message: alert, userInfo: userinfo, isPostLocalNotification: false)
                        }
                    }else{
                        self.tripOfferViewModel.getDriverTripOffers(isShowLoader:false)
                    }
                }else{
                    self.tripOfferViewModel.getDriverTripOffers(isShowLoader:false)
                }
            }else{
                self.tripOfferViewModel.getDriverTripOffers(isShowLoader:false)
            }
        }
        
        observerOfferNotifcation = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: AppNotificationName.USER_OFFER_NOTIFICATION), object: nil, queue: .main) { [unowned self] notification in
            /*
             La lista se recarga SOLO cuando el pasajero rechazo la oferta.

             Este aviso llega con varios estados distintos. El que interesa aqui es "declined":
             antes solo salia el mensaje y la oferta rechazada se quedaba en la lista hasta que
             picara el temporizador, asi que el conductor veia una oferta viva que ya no
             existia y al tocarla se encontraba con un error del servidor.

             POR QUE NO SE RECARGA EN LOS DEMAS. Recargar llama a getDriverTripOffers, y esa
             funcion, al encontrar una oferta que ya no esta pendiente, pone tripDriver y
             levanta isTripUpdated (TripOfferViewModel). El bind de isTripUpdated, con el viaje
             en accept, hace navigationController?.popViewController... y esta pantalla es un
             HIJO de HomeViewController añadido como subvista, no esta en la pila. O sea que
             ese pop se lleva por delante a HomeViewController y deja debajo la pantalla del
             PASAJERO. Recargando en todos los avisos, eso saltaba justo al aceptar el viaje.

             El pop mal dirigido es anterior a esto y sigue ahi: cualquier otra cosa que
             provoque la recarga en ese momento lo volvera a disparar. Se acota el disparador,
             no se arregla la causa.
             */
            var estadoDelAviso = ""
            if let userinfo = notification.userInfo as? [String:Any],
               let aps = userinfo["aps"] as? [String:Any] {
                estadoDelAviso = (aps["trip_status"] as? String ?? "").lowercased()
            }
            if estadoDelAviso == "declined" {
                self.refloadData()
            }

            if let userinfo = notification.userInfo as? [String:Any]{
                if let aps = userinfo["aps"] as? [String:Any]{
                    let alertMessageText = aps["alert"] as? String ?? ""
                    if alertMessageText.count > 1  {
                        if alertMessageText == "\0" {
                            return
                        }
                        let alert = alertMessage(title: "", msg: alertMessageText, btTtile: LanguageHelper.getStringWithKey("k_18_s4_vw_cht")) { action in
                            self.autoHideOfferNotification?.performAction()
                        }
                        self.autoHideOfferNotification = AutoHideAlert.init()
                        self.autoHideOfferNotification?.handle(alert)
                        self.autoHideOfferNotification?.delegate = self
                    }
                }
            }
        }
        func alertMessage(title:String,msg:String,btTtile:String,handler:((UIAlertAction) -> Void)? = nil) -> UIAlertController{
            let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LanguageHelper.getStringWithKey("k_18_s4_Ok"), style: .default, handler: nil))
    //        alert.addAction(UIAlertAction(title: btTtile, style: .default, handler: handler))
            self.present(alert, animated: true)
            return alert
        }
        
        
        observerForgound = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            self.stopUpRefresTripOffer()
            self.tripOfferViewModel.getDriverTripOffers(isShowLoader:false)
        }
//        self.startGetTripDetailsTimer()
        observerBackground = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [unowned self] notification in
            self.stopUpRefresTripOffer()
        }
    }
    
    
    func refloadData(){
        self.stopUpRefresTripOffer()
        self.tripOfferViewModel.getDriverTripOffers(isShowLoader:false)
    }

    @objc func fetchDriverOffersWithCompletion(_ completion: @escaping ([TripOffer]) -> Void) {
        onDriverOffersFetched = completion
        tripOfferViewModel.getDriverTripOffers(isShowLoader: false)
    }
    
    func stopAndRemove(){
        self.stopUpRefresTripOffer()
        self.refreshTimer?.invalidate()
        self.tripOfferViewModel.removeAllObserver()
        self.removeFromParent()
        self.view.removeFromSuperview()
        if let observerOfferNotifcation = observerOfferNotifcation {
            NotificationCenter.default.removeObserver(observerOfferNotifcation)
        }
        if let observerOfferNotifcation = observerAcceptNotifcation {
            NotificationCenter.default.removeObserver(observerOfferNotifcation)
        }
        if let observer = self.observerOfferNotifcation {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.observerBackground {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.observerForgound {
            NotificationCenter.default.removeObserver(observer)
        }

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        tripOfferViewModel.getDriverTripOffers(isShowLoader:true)
        refreshTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        RunLoop.current.add(refreshTimer!, forMode: .common)
      
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        refreshTimer?.invalidate()
        stopUpRefresTripOffer()
    }
    
    
    
    
    func runTimedCode() {
        if let tripOfferViewModel = self.tripOfferViewModel {
            for offer in tripOfferViewModel.tripOffer.value {
                offer.count = offer.count - 1
                if(offer.count<1){
                    // missed
                    self.tripOfferViewModel.updateTripOffer(tripOffer: offer, status: "missed" , isShowLoader:false)
                }else{
                    
                }
            }
        }
//        self.tableView.reloadData()
    }
    
    
    func setUpRefresTripOffer(){
        self.stopUpRefresTripOffer()
        refreshTimerForGetTripOffers = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(runTimedCodeForGetTripOffers), userInfo: nil, repeats: false)
        RunLoop.current.add(refreshTimerForGetTripOffers!, forMode: .common)
    }
    
    func stopUpRefresTripOffer(){
        if let timer = refreshTimerForGetTripOffers{
            timer.invalidate()
            refreshTimerForGetTripOffers = nil
        }
    }
    
    func runTimedCodeForGetTripOffers() {
        self.tripOfferViewModel.getDriverTripOffers(isShowLoader:false)
    }
    
    func bindData() {
        tripOfferViewModel.tripOffer.bind { [weak self] in
            print($0)
            if let count = self?.tripOfferViewModel?.tripOffer.value.count,  count > 0{
                self?.lblWatingForOffer.isHidden=true
                self?.delegate?.updateSentOfferCounter(count: count)
            }else{
                self?.lblWatingForOffer.isHidden=false
                self?.delegate?.updateSentOfferCounter(count: 0)
            }
            self?.tableView.reloadData()
            if let callback = self?.onDriverOffersFetched {
                self?.onDriverOffersFetched = nil
                callback(self?.tripOfferViewModel?.tripOffer.value ?? [])
            }
        }
        
        tripOfferViewModel.isRsetTimers.bind { [weak self] in
            if $0 {
                self?.setUpRefresTripOffer()
            }
        }
        tripOfferViewModel.dataOffer.bind { [weak self] in
            if let offer = $0 {
                let canShow = self?.delegate?.canShowAlertForOffer(dict: offer)
//                if self!.delegate!.canShowAlertForOffer(){
//                    let alert = offer.object(forKey: "alert") as? String ?? ""
//                    self?.showAlert(msg: alert)
//                }
//                self?.setUpRefresTripOffer()
            }
        }
        
        
        tripOfferViewModel.isTripUpdated.bind { [weak self] in
            if $0 {
                self?.tripOfferViewModel.socektManger().disconnect()
                self?.tripOfferViewModel.removeAllObserver();
                if(self?.tripOfferViewModel.tripDriver!.trip_Status == TS_USER_CANCEL ){
                    self?.navigationController?.popViewController(animated: true)
                    self?.delegate?.handleAfterTripRequestExpiredOrCancel(isShowAlert: false)
                }else if(self?.tripOfferViewModel.tripDriver!.trip_Status == TS_EXPIRED ){
                    self?.navigationController?.popToRootViewController(animated: true)
//                    self?.navigationController?.popViewController(animated: true)
                    self?.delegate?.handleAfterTripRequestExpiredOrCancel(isShowAlert: true)
                }else if(self?.tripOfferViewModel.tripDriver!.trip_Status == TS_ACCEPTED ){
                    self?.navigationController?.popViewController(animated: true)
                    self?.delegate?.onTripOfferAcceptedByRiderApi(trip: (self?.tripOfferViewModel.tripDriver)!)
                }
            }
        }
        tripOfferViewModel.isTripCanncelErrorUpdated.bind { [weak self] in
            if $0 {
                self?.tripOfferViewModel.socektManger().disconnect()
                self?.tripOfferViewModel.removeAllObserver()
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.handleAfterTripRequestExpiredOrCancel(isShowAlert: false)
            }
        }
        tripOfferViewModel.isAnyOfferRemoved.bind { [weak self] in
            if $0 {
                if let ss = self?.presentedViewController as? UpdateTripOfferViewController {
                    ss.dismiss(animated: false)
                }
            }
        }
        tripOfferViewModel.error.bind { [weak self] in
            guard let error = $0 else { return }
           
//                UserDefaults.standard.removeObject(forKey: TRIP_ID)
            Utilities.handleError(error, viewController: self, defaultMessage: "")
        }
    }
    
    /*
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripOfferViewModel?.tripOffer.value.count ?? 0
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  offerCell =  tableView.dequeueReusableCell(withIdentifier: "TripOfferSentCell", for: indexPath) as! TripOfferSentCell
        offerCell.selectionStyle = .none
        let offer = tripOfferViewModel?.tripOffer.value[indexPath.row]
        offerCell.populateData(tripOffer:offer! ,indexPath:indexPath,trip: offer?.trip)
        offerCell.delegate = self
        return offerCell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tripOffer = tripOfferViewModel?.tripOffer.value[indexPath.row]
        var rating = 0.0
        if let  dRating = tripOffer!.driver?.rating {
            rating = Double(dRating)
        }
        let name = String( format: "%@ %@ (%.1f)", tripOffer!.driver?.d_fname ?? "", tripOffer!.driver?.d_lname ?? "",rating)
        let font = UIFont.init(name: "Karla-Regular", size: 17)!
        let height = Utilities.getLabelHeight(CGSize(width: UIScreen.main.bounds.size.width-78, height: 300), forText: name, with: font)
//        return 155+height-20-20+70+8
        return 155+height-20-20+70+8 
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tripOffer = tripOfferViewModel?.tripOffer.value[indexPath.row]
        self.delegate?.openOfferTripDetail1(tripOffer:tripOffer!)
    }
    
    
    func onAcceptSent(cell: TripOfferSentCell, tripOffer: TripOffer, indexPath: IndexPath) {
//                [APP_DELEGATE stopRequestSound]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopRequestSound()
//         tripAcceptHelper = TripOfferAcceptHelper.init()
//        tripAcceptHelper?.viewController = self
//        tripAcceptHelper?.tripOffer = tripOffer as! NSObject
//        tripAcceptHelper?.onAccetOffer { results, error in
//            if let resultsD = results as? Any  {
                self.onAcceptAfterDecline(cell: cell, tripOffer: tripOffer, indexPath: indexPath)
//            }else{
//
//            }
//        }
    }
    
    func onAcceptAfterDecline(cell: TripOfferSentCell, tripOffer: TripOffer, indexPath: IndexPath) {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.stopRequestSound()
         
                   acceptOfferByDriver(tripOffer: tripOffer, payment_intent_id: nil, pay_mode: CASH_PAY)
    }
    
    
    
    func acceptOfferByDriver(tripOffer: TripOffer,payment_intent_id:String?,pay_mode:String?){
        self.tripOfferViewModel.acceptTrip(tripOffer:tripOffer,offerAmt: tripOffer.user_offer_amt!,payment_intent_id: payment_intent_id,pay_mode: pay_mode) { (results, error) in
            
            if let resultsD = results as? [String:AnyObject] {
                if let status = resultsD["status"] as? String{
                    if status.lowercased() == "ok" {
                        TripNotificationHelper.sendNotification(TS_ACCEPTED, trip: tripOffer.trip!)
                        self.showAlertGoBack(msg: LanguageHelper.getStringWithKey("trip_noti_msg_offer_accepted"),tripOffer: tripOffer)
                    }
                }
            }else{
                Utilities.handleError(error, viewController: self, defaultMessage: "")
            }
        }
    }
    
    func onDeclineSent(cell: TripOfferSentCell, tripOffer: TripOffer, indexPath: IndexPath) {
        self.tripOfferViewModel.updateTripOfferDriver(tripOffer: tripOffer, status: "declined") { results, error in
            if let resultsD = results as? [String:AnyObject] {
                if let status = resultsD["status"] as? String{
                    if status.lowercased() == "ok" {
                        self.tableView.reloadData()
                        if let trip = tripOffer.trip {
                            let socket = self.tripOfferViewModel.socektManger()
                            if socket.isConnected() {
                                socket.sendOfferToUser(trip: trip,status: "declined", data: tripOffer.dictOffer!)
                            }else{
                                TripNotificationHelper.sendNotification(toUser: "declined", data: tripOffer.dictOffer! as! [AnyHashable : Any], trip: trip)
                            }
                        }
                    }
                }
            }else{
                  
            }
        }
    }

    /// Call from Objective-C (e.g. OfferCardCell cancel) to cancel driver's sent offer and notify rider.
    @objc func cancelDriverOffer(withOffer offer: TripOffer, completion: @escaping (Bool) -> Void) {
        tripOfferViewModel.updateTripOfferDriver(tripOffer: offer, status: "declined") { [weak self] results, error in
            var success = false
            if let resultsD = results as? [String:AnyObject], let status = resultsD["status"] as? String, status.lowercased() == "ok" {
                success = true
                if let trip = offer.trip, let data = offer.dictOffer as? [AnyHashable : Any] {
                    let socket = self?.tripOfferViewModel.socektManger()
                    if socket?.isConnected() == true {
                        socket?.sendOfferToUser(trip: trip, status: "declined", data: data as NSDictionary)
                    } else {
                        TripNotificationHelper.sendNotification(toUser: "declined", data: data, trip: trip)
                    }
                }
            }
            DispatchQueue.main.async { completion(success) }
        }
    }
    
    
    func onCustomizeOffer(cell:TripOfferSentCell,tripOffer:TripOffer, indexPath:IndexPath){
        let vc =  self.storyboard?.instantiateViewController(withIdentifier: "UpdateTripOfferViewController") as! UpdateTripOfferViewController
        vc.delegate = self
        vc.tripOffer=tripOffer
        vc.isAsDriver = true
        vc.cell = cell
        vc.socketHelperSwift = tripOfferViewModel.socektManger()
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true) {
        }
    }
    
    
    func handleOfferSentBtnTap(viewController: UpdateTripOfferViewController) {
        viewController.dismiss(animated: true) {
            self.tableView.reloadData()
        }
    }
    
    func handleSkipBtnTap(viewController: UpdateTripOfferViewController) {
        viewController.dismiss(animated: true) {
            
        }
    }
    
    
    
    @IBAction func onCancelButtonTap(_ sender: Any){
        tripOfferViewModel.cancelTrip()
        tripOfferViewModel.socektManger().disconnect()
        
    }
    
    
    @IBAction func onBackButtonTap(_ sender: Any) {
        tripOfferViewModel.socektManger().disconnect()
        self.tripOfferViewModel.removeAllObserver()
        self.navigationController?.popViewController(animated: true)
    }
    
    func onUpdateOfferAmount(cell: TripOfferSentCell, tripOffer: TripOffer, offerAmount: String, indexPath: IndexPath) {
        self.view.endEditing(true)
        tripOfferViewModel.updateTripOfferAmount(tripOffer: tripOffer, offer_amt: offerAmount) { (results, error) in
            if let resultsD = results as? [String:AnyObject] {
                if let status = resultsD["status"] as? String{
                    if status.lowercased() == "ok" {
                        if let trip = tripOffer.trip {
                            let socket = self.tripOfferViewModel.socektManger()
                            if socket.isConnected() {
                                socket.sendOfferToUser(trip: trip, data: resultsD[P_RESPONSE] as! NSDictionary)
                            }else{
                                TripNotificationHelper.sendNotification(TS_OFFER, data: (resultsD[P_RESPONSE] as! NSDictionary) as! [AnyHashable : Any], trip: trip)
                            }
                        }
                        cell.tripOffer?.offer_amt = offerAmount
                        cell.tripOffer?.isEdited = false
//                        cell.btnSendOffer.isSelected = false
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
    func showAlertGoBack(msg:String ,tripOffer:TripOffer){
        tripOffer.trip?.trip_Status=TS_ACCEPTED
        self.tripOfferViewModel.removeAllObserver()
        self.delegate?.replaceWithOfferTripDetail1(tripOffer:tripOffer)
    }
    
    
    @IBAction func onMenuButtonTaped(_ sender: Any) {
        self.delegate?.menuButtonTaped()
    }
}
