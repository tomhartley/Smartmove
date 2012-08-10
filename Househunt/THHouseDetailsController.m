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
    NSNumber *budgetNumber = [NSNumber numberWithFloat:[[defaults objectForKey:@"budget"] floatValue]];
    NSLog(@"READ: %@",budgetNumber);
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    budget.value = [budgetNumber floatValue];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setRoundingIncrement:[NSNumber numberWithInt:10000]];
    currencyFormatter.roundingMode = NSNumberFormatterRoundHalfEven;
    [currencyFormatter setMaximumFractionDigits:0];
    budgetLabel.text = [currencyFormatter stringFromNumber:budgetNumber];
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
    NSNumber *budgetNumber = [NSNumber numberWithFloat:budget.value];
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setRoundingIncrement:[NSNumber numberWithInt:10000]];
    currencyFormatter.roundingMode = NSNumberFormatterRoundHalfEven;
    [currencyFormatter setMaximumFractionDigits:0];
    budgetLabel.text = [currencyFormatter stringFromNumber:budgetNumber];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"SAVED:%f",budget.value);
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
