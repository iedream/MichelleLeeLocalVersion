//
//  audioPlayer.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2015-08-13.
//  Copyright © 2015 Catherine. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation



class audioPlayer:UIViewController,AVAudioPlayerDelegate {
    
    // Singleton
    static let sharedInstance = audioPlayer()
    
    // Player
    var player : AVAudioPlayer! = nil
    var pathName:String = String()

    // Slider
    var slider = UISlider()
    
    // States
    let AUDIO_PLAYER_PLAY_SINGLE:NSInteger = 0
    let AUDIO_PLAYER_PLAY_MULTIPLE:NSInteger = 1
    let AUDIO_PLAYER_PAUSE_SINGLE:NSInteger = 2
    let AUDIO_PLAYER_PAUSE_MULTIPLE:NSInteger = 3
    let AUDIO_NOT_INIT:NSInteger  = 4
    var currentMode:NSInteger = 4
    
    // Time Lables
    var currentTimeLable = UILabel()
    var endTimeLable = UILabel()
    
    // Video MV Button
    var mvButton:UIButton = UIButton()
    var videoDic:[String:String] = [String:String]()

    // Timer
    var timer = NSTimer()
    
    // Data
    var mainData = NSArray()
    var currentPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Set Up player
    func setUpPlayer(name:String, actSlider:UISlider, actCurrentLabel:UILabel, actEndLabel:UILabel, videoButton:UIButton){
        
        // Assign View Property
        slider = actSlider
        currentTimeLable = actCurrentLabel
        endTimeLable = actEndLabel
        mvButton = videoButton
        
        // Set up the Player
        let path =  NSBundle.mainBundle().pathForResource(name, ofType: "mp3")
        
        do {
            try player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path!), fileTypeHint:nil)
        } catch {
            //Handle the error
        }
        
        // If there is video for it, enable the mv button
        if((videoDic[name]) != nil){
            mvButton.alpha = 1.0
            mvButton.userInteractionEnabled = true
        }else{
            mvButton.alpha = 0.3
            mvButton.userInteractionEnabled = false
        }
        
        //AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path!), error: nil)
       //player = AVAudioPlayer(contentsOfURL: NSURL (fileURLWithPath: path!), fileTypeHint:nil)

        //Handle the error

        // Set Up Slider
        slider.userInteractionEnabled = true
        slider.alpha = 1.0
        slider.maximumValue = Float32(self.player.duration)
        
        // Start Time Lable
        currentTimeLable.alpha = 1.0
        currentTimeLable.text = "00:00"
        
        // Set up End Time Lable
        let minute:Double = floor(Double(slider.maximumValue)/60)
        let second:Double = Double(slider.maximumValue) - (minute*60)
        var minuteToDisplay = String()
        var secondToDisplay = String()
        if(minute >= 10)
        {
            minuteToDisplay = String(format: "%.0f", minute)
        }
        if(minute < 10)
        {
            minuteToDisplay = String(format: "0%0.0f",minute)
        }
        if(second >= 10)
        {
            secondToDisplay = String(format: "%.0f", second)
        }
        if(second < 10)
        {
            secondToDisplay = String(format: "0%0.0f",second)
        }
        endTimeLable.alpha = 1.0
        endTimeLable.text = String(format:"%@:%@",minuteToDisplay,secondToDisplay)
        endTimeLable.adjustsFontSizeToFitWidth = true
        
        // automatically play
        self.play()
    }
    
    // Update the Current Time Lable
    func update(){
        // If not currently srubbing then update the slider to the right position
        if(currentMode == AUDIO_PLAYER_PLAY_SINGLE || currentMode == AUDIO_PLAYER_PLAY_MULTIPLE){
            slider.value = Float(player.currentTime)
            
            // Converting to time formate
            var minute:Double   = Double(floorf(slider.value/60))
            let second:Double   = Double(slider.value) - (minute*60)
            var minuteToDisplay = String()
            var secondToDisplay = String()
            
            
            // Decide how to display
            
            if(roundf(Float(second)) == 60 )
            {
                secondToDisplay = "00"
                minute = minute + 1;
            }else if(roundf(Float(second)) >= 10)
            {
                secondToDisplay = String(format: "%.0f", second)
            }else if(roundf(Float(second)) < 10)
            {
                secondToDisplay = String(format: "0%.0f",second)
            }
            
            
            if(minute >= 10)
            {
                minuteToDisplay = String(format: "%.0f", minute)
            }else if(minute < 10)
            {
                minuteToDisplay = String(format: "0%.0f",minute)
            }
            
            // Update the Current Time lable
            currentTimeLable.text = String(format:"%@:%@",minuteToDisplay,secondToDisplay)
        }
    }
    
    // setMode
    func setMode(state:NSInteger){
        if(state == AUDIO_PLAYER_PAUSE_SINGLE || state == AUDIO_PLAYER_PAUSE_MULTIPLE){
            player.pause()
        }
       currentMode = state
    }
    
    // Play Audio
    func play(){
        // Set Player
        player.prepareToPlay()
        player.play()
        
        // Set Current Mode
        if(currentMode == AUDIO_PLAYER_PAUSE_SINGLE){
            currentMode = AUDIO_PLAYER_PLAY_SINGLE
        }else if(currentMode == AUDIO_PLAYER_PAUSE_MULTIPLE){
            currentMode = AUDIO_PLAYER_PLAY_MULTIPLE
        }
        
        // Set Delegate for Player
        player.delegate = self
        
        // Set up Timer to update Current Time Lable
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    // Pause Audio
    func pause(){
        player.pause()
        timer.invalidate()
    }
    
    func playAtTime(actSlider:UISlider){
        // assign slider
        slider = actSlider
        
        // Set Player
        player.prepareToPlay()
        player.currentTime = Double(slider.value)
        player.play()
        
        // Set Current Mode
        if(currentMode == AUDIO_PLAYER_PAUSE_SINGLE){
            currentMode = AUDIO_PLAYER_PLAY_SINGLE
        }else if(currentMode == AUDIO_PLAYER_PAUSE_MULTIPLE){
            currentMode = AUDIO_PLAYER_PLAY_MULTIPLE
        }
        
        // Set up Timer to update Current Time Lable
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        switch(currentMode){
            case AUDIO_PLAYER_PLAY_MULTIPLE:
                
                // Get Current Index
                let begIndex:NSInteger = mainData.indexOfObject(currentPath) as NSInteger
                
                // Get Index of New Path
                let index:NSInteger = begIndex+1
                
                // Check if the index is ouf of range, if it is, start from the beginning
                if( index >= mainData.count){
                    // Get Next Video Path and give it to the player to set the player up
                    currentPath = mainData.objectAtIndex(0) as! String
                    self.setUpPlayer(currentPath, actSlider: slider, actCurrentLabel: currentTimeLable, actEndLabel: endTimeLable, videoButton: mvButton)
                }else{
                    // Get Next Video Path and give it to the player to set the player up
                    currentPath = mainData.objectAtIndex(index) as! String
                    self.setUpPlayer(currentPath, actSlider: slider, actCurrentLabel: currentTimeLable, actEndLabel: endTimeLable, videoButton: mvButton)
                }
                break
            case AUDIO_PLAYER_PLAY_SINGLE:
                // Give the current Video Path to the player and set the player up
                self.setUpPlayer(currentPath, actSlider: slider, actCurrentLabel: currentTimeLable, actEndLabel: endTimeLable, videoButton: mvButton)
                break
            default:
                break
        }
    }
    
    func setAudioAtBeginning(actSlider:UISlider, actCurrentLabel:UILabel, actEndLabel:UILabel){
        // Assign View Property
        slider = actSlider
        currentTimeLable = actCurrentLabel
        endTimeLable = actEndLabel
        
        // Set Up Slider
        slider.userInteractionEnabled = false
        slider.setValue(0, animated: true)
        slider.alpha = 0.3
        
        // Set Up Label
        currentTimeLable.text = ""
        endTimeLable.text = ""
        
        self.setMode(AUDIO_NOT_INIT)
    }
    
    // Clear Audio Player
    func clearPlayer(actSlider:UISlider, actCurrentLabel:UILabel, actEndLabel:UILabel){
        slider = actSlider
        currentTimeLable = actCurrentLabel
        endTimeLable = actEndLabel
        
        self.setMode(AUDIO_NOT_INIT)
        
        // Disable the Player
        player = nil
        
        // Remove Timer
        timer.invalidate()

        
        // Disable Slider
        slider.userInteractionEnabled = false
        slider.setValue(0, animated: true)
        
        // Clear Time Lable
        currentTimeLable.text = ""
        endTimeLable.text = ""
    }
    



}

