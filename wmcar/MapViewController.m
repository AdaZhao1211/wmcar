//
//  MapViewController.m
//  wmcar
//
//  Created by Ada on 11/20/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <MKMapViewDelegate> {
    CLLocationManager *locationmanager;
    __weak IBOutlet MKMapView *myMapView;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    _city = NO;
    locationmanager = [CLLocationManager new];
    if([locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationmanager requestWhenInUseAuthorization];
    }
    [myMapView setShowsUserLocation: YES];
    myMapView.delegate = self;
    [locationmanager startUpdatingLocation];
    NSLog(@"%d %@", myMapView.showsUserLocation, myMapView.userLocation);
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
//    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:userLocation.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude) eyeAltitude:10000];
//    [mapView setCamera:camera animated:YES];
//    NSLog(@"set camera");
    [mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f)) animated:YES];
    NSLog(@"ssss");
}

@end
