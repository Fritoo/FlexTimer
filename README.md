# FlexTimer
## Miles Alden - June 14th, 2021 
### for Flex

Hello Flex Team!

My initial approach was to create this timer with an eye towards an `MVVM` architecture. This could pretty simply be done in SwiftUI, but since SwiftUI has a deployment target of iOS 13 I thought it might be nicer to include users
from earlier OS' & devices. This project has three major components:

- `FlexTimer`, our own rolled timer functionally similar to `Timer` (aka, `NSTimer`) which leverages `RunLoops` but gives us more control over pausing, starting, stopping, incremental callouts and completion callouts.
- `QuartzCore`, using `CAShapeLayers` to draw our paths, `CABasicAnimations` to interpolate between keyframe states, `CAMediaTiming` to allow for pause/resume a layer's animations. This is preferable to using only `drawRect` and maintaining animation and interpolation between values and states.
- `UIKit`, using `UIView` as a parent class, we're able to bind together our color selection, gesture recognizers, quartz layers, timing duration & timer-states/animation-states.

I've always been a fan of community components that have very little runway or user configuration and that was the intent here. 

This `FlexTimerView` only needs to be added to a superview to immediately function and provides an optional `onChange` callback for external objects to respond to.
