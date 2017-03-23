//
//  LoginViewController.swift
//  RacCriss
//
//  Created by Daniel Karsh on 10/19/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SnapKit
import GLKit
import SpriteKit
import Spring

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private let viewModel: LoginViewModel
    
    @IBOutlet weak var p1y: NSLayoutConstraint!
    @IBOutlet weak var p1x: NSLayoutConstraint!
    @IBOutlet weak var p2y: NSLayoutConstraint!
    @IBOutlet weak var p2x: NSLayoutConstraint!
    @IBOutlet weak var p1View: UILabel!
    @IBOutlet weak var p2View: UILabel!
    
    @IBOutlet weak var logoView:    SpringView!
    @IBOutlet weak var loginView:   SpringView!
    
    @IBOutlet weak var inputEmail:  UITextField!
    @IBOutlet weak var inputPass:   UITextField!
    @IBOutlet weak var btnForgot:   UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signuButton: UIButton!
    
    private var loginAction: CocoaAction
    
    var selectedForce:      CGFloat = 1
    var selectedDuration:   CGFloat = 1
    var selectedDelay:      CGFloat = 1
    
    var selectedDamping:    CGFloat = 0.7
    var selectedVelocity:   CGFloat = 0.7
    
    var selectedScale:      CGFloat = 1
    var selectedX:          CGFloat = 0
    var selectedY:          CGFloat = 0
    var selectedRotate:     CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel      = LoginViewModel(store:Shared.MyInfo.store)
        self.loginAction    = CocoaAction(viewModel.loginAction, { _ in return () })
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        bindViewModel()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        inputEmail.delegate = self
        inputPass.delegate = self
        
        plainsAnimation()
        animateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == inputEmail){
            inputPass.becomeFirstResponder()
            return false
        }else{
            self.loginAction.execute(true)
            return true
        }
    }
    
    private func bindViewModel() {
        viewModel.active <~ isActive()
        
        self.title = viewModel.title
        self.loginButton.addTarget(self.loginAction,
                                   action:CocoaAction.selector,
                                   forControlEvents:.TouchUpInside)
    

        
        
        viewModel.loginEmail <~ inputEmail.signalProducer()
        viewModel.loginPass  <~ inputPass.signalProducer()
        
        viewModel.tokenIsValid.producer
            .observeOn(UIScheduler())
            .startWithNext({ [weak self] tokenIsValid in
                self?.loginView.hidden = tokenIsValid
                if !(tokenIsValid){
                    self?.inputEmail.becomeFirstResponder()
                }
                })
        viewModel.avatarIsValid.producer.startWithNext { (isValid) in
        }
        
        
        
        viewModel.loginAction.events
            .observeOn(UIScheduler())
            .observeNext({ [weak self] event in
                switch event {
                case let .Next(success):
                    if success {
                        self?.performSegueWithIdentifier("Dashboard", sender:nil)
                    }
                case let .Failed(error):
                    self?.presentErrorMessage(error.localizedDescription)
                default:
                    return
                }}
        )
        
        viewModel.tokenFetchResults
            .observeOn(UIScheduler())
            .observeResult {[weak self] user in
                self?.performSegueWithIdentifier("Dashboard", sender:nil)
        }
        
        
        viewModel.alertMessageSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] alertMessage  in
                let alertController = UIAlertController(
                    title: "title",
                    message: "message",
                    preferredStyle: .Alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self?.presentViewController(alertController, animated: true, completion: nil)
                })
    }
    
    func plainsAnimation() {
        
        p1View.transform = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(GLKMathDegreesToRadians(245.0)) );
        p1x.constant = 100
        p1y.constant = self.view.frame.height
  
        p2View.transform = CGAffineTransformRotate(CGAffineTransformIdentity,CGFloat(GLKMathDegreesToRadians(75)));
        p2x.constant = self.view.frame.width - 100
        p2y.constant = -100
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(40) {
            self.p1x.constant = -100
            self.p1y.constant = 0
            self.p1View.alpha = 0
            self.p2x.constant = self.view.frame.width
            self.p2y.constant = self.view.frame.height
            self.p2View.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func presentErrorMessage(message: String) {
        let alertController = UIAlertController(
            title: "Oops!",
            message: message,
            preferredStyle: .Alert
        )
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func animateView() {
        setOptions()
        setLogoOptions()
        logoView.animateNext {
            self.loginView.animate()
        }
    }
    
    func setLogoOptions() {
        logoView.force = selectedForce
        logoView.duration = selectedDuration
        logoView.delay = selectedDelay
        logoView.damping = selectedDamping
        logoView.velocity = selectedVelocity
        logoView.scaleX = selectedScale
        logoView.scaleY = selectedScale
        logoView.x = selectedX
        logoView.y = selectedY
        logoView.rotate = selectedRotate
        
        logoView.animation = "FadeInUp"
        logoView.curve = "easeOutSine"
    }
    
    
    func setOptions() {
        loginView.force = selectedForce
        loginView.duration = selectedDuration
        loginView.delay = selectedDelay
        loginView.damping = selectedDamping
        loginView.velocity = selectedVelocity
        loginView.scaleX = selectedScale
        loginView.scaleY = selectedScale
        loginView.x = selectedX
        loginView.y = selectedY
        loginView.rotate = selectedRotate
        
        loginView.animation = "squeezeUp"
        loginView.curve = "easeOutSine"
    }
}
