//
//  CFPopUpValiderProductViewController.m
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

#import "CFPopUpValiderProductViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "CFMyProductsViewController.h"
#import "CFMyCupBoardViewController.h"

@interface CFPopUpValiderProductViewController ()

@end

@implementation CFPopUpValiderProductViewController

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
    self.titlePop.font = [UIFont fontWithName:@"Roboto-Medium" size:13];
   // self.titlePop.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
    self.message.font = [UIFont fontWithName:@"Roboto-Regular" size:13];
    self.message.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    self.valider.titleLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:13];
    self.message.text = self.messageValide;

}

- (IBAction)validerButtonAction:(id)sender
{
     [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    if ([self.emplacement isEqualToString:@"monFrigo"]) {
        CFMyProductsViewController *addVC = [[CFMyProductsViewController alloc]initWithNibName:@"CFMyProductsViewController" bundle:nil];
        [self.parentNavController pushViewController:addVC animated:NO];
    }
    else if([self.emplacement isEqualToString:@"monPlacard"])
    {
        CFMyCupBoardViewController *addVC = [[CFMyCupBoardViewController alloc]initWithNibName:@"CFMyCupBoardViewController" bundle:nil];
        [self.parentNavController pushViewController:addVC animated:NO];

    }
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
