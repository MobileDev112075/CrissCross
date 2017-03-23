//
//  AppFullScreenViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 10/3/15.
//  Copyright © 2015 RAVN. All rights reserved.
//

#import "AppFullScreenViewController.h"

@interface AppFullScreenViewController ()

@end

@implementation AppFullScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc] init];
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.view.backgroundColor = [UIColor blackColor];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}


-(void)layoutUI{
    
    if(_didLayout)
        return;
    
    _didLayout = YES;
    _topnav.view.width = self.view.width;
    _topnav.theTitle.text = _pageTitle;
    
   
    
    _scrollView.y = _topnav.view.maxY;
    _scrollView.width = self.view.width;
    _scrollView.height = self.view.height - _scrollView.y;
    
    _imageView.width = _scrollView.width;
    _imageView.height = _scrollView.height;
    
    [_scrollView addSubview:_imageView];
    
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 6.0;
    _scrollView.contentSize = CGSizeMake(_scrollView.width, _scrollView.height );
    _scrollView.delegate = self;
    
    __weak UIImageView *iv = _imageView;
    [_imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_imageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        iv.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

    }];
    
    [self.view addSubview:_scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return _imageView;
    
}


@end
