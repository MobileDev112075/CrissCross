//
//  CreateSuggViewController.swift
//  crisscross2.0
//
//  Created by Daniel Karsh on 12/3/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit

class CreatePlanViewController: UIViewController{
    
    @IBAction func backTap(sender: UIButton) {
            self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBOutlet weak var surePlan: UIButton!
    @IBOutlet weak var ifPlan: UIButton!
    
    @IBAction func sureTP(sender: AnyObject) {
        MainSection.createPlanType =  AppPlanType.AppPlanTypeSure
    }
    
    @IBAction func ifTP(sender: AnyObject) {
        MainSection.createPlanType =  AppPlanType.AppPlanTypeIf
    }
}
