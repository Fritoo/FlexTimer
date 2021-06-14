//
//  CALayer+Pause.swift
//  FlexTimer
//
//  Created by Miles Alden on 6/14/21.
//

import Foundation
import QuartzCore

/**
 Protocol for making it clear that a CALayer's animations can be paused
*/
protocol CALayerAnimationControl {
    
    /**
     State
    */
    func isPaused() -> Bool
    
    /**
     Use to pause a active animations on this layer
    */
    func pauseAnimation()
    
    /**
     Use to resume animations on this layer.
    */
    func resumeAnimation()
    
    
}

/**
 Extension on CALayer to manipulate the CAMediaTiming for the layer and allow us to control its animations.
 
 References: https://stackoverflow.com/a/59079995/1601732, https://developer.apple.com/library/content/qa/qa1673/_index.html
 
*/
extension CALayer: CALayerAnimationControl {
    
    /**
     We use this as our marker of being paused since we can't add a stored value in an extension
    */
    func isPaused() -> Bool {
        speed <= 0.0
    }
    
    func pauseAnimation() {
        
        // If we're currently running, we'll capture the time and set our speed to 0.
        if !isPaused() {
            let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
            speed = 0
            timeOffset = pausedTime
        }
    }
    
    func resumeAnimation() {
        
        // If we're paused, calculate how much time as passed since the pause occurred and resume animation with the delta
        if isPaused() {
            let pausedTime = timeOffset
            speed = 1.0
            timeOffset = 0
            beginTime = 0
            
            // Delta
            let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            beginTime = timeSincePause
        }
        
    }
    
}
