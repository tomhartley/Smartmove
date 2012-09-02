//
//  THMainViewController.m
//  Smartmove
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THMainViewController.h"
#import "TSMiniWebBrowser.h"
#import "THHoodDataController.h"
#import "THCustomPinAnnotationView.h"

@interface THMainViewController ()

@end

@implementation THMainViewController

@synthesize flipsidePopoverController = _flipsidePopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPins = [NSMutableArray array];
    //[self performSelectorInBackground:@selector(performAsyncActions) withObject:nil];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //user needs to press for 0.5 seconds
    [map addGestureRecognizer:lpgr];

    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
	MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.labelText = @"Loading...";
	// Register for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(performLaunchActions) onTarget:self withObject:nil animated:YES];
}


- (void)mapView:(MKMapView *)mapView annotationView:(THCustomPinAnnotationView *)view calloutAccessoryControlTapped:(UIButton *)control {
    if (view.annotation == mainPoint) {
        [mapView deselectAnnotation:view.annotation animated:YES];
        
        THHoodDataController *ycvc = [[THHoodDataController alloc] initWithNibName:@"THHoodDataController" bundle:nil];
        ycvc.dataFromAPI = [(THCustomPointAnnotation*)[view annotation] dataDict];
        [ycvc reloadDataFromDict];

        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [self presentViewController:ycvc animated:YES completion:nil];
        } else {
            UIPopoverController *poc = [[UIPopoverController alloc] initWithContentViewController:ycvc];
            
            //hold ref to popover in an ivar
            annotationPopover = poc;
            
            //size as needed
            poc.popoverContentSize = CGSizeMake(320, 460);
            //show the popover next to the annotation view (pin)
            [poc presentPopoverFromRect:view.bounds inView:view 
               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            poc.popoverContentSize = CGSizeMake(320, 0);
            [poc setPopoverContentSize:CGSizeMake(320, 460) animated:YES];
        }
    }
}

- (void)showHouseDetails:(UIButton *)sender {
    //super successful web browser code is super successful -.-
    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:[sender titleForState:UIControlStateNormal]]];
    webBrowser.modalPresentationStyle = UIModalPresentationPageSheet;
    webBrowser.mode = TSMiniWebBrowserModeModal;
    [self presentModalViewController:webBrowser animated:YES];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[sender titleForState:UIControlStateNormal]]];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [gestureRecognizer locationInView:map];   
    CLLocationCoordinate2D touchMapCoordinate = [map convertPoint:touchPoint toCoordinateFromView:map];
    THCustomPointAnnotation *annot = [[THCustomPointAnnotation alloc] init];
    
    if (mainPoint) {
        [map removeAnnotation:mainPoint];
    }
    
    annot.coordinate = touchMapCoordinate;
    mainPoint = annot;
    [map addAnnotation:mainPoint];
    
    //Get area data for the exact location the user dropped a pin
    
    [self updateAreaInfo];
    
    //Get data for houses near the main point where the user dropped a pin

    [self updateHouseInfo];
}

- (void)updateAreaInfo {
    if (mainPoint) {        
        //Get area data for the exact location the user dropped a pin
        NSMutableString *areaDataString = [@"http://yrs2012.eu01.aws.af.cm/api/areadata?" mutableCopy];
        [areaDataString appendFormat:@"lat=%f&lon=%f",mainPoint.coordinate.latitude,mainPoint.coordinate.longitude];
        NSURL *areaDataURL = [NSURL URLWithString:areaDataString];
        NSLog(@"%@",areaDataString);
        NSURLRequest *areaDataRequest = [NSURLRequest requestWithURL:areaDataURL];
        [NSURLConnection sendAsynchronousRequest:areaDataRequest 
                                           queue:[NSOperationQueue mainQueue] 
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   NSDictionary *areaData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   if (![[areaData objectForKey:@"borough_name"] isEqual:[NSNull null]]) {
                                       mainPoint.title = [NSString stringWithFormat:@"Neighbourhood in %@",[areaData objectForKey:@"borough_name"]];
                                       mainPoint.dataDict = areaData;
                                   } else {
                                       mainPoint.title = nil;
                                   }
                                   [[map viewForAnnotation:mainPoint] setEnabled:YES];
                               }];

    }
}

- (void)updateHouseInfo {
    if (mainPoint) {        
        NSMutableString *urlString = [@"http://yrs2012.eu01.aws.af.cm/api/listings?" mutableCopy];
        [urlString appendFormat:@"lat=%f&lon=%f&",mainPoint.coordinate.latitude,mainPoint.coordinate.longitude];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger bathrooms = [defaults integerForKey:@"bathrooms"]+1;
        NSInteger bedrooms = [defaults integerForKey:@"bedrooms"]+1;
        NSInteger houseOrFlat = [defaults integerForKey:@"houseOrFlat"];
        float budget = [defaults floatForKey:@"budget"];
        //the stored values for bedrooms and bathrooms are 0 indexed, so add one to get the actual value
        [urlString appendFormat:@"budget=%.0f&bedrooms=%d&bathrooms=%d",budget,bedrooms,bathrooms];
        switch (houseOrFlat) {
            case 0:
                [urlString appendString:@"&type=house"];
                break;
            case 1:
                [urlString appendString:@"&type=flat"];
                break;
            case 2:
                [urlString appendString:@"&type=all"];
                break;
            default:
                break;
        }
        NSLog(@"%@",urlString);
        NSURL *theURL =  [[NSURL alloc]initWithString:urlString];
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:theURL];
        [NSURLConnection sendAsynchronousRequest:theRequest 
                                           queue:[NSOperationQueue mainQueue] 
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   [map removeAnnotations:currentPins];
                                   [currentPins removeAllObjects];
                                   NSArray * properties = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   if ([properties count] == 0) {
                                       MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                       
                                       // Configure for text only and offset down
                                       hud.mode = MBProgressHUDModeText;
                                       hud.labelText = @"No properties found";
                                       hud.margin = 30.f;
                                       hud.removeFromSuperViewOnHide = YES;
                                       
                                       [hud hide:YES afterDelay:1];
                                       return;
                                   }
                                   for (NSDictionary *dict in properties) {
                                       CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[dict objectForKey:@"lat"] doubleValue], [[dict objectForKey:@"lon"] doubleValue]);
                                       THCustomPointAnnotation *houseAnnotation = [[THCustomPointAnnotation alloc] init];
                                       houseAnnotation.coordinate = coord;
                                       houseAnnotation.title = [dict objectForKey:@"title"];
                                       NSNumber *priceNumber = [NSNumber numberWithInteger:[[dict objectForKey:@"price"] integerValue]];
                                       
                                       NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
                                       [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                                       [currencyFormatter setMaximumFractionDigits:0];
                                       houseAnnotation.subtitle = [currencyFormatter stringFromNumber:priceNumber];
                                       [currentPins addObject:houseAnnotation];
                                       [map addAnnotation:houseAnnotation];
                                       houseAnnotation.urlToShow = [dict objectForKey:@"url"];
                                       if ([[dict objectForKey:@"type"] isEqualToString:@"house"]) {
                                           houseAnnotation.propertyType = THPropertyTypeHouse;
                                       } else if ([[dict objectForKey:@"type"] isEqualToString:@"flat"]){
                                           houseAnnotation.propertyType = THPropertyTypeFlat;
                                       } else {
                                           houseAnnotation.propertyType = THPropertyTypeUndefined;
                                       }
                                   }
                                   // Position the map so that all overlays and annotations are visible on screen.
                                   MKMapRect flyTo = MKMapRectNull;
                                   MKMapPoint main =  MKMapPointForCoordinate(mainPoint.coordinate);
                                   flyTo = MKMapRectMake(main.x, main.y, 0, 0);
                                   for (MKPointAnnotation *poly in currentPins) {
                                       MKMapPoint pt = MKMapPointForCoordinate(poly.coordinate);
                                       flyTo = MKMapRectUnion(flyTo, MKMapRectMake(pt.x, pt.y, 0, 0));
                                   }
                                   [map setVisibleMapRect:flyTo animated:YES];
                                   
                                   
                               }];
    }
}
- (void) performLaunchActions {

    NSDictionary *hoods = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"savedHoods" ofType:@""]];
    
    neighbourhoods = [NSMutableDictionary dictionaryWithCapacity:800];
    for (NSString *hoodID in hoods) {
        THNeighbourhood *newHood = [[THNeighbourhood alloc] initWithID:hoodID coordinates:[hoods objectForKey:hoodID]];
        [neighbourhoods setObject:newHood forKey:hoodID];
    }
    
    [self downloadCombiData];
    [self performSelectorOnMainThread:@selector(centerMap) withObject:nil waitUntilDone:YES];
}

- (void)centerMap {
    // Walk the list of overlays and create a MKMapRect that
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

- (void)readdOverlays {
    [map removeOverlays:[map overlays]];
    for (THNeighbourhood *hood in [neighbourhoods allValues]) {
        [map addOverlay:hood.polygon];
    }
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
    // we get here in order to draw any polygon (these are not the pins, these are the red-green overlays for each neighbourhood)
    if ([overlay isMemberOfClass:[MKPolygon class]]) {
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
        polygonView.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
        for (THNeighbourhood *hood in [neighbourhoods allValues]) {
            if ([hood.polygon isEqual:overlay]) {
                float redColor;
                float greenColor;
                if (hood.colourIndex < 0.5) {
                    redColor = hood.colourIndex * 2;
                    greenColor = 1;
                } else {
                    redColor = 1;
                    greenColor = (1-hood.colourIndex) * 2;
                }
                polygonView.fillColor   = [UIColor colorWithRed:redColor green:greenColor blue:0.0 alpha:0.3+(0.3*hood.colourIndex)];
                polygonView.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
                break;
            }
        }
        polygonView.lineWidth = 2;
        return polygonView;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(THCustomPointAnnotation *)annotation {
    //These are the pins which are placed by the user & application
    
    //Ensure it isn't the user-current-location annotation
    if ([[annotation class] isSubclassOfClass:[MKPointAnnotation class]]) {
        THCustomPinAnnotationView *pin = [[THCustomPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        pin.animatesDrop = YES;
        if ([annotation isEqual:mainPoint]) { //Main point which the user dropped
            pin.pinColor = MKPinAnnotationColorPurple;
            if (annotation.dataDict) { //If annotation has data associated with it
                pin.enabled = YES;
            } else {
                pin.enabled = NO; //Will get enabled later by updateAreaInfo: when data downloaded
            }
            pin.canShowCallout = YES;
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pin.rightCalloutAccessoryView = rightButton;
            pin.draggable = YES; //FIXME: needs more work
        } else { //This is a pin representing a house
            pin.pinColor = MKPinAnnotationColorRed;
            pin.canShowCallout = YES;
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton setTitle:annotation.urlToShow forState:UIControlStateNormal];
            [rightButton addTarget:self
                            action:@selector(showHouseDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            pin.rightCalloutAccessoryView = rightButton;
            if (annotation.propertyType == THPropertyTypeHouse) {
                pin.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"53-house-white"]];
            } else if (annotation.propertyType == THPropertyTypeFlat) {
                pin.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"177-building-white"]];
            }
        }
        return pin;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        [self updateAreaInfo];
        [self updateHouseInfo];
    }
}

#pragma mark - Flipside View Controller

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self flipsideViewControllerDidUpdate:(THFlipsideViewController *)popoverController.contentViewController];
}

- (void)flipsideViewControllerDidFinish:(THFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
    [self flipsideViewControllerDidUpdate:controller];    
}

- (void)downloadCombiData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefs = [[defaults objectForKey:@"userprefs"] mutableCopy];
    NSMutableDictionary *enabled = [[defaults objectForKey:@"enabledPrefs"] mutableCopy];
    float budget = [defaults floatForKey:@"budget"];
    displayedBudget = budget;
    budget = 0;
    if (!prefs || !enabled) {
        prefs = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"crimes",@"employment",@"houseprices",@"ks2",@"ks4", nil]];
        enabled = [[NSMutableDictionary alloc] initWithCapacity:5];
        for (NSString *str in prefs) {
            [enabled setObject:[NSNumber numberWithBool:NO] forKey:str];
        }
        [enabled setObject:[NSNumber numberWithBool:YES] forKey:@"crimes"];
        
        [defaults setObject:prefs forKey:@"userprefs"];
        [defaults setObject:enabled forKey:@"enabledPrefs"];
        [defaults synchronize];

    }
    
    
    /* For combined:
     0 = crime
     1 = primary schooling
     2 = secondary
     3 = house price
     4 = employment
     */
    
    NSMutableString *URL = [@"http://yrs2012.eu01.aws.af.cm/api/combi/" mutableCopy];
    
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
    
    if (budget != 0) {
        [URL appendFormat:@"/%.0f",budget];
    }
    
    
    NSLog(@"URL: %@",URL);
    NSURL *theURL =  [[NSURL alloc]initWithString:URL];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:theURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
    NSDictionary * combiData = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
    displayedOverlaysEnabled = enabled;
    displayedOverlaysOrdering = prefs;
    for (NSString* hoodID in combiData) {
        THNeighbourhood *hood = [neighbourhoods objectForKey:hoodID];
        hood.colourIndex = [[combiData objectForKey:hoodID] floatValue];
    }
    [self performSelectorOnMainThread:@selector(readdOverlays) withObject:nil waitUntilDone:NO];
}
     
- (void)flipsideViewControllerDidUpdate:(THFlipsideViewController *)controller {
    if (![self isMapDataCurrent]) {
        MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        // Register for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        ;
        HUD.yOffset = map.frame.size.height/2-50; //FIXME for iPhone.. I think
        //HUD.yOffset = 0;
        // Show the HUD while the provided method executes in a new thread
        HUD.userInteractionEnabled = NO;
        [HUD showAnimated:YES whileExecutingBlock:^{
            //[self performSelectorInBackground:@selector(downloadCombiData) withObject:nil];
            [self downloadCombiData];
        }];
        [self updateHouseInfo];
    }
}

- (BOOL)isMapDataCurrent {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefs = [[defaults objectForKey:@"userprefs"] mutableCopy];
    NSMutableDictionary *enabled = [[defaults objectForKey:@"enabledPrefs"] mutableCopy];
    float budget = [defaults floatForKey:@"budget"];
    if ([displayedOverlaysEnabled isEqualToDictionary:enabled] && [displayedOverlaysOrdering isEqualToArray:prefs] && ((budget == displayedBudget) || ![[enabled objectForKey:@"houseprices"] boolValue])) {
        return YES;
    }
    return NO;
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
            self.flipsidePopoverController.delegate = self;
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
            [self flipsideViewControllerDidUpdate:(THFlipsideViewController *)self.flipsidePopoverController.contentViewController];
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
