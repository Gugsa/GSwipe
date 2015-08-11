//
//  Extensions.swift
//  Swipe
//
//  Created by Gugsa Gemeda on 7/27/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

extension CGPoint {
    
    func directionVectorToPoint(point: CGPoint) -> CGPoint{
        var vector = CGPoint()
        vector.x = point.x - self.x
        vector.y = point.y - self.y
        return vector
    }
}

public extension Int {
    public static func random(n:Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    
    public static func random(#min:Int, max:Int) -> Int {
        return Int(arc4random_uniform(UInt32(max-min+1))) + min
    }

}