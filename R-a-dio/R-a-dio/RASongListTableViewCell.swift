//
//  RASongListTableViewCell.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-28.
//

import Cocoa

class RASongListTableViewCell: NSTableCellView {
    /// The label that shows the name of the song this cell represents
    @IBOutlet var songNameLabel: NSTextField!
    
    /// The button that the user can press to favourite/un-favourite the song this cell represents
    @IBOutlet var favouriteButton: NSButton!
    
    /// The object to perform favouriteButtonAction
    var favouriteButtonTarget : AnyObject? = nil;
    
    /// The selector to perform when favouriteButton is pressed, passed this cell's represented song
    var favouriteButtonAction : Selector? = nil;
    
    /// The button that the user can press to request to play the song this cell represents
    @IBOutlet var requestButton: NSButton!
    
    /// The object to perform requestButtonAction
    var requestButtonTarget : AnyObject? = nil;
    
    /// The selector to perform when requestButton is pressed, passed this cell's represented song
    var requestButtonAction : Selector? = nil;
    
    /// The RASearchSong this cell represents
    var representedSong : RASearchSong? = nil;
    
    /// Displays the data from the given RASearchSong in this cell
    func displaySong(_ song : RASearchSong) {
        // Set representedSong
        representedSong = song;
        
        // Display the data
        songNameLabel.stringValue = "\(song.artist) - \(song.title)";
        favouriteButton.state = Int.fromBool(bool: song.favourited);
        updateFavouriteButton();
        requestButton.isEnabled = song.requestable;
        
        // Set the favourite button's target and action
        favouriteButton.target = self;
        favouriteButton.action = #selector(RASongListTableViewCell.favouriteButtonPressed);
        
        // Set the request button's target and action
        requestButton.target = self;
        requestButton.action = #selector(RASongListTableViewCell.requestButtonPressed);
    }
    
    /// Called when favouriteButton is pressed
    func favouriteButtonPressed() {
        // Toggle the represented song's favourited bool
        representedSong!.favourited = !representedSong!.favourited;
        
        // Update the favourites button to match
        updateFavouriteButton();
        
        // Call the user's favourite button pressed target and action
        if(favouriteButtonAction != nil && favouriteButtonTarget != nil) {
            favouriteButtonTarget!.perform(favouriteButtonAction!, with: representedSong!);
        }
    }
    
    /// Updates the favourite button image to match the represented song's favourited state
    func updateFavouriteButton() {
        // Update the favourites button to match
        if(representedSong!.favourited) {
            favouriteButton.image = NSImage(named: "RAFavouritedIcon")!;
        }
        else {
            favouriteButton.image = NSImage(named: "RANotFavouritedIcon")!;
        }
    }
    
    /// Called when requestButton is pressed
    func requestButtonPressed() {
        // Call the user's request button pressed target and action
        if(requestButtonAction != nil && requestButtonTarget != nil) {
            requestButtonTarget!.perform(requestButtonAction!, with: representedSong!);
        }
    }
}
