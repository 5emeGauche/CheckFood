//
//  CFPreferencesViewController.m
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

#import "CFPreferencesViewController.h"
#import "CFNavigationController.h"
#import "CFAppDelegate.h"
#import "LOCacheManager.h"
#import "LOPopUpViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "CFAbsenceTableViewCell.h"
#import "CFAbsenceAddButtonTableViewCell.h"
#import "CFActionSheet.h"
#import "CFMyDonationsViewController.h"

#define RGBA(r, g, b, a) [UIColor colorWithRed : r / 255. green : g / 255. blue : b / 255. alpha : a]

static NSString * const ProductCellIdentifier = @"ProductCell";
static NSString * const ProductCellButtonIdentifier = @"ProductButtonCell";

@interface CFPreferencesViewController ()

@property (nonatomic, strong) UIActionSheet *dateActionSheet;
@property (nonatomic, strong) IBOutlet UIToolbar *datePickerToolBar;

@property (nonatomic, strong) UIActionSheet *dateActionSheetSec;
@property (nonatomic, strong) IBOutlet UIToolbar *datePickerToolBarSec;



@end

@implementation CFPreferencesViewController

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
    [self.resultAbsence registerNib:[UINib nibWithNibName:@"CFAbsenceTableViewCell" bundle:nil]  forCellReuseIdentifier:ProductCellIdentifier];
    [self.resultAbsence registerNib:[UINib nibWithNibName:@"CFAbsenceAddButtonTableViewCell" bundle:nil]  forCellReuseIdentifier:ProductCellButtonIdentifier];
    self.titleView.textColor = [UIColor colorWithRed:225/255.0f green:229/255.0f blue:231/255.0f alpha:1.0];
    self.titleView.font = [UIFont fontWithName:@"Roboto-Regular" size:14];
    // Do any additional setup after loading the view from its nib.
    self.background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_produit.png"]];
    self.absenceArray = [[NSMutableArray alloc] init];
    self.statusPushNotif = [[LOCacheManager sharedManager] getFromCacheWithKey:@"pushNotif"];
    self.absenceArray = [[LOCacheManager sharedManager] getFromCacheWithKey:@"absence"];
    self.prFrais = [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
    self.prSecs = [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];
    
    if (self.prFrais == nil) {
         self.prFrais = @"2";
    }
    
    if (self.prSecs == nil) {
        self.prSecs = @"2";
    }

    if (self.statusPushNotif == nil) {
        self.statusPushNotif = @"YES";
    }
    // Array days
    self.dayValues = [[NSMutableArray alloc] init];
        self.dayValues = [NSMutableArray arrayWithObjects:@"1", @"2", @"3" , @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", nil];
    
    if ([self.prFrais isEqualToString:@"1"]) {
        self.fraisLabel.text = [NSString stringWithFormat:@" Produits frais : %@ jour avant", self.prFrais];
    }
    else {
        self.fraisLabel.text = [NSString stringWithFormat:@" Produits frais : %@ jours avant", self.prFrais];
    }
    
    if ([self.prSecs isEqualToString:@"1"]) {
        self.secLabel.text = [NSString stringWithFormat:@" Produits secs : %@ jour avant",self.prSecs ];
    }
    else {
        self.secLabel.text = [NSString stringWithFormat:@" Produits secs : %@ jours avant",self.prSecs ];
    }
    
    [self.fraisLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:13]];
    self.fraisLabel.textColor = [UIColor whiteColor];// [UIColor colorWithRed:146/255.0f green:154/255.0f blue:158/255.0f alpha:1.0];
    [self.secLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:13]];
    self.secLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:146/255.0f green:154/255.0f blue:158/255.0f alpha:1.0];
    
    [self.numOfDonate setFont:[UIFont fontWithName:@"Roboto-Bold" size:9]];
    self.numOfDonate.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    
    self.statusPickerFrai = NO;
    self.statusPickerSec = NO;
    
    // Periode absence array
    if (self.absenceArray.count == 0) {
         self.resultAbsence.hidden= YES;
        self.absence.hidden = NO;
        self.addPeriodButton.hidden = NO;
    }
    
    else if (self.absenceArray.count != 0) {
        self.resultAbsence.hidden= NO;
        self.absence.hidden = YES;
        self.addPeriodButton.hidden = YES;
    }
    // notif status
    if ([self.statusPushNotif isEqualToString:@"YES"]) {
        
        [self.statusPush setImage:[UIImage imageNamed:@"Notif_on.png"] forState:UIControlStateNormal];
        [self.indicPush setImage:[UIImage imageNamed:@"check.png"]forState:UIControlStateNormal];
    }
    
    else if ([self.statusPushNotif isEqualToString:@"NO"]) {
        
        [self.statusPush setImage:[UIImage imageNamed:@"Notif-Off.png"] forState:UIControlStateNormal];
        [self.indicPush setImage:[UIImage imageNamed:@"CROIX.png"] forState:UIControlStateNormal];
        self.fraisLabel.textColor =[UIColor colorWithRed:146/255.0f green:154/255.0f blue:158/255.0f alpha:1.0];
        self.secLabel.textColor = [UIColor colorWithRed:146/255.0f green:154/255.0f blue:158/255.0f alpha:1.0];
        [self.flech1Button setImage:[UIImage imageNamed:@"Arrow-.png"] forState:UIControlStateNormal];
        [self.flech2Button setImage:[UIImage imageNamed:@"Arrow-.png"] forState:UIControlStateNormal];
    }
    
     NSLog(@"result");
    // value don
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
    self.numOfDonate.text = [NSString stringWithFormat:@"%d",numOfDonate.count];
    self.currentCell = 0;
    self.currentCellSec = 0;
   
    
}

#pragma mark -Private Methods

-(void)DisableAllNotification {
    
    NSMutableArray * notifications = [[NSMutableArray alloc] init];
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    NSLog(@"count1 %d",eventArray.count);
    for (int i=0; i<[eventArray count]; i++)
      {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:oneEvent];
        [notifications addObject:data];
      }

    [[LOCacheManager sharedManager] cacheDict:notifications withKey:@"notifications"];
    [app cancelAllLocalNotifications];
    
    NSArray *event = [app scheduledLocalNotifications];
    NSLog(@"count2 %d",event.count);
}

-(void)EnableAllNotification {
    
    NSMutableArray *notifications =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"notifications"]];
    
    for (NSData *notif in notifications) {
        UILocalNotification* notification =[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *) notif];
        NSLog(@"fire date %@",notification.fireDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    NSLog(@"count3 %d",eventArray.count);
}

-(void)cancelNotification :(NSMutableArray *)absences {
    
    for (NSMutableDictionary *absence in absences) {
        UILocalNotification* notification =[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *) [absence objectForKey:@"notification"]];
        NSLog(@"fire date %@",notification.fireDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark -Action Buttons

-(IBAction)openMyDonnationButAction:(id)sender {
    
    CFNavigationController *mainNavVC = (CFNavigationController *)[(CFAppDelegate *)[[UIApplication sharedApplication] delegate] mainNavigationController];
    [mainNavVC tableView:mainNavVC.menuTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    CFMyDonationsViewController *myDonnationVC = [[CFMyDonationsViewController alloc]initWithNibName:@"CFMyDonationsViewController" bundle:nil];
    [self.navigationController pushViewController:myDonnationVC animated:YES];
}

-(IBAction)addPeriodeAbs:(id)sender
{
    LOPopUpViewController *detailViewController = [[LOPopUpViewController alloc] initWithNibName:@"LOPopUpViewController" bundle:nil];
    detailViewController.parentNavController = self.navigationController;
    [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationFade];
}

-(IBAction)toggleMenu:(id)sender {
    CFAppDelegate *appDelegate = (CFAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate mainNavigationController] toggleMenuAnimated:YES];
}

- (void) resetViewAndDismissAllPopups
{
    
    self.absenceArray = [[LOCacheManager sharedManager] getFromCacheWithKey:@"absence"];
    if (self.absenceArray.count > 0) {
        self.resultAbsence.hidden = NO;
        self.absence.hidden = YES;
        self.addPeriodButton.hidden = YES;
        [self.resultAbsence reloadData];
    }
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

- (IBAction)cancelAbsence:(UIButton *)sender
{
    NSString *pushNotif = [[LOCacheManager sharedManager] getFromCacheWithKey:@"pushNotif"];

    for (int i =0; i< self.absenceArray.count; i++) {
        
        if (i == sender.tag) {
            NSMutableArray *array = [self.absenceArray mutableCopy];
            
            if (([array isKindOfClass:[NSMutableArray class]])) {
                [array removeObjectAtIndex:i];
                self.absenceArray =[array mutableCopy];
            }
            
            [[LOCacheManager sharedManager] cacheDict:self.absenceArray withKey:@"absence"];
            [self.resultAbsence reloadData];
            
            if (self.absenceArray.count == 0) {
                self.resultAbsence.hidden = YES;
                self.absence.hidden = NO;
                self.addPeriodButton.hidden = NO;
            }
            
            UIApplication *app = [UIApplication sharedApplication];
            NSArray *eventArray = [app scheduledLocalNotifications];
            NSLog(@" count before %d",eventArray.count);
            
            NSMutableArray *absenceArrayP = [[LOCacheManager sharedManager]getFromCacheWithKey:@"absenceP"];
            
            if ([pushNotif isEqualToString:@"YES"]) {
                [self cancelNotification:[absenceArrayP objectAtIndex:i]];
            }
            
            NSArray *event = [app scheduledLocalNotifications];
            NSLog(@" count after %d",event.count);
            
        }
    }
    
}

-(IBAction)statusPushAction:(id)sender
{
   
    if ([self.statusPushNotif isEqualToString:@"YES"]) {
        
        [self.flech1Button setImage:[UIImage imageNamed:@"Arrow-.png"] forState:UIControlStateNormal];
        [self.flech2Button setImage:[UIImage imageNamed:@"Arrow-.png"] forState:UIControlStateNormal];
        self.fraisLabel.textColor =[UIColor colorWithRed:146/255.0f green:154/255.0f blue:158/255.0f alpha:1.0];
        self.secLabel.textColor = [UIColor colorWithRed:146/255.0f green:154/255.0f blue:158/255.0f alpha:1.0];
        [self.statusPush setImage:[UIImage imageNamed:@"Notif-Off.png"] forState:UIControlStateNormal];
        [self.indicPush setImage:[UIImage imageNamed:@"CROIX.png"]forState:UIControlStateNormal];
        self.statusPushNotif = @"NO";
        [[LOCacheManager sharedManager] cacheDict:self.statusPushNotif withKey:@"pushNotif"];
        [self DisableAllNotification];
    }
    
    else if ([self.statusPushNotif isEqualToString:@"NO"]) {
        
        [self.flech1Button setImage:[UIImage imageNamed:@"arrow_down_pref.png"] forState:UIControlStateNormal];
        [self.flech2Button setImage:[UIImage imageNamed:@"arrow_down_pref.png"] forState:UIControlStateNormal];
        self.fraisLabel.textColor = [UIColor whiteColor];
        self.secLabel.textColor = [UIColor whiteColor];
        [self.statusPush setImage:[UIImage imageNamed:@"Notif_on.png"] forState:UIControlStateNormal];
        [self.indicPush setImage:[UIImage imageNamed:@"check.png"]forState:UIControlStateNormal];
        self.statusPushNotif = @"YES";
        [[LOCacheManager sharedManager] cacheDict:self.statusPushNotif withKey:@"pushNotif"];
        [self EnableAllNotification];
    }
}


#pragma mark - Picker Action
- (IBAction)dateButtonAction:(UIButton *)sender
{
    if ([self.statusPushNotif isEqualToString:@"YES"]) {
        [self _showDatePicker];
    }
}

- (IBAction)cancelDatePickerAction:(id)sender
{
    [self _dismissDatePicker];
}

- (IBAction)validateDate:(id)sender
{
    [self _dismissDatePicker];
    NSString *dateEX;
    dateEX = [self.dayValues objectAtIndex:self.currentCell]; // set text to date description
    self.prFrais = dateEX;
    if ([dateEX isEqualToString:@"1"]) {
        self.fraisLabel.text = [NSString stringWithFormat:@" Produits frais : %@ jour avant",dateEX];
        [[LOCacheManager sharedManager] cacheDict:dateEX withKey:@"alertFrigo"];
    }
    else {
        self.fraisLabel.text = [NSString stringWithFormat:@" Produits frais : %@ jours avant",dateEX];
        [[LOCacheManager sharedManager] cacheDict:dateEX withKey:@"alertFrigo"];
    }
}

- (void)_showDatePicker
{

    if (!self.dateActionSheet) {
        self.dateActionSheet = [[CFActionSheet alloc] initWithFrame:CGRectMake(0., 0., 320., 206.)];
        

        self.dateActionSheet.backgroundColor = [UIColor whiteColor];

        [self.dateActionSheet addSubview:self.datePickerToolBar];
        [self.dateActionSheet addSubview:self.valueDayFrai];
    }
    [self.dateActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [self.dateActionSheet setBounds:CGRectMake(0., 0., 320., 390.)];
    self.dateActionSheet.backgroundColor = [UIColor whiteColor];
    
  //  if (self.currentCell == 0) {
        int firstVal = [self.prFrais intValue];
        if (firstVal == 1) {
             [self.valueDayFrai selectRow:0  inComponent:0 animated:NO];
            NSLog(@"index O %d", [[self.dayValues objectAtIndex:0] intValue ] );
        }
        
        else {
              firstVal = firstVal - 2;
            [self.valueDayFrai selectRow:[[self.dayValues objectAtIndex:firstVal] intValue ]  inComponent:0 animated:NO];
            NSLog(@"ddd %d",[[self.dayValues objectAtIndex:firstVal] intValue ] );
        }
    //}
}

- (void)_dismissDatePicker
{
    [self.dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark - PickerSec Action
- (IBAction)dateButtonActionSec:(UIButton *)sender
{
    if ([self.statusPushNotif isEqualToString:@"YES"]) {
        [self _showDatePickerSec];
    }
}

- (IBAction)cancelDatePickerActionSec:(id)sender
{
    [self _dismissDatePickerSec];
}

- (IBAction)validateDateSec:(id)sender
{
    [self _dismissDatePickerSec];
    NSString *dateEX;
    dateEX = [self.dayValues objectAtIndex:self.currentCellSec]; // set text to date description
    self.prSecs = dateEX;
    if ([dateEX isEqualToString:@"1"]) {
        self.secLabel.text = [NSString stringWithFormat:@" Produits secs : %@ jour avant",dateEX];
        [[LOCacheManager sharedManager] cacheDict:dateEX withKey:@"alertPlacard"];
    }
    else {
        self.secLabel.text = [NSString stringWithFormat:@" Produits secs : %@ jours avant",dateEX];
        [[LOCacheManager sharedManager] cacheDict:dateEX withKey:@"alertPlacard"];
    }

    
    
}

- (void)_showDatePickerSec
{

    if (!self.dateActionSheetSec) {
        self.dateActionSheetSec = [[CFActionSheet alloc] initWithFrame:CGRectMake(0., 0., 320., 206.)];
       
            self.dateActionSheetSec.backgroundColor = [UIColor whiteColor];
            self.valueDaySec.userInteractionEnabled = YES;
    
        [self.dateActionSheetSec addSubview:self.datePickerToolBarSec];
        [self.dateActionSheetSec addSubview:self.valueDaySec];
    }
    [self.dateActionSheetSec showInView:[UIApplication sharedApplication].keyWindow];
    [self.dateActionSheetSec setBounds:CGRectMake(0., 0., 320., 444.)];
   
        self.dateActionSheetSec.backgroundColor = [UIColor whiteColor];
        self.valueDaySec.userInteractionEnabled = YES;

    
  //  if (self.currentCellSec == 0) {
        int firstVal = [self.prSecs intValue];
        if (firstVal == 1) {
            [self.valueDaySec selectRow:0  inComponent:0 animated:NO];
            NSLog(@"index O %d", [[self.dayValues objectAtIndex:0] intValue ] );
        }
        
        else {
            firstVal = firstVal - 2;
            [self.valueDaySec selectRow:[[self.dayValues objectAtIndex:firstVal] intValue ]  inComponent:0 animated:NO];
        }
   // }
}

- (void)_dismissDatePickerSec
{
    [self.dateActionSheetSec dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark - Delegate DataSource PickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;//Or return whatever as you intend
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 31;//Or, return as suitable for you...normally we use array for dynamic
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.dayValues objectAtIndex:row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 37)];
    
    if (component == 0) {
        
        label.font=[UIFont boldSystemFontOfSize:22];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        
        label.text = [NSString stringWithFormat:@"%@", [self.dayValues objectAtIndex:row]];
        label.font=[UIFont boldSystemFontOfSize:22];
        
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.valueDayFrai) {
        
        self.currentCell = row;

    }
    
   else if (pickerView == self.valueDaySec) {
       self.currentCellSec = row;
    }
   
}

#pragma mark - TabaleView DataSource Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.absenceArray.count;
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CFAbsenceTableViewCell *productCell =
        [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier forIndexPath:indexPath];
        self.resultAbsence.separatorColor = [UIColor clearColor];
        productCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.resultAbsence.opaque = NO;
        self.resultAbsence.backgroundColor = [UIColor clearColor];
        
        
        if (productCell == nil) {
            productCell = [[CFAbsenceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
        }
        
        NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
        [df setTimeStyle:NSDateFormatterNoStyle];  // nothing
        [df setLocale:frLocale];
        
        NSString *dateDebutString = [df stringFromDate:[[self.absenceArray objectAtIndex:indexPath.row] objectForKey:@"dateDebut"]];
        
        NSRange isRange = [dateDebutString rangeOfString:@" " options:NSCaseInsensitiveSearch];
        NSLog(@"location ###%d",isRange.location);
        NSString *dayStringInter = [dateDebutString substringWithRange: NSMakeRange (0, isRange.location)];
        NSString *monthStringInter = [dateDebutString substringWithRange: NSMakeRange (isRange.location +1, (dateDebutString.length - (isRange.location +1)))];
        NSRange isRange2 = [monthStringInter rangeOfString:@" " options:NSCaseInsensitiveSearch];
        NSLog(@"location2 ###%d",isRange2.location);
        NSString *monthString = [monthStringInter substringToIndex:isRange2.location];
        
        NSString * reultDateDebut = [NSString stringWithFormat:@"%@ %@",dayStringInter,monthString ];
        
        NSString *dateFin = [df stringFromDate:[[self.absenceArray objectAtIndex:indexPath.row] objectForKey:@"dateFin"]];
        
        NSString *text = reultDateDebut ;
        CGFloat width = 170;
        UIFont *font = [UIFont fontWithName:@"Roboto-Regular" size:17];
        NSAttributedString *attributedText =
        [[NSAttributedString alloc]
         initWithString:text
         attributes:@
         {
         NSFontAttributeName: font
         }];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, 20 }
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize size = rect.size;
        NSLog(@"size %f", size.width);
        
        productCell.dateDebut.frame = CGRectMake(productCell.dateDebut.frame.origin.x,productCell.dateDebut.frame.origin.y, size.width, productCell.dateDebut.frame.size.height);
        
        productCell.messageLab.frame = CGRectMake((productCell.dateDebut.frame.origin.x+productCell.dateDebut.frame.size.width + 5), productCell.messageLab.frame.origin.y,productCell.messageLab.frame.size.width, productCell.messageLab.frame.size.height);
        
        productCell.dateFin.frame = CGRectMake((productCell.messageLab.frame.origin.x + productCell.messageLab.frame.size.width), productCell.dateFin.frame.origin.y,productCell.dateFin.frame.size.width, productCell.dateFin.frame.size.height);
        
        productCell.dateDebut.text = [NSString stringWithFormat:@"%@",reultDateDebut];
        productCell.dateFin.text = [NSString stringWithFormat:@"%@",dateFin];
        productCell.dateDebut.font = [UIFont fontWithName:@"Roboto-Regular" size:17];
        productCell.dateDebut.textColor = [UIColor colorWithRed:225/255.0f green:229/255.0f blue:231/255.0f alpha:1.0];
        productCell.dateFin.font = [UIFont fontWithName:@"Roboto-Regular" size:17];
        productCell.dateFin.textColor = [UIColor colorWithRed:225/255.0f green:229/255.0f blue:231/255.0f alpha:1.0];
        productCell.titreLab.font = [UIFont fontWithName:@"Roboto-Regular" size:12];
        productCell.titreLab.textColor = [UIColor colorWithRed:146/255.0f green:154/255.0f blue:158/255.0f alpha:1.0];
        productCell.messageLab.font = [UIFont fontWithName:@"Roboto-Regular" size:17];
        productCell.messageLab.textColor = [UIColor colorWithRed:146/255.0f green:154/255.0f blue:158/255.0f alpha:1.0];
        
        [productCell.suppButton addTarget:self action:@selector(cancelAbsence:) forControlEvents:UIControlEventTouchUpInside];
        [productCell.suppButton setTag:indexPath.row];
        
        return productCell;

    }
    
    else  {
        CFAbsenceAddButtonTableViewCell *productCell =
        [tableView dequeueReusableCellWithIdentifier:ProductCellButtonIdentifier forIndexPath:indexPath];
        self.resultAbsence.separatorColor = [UIColor clearColor];
        productCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.resultAbsence.opaque = NO;
        self.resultAbsence.backgroundColor = [UIColor clearColor];
        
        
        if (productCell == nil) {
            productCell = [[CFAbsenceAddButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellButtonIdentifier];
        }
        
        [productCell.addPeriodButton addTarget:self action:@selector(addPeriodeAbs:) forControlEvents:UIControlEventTouchUpInside];
        
        return productCell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 0;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
   else {
        return 180;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
