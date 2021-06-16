//
//  SRDevice.swift
//  TheOnePractical
//
//  Created by Urvish Patel on  16/06/21.
//

import UIKit

class SRDevice: NSObject {
    
    internal enum DeviceType{
        case iphone4
        case iphone5
        case iphone6
        case iphone6Plus
        case iphoneX
        case iphoneXSMax
        case iphone12
        case iphone12ProMax
        case ipad
    }
    static let SCREEN_WIDTH:CGFloat = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT:CGFloat = UIScreen.main.bounds.size.height
    
    class var deviceType:DeviceType {
        switch UIScreen.main.bounds.size.height{
        case 420:
            return .iphone4
        case 568:
            return .iphone5
        case 667:
            return .iphone6
        case 736:
            return .iphone6Plus
        case 812,780:
            return .iphoneX
        case 896:
            return .iphoneXSMax
        case 844:
            return .iphone12
        case 926:
            return .iphone12ProMax
        default:
            return .ipad
        }
    }
    
    static var isIpad:Bool{
        if UIDevice.current.userInterfaceIdiom == .phone {
            return false
        }
        else
        {
            return true
            
        }
    }
    
}

extension UIDevice{
    var getSpacing: CGFloat!{
        switch UIScreen.main.scale {
        case 1:
            return 8
        case 2:
            return 16
        case 3:
            return 20
        default:
            return 16
        }
    }
    var getAppStandartSpacing:CGFloat!{
        return self.getSpacing * 1.0
    }
}
