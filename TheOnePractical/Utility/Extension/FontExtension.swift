//
//  FontExtension.swift
//  TheOnePractical
//
//  Created by Urvish Patel on  16/06/21.
//

import UIKit

extension UIFont{
   
    class  func appRegularFont(withFontSize size:CGFloat)-> UIFont{
        return UIFont.systemFont(ofSize: size.praposionalSize())
    }
    class  func appBoldFont(withFontSize size:CGFloat)-> UIFont{
        return UIFont.boldSystemFont(ofSize: size.praposionalSize())
        //return UIFont.init(name: "SegoeUI-Bold", size: size.praposionalSize())!
    }
}
