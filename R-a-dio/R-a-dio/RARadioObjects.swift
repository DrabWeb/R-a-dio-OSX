//
//  RARadioObjects.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-27.
//  

import Cocoa

/// An object for referring to r/a/dio DJs
class RADJ {
    /// The name of this DJ
    var name : String = "";
    
    /// The ID of this DJ's artwork
    var artId : Int = -1;
    
    /// Returns the URL to the artwork for this DJ
    var artUrl : String {
        return "https://r-a-d.io/api/dj-image/\(artId)";
    }
    
    // Init with a name and artwork
    init(name : String, art : NSImage) {
        self.name = name;
    }
    
    // Init with a name and artwork ID
    init(name : String, artId : Int) {
        self.name = name;
        self.artId = artId;
    }
    
    // Init with JSON
    init(json : JSON) {
        self.name = json["djname"].stringValue;
        self.artId = json["djimage"].intValue;
    }
    
    // Blank init
    init() {
        self.name = "";
        self.artId = -1;
    }
}

/// An object for referring to songs that are in the queue or last played
class RASong {
    /// The name of this song
    var name : String = "";
    
    /// The date this song starts/started at
    var startTime : NSDate = NSDate(timeIntervalSince1970: NSTimeInterval(0));
    
    /// The date this song ended/ends at(Only applies if this is the current playing song)
    var endTime : NSDate = NSDate(timeIntervalSince1970: NSTimeInterval(0));
    
    /// Returns the display string for how many minutes until this song starts/how many minutes ago it ended(E.g. "5 mins" or "less than a min")
    var startTimeFromNow : String {
        /// The date components of the difference of the current date and startTime
        var nowStartDateComponents : NSDateComponents = NSCalendar.currentCalendar().components([.Minute, .Second], fromDate: NSDate(timeIntervalSince1970: NSDate().timeIntervalSinceDate(self.startTime)));
        
        // If the difference between the current date and startTime is negative...
        if(NSDate().timeIntervalSinceDate(self.startTime) < 0) {
            // Swap their positions and update nowStartDateComponents
            nowStartDateComponents = NSCalendar.currentCalendar().components([.Minute, .Second], fromDate: NSDate(timeIntervalSince1970: self.startTime.timeIntervalSinceDate(NSDate())));
        }
        
        /// How many minutes until the song starts/ago it ended
        var minutes : Int = nowStartDateComponents.minute;
        
        // If the seconds are more than or equal to 30...
        if(nowStartDateComponents.second >= 30) {
            // Add one to minutes for rounding
            minutes += 1;
        }
        
        /// If minutes is one or zero...
        if(minutes == 0 || minutes == 1) {
            // Return "less than a min"
            return "less than a min";
        }
        // If minutes is not 1...
        else {
            // Return "X mins"
            return "\(minutes) mins";
        }
    }
    
    /// Returns the NSDate for the current playing position of this song
    var positionDate : NSDate {
        return NSDate(timeIntervalSince1970: NSDate().timeIntervalSinceDate(self.endTime));
    }
    
    /// The display label for the current playing position of this song
    var positionString : String {
        /// The minute and second components of positionDate
        let positionDateComponents : NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: positionDate);
        
        /// The display string for the seconds value
        var secondsString : String = String(positionDateComponents.second);
        
        // If there is only one character in secondsString...
        if(secondsString.characters.count == 1) {
            // Append a 0 to the front
            secondsString = "0\(secondsString)";
        }
        
        // Return the position string
        return "\(positionDateComponents.minute):\(secondsString)";
    }
    
    /// The current playing position of this song, in seconds
    var positionSeconds : Int {
        /// The date components for the current playing position of this song
        let positionDateComponents : NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Second, NSCalendarUnit.Minute], fromDate: positionDate);
        
        // Return the position in seconds
        return positionDateComponents.second + (positionDateComponents.minute * 60);
    }
    
    /// Returns the NSDate for the duration of this song
    var durationDate : NSDate {
        return NSDate(timeIntervalSince1970: self.endTime.timeIntervalSinceDate(self.startTime));
    }
    
    /// The display label for the duration of this song
    var durationString : String {
        /// The minute and second components of durationDate
        let durationDateComponents : NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: durationDate);
        
        /// The display string for the seconds value
        var secondsString : String = String(durationDateComponents.second);
        
        // If there is only one character in secondsString...
        if(secondsString.characters.count == 1) {
            // Append a 0 to the front
            secondsString = "0\(secondsString)";
        }
        
        // Return the duration string
        return "\(durationDateComponents.minute):\(secondsString)";
    }
    
    /// The duration of this song, in seconds
    var durationSeconds : Int {
        /// The date components for duration of this song
        let durationDateComponents : NSDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Second, NSCalendarUnit.Minute], fromDate: durationDate);
        
        // Return the duration in seconds
        return durationDateComponents.second + (durationDateComponents.minute * 60);
    }
    
    // Init with a name, start time and end time
    init(name : String, startTime : NSDate, endTime : NSDate) {
        self.name = name;
        self.startTime = startTime;
        self.endTime = endTime;
    }
    
    // Init with JSON
    init(json : JSON) {
        self.name = json["meta"].stringValue;
        self.startTime = NSDate(timeIntervalSince1970: NSTimeInterval(json["timestamp"].intValue));
    }
    
    // Blank init
    init() {
        self.name = "";
        self.startTime = NSDate(timeIntervalSince1970: NSTimeInterval(0));
        self.endTime = NSDate(timeIntervalSince1970: NSTimeInterval(0));
    }
}

/// The object that passes data between RARadioUtilities and the class asking for the data
class RARadioInfo {
    /// The current song that is playing
    var currentSong : RASong = RASong();
    
    /// The current DJ
    var currentDj : RADJ = RADJ();
    
    /// The amount of listeners listening when this object was created
    var listeners : Int = -1;
    
    /// The list of songs in the queue(capped at 5 by the API)
    var queue : [RASong] = [];
    
    /// The list of songs that were last played(capped at 5 by the API)
    var lastPlayed : [RASong] = [];
}