//
//  Gamestate.swift
//  Swipe
//
//  Created by Gugsa Gemeda on 8/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

//enum State {
//    case Playing
//    case Paused
//}

class Gamestate {
    static let sharedInstance = Gamestate()
    
    var playing: Bool = true {
        didSet {
            if playing {
                OALSimpleAudio.sharedInstance().bgMuted = false
            } else {
                OALSimpleAudio.sharedInstance().bgMuted = true
            }
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(playing, forKey: "gamesound")
            userDefaults.synchronize()
        }
    }
    
    func toggleSound() {
        playing = !playing
    }
    
}