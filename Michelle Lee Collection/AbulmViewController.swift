//
//  AbulmViewController.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2015-08-12.
//  Copyright © 2015 Catherine. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AbulmViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate {
    
    // AudioPlayerProperty
    @IBOutlet var audioView: UIView!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var singleRotateButton: UIButton!
    @IBOutlet var multipleRotateButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    
    // AudioPlayer States
    let AUDIO_PLAYER_PLAY_SINGLE:NSInteger = 0
    let AUDIO_PLAYER_PLAY_MULTIPLE:NSInteger = 1
    let AUDIO_PLAYER_PAUSE_SINGLE:NSInteger = 2
    let AUDIO_PLAYER_PAUSE_MULTIPLE:NSInteger = 3
    let AUDIO_NOT_INIT:NSInteger  = 4
    var currentMode:NSInteger = 4
    
    // Table View Property
    let tableViewCellIdentifier = "audioTableViewCell"
    @IBOutlet var audioTableView: UITableView!
    
    // Picker View Property
    @IBOutlet var pickerView: UIPickerView!
    var pickerViewData:[String] = [String]()
    
    // Search View
    @IBOutlet var txtFiled: UITextField!
    
    // Main Data
    let amblum1:[String:String] = ["你看到的我是蓝色的":"song1","习惯":"song2","爸爸给的坚强":"song3","被剧中的音符":"song4","灯":"song5","我没那么狠心":"song6","微笑练习":"song7","你不在的时候":"song8","沉淀":"song9","我为谁而来":"song10"]
    let amblum2:[String:String] = ["可能":"song11","房间1501":"song12","你说的对":"song13","化妆师":"song14","私游":"song15","口袋里的练习曲":"song16","sorry day":"song17"]
    let amblum3:[String:String] = ["沉淀":"song19"]
    let amblum4:[String:String] = ["恋爱世纪":"song19"]
    var allAmblum = [String:[String:String]]()
    
    // Table Data
    var tableTitleArray = [String]()
    var currentDic = [String:String]()
    var currentPath = String()
    
    // Video Data
    @IBOutlet var mvButton: UIButton!
    @IBOutlet var clearVideoButton: UIButton!
    @IBOutlet var videoPlayerView: UIView!
    var isFullScreen:Bool = false
    var timer:NSTimer = NSTimer()
    @IBOutlet var noResult: UILabel!
    let videoDic:[String:String] = ["你看到的我是蓝色的":"video121","可能":"video120","沉淀":"video122","习惯":"video123"]
    let audioVideoDic:[String:String] = ["song1":"video121","song11":"video120","song9":"video122","song2":"video123"]
    var videoObserver:NSObjectProtocol! = nil
    
    // Screen SetUp Property
    @IBOutlet var background: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allAmblum = [/*"快乐女声":amblum3,*/ "你看到的我是蓝色的":amblum1, "可能":amblum2, "恋爱世纪":amblum4]
        tableTitleArray = [String](allAmblum.keys)
        
        audioView.backgroundColor = UIColor.clearColor()
        audioView.layer.borderColor = UIColor.whiteColor().CGColor
        audioView.layer.borderWidth = 1.0
        
        currentTimeLabel.textColor = UIColor.whiteColor()
        endTimeLabel.textColor = UIColor.whiteColor()
        
        audioTableView.backgroundColor = UIColor.clearColor()
        audioTableView.delegate = self
        audioTableView.dataSource = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.hidden = true
        
        videoPlayerView.hidden = true
        clearVideoButton.hidden = true
    
        
        noResult.adjustsFontSizeToFitWidth = true
        noResult.backgroundColor = UIColor.redColor()
        noResult.hidden = true

        audioPlayer.sharedInstance.videoDic = audioVideoDic
        timer = NSTimer.scheduledTimerWithTimeInterval(/*0.00001*/0.5, target: self, selector: Selector("updateFullScreenState"), userInfo: nil, repeats: true)
        
        // All Button Inactive
        let inactiveButton:[UIButton] = [playButton,pauseButton,singleRotateButton,multipleRotateButton,mvButton]
        let activeButton:[UIButton] = [];
        self.buttonActiveandInactive(activeButton, inactiveButtons:inactiveButton)
        audioPlayer.sharedInstance.setAudioAtBeginning(slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -Populate Table Methods -
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTitleArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = audioTableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        
        if(tableTitleArray.count != 0){
            cell.textLabel?.text = tableTitleArray[row]
        }
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    // MARK: - Actions When Table View Cell Selected -
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        audioTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        let name:String = tableTitleArray[row]
        noResult.hidden = true
        
        // if the count equals, then still at main menu, so clear table view and populate it with sub menu, and assign correct properties
        // if the cound doesn't equals, then in sub menu, so set up player and properties, and change audio view
        if(tableTitleArray.count == allAmblum.count){ // Set Property
            currentDic.removeAll()
            currentDic = allAmblum[name]!
            
            // Clear Table View and Reload
            tableTitleArray.removeAll()
            tableTitleArray = [String](allAmblum[name]!.keys)
            audioTableView.reloadData()
        }else{
            currentPath = currentDic[name]!
            
            // Set Up Audio Player, Audio Player Mode, Audio Player Property
            audioPlayer.sharedInstance.setUpPlayer(currentPath, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton)
            audioPlayer.sharedInstance.currentPath = currentDic[name]!
            audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PLAY_MULTIPLE)
            // Set Audio Player Property
            audioPlayer.sharedInstance.mainData = [String](currentDic.values)
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [pauseButton,singleRotateButton]
            let inactiveButton:[UIButton] = [playButton,multipleRotateButton]
            
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }
        
        
        
    }
    
    // MARK: - Populate Picker View Methods -
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewData[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerViewData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.blueColor()])
        return myTitle
    }
    
    // MARK: - Picker View Cell Selected -
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let name:String = pickerViewData[row];
        let subDict:[String:String] = allAmblum[name]!
        currentDic.removeAll()
        currentDic = subDict
        
        // Set Audio Player Property
        audioPlayer.sharedInstance.mainData = [String](currentDic.values)
        
        
        // Set Up Audio Player, Audio Player Mode, Audio Player Property
        audioPlayer.sharedInstance.setUpPlayer(subDict[(txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]!, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton)
        audioPlayer.sharedInstance.currentPath = currentDic[(txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]!
        audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PLAY_MULTIPLE)
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = [pauseButton,singleRotateButton]
        let inactiveButton:[UIButton] = [playButton,multipleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        
        pickerViewData.removeAll()
        pickerView.reloadComponent(0)
        pickerView.hidden = true
        
    }
    
    // MARK: - Function Button Method -
    
    // Go Back to main screen and reset everything in this screen
    @IBAction func goHome(sender: UIButton) {
        
        timer.invalidate()
        
        // Clear Video Player
        videoPlayer.sharedInstance.clear()
        if((videoObserver) != nil){
            NSNotificationCenter.defaultCenter().removeObserver(videoObserver)
        }
        
        // Clear audio player
        audioPlayer.sharedInstance.clearPlayer(slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel)
        
        // All Buttons Inactive
        let inactiveButton:[UIButton] = [playButton,pauseButton,singleRotateButton,multipleRotateButton]
        let activeButton:[UIButton] = []
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    // Go Back to main menu
    @IBAction func backToHomeMenu(sender: AnyObject) {
        noResult.hidden = true
        tableTitleArray.removeAll()
        tableTitleArray = [String](allAmblum.keys)
        audioTableView.reloadData()
    }
    
    // MARK: - Audio Player Button Method -
    
    // call play audio method in audio player class
    @IBAction func playAudio(sender: AnyObject) {
        // set audio player
        audioPlayer.sharedInstance.play()
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [pauseButton]
        let unactiveButton:[UIButton] = [playButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
    }
    
    // call pause audio method in audio player class
    @IBAction func pauseAudio(sender: AnyObject) {
        // assign audio player mode
        if(audioPlayer.sharedInstance.currentMode == AUDIO_PLAYER_PLAY_MULTIPLE){
            audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PAUSE_MULTIPLE)
        }else if(audioPlayer.sharedInstance.currentMode == AUDIO_PLAYER_PLAY_SINGLE){
            audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PAUSE_SINGLE)
        }
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [playButton]
        let unactiveButton:[UIButton] = [pauseButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
    }
    
    // set multiple rotation in audio player class
    @IBAction func setMultipleRotateMode(sender: AnyObject) {
        // assign audio player mode
        audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PLAY_MULTIPLE)
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [singleRotateButton]
        let unactiveButton:[UIButton] = [multipleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
    }
    
    // set single rotation in audio player class
    @IBAction func setSingleRotateMode(sender: AnyObject) {
        // assign audio player mode
        audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PLAY_SINGLE)
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [multipleRotateButton]
        let unactiveButton:[UIButton] = [singleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
    }
    
    // set user scrubbing in audio player class
    @IBAction func userScrubbing(sender: AnyObject) {
        // assign audio player mode
        if(audioPlayer.sharedInstance.currentMode == AUDIO_PLAYER_PLAY_MULTIPLE){
            audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PAUSE_MULTIPLE)
        }else if(audioPlayer.sharedInstance.currentMode == AUDIO_PLAYER_PLAY_SINGLE){
            audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PAUSE_SINGLE)
        }
    }
    
    // set player to play from a certain time in audio player class
    @IBAction func setCurrentAudioTime(sender: AnyObject) {
        audioPlayer.sharedInstance.playAtTime(slider)
    }
    
    // MARK: -  search for songs -
    
    // search for songs
    @IBAction func searchForSongs(sender: AnyObject) {
        var results:[String:[String:String]] = [String:[String:String]]()
        for(key,value) in allAmblum{
            for(name,path) in value{
                if(name == txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())){
                    results[key] = [name:path]
                }
            }
        }
        
        // if there is only one result, then play that one
        if(results.count == 1){
            let resultsDic:[String:String] = Array(results.values).first!
            let dict:[String:String] = [String:String](dictionaryLiteral: resultsDic.first!)
            // Set Up Audio Player, Audio Player Mode, Audio Player Property
            audioPlayer.sharedInstance.setUpPlayer(dict[(txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]!, actSlider: slider, actCurrentLabel: currentTimeLabel, actEndLabel: endTimeLabel, videoButton: mvButton)
            audioPlayer.sharedInstance.currentPath = dict[(txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]!
            currentDic.removeAll()
            currentDic = allAmblum[results.keys.first!]!
            audioPlayer.sharedInstance.mainData = [String](currentDic.values)
            audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PLAY_MULTIPLE)
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [pauseButton,singleRotateButton]
            let inactiveButton:[UIButton] = [playButton,multipleRotateButton]
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }else if(results.count > 1){
            pickerView.hidden = false
            pickerViewData = [String](results.keys)
            pickerView.reloadComponent(0)
        }else if(results.count == 0){
            noResult.text = "No Result For " + (txtFiled.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
            noResult.hidden = false
        }
        txtFiled.resignFirstResponder()
    }
    
    // MARK: - video Button Method -
    
    @IBAction func playVideo(sender: AnyObject) {
        // assign audio player mode
        if(audioPlayer.sharedInstance.currentMode == AUDIO_PLAYER_PLAY_MULTIPLE){
            audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PAUSE_MULTIPLE)
        }else if(audioPlayer.sharedInstance.currentMode == AUDIO_PLAYER_PLAY_SINGLE){
            audioPlayer.sharedInstance.setMode(AUDIO_PLAYER_PAUSE_SINGLE)
        }
        
        // Set Button Active and Inactive
        let activeButton :[UIButton] = [playButton]
        let unactiveButton:[UIButton] = [pauseButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: unactiveButton)
        
        clearVideoButton.hidden = false
        
        let name:String = (currentDic as NSDictionary).allKeysForObject(currentPath).first as! String
        videoPlayer.sharedInstance.playVideo(videoDic[name]!, frame:videoPlayerView.frame)
        self.addChildViewController(videoPlayer.sharedInstance)
        self.view.addSubview(videoPlayer.sharedInstance.view)
        videoPlayer.sharedInstance.player?.play()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        
        videoObserver = notificationCenter.addObserverForName(AVPlayerItemDidPlayToEndTimeNotification, object: nil, queue: mainQueue) { _ in
            
            videoPlayer.sharedInstance.player?.replaceCurrentItemWithPlayerItem(nil)
            videoPlayer.sharedInstance.view.removeFromSuperview()
            videoPlayer.sharedInstance.path = nil
            self.clearVideoButton.hidden = true
        }
    }
    
    @IBAction func clearVideo(sender: AnyObject) {
        videoPlayer.sharedInstance.clear()
        clearVideoButton.hidden = true
    }
    
    
    // MARK: - Helper Methods -
    func buttonActiveandInactive(activeButtons:[UIButton], inactiveButtons:[UIButton]){
        for button:UIButton in activeButtons{
            button.alpha = 1.0
            button.userInteractionEnabled = true
        }
        for button:UIButton in inactiveButtons{
            button.alpha = 0.3
            button.userInteractionEnabled = false
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func textFieldReturn(sender: AnyObject){
        sender.resignFirstResponder()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if(isFullScreen){
            if(UIDevice.currentDevice().orientation.isLandscape){
                return UIInterfaceOrientationMask.Landscape
            }else{
                return UIInterfaceOrientationMask.Portrait
            }
            
        }else{
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    func rotateScreenBackToPortrait(){
        
        videoPlayer.sharedInstance.view.removeFromSuperview()
        videoPlayer.sharedInstance.view.frame = videoPlayerView.frame
        self.view.addSubview(videoPlayer.sharedInstance.view)
    }
    
    func updateFullScreenState(){
        
        var fullScreenView:Bool = false
        if(videoPlayer.sharedInstance.videoBounds.width == self.view.frame.width){
            fullScreenView = true
        }else if(videoPlayer.sharedInstance.videoBounds.width == self.view.frame.height){
            fullScreenView = true
        }else if(videoPlayer.sharedInstance.videoBounds.height == self.view.frame.width){
            fullScreenView = true
        }else if(videoPlayer.sharedInstance.videoBounds.height == self.view.frame.height){
            fullScreenView = true
        }
        
        
        if(videoPlayer.sharedInstance.view != nil && fullScreenView ){
            isFullScreen = true
            
        }else{
            if(isFullScreen && UIDevice.currentDevice().orientation.isLandscape){
                isFullScreen = false
                UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
                _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("rotateScreenBackToPortrait"), userInfo: nil, repeats: false)
            }else if(isFullScreen && UIDevice.currentDevice().orientation.isPortrait){
                isFullScreen = false
                rotateScreenBackToPortrait()
            }
        }
    }

    
}
