//
//  CFMyCupBoardViewController.m
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

#import "CFMyCupBoardViewController.h"
#import "CFProductTableViewCell.h"
#import "CFNavigationController.h"
#import "CFAppDelegate.h"
#import "CFAddProductViewController.h"
#import "CFMyProductsViewController.h"
#import "LOCacheManager.h"
#import "CFAlertesViewController.h"
#import "CFCustomButton.h"
#import "CFVideCellProductTableViewCell.h"
#import "AKProgressView.h"
#import "CFCupBoardTableViewCell.h"
#import "ALRadialMenu.h"
#import "CFHistoriqueViewController.h"
#import "UIImageView+WebCache.h"
#import "NSString+PercentEscapedURL.h"
#import "CFMyDonationsViewController.h"
#import "CFModifyProductViewController.h"
#import "CFPopUpEatProductViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "CFPopUpJetProductViewController.h"
#import "CFPopUpDonProductViewController.h"
#import "CFEmptyCellProductTableViewCell.h"

#define IS_IPHONE_5 ( fabs( ( double )[[UIScreen mainScreen] bounds].size.height - ( double )568. ) < DBL_EPSILON )


static NSString * const ProductCellIdentifier = @"ProductCell";
static NSString * const ProductVideCellIdentifier = @"ProductVideCell";
static NSString * const ProductEmptyCellIdentifier = @"ProductEmptyCell";

@interface CFMyCupBoardViewController ()

@property (nonatomic, strong) ALRadialMenu *radialMenu;
@property BOOL statusButton;


@end

@implementation CFMyCupBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - life View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    self.statusButton = YES;

    
    [self.numberOfNotification setFont:[UIFont fontWithName:@"Roboto-Medium" size:9]];
    self.numberOfNotification.textColor = [UIColor whiteColor];
    
    [self.numOfLike setFont:[UIFont fontWithName:@"Roboto-Bold" size:9]];
    self.numOfLike.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    
    [self.messageLab setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    self.messageLab.textColor = [UIColor blackColor];
    
    [self.placardButton setBackgroundImage:[UIImage imageNamed:@"btn_on.png"] forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_mon_placard.png"]];
    [self.productTable registerNib:[UINib nibWithNibName:@"CFCupBoardTableViewCell" bundle:nil]  forCellReuseIdentifier:ProductCellIdentifier];
    [self.productTable registerNib:[UINib nibWithNibName:@"CFVideCellProductTableViewCell" bundle:nil]  forCellReuseIdentifier:ProductVideCellIdentifier];
    [self.productTable registerNib:[UINib nibWithNibName:@"CFEmptyCellProductTableViewCell" bundle:nil]  forCellReuseIdentifier:ProductEmptyCellIdentifier];

    
    // filtre product
    self.resultProduct =[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"];
    NSArray *beginWithB = [[NSArray alloc] init];
    self.resultProductCache = [[NSMutableArray alloc] init];
    NSMutableArray * resultFiltre = [[NSMutableArray alloc] init];
    NSMutableArray * resultFiltre1 = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.resultProduct.count; i ++) {
        NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] 'monPlacard'"];
        beginWithB =
        [[self.resultProduct objectAtIndex:i] filteredArrayUsingPredicate:bPredicate];
        NSMutableArray *mutableArrayBegin = [NSMutableArray arrayWithArray:beginWithB];
        [resultFiltre addObject:mutableArrayBegin];
    }
    
    for (int i = 0; i < resultFiltre.count ; i++) {
        if ( [[resultFiltre objectAtIndex:i] count] != 0) {
            [resultFiltre1 addObject:[resultFiltre objectAtIndex:i]];
        }
    }
    
    self.resultProductCache = self.resultProduct;
        self.resultProductFiltre = resultFiltre1;

    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    self.dateString = [dateFormatter stringFromDate:currDate];
    
    //Set the number of Alert
    
    NSLog(@"result");
    
    NSMutableArray *filtredProduct = [NSMutableArray array];
    NSMutableArray *numOfDonate = [NSMutableArray array];
    
    NSString *alertTimeFrigo= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
    NSString *alertTimePlacard= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];
    
    
    if (![alertTimeFrigo isKindOfClass:[NSString class]]) {
        alertTimeFrigo = @"2";
    }
    if (![alertTimePlacard isKindOfClass:[NSString class]]) {
        alertTimePlacard = @"2";
    }
    
    NSLog(@"result %d",self.resultProduct.count);
    
    for (int i=0; i<self.resultProduct.count; i++) {
        
        NSMutableArray *products = [self.resultProduct objectAtIndex:i];
        
        for (int j=0; j<products.count;j++) {
            
            NSDictionary *product = [products objectAtIndex:j];
            
            NSDate *endDate= [product objectForKey:@"date"];
            NSString *productState= [product objectForKey:@"etat"];
            NSString *productLieu= [product objectForKey:@"lieu"];
            
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"dd.MM.yyyy"];
            NSDate *Today = [NSDate date];
            NSDate *endDate1 = endDate;
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                fromDate:Today
                                                                  toDate:endDate1
                                                                 options:0];
            NSLog(@"%ld", (long)[components day]);
            
            if ([components day] <= [alertTimeFrigo intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monFrigo"]) {
                [filtredProduct addObject:product];
            }
            
            if ([components day] <= [alertTimePlacard intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monPlacard"]) {
                [filtredProduct addObject:product];
            }
            
            if ([productState isEqual:@"donner"]) {
                
                [numOfDonate addObject:product] ;
            }
        }
    }

    
    self.numberOfNotification.text = [NSString stringWithFormat:@"%d", filtredProduct.count];
    self.numOfLike.text = [NSString stringWithFormat:@"%d",numOfDonate.count];
    
    
    self.addproductButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addproductButton addTarget:self
                              action:@selector(buttonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
    [self.addproductButton setTitle:@"Show View" forState:UIControlStateNormal];
    [self.addproductButton setImage:[UIImage imageNamed:@"SCan-BAs.png"] forState:UIControlStateNormal];
    
    if (IS_IPHONE_5) {
        self.addproductButton.frame = CGRectMake(125 , 468, 70.0, 70.0);
    }
    else {
        self.addproductButton.frame = CGRectMake(125 , 390, 70.0, 70.0);
    }
    
    [self.view addSubview:self.addproductButton];
    
    int countArray = 0;
    for (int i = 0; i<self.resultProductFiltre.count ; i++) {
        
        for (int j = 0; j <[[self.resultProductFiltre objectAtIndex:i] count] ; j++) {
            
            NSDictionary *productInfo;
            productInfo = [[self.resultProductFiltre objectAtIndex:i] objectAtIndex:j];
            NSString * etatProd =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"etat"]];
            
            if ([etatProd isEqualToString:@""]) {
                
                countArray = countArray + 1;
                
            }
        }
    }
    
    if ((self.resultProductFiltre.count == 0) || (countArray == 0))  {
        self.productTable.hidden = YES;
        self.messageLab.hidden = NO;
    }
    
    else {
        self.productTable.hidden = NO;
        self.messageLab.hidden = YES;
    }
    
    // Test sorted Array
    NSMutableArray * datetestArray = [[NSMutableArray alloc] init];
    self.resultFinalSortedArray = [[NSMutableArray alloc] init];
    
    for (int i =0; i < self.resultProductFiltre.count; i ++) {
        
        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        [result setObject:[[[self.resultProductFiltre objectAtIndex:i] objectAtIndex :0] objectForKey:@"date"] forKey:@"date"];
        
        [datetestArray addObject:result];
    }
    
    NSDateFormatter *formatterSorted = [[NSDateFormatter alloc] init];
    [formatterSorted setDateFormat:@"dd.MM.yyyy"];
    
    NSArray *arraySorted  = [datetestArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSDate *d1 = obj1[@"date"];
        NSDate *d2 = obj2[@"date"];
        
        return [d1 compare:d2];
    }];
    
    for (int i = 0 ; i < arraySorted.count; i++) {
        for (int j = 0; j < self.resultProductFiltre.count; j++) {
            
            
            if ([[[arraySorted objectAtIndex:i] objectForKey:@"date" ] isEqualToDate:[[[self.resultProductFiltre objectAtIndex:j] objectAtIndex:0] objectForKey:@"date"]] ) {
                
                [self.resultFinalSortedArray addObject:[self.resultProductFiltre objectAtIndex:j]];
            }
        }
    }

    UISwipeGestureRecognizer *toRightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toRightSwipeAction:)];
    toRightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:toRightSwipeRecognizer];
    
     self.countTable = 0;
    
 NSLog(@"result");

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.countTable = 0;
    [UIView animateWithDuration:0 animations:^{
        [self.productTable  reloadData];
    } completion:^(BOOL finished) {
        //Do something after that...
        [self stopScrollTable];
    }];
    
}


- (void)stopScrollTable
{
    if (self.countTable < 3) {
        [self.productTable setScrollEnabled:NO];
    }
    
    else {
        [self.productTable setScrollEnabled:YES];
    }
    
}


#pragma mark - Public Methods

-(void)removeLocalNotificationWithProductId:(NSString *)productId {
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"uid"]];
        if ([uid isEqualToString:productId])
        {
            //Cancelling local notification
            [app cancelLocalNotification:oneEvent];
            break;
        }
    }
}

//Scroll tableView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  //  NSLog(@"Will begin dragging");
    [self endScrollingScrollView:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // NSLog(@"Did Scroll");
    
    [self endScrollingScrollView:scrollView];}

-(void)endScrollingScrollView:(UIScrollView *)scrollView {
    
    
    self.contentOffsetVal = self.productTable.contentOffset.y;
  //  NSLog(@"offset1111 %f",self.contentOffsetVal);
    
    if (self.contentOffsetVal == 0) {
          [self stopScrollTable];
        
    }
    else   if ((self.contentOffsetVal + self.productTable.frame.size.width) == self.productTable.contentSize.height )
    {
       
    }
    
    else  if (((self.contentOffsetVal + self.productTable.frame.size.height) < self.productTable.contentSize.height )&&(self.contentOffsetVal !=0))
    {
       
    }
    
}


#pragma mark - Action Button

- (void)toRightSwipeAction:(UIGestureRecognizer *)recognizer {
    
    CFMyProductsViewController *productsVC = [[CFMyProductsViewController alloc]initWithNibName:@"CFMyProductsViewController" bundle:nil];
    [self.navigationController pushViewController:productsVC animated:NO];
}

-(IBAction)openMyDonnationButAction:(id)sender {
    
    CFNavigationController *mainNavVC = (CFNavigationController *)[(CFAppDelegate *)[[UIApplication sharedApplication] delegate] mainNavigationController];
    [mainNavVC tableView:mainNavVC.menuTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    CFMyDonationsViewController *myDonnationVC = [[CFMyDonationsViewController alloc]initWithNibName:@"CFMyDonationsViewController" bundle:nil];
    [self.navigationController pushViewController:myDonnationVC animated:YES];
}

- (IBAction)pushFrifoViewAction:(id)sender
{
    CFMyProductsViewController *productsVC = [[CFMyProductsViewController alloc]initWithNibName:@"CFMyProductsViewController" bundle:nil];
    [self.navigationController pushViewController:productsVC animated:NO];

}
-(IBAction)pushAlerteViewAction:(id)sender {
    
    CFAlertesViewController *alertsVC = [[CFAlertesViewController alloc]initWithNibName:@"CFAlertesViewController" bundle:nil];
    [self.navigationController pushViewController:alertsVC animated:NO];

}

-(void)buttonPressed:(id)sender {
	
	if (sender == self.addproductButton) {
        if (self.statusButton == YES) {
            self.statusButton = NO;
            [self.addproductButton setImage:[UIImage imageNamed:@"Btn_Principal.png"] forState:UIControlStateNormal];
            [self.radialMenu buttonsWillAnimateFromButton:sender withFrame:self.addproductButton.frame inView:self.addproductButton.superview isMenu:NO];
        }
        else  if (self.statusButton == NO) {
            self.statusButton = YES;
            [self.addproductButton setImage:[UIImage imageNamed:@"SCan-BAs.png"] forState:UIControlStateNormal];
            [self.radialMenu buttonsWillAnimateFromButton:sender withFrame:self.addproductButton.frame inView:self.addproductButton.superview isMenu:NO];
        }
    }
    
}

-(IBAction)toggleMenu:(id)sender {
    CFAppDelegate *appDelegate = (CFAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate mainNavigationController] toggleMenuAnimated:YES];
}


#pragma mark - radial menu delegate methods
- (NSInteger) numberOfItemsInRadialMenu:(ALRadialMenu *)radialMenu {
	//FIXME: dipshit, change one of these variable names
	if (radialMenu == self.radialMenu) {
		return 2;
	}
	
	return 0;
}


- (NSInteger) arcSizeForRadialMenu:(ALRadialMenu *)radialMenu {
	if (radialMenu == self.radialMenu) {
        return 0;
	}
	return 0;
}


- (NSInteger) arcRadiusForRadialMenu:(ALRadialMenu *)radialMenu {
	if (radialMenu == self.radialMenu) {
        return 80;
	}
	
	return 0;
}


- (UIImage *) radialMenu:(ALRadialMenu *)radialMenu imageForIndex:(NSInteger) index {
	if (radialMenu == self.radialMenu) {
		if (index == 1) {
			return [UIImage imageNamed:@"Btn-Historique"];
		} else if (index == 2) {
			return [UIImage imageNamed:@"SCan-BAs"];
		}
	}
	return nil;
}

// radial items action
- (void) radialMenu:(ALRadialMenu *)radialMenu didSelectItemAtIndex:(NSInteger)index {
	if (radialMenu == self.radialMenu) {
		//[self.radialMenu itemsWillDisapearIntoButton:self.addproductButton];
        switch (index) {
            case 1:{
                
                NSLog(@"view add");
                NSArray *viewControllers =  [self.navigationController viewControllers];
                UIViewController *lastVC = [viewControllers lastObject];
                if ([lastVC isKindOfClass:[CFHistoriqueViewController class]]) {
                    [self.navigationController popToViewController:lastVC animated:NO];
                }
                else {
                    CFHistoriqueViewController *productsPlacardVC = [[CFHistoriqueViewController alloc]initWithNibName:@"CFHistoriqueViewController" bundle:nil];
                    [self.navigationController pushViewController:productsPlacardVC animated:NO];
                }
                
                radialMenu.scanLabel.hidden = YES;
                radialMenu.histLabel.hidden = YES;
                self.statusButton = YES;
                [self.addproductButton setImage:[UIImage imageNamed:@"SCan-BAs.png"] forState:UIControlStateNormal];
                [self.radialMenu buttonsWillAnimateFromButton:radialMenu withFrame:self.addproductButton.frame inView:self.addproductButton.superview isMenu:NO];
                
            }
                
                break;
            case 2:
            {
                
                NSArray *viewControllers =  [[self navigationController] viewControllers];
                UIViewController *lastVC = [viewControllers lastObject];
                if ([lastVC isKindOfClass:[CFAddProductViewController class]]) {
                    [self.navigationController pushViewController:lastVC animated:NO];
                }
                else {
                    CFAddProductViewController *addproductVC = [[CFAddProductViewController alloc] initWithNibName:@"CFAddProductViewController" bundle:nil];
                    [self.navigationController pushViewController:addproductVC animated:NO];
                }
                
                
                radialMenu.scanLabel.hidden = YES;
                radialMenu.histLabel.hidden = YES;
                self.statusButton = YES;
                [self.addproductButton setImage:[UIImage imageNamed:@"SCan-BAs.png"] forState:UIControlStateNormal];
                [self.radialMenu buttonsWillAnimateFromButton:radialMenu withFrame:self.addproductButton.frame inView:self.addproductButton.superview isMenu:NO];
            }
                
                break;
            default:
                break;
        }
        
	}
}


#pragma mark - TabaleView DataSource Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.resultFinalSortedArray.count + 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.resultFinalSortedArray.count) {
        return [[self.resultFinalSortedArray objectAtIndex:section] count];
    }
    
    else return 1;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == self.resultFinalSortedArray.count) {
        
        CFProductTableViewCell *productCell =
        [tableView dequeueReusableCellWithIdentifier:ProductEmptyCellIdentifier forIndexPath:indexPath];
        self.productTable.separatorColor = [UIColor clearColor];
        productCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.productTable.opaque = NO;
        self.productTable.backgroundColor = [UIColor clearColor];
        
        return productCell;
        
    }
    
    else {

    
    
    NSDictionary *productInfo;
    productInfo = [[self.resultFinalSortedArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString * etatProd =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"etat"]];
    // product without status
    if ([etatProd isEqualToString:@""]) {
        
        CFCupBoardTableViewCell *productCell =
        [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier forIndexPath:indexPath];
        self.productTable.separatorColor = [UIColor clearColor];
        productCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.productTable.opaque = NO;
        self.productTable.backgroundColor = [UIColor clearColor];
        
        
        if (productCell == nil) {
            productCell = [[CFCupBoardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
        }
        
        NSString * statusPicture = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"statusPicture"]];
        
        if ([statusPicture isEqualToString:@"local"]) {

        
        NSString * pathImage = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"picture"]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
        UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
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
        productCell.descProd.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
        [productCell.donButton addTarget:self action:@selector(eatProduct:) forControlEvents:UIControlEventTouchUpInside];
        [productCell.cancelButton addTarget:self action:@selector(jetProduct:) forControlEvents:UIControlEventTouchUpInside];
        [productCell.offreButton addTarget:self action:@selector(donProduct:) forControlEvents:UIControlEventTouchUpInside];
        [productCell.donButton setTag:indexPath.row*2];
        [productCell.donButton setSectionValue:indexPath.section];
        [productCell.offreButton setTag:indexPath.row*2];
        [productCell.offreButton setSectionValue:indexPath.section];
        [productCell.cancelButton setTag:indexPath.row*2 + 1];
        [productCell.cancelButton setSectionValue:indexPath.section];
        [productCell setSectionVal:indexPath.section];
        [productCell.modifyProduct setTag:indexPath.row*2 + 2];
        [productCell.modifyProduct setSectionValue:indexPath.section];
        [productCell.modifyProduct addTarget:self action:@selector(modifyProductAction:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDate *startDateC = [productInfo objectForKey:@"dateADD"];
        
       [productCell.progressView setTrackImage:[[UIImage imageNamed:@"process.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];
        
        NSDate *start = [NSDate date];
        NSDate *end = [[[self.resultFinalSortedArray objectAtIndex:indexPath.section] objectAtIndex:0] objectForKey:@"date"];
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"dd.MM.yyyy"];
        NSDate *startDate = start;
        NSDate *endDate = end;
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        NSLog(@"%ld", (long)[components day]);
        
     /*   int dayValues = [end timeIntervalSinceDate:start];
        float resultDay = lroundf((2.0f * dayValues) / (2.0f * 86400));*/
        
        NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
        [f2 setDateFormat:@"dd.MM.yyyy"];
        NSDate *startDate2 = startDateC;
        NSDate *endDateC = end;
        
        NSCalendar *gregorianCalendar2 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components2 = [gregorianCalendar2 components:NSDayCalendarUnit
                                                              fromDate:startDate2
                                                                toDate:endDateC
                                                               options:0];
        
       // progress bar value
        NSLog(@"%ld", (long)[components2 day]);
        NSLog(@"%ld", (long)[components2 day]);
     //   int x = [components2 day] - [components day];
      //  int x = resultDay2 - resultDay;
    /*    float progress;
        if ([components day] <= 0) {
            progress = 1;
        }
        else
        {
            progress = (float) x / [components2 day];
        }*/
        
        float progress = 0.0;
     //   float pourc = (0.1 * [components2 day]);
        if ([components day] <= 0) {
            progress = 1;
        }
        else
        /*   Date de péremption > 100 jours : la barre de progression reste fixée à 10% de progression.
         
         Date de péremption < 100 jourss : La barre de progression commence à progresser, au delà de 10%.
         
         
         D'abord de 0,5% par jours pendant 50 jours (on a alors barre de progression = 10% + (50x0,5) = 35%) puis 1% par jours pendant 45 jours (on a alors 35+45 = 80% de progression) puis 4% par jour pendant 5 jours (on arrive à 100% le dernier jour).*/
        {
            float durationFromTodayToPerim = [components day];
            
            if (durationFromTodayToPerim>=100) {
                //10%
                progress = 0.1;
            }else {
                if (durationFromTodayToPerim>=50){
                    progress = 0.1;
                    
                    //10%+
                    progress += (100-durationFromTodayToPerim)*0.005;
                }else if  (durationFromTodayToPerim>=5){
                    progress = 0.1;
                    
                    progress += 50.*0.005 +(45 - durationFromTodayToPerim)*0.01;
                    
                }else if (durationFromTodayToPerim<5)
                {
                    float test = ((float)(5.-durationFromTodayToPerim));
                    progress = 0.8 + (test* 0.04);
                    NSLog(@"width %f",progress);
                    
                }
                
            }
        }
        NSLog(@"width %f %ld",progress,(long)[components2 day]);
        
        if ((long)[components day] < 3) {
            [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progress_rouge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];
        }
        
        if (((long)[components day] >= 3) && ((long)[components day] < 7)) {
            [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progres_orange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];}
        
        if  ((long)[components day] >= 7) {
            [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progres_vert.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];}
        
        [productCell.progressView setProgress:progress];
        
        self.countTable = self.countTable + 1;
        return productCell;
        
    }
    
    // product with status
    else {
        
        CFVideCellProductTableViewCell *productCellVide =
        [tableView dequeueReusableCellWithIdentifier:ProductVideCellIdentifier forIndexPath:indexPath];
        self.productTable.separatorColor = [UIColor clearColor];
        productCellVide.selectionStyle = UITableViewCellSelectionStyleNone;
        self.productTable.opaque = NO;
        self.productTable.backgroundColor = [UIColor clearColor];
        
        if (productCellVide == nil) {
            productCellVide = [[CFVideCellProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductVideCellIdentifier];
        }
        return productCellVide;
    }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (indexPath.section < self.resultFinalSortedArray.count) {
    
    // product without status
    NSDictionary *productInfo;
    productInfo = [[self.resultFinalSortedArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString * etatProd =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"etat"]];
    if ([etatProd isEqualToString:@""]) {
        
        return 110;
    }
    // product with status
    else return 0;
     }
     else return  120;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30.0)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_mon_placard.png"]];
    
    for (int i = 0; i< self.resultFinalSortedArray.count; i++) {
        if (section == i)
            
        {
            // value days in header
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 200, 20)];
            
            NSDate *start = [NSDate date];
            NSDate *end;
            if ([[self.resultFinalSortedArray objectAtIndex:i] count ] > 0) {
                end = [[[self.resultFinalSortedArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"date"];
                
                NSDateFormatter *f = [[NSDateFormatter alloc] init];
                [f setDateFormat:@"dd.MM.yy"];
                NSDate *startDate = start;
                NSDate *endDate = end;
                
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                    fromDate:startDate
                                                                      toDate:endDate
                                                                     options:0];
                NSLog(@"%ld", (long)[components day]);
                
               /* int dayValues = [end timeIntervalSinceDate:start];
                float resultDay = ceilf((2.0f * dayValues) / (2.0f * 86400));
                int resultDayP = resultDay;*/
                int days = 0;
                if (((long)[components day] < 0)) {
                    days = 0;
                }
                else {
                    days = (long)[components day] ;
                }
                if ((long)[components day] < 2) {
                    textLabel.text =  [NSString stringWithFormat:@"Périme dans %i jour",days];
                }
                else if ((long)[components day] >= 2){
                    textLabel.text =  [NSString stringWithFormat:@"Périme dans %i jours",days];
                }

                textLabel.backgroundColor = [UIColor clearColor];
                [textLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
                textLabel.textColor = [UIColor blackColor];
                
                [header addSubview:textLabel];
                
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 10, 50, 20)];
                // date
                if ([[self.resultFinalSortedArray objectAtIndex:i] count ] > 0) {
                    NSString * resDate = [f stringFromDate:[[[self.resultFinalSortedArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"date"]];
                    dateLabel.text = resDate;
                }
                
                dateLabel.backgroundColor = [UIColor clearColor];
                [dateLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
                dateLabel.textColor = [UIColor blackColor];
                [header addSubview:dateLabel];
                
                if ((long)[components day] <3) {
                    UIImageView *lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_rouge.png"]];
                    lock.frame = CGRectMake(10, 12, 15.0, 15.0);
                    [header addSubview:lock];
                }
                
                if (((long)[components day] >= 3) && ((long)[components day] <7)) {
                    UIImageView *lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_orange.png"]];
                    lock.frame = CGRectMake(10, 12, 15.0, 15.0);
                    [header addSubview:lock];
                }
                if ((long)[components day] >= 7) {
                    UIImageView *lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_bleu.png"]];
                    lock.frame = CGRectMake(10, 12, 15.0, 15.0);
                    [header addSubview:lock];
                }
            }
        }
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < self.resultFinalSortedArray.count) {
    BOOL found = NO;
    for (int i = 0 ; i < [[self.resultFinalSortedArray objectAtIndex:section] count]; i++) {
        NSString * etatpr =[[[self.resultFinalSortedArray objectAtIndex:section] objectAtIndex:i] objectForKey:@"etat"];
        if ([etatpr isEqualToString:@""]) {
            found = YES;
            break;
        }
    }
    return found ? 35 : 0;
    }
    
     else return 0;

}

- (IBAction)eatProduct:(UIButton *)sender
{
    
    CFCustomButton * buttonAdd = (CFCustomButton *)sender;
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonAdd.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
    
    CFPopUpEatProductViewController *detailViewController = [[CFPopUpEatProductViewController alloc] initWithNibName:@"CFPopUpEatProductViewController" bundle:nil];
    detailViewController.parentNavController = self.navigationController;
    [detailViewController setEatButton:buttonAdd];
    [detailViewController setEmplacement:[productInfo objectForKey:@"lieu"]];
    [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationFade];
}

- (IBAction)eatProductAction:(UIButton *)sender
{
    CFCustomButton * buttonAdd = (CFCustomButton *)sender;
    NSLog(@"click but %d", sender.tag);
    NSLog(@"click but %d",(sender.tag-sender.tag%2)/2);
    NSLog(@"click but %d",buttonAdd.SectionValue);
    NSString * idProd;
    
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonAdd.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
    
    if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
        // add status
        [productInfo setObject:@"manger" forKey:@"etat"];
        [productInfo setObject:self.dateString forKey:@"dateConsommation"];
        [[self.resultFinalSortedArray objectAtIndex:buttonAdd.SectionValue] replaceObjectAtIndex:((sender.tag-sender.tag%2)/2) withObject:productInfo];
        // modify product in global array
        for (int j =0; j< [self.resultProduct count] ; j++) {
            
            for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                NSMutableDictionary *productInfo;
                productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonAdd.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
                
                idProd = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"id"]];
                
                if ([[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"] isEqualToString:idProd]) {
                    
                    NSLog(@"xxxx %@",[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"]);
                    NSMutableArray *arrayResult = [self.resultProduct mutableCopy];
                    NSMutableArray *array = [[self.resultProduct objectAtIndex:j] mutableCopy];
                    [array replaceObjectAtIndex:i withObject:productInfo];
                    if ([arrayResult isKindOfClass: [NSMutableArray class]]) {
                        [arrayResult replaceObjectAtIndex:j withObject:array];
                    }
                    self.resultProduct = arrayResult;
                    
                }
                
            }
        }
        [[LOCacheManager sharedManager] cacheDict:self.resultProduct withKey:@"items"];
    }
      self.countTable = 0;
    [self.productTable reloadData];
    
    int countArray = 0;
    for (int i = 0; i<self.resultFinalSortedArray.count ; i++) {
        
        for (int j = 0; j <[[self.resultFinalSortedArray objectAtIndex:i] count] ; j++) {
            
            NSDictionary *productInfo;
            productInfo = [[self.resultFinalSortedArray objectAtIndex:i] objectAtIndex:j];
            NSString * etatProd =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"etat"]];
            
            if ([etatProd isEqualToString:@""]) {
                
                countArray = countArray + 1;
                
            }
        }
    }
    
    
    if ((self.resultFinalSortedArray.count == 0) || (countArray ==0))  {
        self.productTable.hidden = YES;
        self.messageLab.hidden = NO;
    }
    else {
        self.productTable.hidden = NO;
        self.messageLab.hidden = YES;
    }
    
    self.resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    NSMutableArray *filtredProduct = [NSMutableArray array];
    NSString *alertTimeFrigo= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
    NSString *alertTimePlacard= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];
    // alert
    if (![alertTimeFrigo isKindOfClass:[NSString class]]) {
        alertTimeFrigo = @"2";
    }
    if (![alertTimePlacard isKindOfClass:[NSString class]]) {
        alertTimePlacard = @"2";
    }
    
    for (int i=0; i<self.resultProduct.count; i++) {
        
        NSMutableArray *products = [self.resultProduct objectAtIndex:i];
        
        for (int j=0; j<products.count;j++) {
            
            NSDictionary *productVal = [products objectAtIndex:j];
            
            NSDate *endDate= [productVal objectForKey:@"date"];
            NSString *productState= [productVal objectForKey:@"etat"];
            NSString *productLieu= [productVal objectForKey:@"lieu"];
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"dd.MM.yyyy"];
            NSDate *Today =[NSDate date];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                fromDate:Today
                                                                  toDate:endDate
                                                                 options:0];
            NSLog(@"%ld", (long)[components day]);
            
            if ([components day] <= [alertTimeFrigo intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monFrigo"]) {
                [filtredProduct addObject:productVal];
            }
            
            if ([components day] <= [alertTimePlacard intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monPlacard"]) {
                [filtredProduct addObject:productVal];
            }
            
            if ([productState isEqual:@"donner"]) {
                
                [self.numOfDonate addObject:productVal] ;
            }
        }
    }
    self.numberOfNotification.text = [NSString stringWithFormat:@"%d", filtredProduct.count];
    
    
    [self removeLocalNotificationWithProductId:idProd];
}
- (IBAction)jetProduct:(UIButton *)sender
{
    CFCustomButton * buttonAdd = (CFCustomButton *)sender;
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonAdd.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
    
    
    CFPopUpJetProductViewController *detailViewController = [[CFPopUpJetProductViewController alloc] initWithNibName:@"CFPopUpJetProductViewController" bundle:nil];
    detailViewController.parentNavController = self.navigationController;
    [detailViewController setEmplacement:[productInfo objectForKey:@"lieu"]];
    [detailViewController setJetButton:buttonAdd];
    [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationFade];
}

- (IBAction)jetProductAction:(UIButton *)sender
{
    CFCustomButton * buttonCancel = (CFCustomButton *)sender;
    NSLog(@"click but %d", sender.tag);
    NSLog(@"click but %d",(sender.tag-sender.tag%2)/2);
    NSLog(@"click but %d",buttonCancel.SectionValue);
    NSString * idProd;
    
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonCancel.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
    
    if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
        
        [productInfo setObject:@"jeter" forKey:@"etat"];
        [productInfo setObject:self.dateString forKey:@"dateConsommation"];
        [[self.resultFinalSortedArray objectAtIndex:buttonCancel.SectionValue] replaceObjectAtIndex:((sender.tag-sender.tag%2)/2) withObject:productInfo];
        
        for (int j =0; j< [self.resultProduct count] ; j++) {
            
            for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                NSMutableDictionary *productInfo;
                productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonCancel.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
                
                idProd = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"id"]];
                
                if ([[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"] isEqualToString:idProd]) {
                    
                    NSLog(@"xxxx %@",[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"]);
                    NSMutableArray *arrayResult = [self.resultProduct mutableCopy];
                    NSMutableArray *array = [[self.resultProduct objectAtIndex:j] mutableCopy];
                    [array replaceObjectAtIndex:i withObject:productInfo];
                    if ([arrayResult isKindOfClass: [NSMutableArray class]]) {
                        [arrayResult replaceObjectAtIndex:j withObject:array];
                    }
                    self.resultProduct = arrayResult;
                    
                }
                
            }
        }
        [[LOCacheManager sharedManager] cacheDict:self.resultProduct withKey:@"items"];
    }
    self.countTable = 0;
    [self.productTable reloadData];
    int countArray = 0;
    for (int i = 0; i<self.resultFinalSortedArray.count ; i++) {
        
        for (int j = 0; j <[[self.resultFinalSortedArray objectAtIndex:i] count] ; j++) {
            
            NSDictionary *productInfo;
            productInfo = [[self.resultFinalSortedArray objectAtIndex:i] objectAtIndex:j];
            NSString * etatProd =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"etat"]];
            
            if ([etatProd isEqualToString:@""]) {
                
                countArray = countArray + 1;
                
            }
        }
    }
    
    
    if ((self.resultFinalSortedArray.count == 0) || (countArray ==0))  {
        self.productTable.hidden = YES;
        self.messageLab.hidden = NO;
    }
    else {
        self.productTable.hidden = NO;
        self.messageLab.hidden = YES;
    }
    
    
    self.resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    NSMutableArray *filtredProduct = [NSMutableArray array];
    NSString *alertTimeFrigo= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
    NSString *alertTimePlacard= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];
    
    if (![alertTimeFrigo isKindOfClass:[NSString class]]) {
        alertTimeFrigo = @"2";
    }
    if (![alertTimePlacard isKindOfClass:[NSString class]]) {
        alertTimePlacard = @"2";
    }
    
    for (int i=0; i<self.resultProduct.count; i++) {
        
        NSMutableArray *products = [self.resultProduct objectAtIndex:i];
        
        for (int j=0; j<products.count;j++) {
            
            NSDictionary *productVal = [products objectAtIndex:j];
            
            NSDate *endDate= [productVal objectForKey:@"date"];
            NSString *productState= [productVal objectForKey:@"etat"];
            NSString *productLieu= [productVal objectForKey:@"lieu"];
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"dd.MM.yyyy"];
            NSDate *Today =[NSDate date];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                fromDate:Today
                                                                  toDate:endDate
                                                                 options:0];
            NSLog(@"%ld", (long)[components day]);
            
            if ([components day] <= [alertTimeFrigo intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monFrigo"]) {
                [filtredProduct addObject:productVal];
            }
            
            if ([components day] <= [alertTimePlacard intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monPlacard"]) {
                [filtredProduct addObject:productVal];
            }
            
            if ([productState isEqual:@"donner"]) {
                
                [self.numOfDonate addObject:productVal] ;
            }
        }
    }
    self.numberOfNotification.text = [NSString stringWithFormat:@"%d", filtredProduct.count];
    
    [self removeLocalNotificationWithProductId:idProd];
}

- (IBAction)donProduct:(UIButton *)sender
{
    
    
    CFCustomButton * buttonAdd = (CFCustomButton *)sender;
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonAdd.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
    
    
    CFPopUpDonProductViewController *detailViewController = [[CFPopUpDonProductViewController alloc] initWithNibName:@"CFPopUpDonProductViewController" bundle:nil];
    detailViewController.parentNavController = self.navigationController;
    [detailViewController setEmplacement:[productInfo objectForKey:@"lieu"]];
    [detailViewController setDonButton:buttonAdd];
    [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationFade];

}

- (IBAction)donProductAction:(UIButton *)sender
{

    CFCustomButton * buttonCancel = (CFCustomButton *)sender;
    NSLog(@"click but %d", sender.tag);
    NSLog(@"click but %d",(sender.tag-sender.tag%2)/2);
    NSLog(@"click but %d",buttonCancel.SectionValue);
    
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonCancel.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
    
    if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
        
        [productInfo setObject:@"donner" forKey:@"etat"];
        [productInfo setObject:self.dateString forKey:@"dateConsommation"];
        [[self.resultFinalSortedArray objectAtIndex:buttonCancel.SectionValue] replaceObjectAtIndex:((sender.tag-sender.tag%2)/2) withObject:productInfo];
        
        
        for (int j =0; j< [self.resultProduct count] ; j++) {
            
            for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                NSMutableDictionary *productInfo;
                productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonCancel.SectionValue] objectAtIndex:((sender.tag-sender.tag%2)/2)]];
                
                NSString * nameProd = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"id"]];
                
                if ([[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"] isEqualToString:nameProd]) {
                    
                    NSLog(@"xxxx %@",[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"]);
                    NSMutableArray *arrayResult = [self.resultProduct mutableCopy];
                    NSMutableArray *array = [[self.resultProduct objectAtIndex:j] mutableCopy];
                    [array replaceObjectAtIndex:i withObject:productInfo];
                    if ([arrayResult isKindOfClass: [NSMutableArray class]]) {
                        [arrayResult replaceObjectAtIndex:j withObject:array];
                    }
                    self.resultProduct = arrayResult;
                }
            }
        }
        [[LOCacheManager sharedManager] cacheDict:self.resultProduct withKey:@"items"];
    }
    
    self.countTable = 0;
    [self.productTable reloadData];
    int countArray = 0;
    for (int i = 0; i<self.resultFinalSortedArray.count ; i++) {
        
        for (int j = 0; j <[[self.resultFinalSortedArray objectAtIndex:i] count] ; j++) {
            
            NSDictionary *productInfo;
            productInfo = [[self.resultFinalSortedArray objectAtIndex:i] objectAtIndex:j];
            NSString * etatProd =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"etat"]];
            
            if ([etatProd isEqualToString:@""]) {
                
                countArray = countArray + 1;
                
            }
        }
    }
    
    
    if ((self.resultFinalSortedArray.count == 0) || (countArray ==0))  {
        self.productTable.hidden = YES;
        self.messageLab.hidden = NO;
    }
    else {
        self.productTable.hidden = NO;
        self.messageLab.hidden = YES;
    }
    
    int numOfDonate = [self.numOfLike.text intValue];
    numOfDonate++;
    self.numOfLike.text = [NSString stringWithFormat:@"%d",numOfDonate];
    
    self.resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    NSMutableArray *filtredProduct = [NSMutableArray array];
    NSString *alertTimeFrigo= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
    NSString *alertTimePlacard= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];
    
    if (![alertTimeFrigo isKindOfClass:[NSString class]]) {
        alertTimeFrigo = @"2";
    }
    if (![alertTimePlacard isKindOfClass:[NSString class]]) {
        alertTimePlacard = @"2";
    }
    
    for (int i=0; i<self.resultProduct.count; i++) {
        
        NSMutableArray *products = [self.resultProduct objectAtIndex:i];
        
        for (int j=0; j<products.count;j++) {
            
            NSDictionary *productVal = [products objectAtIndex:j];
            
            NSDate *endDate= [productVal objectForKey:@"date"];
            NSString *productState= [productVal objectForKey:@"etat"];
            NSString *productLieu= [productVal objectForKey:@"lieu"];
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"dd.MM.yyyy"];
            NSDate *Today =[NSDate date];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                fromDate:Today
                                                                  toDate:endDate
                                                                 options:0];
            NSLog(@"%ld", (long)[components day]);
            
            if ([components day] <= [alertTimeFrigo intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monFrigo"]) {
                [filtredProduct addObject:productVal];
            }
            
            if ([components day] <= [alertTimePlacard intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monPlacard"]) {
                [filtredProduct addObject:productVal];
            }
            
            if ([productState isEqual:@"donner"]) {
                
                [self.numOfDonate addObject:productVal] ;
            }
        }
    }
    self.numberOfNotification.text = [NSString stringWithFormat:@"%d", filtredProduct.count];
    
}
- (IBAction)modifyProductAction:(UIButton *)sender
{
    CFCustomButton * buttonModify = (CFCustomButton *)sender;
    NSLog(@"click but %d", sender.tag);
    NSLog(@"click but %d",(sender.tag-sender.tag%2)/2);
    NSLog(@"click but %d",buttonModify.SectionValue);
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[[self.resultFinalSortedArray objectAtIndex:buttonModify.SectionValue] objectAtIndex:(((sender.tag-sender.tag%2)/2)-1)]];
    
    
    CFModifyProductViewController *productsVC = [[CFModifyProductViewController alloc]initWithNibName:@"CFModifyProductViewController" bundle:nil];
    [productsVC setProductInfo:productInfo];
    [self.navigationController pushViewController:productsVC animated:NO];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
