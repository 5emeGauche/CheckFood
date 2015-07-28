//
//  CFAddProductViewController.m
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

#import "CFAddProductViewController.h"
#import  "ZXingObjC.h"
#import "CFCaptureProductViewController.h"
#import "CFHistoriqueViewController.h"
#import "CFMyProductsViewController.h"
#import "CFAppDelegate.h"

@interface CFAddProductViewController ()

@property (nonatomic, strong) ZXCapture *capture;

@end

@implementation CFAddProductViewController

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
    
    self.masqueBlackBottom.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"MASQUE2.png"]];
    self.masqueBlackBottom.alpha = 1.;
    self.masqueBlackTop.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"MASQUE2.png"]];
    self.masqueBlackTop.alpha = 1.;
    self.masqueBlackLeft.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"MASQUE2.png"]];
    self.masqueBlackLeft.alpha = 1.;
    self.masqueBlackRight.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"MASQUE2.png"]];
    self.masqueBlackRight.alpha = 1.;
    
    
    self.capture = [[ZXCapture alloc] init];
    //set the default back cams
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0f;
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
    //Set the scan rect
    self.capture.scanRect = CGRectApplyAffineTransform(self.scanRectView.frame, captureSizeTransform);
    
    self.capture.layer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.capture.layer];
    [self.view bringSubviewToFront:self.scanRectView];
    [self.view bringSubviewToFront:self.camOverlay];
    [self.view bringSubviewToFront:self.header];
    
    self.capture.delegate = self;
    self.capture.layer.frame = self.camOverlay.frame;
    //Start the capture
    [self.capture start];

}

#pragma mark - Action Methods

-(IBAction)goToHistoryButAction:(id)sender {
    
    CFHistoriqueViewController *historiqueVC = [[CFHistoriqueViewController alloc]initWithNibName:@"CFHistoriqueViewController" bundle:nil];
    [self.navigationController pushViewController:historiqueVC animated:YES];
}

-(IBAction)backButAction:(id)sender {
   // [self.navigationController popViewControllerAnimated:YES];
    
    CFNavigationController *mainNavVC = (CFNavigationController *)[(CFAppDelegate *)[[UIApplication sharedApplication] delegate] mainNavigationController];
    [mainNavVC tableView:mainNavVC.menuTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSArray *viewControllers =  [self.navigationController viewControllers];
    UIViewController *lastVC = [viewControllers lastObject];
    if ([lastVC isKindOfClass:[CFMyProductsViewController class]]) {
        [self.navigationController popToViewController:lastVC animated:NO];
    }
    else {
        CFMyProductsViewController *productsVC = [[CFMyProductsViewController alloc]initWithNibName:@"CFMyProductsViewController" bundle:nil];
        [self.navigationController pushViewController:productsVC animated:NO];
    }

}


#pragma mark - ZXCaptureDelegate Methods
-(void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    //set the delegate to nil to not capture many time
    self.capture.delegate = nil;
    //Stop the capture
    [self.capture stop];
    //set the capture to nil for memory raison
    self.capture = nil;
    // Vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSLog(@"result %@ ",result.text);

    CFCaptureProductViewController *captureProductVC = [[CFCaptureProductViewController alloc]initWithNibName:@"CFCaptureProductViewController" bundle:nil];
    //set the result
    captureProductVC.productEAN = result.text;
    [self.navigationController pushViewController:captureProductVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
