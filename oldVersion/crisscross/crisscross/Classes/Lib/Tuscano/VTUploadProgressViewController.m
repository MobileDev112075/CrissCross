//
//  VTUploadProgressViewController.m
//  Freebee
//
//  Created by Vincent Tuscano on 9/10/14.
//  Copyright (c) 2014 Ravn. All rights reserved.
//

#import "VTUploadProgressViewController.h"

@interface VTUploadProgressViewController ()

@end

@implementation VTUploadProgressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _progressView.progress = 0;
    
}

-(void)progressUpdated:(NSNotification *)note{
    
    NSString *event = [note.object objectForKey:@"event"];

    if([event isEqualToString:@"starting"]){
        self.view.hidden = NO;
        _progressView.progress = 0;
    }else if([event isEqualToString:@"finished"]){
        self.view.hidden = YES;
        
        
    }else if([event isEqualToString:@"progress"]){
        self.view.hidden = NO;
        
        long long totalBytesWritten = [[note.object objectForKey:@"totalDone"] longLongValue];
        long long totalBytesExpectedToWrite = [[note.object objectForKey:@"total"] longLongValue];
        float percent = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        
        _progressView.progress = percent;
        
        if(percent >= 1){

        }else{

        }
        
    }
}

@end
