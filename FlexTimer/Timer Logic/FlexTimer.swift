//
//  FlexTimer.swift
//  FlexTimer
//
//  Created by Miles Alden on 6/13/21.
//
// References: https://www.mikeash.com/pyblog/friday-qa-2010-01-01-nsrunloop-internals.html

import Foundation


@IBDesignable
class FlexTimer : CustomStringConvertible {

    /**
     Completion function as typealias to make as an @escaping + optional
    */
    typealias Completion = () -> Void

    /**
     Tick on floor-rounded Int seconds.
    */
    typealias Tick = (Double) -> Void

    /**
     State of the timer
    */
    enum State: String {
        
        /**
         New timer, never run before
        */
        case new
        
        /**
         Time is elapsing
        */
        case running
        
        /**
         Time was elapsing bug paused
        */
        case paused
        
        /**
         Time expired
        */
        case ended
        
        /**
         Timer was cancelled and cannot be reused.
        */
        case cancelled
        
    }
    
    /**
     Our internal run loop to monitor and control our timing functions
    */
    private let runLoop: RunLoop = RunLoop()
    
    
    /**
     Our tracked elapsed time
    */
    private var elapsed: Double = 0
    
    /**
     Compute percentage of completion
    */
    var progress: Double {
        elapsed / length
    }
    
    /**
     How long should the timer go for?
    */
    let length : Double
    
    /**
     What state is the timer in
    */
    var state : State = State.new
    
    /**
     Optional execution when firing occurs (timer ends)
    */
    var completion: FlexTimer.Completion?
    
    /**
     Optional tick callback on approximately even seconds
    */
    var tick: FlexTimer.Tick?
    
    /**
     Create our time with an explicit Double
    - Parameter length: How long should this timer go for?
    */
    init ( length: Double, _ completion: Completion? = nil) {
        self.length = length
    }
    
    /**
     Create our time with an Int. Converts to a float.
    - Parameter length: How long should this timer go for?
    */
    init ( length: Int, _ completion: Completion? = nil) {
        self.length = Double(length)
    }
    
    /**
     Sugar for creating and starting the timer immediately.
    - Parameter length: How long should this timer go for?
    - Return: Created and running timer.
    */
    static func runFor( _ length: Int, _ completion: Completion? = nil)  -> FlexTimer {
        
        // Mutable init
        let timer = FlexTimer(length: length)
        
        // Set the completion
        timer.completion = completion
        
        return timer.start()
        
    }
    
    /**
     Begins the newly created timer
    */
    @discardableResult
    func start() -> FlexTimer {
        
        // Cancelled timers are considered invalid.
        guard state != .cancelled else { return self }
        
        print(self)
        
        // Capture outside of the async block
        let tick = self.tick
        
        // Set the state
        self.state = .running
        
        DispatchQueue.global().async { [self] in
                
            // Delta for start / elapsed times
            let uninterruptedEnd = Date().addingTimeInterval( Double(self.length - self.elapsed) )
            
            // Tick checker
            var lastWhole = 0
            

            
            // Run through our timer
            repeat {
                
                // Pump run loop
                self.runLoop.run(mode: .default, before: uninterruptedEnd)
                
                // Adjust elapsed time
                self.elapsed = (self.length - uninterruptedEnd.timeIntervalSinceNow)
                
                // Compare even seconds
                let thisWhole = Int(self.elapsed)
                if lastWhole != thisWhole {
                    lastWhole = Int(self.elapsed)

                    // Make sure this is a value, not reference passed in the tick
                    tick?(Double(self.elapsed))
                }
                
            // Cycle through while we are still in the running state and time is remaining on the timer
            } while self.state == .running && self.elapsed <= self.length
                            
            // State of .running to .ended is the natural flow. Anything else is a stop / cancel.
            if self.state == .running {
                
                // Time completed
                self.state = .ended
                
                // Execute if exists
                DispatchQueue.main.async {
                    self.completion?()
                }
            }
        
        }
        
        return self
        
    }
    
    /**
     Stops the timer
    */
    @discardableResult
    func stop() -> FlexTimer {
        
        // State set to paused, which will take us out of pumping the run loop
        state = .paused
        
        print(self)
        
        return self
        
    }
    
    /**
     Following the NSTimer pattern, this timer is now invalid and cannot be reused.
    */
    @discardableResult
    func cancel() -> FlexTimer {
        
        state = .cancelled
        
        print(self)
        
        return self
    }
    
    
    var description: String {
        return "\(type(of: self)) State: \(state), Remaining: \(length - elapsed)"
    }
}


