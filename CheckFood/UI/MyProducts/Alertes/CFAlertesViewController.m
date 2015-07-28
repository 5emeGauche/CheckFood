//
//  CFAlertesViewController.m
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

#import "CFAlertesViewController.h"
#import "CFMyProductsViewController.h"
#import "CFMyCupBoardViewController.h"
#import "CFAppDelegate.h"
#import "CFNavigationController.h"
#import "CFAlertCollectionViewCell.h"
#import "LOCacheManager.h"
#import "AKProgressView.h"
#import "ALRadialMenu.h"
#import "CFHistoriqueViewController.h"
#import "CFAddProductViewController.h"
#import "CFMyDonationsViewController.h"
#import "NSString+PercentEscapedURL.h"
#import "UIImageView+WebCache.h"
#import "CFPopUpEatProductViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "CFPopUpJetProductViewController.h"
#import "CFPopUpDonProductViewController.h"
#import "CFAlertesEmptyCollectionViewCell.h"
#import "CFAlertCollectionViewCellForFrigo.h"

#define IS_IPHONE_5 ( fabs( ( double )[[UIScreen mainScreen] bounds].size.height - ( double )568. ) < DBL_EPSILON )


static NSString * const AlertCellIdentifier = @"AlertCell";
static NSString * const AlertEmptyCellIdentifier = @"AlertEmptyCell";
static NSString * const AlertCellIdentifierForFrigo = @"AlertCellFrigo";


@interface CFAlertesViewController ()

@property (nonatomic, strong) ALRadialMenu *radialMenu;
@property BOOL statusButton;


@end

@implementation CFAlertesViewController

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
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    self.statusButton = YES;
    
    [self.alertButton setBackgroundImage:[UIImage imageNamed:@"btn_on.png"] forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_mon_placard.png"]];
    
    [self.numberOfNotification setFont:[UIFont fontWithName:@"Roboto-Medium" size:9]];
    self.numberOfNotification.textColor = [UIColor whiteColor];
    self.numberOfNotification.text = @"14";
    
    [self.alertEmptyMessage setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    self.alertEmptyMessage.textColor = [UIColor blackColor];
    
    self.numOfLike.text = @"14";
    [self.numOfLike setFont:[UIFont fontWithName:@"Roboto-Bold" size:9]];
    self.numOfLike.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];

    self.filtredProduct = [NSMutableArray array];
    self.numOfDonate = [NSMutableArray array];
    
    [self.alertCollection registerNib:[UINib nibWithNibName:@"CFAlertCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:AlertCellIdentifier];
    [self.alertCollection registerNib:[UINib nibWithNibName:@"CFAlertesEmptyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:AlertEmptyCellIdentifier];
     [self.alertCollection registerNib:[UINib nibWithNibName:@"CFAlertCollectionViewCellForFrigo" bundle:nil] forCellWithReuseIdentifier:AlertCellIdentifierForFrigo];
   
    self.alertCollection.pagingEnabled = NO;


    //get the configuration of the alerts
    self.alertTimeFrigo= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
    self.alertTimePlacard= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];

    //Test for the default value of alerts
    if (![self.alertTimeFrigo isKindOfClass:[NSString class]]) {
        self.alertTimeFrigo = @"2";
    }
    if (![self.alertTimePlacard isKindOfClass:[NSString class]]) {
        self.alertTimePlacard = @"2";
    }
    
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    [dateFormatter1 setDateFormat:@"dd.MM.YY"];
    self.dateString = [dateFormatter1 stringFromDate:currDate];
    
    //Search for the liste of donated product
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    //[dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    self.currentDate = [dateFormatter stringFromDate:currDate];
    
    self.resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    
    NSLog(@"result %d",self.resultProduct.count);
    
    for (int i=0; i<self.resultProduct.count; i++) {
        
        NSMutableArray *products = [self.resultProduct objectAtIndex:i];
        
        for (int j=0; j<products.count;j++) {
            
            NSDictionary *product = [products objectAtIndex:j];
            
            NSDate *endDate= [product objectForKey:@"date"];
            NSString *productState= [product objectForKey:@"etat"];
            NSString *productLieu= [product objectForKey:@"lieu"];
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSDate *Today = [NSDate date];//[f dateFromString:self.currentDate];
            //NSDate *endDate1 = [f dateFromString:endDate];
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                fromDate:Today
                                                                  toDate:endDate
                                                                 options:0];
            NSLog(@"%ld", (long)[components day]);
            
            if ([components day] <= [self.alertTimeFrigo intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monFrigo"]) {
                [self.filtredProduct addObject:product];
            }
            
            if ([components day] <= [self.alertTimePlacard intValue] && [productState  isEqual: @""] && [productLieu isEqualToString:@"monPlacard"]) {
                [self.filtredProduct addObject:product];
            }
            
            if ([productState isEqual:@"donner"]) {
                 [self.numOfDonate addObject:product] ;
            }
        }
    }
    
    //set the number of alerts
    self.numberOfNotification.text = [NSString stringWithFormat:@"%d", self.filtredProduct.count];
    
    //Sort the list of products
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    
    NSArray *array  = [self.filtredProduct sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSDate *d1 = obj1[@"date"];
        NSDate *d2 = obj2[@"date"];
        
        return [d1 compare:d2];
    }];
    
    self.filtredProduct = [NSMutableArray arrayWithArray:array];
   // NSLog(@"result %@",self.filtredProduct);
    
    //set the number of donated products
    self.numOfLike.text = [NSString stringWithFormat:@"%d",self.numOfDonate.count];
    
    //Button for open the scan product view and the history view
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
    
    //Show message if alert are empty
    if (self.filtredProduct.count == 0) {
        self.alertEmptyMessage.hidden = NO;
    }
    
    UISwipeGestureRecognizer *toLeftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toLeftSwipeAction:)];
    toLeftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:toLeftSwipeRecognizer];
    
    self.countCollection = 0;

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.countCollection = 0;
    [UIView animateWithDuration:0 animations:^{
        [self.alertCollection reloadData];
    } completion:^(BOOL finished) {
        //Do something after that...
        [self stopScrollCollection];
    }];
    
}

- (void)stopScrollCollection
{
    if (self.countCollection < 2) {
        [self.alertCollection setScrollEnabled:NO];
    }
    
    else {
        [self.alertCollection setScrollEnabled:YES];
    }
    
}



#pragma mark - Private Methods

-(void)removeLocalNotificationWithProductId:(NSString *)productId {
    
    //Search the local notification by the product id and cancel it
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"uid"]];
        if ([uid isEqualToString:productId])
        {
            [app cancelLocalNotification:oneEvent];
            break;
        }
    }
}

#pragma ScrollView Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  //  NSLog(@"Will begin dragging");
    [self endScrollingScrollView:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  //  NSLog(@"Did Scroll");
    
    [self endScrollingScrollView:scrollView];
}

-(void)endScrollingScrollView:(UIScrollView *)scrollView {
    
    
    self.contentOffsetVal = self.alertCollection.contentOffset.y;
  //  NSLog(@"offset1111 %f",self.contentOffsetVal);
    
    if (self.contentOffsetVal == 0) {
          [self stopScrollCollection];
    }
    else   if ((self.contentOffsetVal + self.alertCollection.frame.size.width) == self.alertCollection.contentSize.height )
    {
        }
    
    else  if (((self.contentOffsetVal + self.alertCollection.frame.size.height) < self.alertCollection.contentSize.height )&&(self.contentOffsetVal !=0))
    {
    }
    
}

#pragma mark - Action Button

- (void)toLeftSwipeAction:(UIGestureRecognizer *)recognizer {
   
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

- (IBAction)pushplacardViewAction:(id)sender
{
    CFMyCupBoardViewController *productsVC = [[CFMyCupBoardViewController alloc]initWithNibName:@"CFMyCupBoardViewController" bundle:nil];
    [self.navigationController pushViewController:productsVC animated:NO];
    
}

-(IBAction)toggleMenu:(id)sender {
    CFAppDelegate *appDelegate = (CFAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate mainNavigationController] toggleMenuAnimated:YES];
}


- (IBAction)eatProduct:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    
    CFPopUpEatProductViewController *detailViewController = [[CFPopUpEatProductViewController alloc] initWithNibName:@"CFPopUpEatProductViewController" bundle:nil];
    detailViewController.parentNavController = self.navigationController;
    [detailViewController setEatButton:button];
    [detailViewController setEmplacement:@"alerte"];
    [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationFade];
    
}

- (IBAction)eatProductAction:(UIButton *)sender
{

    //get the clicked button
    UIButton *button = (UIButton *)sender;
    //get the row of selected collection view
    int row = (button.tag-button.tag%3)/3;
    NSString * idProd;
    
    NSLog(@"row %d",row);
    
    //Change the State of pproduct and save it in the cache
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.filtredProduct objectAtIndex:row]];
    
    if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
        
        [productInfo setObject:@"manger" forKey:@"etat"];
        [productInfo setObject:self.dateString forKey:@"dateConsommation"];
        
        [self.filtredProduct replaceObjectAtIndex:row withObject:productInfo];
        for (int j =0; j< [self.resultProduct count] ; j++) {
            
            for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                
                NSMutableDictionary *productInfo;
                productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.filtredProduct objectAtIndex:row]];
                
                idProd = [productInfo objectForKey:@"id"];
                
                if ([[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"] isEqualToString:idProd]) {
                    NSMutableArray *array = [[self.resultProduct objectAtIndex:j] mutableCopy];
                    [array replaceObjectAtIndex:i withObject:productInfo];
                    [self.resultProduct replaceObjectAtIndex:j withObject:array];
                }
            }
        }
        [[LOCacheManager sharedManager] cacheDict:self.resultProduct withKey:@"items"];
    }
    
    [self.filtredProduct removeObjectAtIndex:row];
    self.numberOfNotification.text = [NSString stringWithFormat:@"%d", self.filtredProduct.count];
     self.countCollection = 0;
    [self.alertCollection reloadData];
    
    if (self.filtredProduct.count == 0) {
        self.alertEmptyMessage.hidden = NO;
    }
    [self removeLocalNotificationWithProductId:idProd];
    
}
- (IBAction)dropProduct:(UIButton *)sender
{
    
   UIButton *button = (UIButton *)sender;
    
    CFPopUpJetProductViewController *detailViewController = [[CFPopUpJetProductViewController alloc] initWithNibName:@"CFPopUpJetProductViewController" bundle:nil];
    detailViewController.parentNavController = self.navigationController;
    [detailViewController setEmplacement:@"alerte"];
    [detailViewController setJetButton:button];
    [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationFade];
}

- (IBAction)dropProductAction:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    int row = (button.tag-button.tag%3)/3;
    NSString * idProd;
    
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.filtredProduct objectAtIndex:row]];
    
    if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
        
        [productInfo setObject:@"jeter" forKey:@"etat"];
        [productInfo setObject:self.dateString forKey:@"dateConsommation"];
        
        
        [self.filtredProduct replaceObjectAtIndex:row withObject:productInfo];
        
        for (int j =0; j< [self.resultProduct count] ; j++) {
            
            for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                
                NSMutableDictionary *productInfo;
                productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.filtredProduct objectAtIndex:row]];
                
                idProd = [productInfo objectForKey:@"id"];
                
                if ([[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"] isEqualToString:idProd]) {
                    
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
    
    [self.filtredProduct removeObjectAtIndex:row];
    self.numberOfNotification.text = [NSString stringWithFormat:@"%d", self.filtredProduct.count];
    self.countCollection = 0;
    [self.alertCollection reloadData];
    
    if (self.filtredProduct.count == 0) {
        self.alertEmptyMessage.hidden = NO;
    }
    [self removeLocalNotificationWithProductId:idProd];

    
}


- (IBAction)GiveProduct:(UIButton *)sender
{
     UIButton *button = (UIButton *)sender;
    
    CFPopUpDonProductViewController *detailViewController = [[CFPopUpDonProductViewController alloc] initWithNibName:@"CFPopUpDonProductViewController" bundle:nil];
    detailViewController.parentNavController = self.navigationController;
    [detailViewController setEmplacement:@"alerte"];
    [detailViewController setDonButton:button];
    [self presentPopupViewController:detailViewController animationType:MJPopupViewAnimationFade];
    
}

- (IBAction)GiveProductAction:(UIButton *)sender
{
    
    UIButton *button = (UIButton *)sender;
    int row = (button.tag-button.tag%3)/3;
    NSString * idProd;
    
    NSMutableDictionary *productInfo;
    productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.filtredProduct objectAtIndex:row]];
    
    if ([productInfo isKindOfClass: [NSMutableDictionary class]]) {
        [productInfo setObject:@"donner" forKey:@"etat"];
        [productInfo setObject:self.dateString forKey:@"dateConsommation"];
        
        [self.filtredProduct replaceObjectAtIndex:row withObject:productInfo];
        
        for (int j =0; j< [self.resultProduct count] ; j++) {
            
            for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                
                NSMutableDictionary *productInfo;
                productInfo = [NSMutableDictionary dictionaryWithDictionary:[self.filtredProduct objectAtIndex:row]];
                
                idProd = [productInfo objectForKey:@"id"];
                
                if ([[[[self.resultProduct objectAtIndex:j] objectAtIndex:i] objectForKey:@"id"] isEqualToString:idProd]) {
                    
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
    
    [self.filtredProduct removeObjectAtIndex:row];
    
    if (self.filtredProduct.count == 0) {
        self.alertEmptyMessage.hidden = NO;
    }
    self.numberOfNotification.text = [NSString stringWithFormat:@"%d", self.filtredProduct.count];
    int numOfDonate = [self.numOfLike.text intValue];
    numOfDonate++;
    self.numOfLike.text = [NSString stringWithFormat:@"%d",numOfDonate];
    self.countCollection = 0;
    [self.alertCollection reloadData];
    
    [self removeLocalNotificationWithProductId:idProd];
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
		//return 45;
        return 0;
	}
	return 0;
}


- (NSInteger) arcRadiusForRadialMenu:(ALRadialMenu *)radialMenu {
	if (radialMenu == self.radialMenu) {
		//return 160;
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


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return (self.filtredProduct.count + 1);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == self.filtredProduct.count) {
        
        CFAlertesEmptyCollectionViewCell *productCell =
        [collectionView dequeueReusableCellWithReuseIdentifier:AlertEmptyCellIdentifier
                                                  forIndexPath:indexPath];

        return productCell;
    }
    
    
    else {
        
        NSDictionary *product = [self.filtredProduct objectAtIndex:indexPath.row];
        
        if ([[product objectForKey:@"lieu"] isEqualToString:@"monPlacard"]) {
           
            CFAlertCollectionViewCell *productCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:AlertCellIdentifier
                                                      forIndexPath:indexPath];
            
            productCell.eatBut.tag = indexPath.row * 3;
            [productCell.eatBut addTarget:self action:@selector(eatProduct:) forControlEvents:UIControlEventTouchUpInside];
            productCell.addToFavoritesBut.tag = indexPath.row * 3+1;
            [productCell.addToFavoritesBut addTarget:self action:@selector(GiveProduct:) forControlEvents:UIControlEventTouchUpInside];
            productCell.dropProductBut.tag = indexPath.row * 3+2;
            [productCell.dropProductBut addTarget:self action:@selector(dropProduct:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [productCell.progressView setTrackImage:[[UIImage imageNamed:@"process.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];
            
            NSString * statusPicture = [NSString stringWithFormat:@"%@",[product objectForKey:@"statusPicture"]];
            if (self.filtredProduct.count == 1) {
                
                if ([statusPicture isEqualToString:@"local"]) {
                    
                    NSString * pathImage = [NSString stringWithFormat:@"%@",[product objectForKey:@"fullPicture"]];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
                    
                    UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
                    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: myImage.CGImage
                                                                         scale: 1.0
                                                                   orientation: UIImageOrientationRight];
                    [productCell.productImage setImage:PortraitImage];
                }
                
                else if ([statusPicture isEqualToString:@"url"]) {
                    NSString *urlImage  = [NSString stringWithFormat:@"%@",[product objectForKey:@"fullPicture"]];
                    [productCell.productImage  setImageWithURL:[urlImage percentEscapedURL]];
                }
                
            }
            
            else {
                
                if ([statusPicture isEqualToString:@"local"]) {
                    
                    NSString * pathImage = [NSString stringWithFormat:@"%@",[product objectForKey:@"fullPicture"]];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
                    
                    UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
                    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: myImage.CGImage
                                                                         scale: 1.0
                                                                   orientation: UIImageOrientationRight];
                    [productCell.productImage setImage:PortraitImage];
                }
                
                else if ([statusPicture isEqualToString:@"url"]) {
                    NSString *urlImage  = [NSString stringWithFormat:@"%@",[product objectForKey:@"fullPicture"]];
                    [productCell.productImage setImageWithURL:[urlImage percentEscapedURL]];
                }
            }
            
            NSDate *endDate= [product objectForKey:@"date"];
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSDate *Today = [f dateFromString:self.currentDate];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                fromDate:Today
                                                                  toDate:endDate
                                                                 options:0];
            
            NSDate *startDateC = [product objectForKey:@"dateADD"];
            NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
            [f2 setDateFormat:@"dd.MM.yyyy"];
            NSDate *startDate2 = startDateC;
            NSDate *endDateC = [product objectForKey:@"date"];
            NSCalendar *gregorianCalendar2 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components2 = [gregorianCalendar2 components:NSDayCalendarUnit
                                                                  fromDate:startDate2
                                                                    toDate:endDateC
                                                                   options:0];
            
            int dayValue;
            NSLog(@"%ld", (long)[components2 day]);
            
            NSString *perime = @"Périme dans ";
            if ([components day]<=0)
                dayValue = 0;
            else
                dayValue = [components day];
            
            perime = [perime stringByAppendingString:[NSString stringWithFormat:@"%d",dayValue]];
            // perime = [perime stringByAppendingString:[NSString stringWithFormat:@"%d",dayValue]];
            if ((long)[components day] < 2) {
                perime = [perime stringByAppendingString:@" jour"];
            }
            else if ((long)[components day] >= 2){
                perime = [perime stringByAppendingString:@" jours"];
            }
            
            productCell.nameOfProduct.text = [product objectForKey:@"name"];
            productCell.subNameOfProduct.text = [product objectForKey:@"marque"];
            productCell.perimeTxt.text = perime;
            productCell.perimeDate.text = [f2 stringFromDate:[product objectForKey:@"date"]];
            
            if (dayValue < 3) {
                [productCell.perimeImage setImage:[UIImage imageNamed:@"clock_rouge.png"]];
            }
            
            if ((dayValue >= 3) && ([components day] <7)) {
                [productCell.perimeImage setImage:[UIImage imageNamed:@"clock_orange.png"]];
            }
            
            if (dayValue >= 7) {
                [productCell.perimeImage setImage:[UIImage imageNamed:@"clock_bleu.png"]];
            }
            /*   int x = ([components2 day] - [components day]);
             float progress;
             if ([components day] == 0) {
             progress = 1;
             }
             else
             progress = (float) x / [components2 day];*/
            
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
            
            if (dayValue < 3) {
                [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progress_rouge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];
            }
            
            if ((dayValue >= 3) && ([components day] < 7)) {
                [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progres_orange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];}
            
            if  (dayValue >= 7) {
                [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progres_vert.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];}
            
            [productCell.progressView setProgress:progress];
            self.countCollection = self.countCollection + 1;
            
            return productCell;

        }
        else {
            
            CFAlertCollectionViewCellForFrigo *productCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:AlertCellIdentifierForFrigo
                                                      forIndexPath:indexPath];
            
            
            productCell.eatBut.tag = indexPath.row * 3;
            [productCell.eatBut addTarget:self action:@selector(eatProduct:) forControlEvents:UIControlEventTouchUpInside];
            productCell.dropProductBut.tag = indexPath.row * 3+2;
            [productCell.dropProductBut addTarget:self action:@selector(dropProduct:) forControlEvents:UIControlEventTouchUpInside];
            
            [productCell.progressView setTrackImage:[[UIImage imageNamed:@"process.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];
            
            NSString * statusPicture = [NSString stringWithFormat:@"%@",[product objectForKey:@"statusPicture"]];
            if (self.filtredProduct.count == 1) {
                
                if ([statusPicture isEqualToString:@"local"]) {
                    
                    NSString * pathImage = [NSString stringWithFormat:@"%@",[product objectForKey:@"fullPicture"]];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
                    
                    UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
                    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: myImage.CGImage
                                                                         scale: 1.0
                                                                   orientation: UIImageOrientationRight];
                    [productCell.productImage setImage:PortraitImage];
                }
                
                else if ([statusPicture isEqualToString:@"url"]) {
                    NSString *urlImage  = [NSString stringWithFormat:@"%@",[product objectForKey:@"fullPicture"]];
                    [productCell.productImage  setImageWithURL:[urlImage percentEscapedURL]];
                }
            }
            
            else {
                
                if ([statusPicture isEqualToString:@"local"]) {
                    
                    NSString * pathImage = [NSString stringWithFormat:@"%@",[product objectForKey:@"fullPicture"]];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
                    
                    UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
                    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: myImage.CGImage
                                                                         scale: 1.0
                                                                   orientation: UIImageOrientationRight];
                    [productCell.productImage setImage:PortraitImage];
                }
                
                else if ([statusPicture isEqualToString:@"url"]) {
                    NSString *urlImage  = [NSString stringWithFormat:@"%@",[product objectForKey:@"fullPicture"]];
                    [productCell.productImage setImageWithURL:[urlImage percentEscapedURL]];
                }
            }
            
            NSDate *endDate= [product objectForKey:@"date"];
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSDate *Today = [f dateFromString:self.currentDate];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                fromDate:Today
                                                                  toDate:endDate
                                                                 options:0];
            
            NSDate *startDateC = [product objectForKey:@"dateADD"];
            NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
            [f2 setDateFormat:@"dd.MM.yyyy"];
            NSDate *startDate2 = startDateC;
            NSDate *endDateC = [product objectForKey:@"date"];
            NSCalendar *gregorianCalendar2 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components2 = [gregorianCalendar2 components:NSDayCalendarUnit
                                                                  fromDate:startDate2
                                                                    toDate:endDateC
                                                                   options:0];
            
            int dayValue;
            NSLog(@"%ld", (long)[components2 day]);
            
            NSString *perime = @"Périme dans ";
            if ([components day]<=0)
                dayValue = 0;
            else
                dayValue = [components day];
            
            perime = [perime stringByAppendingString:[NSString stringWithFormat:@"%d",dayValue]];
            // perime = [perime stringByAppendingString:[NSString stringWithFormat:@"%d",dayValue]];
            if ((long)[components day] < 2) {
                perime = [perime stringByAppendingString:@" jour"];
            }
            else if ((long)[components day] >= 2){
                perime = [perime stringByAppendingString:@" jours"];
            }
            
            productCell.nameOfProduct.text = [product objectForKey:@"name"];
            productCell.subNameOfProduct.text = [product objectForKey:@"marque"];
            productCell.perimeTxt.text = perime;
            productCell.perimeDate.text = [f2 stringFromDate:[product objectForKey:@"date"]];
            
            if (dayValue < 3) {
                [productCell.perimeImage setImage:[UIImage imageNamed:@"clock_rouge.png"]];
            }
            
            if ((dayValue >= 3) && ([components day] <7)) {
                [productCell.perimeImage setImage:[UIImage imageNamed:@"clock_orange.png"]];
            }
            
            if (dayValue >= 7) {
                [productCell.perimeImage setImage:[UIImage imageNamed:@"clock_bleu.png"]];
            }
            /*   int x = ([components2 day] - [components day]);
             float progress;
             if ([components day] == 0) {
             progress = 1;
             }
             else
             progress = (float) x / [components2 day];*/
            
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
            
            if (dayValue < 3) {
                [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progress_rouge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];
            }
            
            if ((dayValue >= 3) && ([components day] < 7)) {
                [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progres_orange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];}
            
            if  (dayValue >= 7) {
                [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progres_vert.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];}
            
            [productCell.progressView setProgress:progress];
            self.countCollection = self.countCollection + 1;
            
            return productCell;

        
        }
    

    
       }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.filtredProduct.count) {
         return CGSizeMake(320,214);
    }
    else return CGSizeMake(320,120);
   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
