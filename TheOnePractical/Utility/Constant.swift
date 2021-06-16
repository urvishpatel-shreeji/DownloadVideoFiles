//
//  Constant.swift
//  TheOnePractical
//
//  Created by Urvish Patel on 16/06/21.
//

import Foundation


struct Constant {
    static var server:Server = .Production;
    static var thumbImageURL:String = Constant.server.imageThumbURL
}
