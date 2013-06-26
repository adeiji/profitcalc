//
//  FTWDetailViewController.h
//  Project Management Calculator
//
//  Created by Ade on 6/10/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTWDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

/*
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
    PERCENTAGE
} OperandType;
*/
@property (weak, nonatomic) IBOutlet UILabel *lblDetailDescription;
- (IBAction)numberButtonPressed:(UIButton *)button;
- (IBAction)copyToClipboard:(id)sender;
- (IBAction)btnClearPressed:(id)sender;
- (IBAction)costButtonPressed:(UIButton*)button;
- (IBAction)salebuttonPressed:(UIButton*)button;
- (IBAction)marginButtonPressed:(UIButton *)button;
- (IBAction)memoryButtonPressed:(UIButton *)button;

@end
