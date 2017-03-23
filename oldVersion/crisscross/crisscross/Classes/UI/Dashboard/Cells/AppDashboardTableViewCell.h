//
//  AppDashboardTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 7/5/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BRFlabbyHighlightState){
    BRFlabbyHighlightStateNone,
    BRFlabbyHighlightStateCellAboveTouched,
    BRFlabbyHighlightStateCellBelowTouched,
    BRFlabbyHighlightStateCellTouched
};

@interface AppDashboardTableViewCell : UITableViewCell


@property (assign, nonatomic)                                   CGFloat                 verticalVelocity;
@property (assign, nonatomic, setter = setFlabby:)              BOOL                    isFlabby;
@property (assign, nonatomic, setter = setLongPressAnimated:)   BOOL                    longPressIsAnimated;
@property (copy, nonatomic)                                     UIColor                 *flabbyOverlapColor;
@property (copy, nonatomic)                                     UIColor                 *flabbyColor;
@property (assign, nonatomic)                                   BRFlabbyHighlightState  flabbyHighlightState;
@property (assign, nonatomic)                                   CGFloat                 touchXLocationInCell;
@property (copy, nonatomic)                                     UIColor                 *flabbyColorAbove;
@property (copy, nonatomic)                                     UIColor                 *flabbyColorBelow;

@property (strong, nonatomic) IBOutlet UIImageView *itemImage;


@end
