//
//  UploadDocView.m

//
//  Created by Grepix - Baij on 07/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "UploadDocView.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import "Utilities.h"
#import "LanguageHelper.h"
#import "ImageDoc.h"
#import "UIImageView+WebCache.h"
#import "UIHelper.h"

@implementation UploadDocView
{
    int calHeight;
    
    NSMutableArray * arrayDocs;
    //    ImageDoc * selectedImageDoc;
    NSDictionary * selectedDictForUploadImage;
    BOOL isInputMondatory;
    NSDictionary * dictForInput;
    CustomUIButton * selectedButton;
    NIDropDown *dropDown;
    BOOL isRequireToLoad;
    CityModel *genderSelected;
    NSDictionary *countrySelected;
    UIButton *dropDownBtnSelected;
    UITapGestureRecognizer *tapRecognizer;
    UIView *gestureBg;
}

- (instancetype)initWithView:(UIView *)view frame:(CGRect) frame dict:(NSDictionary *) dict
{
    self = [super init];
    if (self) {
        self.dict=dict;
        calHeight=0;
        isInputMondatory=NO;
        arrayDocs=[[NSMutableArray alloc] init];
        [self uploadView:view frame:frame dict:dict];
    }
    return self;
}

-(void) uploadView:(UIView *)view frame:(CGRect) frame dict:(NSDictionary *) dict{
    
    
    NSArray * docs=[self.dict objectForKey:@"inputs"];
    int heightView=40;
    NSString * name=[[dict objectForKey:@"header"] objectForKey:@"placeholder"];
    
    
    name=[LanguageHelper getStringWithKey:name defaultValue:name];
    
    
    //    self.button=[[UIButton alloc] initWithFrame:CGRectMake(8, 0, frame.size.width-16, 30)];
    int height=[Utilities getLabelHeight:CGSizeMake(frame.size.width-16, 2000) forText:name withFont:FONTS_THEME_REGULAR(14)];
    //    heightView=heightView+height;
    //    calHeight=calHeight+height;
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(8, 0, frame.size.width-16, heightView)];
    
    [label setFont:FONTS_THEME_REGULAR(14)];
    label.text=name;
    label.textColor=[UIColor colorNamed:@"color_app_label"];
    
    label.numberOfLines=0;
    
    UIView *viewBg =[[UIView alloc] initWithFrame:frame];
    [viewBg setBackgroundColor:[UIColor clearColor]];
    [viewBg addSubview:label];
    
    [self setBorder:viewBg];
    
    calHeight=calHeight+30;
    calHeight=calHeight+60;
    int  imageRow=1;
    int index=0;
    
    BOOL isRtl=NO;
    if([UIView appearance].semanticContentAttribute==UISemanticContentAttributeForceRightToLeft){
        isRtl=YES;
    }
    int expryAndEditText = 0;
    for (NSDictionary * dictFor in docs) {
        BOOL is_visible = YES;
        if ([[dictFor allKeys] containsObject:@"is_visible"]){
            is_visible = [[dictFor objectForKey:@"is_visible"] boolValue];
        }
        if(is_visible){
            if([[ dictFor objectForKey:@"type"] isEqualToString:@"ImageView"])  {
                int top=[self isExpiryHas:docs]?30:0;
                if ([self isExpiryAndDropHas:docs]){
                    top = top + 40;
                }
                if([[ dictFor objectForKey:@"is_front"] isEqualToString:@"1"]){
                    ImageDoc * imageDoc=[[ImageDoc alloc] initWithFrame:CGRectMake(isRtl?SCREEN_WIDTH/2+10:10, 40+top, 45, 45) view:viewBg];
                    [arrayDocs addObject:imageDoc];
                    [imageDoc.button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
                    imageDoc.button.dictInput=dictFor;
                    
                    imageDoc.label.text=[LanguageHelper getStringWithKey:@"k_r46_s8_frnt"];
                }else{
                    ImageDoc * imageDoc=[[ImageDoc alloc] initWithFrame:CGRectMake(isRtl?10:SCREEN_WIDTH/2+10, 40+top, 45, 45) view:viewBg];
                    [arrayDocs addObject:imageDoc];
                    [imageDoc.button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
                    imageDoc.button.dictInput=dictFor;
                    imageDoc.label.text=[LanguageHelper getStringWithKey:@"k_r47_s8_back"];
                }
            }else if([[ dictFor objectForKey:@"type"] isEqualToString:@"EditText"]) {
                expryAndEditText = expryAndEditText + 1;
                isInputMondatory=YES;
                dictForInput=dictFor;
                int leftPadding=50;
                NSString *textExp=[LanguageHelper getStringWithKey:@"k_r45_s8_dte_of_exp"];
                
                int withText=[Utilities widthOfString:textExp withFont:FONTS_THEME_REGULAR(13)];
                if(withText>leftPadding){
                    if(withText<SCREEN_WIDTH-130){
                        leftPadding=withText+10;
                    }else{
                        leftPadding=SCREEN_WIDTH-130;
                    }
                }
                int top=30;
                if (expryAndEditText== 2){
                    top = top + 30;
                }
                
                BOOL isTwoDoc=docs.count>2;
                CGRect frameLabel=CGRectMake(isRtl?SCREEN_WIDTH-50-leftPadding:10, top, leftPadding, 36);
                UILabel *label=[[UILabel alloc] initWithFrame:frameLabel];
                [label setFont:FONTS_THEME_REGULAR(13)];
                label.textColor=[UIColor colorNamed:@"color_app_label"];
                [viewBg addSubview:label];
                label.text=[LanguageHelper getStringWithKey:@"k_r45_s8_dte_of_exp"];
                self.textField=[[UITextField alloc] initWithFrame:CGRectMake(isRtl?SCREEN_WIDTH-20-frame.size.width-16-leftPadding:leftPadding+5, top-2,isRtl?frame.size.width-16 :frame.size.width-16, heightView)];
                if(isRtl){
                    self.textField.textAlignment=NSTextAlignmentRight;
                    label.textAlignment=NSTextAlignmentRight;
                }else{
                    self.textField.textAlignment=NSTextAlignmentLeft;
                    label.textAlignment=NSTextAlignmentLeft;
                }
                
                UIButton * buttonDate=[[UIButton alloc] initWithFrame:self.textField.frame];
                [buttonDate setTitle:@"" forState:UIControlStateNormal];
                
                [buttonDate addTarget:self action:@selector(dateSelect:) forControlEvents:UIControlEventTouchUpInside];
                int topArea=0;
                if (@available(iOS 11.0, *)) {
                    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
                    topArea = window.safeAreaInsets.top;
                    CGFloat bottomPadding = window.safeAreaInsets.bottom;
                    topArea=topArea+bottomPadding;
                }
                self.textField.font=FONTS_THEME_REGULAR(14);
                self.textField.placeholder=[ dictFor objectForKey:@"placeholder"];
                self.textField.textColor = [UIColor colorNamed:@"color_app_input"];
                [UIHelper setPlaceHolder:self.textField];
                [viewBg addSubview:self.textField];
                [buttonDate setBackgroundColor:[UIColor clearColor]];
                [viewBg addSubview:buttonDate];
                calHeight=calHeight+heightView;
            }else if([[ dictFor objectForKey:@"type"] isEqualToString:@"DropDown"])  {
                expryAndEditText = expryAndEditText + 1;
                isInputMondatory=YES;
                dictForInput=dictFor;
                int leftPadding=20;
                NSString *selectType=[LanguageHelper getStringWithKey:@"k_r_60_s8_plz_slct_typ_of"];
                
                //            int withText=[Utilities widthOfString:textExp withFont:FONTS_THEME_REGULAR(13)];
                //            if(withText>leftPadding){
                //                if(withText<SCREEN_WIDTH-130){
                //                    leftPadding=withText+10;
                //                }else{
                //                    leftPadding=SCREEN_WIDTH-130;
                //                }
                //            }
                BOOL isTwoDoc=docs.count>2;
                //            CGRect frameLabel=CGRectMake(isRtl?SCREEN_WIDTH-50-leftPadding:10, index*heightView+index*5-(isTwoDoc?60:10), leftPadding, 36);
                //            UILabel *label=[[UILabel alloc] initWithFrame:frameLabel];
                //            [label setFont:FONTS_THEME_REGULAR(13)];
                //            label.textColor=[UIColor colorNamed:@"color_app_label"];
                //            [viewBg addSubview:label];
                //            label.text=[LanguageHelper getStringWithKey:@""];
                
                int top=30;
                if (expryAndEditText== 2){
                    top = top + 30;
                }
                self.textField=[[UITextField alloc] initWithFrame:CGRectMake(isRtl?SCREEN_WIDTH-20-frame.size.width-16-leftPadding:leftPadding+5, top-2,isRtl?frame.size.width-16 :frame.size.width-16, heightView)];
                if(isRtl){
                    self.textField.textAlignment=NSTextAlignmentRight;
                    label.textAlignment=NSTextAlignmentRight;
                }else{
                    self.textField.textAlignment=NSTextAlignmentLeft;
                    label.textAlignment=NSTextAlignmentLeft;
                }
                UIImage *imageFro = [UIImage imageNamed:@"drop-down-arrow"];
                UIImageView * imageViewDrop=[[UIImageView alloc] initWithFrame:CGRectMake(isRtl?10:SCREEN_WIDTH-80, self.textField.frame.origin.y + (heightView-16)/2, 16, 16)];
                imageViewDrop.image = imageFro;
                UIButton * buttonDate=[[UIButton alloc] initWithFrame:CGRectMake(10, self.textField.frame.origin.y + (heightView-top)/2, self.textField.frame.size.width-5, 30)];
                [buttonDate setTitle:@"" forState:UIControlStateNormal];
                
                [buttonDate addTarget:self action:@selector(dateSelect:) forControlEvents:UIControlEventTouchUpInside];
                int topArea=0;
                if (@available(iOS 11.0, *)) {
                    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
                    topArea = window.safeAreaInsets.top;
                    CGFloat bottomPadding = window.safeAreaInsets.bottom;
                    topArea=topArea+bottomPadding;
                }
                self.textField.font=FONTS_THEME_REGULAR(14);
                self.textField.placeholder=[NSString stringWithFormat:@"%@ %@",selectType,[LanguageHelper getStringWithKey:name]];
                self.textField.textColor = [UIColor colorNamed:@"color_app_input"];
                self.textField.enabled = NO;
                //            self.textField.text = ;
                [UIHelper setPlaceHolder:self.textField];
                //             self.textField.inputView  = self.pickerView; // Here birthT
                [viewBg addSubview:self.textField];
                [buttonDate setBackgroundColor:[UIColor clearColor]];
                buttonDate.layer.cornerRadius = 2;
                buttonDate.layer.borderWidth = 0.5;
                buttonDate.layer.borderColor = UIColor.lightGrayColor.CGColor;
                [viewBg addSubview:imageViewDrop];
                [viewBg addSubview:buttonDate];
                
                if(docs.count==1){
                    calHeight=75;
                }else{
                    calHeight=calHeight+heightView;
                }
            }
            index++;
        }
    }
    
    //    [viewBg addSubview:self.activityLoader];
    //    [viewBg addSubview:self.imageUploadSuccess];
    
    CGRect rect=viewBg.frame;
    rect.size.height=calHeight+5;
    viewBg.frame=rect;
    [view addSubview:viewBg];
    //    self.button.userInteractionEnabled=YES;
    
}

-(void) dateSelect:(UIButton *)sender{
    BOOL isDropDown=NO;
    NSArray * docs=[self.dict objectForKey:@"inputs"];
    for (NSDictionary * dictFor in docs) {
        if([[ dictFor objectForKey:@"type"] isEqualToString:@"DropDown"]){
            isDropDown = YES;
            break;
        }
    }
    if(isDropDown){
        [self openDorpDown:sender];
    }else{
        [self.delegate docUploadView:self dateSelect:self.selectedDate];
    }
}

- (void)openDorpDown:(id)sender {
    [self addTapGesture];
    dropDownBtnSelected=sender;
    [[self.delegate getParentView] endEditing:YES];
    CGPoint origin = [[self.delegate getParentView] convertPoint:CGPointZero fromView:sender];
    BOOL isDown;
    CGRect frame;
    CGFloat f =120;
    isDown=YES;
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    CityModel * others = [[CityModel alloc]init];
    NSString * name=[[self.dict objectForKey:@"header"] objectForKey:@"placeholder"];
    others.city_name =[NSString stringWithFormat:@"%@ %@",[LanguageHelper getStringWithKey:@"k_r_60_s8_plz_slct_typ_of"],[LanguageHelper getStringWithKey:name]];
    others.city_id=-1;
    others.country_code = @"";
    [arr addObject:others];
    NSString * server_value;
    NSArray * docs=[self.dict objectForKey:@"inputs"];
    for (NSDictionary * dictFor in docs) {
        if([[ dictFor objectForKey:@"type"] isEqualToString:@"DropDown"]){
            server_value = [ dictFor objectForKey:@"server_value" ];
            break;
        }
    }
    NSDictionary * arrayServerValues = [Utilities idFormJsonString:server_value];
    int index = 1;
    for (NSString * vsValue in arrayServerValues.allKeys) {
        CityModel * male = [[CityModel alloc]init];
        male.city_name =[LanguageHelper getStringWithKey:[arrayServerValues objectForKey:vsValue]];
        male.city_id=index;
        male.country_code = [arrayServerValues objectForKey:vsValue];
        [arr addObject:male];
        index = index + 1;
    }
   
    NSArray * arrImage = [[NSArray alloc] init];
    if(arr.count<5)  {
        f=arr.count*40;
    }
    frame=CGRectMake(35, origin.y+40, SCREEN_WIDTH-70,f);
    if(dropDown == nil) {
        dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :arrImage :@"down" view:[self.delegate getParentView] frame: frame up:isDown isLeftAligin:YES isShowCountryCode:YES];
        dropDown.delegate = self;
        dropDown.tag=12;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown=nil;
    }
}


-(void) addTapGesture{
    gestureBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [gestureBg setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.4]];
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandlerMethod:)];
    [gestureBg addGestureRecognizer:tapRecognizer];
    [[self.delegate getParentView] addSubview:gestureBg];
}

-(void) remoeGesture{
    [gestureBg  removeGestureRecognizer:tapRecognizer];
    [gestureBg removeFromSuperview];
}


-(void)gestureHandlerMethod:(UITapGestureRecognizer*)recognizer {
    [self remoeGesture];
    [dropDown hideDropDown:dropDownBtnSelected];
    dropDown=nil;
}

#pragma mark - NIDropDown Delegate Methods

- (void) niDropDownDelegateMethod: (NIDropDown *) sender index:(int) index  result:(id) resullt{
    [self remoeGesture];
    if(sender.tag==12)  {
        CityModel *cityModelTemp=(CityModel *)resullt;
        if(cityModelTemp.city_id>0){
            genderSelected = cityModelTemp;
            [self.textField setText:[NSString stringWithFormat:@"%@",cityModelTemp.city_name]];
            NSDictionary * dictDriver=defaults_object(P_USER_DICT);
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                P_DRIVER_ID           :[dictDriver objectForKey:P_DRIVER_ID],
                @"is_front":@"1",
                @"doc_type":isEmpty(genderSelected.country_code)
            }];
            if (arrayDocs.count>0){
                ImageDoc *doc =[arrayDocs objectAtIndex:0];
                if(doc.dictAssets)  {
                    [dict setObject:isEmpty([doc.dictAssets objectForKey:@"driver_asset_id"]) forKey:@"driver_asset_id"];
                }
            }
            NSString *  key ;
            NSArray * docs=[self.dict objectForKey:@"inputs"];
            for (NSDictionary * dictFor in docs) {
                if([[ dictFor objectForKey:@"type"] isEqualToString:@"DropDown"]){
                    key = [ dictFor objectForKey:@"key" ];
                    break;
                }
            }
            if(key){
                [dict setObject:key forKey:@"asset_type"];
            }
            [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
//            NSString *  key=[self->selectedDictForUploadImage objectForKey:@"key"];
            [GIC mkwerwu:ADD_DRIVER_ASSET  d:dict  cb:^(id results, NSError *error) {
                [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait"]];
                if( error !=nil)  {
                    [Utilities handleError:error viewController:self.viewController defaultMessage:@"Internet Error"];
                    return;
                }
                if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
                    if (self->arrayDocs.count>0){
                        ImageDoc *doc =[self->arrayDocs objectAtIndex:0];
                        if(doc.dictAssets)  {
                            NSArray *dictAssetsNew=[results objectForKey:P_RESPONSE];
                            if([dictAssetsNew isKindOfClass:[NSArray class]]){
                                for (NSDictionary *dict in dictAssetsNew) {
                                    if([[ dict objectForKey:@"asset_type"] isEqualToString:key]){
                                        if([[dict objectForKey:@"is_front"] boolValue]){
                                            doc.dictAssets = dict;
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }else if([[results objectForKey:P_STATUS] isEqualToString:@"Error"]){
                    [self showAlert:[LanguageHelper getStringWithKey:[results objectForKey:P_MESSAGE]]];
                }
                else{
                }
            }];
        }else{
            genderSelected = nil;
            NSString * name=[[self.dict objectForKey:@"header"] objectForKey:@"placeholder"];
            self.textField.placeholder =[NSString stringWithFormat:@"%@ %@",[LanguageHelper getStringWithKey:@"k_r_60_s8_plz_slct_typ_of"],[LanguageHelper getStringWithKey:name]];
            self.textField.text=@"";
        }
    }
    dropDown=nil;
}


-(BOOL) isExpiryHas:(NSArray *) docs{
    for (NSDictionary * dictFor in docs) {
        if([[ dictFor objectForKey:@"type"] isEqualToString:@"EditText"]){
            return YES;
        }
        else if([[ dictFor objectForKey:@"type"] isEqualToString:@"DropDown"]){
            return YES;
        }
    }
    return NO;
}


-(BOOL) isExpiryAndDropHas:(NSArray *) docs{
    int ex = 0;
    for (NSDictionary * dictFor in docs) {
        if([[ dictFor objectForKey:@"type"] isEqualToString:@"EditText"]){
            ex = ex +1;
        }
        else if([[ dictFor objectForKey:@"type"] isEqualToString:@"DropDown"]){
            ex = ex +1;
        }
    }
    if(ex == 2){
        return  YES;
    }
    return NO;
}

-(int)getCalculatedHeight
{
    return calHeight+15;
}
- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    self.textField.text = [df stringFromDate:datePicker.date];
}

-(void) buttonTap:(CustomUIButton *) button{
    selectedButton=button;
    if(isInputMondatory) {
        if( self.textField.text.length<4)   {
            BOOL isMon=[dictForInput objectForKey:@"is_mandatory"];
            if(isMon)
            {
                [self showAlert:[LanguageHelper getStringWithKey:@"k_r49_s8_plz_sel_exp_dte" defaultValue:@"please select expiry date"]];
                return;
            }
        }
    }
    //    for (ImageDoc * imageDoc in arrayDocs) {
    //        if( imageDoc.button==button){
    //            selectedImageDoc=imageDoc;
    //        }
    //    }
    selectedDictForUploadImage=button.dictInput;
    [self openOptionForUploadDocumentNew];
}

-(void)setBorderB:(UIButton *)view{
    view.layer.borderWidth=1;
    view.layer.cornerRadius =2;
    view.layer.borderColor = RGBA(27.0, 27.0, 36.0, 0.2).CGColor;
    [view clipsToBounds];
}
-(void)setBorder:(UIView *)view{
    view.layer.borderWidth=0.6;
    view.layer.cornerRadius =2;
    view.layer.borderColor = [UIColor colorNamed:@"color_app_label"].CGColor;
    [view clipsToBounds];
}


-(void) uploadDocuments:(UIImage *) resizeImage
{
    [self  uploadDocuments:resizeImage imageType:@"RC" is_front:YES customButton:selectedButton];
}

-(void) uploadDocuments:(UIImage *) resizeImage imageType:(NSString *)imageType is_front:(BOOL)is_front customButton:(CustomUIButton *) button{
    ImageDoc *selectedImageDoc=[self getSelectedImageDoc:button];
    NSString *strImage =[Base64 encode:UIImageJPEGRepresentation(resizeImage, 0.8)];
    NSDictionary * dictDriver=defaults_object(P_USER_DICT);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_DRIVER_ID           :[dictDriver objectForKey:P_DRIVER_ID],
        @"asset_type"         :imageType,
        @"image_type":@"jpg",
        @"driver_image"    :strImage,
        @"is_front": is_front?@"1":@"0"
        //        @"img_description"  :self.txtDescription.text
    }];
    
    NSString *  key ;
    NSString *  type ;
    NSArray * docs=[self.dict objectForKey:@"inputs"];
    for (NSDictionary * dictFor in docs) {
        if([[ dictFor objectForKey:@"type"] isEqualToString:@"DropDown"]){
            key = [ dictFor objectForKey:@"key" ];
            type =[ dictFor objectForKey:@"type" ];
            break;
        }
    }
    if([type isEqualToString:@"DropDown"]){
        if(is_front){
            [dict setObject:isEmpty(genderSelected.country_code) forKey:@"doc_type"];
        }
    }else{
        if (self.textField.text.length>5){
            [dict setObject:self.textField.text forKey:@"expire_date"];
        }
    }
    
    if(selectedImageDoc.dictAssets) {
        [dict setObject:isEmpty([selectedImageDoc.dictAssets objectForKey:@"driver_asset_id"]) forKey:@"driver_asset_id"];
    }
    selectedImageDoc.isImageSelect=YES;
    selectedImageDoc.imageView.image=resizeImage;
    selectedImageDoc.activityLoader.hidden=NO;
    [selectedImageDoc.activityLoader startAnimating];
    [GIC mkwerwu:ADD_DRIVER_ASSET
               d:dict  cb:^(id results, NSError *error) {
        selectedImageDoc.activityLoader.hidden=YES;
        [selectedImageDoc.activityLoader stopAnimating];
        if( error !=nil)  {
            [Utilities handleError:error viewController:self.viewController defaultMessage:@"Internet Error"];
            return;
        }
        selectedImageDoc.isImageSelect=YES;
        selectedImageDoc.imageView.image=resizeImage;
        if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
            //            self.imageUploadSuccess.hidden=NO;
            if (self->arrayDocs.count>0){
                NSArray *dictAssetsNew=[results objectForKey:P_RESPONSE];
                if([dictAssetsNew isKindOfClass:[NSArray class]]){
                    [self handleDocsData:dictAssetsNew];
                }
            }
        }
        else{
        }
    }];
    
}
-(ImageDoc *) getSelectedImageDoc:(CustomUIButton *)button{
    for (ImageDoc * imageDoc in arrayDocs) {
        if( imageDoc.button==button){
            return imageDoc;
        }
    }
    return nil;
}

-(void) showAlert:(NSString *)messgae title:(NSString *) title{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:messgae
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:actionOk];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}


-(void) showAlert:(NSString *) message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        //[self dismissViewControllerAnimated:YES completion:nil];
    }]; //You can use a block here to handle a press on this button
    [alertController addAction:actionOk];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}


- (void)openSelectedIsCamrea:(BOOL)isCamrea {
    
    //    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //          picker.delegate = self;
    //          picker.allowsEditing = YES;
    if(isCamrea)
    {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            //             picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else
        {
            [self showAlert:[LanguageHelper getStringWithKey:@"k_32_s6_camera_permission_error"] title:@""];
            return;
        }
    }else
    {
        //          picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    //    picker.delegate=self;
    
    [self openCheckPermission:isCamrea];
    //    [self.viewController presentViewController:picker animated:YES completion:nil];
}


-(void)openCheckPermission:(BOOL) isCamera{
    [UIImagePickerController obtainPermissionForMediaSourceType:isCamera?UIImagePickerControllerSourceTypeCamera:UIImagePickerControllerSourceTypePhotoLibrary withSuccessHandler:^{
        UIImagePickerController *pickerNavController = [[UIImagePickerController alloc] init];
        pickerNavController.delegate = self;
        //            pickerNavController.allowsEditing = YES;
        pickerNavController.sourceType =isCamera?UIImagePickerControllerSourceTypeCamera: UIImagePickerControllerSourceTypePhotoLibrary;
        [self.viewController presentViewController:pickerNavController animated:YES completion:nil];
    } andFailure:^{
        UIAlertController *alertController= [UIAlertController
                                             alertControllerWithTitle:nil
                                             message:[LanguageHelper getStringWithKey:@"k_s6_photo_setting_title"]
                                             preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction
                                    actionWithTitle:[LanguageHelper getStringWithKey:@"k_s6_open_setting"]
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }]
        ];
        [alertController addAction:[UIAlertAction
                                    actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"  ]
                                    style:UIAlertActionStyleCancel
                                    handler:NULL]
        ];
        [self.viewController presentViewController:alertController animated:YES completion:^{}];
    }];
}


-(void) openOptionForUploadDocumentNew{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_r18_s5_chse_img"]
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionCamera= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_28_s6_camera_j"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
        [self openSelectedIsCamrea:YES];
    }];
    UIAlertAction *actionGallery= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_29_s6_gallery_j"]
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        [self openSelectedIsCamrea:NO];
    }];
    
    UIAlertAction *actionCancel= [UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_30_s6_cancel_j"]
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
    }];
    [alertController addAction:actionCamera];
    [alertController addAction:actionGallery];
    [alertController addAction:actionCancel];
    [self.viewController presentViewController:alertController animated:YES completion:nil];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *resizeImage= [Utilities imageWithImageHeight:chosenImage scaledToWidth:1024 scaledToHeight:1024];
        NSString *  key=[self->selectedDictForUploadImage objectForKey:@"key"];
        BOOL   isFront=[[self->selectedDictForUploadImage objectForKey:@"is_front"] boolValue ];
        [self uploadDocuments:resizeImage imageType:key is_front:isFront customButton:self->selectedButton];
    }];
}


-(NSString *)encodeImageToBase64String:(UIImage *)image
{
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) handleDocsData:(NSArray * )array
{
    NSString *  key ;
    NSString *  type ;
    NSArray * docs=[self.dict objectForKey:@"inputs"];
    for (NSDictionary * dictFor in docs) {
        if([[ dictFor objectForKey:@"type"] isEqualToString:@"DropDown"]){
            key = [ dictFor objectForKey:@"key" ];
            type =[ dictFor objectForKey:@"type" ];
            break;
        }
    }
    NSDictionary * dictOldData;
    if([array isKindOfClass:[NSArray class]]){
        for (NSDictionary *dict in array) {
            if([[ dict objectForKey:@"asset_type"] isEqualToString:key]){
                if([[dict objectForKey:@"is_front"] boolValue]){
                    dictOldData = dict;
                    NSString * dd = [LanguageHelper getStringWithKey:[dictOldData objectForKey:@"doc_type"]];
                    self.textField.text=[LanguageHelper getStringWithKey:[dictOldData objectForKey:@"doc_type"]];
                    break;
                }
            }
        }
    }
    
    for (NSDictionary * dict in array) {
        ImageDoc * imageDoc=[self checkIsCanSetImage:dict];
        if(imageDoc)   {
            imageDoc.dictAssets=dict;
            imageDoc.isImageSelect=YES;
            [imageDoc.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images,[dict objectForKey:@"img_path"]]] placeholderImage:[UIImage imageNamed:@"google-docs"]];
            if([type isEqualToString:@"DropDown"]){
                
            }else{
                self.textField.text=[dict objectForKey:@"expire_date"];
            }
        }
    }
    
}


-(NSDictionary *) validateDocsData
{
    
    NSArray *arrInputs=[self.dict objectForKey:@"inputs"];
    for (NSDictionary * dict in arrInputs) {
        
        if([[dict objectForKey:@"type"] isEqualToString:@"ImageView"])
        {
            for (ImageDoc * doc in arrayDocs) {
                if ([[doc.button.dictInput objectForKey:@"key"] isEqualToString:[dict objectForKey:@"key"]])
                {
                    //                    if(!doc.isImageSelect)
                    //                    {
                    //                        BOOL is_mandatory=[[dict objectForKey:@"is_mandatory"] boolValue];
                    //                        if(is_mandatory)
                    //                        {
                    //                            return dict;
                    //                        }
                    ////                        return  dict;
                    //                    }
                    
                    if([[doc.button.dictInput objectForKey:@"is_front"] intValue ] ==[[dict objectForKey:@"is_front"] intValue]){
                        if(!doc.isImageSelect) {
                            BOOL is_mandatory=[[dict objectForKey:@"is_mandatory"] boolValue];
                            if(is_mandatory){
                                return dict;
                            }
                            //                        return  dict;
                        }
                    }
                }
            }
            
        }else if([[dict objectForKey:@"type"] isEqualToString:@"EditText"]){
            if(self.textField.text.length==0)   {
                BOOL is_mandatory=[[dict objectForKey:@"is_mandatory"] boolValue];
                if(is_mandatory)
                {
                    return dict;
                }
            }
        }else if([[dict objectForKey:@"type"] isEqualToString:@"DropDown"]){
            if(self.textField.text.length==0) {
                BOOL is_mandatory=[[dict objectForKey:@"is_mandatory"] boolValue];
                if(is_mandatory)  {
                    return dict;
                }
            }
        }
        
    }
    return nil;
}



-(ImageDoc * ) checkIsCanSetImage:(NSDictionary *) dict{
    for (ImageDoc * doc in  arrayDocs) {
        if([[doc.button.dictInput objectForKey:@"key"] isEqualToString:[dict objectForKey:@"asset_type"]])  {
            if([[doc.button.dictInput objectForKey:@"is_front"] boolValue] ==[[dict objectForKey:@"is_front"] boolValue])  {
                return doc;
            }
        }
    }
    return nil ;
}


@end
