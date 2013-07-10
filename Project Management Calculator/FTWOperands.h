//
//  FTWOperands.h
//  Project Management Calculator
//
//  Created by Ade on 7/4/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTWOperands : NSObject

@property (nonatomic) int currentOperand;
@property (nonatomic) int previousOperand;

-(int) currentOperand;
-(int) previousOperand;

@end
