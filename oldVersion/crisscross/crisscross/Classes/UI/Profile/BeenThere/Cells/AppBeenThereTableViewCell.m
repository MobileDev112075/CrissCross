//
//  AppBeenThereTableViewCell.m
//  crisscross
//
//  Created by Vincent Tuscano on 4/20/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppBeenThereTableViewCell.h"
#import "MGSwipeButton.h"

#define kAppStaticCellNameBeenThereCell @"kAppStaticCellNameBeenThereCell"

@implementation AppBeenThereTableViewCell

- (void)awakeFromNib {
    _items = [[NSMutableArray alloc] init];
    _itemsInView  = [[NSMutableArray alloc] init];
    self.clipsToBounds = YES;
    _dimAlpha = 0.35;
    _itemImage.clipsToBounds = YES;
    _topButtons = [[NSMutableArray alloc] init];
    _childButtons = [[NSMutableArray alloc] init];
    _sectionOffset = 0;
    _btnBackstop = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_btnBackstop addTarget:self action:@selector(deadTap) forControlEvents:UIControlEventTouchUpInside];
    _topButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _childButtonsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _thinLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _currentSelectedCategoryId = @"";
    _options = [AppBeenThere returnCategories];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setupWithBeenThere:(AppBeenThere *)beenThere topOffset:(float)offset{
    _beenThere = beenThere;
    _sectionOffset = offset;
    _items = _beenThere.items;
    [_itemImage cancelImageRequestOperation];
    _itemImage.image = nil;
    [_itemImage setImageWithURL:[NSURL URLWithString:_beenThere.img] placeholderImage:nil];
    _itemTitle.text = _beenThere.title;
    
    _tableView.height = [AppController sharedInstance].screenBoundsSize.height - _tableView.y - 68 + _sectionOffset;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView reloadData];
    [self layoutOptions];
    [self checkWhatShouldBeDisabled];
}


-(void)layoutOptions{
    int btnHeight = 42;
    float totalWidth = [AppController sharedInstance].screenBoundsSize.width;
    [_topButtons removeAllObjects];
    [_childButtons removeAllObjects];
    [_topButtonsView removeAllSubviews];
    [_childButtonsScrollView removeAllSubviews];
    _childButtonsScrollView.hidden = YES;
    _topButtonsView.width = totalWidth;
    _topButtonsView.height = btnHeight + 6;
    _topButtonsView.y = _itemImage.maxY + 10;
    _topButtonsView.x = 0;

    _btnBackstop.width = [AppController sharedInstance].screenBoundsSize.width;
    _btnBackstop.y = _topButtonsView.y;
    _btnBackstop.height = _topButtonsView.maxY - _btnBackstop.y;
    [self.contentView insertSubview:_btnBackstop belowSubview:_topButtonsView];
    
    [self.contentView addSubview:_topButtonsView];
    [self.contentView addSubview:_childButtonsScrollView];
    
    _thinLine.frame = CGRectMake(0, _topButtonsView.y, 0.5, btnHeight);
    [self.contentView addSubview:_thinLine];
    _thinLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    _thinLine.alpha = 0;
    int padding = 5;
    int pillWidth = (totalWidth/[_options count]) - ([_options count] * padding/2);
    int startingX = 15;
    int count = 0;
    for(NSDictionary *dict in _options){
        UIButton *pill = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, pillWidth, btnHeight)];
        [pill setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
        pill.layer.borderWidth = 1;
        [pill setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
        [pill setTitleColor:[UIColor colorWithHexString:COLOR_CC_BLUE_BG] forState:UIControlStateSelected];
        pill.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:16];
        pill.titleLabel.adjustsFontSizeToFitWidth = YES;
        pill.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2].CGColor;
        pill.layer.cornerRadius = 8;
        pill.tag = count++;
        pill.enabled = YES;
        [pill addTarget:self action:@selector(pillActuallyTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_topButtonsView addSubview:pill];
        [_topButtons addObject:pill];
        startingX += pill.width + padding;
    }


}
-(void)deadTap{

}

-(void)layoutChildOptions:(NSArray *)options{

    int firstPossible = -1;
    int btnHeight = 42;
    int idx = 0;
    [_childButtons removeAllObjects];
    _childButtonsScrollView.hidden = NO;
    [_childButtonsScrollView removeAllSubviews];
    
    
    _childButtonsScrollView.x = _topSelectedButton.width + 25;
    float totalWidth = [AppController sharedInstance].screenBoundsSize.width - _childButtonsScrollView.x;
    _childButtonsScrollView.width = totalWidth;
    _childButtonsScrollView.height = _topButtonsView.height;
    _childButtonsScrollView.y = _topButtonsView.y;
    
    [self.contentView addSubview:_childButtonsScrollView];
    
    
    
    int padding = 3;
    int pillWidth = (totalWidth/[_options count]) - ([_options count] * padding/2);
    int startingX = 0;

    for(NSDictionary *dict in options){
        UIButton *pill = [[UIButton alloc] initWithFrame:CGRectMake(startingX, 0, pillWidth, btnHeight)];
        [pill setTitle:[NSString returnStringObjectForKey:@"title" withDictionary:dict] forState:UIControlStateNormal];
        pill.layer.borderWidth = 1;
        [pill setTitleColor:[UIColor colorWithHexString:COLOR_CC_TEAL] forState:UIControlStateNormal];
        [pill setTitleColor:[UIColor colorWithHexString:COLOR_CC_BLUE_BG] forState:UIControlStateSelected];
        pill.titleLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE_MED size:16];
        pill.titleLabel.textAlignment = NSTextAlignmentCenter;
        pill.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [pill sizeToFit];
        pill.height = btnHeight;
        pill.width += 25;
        if(pill.width < pillWidth)
            pill.width = pillWidth;
        
        pill.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2].CGColor;
        pill.layer.cornerRadius = 8;
        pill.tag = [[NSString returnStringObjectForKey:@"id" withDictionary:dict] intValue];
        [pill addTarget:self action:@selector(childPillActuallyTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_childButtonsScrollView addSubview:pill];
        [_childButtons addObject:pill];
        startingX += pill.width + padding;
        
        if(!_isOwner){
            if([_beenThere.disabledChilds containsObject:[NSNumber numberWithInt:(int)pill.tag]]){
                pill.selected = NO;
                pill.alpha = _dimAlpha;
                pill.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2].CGColor;
            }else{
                if(firstPossible == -1){
                    firstPossible = idx;
                }
                pill.alpha = 1;
            }
        }else{
            pill.alpha = 1;
        }
        
        idx++;
    }
    
    [_childButtonsScrollView setContentSize:CGSizeMake(startingX + 10, _childButtonsScrollView.height)];
    [_childButtonsScrollView setContentOffset:CGPointMake(0, 0)];
    float endingX = _childButtonsScrollView.x;
    _childButtonsScrollView.x = [AppController sharedInstance].screenBoundsSize.width;
    _childButtonsScrollView.alpha = 0;
    _thinLine.x = endingX - 5;
    _thinLine.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _childButtonsScrollView.x = endingX;
        _childButtonsScrollView.alpha = 1;
        _thinLine.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];

    _tableView.height = [AppController sharedInstance].screenBoundsSize.height - _tableView.y - 68 + _sectionOffset;
    [_tableView reloadData];
    
}

-(void)checkWhatShouldBeDisabled{
    return;
    
}




-(void)pillActuallyTapped:(UIButton *)btn{
    
    
    if(btn.alpha < 1){
        return;
    }
    _doAnimation = YES;
    _doAdjust = NO;
     [self pillTapped:btn];
    

}

-(void)pillTapped:(UIButton *)btn{
    
    if(btn.selected){
        
        for(UIButton *b in _topButtons){
            b.selected = NO;
            b.hidden = NO;
            b.backgroundColor = [UIColor clearColor];
            b.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2].CGColor;
            
        }
        [_beenThere.searchableCategoryIds removeAllObjects];

        _thinLine.alpha = 0;
        _childButtonsScrollView.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            _topButtonsView.x = 0;
        } completion:^(BOOL finished) {
            
        }];
        [_tableView reloadData];
        return;
    }
    
    for(UIButton *b in _topButtons){
        b.selected = NO;
        b.hidden = YES;
        b.backgroundColor = [UIColor clearColor];
        b.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2].CGColor;
    }
    
    int idx = (int)btn.tag;

    
    [_beenThere.searchableCategoryIds removeAllObjects];
    
    NSDictionary *dict = [_options objectAtIndex:idx];
    NSArray *children = [[_options objectAtIndex:idx] objectForKey:@"children"];
    
    [_beenThere.searchableCategoryIds addObject:[NSNumber numberWithInt:[[NSString returnStringObjectForKey:@"id" withDictionary:dict] intValue]]];
    for(NSDictionary *dict in children){
        [_beenThere.searchableCategoryIds addObject:[NSNumber numberWithInt:[[NSString returnStringObjectForKey:@"id" withDictionary:dict] intValue]]];
    }

    btn.hidden = NO;
    btn.selected = YES;
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
    [_tableView reloadData];
    _topSelectedButton = btn;
    

    if(_doAnimation){
        [UIView animateWithDuration:0.2 animations:^{
            _topButtonsView.x = -btn.x + 15;
        } completion:^(BOOL finished) {

            NSArray *children = [[_options objectAtIndex:idx] objectForKey:@"children"];
            [self layoutChildOptions:children];
            _currentSelectedTopName = [[_options objectAtIndex:idx] objectForKey:@"title"];
            
        }];
    }
    _doAnimation = NO;
}




-(void)childPillActuallyTapped:(UIButton *)btn{
    
    if(btn.alpha < 1){
        return;
    }
    _doAdjust = NO;
    [self childPillTapped:btn];
}

-(void)childPillTapped:(UIButton *)btn{
    
    if(btn.selected){
        btn.selected = NO;
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2].CGColor;

        _beenThere.searchableCategoryIds = _lastTopLevelSelectedIds;
        [_tableView reloadData];
        return;
    }
    int idx = (int)btn.tag;
    
    for(UIButton *b in _childButtons){
        b.selected = NO;
        b.backgroundColor = [UIColor clearColor];
        b.layer.borderColor = [[UIColor colorWithHexString:COLOR_CC_TEAL] colorWithAlphaComponent:0.2].CGColor;
    }
    
    btn.selected = YES;
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
    _currentSelectedCategoryId = [NSString stringWithFormat:@"%d",idx];
    _currentSelectedCategoryName = btn.titleLabel.text;
    
//    _beenThere.childIdx = (int)[_childButtons indexOfObject:btn];
    _beenThere.selectedCategoryId = [_currentSelectedCategoryId intValue];
    
    _lastTopLevelSelectedIds = [NSMutableArray arrayWithArray:_beenThere.searchableCategoryIds];
    [_beenThere.searchableCategoryIds removeAllObjects];
    [_beenThere.searchableCategoryIds addObject:[NSNumber numberWithInt:idx]];
    [_tableView reloadData];
    
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_BTDT_DO_HIDE_SEARCH_CAUSE_OF_SCROLL object:nil];
}



#pragma mark TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    

    if([_beenThere.searchableCategoryIds count] > 0){

        NSPredicate *p = [NSPredicate predicateWithFormat:@"categoryId IN %@",_beenThere.searchableCategoryIds];

        _itemsInView = [NSMutableArray arrayWithArray:[_items filteredArrayUsingPredicate:p]];

    }else{
        _itemsInView = [NSMutableArray arrayWithArray:_items];
    }

    
    if(!_beenThere.communityItem && _isOwner){
        if([_itemsInView count] > 0){
            AppBeenThere *btFirst = [_itemsInView firstObject];
            if(!btFirst.isStubItem){
                AppBeenThere *bt = [[AppBeenThere alloc] initWithDictionary:@{@"placeholder":@"Y"}];
                bt.isAChild = YES;
                [_itemsInView insertObject:bt atIndex:0];
            }
        }else{
            AppBeenThere *bt = [[AppBeenThere alloc] initWithDictionary:@{@"placeholder":@"Y"}];
            bt.isAChild = YES;
            [_itemsInView insertObject:bt atIndex:0];
        }
        
    }
    
    if(!_itemsInView)
        return 0;
    return [_itemsInView count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tableView dequeueReusableCellWithIdentifier:kAppStaticCellNameBeenThereCell];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAppStaticCellNameBeenThereCell];
    }
    
    AppBeenThere *bt = [_itemsInView objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if(bt.isStubItem){
        cell.rightButtons = @[];
        cell.delegate = self;
        cell.textLabel.textColor = [UIColor colorWithHexString:COLOR_CC_TEAL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if(_beenThere.animateIn){
            
        }
    }else{
        
        cell.textLabel.textColor = [UIColor whiteColor];
        if(!_beenThere.communityItem && _beenThere.isOwnerPage){
            cell.rightButtons = @[ [MGSwipeButton buttonWithTitle:@"" andIcon:@"A" backgroundColor:[UIColor colorWithHexString:COLOR_CC_GREEN] withHeight:60.0] ];
            cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
            cell.delegate = self;
        }else{
            cell.rightButtons = @[];
        }
    }
    
    cell.backgroundColor = [UIColor colorWithHexString:COLOR_CC_BLUE_BG];
    cell.textLabel.font = [UIFont fontWithName:FONT_HELVETICA_NEUE size:15];
    [[cell viewWithTag:100] removeFromSuperview];
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    line.tag = 100;
    [cell addSubview:line];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = bt.itemTitle;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppBeenThere *bt = [_itemsInView objectAtIndex:indexPath.row];
    if(_beenThere.communityItem)
        bt.communityItem = YES;
    
    if(bt.isStubItem){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_BEEN_THERE_ITEM object:@{@"top":_beenThere,@"is_a_stub":@"Y"}];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_BEEN_THERE_ITEM object:@{@"top":_beenThere,@"child":bt}];
    }
    
}

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    if(_beenThere.communityItem)
        return NO;
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        
        NSIndexPath * path = [_tableView indexPathForCell:cell];
        AppBeenThere *bt = [_itemsInView objectAtIndex:path.row];
        [_itemsInView removeObjectAtIndex:path.row];
        [_items removeObject:bt];
        [_tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DELETE_BEEN_THERE_CHILD object:bt];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADD_BEEN_THERE_ITEM_RELOAD object:_beenThere];
        return NO;
    }
    return YES;
}





@end
