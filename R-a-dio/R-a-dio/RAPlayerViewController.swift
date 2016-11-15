//
//  RAPlayerViewController.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-27.
//

import Cocoa
import AVKit
import AVFoundation
import Alamofire

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
    @IBAction func volumeSliderChanged(_ sender: NSSlider) {
        // Change the volume
        radioPlayer?.volume = sender.floatValue;
        
        // Update the preferences volume
        (NSApplication.shared().delegate as! AppDelegate).preferences.volume = sender.floatValue;
    }
    
    /// The label that shows the title of the current song
    @IBOutlet var songTitleTextField: NSTextField!
    
    /// When the user presses the last played button...
    @IBAction func lastPlayedButtonPressed(_ sender: NSButton) {
        /// The menu that will show the last played songs
        let lastPlayedMenu : NSMenu = NSMenu();
        
        // Add the "Last Played" header item
        lastPlayedMenu.addItem(withTitle: "Last Played", action: nil, keyEquivalent: "");
        
        // Add a separator
        lastPlayedMenu.addItem(NSMenuItem.separator());
        
        // For every song in the last played songs in currentRadioInfo...
        for(_, currentLastPlayedSong) in currentRadioInfo.lastPlayed.enumerated() {
            // Add an item with the current song's title with how long ago it played to lastPlayedMenu
            lastPlayedMenu.addItem(withTitle: "\(currentLastPlayedSong.name) - \(currentLastPlayedSong.startTimeFromNow) ago", action: nil, keyEquivalent: "");
        }
        
        // Show the last played menu at the last played button's position
        lastPlayedMenu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: sender);
    }
    
    /// When the user presses the queue button...
    @IBAction func queueButtonPressed(_ sender: NSButton) {
        /// The menu that will show the queued songs
        let queueMenu : NSMenu = NSMenu();
        
        // Add the "Queue" header item
        queueMenu.addItem(withTitle: "Queue", action: nil, keyEquivalent: "");
        
        // Add a separator
        queueMenu.addItem(NSMenuItem.separator());
        
        // For every song in the queued songs in currentRadioInfo...
        for(_, currentQueuedSong) in currentRadioInfo.queue.enumerated() {
            // Add an item with the current song's title with it's start time to queueMenu
            queueMenu.addItem(withTitle: "\(currentQueuedSong.name) - in \(currentQueuedSong.startTimeFromNow)", action: nil, keyEquivalent: "");
        }
        
        // Show the queued songs menu at the queued songs button's position
        queueMenu.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: sender);
    }
    
    /// The button for favouriting/unfavouriting the current playing song
    @IBOutlet var favouriteButton: NSButton!
    
    /// When favouriteButton is pressed...
    @IBAction func favouriteButtonPressed(_ sender: NSButton) {
        // Toggle the state
        favouriteButton.state = Int.fromBool(bool: !Bool(favouriteButton.state as NSNumber));
        
        // If the favourited button is now on...
        if(Bool(favouriteButton.state as NSNumber)) {
            // Favourite the current playing song
            favouriteCurrentSong();
        }
        // If the favourited button is now off...
        else {
            // Unfavourite the current playing song
            unfavouriteCurrentSong();
        }
        
        // Update the favourite button
        updateFavouriteButton();
    }
    
    /// Updates favouriteButton to match it's state
    func updateFavouriteButton() {
        // If the favourite button's state is on...
        if(favouriteButton.state == NSOnState) {
            // Set the image
            favouriteButton.image = NSImage(named: "RAFavouritedIcon")!;
        }
        // If the favourite button's state is off...
        else if(favouriteButton.state == NSOffState) {
            // Set the image
            favouriteButton.image = NSImage(named: "RANotFavouritedIcon")!;
        }
    }
    
    /// Updates favouriteButton to match if the current playing song is favourited
    func updateFavouriteButtonState() {
        // Display if the song is favourited
        /// The current song as an RASearchSong
        let currentSongAsSearchSong : RASearchSong = RASearchSong();
        
        // Set currentSongAsSearchSong's ID to the current song's ID
        currentSongAsSearchSong.id = currentRadioInfo.currentSong.id;
        
        // Update the favourited button to match
        favouriteButton.state = Int.fromBool(bool: (NSApplication.shared().delegate as! AppDelegate).preferences.songIsFavourited(currentSongAsSearchSong));
        updateFavouriteButton();
    }
    
    /// The button that the user can press to request a song to be played on r/a/dio
    @IBOutlet var requestButton: NSButton!
    
    /// The pause/play button
    @IBOutlet var pausePlayButton: NSButton!
    
    /// When the user presses pausePlayButton...
    @IBAction func pausePlayButtonPressed(_ sender: NSButton) {
        // If the r/a/dio is stopped...
        if(radioStopped) {
            // Start the r/a/dio
            playRadio();
                
            // Update pausePlayButton
            pausePlayButton.image = NSImage(named: "RAPauseIcon");
        }
        // If the r/a/dio isn't stopped...
        else {
            // If the r/a/dio player is playing...
            if(!radioPlayer!.isMuted) {
                // "Pause" it(Mute it)
                radioPlayer!.isMuted = true;
                
                // Update pausePlayButton
                pausePlayButton.image = NSImage(named: "RAPlayIcon");
            }
            // If the r/a/dio player is paused...
            else {
                // "Play" it(Un-mute it)
                radioPlayer!.isMuted = false;
                
                // Update pausePlayButton
                pausePlayButton.image = NSImage(named: "RAPauseIcon");
            }
        }
    }
    
    /// The stop button
    @IBOutlet weak var stopButton: NSButton!
    
    /// When the user presses stopButton...
    @IBAction func stopButtonPressed(_ sender: NSButton) {
        // Stop the r/a/dio
        stopRadio();
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
    var currentTheme : RATheme = .light;
    
    /// The last retrieved RARadioInfo
    var currentRadioInfo : RARadioInfo = RARadioInfo();
    
    /// The last DJ from currentRadioInfo
    var lastDj : RADJ = RADJ();
    
    /// The AVPlayer for playing the r/a/dio stream
    var radioPlayer : AVPlayer? = nil;
    
    /// The position of the current song, in seconds
    var currentSongPositionSeconds : Int = 0;
    
    /// Is the r/a/dio stopped?
    var radioStopped : Bool = true;
    
    /// The display string for currentSongPositionSeconds, in the format "MM:SS"
    var currentSongPositionSecondsString : String {
        /// The date from currentSongPositionSeconds
        let currentSongPositionSecondsDate : Date = Date(timeIntervalSince1970: TimeInterval(currentSongPositionSeconds));
        
        /// The date components of currentSongPositionSecondsDate
        let currentSongPositionSecondsDateComponents : DateComponents = (Calendar.current as NSCalendar).components([.minute, .second], from: currentSongPositionSecondsDate);
        
        /// The display string for the seconds value
        var secondsString : String = String(describing: currentSongPositionSecondsDateComponents.second!);
        
        // If there is only one character in secondsString...
        if(secondsString.characters.count == 1) {
            // Append a 0 to the front
            secondsString = "0\(secondsString)";
        }
        
        // Return the position string
        return "\(currentSongPositionSecondsDateComponents.minute!):\(secondsString)";
    }
    
    override func rightMouseDown(with theEvent: NSEvent) {
        super.rightMouseDown(with: theEvent);
        
        /// The context menu to show
        let menu : NSMenu = NSMenu();
        
        /// The song request menu item
        let songRequestMenuItem : NSMenuItem = NSMenuItem(title: "Request A Song", action: requestButton.action, keyEquivalent: "r");
        
        // Enable/disable songRequestMenuItem based on if requests are enabled
        menu.autoenablesItems = false;
        songRequestMenuItem.isEnabled = currentRadioInfo.requestingEnabled;
        
        // Set the song request menu item's target
        songRequestMenuItem.target = requestButton.target;
        
        // Add the song request menu item
        menu.addItem(songRequestMenuItem);
        
        // Add a separator
        menu.addItem(NSMenuItem.separator());
        
        // Add the quit menu item
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(RAPlayerViewController.quit), keyEquivalent: "q"));
        
        // Show the context menu
        NSMenu.popUpContextMenu(menu, with: theEvent, for: self.backgroundVisualEffectView);
    }
    
    /// Called when the user right clicks and selects "Quit", quits the application
    func quit() {
        NSApplication.shared().terminate(nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Load the preferences
        (NSApplication.shared().delegate as! AppDelegate).loadPreferences();
        
        // Allow the DJ image view to animate
        currentDjImageView.canDrawSubviewsIntoLayer = true;
        
        // Re-apply the theme
        reapplyTheme();
        
        // Do the initial radio info reload
        reloadRadioInfo();
        
        // Start the updatePositionDurationProgressViews timer
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(RAPlayerViewController.updatePositionDurationProgressViews), userInfo: nil, repeats: true);
        
        // Start the reload timer
        Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RAPlayerViewController.reloadRadioInfoLoop), userInfo: nil, repeats: true);
        
        // Load the previously set volume into the volume slider
        volumeSlider.floatValue = (NSApplication.shared().delegate as! AppDelegate).preferences.volume;
        
        // Start the r/a/dio
        playRadio();
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // If the key path is the one for the the r/a/dio player status...
        if(keyPath! == "status") {
            // If the r/a/dio player is ready to play...
            if(radioPlayer!.status == AVPlayerStatus.readyToPlay) {
                // Start playing the r/a/dio player
                radioPlayer!.play();
                
                // Hide and stop the loading spinner
                loadingSpinner.isHidden = true;
                loadingSpinner.stopAnimation(self);
                
                // Show and enable the pause/play button
                pausePlayButton.isHidden = false;
                pausePlayButton.isEnabled = true;
                
                // Show and enable the stop button
                stopButton.isHidden = false;
                stopButton.isEnabled = true;
            }
            // If the r/a/dio player failed...
            else if(radioPlayer!.status == AVPlayerStatus.failed) {
                // Print that the r/a/dio player failed to load
                print("RAPlayerViewController: Failed to load r/a/dio player");
            }
        }
    }
    
    /// Starts playing the r/a/dio
    func playRadio() {
        // Print that we are starting the r/a/dio
        print("RAPlayerViewController: Starting the r/a/dio");
        
        // Say that the r/a/dio isn't stopped
        radioStopped = false;
        
        // Update the stop button
        stopButton.isEnabled = true;
        
        // Show the loading spinner
        loadingSpinner.isHidden = false;
        
        // Hide and disable the pause/play button
        pausePlayButton.isHidden = true;
        pausePlayButton.isEnabled = false;
        
        // Hide and disable the stop button
        stopButton.isHidden = true;
        stopButton.isEnabled = false;
        
        // Create radioPlayer
        radioPlayer = AVPlayer(url: URL(string: "https://stream.r-a-d.io/main.mp3")!);
        
        // Observe radioPlayer's status so we can play it when it loads
        radioPlayer!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil);
        
        // Start the loading spinner
        loadingSpinner.startAnimation(self);
        
        // Do the initial volume update
        radioPlayer!.volume = volumeSlider.floatValue;
    }
    
    /// Stops playing the r/a/dio
    func stopRadio() {
        // Print that we are stopping the r/a/dio
        print("RAPlayerViewController: Stopping the r/a/dio");
        
        // Say the r/a/dio is stopped
        radioStopped = true;
        
        // Show and enable the pause/play button
        pausePlayButton.isHidden = false;
        pausePlayButton.isEnabled = true;
        
        // Show and disable the stop button
        stopButton.isHidden = false;
        stopButton.isEnabled = false;
        
        // Update pausePlayButton
        pausePlayButton.image = NSImage(named: "RAPlayIcon");
        
        // Remove the r/a/dio player observer
        radioPlayer!.removeObserver(self, forKeyPath: "status");
        
        // Destroy the r/a/dio player
        radioPlayer = nil;
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
        print("RAPlayerViewController: Downloading r/a/dio info");
        
        // Download the info and display it
        RARadioUtilities().getCurrentData(displayRadioInfo);
    }
    
    /// Displays the data from the given RARadioInfo
    func displayRadioInfo(_ radioInfo : RARadioInfo) {
        // Print what we are displaying
        print("RAPlayerViewController: Displaying r/a/dio info");
        
        // Set currentRadioInfo
        currentRadioInfo = radioInfo;
        
        // Display the radio info
        // Set the title label to the current song's name
        songTitleTextField.stringValue = radioInfo.currentSong.name;
        
        // Display if the song is favourited
        updateFavouriteButtonState();
        
        // Enable/disable the request button
        requestButton.isEnabled = radioInfo.requestingEnabled;
        
        // Set currentSongPositionSeconds
        currentSongPositionSeconds = Int(radioInfo.currentSongPosition.timeIntervalSince1970);
        
        // If the DJ is different...
        if(lastDj.name != currentRadioInfo.currentDj.name) {
            // Download the new DJ artwork
            currentDjImageView.downloadImageFromURL(radioInfo.currentDj.artUrl, placeHolderImage: hanyuu);
        }
        
        // Set the DJ artwork image view's tooltip
        currentDjImageView.toolTip = "\(radioInfo.currentDj.name), \(radioInfo.listeners) listeners";
        
        // Set lastDj
        lastDj = currentRadioInfo.currentDj;
    }
    
    /// Favourites the current playing song
    func favouriteCurrentSong() {
        Alamofire.request("https://r-a-d.io/api/search/\(currentRadioInfo.currentSong.id)").responseJSON { (responseData) -> Void in
            /// The string of JSON that will be returned when the GET request finishes
            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: String.Encoding.utf8.rawValue)!;
            
            // If the the response data isnt nil...
            if let dataFromResponseJsonString = responseJsonString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) {
                /// The JSON from the response string
                let responseJson = JSON(data: dataFromResponseJsonString);
                
                /// The RASearchSong from the returned JSON
                let returnedSong : RASearchSong = RASearchSong(json: responseJson["data"][0]);
                
                // Add returnedSong to the favourites
                (NSApplication.shared().delegate as! AppDelegate).preferences.addSongToFavourites(returnedSong);
                
                // Update the favourites button state and image
                self.favouriteButton.state = NSOnState;
                self.updateFavouriteButton();
            }
        }
    }
    
    /// Unfavourites the current playing song
    func unfavouriteCurrentSong() {
        // Unfavourite the current song
        /// The current song as an RASearchSong
        let currentSongAsSearchSong : RASearchSong = RASearchSong();
        
        // Set currentSongAsSearchSong's ID to the current song's ID
        currentSongAsSearchSong.id = currentRadioInfo.currentSong.id;
        
        // Remove currentSongAsSearchSong from the favourites
        (NSApplication.shared().delegate as! AppDelegate).preferences.removeSongFromFavourites(currentSongAsSearchSong);
        
        // Update the favourites button state and image
        favouriteButton.state = NSOffState;
        updateFavouriteButton();
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
        if(currentTheme == .dark) {
            // Style the visual effect views
            backgroundVisualEffectView.material = .dark;
            volumeBarVisualEffectView.material = .titlebar;
            
            backgroundVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
            volumeBarVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
        }
        // If the theme is light...
        else if(currentTheme == .light) {
            // Style the visual effect views
            if #available(OSX 10.11, *) {
                backgroundVisualEffectView.material = .mediumLight
            } else {
                backgroundVisualEffectView.material = .light;
            };
            
            volumeBarVisualEffectView.material = .light;
            
            backgroundVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
            volumeBarVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
        }
    }
}

/// The different themes the application can have
enum RATheme {
    /// The dark theme
    case dark
    
    /// The light theme
    case light
}
