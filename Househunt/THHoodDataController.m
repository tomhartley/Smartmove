//
//  THHoodDataController.m
//  Smartmove
//
//  Created by Tom Hartley on 10/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THHoodDataController.h"

@interface THHoodDataController ()

@end

@implementation THHoodDataController
@synthesize dataFromAPI;

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
    [self reloadDataFromDict];
}

-(void)reloadDataFromDict {
    // Do any additional setup after loading the view from its nib.
    [chartView clearItems];
    
    //[chartView setGradientFillStart:0.3 andEnd:1.0];
    //[chartView setGradientFillColor:PieChartItemColorMake(0.0, 0.0, 0.0, 1)];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setMaximumFractionDigits:0];
    housePrice.text = [currencyFormatter stringFromNumber:[dataFromAPI objectForKey:@"avgHousePrice"]];
    
    
    borough.text = [dataFromAPI objectForKey:@"borough_name"];
    unemployment.text = [NSString stringWithFormat:@"%@%%",[[dataFromAPI objectForKey:@"unploymentPercent"] stringValue]];
    totalCrimes.text = [[dataFromAPI objectForKey:@"crimeTotals"] stringValue];
    
    NSDictionary *crimeData = [dataFromAPI objectForKey:@"crime"];
    
    PieChartItemColor col1 = PieChartItemColorMake(0,0,0, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"burglary"] integerValue] withColor:col1];
    UIColor *colour1 = [UIColor colorWithRed:col1.red green:col1.green blue:col1.blue alpha:col1.alpha];
    viewBurglary.backgroundColor = colour1;
    
    PieChartItemColor col2 = PieChartItemColorMake(1,1,0, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"anti_social_behaviour"] integerValue] withColor:col2];
    UIColor *colour2 = [UIColor colorWithRed:col2.red green:col2.green blue:col2.blue alpha:col2.alpha];
    viewAntisocialBehaviour.backgroundColor = colour2;
    
    PieChartItemColor col3 = PieChartItemColorMake(0.5,0,0.5, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"robbery"] integerValue] withColor:col3];
    UIColor *colour3 = [UIColor colorWithRed:col3.red green:col3.green blue:col3.blue alpha:col3.alpha];
    viewRobbery.backgroundColor = colour3;
    
    PieChartItemColor col4 = PieChartItemColorMake(0,1,1, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"vehicle_crime"] integerValue] withColor:col4];
    UIColor *colour4 = [UIColor colorWithRed:col4.red green:col4.green blue:col4.blue alpha:col4.alpha];
    viewVehicleCrime.backgroundColor = colour4;
    
    PieChartItemColor col5 = PieChartItemColorMake(1,0,0, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"violent_crime"] integerValue] withColor:col5];
    UIColor *colour5 = [UIColor colorWithRed:col5.red green:col5.green blue:col5.blue alpha:col5.alpha];
    viewViolentCrime.backgroundColor = colour5;
    
    PieChartItemColor col6 = PieChartItemColorMake(0,1,0, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"public_disorder"] integerValue] withColor:col6];
    UIColor *colour6 = [UIColor colorWithRed:col6.red green:col6.green blue:col6.blue alpha:col6.alpha];
    viewPublicDisorder.backgroundColor = colour6;
    
    PieChartItemColor col7 = PieChartItemColorMake(0,0,1, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"shoplifting"] integerValue] withColor:col7];
    UIColor *colour7 = [UIColor colorWithRed:col7.red green:col7.green blue:col7.blue alpha:col7.alpha];
    viewShoplifting.backgroundColor = colour7;
    
    PieChartItemColor col8 = PieChartItemColorMake(0.2,0.651,0.569, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"criminal_damage"] integerValue] withColor:col8];
    UIColor *colour8 = [UIColor colorWithRed:col8.red green:col8.green blue:col8.blue alpha:col8.alpha];
    viewCriminalDamage.backgroundColor = colour8;
    
    PieChartItemColor col9 = PieChartItemColorMake(1,0.5,0, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"other_theft"] integerValue] withColor:col9];
    UIColor *colour9 = [UIColor colorWithRed:col9.red green:col9.green blue:col9.blue alpha:col9.alpha];
    viewOtherTheft.backgroundColor = colour9;
    
    PieChartItemColor col10 = PieChartItemColorMake(1,0,0.5, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"drugs"] integerValue] withColor:col10];
    UIColor *colour10 = [UIColor colorWithRed:col10.red green:col10.green blue:col10.blue alpha:col10.alpha];
    viewDrugs.backgroundColor = colour10;
    
    PieChartItemColor col11 = PieChartItemColorMake(0.529,0.345,0.827, 0.8);
    [chartView addItemValue:[[crimeData objectForKey:@"other"] integerValue] withColor:col11];
    UIColor *colour11 = [UIColor colorWithRed:col11.red green:col11.green blue:col11.blue alpha:col11.alpha];
    viewOther.backgroundColor = colour11;
    
    
    chartView.alpha = 0.0;
    [chartView setHidden:NO];
    [chartView setNeedsDisplay];
    
    // Animate the fade-in
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    chartView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction) dismissModal {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
