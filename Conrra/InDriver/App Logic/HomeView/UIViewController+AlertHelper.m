//
//  UIViewController+AlertHelper.m

//
//  Created by Grepix - Baij on 01/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "UIViewController+AlertHelper.h"
#import "LanguageHelper.h"

@implementation UIViewController (AlertHelper)
-(void) showAlert:(NSString *)messgae title:(NSString *) title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:messgae
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
