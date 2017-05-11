//
//  ETPUtils.swift
//  EmailTokenPicker
//
//  Created by Dmitry Shlyugaev on 07/05/2017.
//
//

import UIKit

let ETPTextEmpty = "\u{200B}"

class ETPUtils: NSObject {
    
    static func getRect(_ str: NSString, width: CGFloat, height: CGFloat, font: UIFont) -> CGRect {
        let rectangleStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        rectangleStyle.alignment = NSTextAlignment.center
        let rectangleFontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: rectangleStyle]
        return str.boundingRect(with: CGSize(width: width, height: height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: rectangleFontAttributes, context: nil)
    }
    
    static func getRect(_ str: NSString, width: CGFloat, font: UIFont) -> CGRect {
        let rectangleStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        rectangleStyle.alignment = NSTextAlignment.center
        let rectangleFontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: rectangleStyle]
        return str.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: rectangleFontAttributes, context: nil)
    }
    
    static func widthOfString(_ str: String, font: UIFont) -> CGFloat {
        let attrs = [NSFontAttributeName: font]
        let attributedString = NSMutableAttributedString(string:str, attributes:attrs)
        return attributedString.size().width
    }
    
    static func validateEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
}

extension UIColor {
    func darkendColor(_ darkRatio: CGFloat) -> UIColor {
        var h: CGFloat = 0.0, s: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        if (getHue(&h, saturation: &s, brightness: &b, alpha: &a)) {
            return UIColor(hue: h, saturation: s, brightness: b*darkRatio, alpha: a)
        } else {
            return self
        }
    }
}
