//
//  CFAboutViewController.m
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

#import "CFAboutViewController.h"
#import "CFNavigationController.h"
#import "CFAppDelegate.h"
#import "LOCacheManager.h"
#import "iRate.h"
#import "CFMyDonationsViewController.h"

@interface CFAboutViewController ()

@end

@implementation CFAboutViewController

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
    [self.textlabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:12]];
     self.textlabel.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    [self.titleView setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    self.titleView.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    [self.textlabel2 setFont:[UIFont fontWithName:@"Roboto-Regular" size:12]];
    self.textlabel2.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    [self.textView3 setFont:[UIFont fontWithName:@"Roboto-Bold" size:12]];
    self.textView3.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    [self.textView4 setFont:[UIFont fontWithName:@"Roboto-Regular" size:14]];
    self.textView4.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];

    [self.titleView2 setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    self.titleView2.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    
    [self.textView5 setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    self.textView5.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    
    [self.textView6 setFont:[UIFont fontWithName:@"Roboto-Regular" size:12]];
    self.textView6.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    [self.textView6 setText:@"Checkfood utilise la base de donnée collaborative Open Food Facts. Open Food Facts répertorie les produits alimentaires du monde entier et met à disposition leurs données sous la license Open Database License. Pour plus d'informations rendez-vous sur :\nhttp:/fr.openfoodfacts.org."];
    
    [self.numOfLike setFont:[UIFont fontWithName:@"Roboto-Bold" size:9]];
    self.numOfLike.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    self.opinionButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:12];
    self.opinionButton.titleLabel.textColor = [UIColor colorWithRed:252/255.0f green:252/255.0f blue:252/255.0f alpha:1.0];
    self.allView.contentSize =CGSizeMake(self.allView.frame.size.width,1327);
   // List Product
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
    self.numOfLike.text = [NSString stringWithFormat:@"%d",numOfDonate.count];

}

#pragma mark - Action Button

-(IBAction)openMyDonnationButAction:(id)sender {
    
    CFNavigationController *mainNavVC = (CFNavigationController *)[(CFAppDelegate *)[[UIApplication sharedApplication] delegate] mainNavigationController];
    [mainNavVC tableView:mainNavVC.menuTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    CFMyDonationsViewController *myDonnationVC = [[CFMyDonationsViewController alloc]initWithNibName:@"CFMyDonationsViewController" bundle:nil];
    [self.navigationController pushViewController:myDonnationVC animated:YES];
}

-(IBAction)toggleMenu:(id)sender {
    CFAppDelegate *appDelegate = (CFAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate mainNavigationController] toggleMenuAnimated:YES];
}
// Push appstore
-(IBAction)avisButtonAction:(id)sender {
    
    [iRate sharedInstance].applicationBundleID = @"com.charcoaldesign.rainbowblocks-free";
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable preview mode
    [iRate sharedInstance].previewMode = YES;
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
