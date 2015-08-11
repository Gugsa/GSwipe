//
//  Circle.swift
//  Swipe
//
//  Created by Gugsa Gemeda on 7/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

enum State {
    case OnScreen
    case OffScreen
    case UserInteracting
}

class Circle: CCNode {
    
//    var circleColor: String?
    var state: State = .OffScreen
    
    var typ: genericColor = .blue
    var circleType: String = ""
    var equateStamp: Double = CACurrentMediaTime()
    var removed = false
    
    weak var gamePlay: Gameplay!
    
    func didLoadFromCCB(){
        self.userInteractionEnabled = false
        
        switch circleType{
            case "blueCircle":
                typ = .blue
            case "redCircle":
                typ = .red
            case "greenCircle":
                typ = .green
            case "yellowCircle":
                typ = .yellow
            default:
                println("No Color")
            
        }
        gamePlay = self.parent as? Gameplay
        
    }

}

extension Circle: Equatable {}

func ==(lhs: Circle, rhs: Circle) ->Bool {
    return lhs.equateStamp == rhs.equateStamp
}