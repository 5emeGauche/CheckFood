//
//  CFAlertesViewController.h
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


@interface CFAlertesViewController : UIViewController <ALRadialMenuDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) IBOutlet UIButton *alertButton;
@property (nonatomic, strong) IBOutlet UIButton *frigoButton;
@property (nonatomic, strong) IBOutlet UIButton *placardButton;
@property (strong, nonatomic) IBOutlet UILabel *numOfLike;
@property (nonatomic, strong) IBOutlet UILabel *numberOfNotification;
@property (nonatomic,strong) IBOutlet UILabel *alertEmptyMessage;
@property (nonatomic,strong)IBOutlet UICollectionView *alertCollection;
@property (nonatomic,strong)NSString* alertTimeFrigo;
@property (nonatomic,strong)NSString* alertTimePlacard;
@property (nonatomic,strong)NSString* currentDate;
@property (nonatomic,strong)NSString* dateString;
@property (nonatomic, strong) NSMutableArray *resultProduct;
@property (nonatomic, strong) NSMutableArray *filtredProduct;
@property (nonatomic, strong) NSMutableArray *numOfDonate;
@property (nonatomic, strong) NSArray *sortedByDateProduct;
@property (nonatomic, strong) UIButton *addproductButton;
@property  CGFloat contentOffsetVal;
@property int countCollection;

- (IBAction)eatProductAction:(UIButton *)sender;
- (IBAction)dropProductAction:(UIButton *)sender;
- (IBAction)GiveProductAction:(UIButton *)sender;
- (void)stopScrollCollection;



@end
