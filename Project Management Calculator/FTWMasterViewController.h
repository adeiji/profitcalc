//
//  FTWMasterViewController.h
//  Project Management Calculator
//
//  Created by Ade on 6/10/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FTWDetailViewController;

#import <CoreData/CoreData.h>

@interface FTWMasterViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) FTWDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (IBAction)gotoCalculator:(id)sender;
- (IBAction)clearAll:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSObject *topLayoutGuideline;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBarOutlet;

@end
