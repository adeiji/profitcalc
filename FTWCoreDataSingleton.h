//
//  FTWCoreDataSingleton.h
//  SalesManagementCalculator
//
//  Created by Ade on 12/3/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTWCoreDataSingleton : NSObject

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
