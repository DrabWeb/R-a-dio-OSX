//
//  RASongListTableViewCell.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-28.
//  Copyright © 2016 DrabWeb. All rights reserved.
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
    var favouriteButtonAction : Selector = Selector("");
    
    /// The button that the user can press to request to play the song this cell represents
    @IBOutlet var requestButton: NSButton!
    
    /// The object to perform requestButtonAction
    var requestButtonTarget : AnyObject? = nil;
    
    /// The selector to perform when requestButton is pressed, passed this cell's represented song
    var requestButtonAction : Selector = Selector("");
    
    /// The RASearchSong this cell represents
    var representedSong : RASearchSong? = nil;
    
    /// Displays the data from the given RASearchSong in this cell
    func displaySong(song : RASearchSong) {
        // Set representedSong
        representedSong = song;
        
        // Display the data
        songNameLabel.stringValue = "\(song.title) by \(song.artist)";
        requestButton.enabled = song.requestable;
        
        // Set the favourite button's target and action
        favouriteButton.target = self;
        favouriteButton.action = Selector("favouriteButtonPressed");
        
        // Set the request button's target and action
        requestButton.target = self;
        requestButton.action = Selector("requestButtonPressed");
    }
    
    /// Called when favouriteButton is pressed
    func favouriteButtonPressed() {
        // Toggle the represented song's favourited bool
        representedSong!.favourited = !representedSong!.favourited;
        
        // Update the favourites button to match
        if(representedSong!.favourited) {
            favouriteButton.image = NSImage(named: "RAFavouritedIcon")!;
        }
        else {
            favouriteButton.image = NSImage(named: "RANotFavouritedIcon")!;
        }
        
        // Call the user's favourite button pressed target and action
        favouriteButtonTarget?.performSelector(favouriteButtonAction, withObject: representedSong!);
    }
    
    /// Called when requestButton is pressed
    func requestButtonPressed() {
        // Call the user's favourite button pressed target and action
        requestButtonTarget?.performSelector(requestButtonAction, withObject: representedSong!);
    }
}
