//
//  Category.swift
//  TheOnePractical
//
//  Created by Urvish Patel on 16/06/21.
//

import Foundation
struct CategoryKeyName {
    
    static let name:String = "name"
    static let videos:String = "videos"
}
class Category: BaseModel {
    var aryMovie:[Movie] = []
    var name:String = ""
    override init() {
        super.init()
    }
    convenience init(withData data:[String:Any]) {
        self.init()
        
       
        if let value:String = data[CategoryKeyName.name] as? String{
            self.name = value
        }
        
        if let videos:[[String:Any]] = data[CategoryKeyName.videos] as? [[String:Any]]{
            aryMovie = []
            for data in videos{
                aryMovie.append(Movie.init(withData: data))
            }
            
        }
        
    }
}
