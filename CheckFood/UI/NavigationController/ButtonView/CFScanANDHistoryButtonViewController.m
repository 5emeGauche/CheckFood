//
//  CFScanANDHistoryButtonViewController.m
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

#import "CFScanANDHistoryButtonViewController.h"
#import "CFNavigationController.h"
#import "CFAppDelegate.h"
#import "CFHistoriqueViewController.h"
#import "ALRadialMenu.h"

@interface CFScanANDHistoryButtonViewController ()

@end

@implementation CFScanANDHistoryButtonViewController

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"rectangle_popup_2.png"]];
    [self.cancelButton addTarget:self
                              action:@selector(buttonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];

}
 
- (IBAction)cancelButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
   /* CFAppDelegate *appDelegate = (CFAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate mainNavigationController] toggleMenuAnimated:YES];*/

}

- (IBAction)addProductViewAction:(id)sender
{
    
}
- (IBAction)historiqViewAction:(id)sender
{
    [self.parentNavController dismissViewControllerAnimated:YES completion:nil];
    CFHistoriqueViewController *productsVC = [[CFHistoriqueViewController alloc]initWithNibName:@"CFHistoriqueViewController" bundle:nil];
    [self.parentNavController pushViewController:productsVC animated:NO];

}

-(void)buttonPressed:(id)sender {
	
	if (sender == self.cancelButton) {
        [self.cancelButton setImage:[UIImage imageNamed:@"Btn_Principal.png"] forState:UIControlStateNormal];
        
        [self.radialMenu buttonsWillAnimateFromButton:sender withFrame:self.cancelButton.frame inView:self.cancelButton.superview isMenu:NO];
        // [self.radialMenu buttonsWillAnimateFromButton:sender withFrame:self.addproductButton.frame inView:self.addproductButton.superview];
    }

    
    /*  modalViewController.modalPresentationStyle = UIModalPresentationFormSheet;
     modalViewController.parentNavController = self;
     
     [self presentViewController:modalViewController animated:YES completion:^{}];*/
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
		return 90;
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
			return [UIImage imageNamed:@"SCan-BAs"];
		} else if (index == 2) {
			return [UIImage imageNamed:@"Btn-Historique"];
		}
	}
	return nil;
}


- (void) radialMenu:(ALRadialMenu *)radialMenu didSelectItemAtIndex:(NSInteger)index {
	if (radialMenu == self.radialMenu) {
		[self.radialMenu itemsWillDisapearIntoButton:self.cancelButton];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
