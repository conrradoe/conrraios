//
//  TripOffersViewContoller.swift
//  Conrra
//
//  Programmatic rewrite — OverFullScreen modal.
//  Transparent background lets UHomeViewController's live map + radar show through.
//  State 1 (searching): spinner + label + cancel button.
//  State 2 (offers):    scrollable TripOfferCardView cards, no cancel button.
//

import UIKit


@objc protocol TripOffersViewContollerDelegate {
    func handleAfterTripRequestExpiredOrCancel(isShowAlert: Bool)
    func onTripOfferAcceptedByRider(trip: TripModel?)
    func onTripOfferAssignedByRider(trip: TripModel?)
    func onTripOfferHandleAll(trip: TripModel?)
}


private class TripOffersRootView: UIView {
    var sheetBottom: CGFloat = 0
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if point.y > sheetBottom { return nil }
        return super.hitTest(point, with: event)
    }
}


@objcMembers class TripOffersViewContoller: BaseViewControllerSwift, AutoHideAlertDelegate, TripOfferCardViewDelegate, ConrraCarruselBannersDelegate {


    public var trip: TripModel?
    public weak var delegate: TripOffersViewContollerDelegate?


    private var tripOfferViewModel: TripOfferViewModel!
    private let tripOfferManager = TripOfferManager()


    private let sheetPanel       = UIView()
    private let spinner          = UIActivityIndicatorView(style: .gray)
    private let searchingLabel   = UILabel()
    private let cancelButton     = UIButton(type: .system)
    private let offersScrollView = UIScrollView()
    private var cardViews: [TripOfferCardView] = []


    /// Publicidad rotativa de la espera. Ver ConrraCarruselBanners.
    private let bannerCard      = UIView()
    private let bannerImageView = UIImageView()
    private var carrusel: ConrraCarruselBanners?
    private var bannerEnPantalla: ConrraBanner?
    /// Alto/ancho de la imagen que se esta enseñando. 0 mientras no haya ninguna cargada.
    private var bannerAspecto: CGFloat = 0


    private var refreshTimer: Timer?
    private var refreshOffersTimer: Timer?
    private var observerOfferNotification: NSObjectProtocol?
    private var autoHideDriverBusyAlert: AutoHideAlert?
    private var isShowingOffers = false


    override func loadView() {
        let root = TripOffersRootView()
        root.backgroundColor = .clear
        self.view = root
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen

        setupPanel()
        setupSearchingUI()
        setupScrollView()
        setupBannerUI()
        prepararCarruselDeBanners()
        applySearchingState(animated: false)

        tripOfferViewModel = TripOfferViewModel(tripOfferManager: tripOfferManager)
        tripOfferViewModel.trip = trip
        bindData()

        observerOfferNotification = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AppNotificationName.USER_OFFER_NOTIFICATION),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userinfo = notification.userInfo as? [String: Any],
                  let aps = userinfo["aps"] as? [String: Any],
                  let alertText = aps["alert"] as? String,
                  alertText.count > 1, alertText != "\0" else { return }
            let alert = UIAlertController(title: "", message: alertText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LanguageHelper.getStringWithKey("k_18_s4_Ok"), style: .default))
            self.present(alert, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripOfferViewModel.getTripOffers(isShowLoader: false)
        if trip?.is_ride_later == false {
            startTimer()
            startRefreshOffersTimer()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
        stopRefreshOffersTimer()
        // Sin esto el reloj del carrusel sigue vivo despues de cerrar la pantalla.
        carrusel?.parar()
    }

    deinit {
        carrusel?.parar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutPanel()
    }


    func onAutoHide(_ autoHideAlertHelper: AutoHideAlert) {
        if autoHideAlertHelper === autoHideDriverBusyAlert {
            tripOfferViewModel?.removeAllObserver()
            tripOfferViewModel = nil
            dismiss(animated: true) {
                self.delegate?.handleAfterTripRequestExpiredOrCancel(isShowAlert: true)
            }
        }
    }


    func cardViewDidTapAccept(_ view: TripOfferCardView, offer: TripOffer) {
        guard let trip = trip else { return }
        if trip.payment_card_id.count > 0 && trip.trip_pay_mode == CARD {
            var offerAmt: Float = 0.0
            if let amtStr = offer.offer_amt { offerAmt = Float(amtStr) ?? 0 }
            trip.createStripUserCreatePaymentIntentDone(self, trip_fare: offerAmt) { results, _ in
                if let res = results as? NSDictionary, let intentID = res.object(forKey: "id") as? String {
                    self.tripOfferViewModel.acceptTrip(tripOffer: offer, payment_intent_id: intentID, pay_mode: CARD)
                } else {
                    self.tripOfferViewModel.acceptTrip(tripOffer: offer, payment_intent_id: nil, pay_mode: CASH_PAY)
                }
            }
        } else if trip.trip_pay_mode == HIRE_ME_WALLET_PAY {
            if trip.is_ride_later {
                tripOfferViewModel.assignTrip(tripOffer: offer, payment_intent_id: nil, pay_mode: HIRE_ME_WALLET_PAY)
            } else {
                tripOfferViewModel.acceptTrip(tripOffer: offer, payment_intent_id: nil, pay_mode: HIRE_ME_WALLET_PAY)
            }
        } else {
            if trip.is_ride_later {
                tripOfferViewModel.assignTrip(tripOffer: offer, payment_intent_id: nil, pay_mode: CASH_PAY)
            } else {
                tripOfferViewModel.acceptTrip(tripOffer: offer, payment_intent_id: nil, pay_mode: CASH_PAY)
            }
        }
    }

    func cardViewDidTapDecline(_ view: TripOfferCardView, offer: TripOffer) {
        tripOfferViewModel.updateTripOffer(tripOffer: offer, status: "declined")
    }


    private func bindData() {
        tripOfferViewModel.tripOffer.bind { [weak self] offers in
            guard let self = self else { return }
            self.rebuildCards(offers: offers)
            if offers.isEmpty {
                self.applySearchingState(animated: true)
            } else {
                self.applyOffersState(animated: true)
            }
        }

        tripOfferViewModel.isTripUpdated.bind { [weak self] updated in
            guard let self = self, updated else { return }
            self.removeOfferNotificationObserver()
            let vm = self.tripOfferViewModel
            vm?.socektManger().disconnect()
            let status = self.trip?.trip_Status ?? ""
            if status == TS_USER_CANCEL {
                vm?.removeAllObserver()
                self.tripOfferViewModel = nil
                self.dismiss(animated: true) {
                    self.delegate?.handleAfterTripRequestExpiredOrCancel(isShowAlert: false)
                }
            } else if status == TS_EXPIRED {
                self.handleExpiredTrip()
            } else if status == TS_ASSIGNED {
                let result = vm?.trip
                vm?.removeAllObserver()
                self.tripOfferViewModel = nil
                self.dismiss(animated: false) {
                    self.delegate?.onTripOfferAssignedByRider(trip: result)
                }
            } else if status == TS_ACCEPTED {
                let result = vm?.trip
                vm?.removeAllObserver()
                self.tripOfferViewModel = nil
                self.dismiss(animated: true) {
                    self.delegate?.onTripOfferAcceptedByRider(trip: result)
                }
            } else if status != TS_REQUEST {
                let result = vm?.trip
                self.delegate?.onTripOfferHandleAll(trip: result)
            }
        }

        tripOfferViewModel.error.bind { [weak self] error in
            guard let self = self, let error = error else { return }
            Utilities.handleError(error, viewController: self, defaultMessage: "")
        }
    }


    private func setupPanel() {
        sheetPanel.backgroundColor = .white
        sheetPanel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        sheetPanel.layer.cornerRadius = 20
        sheetPanel.layer.shadowColor   = UIColor.black.cgColor
        sheetPanel.layer.shadowOpacity = 0.10
        sheetPanel.layer.shadowRadius  = 8
        sheetPanel.layer.shadowOffset  = CGSize(width: 0, height: 4)
        view.addSubview(sheetPanel)
    }

    private func setupSearchingUI() {
        spinner.color = UIColor(white: 0.3, alpha: 1)
        spinner.hidesWhenStopped = false
        sheetPanel.addSubview(spinner)

        searchingLabel.text = "Buscando Conductor..."
        searchingLabel.font = UIFont(name: "NotoSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        searchingLabel.textColor = UIColor(white: 0.3, alpha: 1)
        sheetPanel.addSubview(searchingLabel)

        cancelButton.setTitle("Cancelar Pedido", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "NotoSans-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
        cancelButton.layer.cornerRadius = 14
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        sheetPanel.addSubview(cancelButton)
    }

    private func setupScrollView() {
        offersScrollView.alwaysBounceVertical = true
        offersScrollView.showsVerticalScrollIndicator = false
        sheetPanel.addSubview(offersScrollView)
    }


    // MARK: - Publicidad de la espera

    private func setupBannerUI() {
        bannerCard.backgroundColor = .clear
        bannerCard.layer.cornerRadius = 12          // 12dp, igual que el CardView de Android
        bannerCard.clipsToBounds = true
        bannerCard.isHidden = true
        bannerCard.isUserInteractionEnabled = true
        bannerCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapBanner)))
        sheetPanel.addSubview(bannerCard)

        // fitCenter + adjustViewBounds en Android: la imagen manda su proporcion y el
        // hueco se adapta, en vez de recortarla.
        bannerImageView.contentMode = .scaleAspectFit
        bannerImageView.clipsToBounds = true
        bannerCard.addSubview(bannerImageView)
    }

    /**
     El reparto -- premium delante, sorteado dentro de cada plan -- lo decide el rele, no
     el telefono: asi se puede cambiar quien sale primero sin publicar una version nueva.

     Android pasa el city_id del usuario; aqui se usa el del viaje que se esta pidiendo,
     que es la misma ciudad y esta a mano. Si viene 0 se manda nil y el rele no filtra.
     */
    private func prepararCarruselDeBanners() {
        carrusel = ConrraCarruselBanners(delegado: self)
        let ciudadId = trip?.city_id ?? 0
        carrusel?.cargarYArrancar(ciudad: ciudadId > 0 ? String(ciudadId) : nil)
    }

    func carruselAlMostrar(banner: ConrraBanner) {
        guard let url = URL(string: banner.imagen) else { return }
        bannerImageView.sd_setImage(with: url, placeholderImage: nil) { [weak self] image, error, _, _ in
            guard let self = self,
                  let image = image,
                  error == nil,
                  image.size.width > 0 else {
                // Imagen rota o sin red: se deja lo que hubiera y el carrusel sigue con el
                // siguiente. Nunca se enseña el hueco vacio.
                return
            }
            self.bannerEnPantalla = banner
            self.bannerAspecto = image.size.height / image.size.width
            self.bannerCard.isHidden = false
            self.layoutPanel(animated: false)
            // Fundido corto: pasar de una imagen a otra de golpe se lee como un parpadeo
            // de error, no como un cambio de anuncio.
            self.bannerCard.alpha = 0
            UIView.animate(withDuration: 0.25) { self.bannerCard.alpha = 1 }
        }
    }

    func carruselAlQuedarSinBanners() {
        bannerCard.isHidden = true
        bannerAspecto = 0
        layoutPanel(animated: false)
    }

    @objc private func didTapBanner() {
        guard let destino = carrusel?.alPulsar(bannerEnPantalla),
              let url = URL(string: destino) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    /**
     Solo durante la espera.

     En Android el banner vive en el mismo layout con scroll que las ofertas y se queda
     puesto. Aqui el panel conmuta entre dos estados con alfa, asi que dejarlo en el de
     ofertas lo montaria encima del scroll. Las impresiones no se resienten: se cuenta una
     por banner y por espera, no una por vez que se ve.
     */
    private var hayBannerQueMostrar: Bool {
        return !isShowingOffers && !bannerCard.isHidden && bannerAspecto > 0
    }

    /// Alto conservando la proporcion de la imagen, como el adjustViewBounds de Android.
    private func alturaDelBanner(ancho: CGFloat) -> CGFloat {
        guard bannerAspecto > 0 else { return 0 }
        // Un anuncio muy alto empujaria el boton de cancelar fuera de la pantalla.
        return min(ancho * bannerAspecto, UIScreen.main.bounds.height * 0.28)
    }


    private func applySearchingState(animated: Bool) {
        isShowingOffers = false
        spinner.startAnimating()
        let duration = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration) {
            self.spinner.alpha       = 1
            self.searchingLabel.alpha = 1
            self.cancelButton.alpha  = 1
            self.offersScrollView.alpha = 0
        }
        layoutPanel(animated: animated)
    }

    private func applyOffersState(animated: Bool) {
        isShowingOffers = true
        let duration = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration) {
            self.spinner.alpha       = 0
            self.searchingLabel.alpha = 0
            self.cancelButton.alpha  = 0
            self.offersScrollView.alpha = 1
        }
        spinner.stopAnimating()
        layoutPanel(animated: animated)
    }


    private func layoutPanel(animated: Bool = false) {
        let w        = view.bounds.width
        guard w > 0 else { return }
        let safeTop  = view.safeAreaInsets.top
        let screenH  = UIScreen.main.bounds.height

        let panelH: CGFloat
        if isShowingOffers {
            let count   = CGFloat(max(cardViews.count, 1))
            let cardsH  = count * TripOfferCardView.cardHeight + (count - 1) * 12
            panelH = min(safeTop + 16 + cardsH + 16, screenH * 0.72)
        } else {
            // safeTop + spinner/label row + gap + button + bottom pad
            //
            // Se acumula en una variable aparte porque panelH es un 'let' con
            // inicializacion diferida: admite UNA asignacion, no un +=.
            var alto = safeTop + 40 + 20 + 56 + 24
            if hayBannerQueMostrar {
                alto += alturaDelBanner(ancho: w - 32) + 12
            }
            panelH = alto
        }

        let rootView = view as! TripOffersRootView

        let apply = {
            self.sheetPanel.frame = CGRect(x: 0, y: 0, width: w, height: panelH)
            rootView.sheetBottom  = panelH

            // Searching UI
            let rowCenterY = safeTop + 20 + 10   // 10 = half of 20pt spinner
            let spinnerSize: CGFloat = 20
            let labelW: CGFloat      = 210
            let rowW = spinnerSize + 8 + labelW
            let rowX = (w - rowW) / 2
            self.spinner.frame       = CGRect(x: rowX, y: rowCenterY, width: spinnerSize, height: spinnerSize)
            self.searchingLabel.frame = CGRect(x: rowX + spinnerSize + 8, y: rowCenterY, width: labelW, height: 20)
            let btnY = self.spinner.frame.maxY + 20
            self.cancelButton.frame  = CGRect(x: 16, y: btnY, width: w - 32, height: 56)

            // Publicidad, debajo del boton de cancelar.
            if self.hayBannerQueMostrar {
                let anchoBanner = w - 32
                let altoBanner  = self.alturaDelBanner(ancho: anchoBanner)
                self.bannerCard.frame = CGRect(x: 16,
                                               y: self.cancelButton.frame.maxY + 12,
                                               width: anchoBanner,
                                               height: altoBanner)
                self.bannerImageView.frame = self.bannerCard.bounds
                self.bannerCard.alpha = 1
            } else {
                self.bannerCard.alpha = 0
            }

            // Scroll view
            let scrollY: CGFloat = safeTop + 8
            self.offersScrollView.frame = CGRect(x: 0, y: scrollY, width: w, height: panelH - scrollY)
            self.layoutCards(cardWidth: w - 32)
        }

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: apply)
        } else {
            apply()
        }
    }

    private func layoutCards(cardWidth: CGFloat) {
        var yOffset: CGFloat = 8
        for card in cardViews {
            card.frame = CGRect(x: 16, y: yOffset, width: cardWidth, height: TripOfferCardView.cardHeight)
            yOffset += TripOfferCardView.cardHeight + 12
        }
        offersScrollView.contentSize = CGSize(width: offersScrollView.bounds.width, height: yOffset)
    }


    private func rebuildCards(offers: [TripOffer]) {
        let currentIds = Set(offers.map { $0.trip_request_id })

        // Remove stale cards
        cardViews.removeAll { card in
            if !currentIds.contains(card.tripOffer.trip_request_id) {
                card.removeFromSuperview()
                return true
            }
            return false
        }

        // Add new cards
        let existingIds = Set(cardViews.map { $0.tripOffer.trip_request_id })
        for offer in offers where !existingIds.contains(offer.trip_request_id) {
            let card = TripOfferCardView(offer: offer, trip: trip)
            card.delegate = self
            offersScrollView.addSubview(card)
            cardViews.append(card)
        }
    }


    private func startTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(timeInterval: 1,
                                            target: self,
                                            selector: #selector(timerTick),
                                            userInfo: nil,
                                            repeats: true)
        RunLoop.current.add(refreshTimer!, forMode: .common)
    }

    private func stopTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private static let refreshOffersInterval: TimeInterval = 10

    private func startRefreshOffersTimer() {
        stopRefreshOffersTimer()
        refreshOffersTimer = Timer.scheduledTimer(timeInterval: Self.refreshOffersInterval,
                                                 target: self,
                                                 selector: #selector(refreshOffersTimerTick),
                                                 userInfo: nil,
                                                 repeats: true)
        RunLoop.current.add(refreshOffersTimer!, forMode: .common)
    }

    private func stopRefreshOffersTimer() {
        refreshOffersTimer?.invalidate()
        refreshOffersTimer = nil
    }

    @objc private func refreshOffersTimerTick() {
        tripOfferViewModel?.getTripOffers(isShowLoader: false)
    }

    @objc private func timerTick() {
        guard let vm = tripOfferViewModel else { return }
        for offer in vm.tripOffer.value {
            offer.count -= 1
            if offer.count < 1 {
                vm.updateTripOffer(tripOffer: offer, status: "missed", isShowLoader: false)
            }
        }
        for card in cardViews {
            card.updateProgress()
        }
    }


    @objc private func didTapCancel() {
        let alert = UIAlertController(title: "",
                                      message: LanguageHelper.getStringWithKey("k_r16_s8_cancel_trip_now"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LanguageHelper.getStringWithKey("k_22_s4_no"), style: .default))
        alert.addAction(UIAlertAction(title: LanguageHelper.getStringWithKey("k_21_s4_yes"), style: .default) { _ in
            self.tripOfferViewModel.socektManger().disconnect()
            self.tripOfferViewModel.cancelTrip()
        })
        present(alert, animated: true)
    }


    private func handleExpiredTrip() {
        let message = LanguageHelper.getStringWithKey("k_r37_s3_driver_busy")
        guard message.count > 0 else { return }
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LanguageHelper.getStringWithKey("k_18_s4_Ok"), style: .default) { _ in
            self.autoHideDriverBusyAlert?.performAction()
            self.tripOfferViewModel?.removeAllObserver()
            self.tripOfferViewModel = nil
            self.dismiss(animated: true) {
                self.delegate?.handleAfterTripRequestExpiredOrCancel(isShowAlert: true)
            }
        })
        present(alert, animated: true)
        autoHideDriverBusyAlert = AutoHideAlert()
        autoHideDriverBusyAlert?.handle(alert)
        autoHideDriverBusyAlert?.delegate = self
    }


    private func removeOfferNotificationObserver() {
        if let observer = observerOfferNotification {
            NotificationCenter.default.removeObserver(observer)
            observerOfferNotification = nil
        }
    }
}
