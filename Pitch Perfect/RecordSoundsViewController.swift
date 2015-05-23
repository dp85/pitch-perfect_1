//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by David Patrick on 5/9/15.
//  Copyright (c) 2015 Dave Patrick. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // local variables
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    // outlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    // called each time right before the View is shown
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        resetUI()
    }

    // handles the action for when audio is to be recorded. this happens when
    // a user touches the microphone button
    @IBAction func recordAudio() {
        recordButton.enabled = false
        recordingLabel.text = "Recording in Progress"
        stopButton.hidden = false
        
        // Record user's voice
        // get a directory to save the recording to.
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        // construct a file name based on the current date and time
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.record()
    }
    // handles the action when the user wants to stop recording. this is when
    // the stop button is touched
    @IBAction func stopRecording() {
        audioRecorder.stop()
        var session = AVAudioSession.sharedInstance()
        session.setActive(false, error: nil)
    }
    
    // we registered this class as a delegate for the audioRecorder instance. When the audioRecorder
    // has finished, this method gets invoked.
    // flag will be true if the audio recorded successfully. False if there was an error
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag){
            // If audio was recorded successfully, create a RecordedAudio object with
            // the filepath and title.
            recordedAudio = RecordedAudio(FilePathURL: recorder.url, Title: recorder.url.lastPathComponent)
            // transition to PlaySoundsViewController
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else{
            // Audio did not record successfully. Show error message and reset UI
            
            let errMsg = "Audio did not record successfully"
            let errTitle = "Error"
            let buttonTtile = "Understood"
            // Display error message. According to http://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift , 
            // it's best to use UIAlertController , but this class is not available in iOS 7 & lower.
            // in the case it's not available, we will use a UIAlertController.
            if NSClassFromString("UIAlertController") != nil { // use UIAlertController
                var alert = UIAlertController(title: errTitle, message: errMsg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: buttonTtile, style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
             }
             else {
                let alert = UIAlertView()
                alert.title = errTitle
                alert.message = errMsg
                alert.addButtonWithTitle(buttonTtile)
                alert.show()
            }
            resetUI()
        }
    }
    
    // We override UIViewControllers prepareForSegue method so we can send the recordedAudio
    // object to it that contains the path to the audio that was recorded by this view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    // Reset the UI. Hide the stop button, enable record and set the recording label.
    func resetUI(){
        //Hide the stop button, enable record
        stopButton.hidden = true
        recordButton.enabled = true
        recordingLabel.text = "Tap to Record"
    }
}

