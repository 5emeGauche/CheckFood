//
//  CFAlertCollectionViewCellForFrigo.m
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

#import "CFAlertCollectionViewCellForFrigo.h"

@implementation CFAlertCollectionViewCellForFrigo

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self.perimeTxt setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
    self.perimeTxt.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    
    [self.perimeDate setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
    self.perimeDate.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    
    [self.nameOfProduct setFont:[UIFont fontWithName:@"Roboto-Medium" size:14]];
    self.nameOfProduct.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    
    [self.subNameOfProduct setFont:[UIFont fontWithName:@"Roboto-Regular" size:11]];
    self.subNameOfProduct.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
