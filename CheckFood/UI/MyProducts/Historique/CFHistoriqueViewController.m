//
//  CFHistoriqueViewController.m
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

#import "CFHistoriqueViewController.h"
#import "CFMyProductsViewController.h"
#import "CFDateProductTableViewCell.h"
#import "CFHistoriqueTableViewCell.h"
#import "CFCaptureProductViewController.h"
#import "LOCacheManager.h"
#import "UIImageView+WebCache.h"
#import "NSString+PercentEscapedURL.h"
#import "CFActionSheet.h"
#import "CFPopUpErreurDateViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "CFPopUPErreurDateHistoriqueViewController.h"
#import "CFActionSheetHist.h"
#import "CFAppDelegate.h"

static NSString * const ProductCellIdentifier = @"ProductCell";
static NSString * const ProductSuiteCellIdentifier = @"SuiteProductCell";

@interface CFHistoriqueViewController ()

@property (nonatomic, strong) NSMutableArray *searchResult;
@property (nonatomic, strong) CFActionSheetHist *dateActionSheet;
@property (nonatomic, strong) IBOutlet UIToolbar *datePickerToolBar;


@end

@implementation CFHistoriqueViewController

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_mon_placard.png"]];
    [self.productTable registerNib:[UINib nibWithNibName:@"CFHistoriqueTableViewCell" bundle:nil]  forCellReuseIdentifier:ProductCellIdentifier];
    [self.productTable registerNib:[UINib nibWithNibName:@"CFDateProductTableViewCell" bundle:nil]  forCellReuseIdentifier:ProductSuiteCellIdentifier];
    self.suiteCellOpened = NO;
    self.buttonClick = 0;
    self.boolValues = [[NSMutableArray alloc] init];
    self.allProductsArray = [[NSMutableArray alloc] init];
    self.resultSearchArray = [[NSMutableArray alloc] init];
    self.calenderPicker.backgroundColor = [UIColor whiteColor];
    self.buttonSelected = NO;
    self.buttonValid = NO;
    self.buttonValidFinal = NO;
    self.pickerStatus = YES;
    self.addProdBool = NO;
    self.saveProd = NO;
    self.resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    
    [self.calenderPicker addTarget:self action:@selector(pickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.countSection = 0;
    
    for (int i = 0; i< self.resultProduct.count; i++) {
        self.countSection = self.countSection + [[self.resultProduct objectAtIndex:i] count];
    }
    NSLog(@"count == %d", self.countSection);
    // values cell
    for (int i = 0; i< (self.countSection * 2); i++) {
        NSInteger num = 1;
        NSNumber *number = [NSNumber numberWithInt:num];
        
        [self.boolValues addObject:number];
        
    }
    
    self.resultConcatProduct = [[NSMutableArray alloc] init];
    for (int i = 0; i< self.resultProduct.count; i++) {
        self.countSection = self.countSection + [[self.resultProduct objectAtIndex:i] count];
    }
    
    self.searchResult = [NSMutableArray arrayWithCapacity:[self.resultConcatProduct count]];
    self.pastUrls = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.resultConcatProduct count]; i++) {
        
        NSMutableDictionary * productInfo = [self.resultConcatProduct objectAtIndex:i];
        NSString * nameProd = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"name"]];
        [self.pastUrls addObject:nameProd];
    }
    
    self.autocompleteUrls = [[NSMutableArray alloc] init];
    
    NSLog(@"result");
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSingleTap:)];
    
    [self.view addGestureRecognizer:tapGesture];
    self.reloadTabel = NO;
    
    
    
}

-(void)viewDidAppear :(BOOL)animated {
    
     [super viewDidAppear:animated];
    //Add product Table
    for (int j =0; j< [self.resultProduct count] ; j++) {
        
        for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
            
            [self.resultConcatProduct addObject:[[self.resultProduct objectAtIndex:j] objectAtIndex:i]];
        }
    }
    
    self.allProductsArray = self.resultConcatProduct;
    
   NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];
     NSMutableArray *resultArray =  [self.resultConcatProduct mutableCopy];
    for (int i = 0; i< self.resultConcatProduct.count; i++) {
        
       NSString * productName = [[self.resultConcatProduct objectAtIndex:i] objectForKey:@"ean"];
        
        for (int j = i+1; j< self.resultConcatProduct.count; j++) {
            
            if ([productName isEqualToString:[[self.resultConcatProduct objectAtIndex:j] objectForKey:@"ean"]]) {
                
                [indexesToRemove addIndex:i];
            }
        }
    }
    
    [resultArray removeObjectsAtIndexes:indexesToRemove];
    
    self.resultConcatProduct = resultArray;
    
    [self.productTable reloadData];
    if (self.resultConcatProduct.count == 0) {
        self.productTable.hidden = YES;
    }
    
    else {
        self.productTable.hidden = NO;
    }


}

-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
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
    NSDate *endDate= [product objectForKey:@"date"];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:currDate
                                                          toDate:endDate
                                                         options:0];
    int day = [components day];
    
    return [NSString stringWithFormat:@"%d",day];
}


- (IBAction)dateButtonAction:(id)sender
{
    [self _showDatePicker];
}

- (IBAction)cancelDatePickerAction:(id)sender
{
    [self _dismissDatePicker];
    self.pickerStatus = YES;
}
- (void) resetViewAndDismissAllPopups
{
  //  self.datePr.text = [NSString stringWithFormat:@"Périme le :"];
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    [self _showDatePicker];
}

- (void) dismissPickerShowPopUp
{
    NSDate *currDate = [NSDate date];
    NSDate *dateAddProd = self.calenderPicker.date;
    NSComparisonResult result;
    
    result = [currDate compare:dateAddProd]; // comparing two dates
    if(result==NSOrderedDescending){
        NSLog(@"newDate is less");
        [self _dismissDatePicker];
        CFPopUPErreurDateHistoriqueViewController *erreurPopUp = [[CFPopUPErreurDateHistoriqueViewController alloc] initWithNibName:@"CFPopUPErreurDateHistoriqueViewController" bundle:nil];
        erreurPopUp.parentNavController = self.navigationController;
        erreurPopUp.messageErreur  = @"Veuillez choisir une date correcte, svp.";
        
        [self presentPopupViewController:erreurPopUp animationType:MJPopupViewAnimationFade];
        
        
    }
    
    else {
         
        [self _dismissDatePicker];
        self.pickerStatus = YES;
        NSString *dateEX;
        dateEX = self.calenderPicker.date.description; // set text to date description
        // self.dateTakeByPicker = self.calenderPicker.date;
        NSString *dateExString = [dateEX substringToIndex:10];
        NSString *dayString = [dateExString substringWithRange: NSMakeRange (8, 2)];
        NSString *monthString = [dateExString substringWithRange: NSMakeRange (5, 2)];
        NSString *yearString = [dateExString substringWithRange: NSMakeRange (0, 4)];
        NSString * finalDate = [NSString stringWithFormat:@"%@/%@/%@",dayString,monthString,yearString];
        self.datePr = finalDate;
        
        NSMutableDictionary *productInfo;
        productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.resultConcatProduct objectAtIndex:(self.buttonClick/2)]] ;
        
        NSMutableDictionary *cachDict = [[NSMutableDictionary alloc] init];
        NSDate * datePr = [productInfo  objectForKey:@"date"];
        NSString * idCurrentProd = [productInfo  objectForKey:@"id"];
        
        [cachDict setObject:datePr forKey:@"date"];
        [cachDict setObject:idCurrentProd forKey:@"id"];
        
        [[LOCacheManager sharedManager] cacheDict:cachDict withKey:@"currentProd"];
        
        if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
            // save date
            if (self.datePr != nil) {
                //  [productInfo setObject:self.datePr forKey:@"date"];
                [productInfo setObject:self.calenderPicker.date forKey:@"date"];
                [self.resultConcatProduct replaceObjectAtIndex:(self.buttonClick/2) withObject:productInfo];
            }

            
            [self.productTable reloadData];
            self.buttonSelected = YES;
            self.buttonValid = YES;

        }
        
        self.addProdBool = YES;
    }

}

- (IBAction)validateDate:(id)sender
{
    NSDate *currDate = [NSDate date];
    NSDate *dateAddProd = self.calenderPicker.date;
    NSComparisonResult result;
    
    result = [currDate compare:dateAddProd]; // comparing two dates
    
    if(result==NSOrderedDescending){
        NSLog(@"newDate is less");
        [self _dismissDatePicker];
        CFPopUPErreurDateHistoriqueViewController *erreurPopUp = [[CFPopUPErreurDateHistoriqueViewController alloc] initWithNibName:@"CFPopUPErreurDateHistoriqueViewController" bundle:nil];
        erreurPopUp.parentNavController = self.navigationController;
        erreurPopUp.messageErreur  = @"Veuillez choisir une date correcte, svp.";
        
        [self presentPopupViewController:erreurPopUp animationType:MJPopupViewAnimationFade];
    }
    
    else {
        [self _dismissDatePicker];
        self.pickerStatus = YES;
        NSString *dateEX;
        dateEX = self.calenderPicker.date.description; // set text to date description
        // self.dateTakeByPicker = self.calenderPicker.date;
        NSString *dateExString = [dateEX substringToIndex:10];
        NSString *dayString = [dateExString substringWithRange: NSMakeRange (8, 2)];
        NSString *monthString = [dateExString substringWithRange: NSMakeRange (5, 2)];
        NSString *yearString = [dateExString substringWithRange: NSMakeRange (0, 4)];
        NSString * finalDate = [NSString stringWithFormat:@"%@/%@/%@",dayString,monthString,yearString];
        self.datePr = finalDate;
        
        NSMutableDictionary *productInfo;
        productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.resultConcatProduct objectAtIndex:(self.buttonClick/2)]] ;
        
        NSMutableDictionary *cachDict = [[NSMutableDictionary alloc] init];
        NSDate * datePr = [productInfo  objectForKey:@"date"];
        NSString * idCurrentProd = [productInfo  objectForKey:@"id"];
        
        [cachDict setObject:datePr forKey:@"date"];
        [cachDict setObject:idCurrentProd forKey:@"id"];
        
        [[LOCacheManager sharedManager] cacheDict:cachDict withKey:@"currentProd"];
        
        if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
            // save date
            if (self.datePr != nil) {
                //  [productInfo setObject:self.datePr forKey:@"date"];
                [productInfo setObject:self.calenderPicker.date forKey:@"date"];
                [self.resultConcatProduct replaceObjectAtIndex:(self.buttonClick/2) withObject:productInfo];
            }
            
            [self.productTable reloadData];
            self.buttonSelected = YES;
            self.buttonValid = YES;
        }
        
        self.addProdBool = YES;
    }
}

- (void)_showDatePicker
{
    if (!self.dateActionSheet) {
        [self.calenderPicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];        //
      //  self.dateActionSheet = [[CFActionSheet alloc] initWithFrame:CGRectMake(0., 0., 320., 206.)];
        self.dateActionSheet = [[CFActionSheetHist alloc] initWithFrame:CGRectMake(0., 0., 320., 150)];
        self.dateActionSheet.backgroundColor = [UIColor whiteColor];
        [self.dateActionSheet addSubview:self.datePickerToolBar];
        [self.dateActionSheet addSubview:self.calenderPicker];
      }
    
    [self.dateActionSheet showInView:self.view];
  //  [self.dateActionSheet setBounds:CGRectMake(0., 0., 320., 444.)];
     [self.dateActionSheet setBounds:CGRectMake(0., 0., 320., 390)];
}

- (void)_dismissDatePicker
{
    [self.dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) dismissActionSheet:(UIGestureRecognizer*) gesture
{
    [self.dateActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}
#pragma mark -TextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.rechercheProd resignFirstResponder];
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    
    [self.rechercheProd resignFirstResponder];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([newText isEqualToString:@""]) {
        self.reloadTabel = NO;
        [self.productTable reloadData];
    }
    
    else {
        
        [self searchArray:newText];
    }
    return YES;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  
    [self.productTable reloadData];
    return YES;
}

#pragma mark - ActionButton

- (IBAction)backViewAction:(id)sender
{
   NSArray *viewControllers =  [self.navigationController viewControllers];
    UIViewController *lastVC = [viewControllers lastObject];
    
    CFNavigationController *mainNavVC = (CFNavigationController *)[(CFAppDelegate *)[[UIApplication sharedApplication] delegate] mainNavigationController];
    [mainNavVC tableView:mainNavVC.menuTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
   
    if ([lastVC isKindOfClass:[CFMyProductsViewController class]]) {
        [self.navigationController popToViewController:lastVC animated:NO];
    }
    else {
        CFMyProductsViewController *productsVC = [[CFMyProductsViewController alloc]initWithNibName:@"CFMyProductsViewController" bundle:nil];
        [self.navigationController pushViewController:productsVC animated:NO];
    }
   
  /*  CFCaptureProductViewController *productsVC = [[CFCaptureProductViewController alloc]initWithNibName:@"CFCaptureProductViewController" bundle:nil];
    [self.navigationController pushViewController:productsVC animated:NO];*/
}

// open cell date
- (IBAction)openSuiteCellAction:(UIButton *)sender
{
    self.buttonClick = sender.tag;
    
    for (int i =0; i < (self.resultConcatProduct.count * 2); i++) {
        if (i == sender.tag) {
            
            if ([[self.boolValues objectAtIndex:i] intValue] == 0) {
                NSInteger num = 1;
                NSNumber *number = [NSNumber numberWithInt:num];
                [self.boolValues replaceObjectAtIndex:i withObject:number];
                [self.productTable reloadData];
            }
            
            else  {
                NSInteger num = 0;
                NSNumber *number = [NSNumber numberWithInt:num];
                [self.boolValues replaceObjectAtIndex:i withObject:number];
                
                for (int j = 0; j < i; j++) {
                    
                    if ([[self.boolValues objectAtIndex:j] intValue] == 0) {
                        NSInteger num = 1;
                        NSNumber *number = [NSNumber numberWithInt:num];
                        [self.boolValues replaceObjectAtIndex:j withObject:number];
                    }
                }
                for (int k = i+1; k < (self.resultConcatProduct.count * 2); k++) {
                    
                    if ([[self.boolValues objectAtIndex:k] intValue] == 0) {
                        NSInteger num = 1;
                        NSNumber *number = [NSNumber numberWithInt:num];
                        [self.boolValues replaceObjectAtIndex:k withObject:number];
                    }
                }
               [self.productTable reloadData];
            }
        }
    }
}

// close cell date
- (IBAction)closeSuiteCellAction:(UIButton *)sender
{
    
    NSDate *dateLaunch;
    NSString *alertTimeFrigo= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
    NSString *alertTimePlacard= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];
    NSMutableDictionary *userInfoNotification = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *notificationInfo = [[NSMutableDictionary alloc] init];
    NSString *pushNotif = [[LOCacheManager sharedManager] getFromCacheWithKey:@"pushNotif"];
    
    for (int i =0; i < (self.resultConcatProduct.count * 2); i++) {
        if (i == sender.tag) {
            
            if ([[self.boolValues objectAtIndex:i-1] intValue] == 0)  {
                self.buttonValidFinal = YES;
                self.saveProd = YES;
                
                NSInteger num = 1;
                BOOL foundDate = NO;
                NSNumber *number = [NSNumber numberWithInt:num];
                [self.boolValues replaceObjectAtIndex:i-1 withObject:number];
                [self.productTable beginUpdates];
                [self reloadCellWithAnimation:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
                [self reloadCellWithAnimation:[NSIndexSet indexSetWithIndex:i-1] withRowAnimation:UITableViewRowAnimationFade];
                [self.productTable endUpdates];
                
                //create id
                NSString * idProd;
                NSMutableArray *idProdArray = [[NSMutableArray alloc] init];
                for (int i = 0; i<self.allProductsArray.count; i++) {
                    
                    NSString *idProdCurrent = [[self.allProductsArray objectAtIndex:i] objectForKey:@"id"];
                    [idProdArray addObject:idProdCurrent];
                }
                int max = [[idProdArray valueForKeyPath:@"@max.intValue"] intValue];
                int idProdFinal = max + 1;
                idProd = [NSString stringWithFormat:@"%d",idProdFinal];
                NSLog(@"id max %@", idProd);
                //Find info last Product
                NSMutableDictionary *lastProductInfo = [[NSMutableDictionary alloc] init];
                lastProductInfo = [NSMutableDictionary dictionaryWithDictionary:[self.resultConcatProduct objectAtIndex:(self.buttonClick/2)]] ;
                //create new Product
                NSMutableDictionary *productInfo = [[NSMutableDictionary alloc] init];
                if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
                    
                    [productInfo setObject:idProd forKey:@"id"];
                    [productInfo setObject:[lastProductInfo objectForKey:@"name"] forKey:@"name"];
                    //  [productInfo setObject:self.calenderPicker.date forKey:@"date"];
                    [productInfo setObject:[lastProductInfo objectForKey:@"marque"] forKey:@"marque"];
                    [productInfo setObject:[lastProductInfo objectForKey:@"lieu"] forKey:@"lieu"];
                    [productInfo setObject:@"" forKey:@"etat"];
                    [productInfo setObject:@"" forKey:@"dateConsommation"];
                    [productInfo setObject:[lastProductInfo objectForKey:@"ean"] forKey:@"ean"];
                    [productInfo setObject:[lastProductInfo objectForKey:@"picture"] forKey:@"picture"];
                    [productInfo setObject:[lastProductInfo objectForKey:@"fullPicture"]  forKey:@"fullPicture"];
                    [productInfo setObject:[lastProductInfo objectForKey:@"statusPicture"] forKey:@"statusPicture"];
                    
                    NSDate *currDate = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"dd.MM.YY"];
                    [productInfo setObject:currDate forKey:@"dateADD"];
                    [productInfo setObject:[lastProductInfo objectForKey:@"date"] forKey:@"date"];
                    
                    
                }
                
                for (int j =0; j< [self.resultProduct count] ; j++) {
                    for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                        
                        NSDate *datePrProd = [productInfo objectForKey:@"date"];
                        if ([[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"date"] isEqualToDate:datePrProd]) {
                            
                            NSLog(@"xxxx %@",[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"date"]);
                            NSMutableArray *arrayResult = [self.resultProduct mutableCopy];
                            NSMutableArray *array = [[self.resultProduct objectAtIndex:j] mutableCopy];
                            [array addObject:productInfo];
                            if ([arrayResult isKindOfClass: [NSMutableArray class]]) {
                                [arrayResult replaceObjectAtIndex:j withObject:array];
                            }
                            
                            foundDate = YES;
                            self.resultProduct = arrayResult;
                            break;
                        }
                    }
                }
                
                if (foundDate == NO) {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    [array addObject:productInfo];
                    NSMutableArray *arrayResult = [self.resultProduct mutableCopy];
                    if ([arrayResult isKindOfClass: [NSMutableArray class]]) {
                        [arrayResult addObject:array];
                    }
                    self.resultProduct = arrayResult;
                }
                
                if ([[productInfo objectForKey:@"lieu"] isEqualToString:@"monFrigo"]) {
                    
                    dateLaunch = [[productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimeFrigo intValue])*24*60*60];
                }
                else {
                    dateLaunch = [[productInfo objectForKey:@"date"] dateByAddingTimeInterval:-([alertTimePlacard intValue])*24*60*60];
                }
                
                [userInfoNotification setObject:[productInfo objectForKey:@"id"] forKey:@"uid"];
                [notificationInfo setObject:productInfo forKey:@"product"];
                [notificationInfo setObject:[self findLastDaysByDate:productInfo] forKey:@"jourRestant"];
                [userInfoNotification setObject:notificationInfo forKey:@"notificationInfo"];
                
                if ([pushNotif isEqualToString:@"YES"]) {
                    [self scheduleLocalNotificationWithDate:dateLaunch userInfo:userInfoNotification];
                }
                
                [[LOCacheManager sharedManager] cacheDict:self.resultProduct withKey:@"items"];
            }
            NSMutableArray *arrayValid = [[NSMutableArray alloc] init];
            for (int j =0; j< [self.resultProduct count] ; j++) {
                
                for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                    
                    [arrayValid addObject:[[self.resultProduct objectAtIndex:j] objectAtIndex:i]];
                }
            }
            self.allProductsArray = arrayValid;
            
            
            
            NSMutableDictionary * curProductInfo =  [NSMutableDictionary dictionaryWithDictionary:[[LOCacheManager sharedManager] getFromCacheWithKey:@"currentProd"]];
            NSString *idProdMod ;
            NSDate *dateProduct ;
            if ([curProductInfo isKindOfClass: [NSMutableDictionary class]]) {
                
                idProdMod =[NSString stringWithFormat:@"%@",[curProductInfo objectForKey:@"id"]];
                dateProduct =[curProductInfo objectForKey:@"date"];
            }
            // new value date
            NSMutableDictionary *productInfo;
            productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.resultConcatProduct objectAtIndex:(self.buttonClick/2)]] ;
            
            if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
                // save date
                if (self.datePr != nil) {
                    //  [productInfo setObject:self.datePr forKey:@"date"];
                    [productInfo setObject:dateProduct forKey:@"date"];
                    [self.resultConcatProduct replaceObjectAtIndex:(self.buttonClick/2) withObject:productInfo];
                }
                
                for (int i =0; i < self.allProductsArray.count; i++) {
                    
                    if ([idProdMod isEqualToString:[[self.allProductsArray objectAtIndex:i] objectForKey:@"id"]]) {
                        
                        NSLog(@"xxxx %@",[[self.allProductsArray objectAtIndex:i] objectForKey:@"id"]);
                        NSMutableArray *arrayResult = [self.allProductsArray mutableCopy];
                        [arrayResult replaceObjectAtIndex:i withObject:productInfo];
                        self.allProductsArray = arrayResult;
                    }
                }
            }
            // modify date for product
            NSMutableArray *resultProd = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.allProductsArray.count; i++) {
                
                BOOL boolVal = NO;
                BOOL firstProdBool = NO;
                if (resultProd.count == 0) {
                    NSMutableArray *firsProd = [[NSMutableArray alloc] init];
                    [firsProd addObject:[self.allProductsArray objectAtIndex:i]];
                    [resultProd addObject:firsProd];
                    firstProdBool = YES;
                }
                
                else {
                    firstProdBool = NO;
                    for (int j = 0 ; j< resultProd.count; j++) {
                        
                        NSDateFormatter *formatterSorted = [[NSDateFormatter alloc] init];
                        [formatterSorted setDateFormat:@"dd.MM.yyyy"];
                        
                        NSMutableArray * firsObjectArray = [[NSMutableArray alloc] init];
                        firsObjectArray = [resultProd objectAtIndex:j] ;
                        NSDate *dateProd1 = [[firsObjectArray objectAtIndex:0] objectForKey:@"date"];
                        NSString * dateP = [formatterSorted stringFromDate:dateProd1];
                        NSString * calendarVal = [formatterSorted stringFromDate:[[self.allProductsArray objectAtIndex:i] objectForKey:@"date"]];
                        //   if ([self.datePr.text isEqualToString:dateProd1]){
                        if ([calendarVal isEqualToString:dateP]){
                            
                            NSMutableArray *array = [firsObjectArray mutableCopy];
                            if (([array isKindOfClass:[NSMutableArray class]])) {
                                [array addObject:[self.allProductsArray objectAtIndex:i]];
                                [resultProd  replaceObjectAtIndex:j withObject:array];
                            }
                            boolVal = YES;
                            
                        }
                    }
                 }
                
                if (( boolVal == NO) && (firstProdBool == NO)) {
                    NSMutableArray * productListe =[[NSMutableArray alloc] init];
                    [productListe addObject:[self.allProductsArray objectAtIndex:i]];
                    [resultProd addObject:productListe];
                    boolVal = NO;
                }
            }
            
            self.resultProduct = resultProd;
            
            [[LOCacheManager sharedManager] cacheDict:self.resultProduct withKey:@"items"];
            
        }
    }
}
-(void)pickerValueChanged:(UIDatePicker *)picker
{
    NSString *dateEX;
    dateEX = self.calenderPicker.date.description; // set text to date description
    NSString *dateExString = [dateEX substringToIndex:10];
    NSString *dayString = [dateExString substringWithRange: NSMakeRange (8, 2)];
    NSString *monthString = [dateExString substringWithRange: NSMakeRange (5, 2)];
    NSString *yearString = [dateEX substringToIndex:4];
    NSString * finalDate = [NSString stringWithFormat:@"%@-%@-%@",dayString,monthString,yearString];
    if (![finalDate isEqualToString:@""]) {
        self.datePr = finalDate;
        [self.productTable reloadData];
    }
}
#pragma mark - TabaleView DataSource Delegate

-(void)reloadCellWithAnimation:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    
    [self.productTable reloadSections:sections withRowAnimation:animation];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // result search array
    if (self.reloadTabel == YES)
    {
        return (self.resultSearchArray.count * 2);
    }
    // global array
    else {
      return (self.resultConcatProduct.count * 2) ;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger numOfCell;
    // info cell
    if (section %2 == 0)
    {
    numOfCell = 1;
    }
    else
    {// date cell
        if ([[self.boolValues objectAtIndex:(section - 1)] intValue] == 0)
            numOfCell = 1;
        else
            numOfCell = 0;
    }
    return numOfCell;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Search Table
    if (self.reloadTabel == YES)
    {// info cell
        if (indexPath.section % 2 == 0) {
            CFHistoriqueTableViewCell *productCell =
            [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier forIndexPath:indexPath];
            self.productTable.separatorColor = [UIColor clearColor];
            productCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.productTable.opaque = NO;
            self.productTable.backgroundColor = [UIColor clearColor];
            
            
            
            if (productCell == nil) {
                productCell = [[CFHistoriqueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
            }
            
            NSDictionary *productInfo;
            productInfo = [self.resultSearchArray objectAtIndex:(indexPath.section/2)];
            
            NSString * statusPicture = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"statusPicture"]];
            // picture product
            if ([statusPicture isEqualToString:@"local"]) {
                
                
                NSString * pathImage = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"picture"]];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
                UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
               // [productCell.imgProd setImage:myImage];
                
                UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: myImage.CGImage
                                                                     scale: 1.0
                                                               orientation: UIImageOrientationRight];
                [productCell.imgProd setImage:PortraitImage];
            }
            
            else if ([statusPicture isEqualToString:@"url"]) {
                
                NSString *urlImage  = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"picture"]];
                [productCell.imgProd setImageWithURL:[urlImage percentEscapedURL]];
            }

            // info product
            productCell.nameProd.text = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"name"]];
            [productCell.nameProd setFont:[UIFont fontWithName:@"Roboto-Medium" size:13]];
            productCell.descProd.text = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"marque"]];
            [productCell.descProd setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
            
            if ([[self.boolValues objectAtIndex:indexPath.section] intValue] == 0) {
                [productCell.donButton setImage:[UIImage imageNamed:@"arrow_down_2.png"] forState:UIControlStateNormal];
            }
            else if (([[self.boolValues objectAtIndex:indexPath.section] intValue] == 1) && (self.buttonValidFinal == YES)) {
           // else if ([[self.boolValues objectAtIndex:indexPath.section] intValue] == 1)  {
                // [productCell.donButton setImage:[UIImage imageNamed:@"Follow.png"] forState:UIControlStateNormal];
                self.buttonValidFinal = NO;
                [productCell.donButton setImage:[UIImage imageNamed:@"btn_valid_check.png"] forState:UIControlStateNormal];
                [self performSelector:@selector(backGroundButton:)
                           withObject:productCell.donButton
                           afterDelay:2];
            }
            
            else if (([[self.boolValues objectAtIndex:indexPath.section] intValue] == 1) && (self.buttonValidFinal == NO)) {
                [productCell.donButton setImage:[UIImage imageNamed:@"Follow.png"] forState:UIControlStateNormal];
            }
            [productCell.donButton setTag:indexPath.section];
            [productCell.donButton addTarget:self action:@selector(openSuiteCellAction:) forControlEvents:UIControlEventTouchUpInside];
            return productCell;
        }
        // date cell
        else{
            
            CFDateProductTableViewCell *productCell =
            [tableView dequeueReusableCellWithIdentifier:ProductSuiteCellIdentifier forIndexPath:indexPath];
            self.productTable.separatorColor = [UIColor clearColor];
            productCell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.productTable.opaque = NO;
            self.productTable.backgroundColor = [UIColor clearColor];
            
            NSDictionary *productInfo;
            productInfo = [self.resultSearchArray objectAtIndex:(indexPath.section/2)];
         // productCell.dateEx.text = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"date"]];
            
            
            NSDateFormatter *formatterSorted = [[NSDateFormatter alloc] init];
            [formatterSorted setDateFormat:@"dd/MM/yyyy"];
            NSString *dateRes =[formatterSorted stringFromDate:[productInfo objectForKey:@"date"]];
            productCell.dateEx.text = [NSString stringWithFormat:@"Périme le : %@",dateRes];
            [productCell.dateEx setFont:[UIFont fontWithName:@"Roboto-Regular" size:13]];
            [productCell.dateEx setTextColor:[UIColor colorWithRed:71/255.0 green:80/255.0 blue:85/255.0 alpha:1]];
            
            
            [productCell.okButton setTag:indexPath.section];
            [productCell.okButton addTarget:self action:@selector(closeSuiteCellAction:) forControlEvents:UIControlEventTouchUpInside];
            [productCell.dateEx setTag:indexPath.section];
            [productCell.calendarButton setTag:indexPath.section];
            [productCell.calendarButton addTarget:self action:@selector(dateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
           // if (self.buttonSelected == YES) {
                
                [productCell.okButton setBackgroundImage:[UIImage imageNamed:@"btn_ok_vert.png"] forState:UIControlStateNormal];
               // self.buttonSelected = NO;
           // }
            
           /* else {
                
                [productCell.okButton setBackgroundImage:[UIImage imageNamed:@"btn_ok.png"] forState:UIControlStateNormal];
            }*/

            
            if (self.indexButton  == indexPath.section) {
                productCell.dateEx.text = self.datePr;
            }
            
            if (productCell == nil) {
                productCell = [[CFDateProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductSuiteCellIdentifier];
            }
            return productCell;
        }
        
    }
     // global Table
    else {
    
    if (indexPath.section % 2 == 0) {
        CFHistoriqueTableViewCell *productCell =
        [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier forIndexPath:indexPath];
        self.productTable.separatorColor = [UIColor clearColor];
        productCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.productTable.opaque = NO;
        self.productTable.backgroundColor = [UIColor clearColor];
        
        if (productCell == nil) {
            productCell = [[CFHistoriqueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
        }

    NSDictionary *productInfo;
    productInfo = [self.resultConcatProduct objectAtIndex:(indexPath.section/2)];
    
        NSString * statusPicture = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"statusPicture"]];
        
        if ([statusPicture isEqualToString:@"local"]) {
            
            NSString * pathImage = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"picture"]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
            UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
           // [productCell.imgProd setImage:myImage];
            
            UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: myImage.CGImage
                                                                 scale: 1.0
                                                           orientation: UIImageOrientationRight];
            
            [productCell.imgProd setImage:PortraitImage];

        }
        
        else if ([statusPicture isEqualToString:@"url"]) {
            NSString *urlImage  = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"picture"]];
            [productCell.imgProd setImageWithURL:[urlImage percentEscapedURL]];
        }
        
        productCell.nameProd.text = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"name"]];
        [productCell.nameProd setFont:[UIFont fontWithName:@"Roboto-Medium" size:13]];
        productCell.descProd.text = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"marque"]];
        [productCell.descProd setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];

        if ([[self.boolValues objectAtIndex:indexPath.section] intValue] == 0) {
            [productCell.donButton setImage:[UIImage imageNamed:@"arrow_down_2.png"] forState:UIControlStateNormal];
        }
        else if (([[self.boolValues objectAtIndex:indexPath.section] intValue] == 1) && (self.buttonValidFinal == YES)) {
      //  else if ([[self.boolValues objectAtIndex:indexPath.section] intValue] == 1)  {
            self.buttonValidFinal = NO;
            [productCell.donButton setImage:[UIImage imageNamed:@"btn_valid_check.png"] forState:UIControlStateNormal];
            [self performSelector:@selector(backGroundButton:)
                       withObject:productCell.donButton
                       afterDelay:2];
        }
        
        else if (([[self.boolValues objectAtIndex:indexPath.section] intValue] == 1) && (self.buttonValidFinal == NO)) {
             [productCell.donButton setImage:[UIImage imageNamed:@"Follow.png"] forState:UIControlStateNormal];
            }
        [productCell.donButton setTag:indexPath.section];
        [productCell.donButton addTarget:self action:@selector(openSuiteCellAction:) forControlEvents:UIControlEventTouchUpInside];
        return productCell;
    }
   
    else{
    
    CFDateProductTableViewCell *productCell =
    [tableView dequeueReusableCellWithIdentifier:ProductSuiteCellIdentifier forIndexPath:indexPath];
    self.productTable.separatorColor = [UIColor clearColor];
    productCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.productTable.opaque = NO;
    self.productTable.backgroundColor = [UIColor clearColor];
        
        NSDictionary *productInfo;
        productInfo = [self.resultConcatProduct objectAtIndex:(indexPath.section/2)];

        NSDateFormatter *formatterSorted = [[NSDateFormatter alloc] init];
        [formatterSorted setDateFormat:@"dd/MM/yyyy"];
        NSString *dateRes =[formatterSorted stringFromDate:[productInfo objectForKey:@"date"]];
        productCell.dateEx.text = [NSString stringWithFormat:@"Périme le : %@",dateRes];
         [productCell.dateEx setFont:[UIFont fontWithName:@"Roboto-Regular" size:13]];
         [productCell.dateEx setTextColor:[UIColor colorWithRed:71/255.0 green:80/255.0 blue:85/255.0 alpha:1]];
        
     //   if (self.buttonSelected == YES) {
            
             [productCell.okButton setBackgroundImage:[UIImage imageNamed:@"btn_ok_vert.png"] forState:UIControlStateNormal];
          //  self.buttonSelected = NO;
      //  }
        
       /* else {
            
            [productCell.okButton setBackgroundImage:[UIImage imageNamed:@"btn_ok.png"] forState:UIControlStateNormal];
        }*/
        
    [productCell.okButton setTag:indexPath.section];
    [productCell.okButton addTarget:self action:@selector(closeSuiteCellAction:) forControlEvents:UIControlEventTouchUpInside];
    [productCell.dateEx setTag:indexPath.section];
    [productCell.calendarButton setTag:indexPath.section];
    [productCell.calendarButton addTarget:self action:@selector(dateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (productCell == nil) {
        productCell = [[CFDateProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductSuiteCellIdentifier];
    }
     return productCell;
    }
    
}
     }

-(void) backGroundButton: (UIButton*) button{
    
    [button setImage:[UIImage imageNamed:@"Follow.png"] forState:UIControlStateNormal];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // info cell
    if (indexPath.section %2 == 0) {
        return 70.0;
    }
    //date cell
    else return 60;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10.0)];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section %2 == 0) {
        return 10.0;
    }
    
    else return 0;
}

//Search Array
- (void)searchArray:(NSString*)searchText
{
    self.reloadTabel = YES;
     NSMutableArray *mutableArrayBegin =  [[NSMutableArray alloc] init];
    for (int i = 0; i < self.resultConcatProduct.count ; i++) {
        if ([[[self.resultConcatProduct objectAtIndex:i] objectForKey:@"name"] rangeOfString:searchText].location != NSNotFound ) {
            [mutableArrayBegin addObject:[self.resultConcatProduct objectAtIndex:i]];
        }
    }
    self.resultSearchArray = mutableArrayBegin;
    [self.productTable reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
