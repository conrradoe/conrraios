//
//  GIFDisplayHelper.swift
//  GetRide
//
//  Created by Grepix Infotech on 04/06/24.
//

import UIKit
@objc  protocol GIFDisplayHelperDeleage:NSObjectProtocol {
    func animationDone()
}

@objcMembers class GIFDisplayHelper: NSObject {
    weak var delegate:GIFDisplayHelperDeleage?
    var imageView:UIImageView
    private var frames: [UIImage]
    private var frameIndex = 0
    private var displayLink: CADisplayLink?
    init(imageView: UIImageView,frames:[UIImage],delegate:GIFDisplayHelperDeleage) {
        self.imageView = imageView
        self.frames = frames
        self.delegate = delegate
    }
    public func startAnimatingGIF() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.preferredFramesPerSecond = 10 // Set your desired frame rate
        displayLink?.add(to: .main, forMode: .default)
    }
    
    @objc private func updateFrame() {
        if frameIndex < frames.count {
            self.imageView.image = frames[frameIndex]
            frameIndex += 1
        } else {
            stopAnimatingGIF()
        }
    }
    
    private func stopAnimatingGIF() {
        displayLink?.invalidate()
        displayLink = nil
        frameIndex = 0
        delegate?.animationDone()
    }
}
