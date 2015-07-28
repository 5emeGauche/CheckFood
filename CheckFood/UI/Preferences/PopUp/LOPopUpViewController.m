//
//  LOPopUpViewController.m
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

#import "LOPopUpViewController.h"
#import "LOCacheManager.h"
#import "UIViewController+MJPopupViewController.h"
#import "CFAppDelegate.h"
#import "CFPreferencesViewController.h"
#import "CFActionSheet.h"
#import "CFPopUpErreurDatePrefViewController.h"
#import "CFActionSheetPref.h"

@interface LOPopUpViewController ()

@property (nonatomic, strong) CFActionSheetPref *dateActionSheet;
@property (nonatomic, strong) IBOutlet UIToolbar *datePickerToolBar;

@property (nonatomic, strong) UIActionSheet *dateActionSheetFin;
@property (nonatomic, strong) IBOutlet UIToolbar *datePickerToolBarFin;



@end


@implementation LOPopUpViewController

#pragma mark - lifeView
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.valueDayDebut.datePickerMode = UIDatePickerModeDate;
    self.valueDayFin.datePickerMode = UIDatePickerModeDate;
    self.calendarFinButton.enabled = NO;

    self.statusPop = NO;
   // self.valueDayDebut.minimumDate = [NSDate date];
   // self.valueDayFin.minimumDate = [NSDate date];
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_showDatePickerPop) userInfo:nil repeats:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}


#pragma mark - Public Methods

-(void)updateNotificationDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    NSMutableArray * absenceArray = [[NSMutableArray alloc] init];
    NSMutableArray * absences = [[NSMutableArray alloc] init];
    absenceArray = [NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"absenceP"]];

    NSDate *now = [NSDate date];
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    NSLog(@" new count %d",eventArray.count);
    for (int i=0; i<[eventArray count]; i++)
    {
        
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDate *dateEvent = oneEvent.fireDate;
        NSDate *newFireDate;
        NSDictionary *newUserInfo = oneEvent.userInfo;
        
        NSTimeInterval diff = [startDate timeIntervalSinceDate:now];
        int days = diff / (24*60*60);
        
        if ([startDate compare:dateEvent] == NSOrderedAscending && [endDate compare:dateEvent] == NSOrderedDescending) {
            
            if (days < 2) {
                newFireDate = now;
            }
            else {
                newFireDate = [startDate dateByAddingTimeInterval:-(2)*24*60*60];
            }
            
            NSMutableDictionary *absenceDate = [[NSMutableDictionary alloc] init];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:oneEvent];
            [absenceDate setObject:data forKey:@"notification"];
            [absences addObject:absenceDate];
            [app cancelLocalNotification:oneEvent];
            [self createNewNotificationWithFireDate:newFireDate userInfo:newUserInfo];
        }
    }
    
    [absenceArray addObject:absences];
    [[LOCacheManager sharedManager] cacheDict:absenceArray withKey:@"absenceP"];
}

-(void)createNewNotificationWithFireDate:(NSDate *)newFireDate userInfo:(NSDictionary *)userInfo {
    
    NSMutableDictionary *notificationInfo = [userInfo objectForKey:@"notificationInfo"];
    NSMutableDictionary *product = [notificationInfo objectForKey:@"product"];
    NSString *jourRestant = [notificationInfo objectForKey:@"jourRestant"];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSString *msg = @"Le produit ";
    msg = [msg stringByAppendingString:[product objectForKey:@"name"]];
    msg = [msg stringByAppendingString:@"sera périmé dans "];
    msg = [msg stringByAppendingString:jourRestant];
    msg = [msg stringByAppendingString:@" jour(s)"];
    
    
    notification.fireDate = newFireDate; //[NSDate dateWithTimeIntervalSinceNow:10];//
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = msg;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
#pragma mark - ActionButton

-(IBAction)closePopUpButAction:(id)sender {
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];

}
// validate dateAbsence
- (IBAction)validerButtonAction:(id)sender
{
    if (self.dateDebut.text.length >0 && self.dateFin.text.length >0) {
        
    NSMutableArray * absenceArray = [[NSMutableArray alloc] init];
    NSString *pushNotif = [[LOCacheManager sharedManager] getFromCacheWithKey:@"pushNotif"];

    absenceArray = [NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"absence"]];
    
    NSDate *dateDebut = self.valueDayDebut.date;
    NSDate *dateFin = self.valueDayFin.date;
    
    NSMutableDictionary *absenceDate = [[NSMutableDictionary alloc] init];
    [absenceDate setObject:dateDebut forKey:@"dateDebut"];
    [absenceDate setObject:dateFin forKey:@"dateFin"];
    [absenceArray addObject:absenceDate];

    [[LOCacheManager sharedManager] cacheDict:absenceArray withKey:@"absence"];
    
    if ([pushNotif isEqualToString:@"YES"]) {
        [self updateNotificationDate:dateDebut endDate:dateFin];
    }
    UINavigationController *mainNavVC = (UINavigationController *)[(CFAppDelegate *)[[UIApplication sharedApplication] delegate] mainNavigationController];
    CFPreferencesViewController *prefVC = [[mainNavVC viewControllers] lastObject];
    if ([prefVC isKindOfClass:[CFPreferencesViewController class]]) {
        [prefVC resetViewAndDismissAllPopups];
    }
}
    
}


#pragma mark - Picker Action

- (void) dismissPickerShowPopUp
{
    NSDate *currDate = [NSDate date];
    NSDate *dateAddProd = self.valueDayDebut.date;
    NSComparisonResult result;
    
    result = [currDate compare:dateAddProd]; // comparing two dates
    if(result==NSOrderedDescending){
        NSLog(@"newDate is less");
        [self _dismissDatePicker];
        CFPopUpErreurDatePrefViewController *erreurPopUp = [[CFPopUpErreurDatePrefViewController alloc] initWithNibName:@"CFPopUpErreurDatePrefViewController" bundle:nil];
        erreurPopUp.parentNavController = self.parentNavController;
        erreurPopUp.messageErreur  = @"Veuillez choisir une date correcte, svp.";
        
        [self presentPopupViewController:erreurPopUp animationType:MJPopupViewAnimationFade];
        
        
    }
    
    else {
        
        [self _dismissDatePicker];
        self.statusPickerDebut = YES;
        NSString *dateEX;
        dateEX = self.valueDayDebut.date.description; // set text to date description
        NSString *dateExString = [dateEX substringToIndex:10];
        NSString *dayString = [dateExString substringWithRange: NSMakeRange (8, 2)];
        NSString *monthString = [dateExString substringWithRange: NSMakeRange (5, 2)];
        NSString *yearString = [dateExString substringWithRange: NSMakeRange (0, 4)];
        NSString * finalDate = [NSString stringWithFormat:@"%@/%@/%@",dayString,monthString,yearString];
        self.dateDebut.text = finalDate;
        
        if (self.dateDebut.text.length >0 && self.dateFin.text.length >0) {
            
            [self.validerButton setBackgroundImage:[UIImage imageNamed:@"valid_2.png"] forState:UIControlStateNormal];
        }
        else {
            
            [self.validerButton setBackgroundImage:[UIImage imageNamed:@"btn_annuler.png"] forState:UIControlStateNormal];
        }
    }

}

- (void) resetViewAndDismissAllPopups
{
    //  self.datePr.text = [NSString stringWithFormat:@"Périme le :"];
   // [self.parentNavController dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    [self _showDatePicker];
}
- (IBAction)dateButtonAction:(UIButton *)sender
{
    [self _showDatePicker];
}

- (IBAction)cancelDatePickerAction:(id)sender
{
    [self _dismissDatePicker];
    self.dateDebut.text = self.dateDebut.text;
}

- (IBAction)validateDate:(id)sender
{
    NSDate *currDate = [NSDate date];
    NSDate *dateAddProd = self.valueDayDebut.date;
    NSComparisonResult result;
    
    result = [currDate compare:dateAddProd]; // comparing two dates
    if(result==NSOrderedDescending){
        NSLog(@"newDate is less");
        [self _dismissDatePicker];
        CFPopUpErreurDatePrefViewController *erreurPopUp = [[CFPopUpErreurDatePrefViewController alloc] initWithNibName:@"CFPopUpErreurDatePrefViewController" bundle:nil];
        erreurPopUp.parentNavController = self;
        erreurPopUp.messageErreur  = @"Veuillez choisir une date correcte, svp.";
         [self presentPopupViewController:erreurPopUp animationType:MJPopupViewAnimationFade];
      //  [self pre: animated:YES];
    }
    
    else {
    
    [self _dismissDatePicker];
    self.statusPickerDebut = YES;
    NSString *dateEX;
    dateEX = self.valueDayDebut.date.description; // set text to date description
    NSString *dateExString = [dateEX substringToIndex:10];
    NSString *dayString = [dateExString substringWithRange: NSMakeRange (8, 2)];
    NSString *monthString = [dateExString substringWithRange: NSMakeRange (5, 2)];
    NSString *yearString = [dateExString substringWithRange: NSMakeRange (0, 4)];
    NSString * finalDate = [NSString stringWithFormat:@"%@/%@/%@",dayString,monthString,yearString];
    self.dateDebut.text = finalDate;
    
    if (self.dateDebut.text.length >0 && self.dateFin.text.length >0) {
        
        [self.validerButton setBackgroundImage:[UIImage imageNamed:@"valid_2.png"] forState:UIControlStateNormal];
    }
    else {
        
        [self.validerButton setBackgroundImage:[UIImage imageNamed:@"btn_annuler.png"] forState:UIControlStateNormal];
    }
        self.calendarFinButton.enabled = YES;

}
}

- (void)_showDatePicker
{
    if (!self.dateActionSheet) {
        [self.valueDayDebut setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        self.dateActionSheet = [[CFActionSheetPref alloc] initWithFrame:CGRectMake(0., 0., 320., 206.)];
        self.dateActionSheet.backgroundColor = [UIColor whiteColor];
        [self.dateActionSheet addSubview:self.datePickerToolBar];
        [self.dateActionSheet addSubview:self.valueDayDebut];
    }
    [self.dateActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [self.dateActionSheet setBounds:CGRectMake(0., 0., 320., 390.)];
}

- (void)_showDatePickerPop
{
    if (self.statusPop == YES) {
        
        if (!self.dateActionSheet) {
            [self.valueDayDebut setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
            self.dateActionSheet = [[CFActionSheetPref alloc] initWithFrame:CGRectMake(0., 0., 320., 206.)];
            self.dateActionSheet.backgroundColor = [UIColor whiteColor];
            [self.dateActionSheet addSubview:self.datePickerToolBar];
            [self.dateActionSheet addSubview:self.valueDayDebut];
        }
        [self.dateActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        [self.dateActionSheet setBounds:CGRectMake(0., 0., 320., 390.)];

        
    }
    
    self.statusPop = NO;
    
   }


- (void)_dismissDatePicker
{
    [self.dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - Picker Action Fin
- (IBAction)dateButtonActionFin:(UIButton *)sender
{
    
    [self _showDatePickerFin];
   
}

- (IBAction)cancelDatePickerActionFin:(id)sender
{
    [self _dismissDatePickerFin];
    self.dateFin.text = self.dateFin.text;
}

- (IBAction)validateDateFin:(id)sender
{
   
    NSDate *currDate = self.valueDayDebut.date;
    NSDate *dateAddProd = self.valueDayFin.date;
    NSComparisonResult result;
    
    result = [currDate compare:dateAddProd]; // comparing two dates
    if(result==NSOrderedDescending){
        NSLog(@"newDate is less");
        [self _dismissDatePickerFin];
        CFPopUpErreurDatePrefViewController *erreurPopUp = [[CFPopUpErreurDatePrefViewController alloc] initWithNibName:@"CFPopUpErreurDatePrefViewController" bundle:nil];
        erreurPopUp.parentNavController = self.parentNavController;
        erreurPopUp.messageErreur  = @"Veuillez choisir une date correcte, svp.";
        [self presentPopupViewController:erreurPopUp animationType:MJPopupViewAnimationFade];
    }
    
    else {
    
    [self _dismissDatePickerFin];
    self.statusPickerDebut = YES;
    NSString *dateEX;
    dateEX = self.valueDayFin.date.description; // set text to date description
    NSString *dateExString = [dateEX substringToIndex:10];
    NSString *dayString = [dateExString substringWithRange: NSMakeRange (8, 2)];
    NSString *monthString = [dateExString substringWithRange: NSMakeRange (5, 2)];
    NSString *yearString = [dateExString substringWithRange: NSMakeRange (0, 4)];
    NSString * finalDate = [NSString stringWithFormat:@"%@/%@/%@",dayString,monthString,yearString];
    self.dateFin.text = finalDate;
    
    if (self.dateDebut.text.length >0 && self.dateFin.text.length >0) {
        
        [self.validerButton setBackgroundImage:[UIImage imageNamed:@"valid_2.png"] forState:UIControlStateNormal];
    }
    
    else {
        
        [self.validerButton setBackgroundImage:[UIImage imageNamed:@"btn_annuler.png"] forState:UIControlStateNormal];
    }
    }
  //  }
}

- (void)_showDatePickerFin
{
    if (!self.dateActionSheetFin) {
        [self.valueDayFin setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];        //
        self.dateActionSheetFin = [[CFActionSheet alloc] initWithFrame:CGRectMake(0., 0., 320., 206.)];
        self.dateActionSheetFin.backgroundColor = [UIColor whiteColor];
        [self.dateActionSheetFin addSubview:self.datePickerToolBarFin];
        [self.dateActionSheetFin addSubview:self.valueDayFin];
    }
    [self.dateActionSheetFin showInView:[UIApplication sharedApplication].keyWindow];
    [self.dateActionSheetFin setBounds:CGRectMake(0., 0., 320., 390.)];
}

- (void)_dismissDatePickerFin
{
    [self.dateActionSheetFin dismissWithClickedButtonIndex:0 animated:YES];
}



@end
