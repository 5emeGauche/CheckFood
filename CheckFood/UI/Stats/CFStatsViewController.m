//
//  CFStatsViewController.m
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

#import "CFStatsViewController.h"
#import "CFNavigationController.h"
#import "CFAppDelegate.h"
#import "LOCacheManager.h"
#import "CFMyDonationsViewController.h"

@interface CFStatsViewController ()


-(IBAction)toggleMenu:(id)sender;
@end

@implementation CFStatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - life View
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.allView.contentSize =CGSizeMake(self.allView.frame.size.width,448);
    self.buttonView.backgroundColor = [UIColor clearColor];
    self.buttonView.opaque = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_mon_placard.png"]];
    //Button months
    [self.monthButton setBackgroundImage:[UIImage imageNamed:@"btn_on.png"] forState:UIControlStateNormal];
    [self.preLastMonthButton setBackgroundImage:[UIImage imageNamed:@"btn_off.png"] forState:UIControlStateNormal];
    [self.lastMonthButton setBackgroundImage:[UIImage imageNamed:@"btn_off.png"] forState:UIControlStateNormal];
    //like values
    [self.numOfLike setFont:[UIFont fontWithName:@"Roboto-Bold" size:9]];
    self.numOfLike.textColor = [UIColor colorWithRed:18/255.0f green:187/255.0f blue:167/255.0f alpha:1.0];
    //Label Values
    self.titleStat.font = [UIFont fontWithName:@"Roboto-Medium" size:13];
    
    self.totalProductEat.font = [UIFont fontWithName:@"Roboto-Medium" size:13];
    self.totalProductEat.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    self.totalFrigoEat.font = [UIFont fontWithName:@"Roboto-Regular" size:10];
    self.totalFrigoEat.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
    self.totalPlacardEat.font = [UIFont fontWithName:@"Roboto-Regular" size:10];
    self.totalPlacardEat.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
    self.totalProductDon.font = [UIFont fontWithName:@"Roboto-Medium" size:13];
    self.totalProductDon.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    self.totalPlacardDon.font = [UIFont fontWithName:@"Roboto-Regular" size:10];
    self.totalFrigoDon.font = [UIFont fontWithName:@"Roboto-Regular" size:10];
    self.totalFrigoDon.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
    self.totalPlacardDon.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
    self.totalProductJet.font = [UIFont fontWithName:@"Roboto-Medium" size:13];
    self.totalProductJet.textColor = [UIColor colorWithRed:71/255.0f green:80/255.0f blue:85/255.0f alpha:1.0];
    self.totalPlacardJet.font = [UIFont fontWithName:@"Roboto-Regular" size:10];
    self.totalPlacardJet.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
    self.totalFrigoJet.font = [UIFont fontWithName:@"Roboto-Regular" size:10];
    self.totalFrigoJet.textColor = [UIColor colorWithRed:137/255.0f green:137/255.0f blue:137/255.0f alpha:1.0];
    //List product
    self.resultProduct =[NSMutableArray arrayWithArray:[[LOCacheManager sharedManager] getFromCacheWithKey:@"items"]];
    self.dateCreate =[[LOCacheManager sharedManager] getFromCacheWithKey:@"dateCreate"] ;
    self.resultProductCache = [[NSMutableArray alloc] init];
    self.dateArray = [[NSMutableArray alloc] init];
    self.mangerProductArray = [[NSMutableArray alloc] init];
    self.buttonMonths = [[NSMutableArray alloc] init];
    self.jetterProductArray = [[NSMutableArray alloc] init];
    self.donnerProductArray = [[NSMutableArray alloc] init];
    self.boolValues = [[NSMutableArray alloc] init];
    
    self.frigoDonner =0;
    self.frigoManger =0;
    self.frigoJeter =0;
    self.placardDonner =0;
    self.placardJeter =0;
    self.placardManger =0;
   
    // current date
    NSDate *date = [NSDate date]; //I'm using this just to show the this is how you convert a date
    NSDateFormatter *dfC = [[NSDateFormatter alloc] init];
    [dfC setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterLongStyle]; // day, Full month and year
    [df setTimeStyle:NSDateFormatterNoStyle];  // nothing
    [df setLocale:frLocale];
    
    NSString *dateString = [df stringFromDate:date];
    NSRange isRange = [dateString rangeOfString:@" " options:NSCaseInsensitiveSearch];
    NSLog(@"location ###%d",isRange.location);
    NSString *monthStringInter = [dateString substringWithRange: NSMakeRange (isRange.location +1, (dateString.length - (isRange.location +1)))];
    NSRange isRange2 = [monthStringInter rangeOfString:@" " options:NSCaseInsensitiveSearch];
    NSLog(@"location2 ###%d",isRange2.location);
    NSString *monthString = [monthStringInter substringToIndex:isRange2.location];
    
    self.currentMonthVal = self.monthButton.titleLabel.text;
   
    
    
    if (self.dateCreate != nil) {
        NSDate *startDate = self.dateCreate; // your start date
        NSDate *endDate = date; // your end date
        NSDateComponents *monthDifference = [[NSDateComponents alloc] init];
        
        self.dates = [[NSMutableArray alloc] init];
        NSUInteger monthOffset = 1;
        NSDate *nextDate = startDate;
        do {
            /*  [monthDifference setMonth:monthOffset++];
             NSDate *d = [[NSCalendar currentCalendar] dateByAddingComponents:monthDifference toDate:startDate options:0];
             nextDate = d;
             [self.dates addObject:nextDate];*/
            
            [self.dates addObject:nextDate];
         //   monthOffset = monthOffset+1;
            [monthDifference setMonth:monthOffset++];
            NSDate *d = [[NSCalendar currentCalendar] dateByAddingComponents:monthDifference toDate:startDate options:0];
            nextDate = d;
            
        } while([nextDate compare:endDate] == NSOrderedAscending);
        NSDate *testDate = [self.dates objectAtIndex:self.dates.count-1];
    //    NSComparisonResult result = [testDate compare:endDate];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/yyyy"];
        
        NSString *stringDate = [dateFormatter stringFromDate:testDate];
        NSLog(@"%@", stringDate);

        NSString *stringDate2 = [dateFormatter stringFromDate:endDate];
        NSLog(@"%@", stringDate);
        
        if([stringDate isEqualToString:stringDate2])
        {
            NSLog(@"Date1 is in the future");
        } 
        else {
        
        [self.dates addObject:endDate];
        }
        self.datesResult = [[NSMutableArray alloc] init];
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setLocale:frLocale];
        [f setDateFormat:@"MMMM yyyy"];
        for (NSDate *date in self.dates) {
            NSLog(@"%@", [f stringFromDate:date]);
            [self.datesResult addObject:[f stringFromDate:date]];
        }
        NSLog(@"months == %d",monthOffset);
        
        
        if (self.datesResult.count <= 12) {
            
            
            if (self.datesResult.count == 1) {
                
                UIButton * buttonMonth = [UIButton buttonWithType:UIButtonTypeCustom];
                buttonMonth.frame = CGRectMake(0 , 0, 320, 40.0);
                [buttonMonth setBackgroundImage:[UIImage imageNamed:@"btn_off.png"] forState:UIControlStateNormal];
                [self.buttonMonths addObject:buttonMonth];
                [self.buttonView addSubview:buttonMonth];
            }
            
            else if (self.datesResult.count == 2) {
                
                UIButton * buttonMonth = [UIButton buttonWithType:UIButtonTypeCustom];
                buttonMonth.frame = CGRectMake(0 , 0, 160, 40.0);
                [buttonMonth setBackgroundImage:[UIImage imageNamed:@"btn_off.png"] forState:UIControlStateNormal];
                [self.buttonMonths addObject:buttonMonth];
                [self.buttonView addSubview:buttonMonth];
                
                UIButton * buttonMonth2 = [UIButton buttonWithType:UIButtonTypeCustom];
                buttonMonth2.frame = CGRectMake(160 , 0, 160, 40.0);
                [buttonMonth2 setBackgroundImage:[UIImage imageNamed:@"btn_off.png"] forState:UIControlStateNormal];
                [self.buttonMonths addObject:buttonMonth2];
                [self.buttonView addSubview:buttonMonth2];
                
            }
            
            else if (self.datesResult.count > 2) {
                int widthVal = 0;
                for (int i = 0; i< self.datesResult.count ; i++) {
                    UIButton * buttonMonth = [UIButton buttonWithType:UIButtonTypeCustom];
                    buttonMonth.frame = CGRectMake(widthVal , 0, 107.0, 40.0);
                    [buttonMonth setBackgroundImage:[UIImage imageNamed:@"btn_off.png"] forState:UIControlStateNormal];
                    widthVal = widthVal + 107;
                    [self.buttonMonths addObject:buttonMonth];
                    [self.buttonView addSubview:buttonMonth];
                }
            }
        }
        
        else if (self.datesResult.count > 12)
        {
            int interVal = self.datesResult.count - 12;
            NSMutableArray * arrayInterm = [[NSMutableArray alloc] init];
            NSMutableArray * arrayIntermDates = [[NSMutableArray alloc] init];
            
            for (int i = self.datesResult.count; i > interVal; i--) {
                
                [arrayInterm addObject: [self.datesResult objectAtIndex:i]];
                [arrayIntermDates addObject: [self.dates objectAtIndex:i]];
            }
            
            self.dates = arrayIntermDates;
            self.datesResult = arrayInterm;
        }
        
        UIButton * finalBut = [self.buttonMonths objectAtIndex:(self.buttonMonths.count -1)];
        float widthView = finalBut.frame.origin.x + finalBut.frame.size.width;
        [self.buttonView setContentSize:CGSizeMake(widthView , self.buttonView.frame.size.height)];
        // [self.buttonView setShowsHorizontalScrollIndicator:NO];
        [self.buttonView setPagingEnabled:YES];
        
        for (int i = 0; i < self.datesResult.count ; i++) {
            
            [[self.buttonMonths objectAtIndex:i] setTitle:[NSString stringWithFormat:@"%@",[[self.datesResult objectAtIndex:i] uppercaseString] ] forState:UIControlStateNormal];
            UIButton * buttonItem = [self.buttonMonths objectAtIndex:i];
            buttonItem.titleLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:9];
            buttonItem.titleLabel.textColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0];
            [buttonItem addTarget:self action:@selector(monthStatAction:) forControlEvents:UIControlEventTouchUpInside];
            [buttonItem setTag:i];
        }
        [monthString uppercaseString];
        
        for (int j =0; j< [self.resultProduct count] ; j++) {
            
            for (int i =0; i< [[self.resultProduct objectAtIndex:j] count] ; i++) {
                
                [self.resultProductCache addObject:[[self.resultProduct objectAtIndex:j] objectAtIndex:i]];
                
            }
        }
        
        [[self.buttonMonths objectAtIndex:self.buttonMonths.count-1] setBackgroundImage:[UIImage imageNamed:@"btn_on.png"] forState:UIControlStateNormal];
        NSDate *dateFirstV = [self.dates objectAtIndex:self.dates.count-1];
        NSString *dateFirst = [NSString stringWithFormat:@"%@",dateFirstV];
        NSString *currentMonthFirst = [dateFirst substringWithRange: NSMakeRange (5, 2)];
        [self calculateStat:currentMonthFirst];
    }
    // no products
    else if (self.dateCreate == nil)
    {
        UIButton * buttonMonth = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonMonth.frame = CGRectMake(0 , 0, 320, 40.0);
        [buttonMonth setBackgroundImage:[UIImage imageNamed:@"btn_on.png"] forState:UIControlStateNormal];
        [self.buttonMonths addObject:buttonMonth];
        [self.buttonView addSubview:buttonMonth];
        NSString *dateString = [df stringFromDate:date];
        NSRange isRange = [dateString rangeOfString:@" " options:NSCaseInsensitiveSearch];
        NSLog(@"location ###%d",isRange.location);
        NSString *monthStringInter = [dateString substringWithRange: NSMakeRange (isRange.location +1, (dateString.length - (isRange.location +1)))];

        [[self.buttonMonths objectAtIndex:0] setTitle:[NSString stringWithFormat:@"%@", [monthStringInter uppercaseString]]  forState:UIControlStateNormal];
        UIButton * buttonItem = [self.buttonMonths objectAtIndex:0];
        buttonItem.titleLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:9];
        [buttonItem addTarget:self action:@selector(monthStatAction:) forControlEvents:UIControlEventTouchUpInside];
        [buttonItem setTag:0];
        
        [[self.buttonMonths objectAtIndex:0] setBackgroundImage:[UIImage imageNamed:@"btn_on.png"] forState:UIControlStateNormal];
        NSDate *dateFirstV = date;
        NSString *dateFirst = [NSString stringWithFormat:@"%@",dateFirstV];
        NSString *currentMonthFirst = [dateFirst substringWithRange: NSMakeRange (5, 2)];
        [self calculateStat:currentMonthFirst];

    }
    NSLog(@"result");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"view will Appear");
   
}

#pragma mark - Action Buttons

-(IBAction)openMyDonnationButAction:(id)sender {
    
    CFNavigationController *mainNavVC = (CFNavigationController *)[(CFAppDelegate *)[[UIApplication sharedApplication] delegate] mainNavigationController];
    [mainNavVC tableView:mainNavVC.menuTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    CFMyDonationsViewController *myDonnationVC = [[CFMyDonationsViewController alloc]initWithNibName:@"CFMyDonationsViewController" bundle:nil];
    [self.navigationController pushViewController:myDonnationVC animated:YES];
}

-(IBAction)toggleMenu:(id)sender {
    CFAppDelegate *appDelegate = (CFAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate mainNavigationController] toggleMenuAnimated:YES];
}

-(IBAction)monthStatAction:(UIButton *)sender
{
    // Select Month
    for (int i =0; i < self.datesResult.count; i++) {
        if (i == sender.tag) {
            
            [[self.buttonMonths objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"btn_on.png"] forState:UIControlStateNormal];
           

            NSDate *date = [self.dates objectAtIndex:i];
            NSString *dateStr = [NSString stringWithFormat:@"%@",date];
            NSString *currentMonth = [dateStr substringWithRange: NSMakeRange (5, 2)];
            
            self.dateArray = [[NSMutableArray alloc] init];
            self.mangerProductArray = [[NSMutableArray alloc] init];
            self.jetterProductArray = [[NSMutableArray alloc] init];
            self.donnerProductArray = [[NSMutableArray alloc] init];
            
            self.totalPlacardDon.hidden = NO;
            self.totalPlacardJet.hidden = NO;
            self.totalPlacardEat.hidden = NO;
            self.totalFrigoJet.hidden = NO;
            self.totalFrigoEat.hidden = NO;
            
            self.progressValueEat.frame = CGRectMake(40, 128, 40,10);
            self.progressValueDon.frame = CGRectMake(40, 128, 40,10);
            self.progressValueJet.frame = CGRectMake(40, 128, 40,10);
            
            
            [self calculateStat:currentMonth];

            
        }
        
        else {
            [[self.buttonMonths objectAtIndex:i] setBackgroundImage:[UIImage imageNamed:@"btn_off.png"] forState:UIControlStateNormal];
        }
    }
    
}

//calculate Statistic month
-(void)calculateStat :(NSString *)month
{
    
    self.frigoDonner =0;
    self.frigoManger =0;
    self.frigoJeter =0;
    self.placardDonner =0;
    self.placardJeter =0;
    self.placardManger =0;

    // Month selected
    
    
        for (int i =0; i< self.resultProductCache.count ; i++) {
            NSDictionary *productInfo;
            productInfo = [self.resultProductCache objectAtIndex:i] ;
            NSString * dateProd =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"dateConsommation"]];
            if (dateProd.length > 0) {
                NSString *dayString = [dateProd substringWithRange: NSMakeRange (3, 2)];
                
                if ([dayString isEqualToString:month])
                {
                    [self.dateArray addObject:productInfo];
                }
                
            }
        }
    
     if (self.datesResult.count > 12)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd.MM.yyyy"];
        
        NSArray *array  = [self.dateArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            NSDate *d1 = [formatter dateFromString:obj1[@"date"]];
            NSDate *d2 = [formatter dateFromString:obj2[@"date"]];
            
            return [d1 compare:d2];
        }];
        
        NSString * bigDate = [[array objectAtIndex:(array.count - 1)] objectForKey:@"date"];
        NSMutableArray * triDate = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.dateArray.count ; i++) {
            
            if ([[[self.dateArray objectAtIndex:i] objectForKey:@"date"] isEqualToString:bigDate]) {
                
                
                [triDate addObject:[self.dateArray objectAtIndex:i]];
            }
        }
        
        self.dateArray = triDate;
    }
/*    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];

    NSArray *array  = [self.dateArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSDate *d1 = [formatter dateFromString:obj1[@"date"]];
        NSDate *d2 = [formatter dateFromString:obj2[@"date"]];
        
        return [d1 compare:d2];
    }];
    
    self.dateArray = [NSMutableArray arrayWithArray:array];
    NSLog(@"result %@",self.dateArray);

    if (self.dateArray.count > 12) {
        
        int interVal = self.datesResult.count - 12;
        NSMutableArray * arrayInterm = [[NSMutableArray alloc] init];
        NSMutableArray * arrayIntermDates = [[NSMutableArray alloc] init];
        
        for (int i = self.datesResult.count; i > interVal; i--) {
            
            [arrayInterm addObject: [self.datesResult objectAtIndex:i]];
            [arrayIntermDates addObject: [self.dates objectAtIndex:i]];
        }
        
        self.dates = arrayIntermDates;

        
    }*/
    // Filter product Status
    for (int i =0; i< self.dateArray.count ; i++) {
        NSDictionary *productInfo;
        productInfo = [self.dateArray objectAtIndex:i] ;
        NSString * etatPr =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"etat"]];
        if ([etatPr isEqualToString:@"manger"]) {
            [self.mangerProductArray addObject:productInfo];
        }
        else    if ([etatPr isEqualToString:@"jeter"]) {
            [self.jetterProductArray addObject:productInfo];
        }
        
        else   if ([etatPr isEqualToString:@"donner"]) {
            [self.donnerProductArray addObject:productInfo];
        }
        
    }
    // Filtre product Emplacement
    for (int i =0; i< self.mangerProductArray.count ; i++) {
        NSDictionary *productInfo;
        productInfo = [self.mangerProductArray objectAtIndex:i] ;
        NSString * lieuPr =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"lieu"]];
        if ([lieuPr isEqualToString:@"monPlacard"]) {
            self.placardManger = self.placardManger + 1;
        }
        else if ([lieuPr isEqualToString:@"monFrigo"]) {
            self.frigoManger = self.frigoManger + 1;
        }
    }
    
    for (int i =0; i< self.jetterProductArray.count ; i++) {
        NSDictionary *productInfo;
        productInfo = [self.jetterProductArray objectAtIndex:i] ;
        NSString * lieuPr =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"lieu"]];
        if ([lieuPr isEqualToString:@"monPlacard"]) {
            self.placardJeter = self.placardJeter + 1;
        }
        else  if ([lieuPr isEqualToString:@"monFrigo"]) {
            self.frigoJeter = self.frigoJeter + 1;
        }
    }
    
    for (int i =0; i< self.donnerProductArray.count ; i++) {
        NSDictionary *productInfo;
        productInfo = [self.donnerProductArray objectAtIndex:i] ;
        NSString * lieuPr =  [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"lieu"]];
        if ([lieuPr isEqualToString:@"monPlacard"]) {
            self.placardDonner = self.placardDonner + 1;
        }
        else  if ([lieuPr isEqualToString:@"monFrigo"]) {
            self.frigoDonner = self.frigoDonner + 1;
        }
    }
    // value label
    if (self.mangerProductArray.count > 1)
         self.totalProductEat.text =  [NSString stringWithFormat:@"%d produits mangés",self.mangerProductArray.count];
    else
    self.totalProductEat.text =  [NSString stringWithFormat:@"%d produit mangé",self.mangerProductArray.count];
    
    self.totalFrigoEat.text =  [NSString stringWithFormat:@"%d dans mon frigo",self.frigoManger];
    self.totalPlacardEat.text =  [NSString stringWithFormat:@"%d dans mon placard",self.placardManger];
    
    if (self.jetterProductArray.count > 1)
    self.totalProductJet.text =  [NSString stringWithFormat:@"%d produits jetés",self.jetterProductArray.count];
    else
    self.totalProductJet.text =  [NSString stringWithFormat:@"%d produit jeté",self.jetterProductArray.count];

    self.totalFrigoJet.text =  [NSString stringWithFormat:@"%d dans mon frigo",self.frigoJeter];
    self.totalPlacardJet.text =  [NSString stringWithFormat:@"%d dans mon placard",self.placardJeter];
    
    if (self.donnerProductArray.count > 1)
    self.totalProductDon.text =  [NSString stringWithFormat:@"%d produits donnés",self.donnerProductArray.count];
    else
    self.totalProductDon.text =  [NSString stringWithFormat:@"%d produit donné",self.donnerProductArray.count];

    self.totalFrigoDon.text =  [NSString stringWithFormat:@"%d dans mon frigo",self.frigoDonner];
    self.totalPlacardDon.text =  [NSString stringWithFormat:@"%d dans mon placard",self.placardDonner];
    
    float unitView = 0;
    int totalProduct = 0;
    totalProduct = self.mangerProductArray.count + self.jetterProductArray.count + self.donnerProductArray.count;
    
    if (totalProduct > 0) {
          unitView = 240/ totalProduct;
        NSLog(@"%f",unitView);
    }
    
   // Color progress Statistic
    float widthEat = unitView*self.mangerProductArray.count;
    self.progressValueEat.frame = CGRectMake(self.progressValueEat.frame.origin.x, self.progressValueEat.frame.origin.y,widthEat , self.progressValueEat.frame.size.height);
    NSLog(@"### %f",widthEat);
    
    float widthDon = unitView*self.donnerProductArray.count;
    self.progressValueDon.frame = CGRectMake((self.progressValueEat.frame.origin.x + widthEat), self.progressValueDon.frame.origin.y,widthDon , self.progressValueDon.frame.size.height);
    NSLog(@"##### %f",widthDon);
    
    float widthJet = unitView*self.jetterProductArray.count;
    self.progressValueJet.frame = CGRectMake((self.progressValueDon.frame.origin.x + widthDon), self.progressValueJet.frame.origin.y,widthJet , self.progressValueJet.frame.size.height);
     NSLog(@"####### %f",widthJet);
   
    // Initial label
    if (self.placardDonner == 0) {
        self.totalPlacardDon.hidden = YES;
    }
    if (self.placardJeter == 0) {
        self.totalPlacardJet.hidden = YES;
    }
    if (self.placardManger == 0) {
        self.totalPlacardEat.hidden = YES;
    }
    if (self.frigoJeter == 0) {
        self.totalFrigoJet.hidden = YES;
        self.totalPlacardJet.frame = CGRectMake(100, 342,self.totalPlacardJet.frame.size.width , self.totalPlacardJet.frame.size.height);
    }
    if (self.frigoManger == 0) {
        self.totalFrigoEat.hidden = YES;
        self.totalPlacardEat.frame = CGRectMake(100, 182,self.totalPlacardEat.frame.size.width , self.totalPlacardEat.frame.size.height);
    }
    if (self.frigoDonner == 0) {
        self.totalFrigoDon.hidden = YES;
        self.totalPlacardDon.frame = CGRectMake(100, 261,self.totalPlacardDon.frame.size.width , self.totalPlacardDon.frame.size.height);
    }
    // num of like
    self.numOfLike.text = [NSString stringWithFormat:@"%d",self.donnerProductArray.count];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
