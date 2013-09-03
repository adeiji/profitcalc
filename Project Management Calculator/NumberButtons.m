//
//  NumberButtons.m
//  Project Management Calculator
//
//  Created by Ade on 6/10/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "NumberButtons.h"

@implementation NumberButtons

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect drawRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect)-5, CGRectGetHeight(rect)-5);
    CGFloat radius = 5;
    CGFloat minX = CGRectGetMinX(drawRect), midX = CGRectGetMidX(drawRect), maxX = CGRectGetMaxX(drawRect);
    CGFloat minY = CGRectGetMinY(drawRect), midY = CGRectGetMidY(drawRect), maxY = CGRectGetMaxY(drawRect);
    
    {
        //for the shadow, save the state and then draw the shadow
        CGContextSaveGState(context);
        
        //Start from the upper left
        CGContextMoveToPoint(context, minX, midY);
        
        // Add an arc through 2 to 3
        CGContextAddArcToPoint(context, minX, minY, midX, minY, radius);
        // Add an arc through 4 to 5
        CGContextAddArcToPoint(context, maxX, minY, maxX, midY, radius);
        // Add an arc through 6 to 7
        CGContextAddArcToPoint(context, maxX, maxY, midX, maxY, radius);
        // Add an arc through 8 to 9
        CGContextAddArcToPoint(context, minX, maxY, minX, midY, radius);
        // Close the path
        CGContextClosePath(context);
        CGContextSetShadow(context, CGSizeMake(1, rect.size.width / 60), rect.size.width / 100);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.49 green:0.514 blue:0.514 alpha:1.0].CGColor);
        
        // Fill & stroke the path
        CGContextDrawPath(context, kCGPathFillStroke);
        
        //for the shadow
        CGContextRestoreGState(context);
    }
    
    //Start from the upper left
    CGContextMoveToPoint(context, minX, midY);
    
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minX, minY, midX, minY, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxX, minY, maxX, midY, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxX, maxY, midX, maxY, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minX, maxY, minX, midY, radius);
    // Close the path
    CGContextClosePath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.49 green:0.514 blue:0.514 alpha:1.0].CGColor);
   // CGContextSetRGBFillColor(context, 0.8, 0.851, .875, 1.0);
    CGContextSetFillColorWithColor(context, self.titleLabel.shadowColor.CGColor);
    
    // Fill & stroke the path
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetLineWidth(context, rect.size.width / 100);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.42 green:0.455 blue:0.451 alpha:1.0].CGColor);
    CGContextMoveToPoint(context, minX + 5, maxY);
    CGContextAddLineToPoint(context, maxX, maxY);
    CGContextSetLineWidth(context, rect.size.width / 200);
    CGContextAddLineToPoint(context, maxX, minY + 5);
    CGContextStrokePath(context);
}
 */

@end
