//
//  AppDelegate.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-27.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// The theme the application is currently using
    var applicationTheme : RATheme = .Dark;

    /// The status item that brings up the app in a popup
    var applicationStatusItem : NSStatusItem? = nil;
    
    /// The view controller for the popup that comes out of applicationStatusItem
    var applicationStatusItemPopupViewController : RAPlayerViewController? = nil;
    
    /// The global default preferences object
    var preferences : RAPreferences = RAPreferences();

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // Set up applicationStatusItem
        setupApplicationStatusItem();
        
        // Create applicationStatusItemPopupViewController
        applicationStatusItemPopupViewController = (NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("playerViewController") as! RAPlayerViewController);
        
        // Set the default time zone of the application to GMT
        NSTimeZone.setDefaultTimeZone(NSTimeZone(abbreviation: "GMT")!);
        
        // Load applicationStatusItemPopupViewController
        applicationStatusItemPopupViewController!.loadView();
    }
    
    /// Sets up applicationStatusItem
    func setupApplicationStatusItem() {
        // Create applicationStatusItem
        applicationStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength);
        
        // Set the image scaling
        (applicationStatusItem!.button?.cell as! NSButtonCell).imageScaling = .ScaleProportionallyUpOrDown;
        
        // Set the iamge
        applicationStatusItem!.image = NSImage(named: "RAMenubarIcon");
        
        // Set the target and action
        applicationStatusItem!.target = self;
        applicationStatusItem!.action = Selector("applicationStatusItemPressed");
    }
    
    /// Called when applicationStatusItem is pressed
    func applicationStatusItemPressed() {
        // If the user is using the OSX dark theme...
        if(NSAppearance.currentAppearance().name.hasPrefix("NSAppearanceNameVibrantDark")) {
            // Set applicationTheme accordingly
            applicationTheme = .Dark;
        }
        // If the user is using the OSX light theme...
        else if(NSAppearance.currentAppearance().name.hasPrefix("NSAppearanceNameVibrantLight")) {
            // Set applicationTheme accordingly
            applicationTheme = .Light;
        }
        
        // Set applicationStatusItemPopupViewController's theme
        applicationStatusItemPopupViewController!.currentTheme = applicationTheme;
        
        // Reload applicationStatusItemPopupViewController's theme
        applicationStatusItemPopupViewController!.reapplyTheme();
        
        // Dismiss the popup, if its open
        applicationStatusItemPopupViewController!.dismissController(self);
        
        // Reload the radio info
        applicationStatusItemPopupViewController!.reloadRadioInfo();
        
        // Set the popup's theme
        switch(applicationTheme) {
            case .Dark:
                applicationStatusItem!.button!.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
                break;
            case .Light:
                applicationStatusItem!.button!.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
                break;
        }
        
        // Present applicationStatusItemPopupViewController
        applicationStatusItemPopupViewController!.presentViewController(applicationStatusItemPopupViewController!, asPopoverRelativeToRect: applicationStatusItem!.button!.bounds, ofView: applicationStatusItem!.button!, preferredEdge: NSRectEdge.MaxY, behavior: NSPopoverBehavior.Transient);
        
        // Reset applicationStatusItem's appearance so the image isnt the wrong color for the menubar
        applicationStatusItem!.button!.appearance = nil;
    }
    
    /// Saves the preferences
    func savePreferences() {
        /// The data for the preferences object
        let data = NSKeyedArchiver.archivedDataWithRootObject(preferences);
        
        // Set the standard user defaults preferences key to that data
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "preferences");
        
        // Synchronize the data
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    /// Loads the preferences
    func loadPreferences() {
        // If we have any data to load...
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("preferences") as? NSData {
            // Set the preferences object to the loaded object
            self.preferences = (NSKeyedUnarchiver.unarchiveObjectWithData(data) as! RAPreferences);
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        // Save the preferences
        savePreferences();
    }
}