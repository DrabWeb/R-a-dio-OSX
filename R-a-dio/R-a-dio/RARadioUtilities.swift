//
//  RARadioUtilities.swift
//  R-a-dio
//
//  Created by Seth on 2016-06-27.
//

import Cocoa
import Alamofire

/// The class used for getting information from r/a/dio
class RARadioUtilities {
    /// Gets the current RARadioInfo from r/a/dio, calls the given completion handler with the object
    func getCurrentData(completionHandler : ((RARadioInfo) -> ())) {
        // Make the request
        Alamofire.request(.GET, "https://r-a-d.io/api", encoding: .JSON).responseJSON { (responseData) -> Void in
            /// The string of JSON that will be returned when the GET request finishes
            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: NSUTF8StringEncoding)!;
            
            // If the the response data isnt nil...
            if let dataFromResponseJsonString = responseJsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                /// The JSON from the response string
                let responseJson = JSON(data: dataFromResponseJsonString);
                
                /// The radio info that we retrieved
                let radioInfo : RARadioInfo = RARadioInfo();
                
                // Parse the JSON
                radioInfo.currentSong = RASong(name: responseJson["main"]["np"].stringValue, startTime: NSDate(timeIntervalSince1970: NSTimeInterval(responseJson["main"]["start_time"].intValue)), endTime: NSDate(timeIntervalSince1970: NSTimeInterval(responseJson["main"]["end_time"].intValue)));
                
                radioInfo.currentDj = RADJ(json: responseJson["main"]["dj"]);
                
                radioInfo.listeners = responseJson["main"]["listeners"].intValue;
                
                for(_, currentSongJson) in responseJson["main"]["queue"].enumerate() {
                    radioInfo.queue.append(RASong(json: currentSongJson.1));
                }
                
                for(_, currentSongJson) in responseJson["main"]["lp"].enumerate() {
                    radioInfo.lastPlayed.append(RASong(json: currentSongJson.1));
                }
                
                // Call the completion handler
                completionHandler(radioInfo);
            }
        }
    }
}
