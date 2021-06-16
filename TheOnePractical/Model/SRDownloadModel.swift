//
//  SRDownloadModel.swift
//  TheOnePractical
//
//  Created by Urvish Patel on  16/06/21.
//

import UIKit

public enum Status: Int {
    case unknown, gettingInfo, downloading, paused, failed, downloaded
    
    public func description() -> String {
        switch self {
        case .gettingInfo:
            return "GettingInfo"
        case .downloading:
            return "Downloading"
        case .paused:
            return "Paused"
        case .failed:
            return "Failed"
        case .downloaded:
            return "downloaded"
        default:
            return "Unknown"
        }
    }
}

class SRDownloadModel: NSObject {
    open var fileName: String!
    open var fileURL: String!
    open var status: String = Status.gettingInfo.description()
    
    open var file: (size: Float, unit: String)?
    open var downloadedFile: (size: Float, unit: String)?
    
    open var remainingTime: (hours: Int, minutes: Int, seconds: Int)?
    
    open var speed: (speed: Float, unit: String)?
    
    open var progress: Float = 0
    
    open var task: URLSessionDownloadTask?
    
    open var startTime: Date?
    
    var didUpdateHandler:((_ model:SRDownloadModel, _ message:String)->Void)?
    
    open var destinationPath: String = ""
    var isVideoPlay:Bool = false
    convenience init(fileName: String, fileURL: String) {
        self.init()
        
        self.fileName = fileName
        self.fileURL = fileURL
    }
    
    convenience init(fileName: String, fileURL: String, destinationPath: String) {
        self.init(fileName: fileName, fileURL: fileURL)
        
        self.destinationPath = destinationPath
    }
    
}
