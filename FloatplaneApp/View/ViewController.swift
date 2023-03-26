//
//  ViewController.swift
//  FloatplaneApp
//
//  Created by George Urick on 3/25/23.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var deliveryKey: DeliveryKey!

    override func viewDidLoad() {
        super.viewDidLoad()
        GetVideos().get()
        DeliveryKeyFetcher().get { deliveryKey in
            self.deliveryKey = deliveryKey
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func startVideo(sender: Any) {
        let playerViewController = AVPlayerViewController()
        guard let qualityLevel = deliveryKey.resource.data.qualityLevelParams.params["360-avc1"] else {
            print("We're fucked")
            return
        }
        let fileName = qualityLevel.filename
        let token = qualityLevel.accessToken
        let cdn = deliveryKey.cdn
        let fileNameKey = DeliveryKey.QualityLevelParams.Constants.FileNameKey
        let accessTokenKey = DeliveryKey.QualityLevelParams.Constants.AccessTokenKey
        let path = deliveryKey.resource.uri
            .replacing(fileNameKey, with: fileName)
            .replacing(accessTokenKey, with: token)
        
        let video = "\(cdn)\(path)"
        let url = URL(string: video)!
        let player = AVPlayer(url: url)
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }


}

