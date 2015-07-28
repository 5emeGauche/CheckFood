//
//  CFMyProductsViewController.h
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
#import "CFProduct.h"
#import "CFNavigationController.h"
#import "ALRadialMenu.h"


@interface CFMyProductsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,ALRadialMenuDelegate>

@property (nonatomic, strong) IBOutlet UIButton *alertButton;
@property (nonatomic, strong) IBOutlet UIButton *frigoButton;
@property (nonatomic, strong) IBOutlet UIButton *placardButton;
@property (nonatomic, strong) IBOutlet UITableView *productTable;
@property (nonatomic, strong) IBOutlet UILabel *numberOfNotification;
@property (weak, nonatomic) IBOutlet UILabel *numOfLike;
@property (nonatomic, strong) NSMutableArray * frigoArray;
@property (nonatomic, strong) NSMutableArray * dateArray;
@property (nonatomic, strong) NSMutableArray * dateResultArray;
@property (nonatomic, strong) NSMutableArray * finalProductArray;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSMutableArray *indexOcc;
@property (nonatomic, strong) NSMutableArray *resultProduct;
@property (nonatomic, strong) NSMutableArray *resultProductSorted;
@property (nonatomic, strong) NSMutableArray *allProducts;
@property (nonatomic, strong) NSMutableArray *allSortedProducts;
@property (nonatomic, copy) NSMutableArray *resultProductFiltre;
@property (nonatomic, copy) NSMutableArray *resultProductCache;
@property (nonatomic, strong) CFProduct *produitAjout;
@property (nonatomic, strong) NSMutableArray *boolValues;
@property (nonatomic,strong)NSMutableArray *numOfDonate;
@property (nonatomic,strong) CFNavigationController *viewNav;
@property (nonatomic, strong) UIButton *addproductButton;
@property  CGFloat contentOffsetVal;
@property (nonatomic, strong) NSMutableArray * resultFinalSortedArray;
@property (nonatomic, strong) IBOutlet UILabel *messageLab;
@property int countTable;

- (IBAction)pushPlacardViewAction:(id)sender;
- (IBAction)eatProduct:(UIButton *)sender;
- (IBAction)eatProductAction:(UIButton *)sender;
- (IBAction)jetProduct:(UIButton *)sender;
- (IBAction)jetProductAction:(UIButton *)sender;
- (void)stopScrollTable;

@end
