//
//  CFPreferencesViewController.h
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

@interface CFPreferencesViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *flech1Button;
@property (nonatomic, strong) IBOutlet UIButton *flech2Button;
@property (nonatomic, strong) IBOutlet UIButton *addPeriodButton;
@property (nonatomic, strong) IBOutlet UILabel *titleView;
@property (nonatomic, strong) IBOutlet UILabel *fraisLabel;
@property (nonatomic, strong) IBOutlet UILabel *secLabel;
@property (nonatomic, strong) IBOutlet UIPickerView *valueDayFrai;
@property (nonatomic, strong) IBOutlet UIPickerView *valueDaySec;
@property (nonatomic,weak) IBOutlet UILabel *numOfDonate;
@property (nonatomic, strong) NSMutableArray *dayValues;
@property (nonatomic, strong) NSMutableArray *absenceArray;
@property (nonatomic, strong) IBOutlet UITableView *resultAbsence;
@property (nonatomic, strong) IBOutlet UIImageView *absence;
@property (nonatomic, strong) IBOutlet UIButton *statusPush;
@property (nonatomic, strong) IBOutlet UIButton *indicPush;
@property (nonatomic, strong) IBOutlet UIView *background;
@property int currentCell ;
@property int currentCellSec ;
@property int myLastPressed;
@property (nonatomic, strong) NSString * prFrais;
@property (nonatomic, strong) NSString * prSecs;
@property BOOL statusPickerFrai;
@property BOOL statusPickerSec;
@property (nonatomic, strong) NSString * statusPushNotif;


-(IBAction)addPeriodeAbs:(id)sender;
-(void)resetViewAndDismissAllPopups;
-(IBAction)statusPushAction:(id)sender;

@end
