//
//  MediaListViewController.swift
//  TheOnePractical
//
//  Created by Urvish Patel on 16/06/21.
//

import UIKit
import AVFoundation
import AVKit

class MediaListViewController: UIViewController {

    @IBOutlet weak var tblMediaList:MediaListTableView!
    private var aryCategories:[Category] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableView()
    }
    //MARK: - Setup UI
    private func setupUI(){
        
        #if DEBUG
        view.overrideUserInterfaceStyle = .light
        #else
        view.overrideUserInterfaceStyle = .dark
        #endif
        
        self.title = "Video List"
        self.callListOfCategoryAPI()
        self.tableViewHandler()
    }
    
    //MARK: - API Method
    func callListOfCategoryAPI(){
        SRDownloadManager.shared.downloadingArray = []
        SRServiceManager.shared.callGetCategoryList {[weak self] (categories) in
            guard let self = `self` else {return}
            
            self.aryCategories = categories
            self.reloadTableView()
        }
    }
    //MARK: - TableView
    private func tableViewHandler(){
        self.tblMediaList.didSelectMovie {[weak self] (movie) in
            guard let self = `self` else {return}
            self.pushToMediaDetailViewController(withMovie: movie)
            
        }
        
        self.tblMediaList.didPlayMovie{[weak self] (movie) in
            guard let self = `self` else {return}
            self.openMoviePlayerViewController(withMovie: movie)
            
        }
    }
    private func reloadTableView(){
        self.tblMediaList.loadTableView(withData: self.aryCategories)
    }
    //MARK: - Navigation
    private func pushToMediaDetailViewController(withMovie movie:Movie){
        if let mediaDetailVC:MediaDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "MediaDetailViewController") as? MediaDetailViewController{
            mediaDetailVC.model = movie
            self.navigationController?.pushViewController(mediaDetailVC, animated: true )
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
