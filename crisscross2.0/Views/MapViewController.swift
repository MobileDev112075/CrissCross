//
//  MapViewController.swift
//  
//
//  Created by Daniel Karsh on 11/30/16.
//
//

import UIKit


class MapViewController: UIViewController {

    var exMapView:UIView?
    
    @IBOutlet weak var mapView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let exmap = self.exMapView{
            exmap.layer.cornerRadius = 18
            exmap.frame = self.mapView.bounds
            exmap.center = CGPoint(x: self.view.center.x, y: exmap.center.y)
            exmap.opaque = false
            exmap.clipsToBounds = true
            self.mapView.addSubview(exmap)
        }
      
        // Do any additional setup after loading the view.
    }

    func addMapView(view:UIView){
        self.exMapView = view
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
