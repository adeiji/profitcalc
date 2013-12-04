//
//  FTWCoreDataSingleton.m
//  SalesManagementCalculator
//
//  Created by Ade on 12/3/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "FTWCoreDataSingleton.h"

@implementation FTWCoreDataSingleton

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

+ (id) sharedCoreDataObject
{
    static FTWCoreDataSingleton *mySharedCoreDataObject = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        mySharedCoreDataObject = [[self alloc] init];
    });
    
    return mySharedCoreDataObject;
}

- (id) init {
    if (self = [super init]) {
        //Get the fetched results controller.
        
    }
    
    return self;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Calculations" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"calculation" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //    abort();
	}
    
    return _fetchedResultsController;
}

- (void) clearAll
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Calculations" inManagedObjectContext:context]];
    
    NSArray * result = [context executeFetchRequest:fetch error:nil];
    
    for (id calculation in result)
    {
        [context deleteObject:calculation];
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

- (void) SaveContext : (NSString *) calculationString
          dateString : (NSString *) dateString
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSManagedObject *calculation;
    calculation = [NSEntityDescription insertNewObjectForEntityForName:@"Calculations" inManagedObjectContext:context];
    
    calculationString = [NSString stringWithFormat:@"%@\n%@", dateString, calculationString];
    
    //Save the tag in the database
    [calculation setValue:calculationString forKey:@"calculation"];
    
    NSError *error;
    
    if (![context save:&error])
    {
        NSLog([NSString stringWithFormat:@"%@", error]);
    }
    else
    {
        NSLog(@"Information Saved");
    }
    
}

@end
