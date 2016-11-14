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
    func getCurrentData(_ completionHandler : @escaping ((RARadioInfo) -> ())) {
        // Make the request
        Alamofire.request("https://r-a-d.io/api").responseJSON { (responseData) -> Void in
            /// The string of JSON that will be returned when the GET request finishes
            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: String.Encoding.utf8.rawValue)!;
            
            // If the the response data isnt nil...
            if let dataFromResponseJsonString = responseJsonString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) {
                /// The JSON from the response string
                let responseJson = JSON(data: dataFromResponseJsonString);
                
                /// The radio info that we retrieved
                let radioInfo : RARadioInfo = RARadioInfo();
                
                // Parse the JSON
                radioInfo.currentSong = RASong(name: responseJson["main"]["np"].stringValue, startTime: Date(timeIntervalSince1970: TimeInterval(responseJson["main"]["start_time"].intValue)), endTime: Date(timeIntervalSince1970: TimeInterval(responseJson["main"]["end_time"].intValue)));
                
                radioInfo.currentSong.id = responseJson["main"]["trackid"].intValue;
                
                radioInfo.currentSongPosition = NSDate(timeIntervalSince1970: TimeInterval(responseJson["main"]["current"].intValue)) as Date;
                
                radioInfo.updateCurrentSongPosition();
                
                radioInfo.currentDj = RADJ(json: responseJson["main"]["dj"]);
                
                radioInfo.listeners = responseJson["main"]["listeners"].intValue;
                
                radioInfo.requestingEnabled = Bool(responseJson["main"]["requesting"].intValue as NSNumber);
                
                for(_, currentSongJson) in responseJson["main"]["queue"].enumerated() {
                    radioInfo.queue.append(RASong(json: currentSongJson.1));
                }
                
                for(_, currentSongJson) in responseJson["main"]["lp"].enumerated() {
                    radioInfo.lastPlayed.append(RASong(json: currentSongJson.1));
                }
                
                // Call the completion handler
                completionHandler(radioInfo);
            }
        }
    }
}
