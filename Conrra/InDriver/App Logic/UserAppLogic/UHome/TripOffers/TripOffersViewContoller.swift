//
//  TripOffersViewContoller.swift
//  Conrra
//
//  Programmatic rewrite — OverFullScreen modal.
//  Transparent background lets UHomeViewController's live map + radar show through.
//
//  Copia la pantalla de Android (activity_offers.xml + OffersActivity):
//  cabecera FLOTANTE sobre el mapa y hoja ABAJO. Antes estaba todo en una tarjeta
//  blanca pegada arriba, que tapaba la mitad del mapa justo donde late el radar.
//
//  Estado 1 (esperando): hoja con publicidad, direcciones, ajustador de oferta y
//                        boton de enviar. La cabecera flota sobre el mapa.
//  Estado 2 (ofertas):   la hoja se vuelve transparente y solo quedan las tarjetas;
//                        la cabecera desaparece, igual que en Android.
//

import UIKit


@objc protocol TripOffersViewContollerDelegate {
    func handleAfterTripRequestExpiredOrCancel(isShowAlert: Bool)
    func onTripOfferAcceptedByRider(trip: TripModel?)
    func onTripOfferAssignedByRider(trip: TripModel?)
    func onTripOfferHandleAll(trip: TripModel?)

    /**
     Cuanto mapa tapa la hoja.

     El mapa vive en la pantalla de abajo, que no sabe nada de esta: sin este aviso
     encuadra la recogida contra la pantalla entera y la deja justo detras de la hoja.
     Android hace lo mismo midiendo el solape real (ajustarEncuadre).
     */
    @objc optional func tripOffersDidLayoutSheet(withHeight height: CGFloat)
}


/**
 Deja pasar los toques al mapa de detras.

 Antes se comparaba contra una altura -- todo lo que cayera por debajo de la hoja
 pasaba. Ya no vale: ahora hay cosas arriba (la cabecera) y abajo (la hoja) con mapa
 en medio. Se mira QUE vista respondio: si es la raiz o el hueco de la cabecera, ahi
 no hay nada que tocar y el toque sigue su camino. Es lo que hace Android sin pedirlo,
 porque un ViewGroup sin nada encima no consume el evento.
 */
private class TripOffersRootView: UIView {
    weak var contenedorTransparente: UIView?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let vista = super.hitTest(point, with: event)
        if vista === self || vista === contenedorTransparente { return nil }
        return vista
    }
}


@objcMembers class TripOffersViewContoller: BaseViewControllerSwift, AutoHideAlertDelegate, TripOfferCardViewDelegate, ConrraCarruselBannersDelegate {


    public var trip: TripModel?
    public weak var delegate: TripOffersViewContollerDelegate?


    private var tripOfferViewModel: TripOfferViewModel!
    private let tripOfferManager = TripOfferManager()


    private let sheetPanel       = UIView()
    private let offersScrollView = UIScrollView()
    private var cardViews: [TripOfferCardView] = []

    /// Cabecera flotante sobre el mapa: volver, titulo y cancelar.
    private let cabecera       = UIView()
    private let btnAtras       = UIButton(type: .system)
    private let searchingLabel = UILabel()
    private let cancelButton   = UIButton(type: .system)

    /// Contenido de la hoja de abajo.
    private let asa             = UIView()
    private let tarjetaViaje    = UIView()
    private let puntoRecogida   = UIView()
    private let lineaUnion      = UIView()
    private let puntoDestino    = UIView()
    private let lblRecogida     = UILabel()
    private let lblNotas        = UILabel()
    private let lblDestino      = UILabel()
    private let lblTuOferta     = UILabel()
    private let btnMenos        = UIButton(type: .custom)
    private let lblMonto        = UILabel()
    private let btnMas          = UIButton(type: .custom)
    private let lblConversion   = UILabel()
    private let btnEnviarOferta = UIButton(type: .custom)

    /// Lo que el viaje tiene ofrecido AHORA, ya confirmado por el servidor.
    private var montoOfrecido: Float = 0
    /// Lo que marca el ajustador, que puede ir por delante de lo confirmado.
    private var montoDelAjustador: Float = 0
    private var pasoDeOferta: Float = 0.5
    private var ofertaMinima: Float = 0
    private var ofertaMaxima: Float = 0
    private var hayTopes = false
    private var moneda = "$"
    /// El ultimo alto de hoja que se le conto al mapa, para no repetir el aviso.
    private var altoAvisadoAlMapa: CGFloat = -1


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
        setupCabecera()
        setupContenidoDeLaHoja()
        setupScrollView()
        setupBannerUI()
        prepararCarruselDeBanners()
        prepararOferta()
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
        // Redondeada por ARRIBA: la hoja sube desde el borde de abajo.
        sheetPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetPanel.layer.cornerRadius = 20
        sheetPanel.layer.shadowColor   = UIColor.black.cgColor
        sheetPanel.layer.shadowOpacity = 0.10
        sheetPanel.layer.shadowRadius  = 8
        sheetPanel.layer.shadowOffset  = CGSize(width: 0, height: -4)
        view.addSubview(sheetPanel)
    }

    /**
     La cabecera va DIRECTA sobre el mapa, sin caja blanca detras.

     El titulo lleva un halo blanco en vez de fondo: sobre un mapa claro un texto
     oscuro sin nada se pierde en las calles, y una barra opaca robaria el trozo de
     mapa donde justo late el radar. Es lo mismo que hace Android con shadowColor.
     */
    private func setupCabecera() {
        cabecera.backgroundColor = .clear
        view.addSubview(cabecera)
        (view as? TripOffersRootView)?.contenedorTransparente = cabecera

        btnAtras.backgroundColor = UIColor(white: 0.13, alpha: 1)
        btnAtras.tintColor = .white
        btnAtras.layer.cornerRadius = 23
        btnAtras.clipsToBounds = true
        btnAtras.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btnAtras.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        cabecera.addSubview(btnAtras)

        searchingLabel.text = "Buscando Conductor..."
        searchingLabel.font = UIFont(name: "NotoSans-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        searchingLabel.textColor = UIColor(white: 0.10, alpha: 1)
        searchingLabel.textAlignment = .center
        searchingLabel.adjustsFontSizeToFitWidth = true
        searchingLabel.minimumScaleFactor = 0.72
        searchingLabel.layer.shadowColor = UIColor.white.cgColor
        searchingLabel.layer.shadowOpacity = 1
        searchingLabel.layer.shadowRadius = 6
        searchingLabel.layer.shadowOffset = .zero
        cabecera.addSubview(searchingLabel)

        // Pastilla blanca propia: en rojo sobre el mapa no se leeria.
        cancelButton.setTitle("Cancelar Pedido", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "NotoSans-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        cancelButton.setTitleColor(UIColor(red: 0.922, green: 0.341, blue: 0.341, alpha: 1), for: .normal)
        cancelButton.backgroundColor = UIColor(white: 1, alpha: 0.92)
        cancelButton.layer.cornerRadius = 23
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        cabecera.addSubview(cancelButton)
    }

    private func setupContenidoDeLaHoja() {
        let oscuro = UIColor(white: 0.157, alpha: 1)
        let gris   = UIColor(white: 0.45, alpha: 1)
        let borde  = UIColor(white: 0.878, alpha: 1)

        asa.backgroundColor = UIColor(white: 0.85, alpha: 1)
        asa.layer.cornerRadius = 2
        sheetPanel.addSubview(asa)

        // --- Tarjeta de las direcciones ---
        tarjetaViaje.layer.borderWidth = 1
        tarjetaViaje.layer.borderColor = borde.cgColor
        tarjetaViaje.layer.cornerRadius = 12
        sheetPanel.addSubview(tarjetaViaje)

        puntoRecogida.backgroundColor = UIColor(red: 0.18, green: 0.72, blue: 0.35, alpha: 1)
        puntoRecogida.layer.cornerRadius = 6
        tarjetaViaje.addSubview(puntoRecogida)

        lineaUnion.backgroundColor = borde
        tarjetaViaje.addSubview(lineaUnion)

        puntoDestino.backgroundColor = UIColor(red: 0.90, green: 0.25, blue: 0.25, alpha: 1)
        puntoDestino.layer.cornerRadius = 6
        tarjetaViaje.addSubview(puntoDestino)

        lblRecogida.font = UIFont(name: "NotoSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        lblRecogida.textColor = oscuro
        lblRecogida.numberOfLines = 2
        tarjetaViaje.addSubview(lblRecogida)

        lblNotas.font = UIFont(name: "NotoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        lblNotas.textColor = gris
        lblNotas.numberOfLines = 2
        tarjetaViaje.addSubview(lblNotas)

        lblDestino.font = UIFont(name: "NotoSans-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        lblDestino.textColor = gris
        lblDestino.numberOfLines = 2
        tarjetaViaje.addSubview(lblDestino)

        // --- Ajustador ---
        lblTuOferta.font = UIFont(name: "NotoSans-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        lblTuOferta.textColor = oscuro
        sheetPanel.addSubview(lblTuOferta)

        prepararBotonDeAjuste(btnMenos, accion: #selector(bajarOferta))
        prepararBotonDeAjuste(btnMas,   accion: #selector(subirOferta))
        sheetPanel.addSubview(btnMenos)
        sheetPanel.addSubview(btnMas)

        lblMonto.font = UIFont(name: "NotoSans-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28)
        lblMonto.textColor = oscuro
        lblMonto.textAlignment = .center
        lblMonto.adjustsFontSizeToFitWidth = true
        lblMonto.minimumScaleFactor = 0.6
        sheetPanel.addSubview(lblMonto)

        lblConversion.font = UIFont(name: "NotoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        lblConversion.textColor = gris
        lblConversion.textAlignment = .center
        sheetPanel.addSubview(lblConversion)

        btnEnviarOferta.titleLabel?.font = UIFont(name: "NotoSans-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        btnEnviarOferta.layer.cornerRadius = 14
        btnEnviarOferta.clipsToBounds = true
        btnEnviarOferta.addTarget(self, action: #selector(enviarOferta), for: .touchUpInside)
        sheetPanel.addSubview(btnEnviarOferta)
    }

    private func prepararBotonDeAjuste(_ boton: UIButton, accion: Selector) {
        boton.backgroundColor = UIColor(white: 0.93, alpha: 1)
        boton.layer.cornerRadius = 24
        boton.clipsToBounds = true
        boton.titleLabel?.font = UIFont(name: "NotoSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        boton.setTitleColor(UIColor(white: 0.35, alpha: 1), for: .normal)
        boton.addTarget(self, action: accion, for: .touchUpInside)
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
        let duration = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration) {
            self.cabecera.alpha = 1
            self.contenidoDeLaHoja.forEach { $0.alpha = 1 }
            self.offersScrollView.alpha = 0
            self.sheetPanel.backgroundColor = .white
        }
        layoutPanel(animated: animated)
    }

    /**
     Llego al menos una oferta.

     La hoja se queda sin fondo y solo viajan las tarjetas, y la cabecera desaparece:
     es lo que hace Android (noResultText), y tiene sentido -- ya no se esta buscando
     nada, hay algo que elegir, y las tarjetas traen su propio boton de cancelar.
     */
    private func applyOffersState(animated: Bool) {
        isShowingOffers = true
        let duration = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration) {
            self.cabecera.alpha = 0
            self.contenidoDeLaHoja.forEach { $0.alpha = 0 }
            self.offersScrollView.alpha = 1
            self.sheetPanel.backgroundColor = .clear
        }
        layoutPanel(animated: animated)
    }

    /// Todo lo que vive dentro de la hoja mientras se espera.
    private var contenidoDeLaHoja: [UIView] {
        return [asa, bannerCard, tarjetaViaje, lblTuOferta,
                btnMenos, lblMonto, btnMas, lblConversion, btnEnviarOferta]
    }


    // MARK: - Encuadre

    private static let padLateral: CGFloat = 24
    private static let altoCabecera: CGFloat = 46

    private func layoutPanel(animated: Bool = false) {
        let w = view.bounds.width
        let h = view.bounds.height
        guard w > 0 else { return }
        let safeTop    = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom

        let panelH: CGFloat
        if isShowingOffers {
            let count  = CGFloat(max(cardViews.count, 1))
            let cardsH = count * TripOfferCardView.cardHeight + (count - 1) * 12
            panelH = min(cardsH + 16 + safeBottom, h * 0.72)
        } else {
            panelH = min(altoDelContenido(ancho: w) + safeBottom, h * 0.78)
        }

        let apply = {
            // --- Cabecera flotante ---
            let alto = Self.altoCabecera
            self.cabecera.frame = CGRect(x: 0, y: safeTop + 16, width: w, height: alto)
            self.btnAtras.frame = CGRect(x: 16, y: 0, width: alto, height: alto)

            let anchoCancelar = min(max(self.cancelButton.intrinsicContentSize.width + 32, 100), w * 0.45)
            self.cancelButton.frame = CGRect(x: w - 16 - anchoCancelar, y: 0,
                                             width: anchoCancelar, height: alto)
            let xTitulo = self.btnAtras.frame.maxX + 8
            self.searchingLabel.frame = CGRect(x: xTitulo, y: 0,
                                               width: max(0, self.cancelButton.frame.minX - 8 - xTitulo),
                                               height: alto)

            // --- La hoja, pegada abajo ---
            self.sheetPanel.frame = CGRect(x: 0, y: h - panelH, width: w, height: panelH)
            self.colocarContenido(ancho: w)

            self.offersScrollView.frame = CGRect(x: 0, y: 0, width: w, height: panelH - safeBottom)
            self.layoutCards(cardWidth: w - 32)
        }

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: apply)
        } else {
            apply()
        }

        avisarAlMapaDelAlto(panelH)
    }

    /**
     Le cuenta al mapa cuanto le tapa la hoja.

     Solo cuando cambia: el aviso mueve la camara, y repetirlo en cada pasada de
     encuadre dejaria el mapa dando tirones.

     Se manda el alto tambien con las ofertas puestas, aunque entonces la hoja no
     tenga fondo: lo que tapa la recogida son las tarjetas, y ser transparente no la
     descubre. Android mide igual, por posicion en pantalla y no por color.
     */
    private func avisarAlMapaDelAlto(_ alto: CGFloat) {
        guard abs(alto - altoAvisadoAlMapa) > 1 else { return }
        altoAvisadoAlMapa = alto
        delegate?.tripOffersDidLayoutSheet?(withHeight: alto)
    }

    /// Lo que mide el contenido de la hoja. Se calcula antes de colocar nada.
    private func altoDelContenido(ancho w: CGFloat) -> CGFloat {
        let cw = w - Self.padLateral * 2
        var y: CGFloat = 10
        y += 4 + 12                                   // asa
        if hayBannerQueMostrar {
            y += alturaDelBanner(ancho: cw) + 12
        }
        y += altoDeLaTarjetaDeViaje(ancho: cw) + 12
        y += 20 + 10                                  // "tu ofreciste (...)"
        y += 48 + 6                                   // ajustador
        // Sin tasa configurada la conversion no se enseña y tampoco deja su hueco,
        // igual que el GONE de Android: un blanco a media hoja se lee como que falta algo.
        y += lblConversion.isHidden ? 10 : (16 + 16)
        y += 56 + 20                                  // enviar oferta
        return y
    }

    private func altoDeLaTarjetaDeViaje(ancho cw: CGFloat) -> CGFloat {
        let anchoTexto = cw - 24 - 24
        var alto: CGFloat = 12
        alto += altoDeTexto(lblRecogida, ancho: anchoTexto)
        if !(lblNotas.text ?? "").isEmpty {
            alto += 6 + altoDeTexto(lblNotas, ancho: anchoTexto)
        }
        alto += 8 + altoDeTexto(lblDestino, ancho: anchoTexto)
        alto += 12
        return max(alto, 64)
    }

    private func altoDeTexto(_ etiqueta: UILabel, ancho: CGFloat) -> CGFloat {
        guard let texto = etiqueta.text, !texto.isEmpty, ancho > 0 else { return 0 }
        let fuente = etiqueta.font ?? UIFont.systemFont(ofSize: 14)
        let tope = fuente.lineHeight * CGFloat(max(etiqueta.numberOfLines, 1))
        let medida = (texto as NSString).boundingRect(
            with: CGSize(width: ancho, height: tope + 2),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: fuente],
            context: nil)
        return ceil(min(medida.height, tope))
    }

    private func colocarContenido(ancho w: CGFloat) {
        let pad = Self.padLateral
        let cw  = w - pad * 2
        var y: CGFloat = 10

        asa.frame = CGRect(x: (w - 40) / 2, y: y, width: 40, height: 4)
        y += 4 + 12

        if hayBannerQueMostrar {
            let altoBanner = alturaDelBanner(ancho: cw)
            bannerCard.frame = CGRect(x: pad, y: y, width: cw, height: altoBanner)
            bannerImageView.frame = bannerCard.bounds
            y += altoBanner + 12
        }

        let altoTarjeta = altoDeLaTarjetaDeViaje(ancho: cw)
        tarjetaViaje.frame = CGRect(x: pad, y: y, width: cw, height: altoTarjeta)
        colocarTarjetaDeViaje(ancho: cw)
        y += altoTarjeta + 12

        lblTuOferta.frame = CGRect(x: pad, y: y, width: cw, height: 20)
        y += 20 + 10

        let ladoBoton: CGFloat = 48
        let anchoBoton: CGFloat = 96
        btnMenos.frame = CGRect(x: pad, y: y, width: anchoBoton, height: ladoBoton)
        btnMas.frame   = CGRect(x: w - pad - anchoBoton, y: y, width: anchoBoton, height: ladoBoton)
        lblMonto.frame = CGRect(x: btnMenos.frame.maxX + 8, y: y,
                                width: max(0, btnMas.frame.minX - btnMenos.frame.maxX - 16),
                                height: ladoBoton)
        y += ladoBoton + 6

        if lblConversion.isHidden {
            lblConversion.frame = CGRect(x: pad, y: y, width: cw, height: 0)
            y += 10
        } else {
            lblConversion.frame = CGRect(x: pad, y: y, width: cw, height: 16)
            y += 16 + 16
        }

        btnEnviarOferta.frame = CGRect(x: pad, y: y, width: cw, height: 56)
    }

    private func colocarTarjetaDeViaje(ancho cw: CGFloat) {
        let anchoTexto = cw - 24 - 24
        var y: CGFloat = 12

        let altoRecogida = altoDeTexto(lblRecogida, ancho: anchoTexto)
        lblRecogida.frame = CGRect(x: 48, y: y, width: anchoTexto, height: altoRecogida)
        puntoRecogida.frame = CGRect(x: 18, y: y + 4, width: 12, height: 12)
        y += altoRecogida

        if !(lblNotas.text ?? "").isEmpty {
            let altoNotas = altoDeTexto(lblNotas, ancho: anchoTexto)
            lblNotas.frame = CGRect(x: 48, y: y + 6, width: anchoTexto, height: altoNotas)
            y += 6 + altoNotas
        } else {
            lblNotas.frame = .zero
        }

        let altoDestino = altoDeTexto(lblDestino, ancho: anchoTexto)
        lblDestino.frame = CGRect(x: 48, y: y + 8, width: anchoTexto, height: altoDestino)
        puntoDestino.frame = CGRect(x: 18, y: y + 8 + 4, width: 12, height: 12)

        lineaUnion.frame = CGRect(x: 23.5,
                                  y: puntoRecogida.frame.maxY + 2,
                                  width: 1,
                                  height: max(0, puntoDestino.frame.minY - puntoRecogida.frame.maxY - 4))
    }


    // MARK: - La oferta

    /**
     Prepara el ajustador con lo que el viaje ya tiene pedido.

     Los topes se miden contra base_est_amt, la estimacion original, NO contra lo que
     se lleva ofrecido: si se midieran contra el importe vivo, cada subida arrastraria
     el techo con ella y no habria tope ninguno. Es lo que hace Android.
     */
    private func prepararOferta() {
        // city_cur llega de Objective-C sin anotar, asi que puede ser nil aunque Swift
        // lo trate como si no: se compara sobre una copia ya desenvuelta.
        let simbolo = CityModel.getCityByCityId(Int(trip?.city_id ?? 0))?.city_cur ?? ""
        if !simbolo.isEmpty {
            moneda = simbolo
        }

        montoOfrecido     = Float(trip?.trip_fare ?? "0") ?? 0
        montoDelAjustador = montoOfrecido

        // El paso viene del servidor partido entre diez, igual que Android.
        let paso = ConstantModel.getConstantsObject()?.offer_step_amount ?? 0
        pasoDeOferta = paso > 0 ? paso / 10.0 : 0.5

        let base = Float(trip?.base_est_amt ?? "0") ?? 0
        if base > 0, let cat = CategoryModel.getCategoryByid(Int32(trip?.category_id ?? "") ?? 0),
           cat.min_offer_perc > -1, cat.max_offer_perc > -1 {
            ofertaMinima = base - base * cat.min_offer_perc / 100.0
            ofertaMaxima = base + base * cat.max_offer_perc / 100.0
            hayTopes = true
        }

        lblRecogida.text = trip?.trip_pick_loc ?? ""
        lblDestino.text  = trip?.trip_drop_loc ?? ""
        lblNotas.text    = notasDeRecogida()

        btnMenos.setTitle(String(format: "- %.2f", pasoDeOferta), for: .normal)
        btnMas.setTitle(String(format: "+ %.2f", pasoDeOferta), for: .normal)
        refrescarTextosDeLaOferta()
    }

    /**
     Lo que se configuro al pedir, para que el pasajero lo tenga delante.

     Llega en pickup_notes con el formato "Cash|Mascotas|3 Pasajero(s)". Se enseña con
     las barras cambiadas por comas: son campos de una sola cadena, no una lista que
     el pasajero deba leer separada.
     */
    private func notasDeRecogida() -> String {
        let notas = (trip?.pickup_notes ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !notas.isEmpty else { return "" }
        let partes = notas.split(separator: "|").map {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter { !$0.isEmpty }
        guard !partes.isEmpty else { return "" }
        return String(format: "%@ %@",
                      LanguageHelper.getStringWithKey("k_1_s8_special_notes", defaultValue: "Notas:"),
                      partes.joined(separator: ", "))
    }

    @objc private func bajarOferta() { moverOferta(-pasoDeOferta) }
    @objc private func subirOferta()  { moverOferta(pasoDeOferta) }

    private func moverOferta(_ delta: Float) {
        let tentativo = montoDelAjustador + delta
        if hayTopes && tentativo < ofertaMinima {
            montoDelAjustador = ofertaMinima
            avisar(LanguageHelper.getStringWithKey("k_r1_s6_pls_ntr_amnt_grtr_thn_min_fare"))
        } else if hayTopes && tentativo > ofertaMaxima {
            montoDelAjustador = ofertaMaxima
            avisar(LanguageHelper.getStringWithKey("k_r1_s6_pls_ntr_amnt_less_thn_max_fare"))
        } else {
            montoDelAjustador = max(tentativo, 0)
        }
        refrescarTextosDeLaOferta()
    }

    /**
     Pinta el importe en los tres sitios donde sale y decide si se puede enviar.

     El boton se apaga cuando el ajustador marca lo mismo que ya esta ofrecido: no hay
     nada que mandar, y un boton vivo que no hace nada se lee como que el envio fallo.
     */
    private func refrescarTextosDeLaOferta() {
        let importe = Utilities.formatAmountAndCurrency(montoDelAjustador, currency: moneda) ?? ""

        lblMonto.text = importe
        lblTuOferta.text = String(format: "%@ (%@)",
                                  LanguageHelper.getStringWithKey("k_1_s9_ur_ofr", defaultValue: "tu ofreciste"),
                                  importe)
        btnEnviarOferta.setTitle(String(format: "%@ (%@)",
                                        LanguageHelper.getStringWithKey("k_63_s4_vw_snd_ofr", defaultValue: "Enviar oferta"),
                                        importe), for: .normal)

        let sePuedeEnviar = abs(montoDelAjustador - montoOfrecido) > 0.001
        btnEnviarOferta.isEnabled = sePuedeEnviar
        btnEnviarOferta.backgroundColor = sePuedeEnviar
            ? (UIColor(named: "app_theame") ?? UIColor(red: 0.922, green: 0.710, blue: 0.094, alpha: 1))
            : UIColor(white: 0.72, alpha: 1)
        btnEnviarOferta.setTitleColor(sePuedeEnviar ? .black : UIColor(white: 0.35, alpha: 1), for: .normal)

        let tasa = ConstantModel.tasaDolarALocal()
        if tasa > 0 {
            let formato = NumberFormatter()
            formato.numberStyle = .decimal
            formato.minimumFractionDigits = 2
            formato.maximumFractionDigits = 2
            let local = formato.string(from: NSNumber(value: montoDelAjustador * tasa)) ?? ""
            lblConversion.text = String(format: "%@ Bs %@",
                                        LanguageHelper.getStringWithKey("k_s10_conversion", defaultValue: "Conversión:"),
                                        local)
            lblConversion.isHidden = false
        } else {
            lblConversion.text = ""
            lblConversion.isHidden = true
        }
    }

    @objc private func enviarOferta() {
        guard let trip = trip, montoDelAjustador > 0 else { return }
        tripOfferManager.updateTripPayAmount(trip: trip, amount: montoDelAjustador) { [weak self] results, error in
            guard let self = self else { return }
            if error != nil || results == nil {
                self.avisar(LanguageHelper.getStringWithKey("k_r29_s3_smthing_wnt_wrng",
                                                            defaultValue: "Algo salió mal, inténtalo de nuevo"))
                return
            }
            // El viaje pasa a valer lo ofrecido: es contra esto contra lo que el boton
            // decide si queda algo por mandar.
            self.montoOfrecido = self.montoDelAjustador
            self.trip?.trip_fare = String(format: "%.2f", self.montoDelAjustador)
            self.refrescarTextosDeLaOferta()
        }
    }

    private func avisar(_ mensaje: String) {
        guard !mensaje.isEmpty, presentedViewController == nil else { return }
        let alerta = UIAlertController(title: "", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: LanguageHelper.getStringWithKey("k_18_s4_Ok", defaultValue: "OK"),
                                       style: .default))
        present(alerta, animated: true)
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
