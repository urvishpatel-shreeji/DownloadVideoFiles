//
//  SRLoader.swift
//  FlipTreeTest
//
//  Created by Urvish Patel on 15/05/21.
//

import UIKit
import Foundation
import NVActivityIndicatorView

class SRLoader: NSObject,NVActivityIndicatorViewable {

    static let shared:SRLoader = SRLoader()
    private let LoaderSize:CGSize = CGSize.init(width: 50, height: 50)
    var activityData:ActivityData = ActivityData()
    private override init() {
        super.init()
        self.setupUI()
    }
    func setupUI(){
        
    }
    private func getActivityData(withMessage message:String)->ActivityData{
        return ActivityData.init(size: LoaderSize, message: message, messageFont: nil, messageSpacing: nil, type: NVActivityIndicatorType.ballPulseSync, color: UIColor.appPrimeryColor(), padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: UIColor.white )
    }
    func showLoader(withMessage message:String){
        activityData = self.getActivityData(withMessage: message)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
     }
    func hideLoader(){
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        
    }
    func showProgressiveLoader(withMessage message:String){
        //self.showLoadingHUD()
    }
    
}

