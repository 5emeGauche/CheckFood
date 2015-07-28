//
//  CFAddProductViewController.h
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
#import  "ZXingObjC.h"


@interface CFAddProductViewController : UIViewController <ZXCaptureDelegate>

@property (nonatomic,weak) IBOutlet UIView *masqueBlackTop;
@property (nonatomic,weak) IBOutlet UIView *masqueBlackLeft;
@property (nonatomic,weak) IBOutlet UIView *masqueBlackRight;
@property (nonatomic,weak) IBOutlet UIView *masqueBlackBottom;
@property (nonatomic,weak) IBOutlet UIView *scanRectView;
@property (nonatomic,weak) IBOutlet UIView *camOverlay;
@property (nonatomic,weak) IBOutlet UIView *header;




@end
