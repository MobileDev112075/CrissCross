//
//  AppBeenThere.h
//  crisscross
//
//  Created by Vincent Tuscano on 6/10/15.
//  Copyright (c) 2015 RAVN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppBeenThere : NSObject

@property(nonatomic,strong) NSString *itemId;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *itemTitle;
@property(nonatomic,strong) NSString *img;
@property(nonatomic,strong) NSString *sortKey;
@property(nonatomic,strong) NSString *customImg;
@property(nonatomic,strong) NSString *locationsId;
@property(nonatomic,strong) NSMutableArray *items;
@property(nonatomic,strong) NSArray *allIds;

@property(nonatomic,strong) NSMutableArray *disabledTops;
@property(nonatomic,strong) NSMutableArray *disabledChilds;
@property(nonatomic,assign) BOOL disabledChecked;

@property(nonatomic,assign) int rating;
@property(nonatomic,assign) int categoryId;
@property(nonatomic,strong) NSString *comment;

@property(nonatomic,assign) BOOL showExpanded;
@property(nonatomic,assign) BOOL communityItem;
@property(nonatomic,assign) BOOL animateIn;

@property(nonatomic,assign) BOOL isOwnerPage;

@property(nonatomic,assign) BOOL isAChild;
@property(nonatomic,assign) BOOL isStubItem;
@property(nonatomic,assign) BOOL isUserUploadedImage;


@property(nonatomic,assign) int topIdx;
@property(nonatomic,assign) int childIdx;
@property(nonatomic,assign) int selectedCategoryId;


@property(nonatomic,strong) NSMutableArray *searchableCategoryIds;

-(float) returnExpandedHeight;
-(AppBeenThere *)initWithDictionary:(NSDictionary *)dict;
-(void)setAsOwnerItem:(BOOL)val;
+(NSArray *)returnCategories;

@end
