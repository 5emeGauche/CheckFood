//
//  CFNavigationController.h
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
#import "BufferedNavigationController.h"
#import "ALRadialMenu.h"


@interface CFNavigationController : BufferedNavigationController<UITableViewDataSource, UITableViewDelegate, ALRadialMenuDelegate >

@property (nonatomic, strong) UIButton *addproductButton;
@property (nonatomic, strong) UIButton *addproductButtonMenu;
/**
 The menu container that slides from the right of the screen
 */
@property (nonatomic, strong) UIView *menu;
/**
 The table view used as the main element of the menu
 */
@property (nonatomic, strong) UITableView *menuTableView;
/**
 The view that represents the top view controller's view
 */
@property (nonatomic, strong) UIView *contentView;
/**
 View that represents the black layer displayed when the menu is visible
 */
@property (nonatomic, strong) UIView *blackLayer;
/**
 The attribute that indicates whether the menu is visible or not
 */
@property (nonatomic, readonly, getter = isMenuHidden) BOOL menuHidden;

/**
 Method used to toogle menu
 @param animated YES to toogle menu using animation, NO otherwise
 */
- (void)toggleMenuAnimated:(BOOL)animated;
/**
 Method called to show menu on the right part of the screen
 @param animated YES to show menu using animation, NO otherwise
 */
- (void)showMenuAnimated:(BOOL)animated;
/**
 Method called to hide menu
 @param animated YES to hide menu using animation, NO otherwise
 */
- (void)hideMenuAnimated:(BOOL)animated;

/**
 Convenience method pushes the root view controller without animation
 @param rootViewController The root controller
 @returns The initialized navigation controller using the given controller
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController;
/**
 Method called to push new controller on the navigation stack. Has no effect if the view controller is already in the stack
 @param viewController The new controller to be pushed
 @param animated YES to use a horizontal slide transition, NO otherwise
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
/**
 Pop the top controller from the navigation stack
 @param animated YES to use a horizontal slide transition, NO otherwise
 @returns The popped controller
 */
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
/**
 Pops view controllers until the one specified is on top.
 @param viewController The controller that will be on the top of the navigation stack
 @param animated YES to use a horizontal slide transition, NO otherwise
 @returns Returns the popped controllers
 */
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
/**
 Pops until there's only a single view controller left on the stack
 @param animated YES to use a horizontal slide transition, NO otherwise
 @returns Returns the popped controllers
 */
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;
/**
 Simulate a push or pop depending on whether the new top view controller was previously in the stack
 @param viewControllers The list of controller to be added to the navigation stack
 @param animated YES to use a horizontal slide transition, NO otherwise
 */
//- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end