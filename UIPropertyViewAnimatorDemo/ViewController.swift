//
//  ViewController.swift
//  UIPropertyViewAnimatorDemo
//
//  Created by John Kulimushi on 15/08/2018.
//  Copyright © 2018 John Kulimushi. All rights reserved.
//

import UIKit

enum Side {
    case Left,Right
}

class ViewController: UIViewController {
    
    var animator:UIViewPropertyAnimator!
    
    var currentSide:Side = .Left
    let boxWidth:CGFloat = 100
    let initialXOrigin:CGFloat = 10
    
    var initialFrame:CGRect = .zero
    var finalFrame:CGRect = .zero
    
    var finalXOrigin:CGFloat{
        return width - (boxWidth + initialXOrigin)
    }
    
    var width:CGFloat{
        return view.frame.width
    }
    
    lazy var  movingView:UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        return view
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        
        //Adding pan gesture recognizer to the orange view
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(moveView))
        movingView.addGestureRecognizer(gesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        
        initialFrame = createFrame(withXOrigin: initialXOrigin)
        finalFrame = createFrame(withXOrigin: finalXOrigin)
        
        movingView.frame = initialFrame
        view.addSubview(movingView)
    }
    
    private func createFrame(withXOrigin x:CGFloat)->CGRect{
        let yOrigin:CGFloat = self.view.frame.midY - 50
        return CGRect(x: x, y: yOrigin,
               width: boxWidth, height: boxWidth)
    }
    
    func initAnimator(){
        animator = UIViewPropertyAnimator(duration: 1, dampingRatio: 0.6, animations: {[weak self] in
            guard let this = self else { return }
            switch this.currentSide{
            case .Left:
                this.movingView.frame = this.finalFrame
            case .Right:
                this.movingView.frame = this.initialFrame
            }
        })
        
        animator.isInterruptible = true
        animator.startAnimation()

    }
    
    
    @objc fileprivate func moveView(gesture: UIPanGestureRecognizer){
        
        let xTranslation = gesture.translation(in: movingView).x
        
        switch gesture.state {
        case .began:
            initAnimator()
            //we start the animation but we can't interact with it...as soon as the user starts the pan gesture
            //the view will animate normally like for the click to its final position (the position that we set in the animation block)
            //This makes sure that when the user initiates the gesture,the latter pauses immediately and wait for the change.
            animator.pauseAnimation()
        case .changed:
            let fraction = abs(xTranslation) / finalXOrigin
            animator.fractionComplete = fraction
        case .ended:
            finish(withTranslation: xTranslation)
        default:
            print("unhandled state")
        }
        
    }
    
    private func finish(withTranslation xTranslation:CGFloat){
        let threshold:CGFloat = currentSide == .Left ? width / 3 : -width / 3

        if xTranslation > threshold {
            
            self.animator.isReversed = currentSide == .Left ? false : true
            completeAnimation(basedOnCurrentSide: .Right)
            
        }else if xTranslation < threshold {
            
            self.animator.isReversed = currentSide == .Left ? true : false
            completeAnimation(basedOnCurrentSide: .Left)
        }
        
        animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
    
    private func completeAnimation(basedOnCurrentSide side:Side){
        animator.addCompletion {[weak self] position in
            guard let this = self else { return }
            if this.currentSide != side{
                this.currentSide = this.currentSide == .Right ? .Left : .Right
            }
        }
    }
}








































