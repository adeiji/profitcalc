//
//  FTWHelpViewController.m
//  Profit Management Calculator
//
//  Created by Ade on 9/11/13.
//  Copyright (c) 2013 Ade. All rights reserved.
//

#import "FTWHelpViewController.h"

@interface FTWHelpViewController ()
{
    UIView *helpView;
}

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
    
    helpView = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if ([self.scrollView.subviews containsObject:helpView])
    {
        [helpView removeFromSuperview];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
        {
            helpView = [[[NSBundle mainBundle] loadNibNamed:@"HelpViewiPadLandscape" owner:self options:nil] objectAtIndex:0];
        }
        else if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
        {
            helpView = [[[NSBundle mainBundle] loadNibNamed:@"HelpViewiPad" owner:self options:nil] objectAtIndex:0];
        }
        
        self.scrollView.contentSize = helpView.frame.size;
    }
    else
    {
        helpView = [[[NSBundle mainBundle] loadNibNamed:@"HelpView" owner:self options:nil] objectAtIndex:0];
        helpView.frame = CGRectMake(helpView.frame.origin.x, helpView.frame.origin.y, self.scrollView.frame.size.width, helpView.frame.size.height);
        self.scrollView.contentSize = CGSizeMake( [[[UIApplication sharedApplication] keyWindow] frame].size.width, helpView.frame.size.height);
    }
    
    [self.scrollView addSubview:helpView];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.alwaysBounceHorizontal = false;
    self.scrollView.showsHorizontalScrollIndicator = false;
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIView *viewToRemove = nil;
    //Get the helpview from the scrollview subviews and remove it from the subviews
    for (UIView *view in self.scrollView.subviews)
    {
        if ([view isEqual:helpView])
        {
            viewToRemove = helpView;
        }
    }
    
    //Remove the view (helpview) from subview
    [viewToRemove removeFromSuperview];
    //Get the orientation and change the view accordingly
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        helpView = [[[NSBundle mainBundle] loadNibNamed:@"HelpViewiPadLandscape" owner:self options:nil] objectAtIndex:0];
    }
    else
    {
        helpView = [[[NSBundle mainBundle] loadNibNamed:@"HelpViewiPad" owner:self options:nil] objectAtIndex:0];
    }
    //Readd the helpView to the scrollView
    [self.scrollView addSubview:helpView];
    self.scrollView.contentSize = helpView.frame.size;
    
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
