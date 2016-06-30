//
//  RAPreferences.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-28.
//

import Cocoa

/// The object that holds the user's preferences and values that need to be kept between sessions
class RAPreferences: NSObject {
    
    /// Returns the default preferences object for the application
    static func defaultPreferences() -> RAPreferences {
        return realDefaultPreferences;
    }
    
    /// The real default preferences object
    private static var realDefaultPreferences : RAPreferences = RAPreferences();
}
