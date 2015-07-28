//
//  CFNavigationController.m
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

#import "CFNavigationController.h"
#import "CFMenuCell.h"
#import "CFMyDonationsViewController.h"
#import "CFAssistantViewController.h"
#import "CFAboutViewController.h"
#import "CFPreferencesViewController.h"
#import "CFStatsViewController.h"
#import "CFMyProductsViewController.h"
#import "CFScanANDHistoryButtonViewController.h"
#import "ALRadialMenu.h"
#import "CFHistoriqueViewController.h"
#import "CFAddProductViewController.h"
#import "LOCacheManager.h"

#define kMenuWidth 278.0
#define kMenuAnimationDuration 0.35


static NSString * const MenuCellIdentifier = @"menuCell";


@interface CFNavigationController ()

@property (nonatomic, strong) NSMutableArray *menuElements;
@property (nonatomic, strong) ALRadialMenu *radialMenu;

@property BOOL statusButton;
@property (nonatomic,strong) NSMutableArray *numOfDonate;
@property (nonatomic,strong) NSMutableArray *numOfProduct;
@end

@implementation CFNavigationController
@synthesize menuHidden = _menuHidden;

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.contentView = self.view;
        _menuHidden = YES;
    }
    
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self hideMenuAnimated:YES];
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self hideMenuAnimated:YES];
    
    UIViewController *retObj = [super popViewControllerAnimated:animated];
    return retObj;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self hideMenuAnimated:YES];
    
    NSArray *retObj = [super popToViewController:viewController animated:animated];
    return retObj;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    [self hideMenuAnimated:YES];
    
    NSArray *retObj = [super popToRootViewControllerAnimated:animated];
    
    return retObj;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    //The menu elements
   // self.menuElements = [NSMutableArray arrayWithObjects:@"Mes produits", @"Mes dons", @"Mes stats", @"Préférences", @"Assistant", @"A propos", nil];
    
    self.menuElements = [NSMutableArray arrayWithObjects:@"Mes produits", @"Mes dons", @"Mes stats", @"Préférences", @"A propos", nil];
    
    // create and add menu as a subview of the main window
    CGFloat menuOriginY = 0.0;
    self.menu = [[UIView alloc] initWithFrame:CGRectMake(-kMenuWidth, menuOriginY, kMenuWidth, self.view.frame.size.height - menuOriginY)];
    self.menu.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_mon_placard.png"]];
    
    UIResponder <UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:self.menu];
    
    self.radialMenu = [[ALRadialMenu alloc] init];
	self.radialMenu.delegate = self;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_menu_2.png"]];
    //set the frame of the menu
    self.menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 20.0, kMenuWidth, self.menu.frame.size.height) style:UITableViewStylePlain];
    [tempImageView setFrame:self.menuTableView .frame];
    self.menuTableView.bounces = NO;
    [self.menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.menuTableView setBackgroundView:tempImageView];
    [self.menuTableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.menuTableView setScrollEnabled:YES];
    
    [self.menuTableView registerNib:[UINib nibWithNibName:@"CFMenuCell" bundle:nil] forCellReuseIdentifier:MenuCellIdentifier];

    [self.menu addSubview:self.menuTableView];
 
    UIView *leftShadow = [[UIView alloc] initWithFrame:CGRectMake(-1.0, self.menuTableView.frame.origin.y, 1.0, self.menuTableView.frame.size.height)];
    [leftShadow setBackgroundColor:[UIColor clearColor]];
    [self.menu addSubview:leftShadow];
    leftShadow.layer.shadowColor = [[UIColor blackColor] CGColor];
    leftShadow.layer.shadowOpacity = 0.50;
    leftShadow.layer.shadowOffset = CGSizeMake(4.0, 0.0);
    CGRect shadowPath = leftShadow.frame;
    shadowPath.origin.y = 0.0;
    leftShadow.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
    leftShadow.layer.masksToBounds = NO;
    
    
    // set menu table view data source & delegate
    [self.menuTableView setDataSource:self];
    [self.menuTableView setDelegate:self];
    
    /*
    // add gesture recognizer to hide menu
     UISwipeGestureRecognizer *toLeftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toLeftSwipeAction:)];
     toLeftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
     [self.menu addGestureRecognizer:toLeftSwipeRecognizer];
    
    // add gesture recognizer to hide menu
    UISwipeGestureRecognizer *toRightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toRightSwipeAction:)];
    toRightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:toRightSwipeRecognizer];
    */
    
    self.addproductButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addproductButton addTarget:self
                         action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.addproductButton setTitle:@"Show View" forState:UIControlStateNormal];
    [self.addproductButton setImage:[UIImage imageNamed:@"SCan-BAs.png"] forState:UIControlStateNormal];
   
    self.addproductButton.frame = CGRectMake(125 , 410, 70.0, 70.0);

    [self.menu.window addSubview:self.addproductButton];
    
    self.statusButton = YES;
    
    //set the number of donate and alert
    [self calculateNumberOfDonateAndProduct];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // hide menu (default state)
    [self hideMenuAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(NSInteger)supportedInterfaceOrientations:(UIWindow *)window{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)buttonPressed:(id)sender {
	
	if (sender == self.addproductButton) {
        if (self.statusButton == YES) {
            self.statusButton = NO;
            [self.addproductButton setImage:[UIImage imageNamed:@"Btn_Principal.png"] forState:UIControlStateNormal];
            [self.radialMenu buttonsWillAnimateFromButton:sender withFrame:self.addproductButton.frame inView:self.addproductButton.superview isMenu:YES];
        }
      else  if (self.statusButton == NO) {
            self.statusButton = YES;
            [self.addproductButton setImage:[UIImage imageNamed:@"SCan-BAs.png"] forState:UIControlStateNormal];
            [self.radialMenu buttonsWillAnimateFromButton:sender withFrame:self.addproductButton.frame inView:self.addproductButton.superview isMenu:YES];
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
                    NSArray *viewControllers =  [self viewControllers];
                    UIViewController *lastVC = [viewControllers lastObject];
                    if ([lastVC isKindOfClass:[CFHistoriqueViewController class]]) {
                        [self popToViewController:lastVC animated:NO];
                    }
                    else {
                        CFHistoriqueViewController *productsPlacardVC = [[CFHistoriqueViewController alloc]initWithNibName:@"CFHistoriqueViewController" bundle:nil];
                        [self pushViewController:productsPlacardVC animated:NO];
                    }
                    radialMenu.scanLabel.hidden = YES;
                    radialMenu.histLabel.hidden = YES;
                    self.statusButton = YES;
                    [self.addproductButton setImage:[UIImage imageNamed:@"SCan-BAs.png"] forState:UIControlStateNormal];
                    [self.radialMenu buttonsWillAnimateFromButton:radialMenu withFrame:self.addproductButton.frame inView:self.addproductButton.superview isMenu:YES];

                    }
                   
                    break;
                case 2:
                {
                    NSArray *viewControllers =  [self viewControllers];
                    UIViewController *lastVC = [viewControllers lastObject];
                    if ([lastVC isKindOfClass:[CFAddProductViewController class]]) {
                        [self popToViewController:lastVC animated:NO];
                    }
                    else {
                        CFAddProductViewController *addproductVC = [[CFAddProductViewController alloc] initWithNibName:@"CFAddProductViewController" bundle:nil];
                        [self pushViewController:addproductVC animated:NO];
                    }
                    
                    radialMenu.scanLabel.hidden = YES;
                    radialMenu.histLabel.hidden = YES;
                    self.statusButton = YES;
                    [self.addproductButton setImage:[UIImage imageNamed:@"SCan-BAs.png"] forState:UIControlStateNormal];
                    [self.radialMenu buttonsWillAnimateFromButton:radialMenu withFrame:self.addproductButton.frame inView:self.addproductButton.superview isMenu:YES];
                }
                    
                    break;
                default:
                    break;
            }
	}
}


#pragma mark - Public methods

-(void)calculateNumberOfDonateAndProduct {
    
    self.numOfDonate = [NSMutableArray array];
    self.numOfProduct = [NSMutableArray array];
    
    NSString *alertTimeFrigo= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertFrigo"];
    NSString *alertTimePlacard= [[LOCacheManager sharedManager] getFromCacheWithKey:@"alertPlacard"];
    NSMutableArray* resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    
    
    if (![alertTimeFrigo isKindOfClass:[NSString class]]) {
        alertTimeFrigo = @"2";
    }
    if (![alertTimePlacard isKindOfClass:[NSString class]]) {
        alertTimePlacard = @"2";
    }
    
    
    for (int i=0; i<resultProduct.count; i++) {
        
        NSMutableArray *products = [resultProduct objectAtIndex:i];
        
        for (int j=0; j<products.count;j++) {
            
            NSDictionary *product = [products objectAtIndex:j];
            
            NSString *productState= [product objectForKey:@"etat"];
            
            if ([productState  isEqual: @""]) {
                [self.numOfProduct addObject:product];
            }
            
            if ([productState isEqual:@"donner"]) {
                
                [self.numOfDonate addObject:product] ;
            }
        }
    }
    CFMenuCell *productCell = (CFMenuCell *)[self.menuTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
      CFMenuCell *donnationCell = (CFMenuCell *)[self.menuTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
 productCell.numberIndicatorMenuCell.text = [NSString stringWithFormat:@"%d",self.numOfProduct.count];
    donnationCell.numberIndicatorMenuCell.text = [NSString stringWithFormat:@"%d",self.numOfDonate.count];
    
}

- (void)toggleMenuAnimated:(BOOL)animated {
    if ([self isMenuHidden]) {
        [self showMenuAnimated:animated];
    } else {
        [self hideMenuAnimated:animated];
    }
}

- (void)showMenuAnimated:(BOOL)animated {
    CGRect menuFrame = self.menu.frame;
    menuFrame.origin.x = 0;
    
    CGRect contentViewFrame = self.contentView.frame;
    contentViewFrame.origin.x = kMenuWidth;
    
    if (animated) {
        [UIView beginAnimations:@"ShowMenu" context:nil];
        [UIView setAnimationDuration:kMenuAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        [self.menu setFrame:menuFrame];
        [self.contentView setFrame:contentViewFrame];
        [self.blackLayer setAlpha:1.0];
        
        [UIView commitAnimations];
    } else {
        [self.menu setFrame:menuFrame];
        [self.contentView setFrame:contentViewFrame];
        [self.blackLayer setAlpha:1.0];
    }
    [self calculateNumberOfDonateAndProduct];
    _menuHidden = NO;
}

- (void)hideMenuAnimated:(BOOL)animated {
    CGRect menuFrame = self.menu.frame;
    menuFrame.origin.x = - kMenuWidth;
    
    CGRect contentViewFrame = self.contentView.frame;
    contentViewFrame.origin.x = 0.0;
    
    if (animated) {
        [UIView beginAnimations:@"HideMenu" context:nil];
        [UIView setAnimationDuration:kMenuAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        [self.menu setFrame:menuFrame];
        [self.contentView setFrame:contentViewFrame];
        
        [self.blackLayer setAlpha:0.0];
        
        [UIView commitAnimations];
    } else {
        [self.menu setFrame:menuFrame];
        [self.contentView setFrame:contentViewFrame];
        
        [self.blackLayer setAlpha:0.0];
    }
    
    _menuHidden = YES;
}



#pragma mark - Actions
- (void)toLeftSwipeAction:(UIGestureRecognizer *)recognizer {

    if (![self isMenuHidden]) {
        [self hideMenuAnimated:YES];
    }
}

- (void)toRightSwipeAction:(UIGestureRecognizer *)recognizer {
    if ([self isMenuHidden]) {
        [self showMenuAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menuElements count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CFMenuCell *cell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if (cell== nil) {
            
            cell = (CFMenuCell *)[[[NSBundle mainBundle] loadNibNamed:@"CFMenuCell" owner:nil options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
    cell.titleMenuCell.text = [self.menuElements objectAtIndex:[indexPath row]];
    cell.titleMenuCell.textColor = [UIColor whiteColor];
    [cell.titleMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
    [cell.numberIndicatorMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
   
    switch ([indexPath row]) {
        case 0: {
            
            cell.imageNumberMenuCell.hidden = NO;
            cell.imageMenuCell.image = [UIImage imageNamed:@"Shop_off.png"];

        }
            break;
            
        case 1: {
            
            cell.imageNumberMenuCell.hidden = NO;
            cell.imageMenuCell.image = [UIImage imageNamed:@"like_off.png"];
            cell.titleMenuCell.text = [self.menuElements objectAtIndex:[indexPath row]];
        }
            
            break;
        case 2: {
            
            cell.imageMenuCell.image = [UIImage imageNamed:@"Graph_off.png"];
            cell.imageNumberMenuCell.hidden = YES;
            cell.titleMenuCell.text = [self.menuElements objectAtIndex:[indexPath row]];

        }
            
            break;
            
        case 3: {
            cell.imageMenuCell.image = [UIImage imageNamed:@"Cog2_off.png"];
            cell.imageNumberMenuCell.hidden = YES;
            cell.titleMenuCell.text = [self.menuElements objectAtIndex:[indexPath row]];

        }
            
            break;
        /*
        case 4: {
            
            cell.imageMenuCell.image = [UIImage imageNamed:@"Note_Book_off.png"];
            cell.imageNumberMenuCell.hidden = YES;
            cell.titleMenuCell.text = [self.menuElements objectAtIndex:[indexPath row]];

        }
            
            break;
        case 5: {
            
            cell.imageMenuCell.image = [UIImage imageNamed:@"Info_off.png"];
            cell.imageNumberMenuCell.hidden = YES;
            cell.titleMenuCell.text = [self.menuElements objectAtIndex:[indexPath row]];

        }
            break;
         */
            
        case 4: {
            
            cell.imageMenuCell.image = [UIImage imageNamed:@"Info_off.png"];
            cell.imageNumberMenuCell.hidden = YES;
            cell.titleMenuCell.text = [self.menuElements objectAtIndex:[indexPath row]];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CFMenuCell *cell = (CFMenuCell*) [tableView cellForRowAtIndexPath:indexPath];
    
    switch ([indexPath row]) {
        case 0: {
            
            cell.imageMenuCell.image = [UIImage imageNamed:@"Shop_on.png"];
            cell.titleMenuCell.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
            [cell.titleMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
            
            //Update the state of other items
            [self.menuTableView beginUpdates];
           // NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],[NSIndexPath indexPathForRow:5 inSection:0],nil];
           
            NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],nil];
            
            [self.menuTableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationNone];
            [self.menuTableView endUpdates];
            
            //push ProductController
            CFMyProductsViewController *productsVC = [[CFMyProductsViewController alloc]initWithNibName:@"CFMyProductsViewController" bundle:nil];
            [self pushViewController:productsVC animated:NO];
            // hide menu
            [self hideMenuAnimated:YES];
            
        }

            break;
            
        case 1: {
            
        cell.imageMenuCell.image = [UIImage imageNamed:@"like_on.png"];
        cell.titleMenuCell.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
            [cell.titleMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];

            //Update the state of other items
            [self.menuTableView beginUpdates];
           // NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],[NSIndexPath indexPathForRow:5 inSection:0],nil];
            
              NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],nil];
            
            [self.menuTableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationNone];
            [self.menuTableView endUpdates];
            CFMyDonationsViewController *donationVC = [[CFMyDonationsViewController alloc]initWithNibName:@"CFMyDonationsViewController" bundle:nil];
            [self pushViewController:donationVC animated:NO];
            // hide menu
            [self hideMenuAnimated:YES];
        }
            
            break;
            
        case 2: {
            cell.imageMenuCell.image = [UIImage imageNamed:@"Graph_on.png"];
            cell.titleMenuCell.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
            [cell.titleMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
            //Update the state of other items
            [self.menuTableView beginUpdates];
           // NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],[NSIndexPath indexPathForRow:5 inSection:0],nil];
            
            NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],nil];
            
            [self.menuTableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationNone];
            [self.menuTableView endUpdates];
            
            CFStatsViewController *statsVC = [[CFStatsViewController alloc]initWithNibName:@"CFStatsViewController" bundle:nil];
            [self pushViewController:statsVC animated:NO];
            // hide menu
            [self hideMenuAnimated:YES];
        }
            
            break;
            
        case 3: {
            cell.imageMenuCell.image = [UIImage imageNamed:@"Cog_on.png"];
            cell.titleMenuCell.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
            [cell.titleMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];

            //Update the state of other items
            [self.menuTableView beginUpdates];
           // NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],[NSIndexPath indexPathForRow:5 inSection:0],nil];
            
                NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],nil];
            
            [self.menuTableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationNone];
            [self.menuTableView endUpdates];
            CFPreferencesViewController *preferenceVC = [[CFPreferencesViewController alloc]initWithNibName:@"CFPreferencesViewController" bundle:nil];
            [self pushViewController:preferenceVC animated:NO];
            // hide menu
            [self hideMenuAnimated:YES];

        }
            
            break;
            
         /*
        case 4: {
            cell.imageMenuCell.image = [UIImage imageNamed:@"Note_Book_on.png"];
           cell.titleMenuCell.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
            [cell.titleMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];

            
            [self.menuTableView beginUpdates];
            NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:5 inSection:0],nil];
            [self.menuTableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationNone];
            [self.menuTableView endUpdates];
            
            CFAssistantViewController *assitanceVC = [[CFAssistantViewController alloc]initWithNibName:@"CFAssistantViewController" bundle:nil];
            [self pushViewController:assitanceVC animated:NO];

        }
            
            break;
        case 5: {
            cell.imageMenuCell.image = [UIImage imageNamed:@"Info_on.png"];
            cell.titleMenuCell.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
            [cell.titleMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];

            //Update the state of other items
            [self.menuTableView beginUpdates];
            NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],[NSIndexPath indexPathForRow:4 inSection:0],nil];
            [self.menuTableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationNone];
            [self.menuTableView endUpdates];            CFAboutViewController *aboutVC = [[CFAboutViewController alloc]initWithNibName:@"CFAboutViewController" bundle:nil];
            [self pushViewController:aboutVC animated:NO];
            // hide menu
            [self hideMenuAnimated:YES];
        }
            break;
         */
          
        case 4: {
            cell.imageMenuCell.image = [UIImage imageNamed:@"Info_on.png"];
            cell.titleMenuCell.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
            [cell.titleMenuCell setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
            
            //Update the state of other items
            [self.menuTableView beginUpdates];
            NSArray *reloadIndexPath = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],[NSIndexPath indexPathForRow:3 inSection:0],nil];
            
            [self.menuTableView reloadRowsAtIndexPaths:reloadIndexPath withRowAnimation:UITableViewRowAnimationNone];
            [self.menuTableView endUpdates];
            CFAboutViewController *aboutVC = [[CFAboutViewController alloc]initWithNibName:@"CFAboutViewController" bundle:nil];
            [self pushViewController:aboutVC animated:NO];
            // hide menu
            [self hideMenuAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}

@end
