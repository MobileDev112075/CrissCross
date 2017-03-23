//
//  DPCalendarMonthlyCell.m
//  DPCalendar
//
//  Created by Ethan Fang on 19/12/13.
//  Copyright (c) 2013 Ethan Fang. All rights reserved.
//

#import "DPCalendarMonthlySingleMonthCell.h"
#import "DPCalendarIconEvent.h"
#import "NSDate+DP.h"
#import "DPConstants.h"
#import "NSString+DP.h"

@interface DPCalendarMonthlySingleMonthCell()

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *iconEvents;

@end

@implementation DPCalendarMonthlySingleMonthCell

#define DAY_TEXT_RIGHT_MARGIN 6.0f

#define ROW_MARGIN 1.0f
#define EVENT_START_MARGIN 1.0f
#define EVENT_END_MARGIN 1.0f
#define EVENT_TITLE_MARGIN 2.0f

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCell:)];
        tapGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

-(void)setDate:(NSDate *)date calendar:(NSCalendar *)calendar events:(NSArray *)events iconEvents:(NSArray *)iconEvents {
    self.date = [calendar dateFromComponents:[calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date]];
    self.events = events;
    self.iconEvents = iconEvents;
    self.calendar = calendar;

    [self setNeedsDisplay];
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

-(void)setIsInSameMonth:(BOOL)isInSameMonth {
    _isInSameMonth = isInSameMonth;
    [self setNeedsDisplay];
}

-(void) didTapCell:(UITapGestureRecognizer *)gesutreRecognizer {
    CGPoint point = [gesutreRecognizer locationInView:self];
    NSDate *day = self.date;
    for (DPCalendarEvent *event in self.events) {
        if (event.rowIndex == 0) {
            continue;
        }
        CGFloat eventOriginY = event.rowIndex * self.rowHeight;
        CGFloat eventMaxY = eventOriginY + self.rowHeight;
        if ((point.y >= eventOriginY) && (point.y < eventMaxY)) {
            [self.delegate didTapEvent:event onDate:day];
            break;
        }
    }

}

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //Draw borders
    CGFloat pixel = 1.f / [UIScreen mainScreen].scale;
    CGSize size = rect.size;
    CGRect internalRect = CGRectMake(0, 0, size.width - pixel, size.height);
    
    //Draw background colors
    if (self.isSelected || self.isPreviousSelectedCell) {
        [self drawCellWithColor:self.selectedColor InRect:internalRect context:context];
    } else if (!self.isInSameMonth) {
        [self drawCellWithColor:self.noInSameMonthColor InRect:internalRect context:context];
    } else {
        [self drawCellWithColor:[UIColor clearColor] InRect:internalRect context:context];
    }
    
    [super drawRect:rect];
    
    
    //Right Border
    DPContextDrawLine(context,
                      CGPointMake(size.width - pixel, pixel),
                      CGPointMake(size.width - pixel, size.height),
                      self.separatorColor.CGColor,
                      pixel);
    
    //Bottom Border
    DPContextDrawLine(context,
                      CGPointMake(0.f, self.bounds.size.height),
                      CGPointMake(self.bounds.size.width, self.bounds.size.height),
                      self.separatorColor.CGColor,
                      pixel);
    
    //Top Border if necessary
    if (self.isFirstRow) {
        DPContextDrawLine(context,
                          CGPointMake(0.f, pixel),
                          CGPointMake(self.bounds.size.width, pixel),
                          self.separatorColor.CGColor,
                          pixel);
    }
    
    //Set text style
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentLeft;
    NSStringDrawingContext *stringContext = [[NSStringDrawingContext alloc] init];
    stringContext.minimumScaleFactor = 1;
    
    BOOL isDayToday = [self.date compare:[[NSDate date] dp_dateWithoutTimeWithCalendar:self.calendar]] == NSOrderedSame;
//    isDayToday = NO;
    if (isDayToday) {
        
        CGContextSaveGState(context);
//        CGContextBeginPath(context);
//        [self.todayBannerBkgColor setFill];
//        [self.todayBannerBkgColor setStroke];
//        CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
        
        
        
        CGContextSetStrokeColorWithColor(context,[[UIColor grayColor] colorWithAlphaComponent:0.2].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextAddRect(context, CGRectMake(1, 1, rect.size.width - 2, rect.size.height - 2));
        CGContextStrokePath(context);
        CGContextRestoreGState(context);

        
//        [self drawCellWithColor:self.todayBannerBkgColor InRect:CGRectMake(0, 0, rect.size.width, rect.size.height) context:context];
    }
    
    //Draw Day
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:self.date];
    NSString *dayString = [NSString stringWithFormat:@"%ld", (long)components.day];
    
    CGSize daySize = [dayString dp_boundingRectWithSize:
                                        CGSizeMake(CGFLOAT_MAX, self.dayFont.pointSize + 1)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                     NSFontAttributeName: [UIFont systemFontOfSize:self.dayFont.pointSize]
                                                     
                                                     } context:stringContext].size;
    

    CGRect dayRect = CGRectMake(size.width - daySize.width - DAY_TEXT_RIGHT_MARGIN, (self.rowHeight - self.dayFont.pointSize) / 2, daySize.width, daySize.height);
    
    
    
    int eventsNotShowingCount = 0;

    //Draw Icon events
    float iconX = self.iconEventMarginX;
    for (int i = 0; i < self.iconEvents.count; i++) {
        DPCalendarIconEvent *event = [self.iconEvents objectAtIndex:i];
        CGFloat titleWidth = [event.title dp_boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.iconEventFont.pointSize)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{
                                                           NSFontAttributeName: [UIFont systemFontOfSize:self.iconEventFont.pointSize]
                                                           } context:stringContext].size.width;
        
        BOOL isWidthLonger = event.icon.size.width > event.icon.size.height;
        float iconMaxHeight = self.rowHeight - self.iconEventMarginY * 2;
        float scale = (iconMaxHeight) / (isWidthLonger ? event.icon.size.width : event.icon.size.height);
        float iconWidth = isWidthLonger ? (iconMaxHeight) : event.icon.size.width * scale;
        float iconHeight = isWidthLonger ? event.icon.size.height * scale : (iconMaxHeight);
        
        if (event.title.length) {
            if (iconX + titleWidth + iconWidth> rect.size.width - daySize.width - DAY_TEXT_RIGHT_MARGIN) {
                //Not enough space
            } else {
                [self drawRoundedRect:CGRectMake(iconX, 0, titleWidth + iconWidth + iconHeight, self.rowHeight) radius:self.rowHeight / 2 withColor:[self.iconEventBkgColors objectAtIndex:event.bkgColorIndex]];
                
                NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
                textStyle.lineBreakMode = NSLineBreakByWordWrapping;
                textStyle.alignment = NSTextAlignmentLeft;
                
                [event.title dp_drawInRect:CGRectMake(iconX + iconHeight / 2, (self.rowHeight - self.iconEventFont.pointSize) / 2, titleWidth, self.iconEventFont.pointSize) withAttributes:@{NSFontAttributeName:self.iconEventFont, NSParagraphStyleAttributeName:textStyle, NSForegroundColorAttributeName:[UIColor whiteColor]}];
                
                
                [event.icon drawInRect:CGRectMake(iconHeight / 2 + iconX + titleWidth, (self.rowHeight - iconHeight) / 2, iconWidth, iconHeight)];
                iconX += iconWidth + titleWidth + iconWidth + 2 * iconHeight + self.iconEventMarginX;
            }
        } else {
            if (iconX + iconWidth > rect.size.width - daySize.width - DAY_TEXT_RIGHT_MARGIN) {
                //Not enough space
            } else {
                [event.icon drawInRect:CGRectMake(iconX, (self.rowHeight - iconHeight) / 2, iconWidth, iconHeight)];
                iconX += iconWidth + self.iconEventMarginX;
            }
        }
    }
    
    //Draw Events
//    int count = 0;
    int startingLineY = 16;
    int lineHeight = 5;
    BOOL centerDayText = [AppController sharedInstance].centerCalDayText;
//    int countEvent = 0;
    
    for (DPCalendarEvent *event in self.events) {
        
        NSDate *day = self.date;
        
        UIColor *color = [self.eventColors objectAtIndex:event.colorIndex % self.eventColors.count];

        BOOL conflictFound = NO;
        if ([self.events count] > 1){
            conflictFound = YES;
            if([self.events count] == 2){
                DPCalendarEvent *eventFound1 = [self.events firstObject];
                DPCalendarEvent *eventFound2 = [self.events lastObject];
                
                if([eventFound1.endTime isEqualToDate:eventFound2.startTime]){
                    conflictFound = NO;
                }else if([eventFound1.startTime isEqualToDate:eventFound2.endTime]){
                    conflictFound = NO;
                }
            }
        }
        
        if(conflictFound){
            color = [UIColor redColor];
        }
        
//        if (event.rowIndex == 0 || ((event.rowIndex + 2) * self.rowHeight  > rect.size.height)) {
        
        if ([self.events count] > 3){
            eventsNotShowingCount = (int)[self.events count];
            continue;
        }
        
        
        NSDate *tomorrow = [self.date dateByAddingYears:0 months:0 days:1];
        BOOL isEventEndedToday = [event.endTime compare:tomorrow] == NSOrderedAscending;
        BOOL isEventStartToday = !([event.startTime compare:day] == NSOrderedAscending) || ([event.startTime compare:day] == NSOrderedAscending && [self.date isEqualToDate:self.firstVisiableDateOfMonth]);
        
        float startPosition = isEventStartToday ? EVENT_START_MARGIN : 0;
        float width = isEventStartToday ? (isEventEndedToday ? (size.width - EVENT_START_MARGIN - EVENT_END_MARGIN):(size.width - EVENT_START_MARGIN - pixel) ) : (isEventEndedToday ? (size.width-EVENT_END_MARGIN-pixel) : (size.width-pixel));
        
        
        float startX = startPosition;
        float startXEnding = roundf(width * 0.42);
        
        if (self.eventDrawingStyle == DPCalendarMonthlyViewEventDrawingStyleBar) {
            //Draw Bar
//            [self drawCellWithColor:[color colorWithAlphaComponent:0.2] InRect:CGRectMake(startPosition, event.rowIndex * self.rowHeight + ROW_MARGIN, width, self.rowHeight - ROW_MARGIN) context:context];
            
            
            if(event.doFillWithColor){
                
                [self drawCellWithColor:[[UIColor colorWithHexString:event.fillWithColor] colorWithAlphaComponent:1] InRect:internalRect context:context];
//                [self drawCellWithColor:[[UIColor colorWithHexString:event.fillWithColor] colorWithAlphaComponent:0.2] InRect:CGRectMake(startX, startingLineY + event.rowIndex * lineHeight + ROW_MARGIN, newWidth, 3) context:context];
                
            }else{
                
                //VT CHANGED
                
                float newWidth = width;
                if (isEventStartToday){
                    startX = roundf(width * 0.58);
                    newWidth = width/2;
                }else if (isEventEndedToday){
                    newWidth = width/2;
                }

                [self drawCellWithColor:[color colorWithAlphaComponent:0.2] InRect:CGRectMake(startX, startingLineY + event.rowIndex * lineHeight + ROW_MARGIN, newWidth, 3) context:context];
                
            }
            
            
        } else {

            //Draw Underline
            [self drawCellWithColor:color InRect:CGRectMake(startPosition, (event.rowIndex + 1) * self.rowHeight, width, 0.1f) context:context];
        }
        
        if (isEventEndedToday) {
            //Draw DOT
            if(event.doFillWithColor){
                [self drawCellWithColor:[[UIColor colorWithHexString:event.fillWithColorOn] colorWithAlphaComponent:1] InRect:internalRect context:context];
            }else{
                [self drawCellWithColor:color InRect:CGRectMake(startXEnding, startingLineY + event.rowIndex * lineHeight + ROW_MARGIN, 3, 3) context:context];
               
            }
        }
        
        if (isEventStartToday) {
            //Draw DOT
            if(event.doFillWithColor){
                [self drawCellWithColor:[[UIColor colorWithHexString:event.fillWithColorOn] colorWithAlphaComponent:1] InRect:internalRect context:context];
            }else{
                [self drawCellWithColor:color InRect:CGRectMake(startX, startingLineY + event.rowIndex * lineHeight + ROW_MARGIN, 3, 3) context:context];
                
                
            }
            
            if((0)){
                [self drawCellWithColor:color InRect:CGRectMake(EVENT_START_MARGIN, event.rowIndex * self.rowHeight + ROW_MARGIN, 2, self.rowHeight - ROW_MARGIN) context:context];
                
                
                [[UIColor blackColor] set];
                [event.title dp_drawInRect:CGRectMake(startPosition + 2 +  EVENT_TITLE_MARGIN, event.rowIndex * self.rowHeight + ROW_MARGIN, rect.size.width - EVENT_END_MARGIN, self.rowHeight - ROW_MARGIN) withAttributes:@{NSFontAttributeName:self.eventFont, NSParagraphStyleAttributeName:textStyle, NSForegroundColorAttributeName:[UIColor colorWithRed:67/255.0f green:67/255.0f blue:67/255.0f alpha:1]}];
            }
        }
        
        
        
    }
    if (eventsNotShowingCount > 0) {
        //show more
        [[NSString stringWithFormat:@"%d more...", eventsNotShowingCount] dp_drawInRect:CGRectMake(5, rect.size.height - self.rowHeight, rect.size.width - 5, self.rowHeight - 2) withAttributes:@{NSFontAttributeName:self.eventFont, NSParagraphStyleAttributeName:textStyle, NSForegroundColorAttributeName:[UIColor colorWithRed:67/255.0f green:67/255.0f blue:67/255.0f alpha:1]}];
    }
    
    if(centerDayText){
        dayRect = CGRectMake(size.width/2 - daySize.width/2,size.height/2-daySize.height/2, daySize.width, daySize.height);
        
    }
    

    UIFont *todayFont = self.dayFont;

//    UIFont *todayFont = [UIFont fontWithName:FONT_HELVETICA_NEUE_BOLD size:self.dayFont.pointSize];
    
    
//    [dayString dp_drawInRect:dayRect withAttributes:@{NSFontAttributeName:self.dayFont, NSParagraphStyleAttributeName:textStyle, NSForegroundColorAttributeName:isDayToday ? [UIColor whiteColor] : self.dayTextColor}];
    
    [dayString dp_drawInRect:dayRect withAttributes:@{NSFontAttributeName: isDayToday ? todayFont : self.dayFont, NSParagraphStyleAttributeName:textStyle, NSForegroundColorAttributeName: isDayToday ? [UIColor blackColor] :  self.dayTextColor}];

    
    
    
}

-(void)setIsPreviousSelectedCell:(BOOL)isPreviousSelectedCell {
    _isPreviousSelectedCell = isPreviousSelectedCell;
}

@end
