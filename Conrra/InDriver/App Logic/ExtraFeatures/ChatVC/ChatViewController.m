//
//  ChatViewController.m
//  HireMe Rider
//
//  Created by Prashant on 12/02/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "ChatViewController.h"
#import "IQKeyboardManager.h"
#import "SenderCell.h"
#import "ReceiverCell.h"
#import "FireBaseModel.h"
#import <GIKit/GIKit.h>
#import "AppDelegate.h"
#import "WebCallConstants.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "TripModel+Helper.h"
#import "Utilities.h"
@interface ChatViewController ()  < UITableViewDelegate, UITableViewDataSource>{
    NSString *lastMessageKey;
    FireBaseModel *fireModel;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputBottom;
@property (weak, nonatomic) IBOutlet UIView *viewChatBottom;

@property (strong,nonatomic) NSMutableArray<FIRDataSnapshot *> *arrChats;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ChatViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(keyPressed:)
                                                 name: UITextViewTextDidChangeNotification
                                               object: nil];
    [self configureVC];
    [self setUIFields];
    UIImage * ima=[self.imageSendIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageSendIcon.tintColor=[UIColor colorNamed:@"app_theame"];
    self.imageSendIcon.image=ima;
    fireModel = [[FireBaseModel alloc] initFirebaseWithChannelID:self.tripID];
    
    [self getChats];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appInForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBack:) name:@"TripCancelled" object:nil];
    
    if (self.isFromHistory) {
        //hide text field and post button
        self.viewChatBottom.userInteractionEnabled = NO;
        self.viewChatBottom.alpha = 0.4;
    }
    
    
    if (IS_IOS10_AND_ABOVE) {
        // Initialize the refresh control.
        self.refreshControl = [[UIRefreshControl alloc] init];
        //self.refreshControl.backgroundColor = [UIColor whiteColor];
        self.refreshControl.tintColor = [UIColor lightGrayColor];
        [self.refreshControl addTarget:self
                                action:@selector(loadMoreMessages)
                      forControlEvents:UIControlEventValueChanged];
        
        _tableView.refreshControl = self.refreshControl;
    }
    if(self.tripModel==nil)
    {
        self.tripModel=[[TripModel alloc] init];
        self.tripModel.trip_Id=self.tripID;
        if(self.tripID!=nil)
        {
            [self.tripModel refreshTripModelWithCompletionBlock:^(id results, NSError *error) {
                
                    self.lblHeader.text=[NSString stringWithFormat:@"%@ %@",isEmpty(self.tripModel.user.u_fname),isEmpty(self.tripModel.user.u_lname)];
                
            } isShowLoader:YES];
        }
    }else{
        self.lblHeader.text=[NSString stringWithFormat:@"%@ %@",self.tripModel.user.u_fname,self.tripModel.user.u_lname];
    }
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    self.txtChatMessage.placeholder=[LanguageHelper getStringWithKey:@"k_s11_type_message"];
}

-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [fireModel updateUserTotalReadCount];  ///  <<<===== new
}


-(void) setUIFields{
}






-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self scrollToBottom_animated:YES];
    [self.view layoutIfNeeded];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [fireModel.ref removeAllObservers];
    fireModel=nil;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [fireModel removeMessageVCObservers];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TripCancelled" object:nil];
}

-(void)appInBackground{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TripCancelled" object:nil];
}
-(void)appInForeground{ 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBack:) name:@"TripCancelled" object:nil];
}


#pragma mark - FireBase Model Call Back

-(void)getChats{
    [fireModel getAllChatsWithCompletion:^(id result, NSError *error) {
        [self.arrChats addObject:(FIRDataSnapshot *)result];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.arrChats.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationBottom];
        [self scrollToBottom_animated:NO];
    }];
    
    [fireModel getAllChatsValueChangeWithCompletion:^(id result, NSError *error) {
        if(error==nil) {
            [self.tableView reloadData];
        }
    }];
}


-(void) keyPressed: (NSNotification*) notification{
    int height = [UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-54,9999) forText:self.txtChatMessage.text withFont:FONTS_THEME_REGULAR_NO_SCALE(17)];

    if ((long)self.txtChatMessage.hasText)  {
        if (height <= 90)
        {
            [self.txtChatMessage scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
            [self.viewChatBottom setConstraintConstant:30+height forAttribute:NSLayoutAttributeHeight];
            self.txtChatMessage.scrollEnabled = NO;
        }
        if (height > 90)
        {
            self.txtChatMessage.scrollEnabled = YES;
        }
    }
}

#pragma mark - Keyboard Notifications
-(void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    int height = keyboardSize.height;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        CGFloat bottomPadding = window.safeAreaInsets.bottom;
        height=height-bottomPadding;
    }
    self.inputBottom.constant = height;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, height , 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, height, 0)];
     
    [UIView animateWithDuration:0.0 animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self scrollToBottom_animated:YES];
    }];
}


-(void)keyboardWillHide:(NSNotification *)notification {
    [self.inputBottom setConstant:0];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [UIView animateWithDuration:0.0 animations:^{
        [self.view layoutIfNeeded];
    }
                     completion:^(BOOL finished) {
        
    }];
    
}




#pragma mark - Table Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  [_arrChats count];
    // return 20;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifierSender = @"SenderCell";
    static NSString *cellIdentifierReceiver = @"ReceiverCell";
    @try {
        FIRDataSnapshot *messageSnapshot = self.arrChats[indexPath.row];
        NSDictionary<NSString *, NSString *> *message = messageSnapshot.value;
        NSString *time = [Utilities convertTimeStamp:[message[@"timeStamp"] doubleValue]];
        NSDictionary *userDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
        NSString *userid = [userDict  objectForKey:P_FIRE_ID];
        BOOL isSender=NO;
        if ([message[@"from"] isEqualToString:userid]) {
            isSender=YES;
        }
        NSMutableAttributedString *finalText=[self formattMessage:time message:message[@"text"] isSender:isSender];
        if (isSender) {
            ReceiverCell *cellReceiver = [tableView dequeueReusableCellWithIdentifier:cellIdentifierReceiver];
            if (!cellReceiver) {
                cellReceiver = [[ReceiverCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifierReceiver];
            }
            cellReceiver.message.attributedText = finalText;
            return cellReceiver;
        }
        else {
            SenderCell *cellSender = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSender];
            if (!cellSender) {
                cellSender = [[SenderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifierSender];
            }
            BOOL isRead=[[message objectForKey:@"is_read"] boolValue];
            if(!isRead)  {
                [fireModel makerRead:nil key:messageSnapshot.key withCompletion:^(id result, NSError *error) {
                    
                }];
            }
            cellSender.message.attributedText =  finalText;
            cellSender.message.textColor = [UIColor colorNamed:@"color_app_label"];
            [cellSender.profilePic sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images,self.tripModel.user.u_profile_image_path]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
            return cellSender;
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
    SenderCell *cellSender = [tableView dequeueReusableCellWithIdentifier:cellIdentifierSender];
    return cellSender;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.txtChatMessage resignFirstResponder];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FIRDataSnapshot *messageSnapshot = self.arrChats[indexPath.row];
    NSDictionary<NSString *, NSString *> *message = messageSnapshot.value;
    NSString *time = [Utilities convertTimeStamp:[message[@"timeStamp"] doubleValue]];
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSString *userid = [userDict  objectForKey:P_FIRE_ID];
    BOOL isSender=NO;
    if ([message[@"from"] isEqualToString:userid]) {
        isSender=YES;
    }
    NSMutableAttributedString *finalText=[self formattMessage:time message:message[@"text"] isSender:isSender];
    int height=[self getHeight:finalText];
    return 30+height;
    
}

-(float) getHeight:(NSAttributedString *) attrStr{
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-150, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return rect.size.height;
}

-(NSMutableAttributedString *)  formattMessage:(NSString *)time message:(NSString *) message isSender:(BOOL)isSender{
    
    UIColor * colorDate=[UIColor whiteColor];
    UIColor * msgColor=[UIColor whiteColor];
    if (!isSender) {
        colorDate=[UIColor lightGrayColor];
        msgColor=[UIColor colorNamed:@"color_app_label"];
    }
    NSMutableAttributedString *attributedTime = [[NSMutableAttributedString alloc] initWithString:time];
    [attributedTime addAttribute:NSForegroundColorAttributeName value:colorDate range:NSMakeRange(0, time.length)];
    NSMutableAttributedString *finalText = [[NSMutableAttributedString alloc]initWithString:message];
    [finalText addAttribute:NSFontAttributeName value:FONTS_THEME_REGULAR_NO_SCALE(15) range:NSMakeRange(0, message.length)];
    
    [finalText addAttribute:NSForegroundColorAttributeName value:msgColor range:NSMakeRange(0, message.length)];
    
    NSAttributedString *space = [[NSAttributedString alloc]initWithString:@"\n"];
    [finalText appendAttributedString:space];
    [finalText appendAttributedString:attributedTime];
    return finalText;
}

#pragma mark - Load previous methods

- (void)loadMoreMessages {
    if (self.arrChats.count==0) {
        [self.refreshControl endRefreshing];
        return;
    }
    NSString *firstKey = [[self.arrChats firstObject] key];
    [fireModel loadPreviousChatsWithKey:firstKey withCompletionBlock:^(id result, NSError *error) {
        FIRDataSnapshot *snapshot = (FIRDataSnapshot *)result;
        if (snapshot.exists) {
            NSInteger count = 0;
            NSMutableArray *newPage = [NSMutableArray new];
            for (FIRDataSnapshot *child in snapshot.children) {
                // Ignore last object because this is duplicate of last page
                if (count == snapshot.childrenCount - 1) {
                    break;
                }
                count += 1;
                [newPage addObject:child];
            }
            
            self->lastMessageKey = [[snapshot.children.allObjects firstObject] key];
            // Insert new messages at top of old array
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [newPage count])];
            [self.arrChats insertObjects:newPage atIndexes:indexes];
            [self.tableView reloadData];
        }else {
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}



#pragma mark - Handle methods
- (IBAction)handleChatPost:(UIButton *)sender {
    NSString *text = [self.txtChatMessage.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(text.length==0) {
        return;
    }
    NSDictionary * dict=defaults_object(P_USER_DICT);
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data[@"timeStamp"] = [FIRServerValue timestamp];
    data[@"text"] = text;
    data[@"user_name"] = [dict objectForKey:@"d_name"];
    data[@"isUser"] = @(NO) ;
    data[@"is_read"] = [NSNumber numberWithBool:NO] ;
    data[@"trip_id"] = self.tripID ;
    data[@"id"] = [dict objectForKey:P_DRIVER_ID];
    data[@"from"] = [dict objectForKey:P_FIRE_ID];
    data[@"to"] = isEmpty(self.tripModel.user.fire_id);
    // clear text
    self.txtChatMessage.text = @"";
    [self.viewChatBottom setConstraintConstant:50 forAttribute:NSLayoutAttributeHeight];
    // Push data to Firebase Database
    [fireModel sendChat:data withCompletion:^(id result, NSError *error) {
        
        if (error == nil) {
            [self.tripModel sendChatNotificationToUser:text];
            [self scrollToBottom_animated:YES];
        }
        else {
            // not posted
        }
    }];
}





- (IBAction)handleBack:(id)sender {
    if ([self isModal])
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
    
}



- (BOOL)isModal {
    if([self presentingViewController])
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}

#pragma mark - Helper methods
- (void)scrollToBottom_animated:(BOOL)animate {
    if([self.arrChats count]==0) {
        return;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.arrChats count]-1   inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    
}



-(void)configureVC{
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    self.arrChats = [[NSMutableArray alloc] init];
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

@end


