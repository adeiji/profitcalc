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
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
@end

@implementation FTWDetailViewController


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
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
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

    if (state == OPERANDPRESSEDLAST || state == EQUALSPRESSEDLAST)
    {
        lblDetailDescription.text = @"";
    }
    if (button.tag < 10)    //NOT A NUMBER BUTTON
    {
        //if this is a number than simply add the number to the integer.  If it's a decimal than check if there is already a decimal there and if not add the point.
        lblDetailDescription.text = [NSString stringWithFormat:@"%@%ld",lblDetailDescription.text, (long)button.tag];
    }
    else if (button.tag == DECIMALBUTTON)
    {
        if ([lblDetailDescription.text rangeOfString:@"."].location == NSNotFound)
        {
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
    
    if (state != EQUALSPRESSEDLAST)         /*If the equals button was pressed last, we don't want perform the operation 
                                             immediately, but wait until the next operand press*/
    {
        //[--self performOperation: (bool) performOperation: (bool) equals
        [self performOperation : true : false];
    }
    else
    {
        operands.previousOperand = operands.currentOperand;
    }
    
    state = OPERANDPRESSEDLAST;
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
        
        if (state != OPERANDPRESSEDLAST)    //If the user has not pressed an operand before pressing the equals sing
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
            lblDetailDescription.text = [NSString stringWithFormat:@"%g",[self oppositeValue]];
        }
        else if (button.tag == SQUAREROOTBUTTON)   //Opposite Value || Square Root Operand ------ Respectively
        {
            operands.currentOperand = [self getOperand: button];
            
            [self performOperation : true : false];
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
            else                                        //In this case, two operands have been pressed consecutively.
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
        return [self add:num1 :num2];
    }
    else if (operand == SUBTRACTION)
    {
        return [self subtract:num1 :num2];
    }
    else if (operand == MULTIPLICATION)
    {
        return [self multiply:num1 :num2];
    }
    else if (operand == DIVISION)
    {
        return [self division:num1 :num2];
    }
    else if (operand == PERCENTAGE)     //When percentage is pressed then generally there are special calculations performed.  Ex - 250 X 5% is = to 5% of 250
    {
        operand = operands.previousOperand;
        reservedNumber = num1;
        
        if (operand == MULTIPLICATION)
        {
            reservedNumberForPercentPlusEqualsOperator = (reservedNumber / 100) * num2;
        }
        else if (operand == ADDITION) 
        {
            reservedNumberForPercentPlusEqualsOperator = reservedNumber + ((reservedNumber / 100) * num2);
        }
        else if (operand == SUBTRACTION)
        {
            reservedNumber = reservedNumber - ((reservedNumber / 100) * num2);
            reservedNumberForPercentPlusEqualsOperator = reservedNumber;
        }
        else if (operand == DIVISION)
        {
            reservedNumberForPercentPlusEqualsOperator = (reservedNumber / (num2 / 100));
        }
        else if (operand == NOOPERAND)
        {
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
        return [self sqrt];
    }
    else if (operand == SQUARE)     //Square the number
    {
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
    double num;
    
    if (operand == PERCENTPLUSEQUALS)
    {
        num = reservedNumber + currentNumber;
        lblDetailDescription.text = [NSString stringWithFormat:@"%g", num]; //Display the new number
        
        previousNumber = currentNumber;
        currentNumber = num;
    }
    else if (operand == PERCENTMINUSEQUALS)
    {
        num = reservedNumber - currentNumber;
        lblDetailDescription.text = [NSString stringWithFormat:@"%g", num]; //Display the new number
        
        previousNumber = currentNumber;
        currentNumber = num;
    }
    else if (operand == SQUARE)
    {
        num = [self square];        
        lblDetailDescription.text = [NSString stringWithFormat:@"%g", num]; //Display the new number
        
        previousNumber = currentNumber;
        currentNumber = num;
    }
    else if (operand == PERCENTPLUSNUM)
    {
        num = reservedNumberForPercentPlusEqualsOperator + (reservedNumber * ([lblDetailDescription.text doubleValue] / 100));
        lblDetailDescription.text = [NSString stringWithFormat:@"%g", num];
        
        previousNumber = currentNumber;
        currentNumber = num;
    }
    operands.previousOperand = operands.currentOperand;
    
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
            num = [self performSingularOperations];
          
            previousNumber = currentNumber;             /*These two lines are performed after every operation, to make sure
                                                        that we keep updating the currentNumber, but we keep
                                                        the previous number pressed*/
            currentNumber = num;
        }
        else if (operands.currentOperand == PERCENTAGE)
        {
            num = [self getAllInformationForCalculation:PERCENTAGE];
            previousNumber = currentNumber;
            currentNumber = num;
        }
        else if (!isnan(previousNumber))
        {
            if (state == EQUALSPRESSEDLAST) /*If the equal button was pressed then we perform the operation, 
                                             but don't change the CURRENTNUMBER variable, because if the user keeps 
                                             pressing the equal button we want to keep performing the operation with the 
                                             last number entered before operations began, which is what's stored in CURRENTNUMBER. */
            {
                num = [self getAllInformationForCalculation:operands.currentOperand];
                previousNumber = num;
            }
            else if (operands.previousOperand == operands.currentOperand)   /*If the user has entered the same operand more than once than we
                                                                             simply keep performing the same operation*/
            {
                num = [self getAllInformationForCalculation:operands.currentOperand];
                previousNumber = currentNumber;
                currentNumber = num;
            }
            else                            /*if the user has entered a different operand this time then the last operand entered, then we perform
                                             the first operand that was pressed.*/
            {
                num = [self getAllInformationForCalculation:operands.previousOperand];
                previousNumber = currentNumber;
                currentNumber = num;
            }
        }
        
        //If the user has pressed equals, than we make sure that when the user clicks on another operand, the calculation is not done automatically.
        //We do this by removing all the data except for the last number from the numberList array and copying it to the numberListCopy array.
        operands.previousOperand = operands.currentOperand;
        
        lblDetailDescription.text = [NSString stringWithFormat:@"%g", num]; //Display the new number
        
    }
    
    [numberList addObject:[[NSNumber alloc] initWithDouble:[lblDetailDescription.text doubleValue]]];
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
    }
    else if (numTimesClearPressed == 2)
    {
        previousNumber = NAN;
        currentNumber = NAN;
        operands.currentOperand = NOOPERAND;
        operands.previousOperand = NOOPERAND;
        numberList = [[NSMutableArray alloc] init];
        operatorList = [[NSMutableArray alloc] init];
        numTimesClearPressed = 0;
    }
    
}
//Performing a cost calculation
- (IBAction)costButtonPressed:(UIButton *)button {
    static double salesPrice = 0;
    double cost = 0;
    state = OPERANDPRESSEDLAST;
    mrcPressed = false;
    
    //SEL Pressed
    if (button.tag == SALESPRICEBUTTON)
    {
        if (cost == 0)
        {
            salesPrice = [lblDetailDescription.text doubleValue];
        }
    }
    else if (button.tag == SALESMARGINBUTTON)  //MAR pressed
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
    state = OPERANDPRESSEDLAST;
    mrcPressed = false;
    
    //CST Pressed
    if (button.tag == COSTPRICEBUTTON)
    {
        if (salesPrice == 0)
        {
            cost = [lblDetailDescription.text doubleValue];
        }
    }
    else if (button.tag == COSTMARGINBUTTON)  //MAR pressed
    {
        if (cost != 0)
        {
            salesPrice = cost / (1 - ([lblDetailDescription.text doubleValue] / 100));
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
    state = OPERANDPRESSEDLAST;
    mrcPressed = false;
    
    //CST Pressed
    if (button.tag == MARGINSALESBUTTON)
    {
        cost = [lblDetailDescription.text doubleValue];
    }
    else if (button.tag == MARGINCOSTBUTTON)  //MAR pressed
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
    
    if (button.tag == MEMORYCLEARBUTTON)
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
            lblDetailDescription.text = [[NSString alloc] initWithFormat:@"%Lg", storedValue];
            mrcPressed = true;
            
            [numberList addObject:[[NSNumber alloc]initWithDouble:storedValue]];
        }
    }
    else if (button.tag == MEMORYREMOVEBUTTON)
    {
        [numberList addObject:[[NSNumber alloc]initWithDouble:[lblDetailDescription.text doubleValue]]];
        //[--self performOperation: (bool) performOperation: (bool) equals
        [self performOperation:true:true];
        storedValue = storedValue - [lblDetailDescription.text doubleValue];
    }
    else if (button.tag == MEMORYADDBUTTON)
    {
        [numberList addObject:[[NSNumber alloc]initWithDouble:[lblDetailDescription.text doubleValue]]];
        //[--self performOperation: (bool) performOperation: (bool) equals
        [self performOperation:true:true];
        storedValue = storedValue + [lblDetailDescription.text doubleValue];

    }
    
    //state = OPERANDPRESSEDLAST;
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
