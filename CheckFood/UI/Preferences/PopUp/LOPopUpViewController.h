//
//  LOPopUpViewController.h
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


@class ILTranslucentView;

@interface LOPopUpViewController : UIViewController

@property (nonatomic, strong) UINavigationController *parentNavController;
@property (nonatomic, strong) IBOutlet UIView *popupView;
@property (nonatomic, strong) IBOutlet UIButton *calenderDebButton;
@property (nonatomic, strong) IBOutlet UIButton *calendarFinButton;
@property (nonatomic, strong) IBOutlet UIButton *validerButton;
@property (nonatomic, strong) IBOutlet UILabel *dateDebut;
@property (nonatomic, strong) IBOutlet UILabel *dateFin;
@property (nonatomic, strong) IBOutlet UIDatePicker *valueDayDebut;
@property (nonatomic, strong) IBOutlet UIDatePicker *valueDayFin;
@property BOOL statusPickerDebut;
@property BOOL statusPickerFin;
@property BOOL statusPop;

-(IBAction)validerButtonAction:(id)sender;
- (void) resetViewAndDismissAllPopups;
- (void) dismissPickerShowPopUp;



@end
