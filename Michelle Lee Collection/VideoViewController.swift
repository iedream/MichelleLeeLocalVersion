//
//  VideoViewController.swift
//  Michelle Lee Collection
//
//  Created by Catherine Zhao on 2015-08-17.
//  Copyright © 2015 Catherine. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VideoViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {
    
    // Background Image Related
    @IBOutlet var backGroundImage: UIImageView!
     var imageName:String = String()
    
    // Storyboard Views that need to be populated
    @IBOutlet var videoCollectionView: UICollectionView!
    @IBOutlet var pickerView: UIPickerView!
    
    // Video Player View
    @IBOutlet var videoPlayerView: UIView!
    var isFullScreen:Bool = false
    var timer:NSTimer = NSTimer()
    
    // Search Field
    @IBOutlet var txtField: UITextField!
    
    // Storyboard Buttons
    @IBOutlet var singleRotateButton: UIButton!
    @IBOutlet var multipleRotateButton: UIButton!
    @IBOutlet var backButton: UIButton!
   
    // No Result View
    @IBOutlet var noResult: UILabel!
    
    // Single Section Main Data
    var mainDicSingle:[String:String] = [String:String]()
    var imageDicSingle:[String:CGImage] = [String:CGImage]()
    
    // Multi Section Main Data
    var mainDicMulti:[String:[String:String]] = [String:[String:String]]()
    var imageDicMulti:[String:[String:CGImage]] = [String:[String:CGImage]]()
    
    // Current Data
    var multiCurrentName:String = " "
    var pickerViewData:[String] = [String]()
    
    // Video Player State
    let Single_Rotate:NSInteger = 0
    let Multiple_Rotate:NSInteger = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Up Background Image
        backGroundImage.image = UIImage(named: imageName)
        
        // Set up collection view
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        videoCollectionView.backgroundColor = UIColor.clearColor()
        videoCollectionView.layer.borderColor = UIColor.blackColor().CGColor
        videoCollectionView.layer.borderWidth = 1.0
        
        // Set up picker view
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.hidden = true
        
        // Buttons and Views that need to be hidden
        videoPlayerView.hidden = true
        backButton.hidden = true
        noResult.adjustsFontSizeToFitWidth = true
        noResult.backgroundColor = UIColor.redColor()
        noResult.hidden = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.00001, target: self, selector: Selector("updateFullScreenState"), userInfo: nil, repeats: true)
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = []
        let inactiveButton:[UIButton] = [multipleRotateButton,singleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
     // MARK: - Get Individual Mp4 Image To Disply -
    
    // Setting up to get image from mp4
    func getImage(){
        if(mainDicSingle.count > 0){
            for (key,value) in mainDicSingle{
                let url = NSBundle.mainBundle().URLForResource(value, withExtension: "mp4")
                self.captureFrame(url!, timeInSeconds: 12, key: key, sectionKey: "")
            }
        }else if(mainDicMulti.count > 0){
            for(key,value) in mainDicMulti{
                for(name,path) in value{
                    let url = NSBundle.mainBundle().URLForResource(path, withExtension: "mp4")
                    self.captureFrame(url!, timeInSeconds: 12, key: name, sectionKey: key)
                }
            }
        }
    }
    
    // Acutally getting the image
    func captureFrame(url:NSURL, timeInSeconds time:Int64, key:String, sectionKey:String) {
        let generator = AVAssetImageGenerator(asset: AVAsset(URL: url))
        let tVal = NSValue(CMTime: CMTimeMake(time, 1))
        generator.generateCGImagesAsynchronouslyForTimes([tVal], completionHandler: {(_, im:CGImage?, _, _, e:NSError?) in self.finshedCapture(im, key: key, error: e, sectionKey: sectionKey)})
    }
    
    // Save image in dictionary
    func finshedCapture(im:CGImage?, key:String, error:NSError?, sectionKey:String)  {
        if let img = im {
            if(mainDicSingle.count > 0){
                imageDicSingle[key] = img
            }else if(mainDicMulti.count > 0){
                var dict:[String:CGImage] = [String:CGImage]()
                if(imageDicMulti[sectionKey]?.count > 0){
                    dict = imageDicMulti[sectionKey]!
                }
                dict[key] = img
                imageDicMulti[sectionKey] = dict
            }
        }
    }
    
    // MARK: -Populate Collection View Methods -
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(mainDicSingle.count > 0){
            return mainDicSingle.count
        }else if(multiCurrentName != " "){
            return (mainDicMulti[multiCurrentName]?.count)!
        }else{
            return mainDicMulti.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) 
        
        // Create text label
        let lable:UILabel = UILabel()
        lable.textColor = UIColor.whiteColor()
        lable.backgroundColor  = UIColor.clearColor()
        lable.adjustsFontSizeToFitWidth = true
        lable.frame = CGRectMake(cell.contentView.frame.origin.x, cell.contentView.bounds.height - cell.contentView.bounds.height/4, cell.contentView.bounds.width, cell.contentView.bounds.height/4)
        
        // Populate text label name depending on single or multiple section
        var name:String = String()
        if(mainDicSingle.count > 0){
            name = Array(mainDicSingle.keys)[indexPath.row]
        }else if(mainDicMulti.count > 0 && multiCurrentName == " "){
            name = Array(mainDicMulti.keys)[indexPath.row]
        }else if(mainDicMulti.count > 0 ){
            name = Array(mainDicMulti[multiCurrentName]!.keys)[indexPath.row]
        }
        lable.text = name
        
        // Decide what image should be on collection view cell  depending on single or multiple
        var image:UIImage = UIImage(named: "loadingImage.png")!
        if(mainDicSingle.count > 0){
            if ((imageDicSingle[name]) != nil){
                let cgImage:CGImage = imageDicSingle[name]!
                image = UIImage(CGImage: cgImage)
            }

        }else if(imageDicMulti.count > 0 && multiCurrentName != " "){
            var dict:[String:CGImage] = [String:CGImage]()
            if (imageDicMulti[multiCurrentName] != nil){
                dict = imageDicMulti[multiCurrentName]!
            }
            if (dict[name] != nil){
                let cgImage:CGImage = dict[name]!
                image = UIImage(CGImage: cgImage)
            }
        }
        
        // Populate image view 
        let imageView:UIImageView = UIImageView(image: image)
        imageView.frame = cell.contentView.bounds
        cell.contentView.addSubview(imageView)
        imageView.addSubview(lable)
        
        return cell
        
    }
    
    // MARK: - Actions When Collection View Cell Selected -
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         noResult.hidden = true
        if(mainDicMulti.count > 0 && multiCurrentName == " "){
            // Reload collection view data to individual sections
            let name:String = Array(mainDicMulti.keys)[indexPath.row]

            multiCurrentName = name
            videoCollectionView.reloadData()
            backButton.hidden = false
        }else{
            // Set up video player for playing
            videoPlayer.sharedInstance.setMode(Multiple_Rotate)
            videoPlayer.sharedInstance.addObserverForVideo()
            
            // Grab the video path and pass it to the video player
            if(mainDicMulti.count > 0){
                videoPlayer.sharedInstance.videoData = [String](mainDicMulti[multiCurrentName]!.values)
                videoPlayer.sharedInstance.playVideo(Array(mainDicMulti[multiCurrentName]!.values)[indexPath.row], frame: videoPlayerView.frame)
            }else if(mainDicSingle.count > 0){
                videoPlayer.sharedInstance.videoData = [String](mainDicSingle.values)
                videoPlayer.sharedInstance.playVideo(Array(mainDicSingle.values)[indexPath.row], frame: videoPlayerView.frame)
            }
            
            // add video player view
            self.addChildViewController(videoPlayer.sharedInstance)
            self.view.addSubview(videoPlayer.sharedInstance.view)
            videoPlayer.sharedInstance.player?.play()
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [singleRotateButton]
            let inactiveButton:[UIButton] = [multipleRotateButton]
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }
        
    }
    
     // MARK: -Populate Picker View Methods -
    
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
    
    // MARK: - Actions When Picker View Cell Selected -
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // decide which subsection are we in
        let name:String = pickerViewData[row];
        let subDict:[String:String] = mainDicMulti[name]!
        
        // set up video player for playing
        videoPlayer.sharedInstance.setMode(Multiple_Rotate)
        videoPlayer.sharedInstance.addObserverForVideo()
        
        // get the video path and pass it to video player
        videoPlayer.sharedInstance.videoData = [String](subDict.values)
        videoPlayer.sharedInstance.playVideo(subDict[(txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]!, frame: videoPlayerView.frame)
        
        self.addChildViewController(videoPlayer.sharedInstance)
        self.view.addSubview(videoPlayer.sharedInstance.view)
        videoPlayer.sharedInstance.player?.play()

        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = [singleRotateButton]
        let inactiveButton:[UIButton] = [multipleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        
        // remove pickerView after picking
        pickerViewData.removeAll()
        pickerView.reloadComponent(0)
        pickerView.hidden = true
        
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
    
    // MARK: - Buttons Methods -
    
    @IBAction func singeRotate(sender: AnyObject) {
        videoPlayer.sharedInstance.setMode(Single_Rotate)
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = [multipleRotateButton]
        let inactiveButton:[UIButton] = [singleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    @IBAction func multipleRotate(sender: AnyObject) {
        videoPlayer.sharedInstance.setMode(Multiple_Rotate)
        
        // Set Active and Inactive Buttons
        let activeButton:[UIButton] = [singleRotateButton]
        let inactiveButton:[UIButton] = [multipleRotateButton]
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)

    }
    
    @IBAction func clearVideo(sender: AnyObject) {
        videoPlayer.sharedInstance.clear()
        
        let inactiveButton:[UIButton] = [singleRotateButton,multipleRotateButton]
        let activeButton:[UIButton] = []
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    @IBAction func goHome(sender: AnyObject) {
        
        timer.invalidate()
        
        // Do the transiton
        self.performSegueWithIdentifier("videoToMain", sender: self)
        
        // Clear audio player
        videoPlayer.sharedInstance.clear()
        
        // Clear data
        multiCurrentName = " "
        mainDicMulti.removeAll()
        mainDicSingle.removeAll()
        imageDicMulti.removeAll()
        imageDicSingle.removeAll()
        videoCollectionView.reloadData()
        
        // All Buttons Inactive
        let inactiveButton:[UIButton] = [singleRotateButton,multipleRotateButton]
        let activeButton:[UIButton] = []
        self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
    }
    
    @IBAction func backToHomeMenu(sender: AnyObject) {
        noResult.hidden = true
        backButton.hidden = true
        multiCurrentName = " "
        videoCollectionView.reloadData()
    }

    
    // MARK: - Search Video -
    
    @IBAction func searchVideo(sender: AnyObject) {
        var results:[String:AnyObject] = [String:AnyObject]()
        
        if(mainDicSingle.count > 0){
            for (name,path) in mainDicSingle{
                if(name == txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())){
                    results[name] = path
                }
            }

        }else if(mainDicMulti.count > 0){
            for(key,value) in mainDicMulti{
                for(name,path) in value{
                    if(name == txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())){
                        results[key] = [name:path]
                    }
                }
            }
        }
        
        if(results.count == 1){
            // get video path and pass it to the video player
            if(mainDicSingle.count > 0){
                videoPlayer.sharedInstance.videoData = [String](mainDicSingle.values)
                videoPlayer.sharedInstance.playVideo(mainDicSingle[(txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]!, frame: videoPlayerView.frame)
            }else if(mainDicMulti.count > 0){
                let subDict:[String:String] = mainDicMulti[Array(results.keys).first!]!
                videoPlayer.sharedInstance.videoData = [String](subDict.values)
                videoPlayer.sharedInstance.playVideo(subDict[(txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!]!, frame: videoPlayerView.frame)
            }
            
            // set up video player for playing
            videoPlayer.sharedInstance.setMode(Multiple_Rotate)
            videoPlayer.sharedInstance.addObserverForVideo()
            
            // add video player view
            self.addChildViewController(videoPlayer.sharedInstance)
            self.view.addSubview(videoPlayer.sharedInstance.view)
            videoPlayer.sharedInstance.player?.play()
            
            // Set Active and Inactive Buttons
            let activeButton:[UIButton] = [singleRotateButton]
            let inactiveButton:[UIButton] = [multipleRotateButton]
            self.buttonActiveandInactive(activeButton, inactiveButtons: inactiveButton)
        }else if(results.count > 1){
            // Populate picker view and show it
            pickerView.hidden = false
            pickerViewData = [String](results.keys)
            pickerView.reloadComponent(0)
        }else if(results.count == 0){
            // display no result label
            noResult.text = "No Result For " + (txtField.text?.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
            noResult.hidden = false
        }
        txtField.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        videoCollectionView.reloadData()
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