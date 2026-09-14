//
//  CounrySelectionView.m
//  Conrra
//
//  Fully programmatic redesign — full-screen modal with emoji flags and clean design.
//

#import "CounrySelectionView.h"
#import "WebCallConstants.h"
#import "Utilities.h"
#import "UIView+UpdateAutoLayoutConstraints.h"

@implementation CounrySelectionView {
    NSArray           *arrCountrySearch;
    NSArray           *arrCountry;
    CounrySelectionView *rootViewTemp;
}

#pragma mark - Programmatic build

- (void)buildProgrammaticUI {
    self.backgroundColor = [UIColor whiteColor];

    arrCountry       = [self JSONFromFile];
    arrCountrySearch = [NSArray arrayWithArray:arrCountry];

    CGFloat sw      = self.bounds.size.width;
    CGFloat sh      = self.bounds.size.height;
    CGFloat statusH = UIApplication.sharedApplication.statusBarFrame.size.height;
    if (statusH < 20) statusH = 20;

    UIColor *darkText  = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    UIColor *grayText  = [UIColor colorWithRed:0.502f green:0.502f blue:0.502f alpha:1.0f];
    UIColor *searchBg  = [UIColor colorWithRed:0.945f green:0.945f blue:0.945f alpha:1.0f];
    UIColor *sepColor  = [UIColor colorWithRed:0.922f green:0.922f blue:0.922f alpha:1.0f];

    // ── Header ────────────────────────────────────────────────────────────────
    CGFloat headerH = statusH + 56.0f;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, headerH)];
    header.backgroundColor = [UIColor whiteColor];
    [self addSubview:header];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text      = @"Código de País";
    titleLbl.font      = [UIFont fontWithName:@"NotoSans-Bold" size:17] ?: [UIFont boldSystemFontOfSize:17];
    titleLbl.textColor = darkText;
    [titleLbl sizeToFit];
    titleLbl.center = CGPointMake(sw / 2.0f, statusH + 28.0f);
    [header addSubview:titleLbl];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(sw - 52.0f, statusH + 6.0f, 44.0f, 44.0f);
    UIImage *xIcon = [[UIImage systemImageNamed:@"xmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (xIcon) {
        [closeBtn setImage:xIcon forState:UIControlStateNormal];
        closeBtn.tintColor = darkText;
    } else {
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:darkText forState:UIControlStateNormal];
    }
    [closeBtn addTarget:self action:@selector(onCloseButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeBtn];

    UIView *headerBorder = [[UIView alloc] initWithFrame:CGRectMake(0, headerH - 1, sw, 1)];
    headerBorder.backgroundColor = sepColor;
    [header addSubview:headerBorder];

    // ── Search bar ────────────────────────────────────────────────────────────
    CGFloat searchAreaH = 64.0f;
    UIView *searchArea = [[UIView alloc] initWithFrame:CGRectMake(0, headerH, sw, searchAreaH)];
    searchArea.backgroundColor = [UIColor whiteColor];
    [self addSubview:searchArea];

    UIView *searchBox = [[UIView alloc] initWithFrame:CGRectMake(16, 10, sw - 32, 44)];
    searchBox.backgroundColor    = searchBg;
    searchBox.layer.cornerRadius = 12;
    [searchArea addSubview:searchBox];

    UIImageView *magIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 20, 20)];
    UIImage *magImg = [[UIImage systemImageNamed:@"magnifyingglass"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    magIcon.image       = magImg;
    magIcon.tintColor   = grayText;
    magIcon.contentMode = UIViewContentModeScaleAspectFit;
    [searchBox addSubview:magIcon];

    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, sw - 32 - 52, 44)];
    tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Buscar país"
        attributes:@{ NSForegroundColorAttributeName: grayText,
                      NSFontAttributeName: [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15] }];
    tf.font             = [UIFont fontWithName:@"NotoSans-Regular" size:15] ?: [UIFont systemFontOfSize:15];
    tf.textColor        = darkText;
    tf.clearButtonMode  = UITextFieldViewModeWhileEditing;
    tf.returnKeyType    = UIReturnKeyDone;
    tf.delegate         = self;
    [tf addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [searchBox addSubview:tf];
    self.txtSeach = tf;

    // ── Table view ────────────────────────────────────────────────────────────
    CGFloat tableY = headerH + searchAreaH;
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY, sw, sh - tableY)
                                                   style:UITableViewStylePlain];
    tv.delegate              = self;
    tv.dataSource            = self;
    tv.backgroundColor       = [UIColor whiteColor];
    tv.separatorStyle        = UITableViewCellSeparatorStyleNone;
    tv.keyboardDismissMode   = UIScrollViewKeyboardDismissModeOnDrag;
    [tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CC"];
    [self addSubview:tv];
    self.tableView = tv;

    [tv reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Show (class method)

+ (void)showCountrySelectionViewWithDelegate:(id<CounrySelectionViewDelegate>)delegate
                                  parentView:(UIView *)parentView
                                       label:(UILabel *)label {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) window = UIApplication.sharedApplication.windows.firstObject;

    CounrySelectionView *view = [[CounrySelectionView alloc] initWithFrame:window.bounds];
    view->rootViewTemp = view;
    view.label         = delegate ? label : nil;
    view.delegate      = delegate;
    [view buildProgrammaticUI];

    view.transform = CGAffineTransformMakeTranslation(0, window.bounds.size.height);
    [window addSubview:view];
    [UIView animateWithDuration:0.38 delay:0 usingSpringWithDamping:0.88 initialSpringVelocity:0
                        options:0 animations:^{ view.transform = CGAffineTransformIdentity; }
                     completion:nil];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (@available(iOS 11.0, *)) {
        UIWindow *win = UIApplication.sharedApplication.windows.firstObject;
        height -= win.safeAreaInsets.bottom;
    }
    NSTimeInterval dur = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:dur > 0 ? dur : 0.25 animations:^{
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, height, 0);
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval dur = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:dur > 0 ? dur : 0.25 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

#pragma mark - Dismiss

- (void)dismissAnimated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [UIView animateWithDuration:0.28 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    } completion:^(BOOL finished) {
        [self->rootViewTemp removeFromSuperview];
    }];
}

- (IBAction)onCloseButtonTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onCloseView)]) {
        [self.delegate onCloseView];
    }
    [self dismissAnimated];
}

#pragma mark - TextField

- (IBAction)textFieldFinished:(id)sender { [(UITextField *)sender resignFirstResponder]; }

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    arrCountrySearch = [NSArray arrayWithArray:arrCountry];
    [self.tableView reloadData];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != self.txtSeach) return YES;
    if ([string isEqualToString:@"\n"]) return YES;

    NSString *proposed = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (proposed.length > 0) {
        NSPredicate *p1 = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", proposed];
        arrCountrySearch = [arrCountry filteredArrayUsingPredicate:p1];
        if (!arrCountrySearch.count) {
            NSPredicate *p2 = [NSPredicate predicateWithFormat:@"self.code contains[c] %@", proposed];
            arrCountrySearch = [arrCountry filteredArrayUsingPredicate:p2];
        }
        if (!arrCountrySearch.count) {
            NSPredicate *p3 = [NSPredicate predicateWithFormat:@"self.dial_code contains[c] %@", proposed];
            arrCountrySearch = [arrCountry filteredArrayUsingPredicate:p3];
        }
        [self.tableView setContentOffset:CGPointZero animated:NO];
        [self.tableView reloadData];
    } else {
        arrCountrySearch = [NSArray arrayWithArray:arrCountry];
        [self.tableView reloadData];
    }
    return YES;
}

#pragma mark - TableView datasource / delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)arrCountrySearch.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CC" forIndexPath:indexPath];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];

    for (UIView *v in cell.contentView.subviews) [v removeFromSuperview];

    NSDictionary *dict = arrCountrySearch[(NSUInteger)indexPath.row];
    CGFloat sw = tableView.bounds.size.width;

    UIColor *darkText = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
    UIColor *grayText = [UIColor colorWithRed:0.502f green:0.502f blue:0.502f alpha:1.0f];
    UIColor *sepColor = [UIColor colorWithRed:0.922f green:0.922f blue:0.922f alpha:1.0f];

    // Emoji flag
    NSString *flag = [[self class] flagEmojiForCode:dict[@"code"]];
    UILabel *flagLbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 36, 60)];
    flagLbl.text          = flag.length ? flag : @"🏳";
    flagLbl.font          = [UIFont systemFontOfSize:26];
    flagLbl.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:flagLbl];

    // Country name
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, sw - 60 - 72, 20)];
    nameLbl.text                    = dict[@"name"];
    nameLbl.font                    = [UIFont fontWithName:@"NotoSans-Regular" size:14] ?: [UIFont systemFontOfSize:14];
    nameLbl.textColor               = darkText;
    nameLbl.adjustsFontSizeToFitWidth = YES;
    nameLbl.minimumScaleFactor      = 0.8f;
    [cell.contentView addSubview:nameLbl];

    // ISO code subtitle
    UILabel *codeLbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 32, sw - 60 - 72, 16)];
    codeLbl.text      = dict[@"code"];
    codeLbl.font      = [UIFont fontWithName:@"NotoSans-Regular" size:12] ?: [UIFont systemFontOfSize:12];
    codeLbl.textColor = grayText;
    [cell.contentView addSubview:codeLbl];

    // Dial code (right-aligned)
    UILabel *dialLbl = [[UILabel alloc] initWithFrame:CGRectMake(sw - 70, 0, 62, 60)];
    dialLbl.text          = dict[@"dial_code"];
    dialLbl.font          = [UIFont fontWithName:@"NotoSans-Bold" size:14] ?: [UIFont boldSystemFontOfSize:14];
    dialLbl.textColor     = grayText;
    dialLbl.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:dialLbl];

    // Separator
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(16, 59, sw - 32, 1)];
    sep.backgroundColor = sepColor;
    [cell.contentView addSubview:sep];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = arrCountrySearch[(NSUInteger)indexPath.row];
    [self showLabelText:dict];
    [self.delegate onCountrySelction:dict];
    [self dismissAnimated];
}

#pragma mark - Label update

- (void)showLabelText:(NSDictionary *)countryDict {
    NSString *flag = [[self class] flagEmojiForCode:countryDict[@"code"]];
    NSString *text = [NSString stringWithFormat:@"%@ %@ ", flag, countryDict[@"dial_code"]];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    NSTextAttachment *chevron = [[NSTextAttachment alloc] init];
    UIImage *chevronImg = [Utilities imageWithImage:[UIImage imageNamed:@"drop-down-arrow"] scaledToWidth:24];
    chevron.image = chevronImg;
    [chevron setBounds:CGRectMake(4, -2, 12, 12)];
    [attr appendAttributedString:[NSAttributedString attributedStringWithAttachment:chevron]];
    self.label.attributedText = attr;
    int width = (int)[attr size].width + 20;
    [self.label setConstraintConstant:width forAttribute:NSLayoutAttributeWidth];
}

#pragma mark - Class / static helpers

+ (NSString *)flagEmojiForCode:(NSString *)code {
    if (code.length != 2) return @"";
    NSString *upper = code.uppercaseString;
    uint32_t cp1 = 0x1F1E6 + ([upper characterAtIndex:0] - 'A');
    uint32_t cp2 = 0x1F1E6 + ([upper characterAtIndex:1] - 'A');
    uint16_t s1h = (uint16_t)(((cp1 - 0x10000) >> 10)   | 0xD800);
    uint16_t s1l = (uint16_t)(((cp1 - 0x10000) & 0x3FF) | 0xDC00);
    uint16_t s2h = (uint16_t)(((cp2 - 0x10000) >> 10)   | 0xD800);
    uint16_t s2l = (uint16_t)(((cp2 - 0x10000) & 0x3FF) | 0xDC00);
    unichar chars[] = {s1h, s1l, s2h, s2l};
    return [NSString stringWithCharacters:chars length:4];
}

+ (NSAttributedString *)getCurrentCountry {
    return [self getCurrentCountryWithCountryCode:@"VE"];
}

+ (NSAttributedString *)getCurrentCountryWithCountryCode:(NSString *)countryCode {
    NSArray *array = [self loadCountryArray];
    for (NSDictionary *d in array) {
        if (![countryCode isEqualToString:d[@"code"]]) continue;
        NSString *flag = [self flagEmojiForCode:d[@"code"]];
        NSString *text = [NSString stringWithFormat:@"%@ %@ ", flag, d[@"dial_code"]];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
        NSTextAttachment *chevron = [[NSTextAttachment alloc] init];
        UIImage *chevronImg = [Utilities imageWithImage:[UIImage imageNamed:@"drop-down-arrow"] scaledToWidth:24];
        chevron.image = chevronImg;
        [chevron setBounds:CGRectMake(4, -2, 12, 12)];
        [attr appendAttributedString:[NSAttributedString attributedStringWithAttachment:chevron]];
        return attr;
    }
    return [[NSMutableAttributedString alloc] initWithString:@"Select"];
}

+ (NSDictionary *)getCurrentCountryDict {
    return [self getCurrentCountryDictWithCountryCode:@"VE"];
}

+ (NSDictionary *)getCurrentCountryDictWithCountryCode:(NSString *)countryCode {
    for (NSDictionary *d in [self loadCountryArray]) {
        if ([countryCode isEqualToString:d[@"code"]]) return d;
    }
    return nil;
}

+ (NSDictionary *)getCurrentCountryDictWithDialCode:(NSString *)dialCode {
    for (NSDictionary *d in [self loadCountryArray]) {
        if ([dialCode isEqualToString:d[@"dial_code"]]) return d;
    }
    return nil;
}

+ (NSDictionary *)getCurrentCountryDictWithIsoCode:(NSString *)isocode {
    for (NSDictionary *d in [self loadCountryArray]) {
        if ([[isocode uppercaseString] isEqualToString:d[@"code"]]) return d;
    }
    return nil;
}

+ (NSArray *)loadCountryArray {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CountryCodes" ofType:@"json"];
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path]
                                          options:0 error:nil];
}

- (NSArray *)JSONFromFile {
    return [[self class] loadCountryArray];
}

@end
