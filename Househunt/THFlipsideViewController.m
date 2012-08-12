//
//  THFlipsideViewController.m
//  Smartmove
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THFlipsideViewController.h"
#import "THHouseDetailsController.h"

@interface THFlipsideViewController ()

@end

@implementation THFlipsideViewController

@synthesize delegate = _delegate;
@synthesize userPreferences, enabledRows;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arr = [[defaults objectForKey:@"userprefs"] mutableCopy];
        NSMutableDictionary *enabledDict = [[defaults objectForKey:@"enabledPrefs"] mutableCopy];
        if (1 && arr) {
            userPreferences = arr;
            enabledRows = enabledDict;
        } else {
            userPreferences = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"crimes",@"employment",@"houseprices",@"ks2",@"ks4", nil]];
            enabledRows = [[NSMutableDictionary alloc] initWithCapacity:5];
            for (NSString *str in userPreferences) {
                [enabledRows setObject:[NSNumber numberWithBool:YES] forKey:str];
            }
        }
        numberOfDisabledRows = 0;
        for (NSString *str in userPreferences) {
            if (![[enabledRows objectForKey:str] boolValue]) {
                numberOfDisabledRows += 1;
            }
        }
        [defaults setObject:userPreferences forKey:@"userprefs"];
        [defaults setObject:enabledRows forKey:@"enabledPrefs"];
        [defaults synchronize];
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [tableView setEditing:YES];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NEIN"];
    NSString *str = [userPreferences objectAtIndex:indexPath.row];
    if ([[enabledRows objectForKey:str] boolValue]) {
        cell.showsReorderControl = YES;
        cell.imageView.image = [UIImage imageNamed:@"17-check"];
    } else {
        cell.showsReorderControl = NO;
        cell.imageView.image = [UIImage imageNamed:@"17-blank"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([str isEqualToString:@"crimes"]) {
        cell.textLabel.text = @"Crime Levels";
        cell.detailTextLabel.text = @"Number of crimes committed ";
    } else if ([str isEqualToString:@"employment"]) {
        cell.textLabel.text = @"Unemployment";
        cell.detailTextLabel.text = @"Perentage of workforce unemployed";
    } else if ([str isEqualToString:@"ks2"]) {
        cell.textLabel.text = @"Primary Schools";
        cell.detailTextLabel.text = @"Schools by SAT results (KS2)";
    } else if ([str isEqualToString:@"houseprices"]) {
        cell.textLabel.text = @"House prices";
        cell.detailTextLabel.text = @"Relative to your budget";
    } else {
        //ks3
        cell.textLabel.text = @"Secondary Schools";
        cell.detailTextLabel.text = @"Schools by GCSE";
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


-(BOOL)tableView:(UITableView *)aTableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.imageView.image isEqual:[UIImage imageNamed:@"17-blank"]]) {
        return NO;
    } else {
        //just got de-selected
        return YES;
    }
}

-(BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.imageView.image isEqual:[UIImage imageNamed:@"17-blank"]]) {
        return NO;
    } else {
        //just got de-selected
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *stringToMove = [userPreferences objectAtIndex:sourceIndexPath.row];
    [userPreferences removeObjectAtIndex:sourceIndexPath.row];
    [userPreferences insertObject:stringToMove atIndex:destinationIndexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userPreferences forKey:@"userprefs"];
    [defaults synchronize];
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.imageView.image isEqual:[UIImage imageNamed:@"17-blank"]]) {
        [enabledRows setObject:[NSNumber numberWithBool:YES] forKey:[userPreferences objectAtIndex:indexPath.row]];
        cell.imageView.image = [UIImage imageNamed:@"17-check"];
        cell.showsReorderControl = YES;
        [tableView moveRowAtIndexPath:indexPath toIndexPath:indexPath];
        numberOfDisabledRows -= 1;
        [tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:4-numberOfDisabledRows inSection:0]];
        [self tableView:nil moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:4-numberOfDisabledRows inSection:0]];
    } else {
        //just got de-selected
        [enabledRows setObject:[NSNumber numberWithBool:NO] forKey:[userPreferences objectAtIndex:indexPath.row]];
        cell.imageView.image = [UIImage imageNamed:@"17-blank"];
        cell.showsReorderControl = NO;
        [tableView moveRowAtIndexPath:indexPath toIndexPath:indexPath];
        [tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:4-numberOfDisabledRows inSection:0]];
        [self tableView:nil moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:4-numberOfDisabledRows inSection:0]];
        numberOfDisabledRows += 1;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:enabledRows forKey:@"enabledPrefs"];
    [defaults synchronize];
}

- (NSIndexPath *)tableView:(UITableView *)aTableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if ([[[[tableView cellForRowAtIndexPath:proposedDestinationIndexPath] imageView] image] isEqual:[UIImage imageNamed:@"17-blank"]]) {
        return [NSIndexPath indexPathForRow:4-numberOfDisabledRows inSection:0];
    }
    return proposedDestinationIndexPath;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(IBAction)openDetailsController {
    THHouseDetailsController * houseDetails = [[THHouseDetailsController alloc] initWithNibName:@"THHouseDetailsController" bundle:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        houseDetails.modalPresentationStyle = UIModalPresentationFormSheet;
        houseDetails.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    [self presentModalViewController:houseDetails animated:YES];
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate performSelectorInBackground:@selector(flipsideViewControllerDidUpdate:) withObject:self];
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
