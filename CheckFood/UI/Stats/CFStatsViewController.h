//
//  CFStatsViewController.h
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

@interface CFStatsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *monthButton;
@property (nonatomic, strong) IBOutlet UIButton *lastMonthButton;
@property (nonatomic, strong) IBOutlet UIButton *preLastMonthButton;

@property (nonatomic, strong) IBOutlet UILabel *titleStat;

@property (nonatomic, strong) IBOutlet UILabel *totalProductEat;
@property (weak, nonatomic) IBOutlet UILabel *totalFrigoEat;
@property (weak, nonatomic) IBOutlet UILabel *totalPlacardEat;

@property (nonatomic, strong) IBOutlet UILabel *totalProductDon;
@property (weak, nonatomic) IBOutlet UILabel *totalFrigoDon;
@property (weak, nonatomic) IBOutlet UILabel *totalPlacardDon;

@property (nonatomic, strong) IBOutlet UILabel *totalProductJet;
@property (weak, nonatomic) IBOutlet UILabel *totalFrigoJet;
@property (weak, nonatomic) IBOutlet UILabel *totalPlacardJet;

@property (weak, nonatomic) IBOutlet UIImageView *progressValueTotal;
@property (weak, nonatomic) IBOutlet UIImageView *progressValueEat;
@property (weak, nonatomic) IBOutlet UIImageView *progressValueDon;
@property (weak, nonatomic) IBOutlet UIImageView *progressValueJet;

@property (nonatomic, strong) NSMutableArray * frigoArray;
@property (nonatomic, strong) NSMutableArray * dateArray;
@property (nonatomic, strong) NSMutableArray * dateResultArray;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSMutableArray *indexOcc;
@property (nonatomic, strong) NSMutableArray *resultProduct;
@property (nonatomic, strong) NSMutableArray *resultProductFiltre;
@property (nonatomic, strong) NSMutableArray *resultProductCache;
@property (nonatomic, strong) NSMutableArray *boolValues;

@property (nonatomic, strong) NSMutableArray *mangerProductArray;
@property (nonatomic, strong) NSMutableArray *jetterProductArray;
@property (nonatomic, strong) NSMutableArray *donnerProductArray;

@property (nonatomic, strong) NSString *currentMonthVal;
@property (nonatomic, strong) NSString *nextMonthVal;
@property (nonatomic, strong) NSString *lastMonthVal;
@property (nonatomic, strong) NSDate *dateCreate;
@property (nonatomic, strong) NSMutableArray *buttonMonths;

@property (weak, nonatomic) IBOutlet UILabel *numOfLike;
@property (weak, nonatomic) IBOutlet UIScrollView *buttonView;
@property (weak, nonatomic) IBOutlet UIScrollView *allView;
@property (nonatomic, strong) NSMutableArray *datesResult;
@property (nonatomic, strong) NSMutableArray *dates;
@property (nonatomic, strong) IBOutlet UIButton * testBut;
@property int frigoManger;
@property int frigoJeter;
@property int frigoDonner;
@property int placardJeter;
@property int placardManger;
@property int placardDonner;

-(IBAction)monthStatAction:(UIButton *)sender;

@end
