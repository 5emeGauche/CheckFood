//
//  CFDepositLocationViewController.m
//  CheckFood
//
//  Copyright 2014 5emeGauche
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CFDepositLocationViewController.h"
#import "CFCustumAnnotation.h"
#import "LOCacheManager.h"
#import "CFDepositCenterManager.h"
#import "CFMyDonationsViewController.h"

#define cellHeight 44
#define maxDistanceToSearch 150000
#define kMenuAnimationDuration 0.35



static NSString * const DepositCenterCellIdentifier = @"depositCenterCell";
static NSString * const DepositCenterSuiteCellIdentifier = @"SuiteDepositCenterCell";

CLLocationCoordinate2D coordinateArray[2];

@interface CFDepositLocationViewController ()

@property (nonatomic,strong)NSMutableArray *annotationsToDisplay;
@end

@implementation CFDepositLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.annotationsToDisplay = [NSMutableArray array];
    
    [self.titleScreen setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    [self.numOfLike setFont:[UIFont fontWithName:@"Roboto-Bold" size:9]];
    self.numOfLike.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    
    [self.searchField setValue:[UIFont fontWithName: @"Roboto-Regular" size: 11] forKeyPath:@"_placeholderLabel.font"];
    [self.searchField setValue:[UIColor colorWithRed:156.0/255.0 green:156.0/255.0 blue:156.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    self.searchField.textColor = [UIColor colorWithRed:156.0/255.0 green:156.0/255.0 blue:156.0/255.0 alpha:1.0];

    self.nameOfCenter.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    [self.nameOfCenter setFont:[UIFont fontWithName:@"Roboto-Medium" size:13]];
    
    self.adresseOfCenter.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
    [self.adresseOfCenter setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
    
    self.yAllezLabel.textColor = [UIColor whiteColor];
    [self.yAllezLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:13]];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.depositCenterLocation = [NSMutableArray array];
    self.searchedLocation = [NSMutableArray array];
    self.autocompleteArray = [NSMutableArray array];
    self.depositCenterResult = [NSArray array];
    self.depositCenterHistorique = [NSMutableArray array];
    self.annotationToZoomIn = [NSMutableArray array];
    self.annotationToShowWhenMapOpen = [NSMutableArray array];
    
    //self.depositCenterArray = [[NSMutableArray alloc]initWithObjects:@"a",@"aa",@"b",@"ab",@"c", nil];
  
    self.searchedLocation =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"searchedLocation"]];
    if (self.searchedLocation == nil) {
        self.searchedLocation = [[NSMutableArray alloc] init];
    }
    
    
    if (self.locationManager.location.coordinate.latitude != 0 && self.locationManager.location.coordinate.longitude != 0) {
        
        
        CLLocationCoordinate2D userAnnotation;
        userAnnotation.latitude = self.locationManager.location.coordinate.latitude;
        userAnnotation.longitude =  self.locationManager.location.coordinate.longitude;
        
        
        CFCustumAnnotation *annotation = [[CFCustumAnnotation alloc] init];
        [annotation setCoordinate:userAnnotation];
        annotation.state = @"user";
        
        [self.annotationsToDisplay addObject:annotation];
        [self.annotationToShowWhenMapOpen addObject:annotation];
        [self.mapView addAnnotation:annotation];
        
        self.userLatitude = [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
        self.userLongtitude = [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];

    }


    [[CFDepositCenterManager sharedManager] getAllDepositCenter:^(NSArray *responseDict) {
        
        self.depositCenterResult = responseDict;

        [self showDepositCenterInMap];

    } failureBlock:^(NSError *error, int errorCode, NSString *message) {
        
        if (errorCode == 0) {
        }
        NSLog(@"erreur %@",[error localizedDescription]);
        
    }];

    
    
    NSMutableArray* resultProduct = [NSMutableArray array];
    NSMutableArray* numOfDonate = [NSMutableArray array];
    resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    for (int i=0; i<resultProduct.count; i++) {
        
        NSMutableArray *products = [resultProduct objectAtIndex:i];
        
        for (int j=0; j<products.count;j++) {
            
            NSDictionary *product = [products objectAtIndex:j];
            
            NSString *productState= [product objectForKey:@"etat"];
                if ([productState isEqual:@"donner"]) {
                [numOfDonate addObject:product] ;
            }
        }
    }
    self.numOfLike.text = [NSString stringWithFormat:@"%d",numOfDonate.count];

    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSingleTap:)];
    UITapGestureRecognizer * tapGesture1 = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSingleTap:)];
      [self.mapView addGestureRecognizer:tapGesture];
      [self.header addGestureRecognizer:tapGesture1];
    
   // NSLog(@"user Location %@",[self deviceLocation]);
    [self.listSearchedLocation sizeToFit];
    //self.listSearchedLocation.hidden = YES;
    //self.listSearchedLocationFiltred.hidden = YES;
    [self hideOpenMapStreet:NO];
}

#pragma mark - Private Methods

-(void)showDepositCenterInMap {
    
    NSDate *now = [NSDate date];
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                  fromDate: now];
    [dateComps hour];
    
    NSLog(@"count %d",self.depositCenterResult.count);
    
    for (NSDictionary *center in self.depositCenterResult) {
        
        CLLocationCoordinate2D coordinate;
        
        coordinate.latitude = [[center objectForKey:@"latitude"] doubleValue];
        coordinate.longitude = [[center objectForKey:@"longitude"] doubleValue];
        NSString *closingTime = [center objectForKey:@"closingTime"];
        NSString *openingTime = [center objectForKey:@"openingTime"];
        CFCustumAnnotation *annotation = [[CFCustumAnnotation alloc] init];
        [annotation setCoordinate:coordinate];
        [annotation setTitle:[center objectForKey:@"name"]];
        annotation.subTitle = [center objectForKey:@"address"];
        
        if ([closingTime isKindOfClass:[NSString class]] && [openingTime isKindOfClass:[NSString class]]) {
            int hour;
            
            if ([dateComps minute] > 0) {
                
                hour = [dateComps hour]+1;
            }
            
            if ([dateComps hour] < [closingTime intValue] && hour > [openingTime intValue]) {
                
                annotation.state = @"open";
            }
            else {
                annotation.state = @"close";
            }
        }
        
        [self.annotationsToDisplay addObject:annotation];
        [self.depositCenterLocation addObject:annotation];
        
        CLLocation *L1 = [[CLLocation alloc]initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
        
        CLLocation *L2 = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        
        if ([self distanceBetweenLocation:L1 L2:L2 maxDistance:maxDistanceToSearch]) {
            
            [self.annotationToShowWhenMapOpen addObject:annotation];
            [self.mapView addAnnotation:annotation];
        }
        
        /*
         MKMapRect regionToDisplay = [self mapRectForAnnotations:self.annotationsToDisplay];
         if (!MKMapRectIsNull(regionToDisplay))
         self.mapView.visibleMapRect = regionToDisplay;*/
        
        if (self.annotationToShowWhenMapOpen.count > 1 ) {
            MKMapRect regionToDisplay = [self mapRectForAnnotations:self.annotationToShowWhenMapOpen];
            if (!MKMapRectIsNull(regionToDisplay))
                [self.mapView setVisibleMapRect:regionToDisplay edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
        }
    }

    
}

-(void)changeLocationMethod {
    
    BOOL found = NO;
    if(self.searchField.text.length > 0) {
        
        [self getLocationByAddress:self.searchField.text];
        for (NSString *address in self.searchedLocation) {
            
            if ([address isEqualToString:self.searchField.text]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [self.searchedLocation addObject:self.searchField.text];
        }
        
        [[LOCacheManager sharedManager] cacheDict:self.searchedLocation withKey:@"searchedLocation"];
        [self.searchField resignFirstResponder];
        [self hideOpenMapStreet:YES];
    }
}

-(void)showOpenMapStreet :(BOOL)animated
{
    CGRect showFrame = CGRectMake(0, self.view.frame.size.height - self.footer.frame.size.height, self.footer.frame.size.width, self.footer.frame.size.height);
    
    if (animated) {
        [UIView beginAnimations:@"Show" context:nil];
        [UIView setAnimationDuration:kMenuAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [self.footer setFrame:showFrame];
        [UIView commitAnimations];
    }
    else {
        [self.footer setFrame:showFrame];
    }
 }
   

-(void)hideOpenMapStreet :(BOOL)animated {
    
    CGRect hideFrame = CGRectMake(0, self.view.frame.size.height + self.footer.frame.size.height, self.footer.frame.size.width, self.footer.frame.size.height);
    
    if (animated) {
        [UIView beginAnimations:@"Hide" context:nil];
        [UIView setAnimationDuration:kMenuAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [self.footer setFrame:hideFrame];
        [UIView commitAnimations];
    }
    else {
        [self.footer setFrame:hideFrame];
    }
}

-(BOOL)distanceBetweenLocation :(CLLocation *)L1 L2:(CLLocation *)L2  maxDistance:(CLLocationDistance )maxDistance{

    CLLocationDistance distance = [L1 distanceFromLocation:L2];
     return (distance < maxDistance) ? YES : NO ;
}

-(void)getLocationByAddress: (NSString *)address {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {

                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         NSLog(@"latitude %f",placemark.location.coordinate.latitude);
                         NSLog(@"longtitude %f",placemark.location.coordinate.longitude);
                         
                         self.userLatitude =[NSString stringWithFormat:@"%f",placemark.location.coordinate.latitude];
                         self.userLongtitude = [NSString stringWithFormat:@"%f",placemark.location.coordinate.longitude];
                         
                         [self.mapView removeAnnotations:self.mapView.annotations];
                         [self.annotationToZoomIn removeAllObjects];
                         
                         CLLocation *L1 = [[CLLocation alloc]initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
                         
                         for (CFCustumAnnotation *annotation in self.depositCenterLocation) {
                             
                          CLLocation *L2 = [[CLLocation alloc]initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
                             
                             if ([self distanceBetweenLocation:L1 L2:L2 maxDistance:maxDistanceToSearch]) {
                                 [self.mapView addAnnotation:annotation];
                                 [self.annotationToZoomIn addObject:annotation];
                             }
                        }
                         
                         CLLocationCoordinate2D coordinate;
                         
                         coordinate.latitude = placemark.location.coordinate.latitude;
                         coordinate.longitude = placemark.location.coordinate.longitude;
                         
                         CFCustumAnnotation *annotation = [[CFCustumAnnotation alloc] init];
                         [annotation setCoordinate:coordinate];
                         annotation.state = @"user";
          
                         [self.annotationsToDisplay addObject:annotation];
                         [self.mapView addAnnotation:annotation];
                         [self.annotationToZoomIn addObject:annotation];
                         
                         if (self.annotationToZoomIn.count > 1 ) {
                             
                             MKMapRect regionToDisplay = [self mapRectForAnnotations:self.annotationToZoomIn];
                             if (!MKMapRectIsNull(regionToDisplay))
                                 [self.mapView setVisibleMapRect:regionToDisplay edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
                         }
                         else {
                             
                             MKMapRect regionToDisplay = [self mapRectForAnnotations:self.annotationToZoomIn];
                             if (!MKMapRectIsNull(regionToDisplay))
                                 [self.mapView setVisibleMapRect:regionToDisplay edgePadding:UIEdgeInsetsMake(0, 0, 0, 0) animated:YES];
                         }
                     }
                 }
     ];
    
}
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    [ self.autocompleteArray removeAllObjects];
    for(NSString *curString in self.searchedLocation) {
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
            [self.autocompleteArray addObject:curString];
        }
    }

    NSLog(@"count %d",self.autocompleteArray.count);
    
    if (self.autocompleteArray.count == 0)
        self.listSearchedLocationFiltred.hidden = YES;
    
    else {
        
        self.listSearchedLocationFiltred.frame = CGRectMake(self.listSearchedLocationFiltred.frame.origin.x, self.listSearchedLocationFiltred.frame.origin.y, self.listSearchedLocationFiltred.frame.size.width, cellHeight * self.autocompleteArray.count);
        [self.listSearchedLocationFiltred reloadData];
    }
}

#pragma mark - ActionButton

-(IBAction)openMyDonnationButAction:(id)sender {
    
    CFMyDonationsViewController *myDonnationVC = [[CFMyDonationsViewController alloc]initWithNibName:@"CFMyDonationsViewController" bundle:nil];
    [self.navigationController pushViewController:myDonnationVC animated:YES];
}

-(IBAction)loopButAction:(id)sender {
    
    if ([self.searchField isFirstResponder]) {
        [self.searchField resignFirstResponder];
    }
    else {
        [self.searchField becomeFirstResponder];        
    }
}

-(IBAction)changeLocationAction:(id)sender {
    
 
    [self changeLocationMethod];
}

-(IBAction)openSearchedLocationAction:(id)sender {
    
    self.searchedLocation =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"searchedLocation"]];
    if (self.searchedLocation == nil) {
        self.searchedLocation = [[NSMutableArray alloc] init];
    }
    
    if (self.listSearchedLocation.hidden) {
        
        if (self.searchedLocation.count > 0) {
            self.listSearchedLocationFiltred.hidden = YES;
            self.listSearchedLocation.hidden = NO;
            
            self.listSearchedLocation.frame = CGRectMake(self.listSearchedLocation.frame.origin.x, self.listSearchedLocation.frame.origin.y, self.listSearchedLocation.frame.size.width, cellHeight * self.searchedLocation.count);
            [self.listSearchedLocation reloadData];
        }
    }
    else {
        if (self.searchedLocation.count > 0) {
            self.listSearchedLocationFiltred.hidden = YES;
            self.listSearchedLocation.hidden = YES;
        }
    }
}

-(IBAction)backButAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)OpenGoogleMap:(id)sender {
    
    if (self.nameOfCenter.text.length >0 && self.adresseOfCenter.text.length >0) {
        
        NSString* browserUrl = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
                         [self.userLatitude floatValue], [self.userLongtitude floatValue],self.selectedAnnotation.coordinate.latitude,self.selectedAnnotation.coordinate.longitude];
       
        
        NSString* appUrl = [NSString stringWithFormat: @"comgooglemaps://?saddr=%f,%f&daddr=%f,%f",
                                [self.userLatitude floatValue], [self.userLongtitude floatValue],self.selectedAnnotation.coordinate.latitude,self.selectedAnnotation.coordinate.longitude];
  
        if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: appUrl]]) {
         
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: browserUrl]];

        } else {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appUrl]];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSString *showUserLocation =[[LOCacheManager sharedManager] getFromCacheWithKey:@"userLocation"];

    if (showUserLocation == nil) {
        
        CLLocationCoordinate2D userAnnotation;
        userAnnotation.latitude = self.locationManager.location.coordinate.latitude;
        userAnnotation.longitude =  self.locationManager.location.coordinate.longitude;
        CFCustumAnnotation *annotation = [[CFCustumAnnotation alloc] init];
        [annotation setCoordinate:userAnnotation];
        annotation.state = @"user";
        [self.annotationsToDisplay addObject:annotation];
        [self.mapView addAnnotation:annotation];
        showUserLocation = @"show";
        
        [self showDepositCenterInMap];
        
        MKMapRect regionToDisplay = [self mapRectForAnnotations:self.annotationsToDisplay];
        if (!MKMapRectIsNull(regionToDisplay))
        [self.mapView setVisibleMapRect:regionToDisplay edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    }
    
    [[LOCacheManager sharedManager] cacheDict:self.searchedLocation withKey:@"userLocation"];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
}

#pragma mark - MapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationIdentifier = @"AnnotationIdentifier";
    MKPinAnnotationView *pinView =
    (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!pinView)
    {
        CFCustumAnnotation *cvAnnotation = (CFCustumAnnotation *)annotation;
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] init];
        
        if (annotation ==self.mapView.userLocation || [cvAnnotation.state isEqualToString:@"user"]) {
            
            UIImage *flagImage = [UIImage imageNamed:@"Pin_rouge.png"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
            return annotationView;
        }
        
        else {
            
            UIImage *flagImage ;
            
            if ([cvAnnotation.state isEqualToString:@"open"]) {
                
               flagImage = [UIImage imageNamed:@"Pin_vert.png"];
            }
            
            else {
                
                flagImage = [UIImage imageNamed:@"Pin_gris.png"];
            }
            
            // You may need to resize the image here.
            annotationView.image = flagImage;
            return annotationView;
        }
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    
    CLLocationCoordinate2D userAnnotation;
    userAnnotation.latitude = self.locationManager.location.coordinate.latitude;
    userAnnotation.longitude =  self.locationManager.location.coordinate.longitude;
    
    //self.userLatitude = [NSString stringWithFormat:@"%f",userAnnotation.latitude];
    //self.userLongtitude = [NSString stringWithFormat:@"%f",userAnnotation.longitude];
    
    CLLocationCoordinate2D selectedAnnotation;
    selectedAnnotation.latitude = [[view annotation] coordinate].latitude;
    selectedAnnotation.longitude =  [[view annotation] coordinate].longitude;

    
    if (userAnnotation.latitude != selectedAnnotation.latitude && userAnnotation.longitude != selectedAnnotation.longitude) {
        
       [self showOpenMapStreet:YES];
        
        self.selectedAnnotation = (CFCustumAnnotation *)view.annotation;
        self.nameOfCenter.text = self.selectedAnnotation.title;
        
        //CGSize maximumLabelSize = CGSizeMake(FLT_MAX, 0);
        
        //CGSize expectedLabelSize = [self.nameOfCenter.text sizeWithFont:self.nameOfCenter.font constrainedToSize:maximumLabelSize lineBreakMode:self.nameOfCenter.lineBreakMode];
        
        //CGRect newFrame = self.nameOfCenter.frame;
        //newFrame.size.width = expectedLabelSize.width;
        //self.nameOfCenter.frame = newFrame;
        
        self.adresseOfCenter.text = self.selectedAnnotation.subTitle;
        //CGRect frame = self.adresseOfCenter.frame;
        //frame.size.width = self.nameOfCenter.frame.size.width;
        //self.adresseOfCenter.frame = frame;
      
    }
}

#pragma mark - TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchField resignFirstResponder];
    [self changeLocationMethod];
    
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.searchField) {
        
        NSString *substring = [NSString stringWithString:textField.text];
        substring = [substring stringByReplacingCharactersInRange:range withString:string];
        NSLog(@"text %@",substring);
        if (substring.length != 0) {
            
            self.listSearchedLocationFiltred.hidden = NO;
            self.listSearchedLocation.hidden = YES;
            [self searchAutocompleteEntriesWithSubstring:substring];
        }
        
        else {
            self.listSearchedLocationFiltred.hidden = YES;
            self.listSearchedLocation.hidden = YES;
        }

    }
    return YES;
}


-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    
    self.listSearchedLocation.hidden = YES;
    self.listSearchedLocationFiltred.hidden = YES;
    [self.searchField resignFirstResponder];
}


#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    
    if (tableView == self.listSearchedLocationFiltred)
        return self.autocompleteArray.count;
    
    else
        return self.searchedLocation.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    if (tableView == self.listSearchedLocationFiltred)
        cell.textLabel.text = [self.autocompleteArray objectAtIndex:indexPath.row];
    
    else
        cell.textLabel.text = [self.searchedLocation objectAtIndex:indexPath.row];

    return cell;
}


#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    self.searchField.text = selectedCell.textLabel.text;
    NSLog(@"selected %@",selectedCell.textLabel.text);
    self.listSearchedLocationFiltred.hidden = YES;
    self.listSearchedLocation.hidden = YES;
    [self.searchField resignFirstResponder];

}



- (MKMapRect) mapRectForAnnotations:(NSArray*)annotationsArray
{
    MKMapRect mapRect = MKMapRectNull;
    
    //annotations is an array with all the annotations I want to display on the map
    for (id<MKAnnotation> annotation in annotationsArray) {
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        
        if (MKMapRectIsNull(mapRect))
        {
            mapRect = pointRect;
        } else
        {
            mapRect = MKMapRectUnion(mapRect, pointRect);
        }
    }
    
    return mapRect;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
