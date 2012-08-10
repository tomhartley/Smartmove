//
//  THHouseDetailsController.m
//  Househunt
//
//  Created by Tom Hartley on 08/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THHouseDetailsController.h"

@interface THHouseDetailsController ()

@end

@implementation THHouseDetailsController

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
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    budget.value = [[defaults objectForKey:@"budget"] floatValue];
    budgetLabel.text = [NSString stringWithFormat:@"£%.0f",budget.value];
    bedrooms.selectedSegmentIndex = [defaults integerForKey:@"bedrooms"];
    bathrooms.selectedSegmentIndex = [defaults integerForKey:@"bathrooms"];
    flatOrHouse.selectedSegmentIndex = [defaults integerForKey:@"houseOrFlat"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)dataUpdated {
    budgetLabel.text = [NSString stringWithFormat:@"£%.0f",budget.value];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:budget.value forKey:@"budget"];
    [defaults setInteger:bedrooms.selectedSegmentIndex forKey:@"bedrooms"];
    [defaults setInteger:bathrooms.selectedSegmentIndex forKey:@"bathrooms"];
    [defaults setInteger:flatOrHouse.selectedSegmentIndex forKey:@"houseOrFlat"];
    [defaults synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)close {
    [self dismissModalViewControllerAnimated:YES];
}

@end
