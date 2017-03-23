//
//  VTImagePicker.m
//  VTuscano
//
//  Created by Vincent Tuscano on 5/29/14.
//  Copyright (c) 2014 Tuscano Studios. All rights reserved.
//

#import "VTImagePicker.h"

@implementation VTImagePicker


- (void)presentPhotoPicker {
    
    [[AppController sharedInstance] hideKeyboard];
    
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *actions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:(@"Use Existing Photo"),(@"Take Photo"),nil];
		actions.tag = 1;
		[actions showInView:_delegateViewController.view];
	} else {
		[self showImagePicker:0];
        
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet.cancelButtonIndex!=buttonIndex) {
		if (actionSheet.tag==1) {
			[self showImagePicker:buttonIndex];
        }
	}
}

- (void)pickFromLibrary{
    [self showImagePicker:0];
}

- (void)pickFromCamera{
    [self showImagePicker:1];
}


- (void)showImagePicker:(NSInteger)buttonIndex {
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	switch (buttonIndex) {
		case 0: {
			cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			break;
		}
		case 1: {
			cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
			cameraUI.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
			break;
		}
		default:
			return;
	}
    
    cameraUI.allowsEditing = NO;
	cameraUI.delegate = self;
	
    [_delegateViewController presentViewController:cameraUI animated:YES completion:nil];
}


#pragma mark - Camera Delegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!img) img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    
    if([_delegateViewController respondsToSelector: @selector(imagePickedForAvatarPreview:)]){
        id vc = _delegateViewController;
        [vc imagePickedForAvatarPreview:img];
    }
    
    
	NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
	if ([mediaType isEqualToString:@"public.image"]){
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            CGRect cropRect;
            cropRect = [[info valueForKey:@"UIImagePickerControllerCropRect"] CGRectValue];
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                cropRect.origin.y+=50;
            }
            //            cropRect.origin.x-=280;
        

            
            UIImage *image = img;
            
            //            UIImage *imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
            //            CGSize finalSize = CGSizeMake(640,640);
            //            UIImage *image = [self cropImage:imagePicked cropRect:cropRect aspectFitBounds:finalSize fillColor:[UIColor clearColor ]];
            
            if([_delegateViewController respondsToSelector: @selector(imagePickedForAvatar:)]){
                id vc = _delegateViewController;
                [vc imagePickedForAvatar:image];
            }
            
        });
        
	} else {
		//get the videoURL
	}
    
    [_delegateViewController dismissViewControllerAnimated:NO completion:nil];
    
}


// CropRect is assumed to be in UIImageOrientationUp, as it is delivered this way from the UIImagePickerController when using AllowsImageEditing is on.
// The sourceImage can be in any orientation, the crop will be transformed to match
// The output image bounds define the final size of the image, the image will be scaled to fit,(AspectFit) the bounds, the fill color will be
// used for areas that are not covered by the scaled image.
-(UIImage *)cropImage:(UIImage *)sourceImage cropRect:(CGRect)cropRect aspectFitBounds:(CGSize)finalImageSize fillColor:(UIColor *)fillColor {
    
    
    CGImageRef sourceImageRef = sourceImage.CGImage;
    
    //Since the crop rect is in UIImageOrientationUp we need to transform it to match the source image.
    CGAffineTransform rectTransform = [self transformSize:sourceImage.size orientation:sourceImage.imageOrientation];
    CGRect transformedRect = CGRectApplyAffineTransform(cropRect, rectTransform);
    //Now we get just the region of the source image that we are interested in.
    CGImageRef cropRectImage = CGImageCreateWithImageInRect(sourceImageRef, transformedRect);
    
    //Figure out which dimension fits within our final size and calculate the aspect correct rect that will fit in our new bounds
    CGFloat horizontalRatio = finalImageSize.width / CGImageGetWidth(cropRectImage);
    CGFloat verticalRatio = finalImageSize.height / CGImageGetHeight(cropRectImage);
    CGFloat ratio = MIN(horizontalRatio, verticalRatio); //Aspect Fit
    CGSize aspectFitSize = CGSizeMake(CGImageGetWidth(cropRectImage) * ratio, CGImageGetHeight(cropRectImage) * ratio);
    
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 finalImageSize.width,
                                                 finalImageSize.height,
                                                 CGImageGetBitsPerComponent(cropRectImage),
                                                 0,
                                                 CGImageGetColorSpace(cropRectImage),
                                                 CGImageGetBitmapInfo(cropRectImage));
    
    if (context == NULL) {

    }
    
    //Fill with our background color
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, finalImageSize.width, finalImageSize.height));
    
    //We need to rotate and transform the context based on the orientation of the source image.
    CGAffineTransform contextTransform = [self transformSize:finalImageSize orientation:sourceImage.imageOrientation];
    CGContextConcatCTM(context, contextTransform);
    
    //Give the context a hint that we want high quality during the scale
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    float a = (finalImageSize.width-aspectFitSize.width)/2;
    float b = (finalImageSize.height-aspectFitSize.height)/2;
    float c = aspectFitSize.width;
    float d = aspectFitSize.height;
    //Draw our image centered vertically and horizontally in our context.
    CGContextDrawImage(context, CGRectMake(a, b, c, d), cropRectImage);
    
    //Start cleaning up..
    CGImageRelease(cropRectImage);
    
    CGImageRef finalImageRef = CGBitmapContextCreateImage(context);
    UIImage *finalImage = [UIImage imageWithCGImage:finalImageRef];
    
    CGContextRelease(context);
    CGImageRelease(finalImageRef);
    return finalImage;
}

//Creates a transform that will correctly rotate and translate for the passed orientation.
//Based on code from niftyBean.com
- (CGAffineTransform) transformSize:(CGSize)imageSize orientation:(UIImageOrientation)orientation {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation) {
        case UIImageOrientationLeft: { // EXIF #8
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI_2);
            transform = txCompound;
            break;
        }
        case UIImageOrientationDown: { // EXIF #3
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI);
            transform = txCompound;
            break;
        }
        case UIImageOrientationRight: { // EXIF #6
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,-M_PI_2);
            transform = txCompound;
            break;
        }
        case UIImageOrientationUp: // EXIF #1 - do nothing
        default: // EXIF 2,4,5,7 - ignore
            break;
    }
    return transform;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_delegateViewController dismissViewControllerAnimated:YES completion:nil];
    
}





@end
