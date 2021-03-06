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
    func songIsFavourited(_ song : RASearchSong) -> Bool {
        /// Is the given song favourited?
        var favourited : Bool = false;
        
        // For every song in favouriteSongs...
        for(_, currentSong) in favouriteSongs.enumerated() {
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
    func addSongToFavourites(_ song : RASearchSong) {
        // Print what song we are adding to favourites
        print("RAPreferences: Adding \(song.artist) - \(song.title)(\(song.id)) to favourites");
        
        // Set the song as favourited
        song.favourited = true;
        
        // Add the given song to favouriteSongs
        favouriteSongs.append(song);
    }
    
    /// Removes the given RASearchSong from favouriteSongs
    func removeSongFromFavourites(_ song : RASearchSong) {
        // Print what song we are removing from favourites
        print("RAPreferences: Removing \(song.artist) - \(song.title)(\(song.id)) from favourites");
        
        // Set the song as not favourited
        song.favourited = false;
        
        // Remove the given song from favouriteSongs
        /// favouriteSongs without song
        var newFavouriteSongs : [RASearchSong] = [];
        
        // For every item in favouriteSongs...
        for(_, currentSong) in favouriteSongs.enumerated() {
            // If the current song's ID isnt equal to the given song's ID...
            if(currentSong.id != song.id) {
                // Add the current song to newFavouriteSongs
                newFavouriteSongs.append(currentSong);
            }
        }
        
        // Set favouriteSongs to newFavouriteSongs
        favouriteSongs = newFavouriteSongs;
    }
    
    func encodeWithCoder(_ coder: NSCoder) {
        // Encode the values
        coder.encode(self.volume, forKey: "volume");
        coder.encode(self.favouriteSongs, forKey: "favouriteSongs");
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init();
        
        // Decode and load the values
        if(decoder.decodeObject(forKey: "volume") != nil) {
            self.volume = (decoder.decodeObject(forKey: "volume") as! Float?)!;
        }
        
        if(decoder.decodeObject(forKey: "favouriteSongs") != nil) {
            self.favouriteSongs = (decoder.decodeObject(forKey: "favouriteSongs") as? [RASearchSong])!;
        }
    }
}
