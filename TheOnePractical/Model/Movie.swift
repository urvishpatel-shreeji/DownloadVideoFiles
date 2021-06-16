//
//  Movie.swift
//  TheOnePractical
//
//  Created by Urvish Patel on 16/06/21.
//

import Foundation
struct MovieKeyName {
    
    static let movieId:String = "id"
    static let title:String = "title"
    static let description:String = "description"
    static let url:String = "sources"
    static let subTitle:String = "subtitle"
    static let thumb:String = "thumb"
    
}
class  Movie: BaseModel {
    var id:Int = -1
    var movieDescription:String = ""
    var subTitle:String = ""
    var thumbURL:String = ""
    var title:String = ""
    var videoURL:String = ""
    var downloadModel:SRDownloadModel!
    override init() {
        super.init()
    }
    convenience init(withData data:[String:Any]) {
        self.init()
        
        if let value:Int = data[MovieKeyName.movieId] as? Int{
            self.id = value
        }
        
        if let value:String = data[MovieKeyName.description] as? String{
            self.movieDescription = value
        }
        if let value:String = data[MovieKeyName.subTitle] as? String{
            self.subTitle = value
        }
        if let value:String = data[MovieKeyName.thumb] as? String{
            self.thumbURL = Constant.thumbImageURL + "/" + value
        }
        if let value:String = data[MovieKeyName.title] as? String{
            self.title = value
        }
        if let value:[String] = data[MovieKeyName.url] as? [String],let url:String = value.first{
            self.videoURL = url
            let fileURL:NSString = url as NSString
            let fileName : NSString = fileURL.lastPathComponent as NSString
        
            let downloadModel = SRDownloadModel.init(fileName: fileName as String, fileURL: self.videoURL as String, date: Date())
            self.downloadModel = downloadModel
            SRDownloadManager.shared.downloadingArray.append(self.downloadModel)
        }
        
    }
}
