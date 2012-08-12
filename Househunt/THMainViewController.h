//
//  THMainViewController.h
//  Smartmove
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "THFlipsideViewController.h"
#import "THNeighbourhood.h"
#import "MBProgressHUD.h"
#import "THCustomPointAnnotation.h"

@interface THMainViewController : UIViewController <THFlipsideViewControllerDelegate, MKMapViewDelegate, MBProgressHUDDelegate> {
    IBOutlet MKMapView *map;
    NSMutableDictionary *neighbourhoods;
    NSDictionary *currentData;
    MKPointAnnotation *mainPoint;
    NSMutableArray *currentPins;
    UIPopoverController *annotationPopover;
}

- (IBAction)showInfo:(id)sender;
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;
-(void)redoOverlays;
-(void)showHouseDetails:(UIButton *)sender;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;


@end
