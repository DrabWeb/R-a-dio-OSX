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
    @IBAction func searchFieldTextEntered(sender : NSTextField) {
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
    }
    
    /// The last request made for getting search results
    var lastSearchRequest : Request? = nil;
    
    /// Searches for the given query on r/a/dio and puts the results in songsTableView
    func searchFor(query : String) {
        // Cancel the last search request
        lastSearchRequest?.cancel();
        
        // Clear songsTableViewItems
        songsTableViewItems.removeAll();
        
        // Make the search request
        lastSearchRequest = Alamofire.request(.GET, "https://r-a-d.io/api/search/\(query.stringByReplacingOccurrencesOfString(" ", withString: "%20"))", encoding: .JSON).responseJSON { (responseData) -> Void in
            /// The string of JSON that will be returned when the GET request finishes
            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: NSUTF8StringEncoding)!;
            
            // If the the response data isnt nil...
            if let dataFromResponseJsonString = responseJsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                /// The JSON from the response string
                let responseJson = JSON(data: dataFromResponseJsonString);
                
                // For every song in "data" in responseJson...
                for(_, currentSongJson) in responseJson["data"].enumerate() {
                    // Add the current song to songsTableViewItems
                    self.songsTableViewItems.append(RASearchSong(json: currentSongJson.1));
                }
                
                // Reload the songs table view
                self.songsTableView.reloadData();
            }
        }
    }
    
    /// Called when the user presses the favourite button in a row in songsTableView
    func songsTableViewItemFavouriteButtonPressed(pressedSong : RASearchSong) {
        print("\(pressedSong.title) by \(pressedSong.artist)(\(pressedSong.id)) is favourited: \(pressedSong.favourited)");
    }
    
    /// Called when the user presses the request button in a row in songsTableView
    func songsTableViewItemRequestButtonPressed(pressedSong : RASearchSong) {
        print("Requested to play \(pressedSong.title) by \(pressedSong.artist)(\(pressedSong.id))");
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // Center the window
        window.center();
    }
    
    func windowWillEnterFullScreen(notification: NSNotification) {
        // Hide the toolbar
        window.toolbar?.visible = false;
        
        // Set the window's appearance to vibrant dark so the fullscreen toolbar is dark
        window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
    }
    
    func windowDidExitFullScreen(notification: NSNotification) {
        // Show the toolbar
        window.toolbar?.visible = true;
        
        // Set back the window's appearance
        window.appearance = NSAppearance(named: NSAppearanceNameAqua);
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        window = NSApplication.sharedApplication().windows.last!;
        
        // Style the visual effect views
        backgroundVisualEffectView.material = .Dark;
        
        // Style the window's titlebar
        window.titleVisibility = .Hidden;
        window.styleMask |= NSFullSizeContentViewWindowMask;
        window.titlebarAppearsTransparent = true;
        window.standardWindowButton(.CloseButton)?.superview?.superview?.removeFromSuperview();
    }
}

extension RARequestViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        // Return the amount of items in songsTableViewItems
        return self.songsTableViewItems.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view for the cell we want to modify
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView;
        
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
            cellViewSongListTableViewCell.favouriteButtonAction = Selector("songsTableViewItemFavouriteButtonPressed:");
            
            cellViewSongListTableViewCell.requestButtonTarget = self;
            cellViewSongListTableViewCell.requestButtonAction = Selector("songsTableViewItemRequestButtonPressed:");
            
            // Return the modified cell view
            return cellView;
        }
        
        // Return the unmodified cell view, we dont need to do anything
        return cellView;
    }
}

extension RARequestViewController: NSTableViewDelegate {

}