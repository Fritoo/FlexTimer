//
//  FlexTimerView+Tap.swift
//  FlexTimer
//
//  Created by Miles Alden on 6/14/21.
//

import Foundation
import UIKit

extension FlexTimerView {
    
    /**
     Touch event receipt
    */
    @objc
    func tap(_ gesture: UITapGestureRecognizer) {
        print("tapped")
        
        if flexTimer.state != .running {
            print("Animation duration: \(animation.duration)")
            
            // Start the timer
            flexTimer.start()
            
            // Inform others
            onChange?(flexTimer.state)
            
            // If the animation has not been added, we'll add it.
            if progressLayer.animation(forKey: "strokeEnd") == nil {
            
                print("Animation added")
                progressLayer.add(animation, forKey: "strokeEnd")

            } else {
                
                print("Animation resumed")
                progressLayer.resumeAnimation()
            }
            
        } else {
            
            print("Animation paused")
            flexTimer.stop()
            
            // Inform others
            onChange?(flexTimer.state)
            
            progressLayer.pauseAnimation()
        }
        

    }
}
