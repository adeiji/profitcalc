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
#import "FTWCoreDataSingleton.h"

@interface FTWDetailViewController ( )
{
    NSMutableArray *numberList;
    NSMutableArray *operatorList;
    NSMutableArray *numberListCopy;
    long double previousNumber;
    long double currentNumber;
    long double reservedNumber;
    long double reservedNumberForPercentPlusEqualsOperator;
    long double storedValue;
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
    FTWCoreDataSingleton *coreDataSingleton;
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
@synthesize clearButton = __clearButton;
@synthesize lblMemory = __lblMemory;
@synthesize helpButton = __helpButton;

static const NSInteger xCoord = 50;

#pragma mark - Managing the detail item

#define MAINSTORYBOARD_IPHONE @"MainStoryboard_iPhone"
#define MAINSTORYBOARD_IPAD @"MainStoryboard_iPad"

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
    
    helpViewController = [[UIStoryboard storyboardWithName:MAINSTORYBOARD_IPHONE bundle:nil] instantiateViewControllerWithIdentifier:@"HelpViewController"];
    
    [self setButtonBorders];
    coreDataSingleton = [FTWCoreDataSingleton sharedCoreDataObject];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.calculationsTable = [[UIStoryboard storyboardWithName:MAINSTORYBOARD_IPAD bundle:nil] instantiateViewControllerWithIdentifier:@"CalculationsTable"];
    }
    else{
        self.calculationsTable = [[UIStoryboard storyboardWithName:MAINSTORYBOARD_IPHONE bundle:nil] instantiateViewControllerWithIdentifier:@"CalculationsTable"];
    }
    
    
    self.fetchedResultsController = coreDataSingleton.fetchedResultsController;
}

- (void) setButtonBorders
{
    for (UIView *view in __functionViews.subviews)
    {
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
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            view.layer.cornerRadius = view.layer.frame.size.width / 2;
        }
        else
        {
            view.layer.cornerRadius = 21;
        }
        
        view.backgroundColor = [UIColor colorWithRed:0.204 green:0.553 blue:0.733 alpha:1.0];
    }
    for (UIView *view in __mainOperandViews.subviews)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            view.layer.cornerRadius = 52.5;
        }
        else
        {
            view.layer.cornerRadius = 25;
        }

        view.backgroundColor = [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1.0];
    }
    
    __clearButton.layer.cornerRadius = 7.0f;
    __clearButton.layer.borderWidth = 2.0f;
    __clearButton.layer.borderColor = [UIColor colorWithRed:0.204 green:0.553 blue:0.733 alpha:1.0].CGColor;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        __helpButton.layer.cornerRadius = 20.0f;
    }
    
    __helpButton.layer.borderWidth = 1;
    __helpButton.layer.borderColor = [UIColor whiteColor].CGColor;
    __helpButton.backgroundColor = [UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1.0];
}

- (void) didSwipeLeft:(UIGestureRecognizer *) recognizer
{
    [self.navigationController pushViewController:self.calculationsTable animated:YES];
    
    NSLog(@"Left swipe detected");
}

//This handles all the unique operands that are possible of creating through various operand selections available on this calculator.
-(int) getSpecialOperand : (UIButton *) button
{
    if (operands.currentOperand == MULTIPLICATION && button.tag == EQUALSBUTTON)        // *= is square
    {
        return SQUARE;
    }
    else if (operands.previousOperand == PERCENTAGE && button.tag == ADDITIONBUTTON)    // %+
    {
        return PERCENTPLUS;
    }
    else if (operands.previousOperand == PERCENTAGE && button.tag == MINUSBUTTON)       //%-
    {
        return PERCENTMINUS;
    }
    else if (operands.previousOperand == PERCENTPLUS && button.tag == EQUALSBUTTON)     //%+=   is  (250 X 5%) + 250
    {
        return PERCENTPLUSEQUALS;
    }
    else if (operands.previousOperand == PERCENTMINUS && button.tag == EQUALSBUTTON)    //%-=   is  250 - (250 X 5%)
    {
        return PERCENTMINUSEQUALS;
    }
    else if (operands.currentOperand == PERCENTPLUS && button.tag < 10)
    {
        return PERCENTPLUSNUM;
    }
    else
    {
        return [self getOperand:button];
    }
    
    return NOOPERAND;
}
//Returns the selected operand
-(int) getOperand : (UIButton *) button
{
    if (button.tag == OPPOSITEBUTTON)       //Negative - Positive
    {
        return OPPOSITE;
    }
    else if (button.tag == ADDITIONBUTTON)      //Plus
    {
        return ADDITION;
    }
    else if (button.tag == MINUSBUTTON)      //Minus
    {
        return SUBTRACTION;
    }
    else if (button.tag == MULTIPLICATIONBUTTON)      //Multiply
    {
        return MULTIPLICATION;
    }
    else if (button.tag == DIVISIONBUTTON)      //Divide
    {
        return DIVISION;
    }
    else if (button.tag == SQUAREROOTBUTTON)      //Square Root
    {
        return SQUAREROOT;
    }
    if (button.tag == PERCENTAGEBUTTON)      //Percentage button pressed
    {
        return PERCENTAGE;
    }    
    return 0;
}

-(void) updateDisplay:(UIButton*) button
{
    //If there has just been an operand pressed, we want to make sure that we don't erase all the contents of the display label until the user clicks on a number, than we will delete all the contents.  We set operandPressed to false so that we don't keep deleting the contents of the label every time the user clicks on the number button.
    
    if (state == OPERANDPRESSEDLAST || state == EQUALSPRESSEDLAST || state == MEMORYBUTTONPRESSEDLAST)
    {
        lblDetailDescription.text = @"";

        lblNumberType.text = @"";
    
        
        newNumber = @"";
    }
    if (button.tag < 10)    //IS A NUMBER BUTTON
    {
        newNumber = [NSString stringWithFormat:@"%@%d", newNumber, button.tag];
        //if this is a number than simply add the number to the integer.  If it's a decimal than check if there is already a decimal there and if not add the point.
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", [newNumber doubleValue]];
    }
    else if (button.tag == DECIMALBUTTON)
    {
        if ([lblDetailDescription.text rangeOfString:@"."].location == NSNotFound)
        {
            newNumber = [NSString stringWithFormat:@"%@.", newNumber];
            lblDetailDescription.text = [NSString stringWithFormat:@"%@.",lblDetailDescription.text];
        }
    }
    
    //set the state so that it shows that the last thing entered was a number
    state = NUMBERENTEREDLAST;
}

- (void) validateOperation : (UIButton *) button
{
 
}

- (void) percentageButtonPressed : (UIButton *) button
{
    if (operands.currentOperand == PERCENTPLUSNUM)
    {
        [self performSpecialOperation];
    }
    else
    {
        operands.currentOperand = [self getOperand : button];
    
        [self setNumbersToBeCalculated];        //Every time we press an operand button, we add that number to the number list
        //[--self performOperation: (bool) performOperation: (bool) equals
        [self performOperation : true : false];
    
        state = OPERANDPRESSEDLAST;
    }
}

- (void) operandPressedOnce : (UIButton *) button
{
    operands.currentOperand = [self getOperand : button];
    
    [self setNumbersToBeCalculated];        //Every time we press an operand button, we add that number to the number list
    
    if (state != EQUALSPRESSEDLAST)         /*If the equals button was pressed last, we don't want to perform the operation
                                             immediately, but wait until the next operand is press*/
    {
        if (equalPressed == FALSE)
        {
            //[--self performOperation: (bool) performOperation: (bool) equals
            [self performOperation : true : false];
        }
    }
    else
    {
        operands.previousOperand = operands.currentOperand;
    }
    
    state = OPERANDPRESSEDLAST;
    equalPressed = FALSE;
}

- (void) equalButtonPressed : (UIButton *) button
{
    
    if (state == EQUALSPRESSEDLAST)  //If this is not the first continous time that the equal time has been pressed
    {
        state = EQUALSPRESSEDLAST;
        //[--self performOperation: (bool) performOperation: (bool) equals
        [self performOperation : true : true];
    }
    else if (state != EQUALSPRESSEDLAST)    //If the user presses the equals button for the first time
    {
        [self setNumbersToBeCalculated];
        
        if (state != OPERANDPRESSEDLAST)    //If the user has not pressed an operand before pressing the equals sign
        {
            state = EQUALSPRESSEDLAST;
            //[--self performOperation: (bool) performOperation: (bool) equals
            [self performOperation:true :true];     //perform the operation
        }
        else if (state == OPERANDPRESSEDLAST)       //if the user has just pressed an operand, we call the special operand method
        {
            operands.currentOperand = [self getSpecialOperand:button];
            state = EQUALSPRESSEDLAST;
            [self performSpecialOperation];
            
        }
        else
        {
            //[--self performOperation: (bool) performOperation: (bool) equals
            [self performOperation : true: true];       //simply perform the operation
        }
    }
    
    state = EQUALSPRESSEDLAST;
    equalPressed = TRUE;
}

//Handles all button presses that have to do with numbers or operations
- (IBAction)numberButtonPressed:(UIButton*)button {
    static double numBeforeEqualPressed = 0;
    numTimesClearPressed = 0;
    bool performOperation;
    
    mrcPressed = false;
    
    if (button.tag <= 10) //If the user pressed a number
    {
        if (operands.currentOperand == PERCENTPLUS)
        {
            operands.currentOperand = [self getSpecialOperand:button];
        }
        
        [self updateDisplay:button];
        numBeforeEqualPressed = [lblDetailDescription.text doubleValue];
    }

    if (button.tag > 10) //If the user pressed an operand
    {
        if (button.tag == OPPOSITEBUTTON)
        {
            lblDetailDescription.text = [NSString stringWithFormat:@"%.12g",[self oppositeValue]];
        }
        else if (button.tag == SQUAREROOTBUTTON)   //Opposite Value || Square Root Operand ------ Respectively
        {
            operands.currentOperand = [self getOperand: button];
            
            [self performOperation : true : false];
            state = OPERANDPRESSEDLAST;
        }
        else if (button.tag != EQUALSBUTTON)           //If the equal button has not been pressed now
        {
            if (button.tag == PERCENTAGEBUTTON)
            {
                [self percentageButtonPressed : button];
            }
            else if (state != OPERANDPRESSEDLAST)            //If the last button pressed was an operand then we need to get a special operand, otherwise, just get the normal operand
            {
                [self operandPressedOnce:button];
            }                   
            else    //In this case, two operands have been pressed consecutively.
            {   
                operands.currentOperand = [self getSpecialOperand : button];
                state = OPERANDPRESSEDLAST;
                
                [self performSpecialOperation];
            }
        }
        else if (button.tag == EQUALSBUTTON)
        {
            [self equalButtonPressed:button];
        }
        else
        {
            if (state != OPERANDPRESSEDLAST)
            {
                operands.currentOperand = [self getOperand : button];
            
                performOperation = true;
                //Perform the operation with the specified operand
                //[--self performOperation: (bool) performOperation: (bool) equals
                [self performOperation:performOperation:false];
            }
        }
    }
}

-(void) setNumbersToBeCalculated
{
    previousNumber = currentNumber;
    currentNumber = [lblDetailDescription.text doubleValue];
}

- (double) add:(double) num1 :(double) num2
{
    return num1 + num2;
}
- (double) subtract:(double) num1 : (double) num2
{
    return num1 - num2;
}
- (double) oppositeValue
{
    return [lblDetailDescription.text doubleValue] * -1;
}
-(double) multiply:(double) num1 : (double) num2
{
    return num1 * num2;
}

-(double) division:(double) num1 : (double) num2
{
    return num1 / num2;
}

-(double) sqrt
{
    return sqrt([lblDetailDescription.text doubleValue]);
}

-(double) square
{
    return [lblDetailDescription.text doubleValue] * [lblDetailDescription.text doubleValue];
}

- (double) performCalculation: (double) num1 : (double) num2 : (int) operand
{
    if (operand == ADDITION)
    {
        [numberList addObject:@"+"];
        return [self add:num1 :num2];
    }
    else if (operand == SUBTRACTION)
    {
        [numberList addObject:@"-"];
        return [self subtract:num1 :num2];
    }
    else if (operand == MULTIPLICATION)
    {
        [numberList addObject:@"*"];
        return [self multiply:num1 :num2];
    }
    else if (operand == DIVISION)
    {
        [numberList addObject:@"/"];
        return [self division:num1 :num2];
    }
    else if (operand == PERCENTAGE)     //When percentage is pressed then generally there are special calculations performed.  Ex - 250 X 5% is = to 5% of 250
    {
        operand = operands.previousOperand;
        reservedNumber = num1;
        
        if (operand == MULTIPLICATION)
        {
            [numberList addObject:@"%*"];
            reservedNumberForPercentPlusEqualsOperator = (reservedNumber / 100) * num2;
        }
        else if (operand == ADDITION) 
        {
            [numberList addObject:@"%+"];
            reservedNumberForPercentPlusEqualsOperator = reservedNumber + ((reservedNumber / 100) * num2);
        }
        else if (operand == SUBTRACTION)
        {
            [numberList addObject:@"%-"];
            reservedNumber = reservedNumber - ((reservedNumber / 100) * num2);
            reservedNumberForPercentPlusEqualsOperator = reservedNumber;
        }
        else if (operand == DIVISION)
        {
            [numberList addObject:@"%/"];
            reservedNumberForPercentPlusEqualsOperator = (reservedNumber / (num2 / 100));
        }
        else if (operand == NOOPERAND)
        {
            [numberList addObject:@"%"];
            reservedNumberForPercentPlusEqualsOperator = [lblDetailDescription.text doubleValue] / 100;
        }
        else
        {
            reservedNumberForPercentPlusEqualsOperator = [lblDetailDescription.text doubleValue];
        }
        
        return reservedNumberForPercentPlusEqualsOperator;
    }
    
    return num2;
}

- (int) performSimpleOperations
{
    return 1;
}

- (double) performSingularOperations
{
    int operand = operands.currentOperand;

    if (operand == SQUAREROOT) //Get the square root of the number
    {
        [numberList addObject:@"SQRT"];
        return [self sqrt];
    }
    else if (operand == SQUARE)     //Square the number
    {
        [numberList addObject:@"^2"];
        return [self square];
    }
    else if (operand == NOOPERAND)  //Here is where there is no calculation performed, we simply wait for the next operand selection
    {
        double num = [lblDetailDescription.text doubleValue];
        //Remove the last object, so that there is not a -1 in the operatorList which would show that no calculation was performed.  If this is not deleted then when you enter in another operand, the getSpecialOperand method will read the last operand and the -1, which will cause no action to be taken.
        [operatorList removeLastObject];
        
        return num;
    }
    return -1;
}
//After the user presses equals we reset the number list so that we don't perform the calculation until there is another operand pressed
-(void) resetNumberList
{
    [numberListCopy addObjectsFromArray:numberList];
    [numberList removeAllObjects];
    [numberList addObject: [numberListCopy objectAtIndex:[numberListCopy count] - 1]];
    [numberListCopy removeObject:[numberListCopy objectAtIndex:[numberListCopy count] - 1]];
    
    equalPressed = false;
}


//Get the new value after the operands are pressed
- (double) getAllInformationForCalculation : (int) operand
{
    //Perform the calculation with whatever the specified operand is
    double calculatedNum =  [self performCalculation: previousNumber : currentNumber : operand];
    
   // [self addNumberToNumberList:calculatedNum];
    
    return calculatedNum;
}


//Add the given number to the number array
-(void) addNumberToNumberList: (double) num
{
    [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
}

#pragma mark - Performing Operations
//Performs all special operations
- (void) performSpecialOperation
{
    int operand = operands.currentOperand;
    double num = [lblDetailDescription.text doubleValue];
    
    if (operand == PERCENTPLUSEQUALS)
    {
        [numberList addObject:@"%+="];
        num = reservedNumber + currentNumber;
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", num]; //Display the new number
        
        previousNumber = currentNumber;
        currentNumber = num;
    }
    else if (operand == PERCENTMINUSEQUALS)
    {
        [numberList addObject:@"%-="];
        num = reservedNumber - currentNumber;
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", num]; //Display the new number
        
        previousNumber = currentNumber;
        currentNumber = num;
    }
    else if (operand == SQUARE)
    {
        [numberList addObject:@"^2"];
        num = [self square];        
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", num]; //Display the new number
        
        previousNumber = currentNumber;
        currentNumber = num;
    }
    else if (operand == PERCENTPLUSNUM)
    {
        [numberList addObject:@"%+"];
        num = reservedNumberForPercentPlusEqualsOperator + (reservedNumber * ([lblDetailDescription.text doubleValue] / 100));
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", num];
        
        previousNumber = currentNumber;
        currentNumber = num;
    }
    operands.previousOperand = operands.currentOperand;
    [numberList addObject:[[NSNumber alloc] initWithDouble:num] ];
    
}

- (void) performOperation: (bool) willPerformOperation : (bool) equals
{
    double num = [lblDetailDescription.text doubleValue];
    int operand = operands.currentOperand;
    
    if (operand != NOOPERAND)
    {
        //Check to see if there are any numbers that we're performing calculations on, if we can perform a calculation, and if they've pressed equals and they're not pressing an operand over and over again.
        if (operand == SQUAREROOT || operand == SQUARE)
        {
            [numberList addObject:lblDetailDescription.text];
            num = [self performSingularOperations];
          
            previousNumber = currentNumber;             /*These two lines are performed after every operation, to make sure
                                                        that we keep updating the currentNumber, but we keep
                                                        the previous number pressed*/
            currentNumber = num;
            [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
        }
        else if (operands.currentOperand == PERCENTAGE)
        {
            [numberList addObject:lblDetailDescription.text];
            num = [self getAllInformationForCalculation:PERCENTAGE];
            previousNumber = currentNumber;
            currentNumber = num;
            [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
        }
        else if (!isnan(previousNumber))
        {
            if (state == EQUALSPRESSEDLAST) /*If the equal button was pressed then we perform the operation, 
                                             but don't change the CURRENTNUMBER variable, because if the user keeps 
                                             pressing the equal button we want to keep performing the operation with the 
                                             last number entered before operations began, which is what's stored in CURRENTNUMBER. */
            {
                [numberList addObject:lblDetailDescription.text];
                num = [self getAllInformationForCalculation:operands.currentOperand];
                previousNumber = num;
                
                [numberList addObject:@"="];
                [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
            }
            else if (operands.previousOperand == operands.currentOperand)   /*If the user has entered the same operand more than once than we
                                                                             simply keep performing the same operation*/
            {
                [numberList addObject:lblDetailDescription.text];
                num = [self getAllInformationForCalculation:operands.currentOperand];
                previousNumber = currentNumber;
                currentNumber = num;
                [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
            }
            else                            /*if the user has entered a different operand this time then the last operand entered, then we perform
                                             the first operand that was pressed.*/
            {
                [numberList addObject:lblDetailDescription.text];
                num = [self getAllInformationForCalculation:operands.previousOperand];
                previousNumber = currentNumber;
                currentNumber = num;
                [numberList addObject:[[NSNumber alloc] initWithDouble:num]];
            }
        }
        else
        {
             [numberList addObject:lblDetailDescription.text];
        }
        
        //If the user has pressed equals, than we make sure that when the user clicks on another operand, the calculation is not done automatically.
        //We do this by removing all the data except for the last number from the numberList array and copying it to the numberListCopy array.
        operands.previousOperand = operands.currentOperand;
        
        lblDetailDescription.text = [NSString stringWithFormat:@"%.12g", num]; //Display the new number
        
    }
    
    [operatorList addObject:[[NSNumber alloc] initWithInt:operands.currentOperand]];
}

- (IBAction)copyToClipboard:(id)sender {
    NSMutableString *arrayAsParagraphs = [[numberList componentsJoinedByString:@"\n"] mutableCopy];
    
    [UIPasteboard generalPasteboard].string = arrayAsParagraphs;    
}

- (IBAction)btnClearPressed:(id)sender {
    
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
    previousNumber = NAN;
    currentNumber = NAN;
    operands.currentOperand = NOOPERAND;
    operands.previousOperand = NOOPERAND;
    numberList = [[NSMutableArray alloc] init];
    operatorList = [[NSMutableArray alloc] init];
    numTimesClearPressed = 0;
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
        }
    }
    else if (button.tag == COSTMARBUTTON)  //MAR pressed
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
        }
    }
    else if (button.tag == SELMARBUTTON)  //MAR pressed
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
    }
    else if (button.tag == MARSELBUTTON)  //MAR pressed
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
    }
}
//Handle adding and removing, and manipulating the values that are stored in memory
- (IBAction)memoryButtonPressed:(UIButton *)button {
    
    if (button.tag == MEMORYCLEARBUTTON)
    {
        //IF they've pressed the MRC button twice, we clear the memory
        if (mrcPressed)
        {
            storedValue = 0;
            lblDetailDescription.text = @"";
            __lblMemory.text = @"";
            newNumber = @"";
        }
        else
        {
            //If they press the MRC button only once then we pull up the stored value onto the screen
            lblDetailDescription.text = [[NSString alloc] initWithFormat:@"%Lg", storedValue];
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
        lblDetailDescription.text = [NSString stringWithFormat:@"%Lg", storedValue];
        __lblMemory.text = @"M";
    }
    else if (button.tag == MEMORYADDBUTTON)
    {
        [numberList addObject:[[NSNumber alloc]initWithDouble:[lblDetailDescription.text doubleValue]]];
        //[--self performOperation: (bool) performOperation: (bool) equals
       // [self performOperation:true:true];
        storedValue = storedValue + [lblDetailDescription.text doubleValue];
        lblDetailDescription.text = [NSString stringWithFormat:@"%Lg", storedValue];
        __lblMemory.text = @"M";
    }
    
    state = MEMORYBUTTONPRESSEDLAST;
}

- (IBAction)saveButtonPressed:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *myDate = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:myDate];
    
//    FTWDataLayer *dataLayer = [[FTWDataLayer alloc] init:self.managedObjectContext];
//    dataLayer.fetchedResultsController = self.fetchedResultsController;
    
    [coreDataSingleton SaveContext:[NSString stringWithFormat:@"SEL = %g\nCST = %g\nMAR = %g", sellToSave, costToSave, marginToSave] dateString:dateString];
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
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSManagedObject *object = [[coreDataSingleton fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailItem = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[coreDataSingleton fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

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

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"calculation"] description];
}

- (IBAction)buttonTouched:(id)sender withEvent:(UIEvent *) event {
}

- (IBAction)buttonMoved:(id)sender withEvent:(UIEvent *) event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    UIControl *control = sender;
    
    CGPoint controlPoint = control.center;
    controlPoint.x = point.x;
    
    control.center = controlPoint;
    
    if (control.center.x > 250)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)gotoCalculator:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)clearAll:(id)sender {
    //Clear everything in the fetchedresultscontroller
    [coreDataSingleton clearAll];
    self.fetchedResultsController = coreDataSingleton.fetchedResultsController;
}

- (IBAction)buttonReleased:(id)sender withEvent:(UIEvent *) event {
    UIControl *control = sender;
    CGPoint controlPoint = control.center;
    controlPoint.x = xCoord;
    control.center = controlPoint;
}


@end
