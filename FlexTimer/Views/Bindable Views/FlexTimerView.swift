//
//  FlexTimerView.swift
//  FlexTimer
//
//  Created by Miles Alden on 6/13/21.
//

import UIKit
import CoreGraphics


/**
 This is our view, bound to a `FlexTimer` instance and
*/
class FlexTimerView: UIView {

    /**
     Colors in struct form
    */
    struct Colors {
        
        /**
         The color of the bar as it fills the circle
        */
        static let strokeColor: UIColor = UIColor.black
        
        /**
         The color of the bar before being filled
        */
        static let grayStrokeColor: UIColor = UIColor.gray
        
        /**
         The color of the bar before being filled
        */
        static let fillColor: UIColor? = .none
    }
    
    /**
     Auto create and add our tap to this view
    */
    var tapGesture: UITapGestureRecognizer? = nil
    
    /**
     Fill layer, if we choose to use it.
    */
    var fillLayer: CAShapeLayer!
    
    /**
     The empty path layer, the bar when not filled
    */
    var emptyStrokeLayer: CAShapeLayer!
    
    /**
     Updated progress, if needed.
    */
    var progress: Double {
        flexTimer.progress
    }
    
    /**
     Inner circle, if we want. Defaults to clear
    */
    @IBInspectable
    var fillColor: UIColor? = Colors.fillColor {
        didSet {
            resetLayers()
        }
    }
    
    /**
     Stroke progress color
    */
    @IBInspectable
    var strokeColor: UIColor = Colors.strokeColor {
        didSet {
            resetLayers()
        }
    }
    
    /**
     Stroke progress when empty
    */
    @IBInspectable
    var emptyStrokeColor: UIColor = Colors.grayStrokeColor {
        didSet {
            resetLayers()
        }
    }
    
    /**
     Duration can be set here, but also
    */
    @IBInspectable
    var duration: Double = 5.0 {
        didSet {
            flexTimer = FlexTimer(length: duration)
            resetLayers()

        }
    }
    
    /**
     Update the layer info and reset
    */
    func resetLayers() {
        
        progressLayer.removeFromSuperlayer()
        _progressLayer = nil
        _animation = nil
        
        setNeedsLayout()
    }
    
    /**
     The timer running the show
    */
    var flexTimer: FlexTimer!
    
    /**
     Lazy loaded animation
    */
    private var _animation: CABasicAnimation?
    var animation: CABasicAnimation {
        
        get {
            guard _animation == nil else {
                return _animation!
            }
            
            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.duration = flexTimer.length
            strokeAnimation.fromValue = flexTimer.progress
            strokeAnimation.toValue = 1

            strokeAnimation.fillMode = .forwards
            strokeAnimation.isRemovedOnCompletion = false
            strokeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear )
            strokeAnimation.autoreverses = false
            strokeAnimation.delegate = self
            
            _animation = strokeAnimation
            return _animation!
        }
        
    }
    

    /**
     The bar as it fills
    */
    private var _progressLayer: CAShapeLayer?
    var progressLayer: CAShapeLayer {
        
        // TODO: Gradient colors would be nice.
        
        guard _progressLayer == nil else {
            return _progressLayer!
        }
        
        let strokeLayer = CAShapeLayer()
        strokeLayer.lineWidth = 16

        // Square frame
        let square = CGRect(
            origin: CGPoint(x: layer.frame.origin.x + strokeLayer.lineWidth, y: layer.frame.origin.y + strokeLayer.lineWidth),
            size: CGSize(width: layer.frame.width - strokeLayer.lineWidth * 2 , height: layer.frame.width - strokeLayer.lineWidth * 2)
        )
        
        // This path starts us at the top of our circle, and not 90° to the right
        let path = UIBezierPath(
            arcCenter: CGPoint(x: square.origin.x + square.width / 2, y: square.origin.y + square.height / 2),
            radius: square.width / 2,
            startAngle: Utils.degreesToRadians(270),
            endAngle: Utils.degreesToRadians(630),
            clockwise: true
        )
        
        strokeLayer.path = path.cgPath
        strokeLayer.frame = layer.frame
        strokeLayer.fillColor = .none
        strokeLayer.strokeStart = 0
        strokeLayer.strokeEnd = 0
        strokeLayer.strokeColor = strokeColor.cgColor
        
        // The path is stroked on-center, so this will be a circle inserted underneath the stroked path, but
        // with a radius of 1 line-width larger. This way the stroke won't look like it hangs off the edge. 😆
        emptyStrokeLayer = CAShapeLayer()
        emptyStrokeLayer.frame = layer.frame
        emptyStrokeLayer.fillColor = .none
        emptyStrokeLayer.strokeColor = emptyStrokeColor.cgColor
        emptyStrokeLayer.path = CGPath(ellipseIn: square, transform: nil)
        emptyStrokeLayer.lineWidth = strokeLayer.lineWidth
        
        // An inset square
        let innerSquare = CGRect(
            origin: CGPoint(x: square.origin.x + strokeLayer.lineWidth / 2, y: square.origin.y + strokeLayer.lineWidth / 2),
            size: CGSize(width: square.size.width - strokeLayer.lineWidth, height: square.size.height - strokeLayer.lineWidth)
        )
        
        
        fillLayer = CAShapeLayer()
        fillLayer.frame = layer.frame
        fillLayer.path = CGPath(ellipseIn: innerSquare, transform: nil)
        fillLayer.fillColor = fillColor?.cgColor

        _progressLayer = strokeLayer
        
        return _progressLayer!
        
    }
    
    
    
    override func layoutSubviews() {
        
        if progressLayer.superlayer == nil {
            
            if tapGesture == nil {
                tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:) ) )
                self.addGestureRecognizer(tapGesture!)
            }
            
            
            // Grey empty stroke first
            layer.addSublayer(emptyStrokeLayer)
            
            // Then a fill, slightly smaller
            layer.addSublayer(fillLayer)
            
            // Then our colored stroke
            layer.addSublayer(progressLayer)
            
            print("Layer frame: \(layer.frame), bounds: \(layer.bounds)")
            print("Adding sublayer. frame: \(progressLayer.frame), bounds: \(progressLayer.bounds)")
            print("Empty Path. frame: \(emptyStrokeLayer.frame), bounds: \(emptyStrokeLayer.bounds)")

        }
        
        
    }
    
    
}

/**
 Animation delegate for rewinding
*/
extension FlexTimerView: CAAnimationDelegate {

    /**
     Reversing animation
    */
    var rewindAnimation: CABasicAnimation {
        
        let rewindAnimation = CABasicAnimation(keyPath: "strokeEnd")
        rewindAnimation.duration = 0.3
        rewindAnimation.fillMode = .removed
        rewindAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut )
        rewindAnimation.fromValue = 1
        rewindAnimation.toValue = 0
        rewindAnimation.autoreverses = false
        
        return rewindAnimation
    }
    
    /**
     Listen for this event to add the reverse animation upon completion
    */
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag == true {
            // rewind
            print("Completion")
            
            progressLayer.add(rewindAnimation, forKey: "strokeEnd")

            
        }
    }
}

extension FlexTimerView {
    
    @objc
    func tap(_ gesture: UITapGestureRecognizer) {
        print("tapped")
        
        if flexTimer.state != .running {
            print("Animation duration: \(animation.duration)")
            
            // Start the timer
            flexTimer.start()
            
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
            progressLayer.pauseAnimation()
        }
        

    }
}
