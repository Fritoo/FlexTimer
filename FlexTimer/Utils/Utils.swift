//
//  Utils.swift
//  FlexTimer
//
//  Created by Miles Alden on 6/14/21.
//

import Foundation
import CoreGraphics

struct Utils {
    
    /**
     Convert degrees to radians for rotation transforms
    */
    static func degreesToRadians( _ degrees: Double) -> CGFloat {
        CGFloat(degrees * (Double.pi / 180.0))
    }
    
    /**
     Round a Double to a given place value.
    */
    static func roundTo( _ source: Double, places: Int ) -> Float {
        
        let placeValue = pow(10.0, Float(places))
        
        print("Place Value: \(placeValue)")
        let rounded = round(Float(source) * placeValue) / placeValue
        
        print("Rounded: \(rounded)")
        return rounded
    }
}
