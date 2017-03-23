

#import "DreamingView.h"
#import "UIView+Additions.h"
#import "NSString+Additions.h"
#import "UIColor+Additions.h"

@interface DreamingView ()
{
    NSMutableArray *_tagsOnScreen;
    BOOL isOwner;
    float yMin;
    float yMax;
    int colorIdx;
    BOOL reloadOnView;
    BOOL isFullyLoaded;
}
@end

@implementation DreamingView

- (void)drawRect:(CGRect)rect {
  _tagsOnScreen = [[NSMutableArray alloc] init];  
}

- (IBAction)re:(id)sender {
    for(UIView *v in _tagsOnScreen){
        [UIView animateWithDuration:0.2 animations:^{
            v.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
            v.y += 40;
        } completion:^(BOOL finished) {
            
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self buildTagCloud:0];
    });
}


-(void)doRefreshTagCloud{
    [self buildTagCloud:0];
}

-(void)buildTagCloud:(int)step{

    yMin = 0.0;
    yMax = 0.0;
    colorIdx = 0;
    
    [_tagCloudView removeAllSubviews];
    [_tagsOnScreen removeAllObjects];
    
    int count = 0;
    int minVal = 16-step;
    if(minVal < 14)
        minVal = 14;
    int maxVal = 50-step;
    

    
    NSArray *colors = @[@"00DBFF",@"30C720",@"FFFFFF"];
    
    float delay = 0.2;

    isFullyLoaded = YES;

    
    for(id dict in _dreams){

        int rndValue = minVal + arc4random() % (maxVal - minVal);

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        NSString *title = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
        NSArray *titleParts = [title componentsSeparatedByString:@","];
        label.text = [NSString stringWithFormat:@"%@",[titleParts firstObject]];
        label.textColor = [UIColor colorWithHexString:[colors objectAtIndex:colorIdx]];
        
        
        if(++colorIdx > [colors count]-1)
            colorIdx = 0;
//        label.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_THIN size:rndValue];
        label.adjustsFontSizeToFitWidth = YES;
        [label sizeToFit];
        if(label.width > self.width){
            label.width = self.width - maxVal;
        }
        if(count == 0){
            label.x = _tagCloudView.width/2 - label.width/2;
            label.y = _tagCloudView.height/2 - label.height/2;
        }
        
        
        if(count > 0){
            UILabel *l;
            if(count == 1){
                l = [_tagsOnScreen lastObject];
            }else{
                l = [_tagsOnScreen objectAtIndex:[_tagsOnScreen count] - 2];
            }
            if(count % 2 == 0){
                label.y = l.maxY - 5;
            }else{
                label.y = l.y - label.height + 5;
            }
            
            label.x = _tagCloudView.width/2 - label.width/2;
            int playArea = (self.width - label.width)/4;
            int rndX = 0;
            if(playArea > 0){
                rndX = arc4random() % playArea;
            }
            
            int positiveNegative =  arc4random() % 2;
            if(positiveNegative == 1)
                label.x += rndX;
            else
                label.x -= rndX;
        }
        [_tagsOnScreen addObject:label];
        [_tagCloudView addSubview:label];
        count++;
        label.alpha = 0;
        
        if(label.y < yMin){
            yMin = label.y;
        }
        
        if(label.maxY > yMax){
            yMax = label.maxY;
        }
        
        
        label.y += 40;
        label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.3, 0.3);
        [UIView animateWithDuration:0.9 delay:delay usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionNone animations:^{
            label.alpha = 1;
            label.y -= 40;
            label.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
        delay += 0.1;
    }
    if(step < 35 && (yMin < 0 || yMax > _tagCloudView.height)){
        [self buildTagCloud:++step];
        
    }else{

    }
}


@end
