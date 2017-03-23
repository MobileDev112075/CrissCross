//
//  VTImagePicker.h
//  VTuscano
//
//  Created by Vincent Tuscano on 5/29/14.
//  Copyright (c) 2014 Tuscano Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VTImagePicker;
@protocol VTImagePickerDelegate <NSObject>
@optional
- (void)imagePickedForAvatar:(UIImage *)image;
- (void)imagePickedForAvatarPreview:(UIImage *)image;
@end

@interface VTImagePicker : NSObject<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(strong,nonatomic) UIViewController *delegateViewController;


-(void)presentPhotoPicker;
- (void)pickFromLibrary;
- (void)pickFromCamera;

@end
