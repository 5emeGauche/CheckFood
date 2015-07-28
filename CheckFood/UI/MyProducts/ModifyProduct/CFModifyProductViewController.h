//
//  CFModifyProductViewController.h
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
#import <MobileCoreServices/MobileCoreServices.h>
#import "JAPTextField.h"


@interface CFModifyProductViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UILabel *codeValue;
@property (nonatomic, strong) IBOutlet UILabel *datePr;
@property (nonatomic, strong) IBOutlet UIImagePickerController *imgPicker;
@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UIButton *buttonFullImage;
@property (nonatomic, strong) IBOutlet UIImageView *image;
@property (nonatomic, strong) IBOutlet JAPTextField *nameProd;
@property (nonatomic, strong) IBOutlet JAPTextField *marqProd;
@property (nonatomic, strong) IBOutlet UIButton *addProd;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *pickerDate;
@property (nonatomic, strong) IBOutlet UIButton *monFrigo;
@property (nonatomic, strong) IBOutlet UIButton *monPlacard;
@property (nonatomic, strong) UIPopoverController *popoverControllerCam;
@property (nonatomic, strong) IBOutlet UIDatePicker *calenderPicker;
@property (nonatomic, strong) IBOutlet UIImageView *testImage;
@property (nonatomic, strong) NSString *emplacementProd;
@property (nonatomic, strong) NSString *localFilePath;
@property (nonatomic,strong) NSDate *dateTakeByPicker;
@property (nonatomic,strong) NSString *urlImage;
@property (nonatomic, strong) NSString *fullPicturePath;
@property BOOL monFrigoBool;
@property BOOL pickerStatus;
@property BOOL monPlacardBool;
@property BOOL boolArray;
@property BOOL statusImage;
@property BOOL modifyProduct;
@property BOOL nextButton;
@property (nonatomic, strong) UIView* overlayCam ;
@property(nonatomic,strong)NSString *productEAN;
@property(nonatomic,strong)NSDictionary *productEANResult;
@property (weak, nonatomic) IBOutlet UIView *recorderView;
@property (weak, nonatomic) IBOutlet UIView *masqueView;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (nonatomic, strong) IBOutlet UIImageView *fullImage;
@property (nonatomic, strong) IBOutlet UIView *fullImageView;
@property (nonatomic, strong) IBOutlet UIView *buttonCam;
@property (nonatomic, strong) IBOutlet UIScrollView *allView;
@property (nonatomic, strong) IBOutlet UILabel *titleView;
@property (nonatomic, strong) NSMutableDictionary *productInfo;

- (IBAction)addProduct:(id)sender;
- (IBAction)cancelAddproduct:(id)sender;
//- (IBAction)showPickerDate:(id)sender;
- (IBAction)saveFrigo:(id)sender;
- (IBAction)savePlacard:(id)sender;

- (IBAction)useCamera: (id)sender;
- (IBAction)showFullPicture:(id)sender;


@end

