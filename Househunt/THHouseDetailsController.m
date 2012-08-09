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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)close {
    [self dismissModalViewControllerAnimated:YES];
}

@end
