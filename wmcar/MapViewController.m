//
//  MapViewController.m
//  wmcar
//
//  Created by Ada on 11/20/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationmanager;
    __weak IBOutlet MKMapView *myMapView;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    _city = YES;
    locationmanager = [CLLocationManager new];
    if([locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationmanager requestWhenInUseAuthorization];
    }
    [myMapView setShowsUserLocation: YES];
    myMapView.delegate = self;
    locationmanager.delegate = self;
    [locationmanager startUpdatingLocation];
    self.noteModel = [Model new];
    self.settingModel = [Model new];
}

- (void)customSetup
{
    _revealButtonItem.target = self.revealViewController;
    _revealButtonItem.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (IBAction)setPinpoint:(id)sender {
    if(_city){
        [self performSegueWithIdentifier:@"showNote" sender:nil];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:userLocation.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude) eyeAltitude:10000];
    [mapView setCamera:camera animated:YES];
    NSLog(@"set camera");
}
-(IBAction)saveNote:(UIStoryboardSegue *) segue {
    NSLog(@"completeSignIn: in ViewController");

    NSLog(@"%@", _noteModel.thisFloor);
    NSLog(@"%@", _noteModel.thisNumber);
}

-(IBAction)cancelNote:(UIStoryboardSegue *) segue {
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showNote"]){
        NoteViewController *noteVC = segue.destinationViewController;
        noteVC.model = self.noteModel;
    }

}
@end
