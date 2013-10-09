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

@interface FTWDetailViewController : UIViewController <UISplitViewControllerDelegate>

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

@property (strong, nonatomic) IBOutlet UILabel *lblDetailDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblNumberType;

- (IBAction)numberButtonPressed:(UIButton *)button;
- (IBAction)copyToClipboard:(id)sender;
- (IBAction)btnClearPressed:(id)sender;
- (IBAction)costButtonPressed:(UIButton*)button;
- (IBAction)salebuttonPressed:(UIButton*)button;
- (IBAction)marginButtonPressed:(UIButton *)button;
- (IBAction)memoryButtonPressed:(UIButton *)button;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)helpButtonPressed:(id)sender;

@property (strong, nonatomic) FTWMasterViewController *calculationsTable;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
