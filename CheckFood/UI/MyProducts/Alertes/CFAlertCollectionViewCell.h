//
//  CFAlertCollectionViewCell.h
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

@class AKProgressView;

static NSString *alertPalagardIdentifier = @"AlertCell";
@interface CFAlertCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)IBOutlet UILabel *nameOfProduct;
@property (nonatomic,strong)IBOutlet UILabel *subNameOfProduct;
@property (nonatomic,strong)IBOutlet UILabel *perimeTxt;
@property (nonatomic,strong)IBOutlet UILabel *perimeDate;
@property (nonatomic,strong)IBOutlet UIImageView *perimeImage;
@property (nonatomic,strong)IBOutlet AKProgressView *progressView;
@property (nonatomic,strong)IBOutlet UIButton *eatBut;
@property (nonatomic,strong)IBOutlet UIButton *addToFavoritesBut;
@property (nonatomic,strong)IBOutlet UIButton *dropProductBut;
@property (nonatomic,strong) IBOutlet UIImageView *productImage;
@property (nonatomic,strong) IBOutlet UIImageView *separator;
@property (nonatomic,strong) IBOutlet UIImageView *separator1;

@property (nonatomic,strong)  NSString *mode;

@end

