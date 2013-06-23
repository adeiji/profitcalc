//
//  GradientView.m
//  Inspection Form App
//
//  Created by Developer on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GradientView.h"
#import "QuartzCore/QuartzCore.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t numLocations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { .945, .996, .969, .05, //start color
        .82, .871, .894, 1 }; //End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, numLocations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topLeft = CGPointMake(CGRectGetMinX(currentBounds), 0.0f);
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(currentBounds), CGRectGetMaxY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topLeft, bottomRight, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    //self.layer.shadowColor = [UIColor blackColor].CGColor;
    //self.layer.shadowOpacity = 1.0;
    //self.layer.shadowRadius = 2.0;
    //self.layer.shadowOffset = CGSizeMake(0,3);
    self.clipsToBounds = NO;
    
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = .5;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
