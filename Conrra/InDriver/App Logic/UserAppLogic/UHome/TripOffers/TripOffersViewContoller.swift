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

    /**
     La paleta de Android, valor por valor (res/values/colors.xml).

     Se copian los numeros en vez de tirar de los colores del catalogo de iOS: los
     nombres no se corresponden uno a uno entre las dos apps, y la unica forma de que
     las dos pantallas se vean iguales es partir de la misma tinta.
     */
    private enum Tinta {
        static let textoPrimario  = UIColor(red: 0x21/255.0, green: 0x21/255.0, blue: 0x21/255.0, alpha: 1) // neutral_900
        static let textoTerciario = UIColor(red: 0x69/255.0, green: 0x69/255.0, blue: 0x69/255.0, alpha: 1) // neutral_500
        static let bordeSuave     = UIColor(red: 0xEF/255.0, green: 0xEF/255.0, blue: 0xEF/255.0, alpha: 1) // neutral_150
        static let asa            = UIColor(red: 0xC8/255.0, green: 0xC8/255.0, blue: 0xC8/255.0, alpha: 1) // neutral_300
        static let verde          = UIColor(red: 0x54/255.0, green: 0xAB/255.0, blue: 0x47/255.0, alpha: 1) // state_success
        static let rojo           = UIColor(red: 0xEB/255.0, green: 0x54/255.0, blue: 0x4D/255.0, alpha: 1) // state_error
        static let rojoCancelar   = UIColor(red: 0xEB/255.0, green: 0x57/255.0, blue: 0x57/255.0, alpha: 1) // tvCancel
        static let amarillo       = UIColor(red: 0xEB/255.0, green: 0xB5/255.0, blue: 0x18/255.0, alpha: 1) // brand_yellow_400
        static let grisAjustador  = UIColor(red: 0xE0/255.0, green: 0xE0/255.0, blue: 0xE0/255.0, alpha: 1) // bg_stepper_button
        static let grisApagado    = UIColor(red: 0x69/255.0, green: 0x69/255.0, blue: 0x69/255.0, alpha: 1) // rounded_corner_grey
    }

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
    /// El simbolo y el numero van aparte, como en Android (tvStepperCurrency + etStepper).
    private let lblMoneda       = UILabel()
    private let txtMonto        = UITextField()
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
        sheetPanel.layer.cornerRadius = 24              // radius_2xl
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

        btnAtras.backgroundColor = Tinta.textoPrimario
        btnAtras.tintColor = .white
        btnAtras.layer.cornerRadius = 23
        btnAtras.clipsToBounds = true
        btnAtras.setImage(UIImage(systemName: "arrow.left") ?? UIImage(systemName: "chevron.left"), for: .normal)
        btnAtras.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        // Android lo esconde en los viajes normales y solo lo deja en los programados
        // (noti_Back.visibility). En un viaje que se acaba de pedir, volver atras no
        // lleva a ningun sitio: lo que hay que hacer es cancelar, y eso ya esta al lado.
        btnAtras.isHidden = !(trip?.is_ride_later ?? false)
        cabecera.addSubview(btnAtras)

        searchingLabel.text = "Buscando Conductor..."
        // autoSize uniforme de 13 a 18 en Android: aqui, la mayor y que encoja hasta 13.
        searchingLabel.font = UIFont(name: "NotoSans-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        searchingLabel.textColor = Tinta.textoPrimario
        searchingLabel.textAlignment = .center
        searchingLabel.numberOfLines = 1
        searchingLabel.lineBreakMode = .byTruncatingTail
        searchingLabel.adjustsFontSizeToFitWidth = true
        searchingLabel.minimumScaleFactor = 13.0 / 18.0
        searchingLabel.layer.shadowColor = UIColor.white.cgColor
        searchingLabel.layer.shadowOpacity = 1
        searchingLabel.layer.shadowRadius = 10
        searchingLabel.layer.shadowOffset = .zero
        cabecera.addSubview(searchingLabel)

        // Pastilla blanca propia: en rojo sobre el mapa no se leeria.
        cancelButton.setTitle("Cancelar Pedido", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "NotoSans-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        cancelButton.setTitleColor(Tinta.rojoCancelar, for: .normal)
        cancelButton.backgroundColor = UIColor(white: 1, alpha: 0.5)   // bg_circle_white_alpha
        cancelButton.layer.cornerRadius = 23
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        cabecera.addSubview(cancelButton)
    }

    private func setupContenidoDeLaHoja() {
        asa.backgroundColor = Tinta.asa
        asa.layer.cornerRadius = 2
        sheetPanel.addSubview(asa)

        // --- Tarjeta de las direcciones (bg_request_inner) ---
        tarjetaViaje.backgroundColor = .white
        tarjetaViaje.layer.borderWidth = 1
        tarjetaViaje.layer.borderColor = Tinta.bordeSuave.cgColor
        tarjetaViaje.layer.cornerRadius = 12          // radius_md
        sheetPanel.addSubview(tarjetaViaje)

        // La columna de la izquierda es FIJA: punto, 28 de linea y pin, pegados arriba.
        // No se alinea cada marca con su direccion -- en Android tampoco, y por eso una
        // direccion de dos lineas deja la linea corta. Calcarlo incluye calcar eso.
        puntoRecogida.backgroundColor = Tinta.verde
        puntoRecogida.layer.cornerRadius = 6
        tarjetaViaje.addSubview(puntoRecogida)

        lineaUnion.backgroundColor = Tinta.bordeSuave
        tarjetaViaje.addSubview(lineaUnion)

        puntoDestino.backgroundColor = Tinta.rojo
        puntoDestino.layer.cornerRadius = 6
        tarjetaViaje.addSubview(puntoDestino)

        lblRecogida.font = UIFont(name: "NotoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        lblRecogida.textColor = Tinta.textoPrimario
        lblRecogida.numberOfLines = 2
        lblRecogida.lineBreakMode = .byTruncatingTail
        tarjetaViaje.addSubview(lblRecogida)

        lblNotas.font = UIFont(name: "NotoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        lblNotas.textColor = Tinta.textoTerciario
        lblNotas.numberOfLines = 0
        tarjetaViaje.addSubview(lblNotas)

        lblDestino.font = UIFont(name: "NotoSans-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
        lblDestino.textColor = Tinta.textoPrimario
        lblDestino.numberOfLines = 2
        lblDestino.lineBreakMode = .byTruncatingTail
        tarjetaViaje.addSubview(lblDestino)

        // --- Ajustador ---
        lblTuOferta.font = UIFont(name: "NotoSans-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
        lblTuOferta.textColor = Tinta.textoPrimario
        sheetPanel.addSubview(lblTuOferta)

        prepararBotonDeAjuste(btnMenos, accion: #selector(bajarOferta))
        prepararBotonDeAjuste(btnMas,   accion: #selector(subirOferta))
        sheetPanel.addSubview(btnMenos)
        sheetPanel.addSubview(btnMas)

        lblMoneda.font = UIFont(name: "NotoSans-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22)
        lblMoneda.textColor = Tinta.textoPrimario
        sheetPanel.addSubview(lblMoneda)

        // Se puede escribir el importe a mano, como el etStepper de Android.
        txtMonto.font = UIFont(name: "NotoSans-Bold", size: 24) ?? UIFont.boldSystemFont(ofSize: 24)
        txtMonto.textColor = Tinta.textoPrimario
        txtMonto.borderStyle = .none
        txtMonto.keyboardType = .decimalPad
        txtMonto.addTarget(self, action: #selector(montoEscrito), for: .editingChanged)
        sheetPanel.addSubview(txtMonto)

        lblConversion.font = UIFont(name: "NotoSans-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        lblConversion.textColor = Tinta.textoTerciario
        lblConversion.textAlignment = .center
        sheetPanel.addSubview(lblConversion)

        btnEnviarOferta.titleLabel?.font = UIFont(name: "NotoSans-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        btnEnviarOferta.setTitleColor(Tinta.textoPrimario, for: .normal)
        btnEnviarOferta.setTitleColor(Tinta.textoPrimario, for: .disabled)
        btnEnviarOferta.clipsToBounds = true
        btnEnviarOferta.addTarget(self, action: #selector(enviarOferta), for: .touchUpInside)
        sheetPanel.addSubview(btnEnviarOferta)

        // El teclado del importe tapa la hoja entera: hace falta salida.
        let cierre = UITapGestureRecognizer(target: self, action: #selector(cerrarTeclado))
        // Sin esto el gesto le robaria el toque a los botones que tiene debajo.
        cierre.cancelsTouchesInView = false
        sheetPanel.addGestureRecognizer(cierre)
    }

    @objc private func cerrarTeclado() {
        view.endEditing(true)
    }

    /// bg_stepper_button: gris E0E0E0 y esquinas de pastilla.
    private func prepararBotonDeAjuste(_ boton: UIButton, accion: Selector) {
        boton.backgroundColor = Tinta.grisAjustador
        boton.layer.cornerRadius = 24
        boton.clipsToBounds = true
        boton.titleLabel?.font = UIFont(name: "NotoSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        boton.setTitleColor(Tinta.textoTerciario, for: .normal)
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
                btnMenos, lblMoneda, txtMonto, btnMas, lblConversion, btnEnviarOferta]
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
            let xTitulo = (self.btnAtras.isHidden ? 16 : self.btnAtras.frame.maxX) + 8
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
    /**
     Lo que mide el contenido de la hoja, con los margenes de activity_offers.xml:
     paddingTop 10, asa 4 + 12, banner + 12, tarjeta, +12 rotulo, +10 ajustador,
     +4 conversion, +16 boton, paddingBottom 20.
     */
    private func altoDelContenido(ancho w: CGFloat) -> CGFloat {
        let cw = w - Self.padLateral * 2
        var y: CGFloat = 10
        y += 4 + 12
        if hayBannerQueMostrar {
            y += alturaDelBanner(ancho: cw) + 12
        }
        y += altoDeLaTarjetaDeViaje(ancho: cw)
        y += 12 + 18
        y += 10 + 48
        // Sin tasa configurada la conversion no se enseña y tampoco deja hueco, igual
        // que el GONE de Android: un blanco a media hoja se lee como que falta algo.
        y += lblConversion.isHidden ? 0 : (4 + 16)
        y += 16 + 56
        y += 20
        return y
    }

    /// padding 12, columna de marcas de 12 de ancho, 12 de separacion, texto a la derecha.
    private func altoDeLaTarjetaDeViaje(ancho cw: CGFloat) -> CGFloat {
        let anchoTexto = cw - 12 - 12 - 12 - 12
        var alto: CGFloat = 12
        alto += altoDeTexto(lblRecogida, ancho: anchoTexto)
        alto += 8 + altoDeTexto(lblNotas, ancho: anchoTexto)
        alto += 8 + altoDeTexto(lblDestino, ancho: anchoTexto)
        alto += 12
        // La columna de marcas mide 12 + 28 + 12 y no encoge: si el texto es mas corto,
        // manda ella.
        return max(alto, 12 + 52 + 12)
    }

    private func altoDeTexto(_ etiqueta: UILabel, ancho: CGFloat) -> CGFloat {
        guard let texto = etiqueta.text, !texto.isEmpty, ancho > 0 else { return 0 }
        let fuente = etiqueta.font ?? UIFont.systemFont(ofSize: 13)
        let lineas = etiqueta.numberOfLines
        let sinTope = CGFloat.greatestFiniteMagnitude
        let tope = lineas > 0 ? fuente.lineHeight * CGFloat(lineas) : sinTope
        let medida = (texto as NSString).boundingRect(
            with: CGSize(width: ancho, height: lineas > 0 ? tope + 2 : sinTope),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: fuente],
            context: nil)
        return ceil(lineas > 0 ? min(medida.height, tope) : medida.height)
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
        y += altoTarjeta

        y += 12
        lblTuOferta.frame = CGRect(x: pad, y: y, width: cw, height: 18)
        y += 18

        // Los botones se miden por su texto, con 20 de aire a cada lado (paddingHorizontal).
        y += 10
        let ladoBoton: CGFloat = 48
        let anchoMenos = ceil(btnMenos.intrinsicContentSize.width) + 40
        let anchoMas   = ceil(btnMas.intrinsicContentSize.width) + 40
        btnMenos.frame = CGRect(x: pad, y: y, width: anchoMenos, height: ladoBoton)
        btnMas.frame   = CGRect(x: w - pad - anchoMas, y: y, width: anchoMas, height: ladoBoton)

        // El simbolo y el numero van juntos y centrados entre los dos botones.
        let anchoMoneda = ceil(lblMoneda.intrinsicContentSize.width)
        let anchoNumero = ceil(txtMonto.intrinsicContentSize.width) + 6
        let huecoCentro = btnMas.frame.minX - btnMenos.frame.maxX
        let anchoPar = min(anchoMoneda + 4 + anchoNumero, max(huecoCentro - 8, 0))
        let xPar = btnMenos.frame.maxX + (huecoCentro - anchoPar) / 2
        lblMoneda.frame = CGRect(x: xPar, y: y, width: anchoMoneda, height: ladoBoton)
        txtMonto.frame  = CGRect(x: xPar + anchoMoneda + 4, y: y,
                                 width: max(0, anchoPar - anchoMoneda - 4), height: ladoBoton)
        y += ladoBoton

        if lblConversion.isHidden {
            lblConversion.frame = CGRect(x: pad, y: y, width: cw, height: 0)
        } else {
            y += 4
            lblConversion.frame = CGRect(x: pad, y: y, width: cw, height: 16)
            y += 16
        }

        y += 16
        btnEnviarOferta.frame = CGRect(x: pad, y: y, width: cw, height: 56)
        // bg_button_primary es una pastilla; el estado apagado usa rounded_corner_grey,
        // que tiene 5 de radio. El radio va con el color, asi que lo pone quien pinta.
        aplicarFormaDelBotonDeEnviar()
    }

    private func colocarTarjetaDeViaje(ancho cw: CGFloat) {
        let anchoTexto = cw - 48
        let xTexto: CGFloat = 36           // 12 de padding + 12 de columna + 12 de aire

        // La columna de marcas, fija y pegada arriba.
        puntoRecogida.frame = CGRect(x: 12, y: 12, width: 12, height: 12)
        lineaUnion.frame    = CGRect(x: 17.5, y: 24, width: 1, height: 28)
        puntoDestino.frame  = CGRect(x: 12, y: 52, width: 12, height: 12)

        var y: CGFloat = 12
        let altoRecogida = altoDeTexto(lblRecogida, ancho: anchoTexto)
        lblRecogida.frame = CGRect(x: xTexto, y: y, width: anchoTexto, height: altoRecogida)
        y += altoRecogida

        y += 8
        let altoNotas = altoDeTexto(lblNotas, ancho: anchoTexto)
        lblNotas.frame = CGRect(x: xTexto, y: y, width: anchoTexto, height: altoNotas)
        y += altoNotas

        y += 8
        let altoDestino = altoDeTexto(lblDestino, ancho: anchoTexto)
        lblDestino.frame = CGRect(x: xTexto, y: y, width: anchoTexto, height: altoDestino)
    }

    // MARK: - La oferta

    /**
     Prepara el ajustador con lo que el viaje ya tiene pedido.

     Los topes se miden contra base_est_amt, la estimacion original, NO contra lo que
     se lleva ofrecido: si se midieran contra el importe vivo, cada subida arrastraria
     el techo con ella y no habria tope ninguno. Es lo que hace Android.
     */
    private func prepararOferta() {
        // CityModel.h esta dentro de NS_ASSUME_NONNULL, asi que Swift ve esto como no
        // opcional -- pero getCityByCityId devuelve nil cuando la ciudad no esta en la
        // lista cargada. La cabecera miente, vamos. Se recoge en una variable declarada
        // opcional para poder comprobarlo sin que el compilador lo tome por imposible.
        let ciudad: CityModel? = CityModel.getCityByCityId(Int(trip?.city_id ?? 0))
        let simbolo = ciudad?.city_cur ?? ""
        if !simbolo.isEmpty {
            moneda = simbolo
        }
        lblMoneda.text = moneda

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

        /*
         Los tres textos de la tarjeta, tal cual los escribe Android.

         Las notas del pedido van pegadas a la direccion de recogida con dos saltos de
         linea, y esa etiqueta admite dos lineas: cuando la direccion ya ocupa las dos
         -- que es lo normal -- las notas no llegan a verse. Queda asi a proposito,
         porque el encargo era calcar la pantalla; el hueco de en medio lo ocupa el
         rotulo fijo "tu ofreciste", que es lo que pone Android en setLocalizeData.
         */
        let recogida = trip?.trip_pick_loc ?? ""
        let notas = (trip?.pickup_notes ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if notas.isEmpty {
            lblRecogida.text = recogida
        } else {
            lblRecogida.text = String(format: "%@\n\n%@ %@", recogida,
                                      LanguageHelper.getStringWithKey("k_1_s8_special_notes",
                                                                      defaultValue: "Notas especiales:"),
                                      notas)
        }
        lblNotas.text   = LanguageHelper.getStringWithKey("k_1_s9_ur_ofr", defaultValue: "tu ofreciste")
        lblDestino.text = trip?.trip_drop_loc ?? ""

        btnMenos.setTitle(String(format: "- %.2f", pasoDeOferta), for: .normal)
        btnMas.setTitle(String(format: "+ %.2f", pasoDeOferta), for: .normal)
        refrescarTextosDeLaOferta()
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
     El importe escrito a mano.

     Se recorta a dos decimales mientras se teclea, como el doAfterTextChanged de
     Android: el campo es el mismo sitio donde luego escribe el ajustador, y dejar
     entrar tres decimales daria un importe que el boton no sabria comparar.
     */
    @objc private func montoEscrito() {
        var texto = txtMonto.text ?? ""
        if let punto = texto.firstIndex(of: ".") {
            let decimales = texto[texto.index(after: punto)...]
            if decimales.count > 2 {
                texto = String(texto[..<punto]) + "." + String(decimales.prefix(2))
                txtMonto.text = texto
            }
        }
        montoDelAjustador = Float(texto) ?? 0
        refrescarTextosDeLaOferta(actualizandoElCampo: false)
    }

    /**
     Pinta el importe en los tres sitios donde sale y decide si se puede enviar.

     El boton se apaga cuando el ajustador marca lo mismo que ya esta ofrecido: no hay
     nada que mandar, y un boton vivo que no hace nada se lee como que el envio fallo.
     Apagado cambia de color Y de forma, porque Android usa dos fondos distintos --
     bg_button_primary es una pastilla y rounded_corner_grey tiene 5 de radio.
     */
    private func refrescarTextosDeLaOferta(actualizandoElCampo: Bool = true) {
        if actualizandoElCampo {
            txtMonto.text = String(format: "%.2f", montoDelAjustador)
        }
        let importe = Utilities.formatAmountAndCurrency(montoDelAjustador, currency: moneda) ?? ""

        lblTuOferta.text = String(format: "tu ofreciste (%@)", importe)
        btnEnviarOferta.setTitle(String(format: "Enviar oferta (%@)", importe), for: .normal)

        let sePuedeEnviar = abs(montoDelAjustador - montoOfrecido) > 0.001
        btnEnviarOferta.isEnabled = sePuedeEnviar
        btnEnviarOferta.backgroundColor = sePuedeEnviar ? Tinta.amarillo : Tinta.grisApagado
        aplicarFormaDelBotonDeEnviar()

        let tasa = ConstantModel.tasaDolarALocal()
        if tasa > 0 {
            let formato = NumberFormatter()
            formato.numberStyle = .decimal
            formato.minimumFractionDigits = 2
            formato.maximumFractionDigits = 2
            let local = formato.string(from: NSNumber(value: montoDelAjustador * tasa)) ?? ""
            lblConversion.text = String(format: "Conversión: Bs %@", local)
            lblConversion.isHidden = false
        } else {
            lblConversion.text = ""
            lblConversion.isHidden = true
        }
    }

    private func aplicarFormaDelBotonDeEnviar() {
        let alto = max(btnEnviarOferta.bounds.height, 56)
        btnEnviarOferta.layer.cornerRadius = btnEnviarOferta.isEnabled ? alto / 2 : 5
    }

    @objc private func enviarOferta() {
        view.endEditing(true)
        guard let trip = trip, montoDelAjustador > 0 else {
            avisar(LanguageHelper.getStringWithKey("k_r1_s6_please_enter_amount"))
            return
        }
        if hayTopes && montoDelAjustador < ofertaMinima {
            avisar(LanguageHelper.getStringWithKey("k_r1_s6_pls_ntr_amnt_grtr_thn_min_fare"))
            return
        }
        if hayTopes && montoDelAjustador > ofertaMaxima {
            avisar(LanguageHelper.getStringWithKey("k_r1_s6_pls_ntr_amnt_less_thn_max_fare"))
            return
        }
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
            self.refrescarTextosDeLaOferta(actualizandoElCampo: false)
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
