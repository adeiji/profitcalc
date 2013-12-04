//
//  FTWCoreDataSingleton.h
//  SalesManagementCalculator
//
//  Created by Ade on 12/3/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTWCoreDataSingleton : NSObject <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (id) sharedCoreDataObject;
- (NSFetchedResultsController *) insertDate;
- (NSFetchedResultsController *) fetchedResultsController;
- (void) clearAll;

+ (void) SaveContext : (NSString *) calculationString
          dateString : (NSString *) dateString
             Context : (NSManagedObjectContext *) context;

@end
