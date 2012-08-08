//
//  THMainViewController.m
//  Househunt
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THMainViewController.h"
#import "parseCSV.h"
@interface THMainViewController ()

@end

@implementation THMainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelectorInBackground:@selector(performAsyncActions) withObject:nil];
}

-(void) performAsyncActions {
    NSURL *theURL =  [[NSURL alloc]initWithString:@"http://vps.boredomcode.net/YRSApi/crimes"];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:theURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
    NSArray * locations = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
    neighbourhoods = [NSMutableDictionary dictionaryWithCapacity:800];
    for (NSDictionary *dict in locations) {
        THNeighbourhood *newHood = [[THNeighbourhood alloc] initWithID:[dict objectForKey:@"neighbourhoodCode"]];
        [newHood setCrimeIndex:[[dict objectForKey:@"data"] floatValue]];
        [neighbourhoods setObject:newHood forKey:newHood.ID];
    }
    
    [self performSelectorOnMainThread:@selector(centerMap) withObject:nil waitUntilDone:NO];
}

-(void)centerMap {
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    // we get here in order to draw any polygon
    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
    polygonView.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
    for (THNeighbourhood *hood in [neighbourhoods allValues]) {
        if ([hood.polygon isEqual:overlay]) {
            polygonView.fillColor   = [UIColor colorWithRed:hood.crimeIndex green:1-hood.crimeIndex blue:0.0 alpha:0.8];
            break;
        }
    }
    
    polygonView.strokeColor = [UIColor colorWithRed:0 green:0.0 blue:0.0 alpha:0.2];
    
    polygonView.lineWidth = 0.1;
    
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

@end
