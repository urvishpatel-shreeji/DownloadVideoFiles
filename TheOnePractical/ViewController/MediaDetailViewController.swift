//
//  MediaDetailViewController.swift
//  TheOnePractical
//
//  Created by Urvish Patel on 16/06/21.
//

import UIKit
import AVKit

class MediaDetailViewController: UIViewController {
    
    @IBOutlet weak var moviewThumbImageView:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var subTitle:UILabel!
    @IBOutlet weak var fileSize:UILabel!
    @IBOutlet weak var btnDownload:UIButton!
    var model:Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupUI(){
        self.title = "Details"
        #if DEBUG
        view.overrideUserInterfaceStyle = .light
        #else
        view.overrideUserInterfaceStyle = .dark
        #endif
        
        self.name.font = UIFont.appBoldFont(withFontSize: 18)
        self.name.textColor = UIColor.appTextColor()
        self.name.backgroundColor = UIColor.clear
        self.name.numberOfLines = 0
        
        self.subTitle.font = UIFont.appRegularFont(withFontSize: 15)
        self.subTitle.textColor = UIColor.appLightGray()
        self.subTitle.backgroundColor = UIColor.clear
        self.subTitle.numberOfLines = 0
        
        self.fileSize.font = UIFont.appRegularFont(withFontSize: 15)
        self.fileSize.textColor = UIColor.appLightGray()
        self.fileSize.backgroundColor = UIColor.clear
        self.fileSize.numberOfLines = 0
        
        self.didUpdateData()
        self.model.downloadModel.didUpdateHandler = {
            [weak self] (downloadModel,message) in
            guard let self = `self` else {return}
            
            self.model.downloadModel = downloadModel;
            
            self.didUpdateData()
        }
        
    }
    private func didUpdateData(){
        self.name.text = model.title
        self.subTitle.text = model.subTitle
        self.moviewThumbImageView.sd_setImage(with: URL.init(string: model.thumbURL), placeholderImage: UIImage.init(named: "placeholderImage"), options: .continueInBackground) { (image, error, cacheType, url) in
            if error == nil {
                self.moviewThumbImageView.image = image
            }
        }
        if let downloadFile = self.model.downloadModel.downloadedFile{
            self.fileSize.text = "\(String(format: "Size: %.2f", downloadFile.0)) \(downloadFile.1)"
        }
        else{
            self.fileSize.text = ""
        }
        if(self.model.downloadModel.status == Status.downloaded.description()){
            self.btnDownload.setTitle("Play", for: .normal)
            
        }else if (self.model.downloadModel.status == Status.downloading.description()){
            self.btnDownload.setTitle("Downloading", for: .normal)
            
        }else if (self.model.downloadModel.status == Status.failed.description()){
            self.btnDownload.setTitle("Failed", for: .normal)
            
        }else if (self.model.downloadModel.status == Status.gettingInfo.description()){
            self.btnDownload.setTitle("Start Download", for: .normal)
            
        }else if (self.model.downloadModel.status == Status.paused.description()){
            self.btnDownload.setTitle("Pause", for: .normal)
            
        }
        else{
            self.btnDownload.setTitle("Download", for: .normal)
            
        }
    }
    
    //MARK: - Button Action
    @IBAction func btnDownloadHandler(sender:UIButton){
        if (model.downloadModel.status == Status.gettingInfo.description()){
            SRDownloadManager.shared.resumeDownload(model:model.downloadModel)
        } else if (model.downloadModel.status == Status.downloaded.description()){
            self.openMoviePlayerViewController(withMovie: model)
        }else if (model.downloadModel.status == Status.failed.description()){
            print("Not Downloaded :: ")
        }else if (model.downloadModel.status == Status.downloading.description()){
            SRDownloadManager.shared.pauseDownloadTask(model: model.downloadModel)
        }else if (model.downloadModel.status == Status.paused.description()){
            SRDownloadManager.shared.resumeDownload(model:model.downloadModel)
        }
    }
    private func openMoviePlayerViewController(withMovie movie:Movie){
        
        let filePath = SRFileManager.baseFilePath + "/" + movie.downloadModel.fileName
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: filePath))
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
          player.play()
        }
        
    }
}
