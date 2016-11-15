//
//  RARequestViewController.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-28.
//

import Cocoa
import Alamofire

// https://r-a-d.io/api/search/SEARCH%20STRING
// https://r-a-d.io/api/can-request/ID
// https://r-a-d.io/request/ID (POST)

/// The view controller for searching for songs and requesting them on r/a/dio
class RARequestViewController: NSViewController {
    
    /// The main window of this view controller
    var window : NSWindow = NSWindow();
    
    /// The visual effect view for the background of the window
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The text field at the top of the view that lets the user search for songs
    @IBOutlet var searchField: NSTextField!
    
    /// When the user enters text into searchField...
    @IBAction func searchFieldTextEntered(_ sender : NSTextField) {
        // Search for the entered text
        searchFor(sender.stringValue);
    }
    
    /// The table view that shows a list of songs, usually from search results
    @IBOutlet var songsTableView: NSTableView!
    
    /// The items in songsTableView
    var songsTableViewItems : [RASearchSong] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Display all the user's favourites
        displayFavourites();
    }
    
    /// The last request made for getting search results
    var lastSearchRequest : Request? = nil;
    
    /// Searches for the given query on r/a/dio and puts the results in songsTableView
    func searchFor(_ query : String) {
        // Cancel the last search request
        lastSearchRequest?.cancel();
        
        // Clear songsTableViewItems
        songsTableViewItems.removeAll();
        
        // If the search query isnt blank...
        if(query != "") {
            print("RARequestViewController: Searching for \(query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed))");
            // Make the search request
            lastSearchRequest = Alamofire.request("https://r-a-d.io/api/search/\(query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)").responseJSON { (responseData) -> Void in
                /// The string of JSON that will be returned when the GET request finishes
                let responseJsonString : NSString = NSString(data: responseData.data!, encoding: String.Encoding.utf8.rawValue)!;
                
                // If the the response data isnt nil...
                if let dataFromResponseJsonString = responseJsonString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) {
                    /// The JSON from the response string
                    let responseJson = JSON(data: dataFromResponseJsonString);
                    
                    // For every song in "data" in responseJson...
                    for(_, currentSongJson) in responseJson["data"].enumerated() {
                        /// The new song to add to songsTableViewItems
                        let newSearchSong : RASearchSong = RASearchSong(json: currentSongJson.1);
                        
                        // Set if the song is favourited
                        newSearchSong.favourited = (NSApplication.shared().delegate as! AppDelegate).preferences.songIsFavourited(newSearchSong);
                        
                        // Add the current song to songsTableViewItems
                        self.songsTableViewItems.append(newSearchSong);
                    }
                    
                    /// songsTableViewItems sorted so favourites are on top
                    var sortedSongsTableViewItems : [RASearchSong] = [];
                    
                    // For every song in songsTableViewItems...
                    for(_, currentSong) in self.songsTableViewItems.enumerated() {
                        // If the current song is favourited...
                        if(currentSong.favourited) {
                            // Insert the current song at the beginning of sortedSongsTableViewItems
                            sortedSongsTableViewItems.insert(currentSong, at: 0);
                        }
                            // If the current song isnt favourited...
                        else {
                            // Append the current song to the end of sortedSongsTableViewItems
                            sortedSongsTableViewItems.append(currentSong);
                        }
                    }
                    
                    // Set songsTableViewItems to sortedSongsTableViewItems
                    self.songsTableViewItems = sortedSongsTableViewItems;
                    
                    // Reload the songs table view
                    self.songsTableView.reloadData();
                }
            }
        }
        // If the search query is blank...
        else {
            // Display all the user's favourites
            displayFavourites();
        }
    }
    
    /// Displays all the user's favourites in songsTableView
    func displayFavourites() {
        // Print that we are displaying favourites
        print("RARequestViewController: Displaying favourites");
        
        // Set songsTableViewItems to favouriteSongs
        self.songsTableViewItems = (NSApplication.shared().delegate as! AppDelegate).preferences.favouriteSongs;
        
        // Reload songsTableView
        songsTableView.reloadData();
    }
    
    /// Called when the user presses the favourite button in a row in songsTableView
    func songsTableViewItemFavouriteButtonPressed(_ pressedSong : RASearchSong) {
        // If the song is now favourited...
        if(pressedSong.favourited) {
            // Add the pressed song to favourites
            (NSApplication.shared().delegate as! AppDelegate).preferences.addSongToFavourites(pressedSong);
        }
        // If the song is now unfavourited...
        else {
            // Remove the pressed song from favourites
            (NSApplication.shared().delegate as! AppDelegate).preferences.removeSongFromFavourites(pressedSong);
        }
    }
    
    /// Called when the user presses the request button in a row in songsTableView
    func songsTableViewItemRequestButtonPressed(_ pressedSong : RASearchSong) {
        // Print what song we are requesting
        print("RARequestViewController: Requesting to play \(pressedSong.artist) - \(pressedSong.title)(\(pressedSong.id))");
        
        // Request the given song
        Alamofire.request("https://r-a-d.io/api/request/\(pressedSong.id)", method: .post).responseJSON { (responseData) -> Void in
            /// The string of JSON that will be returned when the GET request finishes
            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: String.Encoding.utf8.rawValue)!;
            
            // If the the response data isnt nil...
            if let dataFromResponseJsonString = responseJsonString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) {
                /// The JSON from the response string
                let responseJson = JSON(data: dataFromResponseJsonString);
                
                // If the request was successful...
                if(responseJson["success"].exists()) {
                    // Print that the song request was successful
                    print("RARequestViewController: Song request was successful, \(responseJson["success"].stringValue)");
                    
                    // Send a notification with the returned success message
                    /// The notification to display the success message
                    let successNotification : NSUserNotification = NSUserNotification();
                    
                    // Setup the success notification
                    successNotification.title = "\(pressedSong.artist) - \(pressedSong.title)";
                    successNotification.informativeText = responseJson["success"].stringValue;
                    
                    // Display the success notification
                    NSUserNotificationCenter.default.deliver(successNotification);
                }
                // If the request was unsuccessful...
                else if(responseJson["error"].exists()) {
                    // Print that the song request was unsuccessful
                    print("RARequestViewController: Song request was unsuccessful, \(responseJson["error"].stringValue)");
                    
                    // Send a notification with the returned error message
                    /// The notification to display the error message
                    let errorNotification : NSUserNotification = NSUserNotification();
                    
                    // Setup the error notification
                    errorNotification.title = "\(pressedSong.artist) - \(pressedSong.title)";
                    errorNotification.informativeText = responseJson["error"].stringValue;
                    
                    // Display the error notification
                    NSUserNotificationCenter.default.deliver(errorNotification);
                }
            }
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // Center the window
        window.center();
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        // Hide the toolbar
        window.toolbar?.isVisible = false;
        
        // Set the window's appearance to vibrant dark so the fullscreen toolbar is dark
        window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        // Show the toolbar
        window.toolbar?.isVisible = true;
        
        // Set back the window's appearance
        window.appearance = NSAppearance(named: NSAppearanceNameAqua);
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        window = NSApplication.shared().windows.last!;
        
        // Style the visual effect views
        switch((NSApplication.shared().delegate as! AppDelegate).applicationTheme) {
            case .dark:
                backgroundVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
                backgroundVisualEffectView.material = .dark;
                break;
            case .light:
                backgroundVisualEffectView.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
                if #available(OSX 10.11, *) {
                    backgroundVisualEffectView.material = .mediumLight
                } else {
                    backgroundVisualEffectView.material = .light;
                };
                break;
        }
        
        // Style the window's titlebar
        window.titleVisibility = .hidden;
        window.styleMask.insert(NSWindowStyleMask.fullSizeContentView);
        window.titlebarAppearsTransparent = true;
        window.standardWindowButton(.closeButton)?.superview?.superview?.removeFromSuperview();
    }
}

extension RARequestViewController: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        // Return the amount of items in songsTableViewItems
        return self.songsTableViewItems.count;
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view for the cell we want to modify
        let cellView: NSTableCellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! NSTableCellView;
        
        // If this is the main column...
        if(tableColumn!.identifier == "Main Column") {
            /// cellView as a RASongListTableViewCell
            let cellViewSongListTableViewCell : RASongListTableViewCell = cellView as! RASongListTableViewCell;
            
            /// The data for this cell
            let cellData : RASearchSong = self.songsTableViewItems[row];
            
            // Load the data into the cell
            cellViewSongListTableViewCell.displaySong(cellData);
            
            // Set the cell's favourite and request buttons pressed actions and targets
            cellViewSongListTableViewCell.favouriteButtonTarget = self;
            cellViewSongListTableViewCell.favouriteButtonAction = #selector(RARequestViewController.songsTableViewItemFavouriteButtonPressed(_:));
            
            cellViewSongListTableViewCell.requestButtonTarget = self;
            cellViewSongListTableViewCell.requestButtonAction = #selector(RARequestViewController.songsTableViewItemRequestButtonPressed(_:));
            
            // Return the modified cell view
            return cellView;
        }
        
        // Return the unmodified cell view, we dont need to do anything
        return cellView;
    }
}

extension RARequestViewController: NSTableViewDelegate {

}
