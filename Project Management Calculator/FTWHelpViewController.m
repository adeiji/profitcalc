//
//  FTWHelpViewController.m
//  Profit Management Calculator
//
//  Created by Ade on 9/11/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "FTWHelpViewController.h"

@interface FTWHelpViewController ()

@end

@implementation FTWHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIView *helpView = [[[NSBundle mainBundle] loadNibNamed:@"HelpView" owner:self options:nil] objectAtIndex:0];
    
    self.scrollView.contentSize = helpView.frame.size;
    [self.scrollView addSubview:helpView];
    self.scrollView.scrollEnabled = YES;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
