//
//  AppBeenThere.m
//  crisscross
//
//  Created by Vincent Tuscano on 6/10/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import "AppBeenThere.h"

@implementation AppBeenThere

- (id)initWithDictionary:(NSDictionary *)dict{
    self = [self init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _disabledTops = [[NSMutableArray alloc] init];
        _disabledChilds = [[NSMutableArray alloc] init];
        _searchableCategoryIds = [[NSMutableArray alloc] init];

        [self addKeyValueFromDictionary:dict];
    }
    return  self;
}

-(void)addKeyValueFromDictionary:(NSDictionary *)dict{
    
    if([[NSString returnStringObjectForKey:@"placeholder" withDictionary:dict] isEqualToString:@"Y"]){
    
        if([[NSString returnStringObjectForKey:@"overrideTitle" withDictionary:dict] isNotEmpty]){
            _title = [NSString returnStringObjectForKey:@"overrideTitle" withDictionary:dict];
        }else{
            _title = @"+ Add Suggestion";
        }
        
        
        _itemTitle = _title;
        _isStubItem = YES;
        _topIdx = 0;
        _childIdx = 0;
        _selectedCategoryId = 2;
        return;
    }
    _isStubItem = NO;
    _itemId = [NSString returnStringObjectForKey:@"id" withDictionary:dict];
    _title = [NSString returnStringObjectForKey:@"title" withDictionary:dict];
    _itemTitle = [NSString returnStringObjectForKey:@"item_title" withDictionary:dict];
    _img = [NSString returnStringObjectForKey:@"img" withDictionary:dict];
    _customImg = [NSString returnStringObjectForKey:@"custom_img" withDictionary:dict];
    
    _locationsId = [NSString returnStringObjectForKey:@"locations_id" withDictionary:dict];
    _comment = [NSString returnStringObjectForKey:@"comment" withDictionary:dict];
    _rating = [[NSString returnStringObjectForKey:@"rating" withDictionary:dict] intValue];
    _sortKey = [NSString returnStringObjectForKey:@"sort_key" withDictionary:dict];

    _categoryId = [[NSString returnStringObjectForKey:@"category_id" withDictionary:dict] intValue];
    
    _isUserUploadedImage = ([_customImg isNotEmpty]);
        
    _communityItem = [[NSString returnStringObjectForKey:@"communal" withDictionary:dict] isEqualToString:@"Y"];
    [_items removeAllObjects];
    
    _allIds = [NSArray arrayWithArray:[dict objectForKey:@"all_ids"]];
    
    NSArray *children = [NSArray arrayWithArray:[dict objectForKey:@"children"]];
    
    if([children count] > 0){
    
        for(NSDictionary *d in children){
            AppBeenThere *bt = [[AppBeenThere alloc] initWithDictionary:d];
            bt.isAChild = YES;
            [_items addObject:bt];
        }

        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemTitle" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [_items sortedArrayUsingDescriptors:sortDescriptors];
        _items = [NSMutableArray arrayWithArray:sortedArray];
    }
    
    if(_communityItem){
        [_items addObject:[[AppBeenThere alloc] initWithDictionary:@{@"placeholder":@"Y",@"overrideTitle":@"+ Add your own suggestions"}]];
    }
}

+(NSArray *)returnCategories{
    
    return @[
                 @{@"title":@"Eat",@"id":@"1",@"children":
                       @[
                           @{@"title":@"Breakfast",@"id":@"2"},
                           @{@"title":@"Brunch",@"id":@"3"},
                           @{@"title":@"Lunch",@"id":@"4"},
                           @{@"title":@"Dinner",@"id":@"5"},
                           @{@"title":@"Bites",@"id":@"6"}
                           ]},
                 
                 @{@"title":@"Drink",@"id":@"7",@"children":
                       @[
                           @{@"title":@"Coffee & Tea",@"id":@"8"},
                           @{@"title":@"Beer",@"id":@"9"},
                           @{@"title":@"Wine",@"id":@"10"},
                           @{@"title":@"Cocktails",@"id":@"11"}
                           ]},
                 
                 @{@"title":@"See",@"id":@"15",@"children":
                       @[                           
                           @{@"title":@"Sights",@"id":@"19"},
                           @{@"title":@"Secrets",@"id":@"20"},
                           @{@"title":@"Shops",@"id":@"21"},
                           @{@"title":@"Art",@"id":@"22"}
                           
                           ]},
                 
                 @{@"title":@"Sleep",@"id":@"12",@"children":
                       @[
                           @{@"title":@"Hotels",@"id":@"13"},
                           @{@"title":@"Hostels",@"id":@"14"},
                           
                           
                           ]}
                 ];
    

}


-(float) returnExpandedHeight{
    int topScrollItems = 55;
    NSPredicate *p = [NSPredicate predicateWithFormat:@"categoryId IN %@",_searchableCategoryIds];
    NSArray *foundItems = [_items filteredArrayUsingPredicate:p];
    int addOne = (_isOwnerPage) ? 1 : 0;
    if(_communityItem)
        addOne = 0;
        
    return 120.0 + (([foundItems count] + addOne) * 50.0) + topScrollItems;
}

-(void)setAsOwnerItem:(BOOL)val{
    if(val){
        if(_communityItem)
            return;
        _isOwnerPage = YES;
        BOOL found = NO;
        for(AppBeenThere *a in _items){
            if(a.isStubItem){
                found = YES;
                break;
            }
        }
        if(!found){
            AppBeenThere *bt = [[AppBeenThere alloc] initWithDictionary:@{@"placeholder":@"Y"}];
            bt.isAChild = YES;
            [_items insertObject:bt atIndex:0];
        }
    }else{
        for(AppBeenThere *a in _items){
            if(a.isStubItem){
                [_items removeObject:a];
                break;
            }
        }
        _isOwnerPage = NO;
    }
}

@end

