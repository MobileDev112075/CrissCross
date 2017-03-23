//
//  AppBeenThereTableViewCell.h
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface AppBeenThereTableViewCell : MGSwipeTableCell<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>{
    NSMutableArray *_items;
    NSMutableArray *_itemsInView;
    AppBeenThere *_beenThere;
    NSArray *_options;
    UIButton *_btnBackstop;
    UIButton *_topSelectedButton;
    UIView *_topButtonsView;
    UIScrollView *_childButtonsScrollView;
    NSMutableArray *_topButtons;
    NSMutableArray *_childButtons;
    NSString *_currentSelectedCategoryId;
    NSString *_currentSelectedTopName;
    NSString *_currentSelectedCategoryName;
    BOOL _doAdjust;
    float _dimAlpha;
    BOOL _doAnimation;
    NSMutableArray *_lastTopLevelSelectedIds;
    UILabel *_thinLine;
    float _sectionOffset;

}
@property (strong, nonatomic) IBOutlet UIImageView *itemImage;
@property (strong, nonatomic) IBOutlet UILabel *itemTitle;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *shadow;
@property (assign, nonatomic) BOOL isOwner;

-(void)setupWithBeenThere:(AppBeenThere *)beenThere topOffset:(float)offset;

@end
