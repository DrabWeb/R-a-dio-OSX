//
//  RAPlayerViewController.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-27.
//

import Cocoa
import AVKit
import AVFoundation

class RAPlayerViewController: NSViewController {
    
    /// The default DJ image
    var hanyuu : NSImage = NSImage(named: "Hanyuu")!;
    
    /// The visual effect view for the background of the window
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The visual effect view that holds the volume slider
    @IBOutlet var volumeBarVisualEffectView: NSVisualEffectView!
    
    /// The spinner that shows that the r/a/dio stream is loading
    @IBOutlet var loadingSpinner: NSProgressIndicator!
    
    /// The volume slider in volumeBarVisualEffectView
    @IBOutlet weak var volumeSlider: NSSlider!
    
    /// When the user changes volumeSlider's value...
    @IBAction func volumeSliderChanged(sender: NSSlider) {
        // Change the volume
        radioPlayer?.volume = sender.floatValue;
        
        // Update the preferences volume
        (NSApplication.sharedApplication().delegate as! AppDelegate).preferences.volume = sender.floatValue;
    }
    
    /// The label that shows the title of the current song
    @IBOutlet var songTitleTextField: NSTextField!
    
    /// When the user presses the last played button...
    @IBAction func lastPlayedButtonPressed(sender: NSButton) {
        /// The menu that will show the last played songs
        let lastPlayedMenu : NSMenu = NSMenu();
        
        // Add the "Last Played" header item
        lastPlayedMenu.addItemWithTitle("Last Played", action: Selector(""), keyEquivalent: "");
        
        // Add a separator
        lastPlayedMenu.addItem(NSMenuItem.separatorItem());
        
        // For every song in the last played songs in currentRadioInfo...
        for(_, currentLastPlayedSong) in currentRadioInfo.lastPlayed.enumerate() {
            // Add an item with the current song's title with how long ago it played to lastPlayedMenu
            lastPlayedMenu.addItemWithTitle("\(currentLastPlayedSong.name) - \(currentLastPlayedSong.startTimeFromNow) ago", action: Selector(""), keyEquivalent: "");
        }
        
        // Show the last played menu at the last played button's position
        lastPlayedMenu.popUpMenuPositioningItem(nil, atLocation: NSPoint(x: 0, y: 0), inView: sender);
    }
    
    /// When the user presses the queue button...
    @IBAction func queueButtonPressed(sender: NSButton) {
        /// The menu that will show the queued songs
        let queueMenu : NSMenu = NSMenu();
        
        // Add the "Queue" header item
        queueMenu.addItemWithTitle("Queue", action: Selector(""), keyEquivalent: "");
        
        // Add a separator
        queueMenu.addItem(NSMenuItem.separatorItem());
        
        // For every song in the queued songs in currentRadioInfo...
        for(_, currentQueuedSong) in currentRadioInfo.queue.enumerate() {
            // Add an item with the current song's title with it's start time to queueMenu
            queueMenu.addItemWithTitle("\(currentQueuedSong.name) - in \(currentQueuedSong.startTimeFromNow)", action: Selector(""), keyEquivalent: "");
        }
        
        // Show the queued songs menu at the queued songs button's position
        queueMenu.popUpMenuPositioningItem(nil, atLocation: NSPoint(x: 0, y: 0), inView: sender);
    }
    
    /// The button that the user can press to request a song to be played on r/a/dio
    @IBOutlet var requestButton: NSButton!
    
    /// The pause/play button
    @IBOutlet var pausePlayButton: NSButton!
    
    /// When the user presses pausePlayButton...
    @IBAction func pausePlayButtonPressed(sender: NSButton) {
        // If the r/a/dio player is playing...
        if(!radioPlayer!.muted) {
            // "Pause" it(Mute it)
            radioPlayer!.muted = true;
            
            // Update pausePlayButton
            pausePlayButton.image = NSImage(named: "RAPlayIcon");
        }
        // If the r/a/dio player is paused...
        else {
            // "Play" it(Un-mute it)
            radioPlayer!.muted = false;
            
            // Update pausePlayButton
            pausePlayButton.image = NSImage(named: "RAPauseIcon");
        }
    }
    
    /// The label that shows the position of the current song
    @IBOutlet var currentSongPositionLabel: NSTextField!
    
    /// The label that shows the duration of the current song
    @IBOutlet var currentSongDurationLabel: NSTextField!
    
    /// The progress bar that visually indicates how far into the song we are
    @IBOutlet var currentSongProgressProgressBar: NSProgressIndicator!
    
    /// The image view that shows the artwork for the current DJ
    @IBOutlet var currentDjImageView: DKAsyncImageView!
    
    /// The current theme for this player
    var currentTheme : RATheme = .Light;
    
    /// The last retrieved RARadioInfo
    var currentRadioInfo : RARadioInfo = RARadioInfo();
    
    /// The last DJ from currentRadioInfo
    var lastDj : RADJ = RADJ();
    
    /// The AVPlayer for playing the r/a/dio stream
    var radioPlayer : AVPlayer? = nil;
    
    /// The position of the current song, in seconds
    var currentSongPositionSeconds : Int = 0;
    
    /// The display string for currentSongPositionSeconds, in the format "MM:SS"
    var currentSongPositionSecondsString : String {
        /// The date from currentSongPositionSeconds
        let currentSongPositionSecondsDate : NSDate = NSDate(timeIntervalSince1970: NSTimeInterval(currentSongPositionSeconds));
        
        /// The date components of currentSongPositionSecondsDate
        let currentSongPositionSecondsDateComponents : NSDateComponents = NSCalendar.currentCalendar().components([.Minute, .Second], fromDate: currentSongPositionSecondsDate);
        
        /// The display string for the seconds value
        var secondsString : String = String(currentSongPositionSecondsDateComponents.second);
        
        // If there is only one character in secondsString...
        if(secondsString.characters.count == 1) {
            // Append a 0 to the front
            secondsString = "0\(secondsString)";
        }
        
        // Return the position string
        return "\(currentSongPositionSecondsDateComponents.minute):\(secondsString)";
    }
    
    override func rightMouseDown(theEvent: NSEvent) {
        super.rightMouseDown(theEvent);
        
        /// The context menu to show
        let menu : NSMenu = NSMenu();
        
        /// The song request menu item
        let songRequestMenuItem : NSMenuItem = NSMenuItem(title: "Request A Song", action: requestButton.action, keyEquivalent: "r");
        
        // Set the song request menu item's target
        songRequestMenuItem.target = requestButton.target;
        
        // Add the request song menu item
        menu.addItem(songRequestMenuItem);
        
        // Add the quit menu item
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("quit"), keyEquivalent: "q"));
        
        // Show the context menu
        NSMenu.popUpContextMenu(menu, withEvent: theEvent, forView: self.backgroundVisualEffectView);
    }
    
    /// Called when the user right clicks and selects "Quit", quits the application
    func quit() {
        NSApplication.sharedApplication().terminate(nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Load the preferences
        (NSApplication.sharedApplication().delegate as! AppDelegate).loadPreferences();
        
        // Style the window
        styleWindow();
        
        // Re-apply the theme
        reapplyTheme();
        
        // Do the initial radio info reload
        reloadRadioInfo();
        
        // Start the updatePositionDurationProgressViews timer
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: Selector("updatePositionDurationProgressViews"), userInfo: nil, repeats: true);
        
        // Start the reload timer
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(10), target: self, selector: Selector("reloadRadioInfoLoop"), userInfo: nil, repeats: true);
        
        // Create radioPlayer
        radioPlayer = AVPlayer(URL: NSURL(string: "https://stream.r-a-d.io/main.mp3")!);
        
        // Observe radioPlayer's status so we can play it when it loads
        radioPlayer!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil);
        
        // Start the loading spinner
        loadingSpinner.startAnimation(self);
        
        // Load the previously set volume into the volume slider
        volumeSlider.floatValue = (NSApplication.sharedApplication().delegate as! AppDelegate).preferences.volume;
        
        // Do the initial volume update
        radioPlayer!.volume = volumeSlider.floatValue;
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // If the key path is the one for the the r/a/dio player status...
        if(keyPath! == "status") {
            // If the r/a/dio player is ready to play...
            if(radioPlayer!.status == AVPlayerStatus.ReadyToPlay) {
                // Start playing the r/a/dio player
                radioPlayer!.play();
                
                // Hide and stop the loading spinner
                loadingSpinner.hidden = true;
                loadingSpinner.stopAnimation(self);
                
                // Show and enable the pause/play button
                pausePlayButton.hidden = false;
                pausePlayButton.enabled = true;
            }
            // If the r/a/dio player failed...
            else if(radioPlayer!.status == AVPlayerStatus.Failed) {
                // Print that the r/a/dio player failed to load
                print("RAPlayerViewController: Failed to load r/a/dio player");
            }
        }
    }
    
    /// The 5 second loop that calls reloadRadioInfo, but only when this view controller is open
    func reloadRadioInfoLoop() {
        // If this view controller is open...
        if(self.view.window != nil) {
            // Reload the radio info
            reloadRadioInfo();
        }
    }
    
    /// Downloads the radio info from r/a/dio and displays it
    func reloadRadioInfo() {
        // Print that we are downloading the radio info
        print("RAPlayerViewController: Downloading radio info");
        
        // Download the info and display it
        RARadioUtilities().getCurrentData(displayRadioInfo);
    }
    
    /// Displays the data from the given RARadioInfo
    func displayRadioInfo(radioInfo : RARadioInfo) {
        // Print what we are displaying
        print("RAPlayerViewController: Displaying radio info");
        
        // Set currentRadioInfo
        currentRadioInfo = radioInfo;
        
        // Display the radio info
        // Set the title label to the current song's name
        songTitleTextField.stringValue = radioInfo.currentSong.name;
        
        // Set currentSongPositionSeconds
        currentSongPositionSeconds = Int(radioInfo.currentSongPosition.timeIntervalSince1970);
        
        // If the DJ is different...
        if(lastDj.name != currentRadioInfo.currentDj.name) {
            // Download the new DJ artwork
            currentDjImageView.downloadImageFromURL(radioInfo.currentDj.artUrl, placeHolderImage: hanyuu);
        }
        
        // Set the DJ artwork image view's tooltip
        currentDjImageView.toolTip = "\(radioInfo.currentDj.name)\n\(radioInfo.listeners) listeners";
        
        // Set lastDj
        lastDj = currentRadioInfo.currentDj;
    }
    
    /// Updates the position/duration labels and the playing progress bar. Called every second
    func updatePositionDurationProgressViews() {
        // Add one second to currentSongPositionSeconds
        currentSongPositionSeconds += 1;
        
        // Update the position/duration labels
        currentSongPositionLabel.stringValue = currentSongPositionSecondsString;
        currentSongDurationLabel.stringValue = currentRadioInfo.currentSong.durationString;
        
        // Update the progress bar
        currentSongProgressProgressBar.doubleValue = Double((Float(currentSongPositionSeconds) / Float(currentRadioInfo.currentSong.durationSeconds)) * 100);
        
        // If this view controller is open...
        if(self.view.window != nil) {
            /// If we are at the end of the song...
            if(currentSongPositionSeconds == (currentRadioInfo.currentSong.durationSeconds + 1)) {
                // If the duration is more than 0(Meaning its loaded)...
                if(currentRadioInfo.currentSong.durationSeconds > 0) {
                    // Reload the r/a/dio info
                    reloadRadioInfo();
                }
            }
        }
    }
    
    /// Re-applies currentTheme
    func reapplyTheme() {
        // If the theme is dark...
        if(currentTheme == .Dark) {
            // Style the visual effect views
            backgroundVisualEffectView.material = .Dark;
            volumeBarVisualEffectView.material = .Titlebar;
            
            backgroundVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
            volumeBarVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
        }
        // If the theme is light...
        else if(currentTheme == .Light) {
            // Style the visual effect views
            if #available(OSX 10.11, *) {
                backgroundVisualEffectView.material = .MediumLight
            } else {
                backgroundVisualEffectView.material = .Light;
            };
            
            volumeBarVisualEffectView.material = .Light;
            
            backgroundVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
            volumeBarVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
        }
    }
    
    /// Styles the window
    func styleWindow() {
        // Hide and disable the pause/play button
        pausePlayButton.hidden = true;
        pausePlayButton.enabled = false;
    }
}

/// The different themes the application can have
enum RATheme {
    /// The dark theme
    case Dark
    
    /// The light theme
    case Light
}