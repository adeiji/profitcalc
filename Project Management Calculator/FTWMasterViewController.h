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
- (IBAction)buttonTouched:(id)sender;
- (IBAction)buttonMoved:(id)sender withEvent:(UIEvent *) event;

@property (strong, nonatomic) IBOutlet UIButton *swipeButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
