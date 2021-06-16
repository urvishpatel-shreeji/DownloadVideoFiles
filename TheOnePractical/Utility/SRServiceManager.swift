//
//  SRServiceManager.swift
//  TheOnePractical
//
//  Created by Urvish Patel on  16/06/21.
//

import UIKit
import Alamofire

public enum APIType{
    case Media
    var getEndPoint:String{
        switch self {
        case .Media:
           return "uc"
        }
    }
}
public enum Server:String {
    case Production = "https://drive.google.com/"
    case Stagging = ""
    var imageThumbURL:String{
        return "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample"
    }
}
typealias APIResponse = (_ isSuccess:Bool,_ response:Any?,_ message:String?)->Void

class SRServiceManager: NSObject {
    
    static let shared:SRServiceManager = SRServiceManager()
    private let server:Server = Constant.server;
    private override init() {
        
    }
    
    
    private func getPerametersFromAPI(withAPIType apiType:APIType,perameters:[String:Any]) -> (url:String,perameters:[String:Any],headers:[String:String]){
        
        var url:String = server.rawValue;
        url.append(apiType.getEndPoint)
        if apiType == .Media{
            ///we do some addition thing in url
            for (key,value) in perameters{
                let strPerameters:String = "\(key)=\(value)"
                url.append("?\(strPerameters)")
            }
        }
        
        let headers:[String:String] = [:]
        return (url,perameters,headers)
        
        
    }

    //MARK: - Get Request
    private func callGetAPI(withAPIType apiType:APIType, perameters:[String:Any] = [:],headers:[String:String] = [:],apiResponseHandler:APIResponse?){
        
        let apiHelpler = self.getPerametersFromAPI(withAPIType: apiType, perameters: perameters)
     
        SRLoader.shared.showLoader(withMessage: "")
        print(apiHelpler.url)
        AF.request(apiHelpler.url, method: .get)
                .responseJSON { (response) in
                    SRLoader.shared.hideLoader()
                 
                    switch response.result {
                    case .success(let json ):
                        print(json)
                        
                        if let handler = apiResponseHandler {
                            handler(true,json,"")
                        }
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                        if let handler = apiResponseHandler{
                            handler(false,nil,error.localizedDescription)
                        }
                        break
                    }
            }
        
    
        
    }
    
}

extension SRServiceManager{
    public func callGetCategoryList(withCompletionHandler completion:((_ categories:[Category])->Void)?){
        self.callGetAPI(withAPIType: .Media, perameters: ["id":"1lVufsMFWDmB6UsEkho8bz_VlQmxoznyP"], headers: [:]) { (isSucces, response, errorMessage) in
            guard `self` != nil else {return}
           
            
            var aryCategory:[Category] = []
            if isSucces{
                if let details:[String:Any] = response as? [String:Any]{
                    if let categories:[[String:Any]] = details["categories"] as? [[String:Any]]{
                        aryCategory = []
                        for data in categories{
                            aryCategory.append(Category.init(withData: data))
                        }
                        if let handler = completion {
                            handler(aryCategory)
                        }
                    }
                }else{
                    //print alert or notify user for not getting proper data
                    if let handler = completion {
                        handler(aryCategory)
                    }
                }
            }else{
                //print alert or notify user for failed api
                if let handler = completion {
                    handler(aryCategory)
                }
            }
        }
    }
    
}
