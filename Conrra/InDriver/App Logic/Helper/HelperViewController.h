//
//  HelperViewController.h

//
//  Created by Grepix - Baij on 15/04/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface HelperViewController : BaseViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnEmpezar;
@property (weak, nonatomic) IBOutlet UIPageControl *viewPageControl;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

NS_ASSUME_NONNULL_END
