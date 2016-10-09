//
//  RAPreferences.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-28.
//

import Cocoa

/// The object that holds the user's preferences and values that need to be kept between sessions
class RAPreferences: NSObject {
    
    /// The volume for the music to play
    var volume : Float = 0.9;
    
    /// The songs the user has favourited
    var favouriteSongs : [RASearchSong] = [];
    
    /// Returns if the given RASearchSong is favourited
    func songIsFavourited(song : RASearchSong) -> Bool {
        /// Is the given song favourited?
        var favourited : Bool = false;
        
        // For every song in favouriteSongs...
        for(_, currentSong) in favouriteSongs.enumerate() {
            // If the current song's ID is equal to the given song's ID...
            if(currentSong.id == song.id) {
                // Set favourited to true and break the loop
                favourited = true;
                break;
            }
        }
        
        // Return if the given song is favourited
        return favourited;
    }
    
    /// Adds the given RASearchSong to favouriteSongs
    func addSongToFavourites(song : RASearchSong) {
        // Print what song we are adding to favourites
        print("RAPreferences: Adding \(song.artist) - \(song.title)(\(song.id)) to favourites");
        
        // Add the given song to favouriteSongs
        favouriteSongs.append(song);
    }
    
    /// Removes the given RASearchSong from favouriteSongs
    func removeSongFromFavourites(song : RASearchSong) {
        // Print what song we are removing from favourites
        print("RAPreferences: Removing \(song.artist) - \(song.title)(\(song.id)) from favourites");
        
        // Remove the given song from favouriteSongs
        /// favouriteSongs without song
        var newFavouriteSongs : [RASearchSong] = [];
        
        // For every item in favouriteSongs...
        for(_, currentSong) in favouriteSongs.enumerate() {
            // If the current song's ID isnt equal to the given song's ID...
            if(currentSong.id != song.id) {
                // Add the current song to newFavouriteSongs
                newFavouriteSongs.append(currentSong);
            }
        }
        
        // Set favouriteSongs to newFavouriteSongs
        favouriteSongs = newFavouriteSongs;
    }
    
    func encodeWithCoder(coder: NSCoder) {
        // Encode the values
        coder.encodeObject(self.volume, forKey: "volume");
        coder.encodeObject(self.favouriteSongs, forKey: "favouriteSongs");
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init();
        
        // Decode and load the values
        if(decoder.decodeObjectForKey("volume") != nil) {
            self.volume = (decoder.decodeObjectForKey("volume") as! Float?)!;
        }
        
        if(decoder.decodeObjectForKey("favouriteSongs") != nil) {
            self.favouriteSongs = (decoder.decodeObjectForKey("favouriteSongs") as? [RASearchSong])!;
        }
    }
}
