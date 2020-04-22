//
//  UIColorExtensions.swift
//  AWSPinpoint
//
//  Created by Guan, Zhinan on 4/9/20.
//

import Foundation

@objc extension UIColor {

    static public var primeNowThemePrimary = UIColor.from(hex: "#FFD77B")
    static public var primeNowThemePrimarySelected = UIColor.from(hex: "#F3A721")
    static public var primeNowThemePrimaryButtonBorderColor = UIColor.from(hex: "#F3A721")
    static public var primeNowHyperLinkTextColor = UIColor.from(hex: "#0066C0")
    static public var primeNowDividerGray = UIColor.from(hex: "#DDDDDD")
    static public var labelGrayOnWhite = UIColor.from(hex: "#555555")
    static public var lightGrayBackgroundColor = UIColor.from(hex: "#F1F1F1")

    var hexValue: String {
        get {
            if let colorSpace = self.cgColor.colorSpace?.model,
                let components = self.cgColor.components {

                if colorSpace == .monochrome {
                    let r = lroundf(Float(components[0]) * 255.0)
                    let g = lroundf(Float(components[0]) * 255.0)
                    let b = lroundf(Float(components[0]) * 255.0)
                    return String(format: "#%.2f%.2f%.2f%", r, g, b)
                } else if colorSpace == .rgb {
                    let r = lroundf(Float(components[0]) * 255.0)
                    let g = lroundf(Float(components[1]) * 255.0)
                    let b = lroundf(Float(components[2]) * 255.0)
                    return String(format: "#%.2f%.2f%.2f%", r, g, b)
                }
            }
            return ""
        }
    }

    @objc static public func from(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIImageView {
    func download(from url: URL,
                  contentMode mode: UIView.ContentMode = .scaleAspectFit,
                  completion: @escaping (Bool) -> ()) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completion(false)
                    return
                }
            DispatchQueue.main.async() {
                self.image = image
                completion(true)
            }
        }.resume()
    }
}
