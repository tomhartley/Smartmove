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
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //user needs to press for 0.5 seconds
    [map addGestureRecognizer:lpgr];

    
	MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.labelText = @"Updating...";
	// Register for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(performAsyncActions) onTarget:self withObject:nil animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(THCustomPointAnnotation *)annotation {
    if ([[annotation class] isSubclassOfClass:[MKPointAnnotation class]]) {
        THCustomPinAnnotationView *pin = [[THCustomPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        pin.animatesDrop = YES;
        if ([annotation isEqual:mainPoint]) {
            pin.pinColor = MKPinAnnotationColorPurple;
            pin.canShowCallout = YES;
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pin.dataDict = annotation.dataDict;
            pin.rightCalloutAccessoryView = rightButton;
        } else {
            pin.pinColor = MKPinAnnotationColorRed;
            pin.canShowCallout = YES;
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton setTitle:annotation.urlToShow forState:UIControlStateNormal];
            [rightButton addTarget:self
                            action:@selector(showHouseDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            pin.rightCalloutAccessoryView = rightButton;
            if (annotation.propertyType = THPropertyTypeHouse) {
                pin.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"53-house-white"]];
            } else if (annotation.propertyType = THPropertyTypeFlat) {
                pin.leftCalloutAccessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"177-building-white"]];
            }
        }
        return pin;
    }
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(THCustomPinAnnotationView *)view calloutAccessoryControlTapped:(UIButton *)control {
    if (view.leftCalloutAccessoryView == nil) {
        [mapView deselectAnnotation:view.annotation animated:YES];
        
        THHoodDataController *ycvc = [[THHoodDataController alloc] initWithNibName:@"THHoodDataController" bundle:nil];
        ycvc.dataFromAPI = view.dataDict;
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
        }
    }
}

-(void)showHouseDetails:(UIButton *)sender {
    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:[sender titleForState:UIControlStateNormal]]];
    webBrowser.modalPresentationStyle = UIModalPresentationPageSheet;
    webBrowser.mode = TSMiniWebBrowserModeModal;
    [self presentModalViewController:webBrowser animated:YES];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint touchPoint = [gestureRecognizer locationInView:map];   
    CLLocationCoordinate2D touchMapCoordinate = [map convertPoint:touchPoint toCoordinateFromView:map];
    THCustomPointAnnotation *annot = [[THCustomPointAnnotation alloc] init];
    
    annot.coordinate = touchMapCoordinate;
    
    if (mainPoint) {
        [map removeAnnotation:mainPoint];
    }
    mainPoint = annot;
    
    NSMutableString *areaDataString = [@"http://yrs2012.eu01.aws.af.cm//api/areadata?" mutableCopy];
    [areaDataString appendFormat:@"lat=%f&lon=%f",touchMapCoordinate.latitude,touchMapCoordinate.longitude];
    NSURL *areaDataURL = [NSURL URLWithString:areaDataString];
    NSLog(@"%@",areaDataString);
    NSURLRequest *areaDataRequest = [NSURLRequest requestWithURL:areaDataURL];
    [NSURLConnection sendAsynchronousRequest:areaDataRequest 
                                       queue:[NSOperationQueue mainQueue] 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSDictionary *areaData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               annot.title = [NSString stringWithFormat:@"Neighbourhood in %@",[areaData objectForKey:@"borough_name"]];
                               annot.dataDict = areaData;
                               [map addAnnotation:annot];
                           }];
    

    
    //NSMutableString *urlString = [@"http://yrs2012.eu01.aws.af.cm/api/listings?" mutableCopy];

    NSMutableString *urlString = [@"http://yrs2012.eu01.aws.af.cm/api/listings?" mutableCopy];
    [urlString appendFormat:@"lat=%f&lon=%f&",touchMapCoordinate.latitude,touchMapCoordinate.longitude];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [urlString appendFormat:@"budget=%.0f&bedrooms=%d&bathrooms=%d",[defaults floatForKey:@"budget"],[defaults integerForKey:@"bedrooms"]+1, [defaults integerForKey:@"bathrooms"]+1];
    switch ([defaults integerForKey:@"houseOrFlat"]) {
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


-(void) performAsyncActions {
    NSDictionary *hoods = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"neighbourhoods" ofType:@"json"]] options:0 error:nil];
    
        
    neighbourhoods = [NSMutableDictionary dictionaryWithCapacity:800];
    for (NSString *hoodID in hoods) {
        THNeighbourhood *newHood = [[THNeighbourhood alloc] initWithID:hoodID coordinates:[hoods objectForKey:hoodID]];
        [neighbourhoods setObject:newHood forKey:hoodID];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefs = [[defaults objectForKey:@"userprefs"] mutableCopy];
    NSMutableDictionary *enabled = [[defaults objectForKey:@"enabledPrefs"] mutableCopy];
    float budget = [defaults floatForKey:@"budget"];
    /* For combined
     0 = crime
     1 = primary schooling
     2 = secondary
     3 = house price
     4 = employment
     */
    NSMutableString *URL = [@"http://yrs2012.eu01.aws.af.cm/api/combi/" mutableCopy];
    
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
    
    if (budget != 0) {
        [URL appendFormat:@"/%.0f",budget];
    }
    
    NSLog(@"URL: %@",URL);
    NSURL *theURL =  [[NSURL alloc]initWithString:URL];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:theURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
    if (returnData) {
        NSDictionary * crimeData = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
        for (NSString* hoodID in crimeData) {
            THNeighbourhood *hood = [neighbourhoods objectForKey:hoodID];
            hood.crimeIndex = [[crimeData objectForKey:hoodID] floatValue];
        }
        [self centerMap];

    }
    
}

-(void)centerMap {
    [self redoOverlays];
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
    if ([overlay isMemberOfClass:[MKPolygon class]]) {
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
        polygonView.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
        for (THNeighbourhood *hood in [neighbourhoods allValues]) {
            if ([hood.polygon isEqual:overlay]) {
                float redColor;
                float greenColor;
                if (hood.crimeIndex < 0.5) {
                    redColor = hood.crimeIndex * 2;
                    greenColor = 1;
                } else {
                    redColor = 1;
                    greenColor = (1-hood.crimeIndex) * 2;
                }
                polygonView.fillColor   = [UIColor colorWithRed:redColor green:greenColor blue:0.0 alpha:0.3+(0.3*hood.crimeIndex)];
                polygonView.strokeColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
                break;
            }
        }
        polygonView.lineWidth = 2;
        return polygonView;
    }
    return nil;
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

-(void)redoOverlays {
    [map removeOverlays:[map overlays]];
    for (THNeighbourhood *hood in [neighbourhoods allValues]) {
        [map addOverlay:hood.polygon];
    }
}

-(void)flipsideViewControllerDidUpdate:(THFlipsideViewController *)controller {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *prefs = [[defaults objectForKey:@"userprefs"] mutableCopy];
    NSMutableDictionary *enabled = [[defaults objectForKey:@"enabledPrefs"] mutableCopy];
    float budget = [defaults floatForKey:@"budget"];
    /* For combined
     0 = crime
     1 = primary schooling
     2 = secondary
     3 = house price
     4 = employment
     */
    NSMutableString *URL = [@"http://yrs2012.eu01.aws.af.cm/api/combi/" mutableCopy];
    
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
    
    if (budget != 0) {
        [URL appendFormat:@"/%.0f",budget];
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
    
    [self performSelectorOnMainThread:@selector(redoOverlays) withObject:nil waitUntilDone:NO];
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
