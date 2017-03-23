//
//  AppGenericViewController.h
//  crisscross
//
//  Created by Vincent Tuscano on 1/21/16.
//  Copyright © 2016 RAVN. All rights reserved.
//

#import "AppViewController.h"

@interface AppGenericViewController : AppViewController<UIWebViewDelegate>{
    UITextView *_text1;
    UIWebView *_webView;
}


@property(nonatomic,strong) NSDictionary *pageInfo;


@end
