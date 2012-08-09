//
//  THMainViewController.m
//  Househunt
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THMainViewController.h"

@interface THMainViewController ()

@end

@implementation THMainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self performSelectorInBackground:@selector(performAsyncActions) withObject:nil];
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
	MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.labelText = @"Loading Overlay...";
	// Register for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(performAsyncActions) onTarget:self withObject:nil animated:YES];
}

-(void) performAsyncActions {
    NSDictionary *hoods = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"neighbourhoods" ofType:@"json"]] options:0 error:nil];
    
        
    neighbourhoods = [NSMutableDictionary dictionaryWithCapacity:800];
    for (NSString *hoodID in hoods) {
        THNeighbourhood *newHood = [[THNeighbourhood alloc] initWithID:hoodID coordinates:[hoods objectForKey:hoodID]];
        [neighbourhoods setObject:newHood forKey:hoodID];
    }
    
    [self performSelectorInBackground:@selector(flipsideViewControllerDidUpdate:) withObject:nil];
}

-(void)centerMap {
    [map removeOverlays:[map overlays]];
    
    for (THNeighbourhood *hood in [neighbourhoods allValues]) {
        [map addOverlay:hood.polygon];
    }
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    MKMapRect flyTo = MKMapRectNull;
    for (MKPolygon *poly in [map overlays]) {
        if (MKMapRectIsNull(flyTo)) {
            flyTo = [poly boundingMapRect];
        } else {
            flyTo = MKMapRectUnion(flyTo, [poly boundingMapRect]);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    [map setVisibleMapRect:flyTo animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    // we get here in order to draw any polygon
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
    polygonView.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
    for (THNeighbourhood *hood in [neighbourhoods allValues]) {
        if ([hood.polygon isEqual:overlay]) {
            polygonView.fillColor   = [UIColor colorWithRed:hood.crimeIndex*1.5 green:1-hood.crimeIndex blue:0.0 alpha:0.3+(0.3*hood.crimeIndex)];
            polygonView.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
            break;
        }
    }
    polygonView.lineWidth = 1;
    return polygonView;
}



#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(THFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
    
}

-(void)flipsideViewControllerDidUpdate:(THFlipsideViewController *)controller {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefs = [[defaults objectForKey:@"userprefs"] mutableCopy];
    NSMutableDictionary *enabled = [[defaults objectForKey:@"enabledPrefs"] mutableCopy];
    /* For combined
     0 = crime
     1 = primary schooling
     2 = secondary
     3 = house price
     4 = employment
     */
    NSMutableString *URL = [@"http://vps.boredomcode.net/YRSApi/combi/" mutableCopy];
    
    //@"crimes",@"employment",@"houseprices",@"ks2",@"ks4"
    for (NSString *str in prefs) {
        if ([[enabled objectForKey:str] boolValue]) {
            if ([str isEqualToString:@"crimes"]) {
                [URL appendString:@"0"];
            } else if ([str isEqualToString:@"employment"]) {
                [URL appendString:@"4"];
            } else if ([str isEqualToString:@"houseprices"]) {
                [URL appendString:@"3"];
            } else if ([str isEqualToString:@"ks2"]) {
                [URL appendString:@"1"];
            } else {
                [URL appendString:@"2"];
            }
        }
    }
    
    NSLog(@"URL: %@",URL);
    //URL = [@"http://vps.boredomcode.net/YRSApi/crimes/" mutableCopy];
    NSURL *theURL =  [[NSURL alloc]initWithString:URL];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:theURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
    NSDictionary * crimeData = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];

    
    for (NSString* hoodID in crimeData) {
        THNeighbourhood *hood = [neighbourhoods objectForKey:hoodID];
        hood.crimeIndex = [[crimeData objectForKey:hoodID] floatValue];
    }
    
    [self performSelectorOnMainThread:@selector(centerMap) withObject:nil waitUntilDone:NO];
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        THFlipsideViewController *controller = [[THFlipsideViewController alloc] initWithNibName:@"THFlipsideViewController" bundle:nil];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:controller animated:YES];
    } else {
        if (!self.flipsidePopoverController) {
            THFlipsideViewController *controller = [[THFlipsideViewController alloc] initWithNibName:@"THFlipsideViewController" bundle:nil];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}


- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
}


@end
