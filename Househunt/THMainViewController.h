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

@interface THMainViewController : UIViewController <THFlipsideViewControllerDelegate, UIPopoverControllerDelegate, MKMapViewDelegate, MBProgressHUDDelegate> {
    IBOutlet MKMapView *map;
    NSMutableDictionary *neighbourhoods;
    NSDictionary *currentData;
    THCustomPointAnnotation *mainPoint;
    NSMutableArray *currentPins;
    UIPopoverController *annotationPopover;
    NSDictionary *displayedOverlaysEnabled;
    NSArray *displayedOverlaysOrdering;
    float displayedBudget;
}

- (void)performLaunchActions;
- (IBAction)showInfo:(id)sender;
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;
- (void)readdOverlays;
- (void)showHouseDetails:(UIButton *)sender;
- (void)updateAreaInfo;
- (void)updateHouseInfo;
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer;
- (BOOL)isMapDataCurrent;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;


@end
