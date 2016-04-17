//
//  videoPlayer.swift
//  Michelle
//
//  Created by Catherine Zhao on 2015-06-29.
//  Copyright (c) 2015 Catherine. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import AVKit

enum AVPlayerActionAtItemEnd : Int {
    case Advance
    case Pause
    case None
}

class videoPlayer: AVPlayerViewController {
    
    // Singleton
    static let sharedInstance = videoPlayer()
    
    //video player
    var path = NSBundle.mainBundle().pathForResource("hi", ofType:"mp4")
    var timer:NSTimer = NSTimer()
    
    
    // Video Player Data
    var videoData:[String] = [String]()
    var videoObserver:NSObjectProtocol! = nil
    var currentPathName:String = String()
    
    // Video Player State
    let Single_Rotate:NSInteger = 0
    let Multiple_Rotate:NSInteger = 1
    var currentState:NSInteger = 2
    
    override func viewDidLoad() {
    }
    
    func playVideo(video:String, frame:CGRect){
        
        
        currentPathName = video
        path = NSBundle.mainBundle().pathForResource(video, ofType:"mp4")
        let url:NSURL = NSURL(fileURLWithPath: path!)
        player = AVPlayer(URL:url)
        
        self.view.frame = frame

    }
    
    func addObserverForVideo(){
        if((videoObserver) != nil){
            NSNotificationCenter.defaultCenter().removeObserver(videoObserver)
        }
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        videoObserver = notificationCenter.addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: mainQueue) { _ in
            
            var newRow:NSInteger = self.videoData.indexOf(self.currentPathName)! + 1
            self.videoData.indexOf(self.currentPathName)! + 1
            if( newRow >= self.videoData.count){
                newRow = 0
            }
            if(self.currentState == self.Multiple_Rotate){
                self.playNextVideo(self.videoData[newRow])
                self.player!.play()
            }else if(self.currentState == self.Single_Rotate){
                self.playNextVideo(self.videoData[self.videoData.indexOf(self.currentPathName)!])
                self.player!.play()
            }
        }
    }
    
    func playNextVideo(video:String){
        currentPathName = video
        path = NSBundle.mainBundle().pathForResource(video, ofType:"mp4")
        let url:NSURL = NSURL(fileURLWithPath: path!)
        player = AVPlayer(URL:url)
        
    }
    
    func setMode(state:NSInteger){
        currentState = state
    }
    
    func clear(){
        if((videoObserver) != nil){
            NSNotificationCenter.defaultCenter().removeObserver(videoObserver)
        }
        path = nil
        player?.replaceCurrentItemWithPlayerItem(nil)
        self.view.removeFromSuperview()
    }
}