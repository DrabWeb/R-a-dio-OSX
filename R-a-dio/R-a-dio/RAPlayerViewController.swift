//
//  RAPlayerViewController.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-27.
//

import Cocoa
import AVKit
import AVFoundation

class RAPlayerViewController: NSViewController, NSWindowDelegate {
    
    /// The main window of this view controller
    var window : NSWindow = NSWindow();
    
    /// The default DJ image
    var hanyuu : NSImage = NSImage(named: "Hanyuu")!;
    
    /// The visual effect view for the background of the window
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The visual effect view that holds the volume slider
    @IBOutlet var volumeBarVisualEffectView: NSVisualEffectView!
    
    /// The volume slider in volumeBarVisualEffectView
    @IBOutlet weak var volumeSlider: NSSlider!
    
    /// When the user changes volumeSlider's value...
    @IBAction func volumeSliderChanged(sender: NSSlider) {
        // Change the volume
        radioPlayer?.volume = sender.floatValue;
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
    
    override func rightMouseDown(theEvent: NSEvent) {
        super.rightMouseDown(theEvent);
        
        /// The context menu to show
        let menu : NSMenu = NSMenu();
        
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
        songTitleTextField.stringValue = radioInfo.currentSong.name;
        
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
    
    /// Updates the position/duration labels and the playing progress bar. Called once every half second
    func updatePositionDurationProgressViews() {
        // Update the position/duration labels
        currentSongPositionLabel.stringValue = currentRadioInfo.currentSong.positionString;
        currentSongDurationLabel.stringValue = currentRadioInfo.currentSong.durationString;
        
        // Update the progress bar
        currentSongProgressProgressBar.doubleValue = Double((Float(currentRadioInfo.currentSong.positionSeconds) / Float(currentRadioInfo.currentSong.durationSeconds)) * 100);
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
    
    func windowWillEnterFullScreen(notification: NSNotification) {
        // Set the window's appearance to match the background visual effect view
        window.appearance = backgroundVisualEffectView.appearance;
    }
    
    func windowDidExitFullScreen(notification: NSNotification) {
        // Set back the window's appearance
        window.appearance = NSAppearance(named: NSAppearanceNameAqua);
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        window = NSApplication.sharedApplication().windows.last!;
        
        // Set the window's delegate
        window.delegate = self;
        
        // Style the window's titlebar
        window.titleVisibility = .Hidden;
        window.styleMask |= NSFullSizeContentViewWindowMask;
        window.titlebarAppearsTransparent = true;
    }
}

/// The different themes the application can have
enum RATheme {
    /// The dark theme
    case Dark
    
    /// The light theme
    case Light
}