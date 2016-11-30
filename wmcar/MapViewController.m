//
//  MapViewController.m
//  wmcar
//
//  Created by Ada on 11/20/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate> {
    CLLocationManager *locationmanager;
    __weak IBOutlet MKMapView *myMapView;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    //settttttings
    _city = YES;
    _multi = NO;
    
    //map
    locationmanager = [CLLocationManager new];
    if([locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationmanager requestWhenInUseAuthorization];
    }
    [myMapView setShowsUserLocation: YES];
    [myMapView setShowsBuildings:YES];
    myMapView.delegate = self;
    locationmanager.delegate = self;
    [locationmanager startUpdatingLocation];
    self.noteModel = [Model new];
    self.settingModel = [Model new];
    
    //gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    panGesture.delegate = self;
    [myMapView addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pinchGesture.delegate = self;
    [myMapView addGestureRecognizer:pinchGesture];
    
    //car array
    _carArray = [NSMutableArray new];
    _addButton.enabled = _multi;
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
    [mapView setCamera:camera animated:NO];
    
    MKPointAnnotation *temp = [MKPointAnnotation new];
    temp.coordinate = myMapView.centerCoordinate;
    temp.title = @"My Car";
    temp.subtitle = [NSString stringWithFormat:@"%f, %f", temp.coordinate.latitude, temp.coordinate.longitude];
    [myMapView addAnnotation:temp];
    _centerAnnotation = temp;
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _centerAnnotation.coordinate = mapView.centerCoordinate;
    _centerAnnotation.subtitle = [NSString stringWithFormat:@"%f, %f", _centerAnnotation.coordinate.latitude, _centerAnnotation.coordinate.longitude];
}

-(IBAction)saveNote:(UIStoryboardSegue *) segue {
    MKPointAnnotation *pin = [MKPointAnnotation new];
    pin.coordinate = myMapView.centerCoordinate;
    pin.title = @"My Car";
    pin.subtitle = [NSString stringWithFormat:@"%@, %@", _noteModel.thisFloor, _noteModel.thisNumber];
    [_carArray addObject:pin];
    [myMapView addAnnotation:pin];
    [myMapView removeAnnotation:_centerAnnotation];
    [_set setTitle:@"Find My Car" forState:UIControlStateNormal];
}

-(IBAction)cancelNote:(UIStoryboardSegue *) segue {
}

//gesture
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    _centerAnnotation.coordinate = myMapView.centerCoordinate;
    _centerAnnotation.subtitle = [NSString stringWithFormat:@"%f, %f", _centerAnnotation.coordinate.latitude, _centerAnnotation.coordinate.longitude];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showNote"]){
        NoteViewController *noteVC = segue.destinationViewController;
        noteVC.model = self.noteModel;
    }

}
@end
