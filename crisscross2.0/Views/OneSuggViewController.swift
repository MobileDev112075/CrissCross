//
//  OneSuggViewController
//  RacCriss
//
//  Created by tycoon on 11/13/16.
//  Copyright © 2016 Daniel Karsh. All rights reserved.
//


import ReactiveCocoa
import GoogleMaps
import Result

class OneSuggViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , GMSMapViewDelegate {// , UICollectionViewDelegate, UICollectionViewDataSource  {
    
    private let feedbackCellIdentifier = "FeedbackCell"
    
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var phtButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var cllButton: UIButton!
    @IBOutlet weak var disButton: UIButton!
    
    @IBOutlet weak var background:          UIImageView!
    @IBOutlet weak var titleLabel:          UILabel!
    @IBOutlet weak var addressLabel:        UILabel!

    @IBOutlet weak var tableView: UITableView!

    
    @IBAction func dissmisBT(sender: UIButton) {
        self.dissmis()
    }
    
    @IBAction func mapTap(sender: AnyObject) {
        self.showMap()
    }
    
    @IBAction func callTap(sender: AnyObject) {
        self.callBusiness()
    }
    
    @IBAction func webTap(sender: AnyObject) {
        self.showWeb()
    }
    
    @IBAction func photoTap(sender: AnyObject) {
        self.showPhoto()
    }
    
    @IBAction func createSugg(sender: AnyObject) {
        
    }
    // The code snippet below shows how to create a GMSPlacePicker
    // centered on Sydney, and output details of a selected place.
    
    private let viewModel: OneSuggViewModel
    let infoMarker = GMSMarker()
    
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = OneSuggViewModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsSelectionDuringEditing = true
        tableView.rowHeight = 140
        tableView.tableFooterView = UIView()
        
        bindViewModel()
    }
    
    //    // MARK: - Bindings
    

    private func bindViewModel() {
        viewModel.active <~ isActive()
        
        self.title = viewModel.title
        self.titleLabel.text = viewModel.title
        self.addressLabel.text = viewModel.address

        let dn_wb = DynamicProperty(object: webButton, keyPath:"hidden")
        let dn_pb = DynamicProperty(object: phtButton, keyPath:"hidden")
        let dn_mb = DynamicProperty(object: mapButton, keyPath:"hidden")
        let dn_cb = DynamicProperty(object: cllButton, keyPath:"hidden")

        dn_wb <~ viewModel.hidebt.producer
        dn_pb <~ viewModel.hidebt.producer
        dn_mb <~ viewModel.hidebt.producer
        dn_cb <~ viewModel.hidebt.producer
                
        
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] _ in
                guard let tableView = self?.tableView else { return }
                    tableView.reloadData()
                    
                })
        
        
        viewModel.alertMessageSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] alertMessage in
                let alertController = UIAlertController(
                    title: "Oops!",
                    message: alertMessage,
                    preferredStyle: .Alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self?.presentViewController(alertController, animated: true, completion: nil)
                })
        
        viewModel.backImage
            .observeOn(UIScheduler())
            .startWithResult({[weak self] in
                switch $0 {
                case let .Success(image):
                    self?.background.image = image
                case .Failure(_):
                    self?.background.image = nil
                }})
    }

    
    
    func refreshControlTriggered()
    {
        viewModel.refreshObserver.sendNext(())
    }
    
    func showMap()
    {
        if let place = MainSuggSection.placeReady.value {
        let camera = GMSCameraPosition.cameraWithLatitude(place.coordinate.latitude, longitude:place.coordinate.longitude, zoom:16)
        let dmapView = GMSMapView.mapWithFrame(.zero, camera: camera)
        
        self.infoMarker.snippet     = place.name
        self.infoMarker.position    = place.coordinate
        self.infoMarker.opacity     = 0.5;
        self.infoMarker.infoWindowAnchor.y = 1
        self.infoMarker.map         = dmapView
        
        dmapView.selectedMarker = self.infoMarker
        dmapView.delegate = self
        
        self.performSegueWithIdentifier("MapOver", sender: dmapView)
        }
    }
    
    func callBusiness()
    {
        let place =  MainSuggSection.placeReady.value!
        if let phone = place.phoneNumber
        {
            let alertController = UIAlertController(title: place.name, message:phone, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "Call", style: .Default) { (action:UIAlertAction!) in
                self.makeCall(phone)
            }
            alertController.addAction(OKAction)
            self.presentViewController(alertController, animated: true, completion:nil)
        }
    }
    
    func makeCall(phone: String)
    {
        let formatedNumber = phone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
        let phoneUrl = "tel://\(formatedNumber)"
        let url:NSURL = NSURL(string: phoneUrl)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func showWeb()
    {
        if let website =  MainSuggSection.placeReady.value!.website
        {
            UIApplication.sharedApplication().openURL(website)
        }
        
    }
    
    func showPhoto()
    {
        
    }
    

    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfMatchesInSection(section)
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(feedbackCellIdentifier, forIndexPath: indexPath) as! FeedbackCell
        cell.viewModel = viewModel.feedbackViewModel(indexPath)
        return cell
    }

    // MARK: UITableViewDelegate
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if viewModel.editMyfeedback(indexPath) {
            self.performSegueWithIdentifier("EditMine", sender: nil)
        }
    }

}

