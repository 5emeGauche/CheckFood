//
//  CFHistoriqueViewController.h
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

@interface CFHistoriqueViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UITableView *productTable;
@property (nonatomic, strong) IBOutlet UITextField *rechercheProd;
@property (nonatomic, strong) IBOutlet UIDatePicker *calenderPicker;
@property (nonatomic, strong) NSMutableArray *boolValues;
@property (nonatomic, strong) NSString * datePr ;
@property BOOL suiteCellOpened;
@property BOOL pickerStatus;
@property BOOL buttonSelected;
@property BOOL buttonValid;
@property BOOL buttonValidFinal;
@property BOOL addProdBool;
@property BOOL saveProd;
@property NSInteger buttonClick;
@property int indexButton;
@property int countSection;
@property (nonatomic, strong) IBOutlet UIButton *donButton;
@property (nonatomic, strong) NSMutableArray *resultProduct;
@property (nonatomic, strong) NSMutableArray * resultConcatProduct;
@property (nonatomic, strong) NSMutableArray * resultSearchArray;
@property (nonatomic, strong) NSMutableArray * allProductsArray;
//@property (nonatomic, strong) IBOutlet UIBarSe * searchProductBar;
@property (nonatomic, retain) NSMutableArray *pastUrls;
@property (nonatomic, retain) NSMutableArray *autocompleteUrls;
@property (nonatomic, strong) NSString *emplacementProd;


@property BOOL reloadTabel;
- (IBAction)backViewAction:(id)sender;
- (IBAction)openSuiteCellAction:(UIButton*)sender;
- (void) resetViewAndDismissAllPopups;
- (void) dismissPickerShowPopUp;

@end
