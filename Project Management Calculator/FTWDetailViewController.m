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
#import "FTWOperands.h"
#import "FTWMasterViewController.h"
#import "FTWDataLayer.h"
#import "FTWHelpViewController.h"
#import "NumberButtons.h"
#import "FTWAppDelegate.h"

@interface FTWDetailViewController ( )
{
    NSMutableArray *numberList;
    NSMutableArray *operatorList;
    NSMutableArray *numberListCopy;
    double previousNumber;
    double currentNumber;
    long double reservedNumber;
    long double reservedNumberForPercentPlusEqualsOperator;
    long double storedValue;
    
    NSString *specialOperands;
    
    BOOL percentageMode;
    BOOL continuesMode;
    
    int currentOperand;
    
    int state;
    FTWOperands *operands;
    int numTimesClearPressed;
    bool mrcPressed;
    bool equalPressed;
    double marginToSave;
    double costToSave;
    double sellToSave;
    FTWHelpViewController *helpViewController;
    NSString *newNumber;
    BOOL costButtonPressed;
    BOOL marginButtonPressed;
    BOOL saleButtonPressed;
    BOOL memoryButtonPressed;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
@end

@implementation FTWDetailViewController

@synthesize lblDetailDescription;
@synthesize lblNumberType;
@synthesize functionViews = __functionViews;
@synthesize numberViews = __numberViews;
@synthesize mainOperandViews = __mainOperandViews;
@synthesize subOperandViews = __subOperandViews;
@synthesize clearButtons = __clearButtons;
@synthesize lblMemory = __lblMemory;
@synthesize helpButton = __helpButton;

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
    specialOperands = @"";
    currentOperand = NOOPERAND;
    numberList = [[NSMutableArray alloc] init];
    operatorList = [[NSMutableArray alloc] init];
    numberListCopy = [[NSMutableArray alloc] init];
    numTimesClearPressed = 0;
    storedValue = 0;
    operands = [[FTWOperands alloc] init];
    operands.currentOperand = NOOPERAND;
    operands.previousOperand = NOOPERAND;
    previousNumber = NAN;
    currentNumber = NAN;
    lblNumberType.text = @"";
    __lblMemory.text = @"";
    newNumber = @"";
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    helpViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"HelpViewController"];
    
    [self editMainFunctionConstraints];
    [self setButtonBorders];
    FTWAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    //Start observing whether the device is changing orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    self.landscapeView = [[[NSBundle mainBundle] loadNibNamed:@"LandscapeView" owner:self options:nil] objectAtIndex:0];
    
    if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.lbliPhoneDetailDescription.text = self.lblDetailDescription.text;
        self.lblDetailDescription = self.lbliPhoneDetailDescription;
        //Get the current memory setting being displayed.
        self.lbliPhoneMemory.text = self.lblMemory.text;
        self.lblMemory = self.lbliPhoneMemory;
        //Get the current number type being displayed right now.
        self.lbliPhoneNumberType.text = self.lblNumberType.text;
        self.lblNumberType = self.lbliPhoneNumberType;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {    
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.1];
        label.textAlignment = NSTextAlignmentCenter;
        // ^-Use UITextAlignmentCenter for older SDKs.
        label.textColor = [UIColor grayColor]; // change this color
        self.topNavigationBariPad.titleView = label;
        label.text = NSLocalizedString(@"Sales Calculator", @"");
        [label sizeToFit];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        //Create new instances of these objects so that we can use them in the view dictionary
        UILabel *header = self.lblHeader;
        NSObject *topLayoutGuideline = self.topLayoutGuideline;
        NSDictionary *views = NSDictionaryOfVariableBindings(header, topLayoutGuideline);
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            //[[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self.view removeConstraint:self.headerTopConstraint];
            
            self.headerTopConstraint = [[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuideline]-37-[header]" options:0 metrics:nil views:views] objectAtIndex:0];
            
            [self.view addConstraint:self.headerTopConstraint];
        }
    }
}

- (void) editMainFunctionConstraints
{
    [self.mainOperandViews layoutIfNeeded];
    //Remove all the height and width constraints so that we can set them to make sure that the height and the width are equal.
    for (UIButton *button in self.mainFunctionButtons)
    {
        //Check all the constraints to see which one is applicable to our particular button and then remove that constraint.
        for (NSLayoutConstraint *constraint in self.heightWidthConstraints)
        {
            if ([[button constraints] containsObject:constraint])
            {
                [button removeConstraint:constraint];
            }
                
        }
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat height = 0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height > 480.0f) {
                height = 58;
            } else {
                height = 48;
            }
        }
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:0
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:height];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:0
                                                                              toItem:button
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1.0
                                                                            constant:0.0];
        
        [button addConstraints:@[widthConstraint]];
        [self.view addConstraint:heightConstraint];
    }
}

- (void) orientationChanged : (NSNotification *) notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    //[self.navigationController popViewControllerAnimated:NO];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if ([self isKindOfClass:[FTWHelpViewController class]])
         {
             //DO NOTHING
         }
        else if (UIInterfaceOrientationIsLandscape(deviceOrientation)) /*We first need to get the correct view and set it 
                                                                        up as the main view.  Then we get the current information 
                                                                        in the labels displayed currently, and display that on the 
                                                                        labels that will be stored next.*/
        {
            //Set the view to the correct view for the landscape view

            self.view = self.landscapeView;
            //Get the current number
            self.lblLandscapeDetailDescription.text = self.lblDetailDescription.text;
            self.lblDetailDescription = self.lblLandscapeDetailDescription;
            //Get the current memory setting being displayed.
            self.lblLandscapeMemory.text = self.lblMemory.text;
            self.lblMemory = self.lblLandscapeMemory;
            //Get the current number type being displayed right now.
            self.lblLandscapeNumberType.text = self.lblNumberType.text;
            self.lblNumberType = self.lblLandscapeNumberType;
            
            self.tableView = self.landscapeTableView;
            [self.tableView reloadData];
            [self setButtonBorders];
            
        }
        else if (UIInterfaceOrientationIsPortrait(deviceOrientation))
        {
            //Set the view to the correct view for the landscape view
            self.view = self.portraitView;
            self.lblPortraitDetailDescription.text = self.lblDetailDescription.text;
            self.lblDetailDescription = self.lblPortraitDetailDescription;
            //Get the current memory setting being displayed.
            self.lblPortraitMemory.text = self.lblMemory.text;
            self.lblMemory = self.lblPortraitMemory;
            //Get the current number type being displayed right now.
            self.lblPortraitNumberType.text = self.lblNumberType.text;
            self.lblNumberType = self.lblPortraitNumberType;
            
            self.tableView = self.portraitTableView;
            [self.tableView reloadData];
            [self setButtonBorders];
        }
    }
}

- (void) setButtonBorders
{
    for (UIButton *view in __functionViews.subviews)
    {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            view.contentEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
        }
        
        view.layer.cornerRadius = 7;
        view.layer.borderWidth = 2.0f;
        view.layer.borderColor = [UIColor blackColor].CGColor;
    
    }
    for (UIView *view in __numberViews.subviews)
    {
        view.layer.borderWidth = 2.0f;
        view.layer.borderColor = [UIColor blackColor].CGColor;
        view.layer.cornerRadius = 7;
    }
    for (UIView *view in __subOperandViews.subviews)
    {
        //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        view.layer.cornerRadius = view.layer.frame.size.width / 2;
        view.backgroundColor = [UIColor colorWithRed:0.204 green:0.553 blue:0.733 alpha:1.0];
        
    }
    for (UIView *view in __mainOperandViews.subviews)
    {
        [view layoutIfNeeded];
        view.layer.cornerRadius = view.layer.frame.size.width / 2;
        
        view.backgroundColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1.0];
    }
    
    for (UIButton *clearButton in __clearButtons)
    {
        clearButton.layer.cornerRadius = 7.0f;
        clearButton.layer.borderWidth = 2.0f;
        clearButton.layer.borderColor = [UIColor colorWithRed:0.204 green:0.553 blue:0.733 alpha:1.0].CGColor;
    }
    
    
    __helpButton.layer.cornerRadius = __helpButton.layer.frame.size.width / 2.0;
    __helpButton.layer.borderWidth = 1;
    __helpButton.layer.borderColor = [UIColor clearColor].CGColor;
    __helpButton.backgroundColor = [UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1.0];
    
    //Set the equals button background color to the same as the main operand function buttons background.
    self.equalsButton.backgroundColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1.0];
    self.equalsButton.layer.borderColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1.0].CGColor;

}

- (void) didSwipeLeft:(UIGestureRecognizer *) recognizer
{
    [self.navigationController pushViewController:self.calculationsTable animated:YES];
}


//Perform a special operation, if capable.  If a special operation is performed then return true showing that a calculation has already been made.
- (BOOL) specialOperation {
    if ([specialOperands isEqualToString:@"*%-"])
    {
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", previousNumber - [lblDetailDescription.text doubleValue]];
        return true;
    }
    else if ([specialOperands isEqualToString:@"*%+"])
    {
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", previousNumber + [lblDetailDescription.text doubleValue]];
        return true;
    }
    
    return false;
}

//We save the number, and then perform the previous operation
- (IBAction)divideButtonPressed:(id)sender {
    mrcPressed = false;
    numTimesClearPressed = 0;
    if (state != OPERANDPRESSEDLAST)
    {
        previousNumber = currentNumber;
        currentNumber = [lblDetailDescription.text doubleValue];
        
        if (state != EQUALSPRESSEDLAST) {
            [self performOperation];
        }
        
        currentOperand = DIVISION;
        state = OPERANDPRESSEDLAST;
        currentNumber = [lblDetailDescription.text doubleValue];
    }
    
    //Regardless of the state of the application we always store the current operand and the current number.
    currentOperand = DIVISION;
    
    //Whenever the button is pressed we need to make sure that we store the numbers properly.
    [self storeValues];
    
    continuesMode = false;
    
    specialOperands = [NSString stringWithFormat:@"%@%@", specialOperands, @"/"];
}

- (IBAction)multiplyButtonPressed:(id)sender {
    mrcPressed = false;
    numTimesClearPressed = 0;
    if (state != OPERANDPRESSEDLAST)
    {
        previousNumber = currentNumber;
        currentNumber = [lblDetailDescription.text doubleValue];
        
        if (state != EQUALSPRESSEDLAST) {
            [self performOperation];
        }
        currentOperand = MULTIPLICATION;
        state = OPERANDPRESSEDLAST;
        currentNumber = [lblDetailDescription.text doubleValue];
    }
    
    //Regardless of the state of the application we always store the current operand and the current number.
    currentOperand = MULTIPLICATION;
    
    //Whenever the button is pressed we need to make sure that we store the numbers properly.
    [self storeValues];
    
    continuesMode = false;
    specialOperands = [NSString stringWithFormat:@"%@%@", specialOperands, @"*"];
}

- (IBAction)subtractButtonPressed:(id)sender {
    numTimesClearPressed = 0;
    mrcPressed = false;
    if (state != OPERANDPRESSEDLAST)
    {
        previousNumber = currentNumber;
        currentNumber = [lblDetailDescription.text doubleValue];
        
        if (state != EQUALSPRESSEDLAST) {
            [self performOperation];
        }
        currentOperand = SUBTRACTION;
        state = OPERANDPRESSEDLAST;
        currentNumber = [lblDetailDescription.text doubleValue];
    }
    //Regardless of the state of the application we always store the current operand and the current number.
    currentOperand = SUBTRACTION;
    
    //Whenever the button is pressed we need to make sure that we store the numbers properly.
    [self storeValues];
    
    continuesMode = false;
    
    if (state == OPERANDPRESSEDLAST) {
        specialOperands = [NSString stringWithFormat:@"%@%@", specialOperands, @"-"];
    }
}

- (IBAction)plusButtonPressed:(id)sender {
    numTimesClearPressed = 0;
    mrcPressed = false;
    
    if ((state != OPERANDPRESSEDLAST))
    {
        previousNumber = currentNumber;
        currentNumber = [lblDetailDescription.text doubleValue];
        
        if (state != EQUALSPRESSEDLAST)
        {
            [self performOperation];
        }
        currentOperand = ADDITION;
        state = OPERANDPRESSEDLAST;
        currentNumber = [lblDetailDescription.text doubleValue];
    }
    
    //Regardless of the state of the application we always store the current operand and the current number.
    currentOperand = ADDITION;
    
    //Whenever the button is pressed we need to make sure that we store the numbers properly.
    [self storeValues];
    
    continuesMode = false;
    
    if (state == OPERANDPRESSEDLAST) {
        specialOperands = [NSString stringWithFormat:@"%@%@", specialOperands, @"+"];
    }
    
}

- (void) storeValues {
    previousNumber = currentNumber;
    currentNumber = [lblDetailDescription.text doubleValue];
    
    state = OPERANDPRESSEDLAST;
}

- (IBAction)percentButtonPressed:(id)sender {

    numTimesClearPressed = 0;
    mrcPressed = false;
    previousNumber = currentNumber;
    currentNumber = [lblDetailDescription.text doubleValue];
    
    percentageMode = true;
    
    if (currentOperand == NOOPERAND)
    {
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", ([lblDetailDescription.text doubleValue] / 100 )];
        percentageMode = false;
    }
    else if (currentOperand == PERCENTAGE)
    {
         percentageMode = false;
    }
    else
    {
        switch (currentOperand) {
            case ADDITION:
                lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", previousNumber + (previousNumber * (currentNumber / 100))];
                break;
            case MULTIPLICATION:
                lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", (previousNumber * (currentNumber / 100))];
                break;
            case SUBTRACTION:
                lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", previousNumber - (previousNumber * (currentNumber / 100))];
                break;
            case DIVISION:
                lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", (previousNumber / currentNumber) * 100];
                break;
            default:
                break;
        }
    }
    
    state = OPERANDPRESSEDLAST;
    currentOperand = PERCENTAGE;
    continuesMode = false;
    specialOperands = [NSString stringWithFormat:@"%@%@", specialOperands, @"%"];
    currentNumber = [lblDetailDescription.text doubleValue];
}

- (IBAction)squareRootButtonPressed:(id)sender {
    numTimesClearPressed = 0;
    mrcPressed = false;
    lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", sqrt([lblDetailDescription.text doubleValue]) ];
    
}

- (IBAction)oppositeButtonPressed:(id)sender {
    numTimesClearPressed = 0;
    mrcPressed = false;
    lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", [lblDetailDescription.text doubleValue] * -1];
}

- (IBAction)equalButtonPressed:(id)sender {
    
    numTimesClearPressed = 0;
    bool operationHandled = false;
    
    //Special operands are only performed when you have two operand buttons pressed simulateneously.
    
    if (state == OPERANDPRESSEDLAST) {
        operationHandled = [self specialOperation];
    }
    
    //If a special operation is already handled then we don't need to do any other calculations.
    if (!operationHandled)
    {
        if (state == EQUALSPRESSEDLAST) {
            previousNumber = [lblDetailDescription.text doubleValue];
        }
        else if (continuesMode == false) {  //If we're not in the process of handling a percentage calculation.
            previousNumber = currentNumber;
            currentNumber = [lblDetailDescription.text doubleValue];
        }
        else if (continuesMode == true) //If we're in the mode where they can keep pressing the equals button?
        {
            previousNumber = [lblDetailDescription.text doubleValue];
        }
        else
        {
            currentNumber = [lblDetailDescription.text doubleValue];
        }
    }
    [self performOperation];
    state = EQUALSPRESSEDLAST;
    continuesMode = true;
    specialOperands = [NSString stringWithFormat:@"%@%@", specialOperands, @"="];
}

- (void) performOperation {
    mrcPressed = false;
    switch (currentOperand) {
        case ADDITION:
            lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", currentNumber + previousNumber];
            break;
        case MULTIPLICATION:
            lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", currentNumber * previousNumber];
            break;
        case DIVISION:
            lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", previousNumber / currentNumber];
            break;
        case SUBTRACTION:
            lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", previousNumber - currentNumber];
            break;
        default:
            break;
    }
}

- (void) displayValue : (double) num {
    lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", num];
}

- (IBAction)numberButtonPressed:(UIButton*)button {
    numTimesClearPressed = 0;
    mrcPressed = false;
    
    if (state == OPERANDPRESSEDLAST || state == EQUALSPRESSEDLAST)
    {
        lblDetailDescription.text = @"";
        lblNumberType.text = @"";
    }
    
    if (state == EQUALSPRESSEDLAST) {
        currentOperand = NOOPERAND;
    }
    
    if (button.tag == 10)
    {
        if ([lblDetailDescription.text rangeOfString:@"."].location == NSNotFound)
        {
            if ([lblDetailDescription.text isEqualToString:@"0"] || [lblDetailDescription.text isEqualToString:@""])
            {
                lblDetailDescription.text = [NSString stringWithFormat:@"0."];
            }
            else
            {
                lblDetailDescription.text = [NSString stringWithFormat:@"%@.", lblDetailDescription.text];
            }
        }
    }
    else if ([lblDetailDescription.text rangeOfString:@"-"].location != NSNotFound)
    {
        if ([lblDetailDescription.text isEqualToString:@"-0"])
        {
            lblDetailDescription.text = [NSString stringWithFormat:@"-%i", button.tag];
        }
        else {
            lblDetailDescription.text = [NSString stringWithFormat:@"%@%i", lblDetailDescription.text, button.tag];
        }
    }
    else if ([lblDetailDescription.text isEqualToString:@"0"])
    {
        lblDetailDescription.text = [NSString stringWithFormat:@"%i",button.tag];
    }
    else
    {
        lblDetailDescription.text = [NSString stringWithFormat:@"%@%i", lblDetailDescription.text, button.tag];
    }
    
    state = NUMBERENTEREDLAST;
}

- (IBAction)btnClearPressed:(id)sender {
    mrcPressed = false;
    numTimesClearPressed++;
    
    if (numTimesClearPressed == 1)
    {
        lblDetailDescription.text = @"";

        lblNumberType.text = @"";
        
        newNumber = @"";
    
        if (equalPressed == TRUE)
        {
            [self clearEverything];
        }
    }
    else if (numTimesClearPressed == 2)
    {
        [self clearEverything];
    }
}

- (void) clearEverything
{
    previousNumber = 0;
    currentNumber = 0;
    
    currentOperand = NOOPERAND;
    
    numberList = [[NSMutableArray alloc] init];
    operatorList = [[NSMutableArray alloc] init];
    numTimesClearPressed = 0;
    
    continuesMode = false;
    percentageMode = false;
    
    specialOperands = @"";
    

}

//Performing a cost calculation
- (IBAction)costButtonPressed:(UIButton *)button {
    static double salesPrice = 0;
    double cost = 0;
    state = OPERANDPRESSEDLAST;
    mrcPressed = false;
    
    //SEL Pressed
    if (button.tag == COSTSELBUTTON)
    {
        if (cost == 0)
        {
            salesPrice = [lblDetailDescription.text doubleValue];
            lblNumberType.text = @"SEL";
            costButtonPressed = YES;
            marginButtonPressed = NO;
            saleButtonPressed = NO;
        }
    }
    else if (button.tag == COSTMARBUTTON && costButtonPressed)  //MAR pressed
    {
        if (salesPrice != 0)
        {
            marginToSave = [lblDetailDescription.text doubleValue];
            cost = salesPrice - ( salesPrice * ([lblDetailDescription.text doubleValue] / 100));
            lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", cost];
            lblNumberType.text = @"CST";
            [operatorList addObject:@"Cost Calculation"];
            [numberList addObject:[[NSNumber alloc] initWithDouble:cost ]];
            
            costToSave = cost;
            sellToSave = salesPrice;
            costButtonPressed = NO;
        }
    }
}

- (IBAction)salebuttonPressed:(UIButton *) button {
    static double cost	 = 0;
    double salesPrice = 0;
    state = OPERANDPRESSEDLAST;
    mrcPressed = false;
    
    //CST Pressed
    if (button.tag == SELCOSTBUTTON)
    {
        if (salesPrice == 0)
        {
            cost = [lblDetailDescription.text doubleValue];
            lblNumberType.text = @"CST";
            costButtonPressed = NO;
            marginButtonPressed = NO;
            saleButtonPressed = YES;
        }
    }
    else if (button.tag == SELMARBUTTON && saleButtonPressed)  //MAR pressed
    {
        if (cost != 0)
        {
            marginToSave = [lblDetailDescription.text doubleValue];
            salesPrice = cost / (1 - ([lblDetailDescription.text doubleValue] / 100));
            lblNumberType.text = @"SEL";
            //salesPrice = cost - ( cost * ([lblDetailDescription.text doubleValue] / 100));
            lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", salesPrice];
            [operatorList addObject:@"Sales Price Calculation"];
            [numberList addObject:[[NSNumber alloc] initWithDouble:salesPrice ]];
            
            sellToSave = salesPrice;
            costToSave = cost;
            saleButtonPressed = NO;
        }
    }
}

- (IBAction)marginButtonPressed:(UIButton *)button {
    static double cost = 0;
    double margin = 0;
    state = OPERANDPRESSEDLAST;
    mrcPressed = false;
    
    //CST Pressed
    if (button.tag == MARCOSTBUTTON)
    {
        cost = [lblDetailDescription.text doubleValue];
        lblNumberType.text = @"CST";
        costButtonPressed = NO;
        marginButtonPressed = YES;
        saleButtonPressed = NO;
    }
    else if (button.tag == MARSELBUTTON && marginButtonPressed)  //MAR pressed
    {
        sellToSave = [lblDetailDescription.text doubleValue];
        margin = (1 - (cost / ([lblDetailDescription.text doubleValue]))) * 100;
        lblNumberType.text = @"MAR";
        //salesPrice = cost - ( cost * ([lblDetailDescription.text doubleValue] / 100));
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", margin];
        [operatorList addObject:@"Sales Price Calculation"];
        [numberList addObject:[[NSNumber alloc] initWithDouble:margin ]];
        
        marginToSave = margin;
        costToSave = cost;
        marginButtonPressed = NO;
    }
}
//Handle adding and removing, and manipulating the values that are stored in memory
- (IBAction)memoryButtonPressed:(UIButton *)button {

    memoryButtonPressed = true;
    state = OPERANDPRESSEDLAST;
    
    if (button.tag == MEMORYCLEARBUTTON)
    {
        //IF they've pressed the MRC button twice, we clear the memory
        if (mrcPressed)
        {
            storedValue = 0;
            lblDetailDescription.text = @"";
            __lblMemory.text = @"";
            newNumber = @"";
            state = NOOPERAND;
            [self clearEverything];
        }
        else
        {
            //If they press the MRC button only once then we pull up the stored value onto the screen
            lblDetailDescription.text = [[NSString alloc] initWithFormat:@"%.12Lg", storedValue];
            mrcPressed = true;
            
            [numberList addObject:[[NSNumber alloc]initWithDouble:storedValue]];
            __lblMemory.text = @"M";
        }
    }
    else if (button.tag == MEMORYREMOVEBUTTON)
    {
        [numberList addObject:[[NSNumber alloc]initWithDouble:[lblDetailDescription.text doubleValue]]];
        //[--self performOperation: (bool) performOperation: (bool) equals
        //[self performOperation:true:true];
        storedValue = storedValue - [lblDetailDescription.text doubleValue];
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12Lg", storedValue];
        __lblMemory.text = @"M";
    }
    else if (button.tag == MEMORYADDBUTTON)
    {
        [numberList addObject:[[NSNumber alloc]initWithDouble:[lblDetailDescription.text doubleValue]]];
        //[--self performOperation: (bool) performOperation: (bool) equals
       // [self performOperation:true:true];
        storedValue = storedValue + [lblDetailDescription.text doubleValue];
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12Lg", storedValue];
        __lblMemory.text = @"M";
    }
    
    state = OPERANDPRESSEDLAST;
}

- (IBAction)saveButtonPressed:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *myDate = [NSDate date];

    
    FTWDataLayer *dataLayer = [[FTWDataLayer alloc] init:self.managedObjectContext];
    dataLayer.fetchedResultsController = self.fetchedResultsController;
    
    [dataLayer SaveContext:[NSString stringWithFormat:@"SEL = %g\nCST = %g\nMAR = %g", sellToSave, costToSave, marginToSave] date:myDate];
}

- (IBAction)helpButtonPressed:(id)sender {
    [self.navigationController pushViewController:helpViewController animated:YES];
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.lblDetailDescription.text = [[self.detailItem valueForKey:@"calculation"] description];
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


- (void)viewDidUnload {
    [self setLblNumberType:nil];
    [super viewDidUnload];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.view isEqual:self.landscapeView])
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 150)];
        
        cell.textLabel.numberOfLines = 4;
        [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
        
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Saving" message:@"There was a problem saving the calculation.  It wasn't your fault.  Restart the application, and try again please.  If the problem persists, please email salescalculator@gmail.com and explain the problem." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            
            [alert show];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Saving" message:@"There was a problem saving the calculation.  It wasn't your fault.  Restart the application, and try again please.  If the problem persists, please email salescalculator@gmail.com and explain the problem." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alert show];
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([self.fetchedResultsController.fetchedObjects count] > 0)
    {
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [object valueForKey:@"date"];

        NSString *stringFromDate = [dateFormat stringFromDate:date];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@",  stringFromDate, [[object valueForKey:@"calculation"] description]];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    
    return NO;
}

- (IBAction)clearAll:(id)sender {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    [fetch setEntity:[NSEntityDescription entityForName:@"Calculations" inManagedObjectContext:context]];
    
    NSArray * result = [context executeFetchRequest:fetch error:&error];
    if (error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Deleting" message:@"There was a problem deleting all the calculations.  It wasn't your fault.  Restart the application, and try again please.  If the problem persists, please email salescalculator@gmail.com and explain the problem." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alert show];
    }
    for (id calculation in result)
    {
        [context deleteObject:calculation];
    }
    
    error = nil;
    if (![context save:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Saving" message:@"There was a problem saving the calculation.  It wasn't your fault.  Restart the application, and try again please.  If the problem persists, please email salescalculator@gmail.com and explain the problem." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alert show];
    }
}

@end
