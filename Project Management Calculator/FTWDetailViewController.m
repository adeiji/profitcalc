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

@interface FTWDetailViewController ( )
{
    NSMutableArray *numberList;
    NSMutableArray *operatorList;
    NSInteger *previousNumber;
    NSInteger *currentNumber;
    bool operandPressed;
    bool dontAddNumberBeforeEqualPressed;
    int numTimesClearPressed;
    double storedValue;
    bool mrcPressed;
    bool equalPressed;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
@end

@implementation FTWDetailViewController

NSString *const MULTIPLY = @"*";
NSString *const DIVISION = @"/";
NSString *const ADDITION = @"+";
NSString *const SUBTRACTION = @"-";
NSString *const SQUARE = @"square";
NSString *const SQUAREROOT = @"sqrt";
NSString *const PERCENTAGE = @"%";
NSString *const EQUALS = @"=";
NSString *const OPPOSITE = @"-/+";

@synthesize lblDetailDescription;

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

- (void)viewDidLoad
{
    dontAddNumberBeforeEqualPressed = false;
    numberList = [[NSMutableArray alloc] init];
    operatorList = [[NSMutableArray alloc] init];
    numTimesClearPressed = 0;
    storedValue = 0;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
}

//This handles all the unique operands that are possible of creating through various operand selections available on this calculator.
-(NSString *) getSpecialOperand
{
    int count = [operatorList count];
    if (count > 1)
    {
        NSString *operand = [[NSString alloc] initWithFormat:@"%@ %@", [operatorList objectAtIndex:count - 1], [operatorList objectAtIndex:count - 2]];
    
        if ([operand isEqualToString:@"= *"])
        {
            operand = @"square";
            dontAddNumberBeforeEqualPressed = true;
            operandPressed = false;
        }
    
        else if ([operand isEqualToString:@"= +"])
        {
            operand = @"+";
        }
        else if ([operand isEqualToString:@"= ="])
        {
            return [operatorList objectAtIndex:count - 1];
        }
        
        return operand;
    }
    
    return nil;
}

-(NSString *) getOperand : (UIButton *) button : (double) numBeforeEqualPressed;
{
    if (button.tag != 14)
    {
        //Every time we press an operand button, we add that number to the number list
        [numberList addObject:[[NSNumber alloc] initWithDouble:[lblDetailDescription.text doubleValue] ]];
    }
    if (button.tag == 16)       //Negative - Positive
    {
        return OPPOSITE;
    }
    else if (button.tag == 11)      //Plus
    {
        [operatorList addObject:@"+"];
        return ADDITION;
    }
    else if (button.tag == 12)      //Minus
    {
        [operatorList addObject:@"-"];
        return SUBTRACTION;
    }
    else if (button.tag == 13)      //Multiply
    {
        [operatorList addObject:@"*"];
        return MULTIPLY;
    }
    else if (button.tag == 15)      //Divide
    {
        [operatorList addObject:@"/"];
        return DIVISION;
    }
    else if (button.tag == 22)      //Square Root
    {
        [operatorList addObject:@"sqrt"];
        return SQUAREROOT;
    }
    else if (button.tag == 14)      //Equals button pressed
    {
        [operatorList addObject:@"="];
        [numberList addObject:[[NSNumber alloc] initWithDouble:numBeforeEqualPressed ]];
        return EQUALS;
    }
    if (button.tag == 20)      //Percentage button pressed
    {
        [operatorList addObject:@"%"];
        return PERCENTAGE;
    }

    return nil;
}

-(void) updateDisplay:(UIButton*) button
{
    //If there has just been an operand pressed, we want to make sure that we don't erase all the contents of the display label until the user clicks on a number, than we will delete all the contents.  We set operandPressed to false so that we don't keep deleting the contents of the label every time the user clicks on the number button.

    if (operandPressed)
    {
        lblDetailDescription.text = @"";
    }
    if (button.tag < 10)
    {
        //if this is a number than simply add the number to the integer.  If it's a decimal than check if there is already a decimal there and if not add the point.
        lblDetailDescription.text = [NSString stringWithFormat:@"%@%ld",lblDetailDescription.text, (long)button.tag];
    }
    else if (button.tag == 10)
    {
        if ([lblDetailDescription.text rangeOfString:@"."].location == NSNotFound)
        {
            lblDetailDescription.text = [NSString stringWithFormat:@"%@.",lblDetailDescription.text];
        }
    }
    
    operandPressed = false;
}

- (IBAction)numberButtonPressed:(UIButton*)button {
    NSString *operand = [[NSString alloc] init];
    static double numBeforeEqualPressed = 0;
    numTimesClearPressed = 0;
    bool performOperation;
    
    mrcPressed = false;
    
    if (button.tag <= 10)
    {
        [self updateDisplay:button];
        numBeforeEqualPressed = [lblDetailDescription.text doubleValue];
    }
    //OPERAND BUTTONS
    if (button.tag > 10)
    {
        operand = [self getOperand:button:numBeforeEqualPressed];
        operandPressed = true;
        
        performOperation = true;
        //Perform the operation with the specified operand
        [self performOperation:operand:performOperation];
    }
}

- (double) add:(double) num1 :(double) num2
{
    return num1 + num2;
}
- (double) subtract:(double) num1 : (double) num2
{
    return num2 - num1;
}
- (double) oppositeValue
{
    double num;
    
    num = [lblDetailDescription.text doubleValue] * -1;
    //Instead of adding and removing the number fromt he numberList, we simply keep updating it with the new number
    [numberList replaceObjectAtIndex:[numberList count] - 1 withObject: [[NSNumber alloc] initWithDouble:num]];

    return num;
}
-(double) multiply:(double) num1 : (double) num2
{
    return num1 * num2;
}

-(double) division:(double) num1 : (double) num2
{
    return num2 / num1;
}

-(double) sqrt
{
    return sqrt([lblDetailDescription.text doubleValue]);
}

-(double) square
{
    return [lblDetailDescription.text doubleValue] * [lblDetailDescription.text doubleValue];
}

- (void) performOperation: (NSString *) operand : (bool) performOperation
{
    bool addNum = false;
    double num = 0;
    double num1, num2;
    
    if (([numberList count] != 0 && performOperation))
    {
        
        if ([numberList count] >= 2)
        {
            //If the operand is equals, then we find out what the operation was before that, and handle the operation correspondingly.
            if ([operand isEqualToString:EQUALS])
            {
                for (int i = [operatorList count] - 1; i >= 0; i--)
                {
                    operand = [operatorList objectAtIndex:i];
                    
                    if (![operand isEqualToString:EQUALS])
                    {
                        i = 0;
                    }
                }
            }
            
            //If the operand is not equals, than we need to get the operand from the previous calculation the way a calculator normally works.
            operand = [operatorList objectAtIndex:[operatorList count]-2];
            equalPressed = false;
                
            num1 = [[numberList objectAtIndex:[numberList count]-1] doubleValue];
            num2 = [[numberList objectAtIndex:[numberList count]-2] doubleValue];
                
            if ([operand isEqualToString:ADDITION])
            {
                num = [self add:num1 :num2];
            }
            else if ([operand isEqualToString:SUBTRACTION])
            {
                num = [self subtract:num1 :num2];
            }
            else if ([operand isEqualToString:MULTIPLY])
            {
                num = [self multiply:num1 :num2];
            }
            else if ([operand isEqualToString:DIVISION])
            {
                num = [self division:num1 :num2];
            }
            else if ([operand isEqualToString:PERCENTAGE])
            {
                operand = [operatorList objectAtIndex:[operatorList count] - 2];
                
                if ([operand isEqualToString:MULTIPLY])
                {
                    num = (num1 / 100) * num2;
                }
                else if ([operand isEqualToString:ADDITION])
                {
                    num = num2 + ((num1 / 100) * num2);
                }
                else if ([operand isEqualToString:SUBTRACTION])
                {
                    num = num2 - ((num1 / 100) * num2);
                }
                else if ([operand isEqualToString:DIVISION])
                {
                    num = (num2 / (num1 / 100));
                }
            }


        if ([[operatorList objectAtIndex:[operatorList count] - 1] isEqualToString:EQUALS ])
        {
            equalPressed = true;
        }
        addNum = true;
        }
        else if ([operand isEqualToString:OPPOSITE])
        {
            num = [self oppositeValue];
            addNum = false;
        }
        else if ([operand isEqualToString:SQUAREROOT])
        {
            num = [self sqrt];
            addNum = true;
        }
        else if ([operand isEqualToString:SQUARE])
        {
            num = [self square];
            addNum = true;
        }
        else
        {
            num = [lblDetailDescription.text doubleValue];
            addNum = false;
        }
        
        lblDetailDescription.text = [NSString stringWithFormat:@"%g", num];
        
        if (addNum)
        {
            [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
        }
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
//Performing a cost calculation
- (IBAction)costButtonPressed:(UIButton *)button {
    static double salesPrice = 0;
    double cost = 0;
    operandPressed = true;
    mrcPressed = false;
    
    //SEL Pressed
    if (button.tag == 22)
    {
        if (cost == 0)
        {
            salesPrice = [lblDetailDescription.text doubleValue];
        }
    }
    else if (button.tag == 21)  //MAR pressed
    {
        if (salesPrice != 0)
        {
            cost = salesPrice - ( salesPrice * ([lblDetailDescription.text doubleValue] / 100));
            lblDetailDescription.text = [NSString stringWithFormat:@"%g", cost];
            [operatorList addObject:@"Cost Calculation"];
            [numberList addObject:[[NSNumber alloc] initWithDouble:cost ]];
        }
    }
}

- (IBAction)salebuttonPressed:(UIButton *) button {
    static double cost	 = 0;
    double salesPrice = 0;
    operandPressed = true;
    mrcPressed = false;
    
    //CST Pressed
    if (button.tag == 24)
    {
        if (salesPrice == 0)
        {
            cost = [lblDetailDescription.text doubleValue];
        }
    }
    else if (button.tag == 23)  //MAR pressed
    {
        if (cost != 0)
        {
            salesPrice = cost + cost * ([lblDetailDescription.text doubleValue] / 100);
            //salesPrice = cost - ( cost * ([lblDetailDescription.text doubleValue] / 100));
            lblDetailDescription.text = [NSString stringWithFormat:@"%g", salesPrice];
            [operatorList addObject:@"Sales Price Calculation"];
            [numberList addObject:[[NSNumber alloc] initWithDouble:salesPrice ]];
        }
    }

}

- (IBAction)marginButtonPressed:(UIButton *)button {
    static double cost	 = 0;
    double margin = 0;
    operandPressed = true;
    mrcPressed = false;
    
    //CST Pressed
    if (button.tag == 26)
    {
        cost = [lblDetailDescription.text doubleValue];
    }
    else if (button.tag == 25)  //MAR pressed
    {
        margin = (1 - (cost / ([lblDetailDescription.text doubleValue]))) * 100;
        //salesPrice = cost - ( cost * ([lblDetailDescription.text doubleValue] / 100));
        lblDetailDescription.text = [NSString stringWithFormat:@"%g", margin];
        [operatorList addObject:@"Sales Price Calculation"];
        [numberList addObject:[[NSNumber alloc] initWithDouble:margin ]];
    }
}
//Handle adding and removing, and manipulating the values that are stored in memory
- (IBAction)memoryButtonPressed:(UIButton *)button {
    
    if (button.tag == 19)
    {
        //IF they've pressed the MRC button twice, we clear the memory
        if (mrcPressed)
        {
            storedValue = 0;
            lblDetailDescription.text = @"";
        }
        else
        {
            //If they press the MRC button only once then we pull up the stored value onto the screen
            lblDetailDescription.text = [[NSString alloc] initWithFormat:@"%g", storedValue];
            mrcPressed = true;
            
            [numberList addObject:[[NSNumber alloc]initWithDouble:storedValue]];
        }
    }
    else if (button.tag == 18)
    {
        [numberList addObject:[[NSNumber alloc]initWithDouble:[lblDetailDescription.text doubleValue]]];
        
        [self performOperation:EQUALS :true];
        storedValue = storedValue - [lblDetailDescription.text doubleValue];
    }
    else if (button.tag == 17)
    {
        [numberList addObject:[[NSNumber alloc]initWithDouble:[lblDetailDescription.text doubleValue]]];
        
        [self performOperation:EQUALS :true];
        storedValue = storedValue + [lblDetailDescription.text doubleValue];

    }
    operandPressed = true;
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.lblDetailDescription.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
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
