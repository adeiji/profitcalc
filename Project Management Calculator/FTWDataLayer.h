//
//  FTWDataLayer.h
//  Profit Management Calculator
//
//  Created by Ade on 9/3/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTWDataLayer : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (NSObject*) init : (NSManagedObjectContext *) managedObjectContext;
- (void) SaveContext : (NSString *) calculationString
          dateString : (NSString *) dateString;

@end
