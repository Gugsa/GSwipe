//
//  Rectangle.swift
//  Swipe
//
//  Created by Gugsa Gemeda on 7/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class Rectangle: CCNode {
    
    var type: genericColor = .red
    var rectType: String = ""
    
    weak var gamePlay: Gameplay!
    
    func didLoadFromCCB(){
        self.userInteractionEnabled = true
        
        switch rectType{
            case "redRectangle":
                type = .red
            case "blueRectangle":
                type = .blue
            case "greenRectangle":
                type = .green
            case "yellowRectangle":
                type = .yellow
            default:
                println("No Color")
            
        }
        gamePlay = self.parent as? Gameplay
        
    }

    
}