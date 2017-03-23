//
//  CalendarViewController.swift
//  crisscross2.0
//
//  Created by daniel karsh on 12/26/16.
//  Copyright © 2016 tycoon. All rights reserved.
//

import UIKit
import Result
import ReactiveCocoa
import RSKImageCropper

class CreateSuggSecViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,RSKImageCropViewControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    private let viewModel:CreateSuggSecModel
    private var imp:VTImagePicker?
    private var imc:RSKImageCropViewController?
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = CreateSuggSecModel(store:Shared.MyInfo.store)
        super.init(coder:aDecoder)
    }
    
    deinit {
        print("D >>>> deinit >>>>> \(String(self)) <<<<<<")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView() // Prevent empty rows at bottom
        tableView.reloadData()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.active <~ isActive()
    
        viewModel.addPhotoSelect.0
            .observeOn(UIScheduler())
            .observeNext {[weak self]  () in
                self?.imp = VTImagePicker()
                self?.imp!.delegateViewController = self
                self?.imp!.presentPhotoPicker()
        }
        

        
        viewModel.stopEditing.0
            .observeOn(UIScheduler())
            .observeNext {[weak self]  () in
                self?.view.endEditing(true)
        }
        
        viewModel.contentChangesSignal
            .observeOn(UIScheduler())
            .observeNext({ [weak self] changeset in
                guard let tableView = self?.tableView else { return }
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths(changeset.deletions, withRowAnimation: .Fade)
                tableView.reloadRowsAtIndexPaths(changeset.modifications, withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths(changeset.insertions, withRowAnimation: .Fade)
                tableView.endUpdates()
                })
        
        MainSection.planSavedResult.0
            .observeOn(UIScheduler())
            .observeNext {[weak self]  _ in
                MainSuggSection.showSections.swap([])
                    self?.dismissViewControllerAnimated(false, completion: {
                })
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.viewModel.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.viewModel.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.viewModel.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 {
            if MainSuggSection.showSections.value.contains(10) {
                MainSuggSection.showSections.swap([0,1,2,3,4])
            }
        }
    }
    
    func imagePickedForAvatar(image: UIImage!) {
        self.imc = RSKImageCropViewController(image: image, cropMode:.Square)
        self.imc?.delegate = self
        self.presentViewController(imc!, animated: true) {
        }
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        controller.dismissViewControllerAnimated(true, completion: {
            
        })
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        self.viewModel.photoSelected.swap(croppedImage)
        controller.dismissViewControllerAnimated(true, completion: {
        })
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.viewModel.photoSelected.swap(croppedImage)
        controller.dismissViewControllerAnimated(true, completion: {
        })
    }

}
