//
//  FlexTimerView.swift
//  FlexTimer
//
//  Created by Miles Alden on 6/13/21.
//

import UIKit
import CoreGraphics


/**
 This is our view, bound in an MVVM style to a `FlexTimer` instance and its layers
*/
class FlexTimerView: UIView {

    /**
     Callback format for external object responses
    */
    typealias OnChangeCallback = (FlexTimer.State) -> Void
    
    /**
     A callback that can be registered for external components to receive change events
    */
    var onChange: OnChangeCallback? = nil
    
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

            resetAll()
        }
    }
    
    /**
     Reload the timer and reset all layers
    */
    func resetAll() {
        flexTimer = FlexTimer(length: duration)
        resetLayers()
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
     Lazy loaded `strokeEnd` animation.
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
            strokeAnimation.setValue("forward", forKey: "animationID")

            _animation = strokeAnimation
            return _animation!
        }
        
    }
    

    /**
     The bar layer as it fills
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
        
        // An optional color-layer fill
        fillLayer = CAShapeLayer()
        fillLayer.frame = layer.frame
        fillLayer.path = CGPath(ellipseIn: innerSquare, transform: nil)
        fillLayer.fillColor = fillColor?.cgColor

        _progressLayer = strokeLayer
        
        return _progressLayer!
        
    }
    
    
    
    override func layoutSubviews() {
        
        if progressLayer.superlayer == nil {
            
            // Add the tap gesture
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
        rewindAnimation.delegate = self
        rewindAnimation.setValue("rewind", forKey: "animationID")
        
        return rewindAnimation
    }
    
    /**
     Listen for this event to add the reverse animation upon completion
    */
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag == true {
            
            // Manage transitions between our animations
            switch anim.value(forKey: "animationID") as? String {
                case "forward":
                    // rewind
                    print("Completion")
                    
                    progressLayer.add(rewindAnimation, forKey: "strokeEnd")
                    
                    // Inform others
                    onChange?(flexTimer.state)
                    break
                    
                // Prepare timer, animation and layers to start over
                case "rewind":
                    // Trigger a reset of timer & layers
                    resetAll()
                    break
                    
                default:
                    // Do nothin
                    break
            }

            
        }
    }
}


