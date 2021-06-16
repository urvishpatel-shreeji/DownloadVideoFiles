//
//  FloatExtension.swift
//  TheOnePractical
//
//  Created by Urvish Patel on  16/06/21.
//

import UIKit


extension CGFloat{
    
    func praposionalSize()->CGFloat{
        let sizeToCheckAgainst = self
        
        switch SRDevice.deviceType {
        case .iphone4:
            return (sizeToCheckAgainst  - 3.5)
            
        case .iphone5:
            return (sizeToCheckAgainst  - 2 )
        case .iphone6:
            return (sizeToCheckAgainst  + 0)
        case .iphone6Plus:
            return (sizeToCheckAgainst  + 1 )
        case .iphoneX:
            return (sizeToCheckAgainst  + 0 )
        case .iphoneXSMax:
            return (sizeToCheckAgainst  + 1 )
        case .iphone12:
            return (sizeToCheckAgainst  + 0 )
        case .iphone12ProMax:
            return (sizeToCheckAgainst  + 1 )
        case .ipad:
            return (sizeToCheckAgainst  + 12)
        }
    }
}
