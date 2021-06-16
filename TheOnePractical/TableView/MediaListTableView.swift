//
//  MediaListTableView.swift
//  TheOnePractical
//
//  Created by Urvish Patel on 16/06/21.
//

import UIKit
import AVFoundation
typealias DidSelectMovieSelectionCell = ((_ movie:Movie)->Void)

class MediaListTableView: UITableView {

    private var aryList:[Category] = []
    var didSelectMovieHandler:((_ movie:Movie)->Void)?
    var didPlayMovieHanlder:((_ movie:Movie)->Void)?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    func commonInit(){
        
        self.delegate = self
        self.dataSource = self
        //self.style = UITableView.Style.grouped
        //self.sectionIndexBackgroundColor = UIColor.appLightGrayColor()
        //self.sectionIndexTrackingBackgroundColor = UIColor.appBlueColor()
        self.estimatedRowHeight = 60.0
        self.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.rowHeight = UITableView.automaticDimension;
        self.separatorStyle = .none
        self.register(UINib(nibName: "MediaTableCell", bundle: nil), forCellReuseIdentifier: "MediaTableCell")
        
    }
    func loadTableView(withData data:[Category]){
        self.aryList = data;
        self.reloadData()
    }
    func didSelectMovie(withHandler handler:DidSelectMovieSelectionCell?){
        if let value = handler{
            self.didSelectMovieHandler = value
        }
    }
    func didPlayMovie(withHandler handler:DidSelectMovieSelectionCell?){
        if let value = handler{
            self.didPlayMovieHanlder = value
        }
    }
}
extension MediaListTableView:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return aryList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category:Category = aryList[section]
        return category.aryMovie.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let category:Category = aryList[indexPath.section]
        let cell:MediaTableCell = tableView.dequeueReusableCell(withIdentifier: "MediaTableCell") as! MediaTableCell
        
        let model:Movie = category.aryMovie[indexPath.row]
        cell.updateCell(withModel: model)
        
        cell.btnDidClickHandler = {
            (model) in

            if (model.downloadModel.status == Status.gettingInfo.description()){
                SRDownloadManager.shared.resumeDownload(model:model.downloadModel)
            } else if (model.downloadModel.status == Status.downloaded.description()){
                if let handler = self.didPlayMovieHanlder{
                    handler(model)
                }
            }else if (model.downloadModel.status == Status.failed.description()){
                print("Not Downloaded :: ")
            }else if (model.downloadModel.status == Status.downloading.description()){
                print("Downloading")
                SRDownloadManager.shared.pauseDownloadTask(model: model.downloadModel)
                //SRDownloadManager.shared.resumeDownloadTaskAtIndex(indexPath.row)
            }else if (model.downloadModel.status == Status.paused.description()){
                SRDownloadManager.shared.resumeDownload(model:model.downloadModel)
            }
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category:Category = aryList[indexPath.section]
      
        let model:Movie = category.aryMovie[indexPath.row]
        
        if let handler = self.didSelectMovieHandler{
            handler(model)
        }
    }
}
