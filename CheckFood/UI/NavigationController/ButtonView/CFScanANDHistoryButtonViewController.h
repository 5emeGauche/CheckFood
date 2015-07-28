//
//  CFScanANDHistoryButtonViewController.h
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

#import <UIKit/UIKit.h>
#import "ALRadialMenu.h"

@interface CFScanANDHistoryButtonViewController : UIViewController <ALRadialMenuDelegate>

@property (nonatomic, strong) IBOutlet UIButton *addProductButton;
@property (nonatomic, strong) IBOutlet UIButton *historiqButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) UINavigationController *parentNavController;
@property (nonatomic, strong) ALRadialMenu *radialMenu;

- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)addProductViewAction:(id)sender;
- (IBAction)historiqViewAction:(id)sender;
-(void)buttonPressed:(id)sender ;

@end
