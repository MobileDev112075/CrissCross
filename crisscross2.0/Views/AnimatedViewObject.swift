//
//  AnimatedViewObject.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 11/30/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import pop

class AnimatedViewObject:NSObject,UIViewControllerAnimatedTransitioning
{
   
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
        fromView.tintAdjustmentMode = .Dimmed
        fromView.userInteractionEnabled = false
        
        let dimmingView = UIView(frame: fromView.bounds)
        dimmingView.backgroundColor = UIColor(red: 84/255, green:  84/255, blue:  84/255, alpha: 1)
        dimmingView.layer.opacity = 0.0
        
        let toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
        toView.frame = CGRectMake(0, 0, CGRectGetWidth(transitionContext.containerView().bounds) - 50, CGRectGetHeight(transitionContext.containerView().bounds) - 100)
        fromView.tintAdjustmentMode = .Dimmed
        fromView.center = CGPointMake(transitionContext.containerView().center.x, -transitionContext.containerView().center.y)
        
        transitionContext.containerView().addSubview(dimmingView)
        transitionContext.containerView().addSubview(toView)
        
        let positionAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPositionY)
        
        positionAnimation.toValue = transitionContext.containerView().center.y
        positionAnimation.springBounciness = 10
        positionAnimation.completionBlock  = { _ in
            transitionContext.completeTransition(true)
        }
        
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation.springBounciness = 20
        scaleAnimation.fromValue = NSValue(CGPoint: CGPointMake(1.2, 1.4))
        let opacityAnimation = POPSpringAnimation(propertyNamed: kPOPLayerOpacity)
        opacityAnimation.toValue = 0.2
        
        toView.layer.pop_addAnimation(positionAnimation, forKey: "positionAnimation")
        toView.layer.pop_addAnimation(scaleAnimation, forKey: "scaleAnimation")
        dimmingView.layer.pop_addAnimation(opacityAnimation, forKey: "opacityAnimation")
        
    }
}

