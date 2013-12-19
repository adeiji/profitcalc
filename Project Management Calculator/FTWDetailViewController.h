//
//  FTWDetailViewController.h
//  Project Management Calculator
//
//  Created by Ade on 6/10/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FTWMasterViewController.h"

@interface FTWDetailViewController : UIViewController <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) id detailItem;

typedef enum
{
    MULTIPLICATION,
    ADDITION,
    SUBTRACTION,
    DIVISION,
    SQUARE,
    SQUAREROOT,
    EQUALS,
    OPPOSITE,
    PERCENTAGE,
    NOOPERAND,
    PERCENTPLUS,
    PERCENTMINUS,
    PERCENTPLUSEQUALS,
    PERCENTMINUSEQUALS,
    PERCENTPLUSNUM,
    PERCENTPLUSNUMEQUALS
} OperandType;

typedef enum
{
    OPERANDPRESSEDLAST,
    EQUALSPRESSEDLAST,
    NEWOPERATION,
    NUMBERENTEREDLAST,
    PERCENTAGEPRESSEDLAST,
    MEMORYBUTTONPRESSEDLAST
} states;

typedef enum
{
    DECIMALBUTTON = 10,
    ADDITIONBUTTON = 11,
    MINUSBUTTON = 12,
    MULTIPLICATIONBUTTON = 13,
    EQUALSBUTTON = 14,
    DIVISIONBUTTON = 15,
    OPPOSITEBUTTON = 16,
    MEMORYADDBUTTON = 17,
    MEMORYREMOVEBUTTON = 18,
    MEMORYCLEARBUTTON = 19,
    PERCENTAGEBUTTON = 20,
    CLEARBUTTON = 21,
    SQUAREROOTBUTTON = 22,
    SELMARBUTTON = 23,
    COSTSELBUTTON = 24,
    COSTMARBUTTON = 25,
    SELCOSTBUTTON = 26,
    MARSELBUTTON = 27,
    MARCOSTBUTTON = 28
} OperandButton;

@property (strong, nonatomic) IBOutlet UILabel *lbliPhoneDetailDescription;
@property (strong, nonatomic) IBOutlet UILabel *lbliPhoneNumberType;
@property (strong, nonatomic) IBOutlet UILabel *lbliPhoneMemory;

@property (strong, nonatomic) UILabel *lblDetailDescription;
@property (strong, nonatomic) UILabel *lblNumberType;
@property (strong, nonatomic) UILabel *lblMemory;
@property (strong, nonatomic) IBOutlet UILabel *lblPortraitNumberType;
@property (strong, nonatomic) IBOutlet UILabel *lblPortraitMemory;
@property (strong, nonatomic) IBOutlet UILabel *lblLandscapeNumberType;
@property (strong, nonatomic) IBOutlet UILabel *lblLandscapeMemory;
@property (strong, nonatomic) IBOutlet UINavigationItem *topNavigationBariPad;

- (IBAction)numberButtonPressed:(UIButton *)button;
- (IBAction)copyToClipboard:(id)sender;
- (IBAction)btnClearPressed:(id)sender;
- (IBAction)costButtonPressed:(UIButton*)button;
- (IBAction)salebuttonPressed:(UIButton*)button;
- (IBAction)marginButtonPressed:(UIButton *)button;
- (IBAction)memoryButtonPressed:(UIButton *)button;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)helpButtonPressed:(id)sender;
- (IBAction)clearAll:(id)sender;

@property (strong, nonatomic) FTWMasterViewController *calculationsTable;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *landscapeTableView;
@property (strong, nonatomic) IBOutlet UITableView *portraitTableView;


@property (strong, nonatomic) IBOutlet UIButton *helpButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;
@property (strong, nonatomic) IBOutlet UIView *subOperandViews;
@property (strong, nonatomic) IBOutlet UIView *mainOperandViews;
@property (strong, nonatomic) IBOutlet UIView *functionViews;
@property (strong, nonatomic) IBOutlet UIView *numberViews;
@property (strong, nonatomic) IBOutlet UIButton *equalsButton;
@property (strong, nonatomic) IBOutlet UILabel *lblPortraitDetailDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblLandscapeDetailDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *heightWidthConstraints;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *mainFunctionButtons;

@property (strong, nonatomic) UIView *landscapeView;
@property (strong, nonatomic) IBOutlet UIView *portraitView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property (strong, nonatomic) IBOutlet NSObject *topLayoutGuideline;


@end
