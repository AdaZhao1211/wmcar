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
    int carCount;
}
@end

@implementation MapViewController
MKRoute *routeDetails;
int thepin = -1;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    //settttttings
    _city = NO;
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
    _addButton.enabled = NO;
}

- (void)customSetup
{
    _revealButtonItem.target = self.revealViewController;
    _revealButtonItem.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

/////////////////bottom button
- (IBAction)setPinpoint:(id)sender {
    if([_set.titleLabel.text isEqual: @"Set Pinpoint"]){
        if(_city){
            [self performSegueWithIdentifier:@"showNote" sender:nil];
            if(_multi){
                _addButton.enabled = YES;
            }
        }else{
            MKPointAnnotation *pin = [MKPointAnnotation new];
            pin.coordinate = myMapView.centerCoordinate;
            pin.title = @"My Car";
            [_carArray addObject:pin];
            [myMapView addAnnotation:pin];
            [myMapView removeAnnotation:_centerAnnotation];
            [_set setTitle:@"Find My Car" forState:UIControlStateNormal];
            if(_multi){
                _addButton.enabled = YES;
            }
        }
    }else if([_set.titleLabel.text isEqual: @"Find My Car"]){
        if(_multi){
            if(_carArray.count == 1){
                //navigate
                thepin = 0;
                NSLog(@"in multi mode with only one pin, requeting directions");
                MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
                MKPointAnnotation *temp = [_carArray objectAtIndex:0];
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:temp.coordinate];
                [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
                [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
                [directionsRequest setTransportType: MKDirectionsTransportTypeWalking];
                directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
                MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                    } else {
                        NSLog(@"no error");
                        //got the call back
                        routeDetails = response.routes.lastObject;
                        [myMapView addOverlay:routeDetails.polyline];
                    }
                }];
            }else{
                //alert
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please select a pin" message:@"You are in multi-pinpoint mode" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else{
            thepin = 0;
            NSLog(@"in non multi mode, requeting directions");
            MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
            MKPointAnnotation *temp = [_carArray objectAtIndex:0];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:temp.coordinate];
            [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
            [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
            [directionsRequest setTransportType:MKDirectionsTransportTypeWalking];
            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"Error %@", error.description);
                } else {
                    NSLog(@"no error");
                    //got the call back
                    NSLog(@"%lu", (unsigned long)routeDetails.transportType);
                    routeDetails = response.routes.lastObject;
                    [myMapView addOverlay:routeDetails.polyline];
                }
            }];
        }
        [_set setTitle:@"Found" forState:UIControlStateNormal];
    }else{
        [_set setTitle:@"Set Pinpoint" forState:UIControlStateNormal];
        [myMapView removeOverlay:routeDetails.polyline];
        [myMapView removeAnnotation:[_carArray objectAtIndex:thepin]];
        [_carArray removeObjectAtIndex:thepin];
        thepin = -1;
        if(_carArray.count == 0){
            [myMapView addAnnotation:_centerAnnotation];
        }
    }
}
///////////end of bottom button



//overlay the route details
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

// + for multi pinpoint
- (IBAction)addPinpoint:(id)sender {
    [_set setTitle:@"Set Pinpoint" forState:UIControlStateNormal];
    [myMapView addAnnotation:_centerAnnotation];
    _addButton.enabled = NO;
}

//zoom in to current location
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:userLocation.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude) eyeAltitude:1000];
    [mapView setCamera:camera animated:NO];
    
    MKPointAnnotation *temp = [MKPointAnnotation new];
    temp.coordinate = myMapView.centerCoordinate;
    temp.title = @"My Car";
    temp.subtitle = [NSString stringWithFormat:@"%f, %f", temp.coordinate.latitude, temp.coordinate.longitude];
    [myMapView addAnnotation:temp];
    _centerAnnotation = temp;
}

//move the pin
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _centerAnnotation.coordinate = mapView.centerCoordinate;
    _centerAnnotation.subtitle = [NSString stringWithFormat:@"%f, %f", _centerAnnotation.coordinate.latitude, _centerAnnotation.coordinate.longitude];
}

//note view
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

//direction
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[myMapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}
@end
