//
//  EncodePolylineHelperSwift.swift
//  LTS Driver
//
//  Created by Grepix on 01/02/21.
//  Copyright © 2023 Grepixit. All rights reserved.
//

import UIKit
import CoreLocation

@objcMembers  open class EncodePolylineHelperSwift: NSObject {

 
    public func encodePoint( locations:Array<CLLocation>  )->String{
//        let locations = [CLLocation(latitude: 40.2349727, longitude: -3.7707443),
//        CLLocation(latitude: 44.3377999, longitude: 1.2112933)]

//        (38.5, -120.2), (40.7, -120.95), (43.252, -126.453)
//        let locations = [CLLocation(latitude: 38.5, longitude: -120.2),
//        CLLocation(latitude: 40.7, longitude: -120.95),CLLocation(latitude: 43.252, longitude: -126.453)]
        
//        let polyline = Polyline(locations: locations)
//        let encodedPolyline: String = polyline.encodedPolyline
//         Or for a functional approach :
        let encodedPolyline1: String = encodeLocations(locations)
        print(encodedPolyline1)
        return encodedPolyline1;
    }
    
    public func addDotView(view:UIView ){
         
       
    }
    public func trimAttributedStrin( attstring :NSMutableAttributedString )->NSAttributedString {
        let result = attstring.attributedStringByTrimmingCharactersInSet(set: NSCharacterSet.whitespacesAndNewlines)
        return result
    }
    
    
    func getFinale(imageData:Data)->[UIImage]?{
        if let arrayFrames = getSequenceForPath(imageData: imageData) {
            var aa:[UIImage] = []
            for item in arrayFrames {
                aa.append(item.image)
            }
            return aa
        }
        return []
    }
    
    func getSequenceForPath(imageData: Data) -> [GifInfo]? {
//        guard let imageData = try? Data(contentsOf: bundleURL) else {
//            print("Cannot turn image named \"\(bundleURL)\" into NSData")
//            return nil
//        }
        
        let gifOptions = [
            kCGImageSourceShouldAllowFloat as String : true as NSNumber,
            kCGImageSourceCreateThumbnailWithTransform as String : true as NSNumber,
            kCGImageSourceCreateThumbnailFromImageAlways as String : true as NSNumber
        ] as CFDictionary
        
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, gifOptions) else {
            debugPrint("Cannot create image source with data!")
            return nil
        }
        
        let framesCount = CGImageSourceGetCount(imageSource)
        var frameList = [GifInfo]()
        for index in 0 ..< framesCount {
            if let cgImageRef = CGImageSourceCreateImageAtIndex(imageSource, index, nil) {
                let uiImageRef = UIImage(cgImage: cgImageRef)
                let deley = UIImage.delayForImageAtIndex(index,source: imageSource)
                frameList.append(GifInfo(image: uiImageRef, delay: deley))
            }
        }
        
        return frameList // Your gif frames is ready
    }
}
extension NSMutableAttributedString {
     public func trimCharactersInSet(charSet: CharacterSet) {
        var range = (string as NSString).rangeOfCharacter(from: charSet as CharacterSet)

         // Trim leading characters from character set.
         while range.length != 0 && range.location == 0 {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet)
         }

         // Trim trailing characters from character set.
        range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
         while range.length != 0 && NSMaxRange(range) == length {
            replaceCharacters(in: range, with: "")
            range = (string as NSString).rangeOfCharacter(from: charSet, options: .backwards)
         }
     }
    
    public func attributedStringByTrimmingCharactersInSet(set: CharacterSet) -> NSAttributedString {
        let invertedSet = set.inverted
        let rangeFromStart = string.rangeOfCharacter(from: invertedSet)
        let rangeFromEnd = string.rangeOfCharacter(from: invertedSet, options: .backwards)
        if let startLocation = rangeFromStart?.upperBound, let endLocation = rangeFromEnd?.lowerBound {
            let location = string.distance(from: string.startIndex, to: startLocation) - 1
            let length = string.distance(from: startLocation, to: endLocation) + 2
            let newRange = NSRange(location: location, length: length)
            return self.attributedSubstring(from: newRange)
        } else {
            return NSAttributedString()
        }
    }
    
}
struct GifInfo{
    var image:UIImage
    var delay:Double
}
extension UIImage {
    
    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gif(url: URL) -> UIImage? {
        // Validate URL
        //        guard let bundleURL = URL(string: url) else {
        //            print("SwiftGif: This image named \"\(url)\" does not exist")
        //            return nil
        //        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: url) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }
        
        return gif(data: imageData)
    }
    
    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }
        
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gif(data: imageData)
    }
    
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        if CFDictionaryGetValueIfPresent(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque(), gifPropertiesPointer) == false {
            return delay
        }
        
        let gifProperties:CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as? Double ?? 0
        
        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }
        
        return delay
    }
    
    internal class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
    
    internal class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        // Calculate full duration
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
    
}
