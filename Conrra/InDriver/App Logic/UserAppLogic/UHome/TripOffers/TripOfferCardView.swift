//
//  TripOfferCardView.swift
//  Conrra
//
//  Programmatic card view replacing XIB-based TripOfferCell.
//  Uses frame-based layout (no Auto Layout). iOS 12+.
//

import UIKit
import CoreLocation
import SDWebImage


protocol TripOfferCardViewDelegate: AnyObject {
    func cardViewDidTapAccept(_ view: TripOfferCardView, offer: TripOffer)
    func cardViewDidTapDecline(_ view: TripOfferCardView, offer: TripOffer)
}


class TripOfferCardView: UIView {


    static let cardHeight: CGFloat = 212


    let tripOffer: TripOffer
    weak var delegate: TripOfferCardViewDelegate?


    private let avatarImageView   = UIImageView()
    private let statsLabel        = UILabel()
    private let nameLabel         = UILabel()
    private let carInfoLabel      = UILabel()
    private let carImageView      = UIImageView()
    private let plateLabel        = UILabel()
    private let progressBar       = UIProgressView(progressViewStyle: .default)
    private let offerBgView       = UIView()
    private let offerTextLabel    = UILabel()
    private let offerAmountLabel  = UILabel()
    private let declineButton     = UIButton(type: .system)
    private let acceptButton      = UIButton(type: .system)

    private weak var trip: TripModel?

    // KVO token for offer amount updates
    private var offerObservation: NSKeyValueObservation?


    init(offer: TripOffer, trip: TripModel?) {
        self.tripOffer = offer
        self.trip = trip
        super.init(frame: .zero)
        setupCard()
        populateData()
        observeOfferUpdates()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    deinit {
        offerObservation?.invalidate()
    }


    override func layoutSubviews() {
        super.layoutSubviews()

        let w = bounds.width
        let pad: CGFloat = 14

        // Avatar
        let avatarX: CGFloat = pad
        let avatarY: CGFloat = 14
        let avatarW: CGFloat = 56
        let avatarH: CGFloat = 56
        avatarImageView.frame = CGRect(x: avatarX, y: avatarY, width: avatarW, height: avatarH)
        avatarImageView.layer.cornerRadius = avatarW / 2
        avatarImageView.clipsToBounds = true

        // Car image (top-right)
        let carImgW: CGFloat = 64
        let carImgH: CGFloat = 38
        let carImgX: CGFloat = w - pad - carImgW
        let carImgY: CGFloat = 14
        carImageView.frame = CGRect(x: carImgX, y: carImgY, width: carImgW, height: carImgH)

        // Plate label (below car image, right-aligned)
        plateLabel.frame = CGRect(x: carImgX, y: carImgY + carImgH + 2, width: carImgW, height: 14)

        // Stats row (right of avatar, left of car image)
        let statsX: CGFloat = avatarX + avatarW + 10
        let statsW: CGFloat = max(0, carImgX - statsX - 6)
        statsLabel.frame   = CGRect(x: statsX, y: 14, width: statsW, height: 16)
        nameLabel.frame    = CGRect(x: statsX, y: statsLabel.frame.maxY + 4, width: statsW, height: 20)
        carInfoLabel.frame = CGRect(x: statsX, y: nameLabel.frame.maxY + 3, width: statsW, height: 16)

        // Progress bar: sits 10pt below the taller of avatar / car image
        let contentBottom = max(avatarImageView.frame.maxY, carImageView.frame.maxY)
        let progressY: CGFloat = contentBottom + 10
        progressBar.frame = CGRect(x: 0, y: progressY, width: w, height: 3)

        // Offer row background
        let offerBgY: CGFloat = progressBar.frame.maxY
        let offerBgH: CGFloat = 48
        offerBgView.frame = CGRect(x: 0, y: offerBgY, width: w, height: offerBgH)

        // "Oferta por:" label (left)
        offerTextLabel.frame = CGRect(x: pad, y: offerBgY, width: 130, height: offerBgH)

        // Amount label (right)
        let amtW: CGFloat = 140
        offerAmountLabel.frame = CGRect(x: w - pad - amtW, y: offerBgY, width: amtW, height: offerBgH)

        // Buttons row
        let btnY: CGFloat = offerBgView.frame.maxY + 10
        let btnH: CGFloat = 42
        let totalBtnW: CGFloat = w - pad * 2
        let btnW: CGFloat = (totalBtnW - 10) / 2

        declineButton.frame = CGRect(x: pad, y: btnY, width: btnW, height: btnH)
        acceptButton.frame  = CGRect(x: pad + btnW + 10, y: btnY, width: btnW, height: btnH)
    }


    /// Call every second from the parent view controller's timer.
    func updateProgress() {
        let progress = Float(tripOffer.count) / tripOffer.countTotal
        progressBar.setProgress(progress, animated: true)
    }

    /// Call when `offer_amt` has changed on the model.
    func refreshOfferAmount() {
        let formattedAmt = formattedOfferAmount()
        offerAmountLabel.text = formattedAmt
        let acceptTitle = "Aceptar (\(formattedAmt))"
        acceptButton.setTitle(acceptTitle, for: .normal)
    }


    private func setupCard() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor  = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowRadius  = 10
        layer.shadowOffset  = CGSize(width: 0, height: 2)

        setupAvatarImageView()
        setupLabels()
        setupCarImageView()
        setupProgressBar()
        setupOfferRow()
        setupButtons()
    }

    private func setupAvatarImageView() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor(white: 0.92, alpha: 1)
        addSubview(avatarImageView)
    }

    private func setupLabels() {
        // Stats
        statsLabel.font = notoRegular(12)
        statsLabel.textColor = UIColor(white: 0.45, alpha: 1)
        statsLabel.numberOfLines = 1
        addSubview(statsLabel)

        // Name
        nameLabel.font = notoBold(16)
        nameLabel.textColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        nameLabel.numberOfLines = 1
        addSubview(nameLabel)

        // Car info
        carInfoLabel.font = notoRegular(13)
        carInfoLabel.textColor = UIColor(white: 0.45, alpha: 1)
        carInfoLabel.numberOfLines = 1
        addSubview(carInfoLabel)

        // Plate
        plateLabel.font = notoRegular(11)
        plateLabel.textColor = UIColor(white: 0.45, alpha: 1)
        plateLabel.textAlignment = .right
        addSubview(plateLabel)
    }

    private func setupCarImageView() {
        carImageView.contentMode = .scaleAspectFit
        carImageView.clipsToBounds = true
        carImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        addSubview(carImageView)
    }

    private func setupProgressBar() {
        progressBar.trackTintColor = UIColor(white: 0.85, alpha: 1)
        progressBar.progressTintColor = UIColor(red: 229/255, green: 57/255, blue: 53/255, alpha: 1) // #E53935
        progressBar.transform = CGAffineTransform(scaleX: 1, y: 3) // make it ~3pt tall
        addSubview(progressBar)
    }

    private func setupOfferRow() {
        offerBgView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1) // #F5F5F5
        addSubview(offerBgView)

        offerTextLabel.text = "Oferta por:"
        offerTextLabel.font = notoRegular(15)
        offerTextLabel.textColor = UIColor(white: 0.45, alpha: 1)
        offerTextLabel.textAlignment = .left
        addSubview(offerTextLabel)

        offerAmountLabel.font = notoBold(22)
        offerAmountLabel.textColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        offerAmountLabel.textAlignment = .right
        addSubview(offerAmountLabel)
    }

    private func setupButtons() {
        // Decline button — light red
        declineButton.setTitle("Rechazar", for: .normal)
        declineButton.titleLabel?.font = notoBold(15)
        declineButton.setTitleColor(UIColor(red: 198/255, green: 40/255, blue: 40/255, alpha: 1), for: .normal) // #C62828
        declineButton.backgroundColor = UIColor(red: 255/255, green: 235/255, blue: 238/255, alpha: 1)         // #FFEBEE
        declineButton.layer.cornerRadius = 10
        declineButton.clipsToBounds = true
        declineButton.addTarget(self, action: #selector(didTapDecline), for: .touchUpInside)
        addSubview(declineButton)

        // Accept button — light green
        acceptButton.titleLabel?.font = notoBold(15)
        acceptButton.setTitleColor(UIColor(red: 46/255, green: 125/255, blue: 50/255, alpha: 1), for: .normal) // #2E7D32
        acceptButton.backgroundColor = UIColor(red: 232/255, green: 245/255, blue: 233/255, alpha: 1)          // #E8F5E9
        acceptButton.layer.cornerRadius = 10
        acceptButton.clipsToBounds = true
        acceptButton.addTarget(self, action: #selector(didTapAccept), for: .touchUpInside)
        addSubview(acceptButton)
    }


    private func populateData() {
        let driver = tripOffer.driver

        // Avatar — profile photo
        if let profilePath = driver?.d_profile_image_path, !profilePath.isEmpty {
            let url = URL(string: "\(url_base_images)\(profilePath)")
            avatarImageView.sd_setImage(with: url,
                                        placeholderImage: UIImage(named: "Profile Icon Crop Image"))
        } else {
            avatarImageView.image = UIImage(named: "Profile Icon Crop Image")
        }

        // Car image
        if let carPath = driver?.d_car_image_path, !carPath.isEmpty {
            let url = URL(string: "\(url_base_images)\(carPath)")
            carImageView.sd_setImage(with: url, placeholderImage: nil)
        }

        // Plate
        plateLabel.text = driver?.car_registration_no ?? ""

        // Rating & distance stats
        let rating = Double(driver?.rating ?? 0)
        let numTrips = driver?.num_trip ?? 0
        let distanceStr = computeDistanceString()
        statsLabel.text = String(format: "⭐ %.1f (%d)  |  %@", rating, numTrips, distanceStr)

        // Driver name
        let fname = driver?.d_fname ?? ""
        let lname = driver?.d_lname ?? ""
        nameLabel.text = "\(fname) \(lname)".trimmingCharacters(in: .whitespaces)

        // Car info
        let carParts = [driver?.car_name, driver?.car_model, driver?.car_make]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        carInfoLabel.text = carParts.joined(separator: " ")

        // Offer amount
        let formattedAmt = formattedOfferAmount()
        offerAmountLabel.text = formattedAmt
        acceptButton.setTitle("Aceptar (\(formattedAmt))", for: .normal)

        // Initial progress
        updateProgress()
    }

    private func observeOfferUpdates() {
        offerObservation = tripOffer.observe(\.offerUpated, options: .new) { [weak self] _, _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.refreshOfferAmount()
                // Reset progress timer
                self.tripOffer.count = Int(self.tripOffer.countTotal)
            }
        }
    }


    /// Returns formatted offer amount string using city currency when possible.
    private func formattedOfferAmount() -> String {
        if let trip = trip,
           let amtStr = tripOffer.offer_amt,
           let amt = Float(amtStr) {
            let cityId = Int(trip.city_id) ?? 0
            let city = CityModel.getCityByCityId(cityId)
            if let formatted = Utilities.formatAmountAndCurrency(amt, currency: city.city_cur) {
                return formatted
            }
        }
        return tripOffer.offer_amt ?? "—"
    }

    /// Computes a "X Min - Y Kms" string from driver location to pickup.
    private func computeDistanceString() -> String {
        guard let driver = tripOffer.driver,
              let pickLat = Double(trip?.trip_pick_lat ?? ""),
              let pickLng = Double(trip?.trip_pick_long ?? "") else {
            return "— Min - — Kms"
        }

        let driverLoc  = CLLocation(latitude: driver.lat, longitude: driver.lng)
        let pickupLoc  = CLLocation(latitude: pickLat, longitude: pickLng)
        let distanceKm = driverLoc.distance(from: pickupLoc) / 1000.0
        var timeMin    = (distanceKm / 15.0) * 60.0
        if timeMin < 1 { timeMin = 1 }

        return String(format: "%d Min - %.1f Kms", Int(timeMin), distanceKm)
    }


    private func notoBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSans-Bold", size: size)
            ?? UIFont.boldSystemFont(ofSize: size)
    }

    private func notoRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSans-Regular", size: size)
            ?? UIFont.systemFont(ofSize: size)
    }


    @objc private func didTapAccept() {
        delegate?.cardViewDidTapAccept(self, offer: tripOffer)
    }

    @objc private func didTapDecline() {
        delegate?.cardViewDidTapDecline(self, offer: tripOffer)
    }
}
