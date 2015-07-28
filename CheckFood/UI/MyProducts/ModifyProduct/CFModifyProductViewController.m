//
//  CFModifyProductViewController.m
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

#import "CFModifyProductViewController.h"
#import "LOCacheManager.h"
#import "CFMyProductsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CFProduct.h"
#import <sys/socket.h>
#import <netdb.h>
#import "CFProductManager.h"
#import "UIImageView+WebCache.h"
#import "NSString+PercentEscapedURL.h"
#import "CFPopUpValiderProductViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "CFAddProductViewController.h"
#import "CFPopUpErreurViewController.h"
#import "CFActionSheet.h"

#define kCurrentDateFormat @"dd/MM/yyyy"


@interface CFModifyProductViewController ()

@property (nonatomic, strong) UIActionSheet *dateActionSheet;
@property (nonatomic, strong) IBOutlet UIToolbar *datePickerToolBar;

- (IBAction)dateButtonAction:(id)sender;
- (IBAction)cancelDatePickerAction:(id)sender;
- (IBAction)validateDate:(id)sender;



@end

@implementation CFModifyProductViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Cycle Life View
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary * resultproduct = self.productInfo;
    NSLog(@"resultProduct %@", resultproduct);
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.allView.contentSize =CGSizeMake(self.allView.frame.size.width, 508);
    self.titleView.font = [UIFont fontWithName:@"Roboto-Regular" size:13];
    self.statusImage = NO;
    self.datePr.text = [NSString stringWithFormat:@"Périme le :"];
    self.datePr.font = [UIFont fontWithName:@"Roboto-Regular" size:13];
    [self.datePr setTextColor:[UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0]];
    [self.monFrigo setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.monPlacard setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.pickerStatus = YES;
    self.calenderPicker.backgroundColor = [UIColor clearColor];
    self.monPlacardBool = NO;
    self.monFrigoBool = NO;
    self.modifyProduct = NO;
    self.nextButton = YES;
    
    self.boolArray = NO;
  //  self.calenderPicker.minimumDate = [NSDate date];
    
    self.nameProd.text = [self.productInfo objectForKey:@"name"];
    self.marqProd.text = [self.productInfo objectForKey:@"marque"];
    self.codeValue.text = [self.productInfo objectForKey:@"ean"];
    if ([[self.productInfo objectForKey:@"lieu"] isEqualToString:@"monFrigo"] ) {
      
        [self.monFrigo setTitleColor:[UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0] forState:UIControlStateNormal];
        [self.monPlacard setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
    }
    else {
        
        [self.monPlacard setTitleColor:[UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0] forState:UIControlStateNormal];
        [self.monFrigo setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    NSDate *dateprod = [self.productInfo objectForKey:@"date"];
    NSString *dateEX;
    dateEX = dateprod.description; // set text to date description
    NSString *dateExString = [dateEX substringToIndex:10];
    NSString *dayString = [dateExString substringWithRange: NSMakeRange (8, 2)];
    NSString *monthString = [dateExString substringWithRange: NSMakeRange (5, 2)];
    NSString *yearString = [dateExString substringWithRange: NSMakeRange (0, 4)];
    NSString * finalDate = [NSString stringWithFormat:@"%@/%@/%@",dayString,monthString,yearString];
    self.datePr.text = [NSString stringWithFormat:@"Périme le : %@",finalDate];
    
    if ([[self.productInfo objectForKey:@"statusPicture"] isEqualToString:@"local"]) {
       
        NSString * pathImage = [NSString stringWithFormat:@"%@",[self.productInfo objectForKey:@"fullPicture"]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
        
        UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
        
        UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: myImage.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationRight];
        
       
        
        [self.image setImage:PortraitImage];
        
    }
    
    else if ([[self.productInfo objectForKey:@"statusPicture"] isEqualToString:@"url"])
    {
        NSString *urlImage  = [NSString stringWithFormat:@"%@",[self.productInfo objectForKey:@"fullPicture"]];
        [self.image setImageWithURL:[urlImage percentEscapedURL]];
    }
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSingleTap:)];
    
    [self.view addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    CGSize kbSize = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    double duration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Shrink the scroll view's content
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.allView.contentInset = contentInsets;
    self.allView.scrollIndicatorInsets = contentInsets;
    
    // Scroll the text field to be visible (use own animation with keyboard's duration)
    CGRect textFieldRect = [self.marqProd convertRect:self.nameProd.bounds toView:self.allView];
    [UIView animateWithDuration:duration animations:^{
        [self.allView scrollRectToVisible:CGRectInset(textFieldRect, 0.0, -20.0) animated:NO];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    if (self.nextButton == NO) {
    double duration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Set content inset back to default with a nice little animation
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        // self.allView.contentInset = contentInsets;
        self.allView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.allView.scrollIndicatorInsets = contentInsets;
        [self.allView setContentOffset:CGPointZero animated:YES];
    }];
    }
}

#pragma mark - Picker Action Sheet
- (IBAction)dateButtonAction:(id)sender
{
    [self _showDatePicker];
}

- (IBAction)cancelDatePickerAction:(id)sender
{
    [self _dismissDatePicker];
    self.datePr.text = self.datePr.text;
    self.pickerStatus = YES;
}

- (IBAction)validateDate:(id)sender
{
    [self _dismissDatePicker];
    self.pickerStatus = YES;
    self.modifyProduct = YES;
    
    NSString *dateEX;
    dateEX = self.calenderPicker.date.description; // set text to date description
    self.dateTakeByPicker = self.calenderPicker.date;
    NSString *dateExString = [dateEX substringToIndex:10];
    NSString *dayString = [dateExString substringWithRange: NSMakeRange (8, 2)];
    NSString *monthString = [dateExString substringWithRange: NSMakeRange (5, 2)];
    NSString *yearString = [dateExString substringWithRange: NSMakeRange (0, 4)];
    NSString * finalDate = [NSString stringWithFormat:@"%@/%@/%@",dayString,monthString,yearString];
    self.datePr.text = [NSString stringWithFormat:@"Périme le : %@",finalDate];//finalDate;
}

- (void)_showDatePicker
{
    if (!self.dateActionSheet) {
        [self.calenderPicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];        //
        self.dateActionSheet = [[CFActionSheet alloc] initWithFrame:CGRectMake(0., 0., 320., 206.)];
        self.dateActionSheet.backgroundColor = [UIColor whiteColor];
        [self.dateActionSheet addSubview:self.datePickerToolBar];
        [self.dateActionSheet addSubview:self.calenderPicker];
    }
    [self.dateActionSheet showInView:self.view];
    [self.dateActionSheet setBounds:CGRectMake(0., 0., 320., 444.)];
}

- (void)_dismissDatePicker
{
    [self.dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)showFullPicture:(id)sender
{
    if (self.statusImage == NO) {
        [UIView animateWithDuration:0.75 animations:^{
            self.fullImageView.frame = CGRectMake(0, 320, self.fullImageView.frame.size.width, self.fullImageView.frame.size.height);
        }];
        
        self.statusImage = YES;
        
    }
    
    else  if (self.statusImage == YES) {
        [UIView animateWithDuration:0.75 animations:^{
            self.fullImageView.frame = CGRectMake(0, 130, self.fullImageView.frame.size.width, self.fullImageView.frame.size.height);
        }];
        
        self.statusImage = NO;
        
    }
    
    
}

#pragma mark - Private Methods

-(void) cancelLocalNotificationByProductId :(NSString *)productId {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    NSLog(@"count1 %d",eventArray.count);
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfo = oneEvent.userInfo;
        NSMutableDictionary *notificationInfo = [userInfo objectForKey:@"notificationInfo"];
        NSMutableDictionary *product = [notificationInfo objectForKey:@"product"];

        if ([[product objectForKey:@"id"]isEqualToString:productId] ) {
            [app cancelLocalNotification:oneEvent];
        }
    }
}
-(void) scheduleLocalNotificationWithDate:(NSDate *)fireDate userInfo:(NSDictionary *)userInfo{
    
    
    NSMutableDictionary *notificationInfo = [userInfo objectForKey:@"notificationInfo"];
    NSMutableDictionary *product = [notificationInfo objectForKey:@"product"];
    NSString *jourRestant = [notificationInfo objectForKey:@"jourRestant"];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSLog(@"date %@",fireDate);
    
    NSString *msg = @"Le produit ";
    msg = [msg stringByAppendingString:[product objectForKey:@"name"]];
    msg = [msg stringByAppendingString:@" périme dans "];
    msg = [msg stringByAppendingString:jourRestant];
    msg = [msg stringByAppendingString:@" jour(s)"];
    
    
    notification.fireDate = fireDate; //[NSDate dateWithTimeIntervalSinceNow:10];//
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = msg;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


-(NSString *)findLastDaysByDate:(NSMutableDictionary *)product {
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    //   NSString *currentDate = [dateFormatter stringFromDate:currDate];
    
    NSDate *endDate= [product objectForKey:@"date"];
    
    /*  NSDateFormatter *f = [[NSDateFormatter alloc] init];
     [f setDateFormat:@"dd.MM.yyyy"];
     NSDate *Today = [f dateFromString:currentDate];*/
    //NSDate *endDate1 = [f dateFromString:endDate];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:currDate
                                                          toDate:endDate
                                                         options:0];
    int day = [components day];
    
    return [NSString stringWithFormat:@"%d",day];
}

-(NSMutableDictionary *)findProductById :(NSString *)productid {
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    NSString *currentDate = [dateFormatter stringFromDate:currDate];
    
    for (int i=0; i<resultProduct.count; i++) {
        
        NSMutableArray *products = [resultProduct objectAtIndex:i];
        
        for (int j=0; j<products.count;j++) {
            
            NSDictionary *product = [products objectAtIndex:j];
            
            NSString *endDate= [product objectForKey:@"date"];
            NSString *productId= [product objectForKey:@"id"];
            
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"dd.MM.yyyy"];
            NSDate *Today = [f dateFromString:currentDate];
            NSDate *endDate1 = [f dateFromString:endDate];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                fromDate:Today
                                                                  toDate:endDate1
                                                                 options:0];
            int day = [components day];
            NSLog(@"%ld", (long)[components day]);
            if ([productId  isEqual: productid] ) {
                [result setObject:product forKey:@"product"];
                [result setObject: [NSString stringWithFormat:@"%d", day] forKey:@""];
            }
        }
    }
    return result;
}

#pragma mark - Action Button

-(IBAction)backButAction:(id)sender {
    
  /*  CFMyProductsViewController *addVC = [[CFMyProductsViewController alloc]initWithNibName:@"CFMyProductsViewController" bundle:nil];
    [self.navigationController pushViewController:addVC animated:NO];*/
    
      [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)addProduct:(id)sender
{
    NSMutableArray * firstResultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    NSString * idProd;
    NSMutableArray *arrayResult = [firstResultProduct mutableCopy];

    for (int j =0; j< [firstResultProduct count] ; j++) {
        
        for (int i =0; i< [[firstResultProduct objectAtIndex:j] count] ; i++) {
            NSMutableDictionary *productInfo;
            productInfo = self.productInfo;
            
            idProd = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"id"]];
            
            if ([[[[firstResultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"] isEqualToString:idProd]) {
                
                NSLog(@"xxxx %@",[[[firstResultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"]);
                               NSMutableArray *array = [[firstResultProduct objectAtIndex:j] mutableCopy];
                [array removeObjectAtIndex:i];
                if ([arrayResult isKindOfClass: [NSMutableArray class]]) {
                    
                    if (array.count == 0) {
                        
                         [arrayResult removeObjectAtIndex:j];
                    }
                    else {
                        [arrayResult replaceObjectAtIndex:j withObject:array];
                    }
                    
                    
                }
                
            }
        }
    }
    firstResultProduct = arrayResult;
    [[LOCacheManager sharedManager] cacheDict:firstResultProduct withKey:@"items"];

    NSString *pushNotif = [[LOCacheManager sharedManager] getFromCacheWithKey:@"pushNotif"];
        NSMutableDictionary *userInfoNotification = [[NSMutableDictionary alloc]init];
        NSDate *dateLaunch;
        NSString *alertTimeFrigo= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
        NSString *alertTimePlacard= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];
        
        if (![alertTimeFrigo isKindOfClass:[NSString class]]) {
            alertTimeFrigo = @"2";
        }
        if (![alertTimePlacard isKindOfClass:[NSString class]]) {
            alertTimePlacard = @"2";
        }
        
        
        NSMutableArray *resultProduct1 = [NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
        NSString *productId = [[LOCacheManager sharedManager]getFromCacheWithKey:@"productId"];
        
        if (resultProduct1 == nil) {
            resultProduct1 = [[NSMutableArray alloc] init];
        }
        
        if (![productId isKindOfClass:[NSString class]]) {
            
            productId = @"1";
        }
        // First product in application
        if (resultProduct1.count == 0) {
            NSMutableArray * productListe =[[NSMutableArray alloc] init];
            NSMutableDictionary *productInfo = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
            
            [productInfo setObject:productId forKey:@"id"];
            [productInfo setObject:self.nameProd.text forKey:@"name"];
            
            
            if (self.modifyProduct == YES) {
                
                [productInfo setObject:self.calenderPicker.date forKey:@"date"];
            }
            else
            {
                [productInfo setObject:[self.productInfo objectForKey:@"date"] forKey:@"date"];
            }
         //   [productInfo setObject:self.calenderPicker.date forKey:@"date"];
            [productInfo setObject:self.marqProd.text forKey:@"marque"];
            
            if (self.emplacementProd.length == 0)
            {
                [productInfo setObject:[self.productInfo objectForKey:@"lieu"] forKey:@"lieu"];
            }
            else
            {
                 [productInfo setObject:self.emplacementProd forKey:@"lieu"];
            }
            
         //   [productInfo setObject:self.emplacementProd forKey:@"lieu"];
            [productInfo setObject:@"" forKey:@"etat"];
            if (self.productEAN.length == 0) {
                [productInfo setObject:[self.productInfo objectForKey:@"ean"] forKey:@"ean"];
            }
            else {
                [productInfo setObject:self.productEAN forKey:@"ean"];
            }

            [productInfo setObject:@"" forKey:@"dateConsommation"];
             NSString *pictureName = [self.productInfo objectForKey:@"picture"];
            if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"]!=nil)){
                [productInfo setObject:[self.productEANResult  objectForKey:@"imageSmallUrl"] forKey:@"picture"];
                [productInfo setObject:[self.productEANResult  objectForKey:@"imageUrl"] forKey:@"fullPicture"];
                [productInfo setObject:@"url" forKey:@"statusPicture"];
                
            }
           
            else if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"] == nil) && (pictureName.length !=0))
            {
                [productInfo setObject:[self.productInfo objectForKey:@"picture"] forKey:@"picture"];
                [productInfo setObject:[self.productInfo objectForKey:@"fullPicture"] forKey:@"fullPicture"];
                [productInfo setObject:@"local" forKey:@"statusPicture"];
            }
            
            else if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"] == nil) && (pictureName.length ==0))
            {
                  [productInfo setObject:@"" forKey:@"picture"];
                 [productInfo setObject:@"local" forKey:@"statusPicture"];
            }
            
            else if (self.localFilePath != nil){
                
                [productInfo setObject:self.localFilePath forKey:@"picture"];
                [productInfo setObject:self.fullPicturePath forKey:@"fullPicture"];
                [productInfo setObject:@"local" forKey:@"statusPicture"];
                
            }
            
            NSDate *currDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"dd.MM.YY"];
            //   NSString * dateAdd = [dateFormatter stringFromDate:currDate];
            [productInfo setObject:currDate forKey:@"dateADD"];
            
            [self cancelLocalNotificationByProductId:[self.productInfo objectForKey:@"id"]];
            
            if (self.modifyProduct) {
                
                if (self.emplacementProd.length == 0)
                {
                    if ([[self.productInfo objectForKey:@"lieu"] isEqualToString:@"monFrigo"]) {
                        
                        dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                    }
                    else {
                        dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                    }
                }
                else
                {
                    if ([self.emplacementProd isEqualToString:@"monFrigo"]) {
                        
                        dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                    }
                    else {
                        dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                    }
                    
                }
            }
            
            else {
                if (self.emplacementProd.length == 0)
                {
                    if ([[self.productInfo objectForKey:@"lieu"] isEqualToString:@"monFrigo"]) {
                        
                        dateLaunch = [[self.productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                    }
                    else {
                        dateLaunch = [[self.productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                    }
                }
                else
                {
                    if ([self.emplacementProd isEqualToString:@"monFrigo"]) {
                        
                        dateLaunch = [[self.productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                    }
                    else {
                        dateLaunch = [[self.productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                    }
                    
                }
            }
            [userInfoNotification setObject:productId forKey:@"uid"];
            [notificationInfo setObject:productInfo forKey:@"product"];
            [notificationInfo setObject:[self findLastDaysByDate:productInfo] forKey:@"jourRestant"];
            [userInfoNotification setObject:notificationInfo forKey:@"notificationInfo"];
            if ([pushNotif isEqualToString:@"YES"]) {
                [self scheduleLocalNotificationWithDate:dateLaunch userInfo:userInfoNotification];
            }
            
            [productListe addObject:productInfo];
            [resultProduct1 addObject:productListe];
            [[LOCacheManager sharedManager] cacheDict:currDate withKey:@"dateCreate"];
        }
    
        else {
            // product with old date
            for (int i = 0 ; i< resultProduct1.count; i++) {
                
                NSDateFormatter *formatterSorted = [[NSDateFormatter alloc] init];
                [formatterSorted setDateFormat:@"dd.MM.yyyy"];
                
                NSMutableArray * firsObjectArray = [[NSMutableArray alloc] init];
                firsObjectArray = [resultProduct1 objectAtIndex:i];
                if (firsObjectArray.count > 0) {
                    NSString * calendarVal;
                    NSDate *dateProd1 = [[firsObjectArray objectAtIndex:0] objectForKey:@"date"];
                    NSString * dateP = [formatterSorted stringFromDate:dateProd1];
                    if (self.modifyProduct == YES) {
                    calendarVal = [formatterSorted stringFromDate:self.calenderPicker.date];
                    }
                    else {
                        calendarVal = [formatterSorted stringFromDate:[self.productInfo objectForKey:@"date"]];
                    }
                    //   if ([self.datePr.text isEqualToString:dateProd1]){
                    if ([calendarVal isEqualToString:dateP]){
                        
                        NSMutableDictionary *productInfo = [[NSMutableDictionary alloc] init];
                        NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
                        
                        int prodId = [productId intValue];
                        prodId++;
                        productId = [NSString stringWithFormat:@"%d",prodId];
                        [productInfo setObject:productId forKey:@"id"];
                        [productInfo setObject:self.nameProd.text forKey:@"name"];
                       // [productInfo setObject:self.calenderPicker.date forKey:@"date"];
                        if (self.productEAN ) {
                            
                        }
                        if (self.modifyProduct == YES) {
                            
                            [productInfo setObject:self.calenderPicker.date forKey:@"date"];
                        }
                        else
                        {
                            [productInfo setObject:[self.productInfo objectForKey:@"date"] forKey:@"date"];
                        }
 
                        [productInfo setObject:self.marqProd.text forKey:@"marque"];
                        if (self.emplacementProd.length == 0)
                        {
                            [productInfo setObject:[self.productInfo objectForKey:@"lieu"] forKey:@"lieu"];
                        }
                        else
                        {
                            [productInfo setObject:self.emplacementProd forKey:@"lieu"];
                        }

                      //  [productInfo setObject:self.emplacementProd forKey:@"lieu"];
                        [productInfo setObject:@"" forKey:@"etat"];
                        if (self.productEAN.length == 0) {
                            [productInfo setObject:[self.productInfo objectForKey:@"ean"] forKey:@"ean"];
                        }
                        else {
                            [productInfo setObject:self.productEAN forKey:@"ean"];
                        }

                        [productInfo setObject:@"" forKey:@"dateConsommation"];
                        NSString *pictureName = [self.productInfo objectForKey:@"picture"];

                        if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"]!=nil)){
                            [productInfo setObject:[self.productEANResult  objectForKey:@"imageSmallUrl"] forKey:@"picture"];
                            [productInfo setObject:[self.productEANResult  objectForKey:@"imageUrl"] forKey:@"fullPicture"];
                            [productInfo setObject:@"url" forKey:@"statusPicture"];
                        }
                        
                        else if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"] == nil) && (pictureName.length !=0))
                        {
                            [productInfo setObject:[self.productInfo objectForKey:@"picture"] forKey:@"picture"];
                            [productInfo setObject:[self.productInfo objectForKey:@"fullPicture"] forKey:@"fullPicture"];
                            [productInfo setObject:[self.productInfo objectForKey:@"statusPicture"] forKey:@"statusPicture"];
                        }
                        
                        else if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"] == nil) && (pictureName.length ==0))
                        {
                            [productInfo setObject:@"" forKey:@"picture"];
                            [productInfo setObject:@"local" forKey:@"statusPicture"];
                        }
                        
                        else if (self.localFilePath != nil)
                        {
                            [productInfo setObject:self.localFilePath forKey:@"picture"];
                            [productInfo setObject:self.fullPicturePath forKey:@"fullPicture"];
                            [productInfo setObject:@"local" forKey:@"statusPicture"];
                        }
                        
                        NSDate *currDate = [NSDate date];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"dd.MM.YY"];
                        //   NSString * dateAdd = [dateFormatter stringFromDate:currDate];
                        [productInfo setObject:currDate forKey:@"dateADD"];
                        
                        NSMutableArray *array = [firsObjectArray mutableCopy];
                        if (([array isKindOfClass:[NSMutableArray class]])) {
                            [array addObject:productInfo];
                            [resultProduct1  replaceObjectAtIndex:i withObject:array];
                        }
                        self.boolArray = YES;
                        [self cancelLocalNotificationByProductId:[self.productInfo objectForKey:@"id"]];
   
                        if (self.modifyProduct) {
                            
                            if (self.emplacementProd.length == 0)
                            {
                                if ([[self.productInfo objectForKey:@"lieu"] isEqualToString:@"monFrigo"]) {
                                    
                                    dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                                }
                                else {
                                    dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                                }
                            }
                            else
                            {
                                if ([self.emplacementProd isEqualToString:@"monFrigo"]) {
                                    
                                    dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                                }
                                else {
                                    dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                                }
                            }
                        }
                
                        else {
                            if ([self.emplacementProd isEqualToString:@"monFrigo"]) {
                                dateLaunch = [[self.productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                            }
                            else {
                                dateLaunch = [[self.productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                            }
                        }
                        [userInfoNotification setObject:productId forKey:@"uid"];
                        [notificationInfo setObject:productInfo forKey:@"product"];
                        [notificationInfo setObject:[self findLastDaysByDate:productInfo] forKey:@"jourRestant"];
                        [userInfoNotification setObject:notificationInfo forKey:@"notificationInfo"];
                        if ([pushNotif isEqualToString:@"YES"]) {
                            [self scheduleLocalNotificationWithDate:dateLaunch userInfo:userInfoNotification];
                        }
                        break;
                }
            }
            }
            // product with new date
            if ( self.boolArray == NO) {
                NSMutableArray * productListe =[[NSMutableArray alloc] init];
                NSMutableDictionary *productInfo = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
                
                int prodId = [productId intValue];
                prodId++;
                productId = [NSString stringWithFormat:@"%d",prodId];
                [productInfo setObject:productId forKey:@"id"];
                [productInfo setObject:self.nameProd.text forKey:@"name"];
             //   [productInfo setObject:self.calenderPicker.date forKey:@"date"];
                if (self.modifyProduct == YES) {
                    [productInfo setObject:self.calenderPicker.date forKey:@"date"];
                }
                else
                {
                    [productInfo setObject:[self.productInfo objectForKey:@"date"] forKey:@"date"];
                }
                
                [productInfo setObject:self.marqProd.text forKey:@"marque"];
            //    [productInfo setObject:self.emplacementProd forKey:@"lieu"];
                if (self.emplacementProd.length == 0)
                {
                    [productInfo setObject:[self.productInfo objectForKey:@"lieu"] forKey:@"lieu"];
                }
                else
                {
                    [productInfo setObject:self.emplacementProd forKey:@"lieu"];
                }

                [productInfo setObject:@"" forKey:@"etat"];
                
                if (self.productEAN.length == 0) {
                    [productInfo setObject:[self.productInfo objectForKey:@"ean"] forKey:@"ean"];
                }
                else {
                     [productInfo setObject:self.productEAN forKey:@"ean"];
                }
               
                [productInfo setObject:@"" forKey:@"dateConsommation"];
                 NSString *pictureName = [self.productInfo objectForKey:@"picture"];
                if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"]!=nil)){
                    [productInfo setObject:[self.productEANResult  objectForKey:@"imageSmallUrl"] forKey:@"picture"];
                    [productInfo setObject:[self.productEANResult  objectForKey:@"imageUrl"] forKey:@"fullPicture"];
                    [productInfo setObject:@"url" forKey:@"statusPicture"];
                    
                }
                
                else if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"] == nil) && (pictureName.length !=0))
                {
                    
                    [productInfo setObject:[self.productInfo objectForKey:@"picture"] forKey:@"picture"];
                    [productInfo setObject:[self.productInfo objectForKey:@"fullPicture"] forKey:@"fullPicture"];
                    [productInfo setObject:@"local" forKey:@"statusPicture"];
                }
                
                else if ((self.localFilePath == nil) && ([self.productEANResult  objectForKey:@"imageSmallUrl"] == nil) && (pictureName.length ==0))
                {
                    [productInfo setObject:@"" forKey:@"picture"];
                    [productInfo setObject:@"local" forKey:@"statusPicture"];
                }
                
                else if (self.localFilePath != nil){
                    
                    [productInfo setObject:self.localFilePath forKey:@"picture"];
                    [productInfo setObject:self.fullPicturePath forKey:@"fullPicture"];
                    [productInfo setObject:@"local" forKey:@"statusPicture"];
                }
                
                NSDate *currDate = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"dd.MM.YY"];
                //   NSString * dateAdd = [dateFormatter stringFromDate:currDate];
                [productInfo setObject:currDate forKey:@"dateADD"];
                
                [productListe addObject:productInfo];
                [resultProduct1 addObject:productListe];
                
                [self cancelLocalNotificationByProductId:[self.productInfo objectForKey:@"id"]];
                if (self.modifyProduct) {
                    
                    if (self.emplacementProd.length == 0)
                    {
                        if ([[self.productInfo objectForKey:@"lieu"] isEqualToString:@"monFrigo"]) {
                            
                            dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                        }
                        else {
                            dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                        }
                    }
                    else
                    {
                        if ([self.emplacementProd isEqualToString:@"monFrigo"]) {
                            
                            dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                        }
                        else {
                            dateLaunch = [self.dateTakeByPicker dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                        }
                    }
                }
                
                else {
                    
                    if ([self.emplacementProd isEqualToString:@"monFrigo"]) {
                        dateLaunch = [[self.productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                    }
                    else {
                        dateLaunch = [[self.productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                    }
                }
                [userInfoNotification setObject:productId forKey:@"uid"];
                [notificationInfo setObject:productInfo forKey:@"product"];
                [notificationInfo setObject:[self findLastDaysByDate:productInfo] forKey:@"jourRestant"];
                [userInfoNotification setObject:notificationInfo forKey:@"notificationInfo"];
                if ([pushNotif isEqualToString:@"YES"]) {
                    [self scheduleLocalNotificationWithDate:dateLaunch userInfo:userInfoNotification];
                }
            }
        }
    
        [[LOCacheManager sharedManager] cacheDict:resultProduct1 withKey:@"items"];
        [[LOCacheManager sharedManager] cacheDict:productId withKey:@"productId"];
    
        CFPopUpValiderProductViewController *validViewController = [[CFPopUpValiderProductViewController alloc] initWithNibName:@"CFPopUpValiderProductViewController" bundle:nil];
        validViewController.parentNavController = self.navigationController;
        validViewController.messageValide  =  @"Votre produit est modifié avec succès";
    
     if (self.emplacementProd.length == 0)
     {
          [validViewController setEmplacement:[self.productInfo objectForKey:@"lieu"]];
     }
    
     else {
         [validViewController setEmplacement:self.emplacementProd];
     }
        [self presentPopupViewController:validViewController animationType:MJPopupViewAnimationFade];
        
        // initialisation of values
        self.nameProd.text = @"";
        self.localFilePath = @"";
        self.marqProd.text = @"";
        self.datePr.text = @"";
        self.emplacementProd = @"";
        self.image.image = [UIImage imageNamed:@"comments_profile_image.png"];
        self.fullImage.image = [UIImage imageNamed:@"comments_profile_image.png"];
        self.urlImage = @"(null)";
        [self.monFrigo setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.monPlacard setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
  // }
    
}

- (IBAction)cancelAddproduct:(id)sender
{
    CFMyProductsViewController *addVC = [[CFMyProductsViewController alloc]initWithNibName:@"CFMyProductsViewController" bundle:nil];
    [self.navigationController pushViewController:addVC animated:NO];
}

- (void)fixCameraOrientation:(NSNotification*)notification
{
    if (self.imgPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                self.imgPicker.cameraViewTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.65, 0.65),CGAffineTransformMakeTranslation(-35 , 100));
                NSLog(@"1");
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                self.imgPicker.cameraViewTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.65, 0.65),CGAffineTransformMakeTranslation(25 , -70));
                NSLog(@"2");
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
                NSLog(@"3");
                
                break;
                
            case UIInterfaceOrientationPortrait:
                NSLog(@"4");
                
                break;
                
            default:
                break;
        }
    }
    
}

- (IBAction)saveFrigo:(id)sender
{
    self.monFrigoBool = YES;
    self.monPlacardBool = NO;
    [self.monFrigo setTitleColor:[UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0] forState:UIControlStateNormal];
    [self.monPlacard setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.emplacementProd = @"monFrigo";
}

- (IBAction)savePlacard:(id)sender
{
    self.monPlacardBool = YES;
    self.monFrigoBool = NO;
    [self.monPlacard setTitleColor:[UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0] forState:UIControlStateNormal];
    
    
    [self.monFrigo setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.emplacementProd = @"monPlacard";
}

#pragma mark - CamDelegate
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.popoverControllerCam dismissPopoverAnimated:true];
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
        
        self.image.image = image;
        self.fullImage.image = image;
        
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(image:finishedSavingWithError:contextInfo:),
                                       nil);
        
        NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        
        // define the block to call when we get the asset based on the url (below)
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
        {
            ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
            NSLog(@"[imageRep filename] : %@", [imageRep filename]);
        };
        
        // get the asset library and fetch the asset based on the ref url (pass in block above)
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    }
    
    self.image.image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.fullImage.image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData *webData = UIImagePNGRepresentation(self.image.image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
	//Create unique filename
	CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
	NSString * path = [documentsDirectory stringByAppendingPathComponent:(__bridge NSString *)newUniqueIdString];
	path = [path stringByAppendingPathExtension: @"png"];
	CFRelease(newUniqueId);
	CFRelease(newUniqueIdString);
    
    // first Picture
    [webData writeToFile:path atomically:YES];
    NSLog(@"path###%@",path);
    UIImage * resultImagePath = [UIImage imageWithContentsOfFile:path];
    NSLog(@"Image:%@", self.image.image);
    
    UIImage * resultImage = [self imageWithImage:resultImagePath convertToSize:CGSizeMake(140,160)];
    
    NSString *someString = path;
    NSRange isRange = [someString rangeOfString:@"/Documents/" options:NSCaseInsensitiveSearch];
    NSLog(@"location ###%d",isRange.location);
    
    NSString *pictureName = [path substringWithRange: NSMakeRange ((isRange.location + 11), 40)];
    NSLog(@"image name ###%@",pictureName);
    self.fullPicturePath = pictureName;
    NSLog(@"self.localFilePath ###%@",self.fullPicturePath);
    
    NSData *webData2 = UIImagePNGRepresentation(resultImage);
    NSArray *paths2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory2 = [paths2 objectAtIndex:0];
    
	//Create unique filename
	CFUUIDRef newUniqueId2 = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef newUniqueIdString2 = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId2);
	NSString * path2 = [documentsDirectory2 stringByAppendingPathComponent:(__bridge NSString *)newUniqueIdString2];
	path2 = [path2 stringByAppendingPathExtension: @"png"];
	CFRelease(newUniqueId2);
	CFRelease(newUniqueIdString2);
    
    // final Picture
    [webData2 writeToFile:path2 atomically:YES];
    NSLog(@"path###%@",path2);
    
    NSString *someString2 = path2;
    NSRange isRange2 = [someString2 rangeOfString:@"/Documents/" options:NSCaseInsensitiveSearch];
    NSLog(@"location ###%d",isRange2.location);
    
    
    NSString *pictureName2 = [path2 substringWithRange: NSMakeRange ((isRange2.location + 11), 40)];
    NSLog(@"image name ###%@",pictureName2);
    self.localFilePath = pictureName2;
    NSLog(@"self.localFilePath ###%@",self.localFilePath);
    
    
    [[LOCacheManager sharedManager] cacheDict:webData withKey:@"picture"];
    
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
   /* if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }*/
}




-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// take picture
- (IBAction) useCamera: (id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        
        self.imgPicker = [[UIImagePickerController alloc] init];
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imgPicker.delegate = self;
        [self presentViewController:self.imgPicker animated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixCameraOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
    } else {
        self.imgPicker = [[UIImagePickerController alloc] init];
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imgPicker.delegate = self;
        [self presentViewController:self.imgPicker animated:YES completion:nil];
        
    }
}

#pragma mark -TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.nameProd) {
        self.nextButton = YES;
        [self.nameProd resignFirstResponder];
        [self.marqProd becomeFirstResponder];
    }
    else if (textField == self.marqProd) {
        self.nextButton = NO;
        [self.marqProd resignFirstResponder];
    }
    return NO;
    
    
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [self.nameProd resignFirstResponder];
    [self.marqProd resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
