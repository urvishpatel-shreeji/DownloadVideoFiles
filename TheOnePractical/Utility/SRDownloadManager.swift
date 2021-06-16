//
//  SRDownloadManager.swift
//  TheOnePractical
//
//  Created by Urvish Patel on  16/06/21.
//

import UIKit
import Foundation

class SRDownloadManager: NSObject {
    fileprivate var sessionManager: URLSession!
    
    fileprivate var backgroundSessionCompletionHandler: (() -> Void)?
    
    fileprivate let TaskDescFileNameIndex = 0
    fileprivate let TaskDescFileURLIndex = 1
    fileprivate let TaskDescFileDestinationIndex = 2
    
    //fileprivate weak var delegate: SRDownloadManagerDelegate?
    
    open var downloadingArray: [SRDownloadModel] = []
    let myDownloadPath = SRFileManager.baseFilePath + "/MyDownloads"
    
    static var shared:SRDownloadManager = SRDownloadManager()
    private override init() {
        super.init()
        let sessionIdentifer: String = "com.TheOnePractical"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let completion = appDelegate.backgroundSessionCompletionHandler
        
        print(myDownloadPath)
        //self.delegate = delegate
        self.sessionManager = self.backgroundSession(identifier: sessionIdentifer, configuration: nil)
        self.populateOtherDownloadTasks()
        self.backgroundSessionCompletionHandler = completion
    
    }
//    public convenience init(session sessionIdentifer: String, delegate: SRDownloadManagerDelegate, sessionConfiguration: URLSessionConfiguration? = nil, completion: (() -> Void)? = nil) {
//        self.init()
//        self.delegate = delegate
//        self.sessionManager = backgroundSession(identifier: sessionIdentifer, configuration: sessionConfiguration)
//        //self.populateOtherDownloadTasks()
//        self.backgroundSessionCompletionHandler = completion
//    }
    
    public class func defaultSessionConfiguration(identifier: String) -> URLSessionConfiguration {
        return URLSessionConfiguration.background(withIdentifier: identifier)
    }
    
    fileprivate func backgroundSession(identifier: String, configuration: URLSessionConfiguration? = nil) -> URLSession {
        let sessionConfiguration = configuration ?? SRDownloadManager.defaultSessionConfiguration(identifier: identifier)
        assert(identifier == sessionConfiguration.identifier, "Configuration identifiers do not match")
        
        let session = URLSession(configuration: sessionConfiguration,delegate: self, delegateQueue: nil)
        return session
    }
    
    public func resumeDownload(model:SRDownloadModel){
        if (model.task == nil ){
            let url = URL(string: model.fileURL)!
            let request = URLRequest(url: url)
           
            let fileURL = url.absoluteString
            
            let downloadTask = sessionManager.downloadTask(with: request)
            downloadTask.taskDescription = [model.fileName, fileURL, self.myDownloadPath].joined(separator: ",")
            downloadTask.resume()
            model.status = Status.downloading.description()
            
            model.startTime = Date()
            model.task = downloadTask;
            
            if self.downloadingArray.contains(model), let objectIndex = self.downloadingArray.firstIndex(of: model) {
                self.downloadingArray[objectIndex] = model
            }
            
            if let handler = model.didUpdateHandler {
                handler(model,"")
            }
            
        }else{
            
            let downloadTask = model.task
            downloadTask?.resume()
            
            model.status = Status.downloading.description()
            model.startTime = Date()
            model.task = downloadTask;
            
            if self.downloadingArray.contains(model), let objectIndex = self.downloadingArray.firstIndex(of: model) {
                self.downloadingArray[objectIndex] = model
            }
            
            if let handler = model.didUpdateHandler {
                handler(model,"")
            }
        }
        
        
    }
    
    @objc public func pauseDownloadTask(model:SRDownloadModel){
    
        
        if (model.task != nil ){

            model.task?.suspend()
            model.status = Status.paused.description()
            
            model.startTime = Date()
            //model.task = model.task;
            
            if self.downloadingArray.contains(model), let objectIndex = self.downloadingArray.firstIndex(of: model) {
                self.downloadingArray[objectIndex] = model
            }
            
            if let handler = model.didUpdateHandler {
                handler(model,"")
            }
        }
        
    }
   
}
// MARK: Private Helper functions

extension SRDownloadManager {
    
    fileprivate func downloadTasks() -> [URLSessionDownloadTask] {
        var tasks: [URLSessionDownloadTask] = []
        let semaphore : DispatchSemaphore = DispatchSemaphore(value: 0)
        sessionManager.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            tasks = downloadTasks
            semaphore.signal()
        }
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        debugPrint("MZDownloadManager: pending tasks \(tasks)")
        
        return tasks
    }
    
    fileprivate func populateOtherDownloadTasks() {
        
        let downloadTasks = self.downloadTasks()
        
        for downloadTask in downloadTasks {
            let taskDescComponents: [String] = downloadTask.taskDescription!.components(separatedBy: ",")
            let fileName = taskDescComponents[TaskDescFileNameIndex]
            let fileURL = taskDescComponents[TaskDescFileURLIndex]
            let destinationPath = taskDescComponents[TaskDescFileDestinationIndex]
            
            let downloadModel = SRDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
            downloadModel.task = downloadTask
            downloadModel.startTime = Date()
            
            if downloadTask.state == .running {
                downloadModel.status = Status.downloading.description()
                downloadingArray.append(downloadModel)
            } else if(downloadTask.state == .suspended) {
                downloadModel.status = Status.paused.description()
                downloadingArray.append(downloadModel)
            } else {
                downloadModel.status = Status.failed.description()
            }
        }
    }
    
    fileprivate func isValidResumeData(_ resumeData: Data?) -> Bool {
        
        guard resumeData != nil || resumeData?.count ?? 0 > 0 else {
            return false
        }
        
        return true
        
    }
}

extension SRDownloadManager: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //print("downloadTask")
        for (index, downloadModel) in self.downloadingArray.enumerated() {
            if downloadTask.isEqual(downloadModel.task) {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let receivedBytesCount = Double(downloadTask.countOfBytesReceived)
                    let totalBytesCount = Double(downloadTask.countOfBytesExpectedToReceive)
                    let progress = Float(receivedBytesCount / totalBytesCount)
                    
                    let taskStartedDate = downloadModel.startTime ?? Date()
                    let timeInterval = taskStartedDate.timeIntervalSinceNow
                    let downloadTime = TimeInterval(-1 * timeInterval)
                    
                    let speed = Float(totalBytesWritten) / Float(downloadTime)
                    
                    let remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten
                    
                    let remainingTime = remainingContentLength / Int64(speed)
                    let hours = Int(remainingTime) / 3600
                    let minutes = (Int(remainingTime) - hours * 3600) / 60
                    let seconds = Int(remainingTime) - hours * 3600 - minutes * 60
                    
                    let totalFileSize = SRFileManager.calculateFileSizeInUnit(totalBytesExpectedToWrite)
                    let totalFileSizeUnit = SRFileManager.calculateUnit(totalBytesExpectedToWrite)
                    
                    let downloadedFileSize = SRFileManager.calculateFileSizeInUnit(totalBytesWritten)
                    let downloadedSizeUnit = SRFileManager.calculateUnit(totalBytesWritten)
                    
                    let speedSize = SRFileManager.calculateFileSizeInUnit(Int64(speed))
                    let speedUnit = SRFileManager.calculateUnit(Int64(speed))
                    
                    downloadModel.remainingTime = (hours, minutes, seconds)
                    downloadModel.file = (totalFileSize, totalFileSizeUnit as String)
                    downloadModel.downloadedFile = (downloadedFileSize, downloadedSizeUnit as String)
                    downloadModel.speed = (speedSize, speedUnit as String)
                    downloadModel.progress = progress
                    
                    if self.downloadingArray.contains(downloadModel), let objectIndex = self.downloadingArray.firstIndex(of: downloadModel) {
                        self.downloadingArray[objectIndex] = downloadModel
                    }
                    if let handler = downloadModel.didUpdateHandler {
                        handler(downloadModel,"")
                    }
                    //self.delegate?.downloadRequestDidUpdateProgress(downloadModel, index: index)
                })
                break
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        for (index, downloadModel) in downloadingArray.enumerated() {
            if downloadTask.isEqual(downloadModel.task) {
                let fileName = downloadModel.fileName as NSString
                let basePath = downloadModel.destinationPath == "" ? SRFileManager.baseFilePath : downloadModel.destinationPath
                let destinationPath = (basePath as NSString).appendingPathComponent(fileName as String)
                
                let fileManager : FileManager = FileManager.default
                
                //If all set just move downloaded file to the destination
                if fileManager.fileExists(atPath: basePath) {
                    let fileURL = URL(fileURLWithPath: destinationPath as String)
                    debugPrint("directory path = \(destinationPath)")
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        downloadModel.status = Status.downloaded.description();
                        
                        if let handler = downloadModel.didUpdateHandler {
                            handler(downloadModel,"Successful Downloaded.")
                        }
                        
                    })
                    
                    
                    do {
                        try fileManager.moveItem(at: location, to: fileURL)
                    } catch let error as NSError {
                        debugPrint("Error while moving downloaded file to destination path:\(error)")
                        //Intruption Error we need to display over here
                        DispatchQueue.main.async(execute: { () -> Void in
                            downloadModel.status = Status.failed.description();
                            if let handler = downloadModel.didUpdateHandler {
                                handler(downloadModel,error.debugDescription)
                            }
                            //self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                        })
                    }
                } else {
                    //Opportunity to handle the folder doesnot exists error appropriately.
                    //Move downloaded file to destination
                    //Delegate will be called on the session queue
                    //Otherwise blindly give error Destination folder does not exists
                    let error = NSError(domain: "FolderDoesNotExist", code: 404, userInfo: [NSLocalizedDescriptionKey : "Destination folder does not exists"])
                    downloadModel.status = Status.failed.description();
                    if let handler = downloadModel.didUpdateHandler {
                        handler(downloadModel,error.debugDescription)
                    }
//                    if let _ = self.delegate?.downloadRequestDestinationDoestNotExists {
//                        //if destination file not exist handle here
//                        //self.delegate?.downloadRequestDestinationDoestNotExists?(downloadModel, index: index, location: location)
//
//                    } else {
//                        let error = NSError(domain: "FolderDoesNotExist", code: 404, userInfo: [NSLocalizedDescriptionKey : "Destination folder does not exists"])
//                        //Failed Error we need to display over here
//                        //self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
//                    }
                }
                
                break
            }
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("task id: \(task.taskIdentifier)")
        /***** Any interrupted tasks due to any reason will be populated in failed state after init *****/
        
        DispatchQueue.main.async {
            
            let err = error as NSError?
            
            if (err?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber)?.intValue == NSURLErrorCancelledReasonUserForceQuitApplication || (err?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber)?.intValue == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
                
                let downloadTask = task as! URLSessionDownloadTask
                let taskDescComponents: [String] = downloadTask.taskDescription!.components(separatedBy: ",")
                let fileName = taskDescComponents[self.TaskDescFileNameIndex]
                let fileURL = taskDescComponents[self.TaskDescFileURLIndex]
                let destinationPath = taskDescComponents[self.TaskDescFileDestinationIndex]
                
                let downloadModel = SRDownloadModel.init(fileName: fileName, fileURL: fileURL, destinationPath: destinationPath)
                downloadModel.status = Status.failed.description()
                downloadModel.task = downloadTask
                
                let resumeData = err?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
                
                var newTask = downloadTask
                if self.isValidResumeData(resumeData) == true {
                    newTask = self.sessionManager.downloadTask(withResumeData: resumeData!)
                } else {
                    newTask = self.sessionManager.downloadTask(with: URL(string: fileURL as String)!)
                }
                
                newTask.taskDescription = downloadTask.taskDescription
                downloadModel.task = newTask
                
                self.downloadingArray.append(downloadModel)
                
                //Intruption Error we need to display over here
                //self.delegate?.downloadRequestDidPopulatedInterruptedTasks(self.downloadingArray)
                downloadModel.status = Status.failed.description();
                if let handler = downloadModel.didUpdateHandler {
                    handler(downloadModel,"Download Request Populated Interrupted.")
                }
                
            } else {
                for(index, object) in self.downloadingArray.enumerated() {
                    let downloadModel = object
                    if task.isEqual(downloadModel.task) {
                        if err?.code == NSURLErrorCancelled || err == nil {
                            //self.downloadingArray.remove(at: index)
                            
                            if err == nil {
                                downloadModel.status = Status.downloaded.description();
                                if let handler = downloadModel.didUpdateHandler {
                                    handler(downloadModel,"Successful Download.")
                                }
                                //Request finished
                                //self.delegate?.downloadRequestFinished?(downloadModel, index: index)
                            } else {
                                downloadModel.status = Status.failed.description();
                                if let handler = downloadModel.didUpdateHandler {
                                    handler(downloadModel,"Canceled Download.")
                                }
                                //Request canceled
                                //self.delegate?.downloadRequestCanceled?(downloadModel, index: index)
                            }
                            
                        } else {
                            let resumeData = err?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
                            var newTask = task
                            if self.isValidResumeData(resumeData) == true {
                                newTask = self.sessionManager.downloadTask(withResumeData: resumeData!)
                            } else {
                                newTask = self.sessionManager.downloadTask(with: URL(string: downloadModel.fileURL)!)
                            }
                            
                            newTask.taskDescription = task.taskDescription
                            downloadModel.status = Status.failed.description()
                            downloadModel.task = newTask as? URLSessionDownloadTask
                            
                            self.downloadingArray[index] = downloadModel
                            
                            if let error = err {
                                //request download failed
                                //self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                                downloadModel.status = Status.failed.description();
                                if let handler = downloadModel.didUpdateHandler {
                                    handler(downloadModel,"Failed Download.")
                                }
                            } else {
                                let error: NSError = NSError(domain: "MZDownloadManagerDomain", code: 1000, userInfo: [NSLocalizedDescriptionKey : "Unknown error occurred"])
                                //request download failed
                                //self.delegate?.downloadRequestDidFailedWithError?(error, downloadModel: downloadModel, index: index)
                                
                                downloadModel.status = Status.failed.description();
                                if let handler = downloadModel.didUpdateHandler {
                                    handler(downloadModel,"Failed Download.")
                                }
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let backgroundCompletion = self.backgroundSessionCompletionHandler {
            DispatchQueue.main.async(execute: {
                backgroundCompletion()
            })
        }
        debugPrint("All tasks are finished")
    }
}

extension SRDownloadModel{
    convenience  init(fileName: String, fileURL: String, date:Date) {
        self.init(fileName: fileName,fileURL: fileURL)
        self.startTime = date;
        let strPath = SRFileManager.baseFilePath + "/" + fileName
        if (SRFileManager.shared.checkFileExistInLocation(withFileName: strPath)){
            self.status = Status.downloaded.description()
        }
        
        
    }
}
