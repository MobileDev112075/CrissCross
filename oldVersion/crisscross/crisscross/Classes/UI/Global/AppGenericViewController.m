//
//  AppGenericViewController.m
//  crisscross
//
//  Created by Vincent Tuscano on 1/21/16.
//  Copyright © 2016 RAVN. All rights reserved.
//

#import "AppGenericViewController.h"

@interface AppGenericViewController ()

@end

@implementation AppGenericViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self layoutUI];
}


-(void)layoutUI{
    
    if(!_didLayout){
        _didLayout = YES;
        _topnav.view.width = self.view.width;
        _topnav.theTitle.text = [NSString returnStringObjectForKey:@"title" withDictionary:_pageInfo];
    

        NSString *pageType = [[NSString returnStringObjectForKey:@"genericType" withDictionary:_pageInfo] uppercaseString];

        if([pageType isEqualToString:@"TERMS"] || [pageType isEqualToString:@"PRIVACY"]){
            [self loadPageType:pageType];
        }else if([pageType isEqualToString:@"FAQ"] || [pageType isEqualToString:@"SUPPORT"]){

        }else{
            _text1 = [[UITextView alloc] initWithFrame:CGRectMake(0, _topnav.view.maxY + 5, roundf(self.view.width * 0.90), self.view.height - (_topnav.view.maxY + 5) )];
            NSString *desc = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sit amet justo justo. Duis maximus vitae urna id placerat. Cras id luctus nunc, at feugiat massa. In quam felis, maximus eget est ut, consectetur sagittis nisi. Proin pellentesque lectus orci, at lobortis lacus lobortis vel. Fusce vulputate quis arcu a vehicula. Duis ut convallis nisi. Praesent lorem erat, semper vitae consectetur id, hendrerit eget eros. Donec sit amet odio sagittis nisl rutrum sagittis.\n\nAliquam a est scelerisque, facilisis quam ut, finibus neque. Duis volutpat gravida eros. Nulla elit nisi, placerat ac lectus ut, mattis tempus enim. Sed facilisis dictum ipsum, non sodales arcu ultrices pretium. Nulla facilisi. Nam pretium purus et metus eleifend aliquam. Suspendisse mollis est vel rutrum ultricies.\n\nNunc vitae eros ut elit consequat fermentum. Nulla est quam, porta eu vulputate ac, molestie ac lacus. Donec posuere sem sit amet ligula commodo, ac porta nulla congue. Sed eu ex maximus, fringilla turpis vitae, rhoncus turpis. In sed erat placerat, euismod sapien in, tristique turpis. Curabitur dignissim est eu urna condimentum tincidunt. Phasellus lacinia mi non consequat ornare. Morbi eu neque accumsan, sagittis urna cursus, laoreet metus. Curabitur dapibus ultricies varius. Proin accumsan volutpat lacus non pulvinar. Fusce blandit gravida velit, quis efficitur velit pharetra ut. Cras bibendum pretium sapien eget fermentum.\n\nNulla elementum laoreet cursus. Cras eget magna quam. Nam lorem enim, iaculis nec feugiat sit amet, imperdiet sit amet elit. Duis eu nunc ligula. Vestibulum porttitor orci at ex suscipit ultricies. Praesent ut felis diam. Curabitur ut odio eleifend, sagittis eros sit amet, consectetur odio. Mauris non lobortis tellus. Nam aliquet orci porta, porta velit vitae, lobortis risus. Ut massa nisi, malesuada sed aliquam nec, convallis vitae purus.\n\nNulla finibus libero vel enim sodales interdum. Fusce suscipit, magna vel pharetra dapibus, tellus nisl dignissim ligula, in aliquam dui nulla sed nulla. Cras et odio sollicitudin, pretium augue id, scelerisque ligula. Quisque congue quam ex, non ornare turpis dignissim at. Nunc bibendum, orci id facilisis ullamcorper, felis turpis euismod nulla, vel ornare sapien nisi vitae enim. Pellentesque ut elit tempus, vulputate lorem id, dignissim lacus. Etiam volutpat eros molestie sodales consequat. Etiam finibus, sapien ut rutrum rutrum, ipsum elit interdum lectus, at finibus quam velit eget sapien. Vivamus eget sem nulla. Proin faucibus finibus gravida.\n\nPraesent vitae turpis at tortor suscipit varius. Mauris mattis quam et interdum dapibus. Integer mollis, ligula et ultricies ultricies, eros sapien vulputate ligula, et imperdiet sapien turpis ut arcu. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Proin in suscipit quam. Pellentesque vel lorem et nisi hendrerit lacinia. Integer blandit at magna eu commodo.\n\nAenean tempus non odio ac gravida. Morbi venenatis tincidunt dui, id elementum tellus aliquet faucibus. Phasellus ligula eros, egestas a rhoncus in, tempor ac orci. Fusce cursus risus risus, et ultricies justo euismod at. Pellentesque gravida diam a nulla gravida, in porta metus facilisis. Ut sollicitudin lacus sit amet elit interdum, et fringilla purus vestibulum. Praesent a vehicula ligula. Fusce fringilla dictum hendrerit. Duis sagittis dignissim mi eu volutpat. Morbi ornare vel mi quis fermentum.\n\nInteger ac feugiat velit. Ut sapien nisl, bibendum at ultricies id, tincidunt in dui. Praesent lectus urna, vulputate sed felis at, malesuada ullamcorper est. Nulla dictum, metus eu porttitor commodo, nisi sapien imperdiet leo, quis volutpat ante justo ac nibh. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque pellentesque venenatis lorem. Duis in dictum dui, pellentesque ullamcorper nunc. Etiam in ex sit amet tortor consectetur interdum non blandit erat. Donec sodales magna nec elit bibendum pharetra. Integer et dui pharetra mi eleifend mollis at ut erat. Quisque eleifend arcu quis est pharetra posuere. Integer luctus, neque quis congue placerat, dui velit varius libero, id efficitur dui ante eu magna. Suspendisse id elementum lectus. Praesent imperdiet egestas elit, pretium aliquam metus aliquam imperdiet. Fusce aliquam arcu in neque tempus facilisis.\n\nPhasellus dignissim lobortis libero, tempus egestas mi pretium eget. Morbi porta nibh metus, id cursus lorem efficitur ac. Donec sodales urna et lectus egestas hendrerit. Morbi aliquam porta sem nec tempus. Aenean dui elit, ultricies sed tortor eleifend, dapibus dignissim ipsum. Nam condimentum euismod odio, sit amet faucibus lorem congue eget. Sed et enim est. Sed semper vestibulum dui, at posuere erat. Integer aliquet massa at enim finibus lacinia.\n\nMauris vel diam sed felis porttitor posuere. Ut eu lectus nisi. Donec nec urna massa. Cras elementum mollis ex quis semper. Nunc porttitor quis felis quis consequat. Phasellus accumsan purus mi, vel accumsan neque varius dapibus. Aenean ultricies nibh et purus faucibus, sed molestie eros blandit. Ut aliquet orci sit amet diam suscipit, sed hendrerit sem hendrerit. Duis cursus, metus sed dictum imperdiet, mi tellus bibendum lectus, nec consequat metus eros sit amet risus. Donec varius justo quis consequat elementum. Pellentesque fringilla nisi justo, id volutpat diam condimentum egestas. Ut non sem nibh.";
            
            float fontSize1 = 14;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.minimumLineHeight = fontSize1;
            paragraphStyle.maximumLineHeight = fontSize1 * 1.15;
            _text1.attributedText = [[NSAttributedString alloc] initWithString:desc
                                                                    attributes:@{
                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                 NSParagraphStyleAttributeName : paragraphStyle,
                                                                                 NSFontAttributeName:[UIFont fontWithName:FONT_HELVETICA_NEUE size:fontSize1]}];
            
            _text1.backgroundColor = [UIColor clearColor];
            _text1.x = roundf(self.view.width/2 - _text1.width/2);
            _text1.showsVerticalScrollIndicator = NO;
            _text1.scrollEnabled = YES;
            _text1.editable = NO;
            _text1.textColor = [UIColor whiteColor];
            [self.view addSubview:_text1];
            
        }
        
    }
    
}

-(void)loadPageType:(NSString *)type{
    
    _loadingScreen = [VTUtils buildAnimatedLoadingViewWithMessage:@"" andColor:nil withDelay:0];
    _loadingScreen.alpha = 1;
    [self.view addSubview:_loadingScreen];
    
    NSMutableDictionary *dict = [AppAPIBuilder APIDictionary];
    [dict setObject:type forKey:@"type"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [AppAPIBuilder APIAcceptableContentTypes];
    
    
    [manager POST:[AppAPIBuilder APIForGetPrivacyOrTerms:nil] parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [_loadingScreen removeFromSuperview];
        responseObject = [VTUtils processResponse:responseObject];
        if([VTUtils isResponseSuccessful:responseObject]){
            
            _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, _topnav.view.maxY + 5, roundf(self.view.width * 0.95), self.view.height - (_topnav.view.maxY + 5) )];
            
            NSString *desc = [NSString returnStringObjectForKey:@"data" withDictionary:responseObject];
            
            [_webView loadHTMLString:desc baseURL:nil];
            _webView.backgroundColor = [UIColor clearColor];
            _webView.tintColor = [UIColor whiteColor];
            [_webView setOpaque:NO];
            _webView.delegate = self;
            _webView.x = roundf(self.view.width/2 - _webView.width/2);
            [self.view addSubview:_webView];
            
            
        }else{
            [[AppController sharedInstance] alertWithServerResponse:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingScreen removeFromSuperview];
        [[AppController sharedInstance] showAlertWithTitle:@"Connection Failed" andMessage:@"Unable to make request, please try again."];
    }];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[AppController sharedInstance] showWebBrowserWithURLString:[[request URL] absoluteString]];
        return NO;
    }
    return YES;
}


@end
