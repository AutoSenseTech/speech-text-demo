//
//  SpeechToTextAnalyzer.swift
//  speech-text demo
//
//  Created by Wang Weihan on 9/29/16.
//  Copyright © 2016 Wang Weihan. All rights reserved.
//

import Foundation

class SpeechToTextAnalyzer {
    //var languageString = ""
    //var audioSource: URL!
    var respondString = ""
    //let urlString = "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"
    let urlString = "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize"
    let username = "cbe9d637-8a27-412f-bc27-f6e23b180344"
    let password = "3VU8YGN4wBXK"
    func analyze(languageChoose: String, audioSource:URL, completionHandler: @escaping (Data?, String?) -> Void){
        
        let config = URLSessionConfiguration.default // Session Configuration
        let userPasswordString = username + ":" + password
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        let base64EncodedCredential = userPasswordData!.base64EncodedString()
        let authString = "Basic \(base64EncodedCredential)"
        
        config.httpAdditionalHeaders = ["Authorization" : authString]
        
        let session = URLSession(configuration: config) // Load configuration into Session
        
        //string: urlString + "?model="+"en-US_BroadbandModel"+"&continuous=true"
        if let url = URL(string: urlString + "?model="+languageChoose+"&continuous=true") {
            print(languageChoose);
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("audio/wav", forHTTPHeaderField: "Content-Type")
            //urlRequest.addValue("audio/flac", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
            
            if let data = try? Data(contentsOf: audioSource) {
                 urlRequest.httpBody = data
            }
            //}
            
            let task = session.dataTask(with: urlRequest, completionHandler: {
                (data, response, error) in
                
                if error != nil {
                    print("error")
                    DispatchQueue.main.sync(execute: {
                        completionHandler(nil, error!.localizedDescription)
                    })
                } else {
                    print("data")
                    let str = String(data: data!, encoding: .utf8)
                    
                    print(str)
                    self.parseJson(data!)
                    DispatchQueue.main.sync(execute: {
                        completionHandler(data, nil)
                    })
                }
                
            })
            task.resume()
        }
    }
    func parseJson(_ data: Data) {
        self.respondString = ""
        if let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let root = json as? [String: Any],
            let resultIndex = root["result_index"] as? Int,
            let results = root["results"] as? [Any]{
            for result in results {
                if let result = result as? [String: Any],
                    let final = result["final"] as? Bool,
                    let alternatives = result["alternatives"] as? [Any]{
                    for alternative in alternatives{
                        if let alternative = alternative as? [String:Any],
                        let confidence = alternative["confidence"] as? Float,
                            let transcript = alternative["transcript"] as? String{
                            self.respondString += transcript
                        }
                    }
                }
            }
        }
    }
    
}
