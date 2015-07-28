//
//  CFAboutViewController.h
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

@interface CFAboutViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *opinionButton;
@property (nonatomic, strong) IBOutlet UIScrollView *allView;
@property (nonatomic, strong) IBOutlet UILabel *textlabel;
@property (nonatomic, strong) IBOutlet UILabel *textlabel2;
@property (nonatomic, strong) IBOutlet UILabel *titleView;
@property (nonatomic, strong) IBOutlet UILabel *titleView2;
@property (nonatomic, strong) IBOutlet UILabel *textView3;
@property (nonatomic, strong) IBOutlet UILabel *textView4;
@property (nonatomic, strong) IBOutlet UILabel *textView5;
@property (nonatomic, strong) IBOutlet UILabel *textView6;
@property (weak, nonatomic) IBOutlet UILabel *numOfLike;
@property (nonatomic, strong) NSMutableArray *resultProduct;
@property (nonatomic,strong)NSMutableArray *numOfDonate;
@property (nonatomic, strong) NSString *dateString;

-(IBAction)avisButtonAction:(id)sender;

@end
