//
//  AppDelegate.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-27.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    /// The theme the application is currently using
    var applicationTheme : RATheme = .dark;

    /// The status item that brings up the app in a popup
    var applicationStatusItem : NSStatusItem? = nil;
    
    /// The view controller for the popup that comes out of applicationStatusItem
    var applicationStatusItemPopupViewController : RAPlayerViewController? = nil;
    
    /// The global default preferences object
    var preferences : RAPreferences = RAPreferences();

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // Set the user notification center delegate
        NSUserNotificationCenter.default.delegate = self;
        
        // Set up applicationStatusItem
        setupApplicationStatusItem();
        
        // Create applicationStatusItemPopupViewController
        applicationStatusItemPopupViewController = (NSStoryboard(name: "Main", bundle: Bundle.main).instantiateController(withIdentifier: "playerViewController") as! RAPlayerViewController);
        
        // Set the default time zone of the application to GMT
        NSTimeZone.default = TimeZone(abbreviation: "GMT")!;
        
        // Load applicationStatusItemPopupViewController
        applicationStatusItemPopupViewController!.loadView();
    }
    
    /// Sets up applicationStatusItem
    func setupApplicationStatusItem() {
        // Create applicationStatusItem
        applicationStatusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength);
        
        // Set the image scaling
        (applicationStatusItem!.button?.cell as! NSButtonCell).imageScaling = .scaleProportionallyUpOrDown;
        
        // Set the iamge
        applicationStatusItem!.image = NSImage(named: "RAMenubarIcon");
        
        // Set the target and action
        applicationStatusItem!.target = self;
        applicationStatusItem!.action = #selector(AppDelegate.applicationStatusItemPressed);
    }
    
    /// Called when applicationStatusItem is pressed
    func applicationStatusItemPressed() {
        // If the user is using the OSX dark theme...
        if(NSAppearance.current().name.hasPrefix("NSAppearanceNameVibrantDark")) {
            // Set applicationTheme accordingly
            applicationTheme = .dark;
        }
        // If the user is using the OSX light theme...
        else if(NSAppearance.current().name.hasPrefix("NSAppearanceNameVibrantLight")) {
            // Set applicationTheme accordingly
            applicationTheme = .light;
        }
        
        // Set applicationStatusItemPopupViewController's theme
        applicationStatusItemPopupViewController!.currentTheme = applicationTheme;
        
        // Reload applicationStatusItemPopupViewController's theme
        applicationStatusItemPopupViewController!.reapplyTheme();
        
        // Dismiss the popup, if its open
        applicationStatusItemPopupViewController!.dismiss(self);
        
        // Reload the radio info
        applicationStatusItemPopupViewController!.reloadRadioInfo();
        
        // Set the popup's theme
        switch(applicationTheme) {
            case .dark:
                applicationStatusItem!.button!.appearance = NSAppearance(named: NSAppearanceNameVibrantDark);
                break;
            case .light:
                applicationStatusItem!.button!.appearance = NSAppearance(named: NSAppearanceNameVibrantLight);
                break;
        }
        
        // Present applicationStatusItemPopupViewController
        applicationStatusItemPopupViewController!.presentViewController(applicationStatusItemPopupViewController!, asPopoverRelativeTo: applicationStatusItem!.button!.bounds, of: applicationStatusItem!.button!, preferredEdge: NSRectEdge.maxY, behavior: NSPopoverBehavior.transient);
        
        // Reset applicationStatusItem's appearance so the image isnt the wrong color for the menubar
        applicationStatusItem!.button!.appearance = nil;
    }
    
    /// Saves the preferences
    func savePreferences() {
        /// The data for the preferences object
        let data = NSKeyedArchiver.archivedData(withRootObject: preferences);
        
        // Set the standard user defaults preferences key to that data
        UserDefaults.standard.set(data, forKey: "preferences");
        
        // Synchronize the data
        UserDefaults.standard.synchronize();
    }
    
    /// Loads the preferences
    func loadPreferences() {
        // If we have any data to load...
        if let data = UserDefaults.standard.object(forKey: "preferences") as? Data {
            // Set the preferences object to the loaded object
            self.preferences = (NSKeyedUnarchiver.unarchiveObject(with: data) as! RAPreferences);
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true;
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        // Save the preferences
        savePreferences();
    }
}
