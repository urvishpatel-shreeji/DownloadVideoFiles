//
//  MediaTableCell.swift
//  TheOnePractical
//
//  Created by Urvish Patel on 16/06/21.
//

import UIKit
import SDWebImage

class MediaTableCell: UITableViewCell {

    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblSubTitle:UILabel!
    @IBOutlet weak var btnDownload:UIButton!
    @IBOutlet weak var movieThumbImageView:UIImageView!
    var btnDidClickHandler:((Movie)->Void)?
    var model:Movie!{
        didSet{
            self.didUpdateData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.configureCell()
    }
    private func configureCell(){
        self.lblName.font = UIFont.appBoldFont(withFontSize: 18)
        self.lblName.textColor = UIColor.appTextColor()
        self.lblName.backgroundColor = UIColor.clear
        self.lblName.numberOfLines = 0
        
        self.lblSubTitle.font = UIFont.appRegularFont(withFontSize: 15)
        self.lblSubTitle.textColor = UIColor.appLightGray()
        self.lblSubTitle.backgroundColor = UIColor.clear
        self.lblSubTitle.numberOfLines = 0
        
        self.selectionStyle = .none
    }
   private func didUpdateData(){
        self.lblName.text = model.title
        self.lblSubTitle.text = model.subTitle
    self.movieThumbImageView.sd_setImage(with: URL.init(string: model.thumbURL), placeholderImage: UIImage.init(named: "placeholderImage"), options: .continueInBackground) { (image, error, cacheType, url) in
        if error == nil {
            self.movieThumbImageView.image = image
        }
    }
    if let downloadFile = self.model.downloadModel.downloadedFile{
        self.lblSubTitle.text = "\(String(format: "Size: %.2f", downloadFile.0)) \(downloadFile.1)"
    }
    else{
        self.lblSubTitle.text = "\(self.model.subTitle)"
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
    func updateCell(withModel model:Movie){
        self.model = model
        self.model.downloadModel.didUpdateHandler = {
           [weak self] (downloadModel,message) in
            guard let self = `self` else {return}
            
            self.model.downloadModel = downloadModel;
            
            self.didUpdateData()
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnDownloadHandler(sender:UIButton){
        if let handler = self.btnDidClickHandler{
            handler(self.model)
        }
    }
    
}
