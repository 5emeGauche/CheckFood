//
//  CFDepositLocationViewController.h
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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@class CFCustumAnnotation,MapView;

@interface CFDepositLocationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UISearchBarDelegate,UISearchDisplayDelegate,MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) UINavigationController *parentNavController;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UILabel *titleScreen;
@property (weak, nonatomic) IBOutlet UILabel *nameOfCenter;
@property (weak, nonatomic) IBOutlet UILabel *adresseOfCenter;
@property (weak, nonatomic) IBOutlet UILabel *yAllezLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfLike;
@property (weak,nonatomic) IBOutlet UIView *header;
@property (weak,nonatomic)IBOutlet UIButton *changeLocation;
@property (weak,nonatomic) IBOutlet UIView *footer;
@property( nonatomic,weak) IBOutlet UITableView *listSearchedLocationFiltred;
@property( nonatomic,weak) IBOutlet UITableView *listSearchedLocation;
@property (nonatomic, strong) NSMutableArray *autocompleteArray;
@property (nonatomic, strong) NSMutableArray *depositCenterHistorique;
@property (nonatomic, strong) NSMutableArray *searchedLocation;
@property (nonatomic, strong) NSMutableArray *depositCenterLocation;
@property (nonatomic, strong) NSMutableArray *annotationToZoomIn;
@property (nonatomic, strong) NSMutableArray *annotationToShowWhenMapOpen;


@property (nonatomic, strong) NSArray *depositCenterResult;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (weak,nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,strong) CFCustumAnnotation* selectedAnnotation;
@property   (nonatomic, strong) NSString *userLatitude;
@property (nonatomic, strong) NSString * userLongtitude;
@property BOOL keyBoardIsOpen;
@property BOOL tableViewIsOpened;


@end
