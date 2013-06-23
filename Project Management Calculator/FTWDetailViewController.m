//
//  FTWDetailViewController.m
//  Project Management Calculator
//
//  Created by Ade on 6/10/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "FTWDetailViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Math.h"

@interface FTWDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSMutableArray *numberList;
@property (strong, nonatomic) NSMutableArray *operatorList;
@property NSInteger *previousNumber;
@property NSInteger *currentNumber;
@property bool operandPressed;
@property int numTimesClearPressed;

- (void)configureView;
@end

@implementation FTWDetailViewController

@synthesize lblDetailDescription;
@synthesize operatorList;
@synthesize numberList;
@synthesize previousNumber;
@synthesize currentNumber;
@synthesize operandPressed;
@synthesize numTimesClearPressed;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}



- (IBAction)numberButtonPressed:(UIButton*)button {
    NSString *operand = [[NSString alloc] init];
    double num = 0;
    static double numBeforeEqualPressed = 0;
    numTimesClearPressed = 0;
    
    if (button.tag < 10)
    {
        //If there has just been an operand pressed, we want to make sure that we don't erase all the contents of the display label until the user clicks on a number, than we will delete all the contents.  We set operandPressed to false so that we don't keep deleting the contents of the label every time the user clicks on the number button.
        if (operandPressed)
        {
            lblDetailDescription.text = @"";
        }
        //if this is a number than simply add the number to the integer.  If it's a decimal than check if there is already a decimal there and if not add the point.
        lblDetailDescription.text = [NSString stringWithFormat:@"%@%ld",lblDetailDescription.text, (long)button.tag];
        operandPressed = false;
        numBeforeEqualPressed = [lblDetailDescription.text doubleValue];
    }
    else if (button.tag == 10)
    {
        if ([lblDetailDescription.text rangeOfString:@"."].location == NSNotFound)
        {
            lblDetailDescription.text = [NSString stringWithFormat:@"%@.",lblDetailDescription.text];
        }
    }   
    if (button.tag > 10)       //Addition
    {
        //If the user is continuing to press an operand button without changing the number than we continue to perform the operation using the number that was first inserted
        if (!operandPressed && button.tag != 14)
        {
            [numberList addObject: [NSNumber numberWithFloat:[lblDetailDescription.text doubleValue]]];
        }
        if (button.tag == 16)       //Negative/Positive
        {
            num = [[numberList objectAtIndex:[numberList count]-1] doubleValue] * -1;
            lblDetailDescription.text = [NSString stringWithFormat:@"%g", num];
            [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
        }
        else if (button.tag == 11)      //Plus
        {
            [operatorList addObject:@"+"];
            operand = @"+";
        }
        else if (button.tag == 12)      //Minus
        {
            [operatorList addObject:@"-"];
            operand = @"-";
        }
        else if (button.tag == 13)      //Multiply
        {
            [operatorList addObject:@"*"];
            operand = @"*";
        }
        else if (button.tag == 15)      //Divide
        {
            [operatorList addObject:@"/"];
            operand = @"/";
        }
        else if (button.tag == 22)      //Square Root
        {
            [operatorList addObject:@"sqrt"];
            operand = @"sqrt";
            operandPressed = false;
        }
        else if (button.tag == 14)      //Equals
        {
            //If we press equal than we keep performing whatever the correct operator is
            operand = [operatorList objectAtIndex:[operatorList count] - 1];
            [numberList addObject:[NSNumber numberWithFloat:numBeforeEqualPressed]];
            operandPressed = false;
        }
        else if (button.tag == 20)
        {
            num = [[numberList objectAtIndex:[numberList count]-1] doubleValue] / 100;
            lblDetailDescription.text = [NSString stringWithFormat:@"%g", num];
            [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
        }
        if (([numberList count] > 1 && operandPressed != true) || [operand isEqualToString:@"sqrt"])
        {
            if ([operand isEqualToString:@"+"])
            {
                num = [[numberList objectAtIndex:[numberList count]-1] doubleValue] + [[numberList objectAtIndex:[numberList count]-2] doubleValue];
            }
            if ([operand isEqualToString:@"-"])
            {
                num = [[numberList objectAtIndex:[numberList count]-2] doubleValue] - [[numberList objectAtIndex:[numberList count]-1] doubleValue];
            }
            if ([operand isEqualToString:@"*"])
            {
                num = [[numberList objectAtIndex:[numberList count]-1] doubleValue] * [[numberList objectAtIndex:[numberList count]-2] doubleValue];
            }
            if ([operand isEqualToString:@"/"])
            {
                num = [[numberList objectAtIndex:[numberList count]-2] doubleValue] / [[numberList objectAtIndex:[numberList count]-1] doubleValue];
            }
            if ([operand isEqualToString:@"sqrt"])
            {
                num = sqrt([[numberList objectAtIndex:[numberList count]-1] doubleValue]);
            }
            
            lblDetailDescription.text = [NSString stringWithFormat:@"%g", num];
            [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
        }
        operandPressed = true;
    }
}

- (IBAction)copyToClipboard:(id)sender {
    UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
    
    appPasteBoard.persistent = YES;
    
    [appPasteBoard setValue:operatorList forPasteboardType:(NSString *)UIPasteboardTypeListString];
}

- (IBAction)btnClearPressed:(id)sender {
    
    numTimesClearPressed++;
    
    if (numTimesClearPressed == 1)
    {
        lblDetailDescription.text = @"";
    }
    else if (numTimesClearPressed == 2)
    {
        numberList = [[NSMutableArray alloc] init];
        operatorList = [[NSMutableArray alloc] init];
        numTimesClearPressed = 0;
    }
    
}



- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.lblDetailDescription.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad
{
    numberList = [[NSMutableArray alloc] init];
    operatorList = [[NSMutableArray alloc] init];
    numTimesClearPressed = 0;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


@end
