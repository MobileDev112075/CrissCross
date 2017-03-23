//
//  AppFullScreenViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 10/3/15.
//  Copyright © 2015 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppFullScreenViewController : AppViewController<UIScrollViewDelegate>{
    UIImageView *_imageView;
    UIScrollView *_scrollView;
}

@property (nonatomic,strong) NSString *imageURL;
@property (nonatomic,strong) NSString *pageTitle;


@end
