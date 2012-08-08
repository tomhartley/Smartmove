//
//  THMainViewController.h
//  Househunt
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "THFlipsideViewController.h"
#import "THNeighbourhood.h"

@interface THMainViewController : UIViewController <THFlipsideViewControllerDelegate, MKMapViewDelegate> {
    IBOutlet MKMapView *map;
    NSMutableDictionary *neighbourhoods;
}

- (IBAction)showInfo:(id)sender;
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;


@end
