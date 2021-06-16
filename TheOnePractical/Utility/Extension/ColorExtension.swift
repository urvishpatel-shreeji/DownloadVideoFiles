//
//  ColorExtension.swift
//  TheOnePractical
//
//  Created by Urvish Patel on  16/06/21.
//

import UIKit

extension UIColor{
    public static func appBlackColor()->UIColor{
        return UIColor.black
    }
    public static func appLightGray()->UIColor{
        #if DEBUG
        return UIColor.lightGray
        #else
        return UIColor.lightText
        #endif
    }
    public static func appPrimeryColor()->UIColor{
        return UIColor.init(red: 70.0/255.0, green: 240.0/255.0  , blue: 124.0/255.0, alpha: 1.0)
    }
    public static func appTextColor() -> UIColor{
        #if DEBUG
        return UIColor.black
        #else
        return UIColor.white
        #endif
    }
}
