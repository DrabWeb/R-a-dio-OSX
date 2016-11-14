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
    
    /// The ID of this song
    var id : Int = -1;
    
    /// The date this song starts/started at
    var startTime : Date = Date(timeIntervalSince1970: TimeInterval(0));
    
    /// The date this song ended/ends at(Only applies if this is the current playing song)
    var endTime : Date = Date(timeIntervalSince1970: TimeInterval(0));
    
    /// Returns the display string for how many minutes until this song starts/how many minutes ago it ended(E.g. "5 mins" or "less than a min")
    var startTimeFromNow : String {
        /// The date components of the difference of the current date and startTime
        var nowStartDateComponents : DateComponents = (Calendar.current as NSCalendar).components([.minute, .second], from: Date(timeIntervalSince1970: Date().timeIntervalSince(self.startTime)));
        
        // If the difference between the current date and startTime is negative...
        if(Date().timeIntervalSince(self.startTime) < 0) {
            // Swap their positions and update nowStartDateComponents
            nowStartDateComponents = (Calendar.current as NSCalendar).components([.minute, .second], from: Date(timeIntervalSince1970: self.startTime.timeIntervalSince(Date())));
        }
        
        /// How many minutes until the song starts/ago it ended
        var minutes : Int = nowStartDateComponents.minute!;
        
        // If the seconds are more than or equal to 30...
        if(nowStartDateComponents.second! >= 30) {
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
    
    /// Returns the NSDate for the duration of this song
    var durationDate : Date {
        return Date(timeIntervalSince1970: self.endTime.timeIntervalSince(self.startTime));
    }
    
    /// The display label for the duration of this song
    var durationString : String {
        /// The minute and second components of durationDate
        let durationDateComponents : DateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.minute, NSCalendar.Unit.second], from: durationDate);
        
        /// The display string for the seconds value
        var secondsString : String = String(describing: durationDateComponents.second!);
        
        // If there is only one character in secondsString...
        if(secondsString.characters.count == 1) {
            // Append a 0 to the front
            secondsString = "0\(secondsString)";
        }
        
        // Return the duration string
        return "\(durationDateComponents.minute!):\(secondsString)";
    }
    
    /// The duration of this song, in seconds
    var durationSeconds : Int {
        /// The date components for duration of this song
        let durationDateComponents : DateComponents = (Calendar.current as NSCalendar).components([NSCalendar.Unit.second, NSCalendar.Unit.minute], from: durationDate);
        
        // Return the duration in seconds
        return durationDateComponents.second! + (durationDateComponents.minute! * 60);
    }
    
    // Init with a name, start time and end time
    init(name : String, startTime : Date, endTime : Date) {
        self.name = name;
        self.startTime = startTime;
        self.endTime = endTime;
    }
    
    // Init with JSON
    init(json : JSON) {
        self.name = json["meta"].stringValue;
        self.startTime = Date(timeIntervalSince1970: TimeInterval(json["timestamp"].intValue));
    }
    
    // Blank init
    init() {
        self.name = "";
        self.startTime = Date(timeIntervalSince1970: TimeInterval(0));
        self.endTime = Date(timeIntervalSince1970: TimeInterval(0));
    }
}

/// An object for referencing a search result song
class RASearchSong: NSObject {
    /// The artist of this song
    var artist : String = "";
    
    /// The title of this song
    var title : String = "";
    
    /// The ID of this song on r/a/dio
    var id : Int = -1;
    
    /// Is this song requestable?
    var requestable : Bool = true;
    
    /// Is this song favourited?
    var favourited : Bool = false;
    
    /// Returns if this RASearchSong is equal to another RASearchSong
    func equals(_ song : RASearchSong) -> Bool {
        // Return if the artist, title and id are the same for this song and the given song
        return (self.artist == song.artist && self.title == song.title && self.id == song.id);
    }
    
    // Blank init
    override init() {
        super.init();
        
        self.artist = "";
        self.title = "";
        self.id = -1;
        self.requestable = true;
    }
    
    // Init with JSON
    init(json : JSON) {
        super.init();
        
        self.artist = json["artist"].stringValue;
        self.title = json["title"].stringValue;
        self.id = json["id"].intValue;
        self.requestable = json["requestable"].boolValue;
    }
    
    func encodeWithCoder(_ coder: NSCoder) {
        // Encode the values
        coder.encode(self.artist, forKey: "artist");
        coder.encode(self.title, forKey: "title");
        coder.encode(self.id, forKey: "id");
        coder.encode(self.requestable, forKey: "requestable");
        coder.encode(self.favourited, forKey: "favourited");
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init();
        
        // Decode and load the values
        self.artist = (decoder.decodeObject(forKey: "artist") as! String?)!;
        self.title = (decoder.decodeObject(forKey: "title") as! String?)!;
        self.id = (decoder.decodeObject(forKey: "id") as! Int?)!;
        self.requestable = (decoder.decodeObject(forKey: "requestable") as! Bool?)!;
        self.favourited = (decoder.decodeObject(forKey: "favourited") as! Bool?)!;
    }
}

/// The object that passes data between RARadioUtilities and the class asking for the data
class RARadioInfo {
    /// The current song that is playing
    var currentSong : RASong = RASong();
    
    /// The position of the current song
    var currentSongPosition : Date = Date(timeIntervalSince1970: TimeInterval(0));
    
    /// Returns the date components of currentSongPosition(Minutes and Seconds)
    var currrentSongPositionDateComponents : DateComponents {
        // Return the date components
        return (Calendar.current as NSCalendar).components([.minute, .second], from: currentSongPosition);
    }
    
    /// Calculates currentSongPosition and sets it, based on it's current value
    func updateCurrentSongPosition() {
        // Calculate and set currentSongPosition
        self.currentSongPosition = Date(timeIntervalSince1970: self.currentSongPosition.timeIntervalSince1970 - self.currentSong.startTime.timeIntervalSince1970);
    }
    
    /// The current DJ
    var currentDj : RADJ = RADJ();
    
    /// The amount of listeners listening when this object was created
    var listeners : Int = -1;
    
    /// Is requesting currently enabled?
    var requestingEnabled : Bool = false;
    
    /// The list of songs in the queue(capped at 5 by the API)
    var queue : [RASong] = [];
    
    /// The list of songs that were last played(capped at 5 by the API)
    var lastPlayed : [RASong] = [];
}
