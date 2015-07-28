//
//  CFMyDonationsViewController.m
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

#import "CFMyDonationsViewController.h"
#import "CFNavigationController.h"
#import "CFAppDelegate.h"
#import "CFDepositLocationViewController.h"
#import "CFProductTableViewCell.h"
#import "CFCustomButton.h"
#import "LOCacheManager.h"
#import "AKProgressView.h"
#import "NSString+PercentEscapedURL.h"
#import "UIImageView+WebCache.h"


static NSString * const ProductCellIdentifier = @"ProductCell";

@interface CFMyDonationsViewController ()

-(IBAction)toggleMenu:(id)sender;

@end

@implementation CFMyDonationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.numOfLike setFont:[UIFont fontWithName:@"Roboto-Bold" size:9]];
    self.numOfLike.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_mon_placard.png"]];
    [self.productTable registerNib:[UINib nibWithNibName:@"CFProductTableViewCell" bundle:nil]  forCellReuseIdentifier:ProductCellIdentifier];
    self.productTable.bounces = NO;
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    self.currentDate = [dateFormatter stringFromDate:currDate];
    self.filtredProduct = [NSMutableArray array];
    self.numOfDonate = [NSMutableArray array];
    NSMutableArray * resultFiltre = [[NSMutableArray alloc] init];
    NSMutableArray * resultFiltre1 = [[NSMutableArray alloc] init];
    NSArray *beginWithB = [[NSArray alloc] init];

    //get the products from the cache
    self.resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    
    //Search for the donated products
    for (int i = 0; i < self.resultProduct.count; i ++) {
        NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] 'donner'"];
        beginWithB =
        [[self.resultProduct objectAtIndex:i] filteredArrayUsingPredicate:bPredicate];
        NSMutableArray *mutableArrayBegin = [NSMutableArray arrayWithArray:beginWithB];
        [resultFiltre addObject:mutableArrayBegin];
    }
    
    for (int i = 0; i < resultFiltre.count ; i++) {
        if ( [[resultFiltre objectAtIndex:i] count] != 0) {
            [resultFiltre1 addObject:[resultFiltre objectAtIndex:i]];
        }
    }

    // Test sorted Array
    NSMutableArray * datetestArray = [[NSMutableArray alloc] init];
    self.resultFinalSortedArray = [[NSMutableArray alloc] init];
    for (int i =0; i < resultFiltre1.count; i ++) {
        
        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        [result setObject:[[[resultFiltre1 objectAtIndex:i] objectAtIndex :0] objectForKey:@"date"] forKey:@"date"];
        [datetestArray addObject:result];
    }
    
    NSDateFormatter *formatterSorted = [[NSDateFormatter alloc] init];
    [formatterSorted setDateFormat:@"dd.MM.yyyy"];
    
    NSArray *arraySorted  = [datetestArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSDate *d1 = obj1[@"date"];
        NSDate *d2 = obj2[@"date"];
        return [d1 compare:d2];
    }];
    
    for (int i = 0 ; i < arraySorted.count; i++) {
        for (int j = 0; j < resultFiltre1.count; j++) {
            
            if ([[[arraySorted objectAtIndex:i] objectForKey:@"date" ] isEqualToDate:[[[resultFiltre1 objectAtIndex:j] objectAtIndex:0] objectForKey:@"date"]] ) {
                [self.resultFinalSortedArray addObject:[resultFiltre1 objectAtIndex:j]];
            }
        }
    }
    
    //Add the first section and last section for open the map
    [self.filtredProduct addObject:@"section0"];
    for (int i = 0; i < self.resultFinalSortedArray.count ; i++) {
        if ( [[self.resultFinalSortedArray objectAtIndex:i] count] != 0) {
            [self.filtredProduct addObject:[self.resultFinalSortedArray objectAtIndex:i]];
        }
    }
    [self.filtredProduct addObject:@"lastSection"];

    //Add number of donation
    for (int i=0; i<self.resultProduct.count; i++) {
        NSMutableArray *products = [self.resultProduct objectAtIndex:i];
        for (int j=0; j<products.count;j++) {
            NSDictionary *product = [products objectAtIndex:j];
            NSString *productState= [product objectForKey:@"etat"];
            if ([productState isEqual:@"donner"]) {
                [self.numOfDonate addObject:product] ;
            }
        }
    }
    
    self.numOfLike.text = [NSString stringWithFormat:@"%d",self.numOfDonate.count];
    
    //Test to show the last section of tableView
    if (self.filtredProduct.count < 5) {
        self.showLastSection = NO;
    }
    else
        self.showLastSection = YES;

}

#pragma mark - ActionButton


-(IBAction)openMapButAction:(id)sender {
    
    CFDepositLocationViewController *depotCenter = [[CFDepositLocationViewController alloc]initWithNibName:@"CFDepositLocationViewController" bundle:nil];
    
    [self.navigationController pushViewController:depotCenter animated:YES];
}

-(IBAction)toggleMenu:(id)sender {
    CFAppDelegate *appDelegate = (CFAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate mainNavigationController] toggleMenuAnimated:YES];
}

#pragma mark - TabaleView DataSource Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.filtredProduct.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0 ) {
        return 1;
    }
    
    if (section == self.filtredProduct.count -1 ) {
        
        if (self.showLastSection)
            return  1;
        else
            return  0;
    }
    
   return [[self.filtredProduct objectAtIndex:section] count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.productTable.opaque = NO;
    self.productTable.backgroundColor = [UIColor clearColor];
    
    NSDictionary *productInfo;


    CFProductTableViewCell *productCell;
    
    
    if (indexPath.section == 0 || indexPath.section == self.filtredProduct.count -1) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CFMyDonnationCell" owner:self options:nil];
        productCell = [nib objectAtIndex:0];
        [productCell.titleOpenMapBut setFont:[UIFont fontWithName:@"Roboto-Regular" size:13]];
        [productCell.openMap addTarget:self action:@selector(openMapButAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return productCell;
    }
    
    else {
        
        productCell =
        [tableView dequeueReusableCellWithIdentifier:ProductCellIdentifier forIndexPath:indexPath];
    
    if (productCell == nil) {
        productCell = [[CFProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ProductCellIdentifier];
    }
    productInfo = [[self.filtredProduct objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    productCell.cancelButton.hidden = YES;
    productCell.donButton.hidden = YES;
    productCell.sepProd.hidden = YES;

    NSString *urlImage = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"picture"]];
    
    [productCell.imgProd setImage:[UIImage imageNamed:urlImage]];
    productCell.nameProd.text = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"name"]];
    [productCell.nameProd setFont:[UIFont fontWithName:@"Roboto-Medium" size:13]];
    productCell.descProd.text = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"marque"]];
    [productCell.descProd setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
    productCell.descProd.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
        
        NSString * statusPicture = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"statusPicture"]];
        
        if ([statusPicture isEqualToString:@"local"]) {
            NSString * pathImage = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"picture"]];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *imageProduct = [NSString stringWithFormat:@"%@/%@", documentsDirectory, pathImage];
            
            
            UIImage * myImage = [UIImage imageWithContentsOfFile:imageProduct];
            
            UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: myImage.CGImage
                                                                 scale: 1.0
                                                           orientation: UIImageOrientationRight];
            
            [productCell.imgProd setImage:PortraitImage];

        }
        
        else if ([statusPicture isEqualToString:@"url"]) {
            
            NSString *urlImage  = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"picture"]];
            [productCell.imgProd setImageWithURL:[urlImage percentEscapedURL]];
            
        }
    }

    NSDate *endDate= [productInfo objectForKey:@"date"];
    NSDate *Today = [NSDate date];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:Today
                                                          toDate:endDate
                                                         options:0];
    NSDate*startDateC = [productInfo objectForKey:@"dateADD"];
    NSDate *endDateC = [productInfo objectForKey:@"date"];
    NSCalendar *gregorianCalendar2 = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components2 = [gregorianCalendar2 components:NSDayCalendarUnit
                                                          fromDate:startDateC
                                                            toDate:endDateC
                                                           options:0];
    
    [productCell.progressView setTrackImage:[[UIImage imageNamed:@"process.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];
    
  /*  int x = [components2 day] - [components day];
    float progress;
    if ([components day] == 0) {
        
        progress = 1;
    }
    else
    {
        progress = (float) x / [components2 day];
    }*/
    
    float progress = 0.0;
  //  float pourc = (0.1 * [components2 day]);
    if ([components day] <= 0) {
        progress = 1;
    }
    else
    /*   Date de péremption > 100 jours : la barre de progression reste fixée à 10% de progression.
     
     Date de péremption < 100 jourss : La barre de progression commence à progresser, au delà de 10%.
     
     
     D'abord de 0,5% par jours pendant 50 jours (on a alors barre de progression = 10% + (50x0,5) = 35%) puis 1% par jours pendant 45 jours (on a alors 35+45 = 80% de progression) puis 4% par jour pendant 5 jours (on arrive à 100% le dernier jour).*/
    {
        float durationFromTodayToPerim = [components day];
        
        if (durationFromTodayToPerim>=100) {
            //10%
            progress = 0.1;
        }else {
            if (durationFromTodayToPerim>=50){
                progress = 0.1;
                
                //10%+
                progress += (100-durationFromTodayToPerim)*0.005;
            }else if  (durationFromTodayToPerim>=5){
                progress = 0.1;
                
                progress += 50.*0.005 +(45 - durationFromTodayToPerim)*0.01;
                
            }else if (durationFromTodayToPerim<5)
            {
                float test = ((float)(5.-durationFromTodayToPerim));
                progress = 0.8 + (test* 0.04);
                NSLog(@"width %f",progress);
                
            }
            
        }
    }

    
    NSLog(@"width %f %d",progress,[components2 day]);
    if ([components day] < 3) {
        [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progress_rouge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];
    }
    
    if (([components day] >= 3) && ([components day] < 7)) {
        [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progres_orange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];}
    
    if  ([components day] >= 7) {
        [productCell.progressView setProgressImage:[[UIImage imageNamed:@"progres_vert.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]];}
    
    [productCell.progressView setProgress:progress];
    
    productCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return productCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30.0)];
    header.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_mon_placard.png"]];
    
    for (int i = 0; i< self.filtredProduct.count; i++) {
        if (section == i)
            
        {
            
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 200, 20)];
            
            NSDate *start = [NSDate date];
            NSDate *end;
            
            if ([[self.filtredProduct objectAtIndex:i] count ] > 0) {
                end = [[[self.filtredProduct objectAtIndex:i] objectAtIndex:0] objectForKey:@"date"];
                
                NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                                    fromDate:start
                                                                      toDate:end
                                                                     options:0];
                NSLog(@"%ld", (long)[components day]);
                
                if ((long)[components day] < 0) {
                    
                    textLabel.text =  @"Périme dans 0 jour";

                }
                else {
                    
                if ((long)[components day] < 2) {
                        textLabel.text =  [NSString stringWithFormat:@"Périme dans %ld jour",(long)[components day]];
                    }
                else if ((long)[components day] >= 2){
                        textLabel.text =  [NSString stringWithFormat:@"Périme dans %ld jours",(long)[components day]];
                    }
                    
                }
                textLabel.backgroundColor = [UIColor clearColor];
                [textLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
                textLabel.textColor = [UIColor blackColor];
                
                
                [header addSubview:textLabel];
                
                UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 10, 50, 20)];
                
                if ([[self.filtredProduct objectAtIndex:i] count ] > 0) {
                    
                    NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
                    [f2 setDateFormat:@"dd.MM.yy"];
                    NSString *txt = [f2 stringFromDate:[[[self.filtredProduct objectAtIndex:i] objectAtIndex:0] objectForKey:@"date"]];
                    dateLabel.text = txt;
                }
                
                
                dateLabel.backgroundColor = [UIColor clearColor];
                [dateLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:10]];
                dateLabel.textColor = [UIColor blackColor];
                [header addSubview:dateLabel];
                
                if ((long)[components day] <3) {
                    UIImageView *lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_rouge.png"]];
                    lock.frame = CGRectMake(10, 12, 15.0, 15.0);
                    [header addSubview:lock];
                }
                
                if (((long)[components day] >= 3) && ((long)[components day] <7)) {
                    UIImageView *lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_orange.png"]];
                    lock.frame = CGRectMake(10, 12, 15.0, 15.0);
                    [header addSubview:lock];
                }
                if ((long)[components day] >= 7) {
                    UIImageView *lock = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock_bleu.png"]];
                    lock.frame = CGRectMake(10, 12, 15.0, 15.0);
                    [header addSubview:lock];
                }
            }
        }
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == self.filtredProduct.count -1)
        return 0;
    
    else
    return 35 ;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
