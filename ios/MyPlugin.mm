#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WeAppNativePlugin.framework/WeAppNativePlugin.h"
#import "MyPlugin.h"
#import <WebKit/WebKit.h>

#define MCOLOR(colorName) [self colorWithHexString:colorName alpha:1.0] // MCOLOR(@"#lightColor,#darkColor")

@implementation UIView (ViewFrameGeometry)

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newwidth {
    if (isnan(newwidth)) {
        return;
    }

    CGRect newframe = self.frame;
    newframe.size.width = newwidth;
    self.frame = newframe;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    if (isnan(centerX)) {
        return;
    }

    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    if (isnan(centerY)) {
        return;
    }

    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)newleft {
    if (isnan(newleft)) {
        return;
    }

    CGRect newframe = self.frame;
    newframe.origin.x = newleft;
    self.frame = newframe;
}

- (void)setHeight:(CGFloat)newheight {
    if (isnan(newheight)) {
        return;
    }

    CGRect newframe = self.frame;
    newframe.size.height = newheight;
    self.frame = newframe;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newtop {
    if (isnan(newtop)) {
        return;
    }

    CGRect newframe = self.frame;
    newframe.origin.y = newtop;
    self.frame = newframe;
}

- (void)setSize:(CGSize)aSize {
    if (isnan(aSize.width) || isnan(aSize.height)) {
        return;
    }

    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)newbottom {
    if (isnan(newbottom)) {
        return;
    }

    CGRect newframe = self.frame;
    newframe.origin.y = newbottom - self.frame.size.height;
    self.frame = newframe;
}

@end

@implementation UILabel (ExtendLabel)

- (CGFloat)calcLineSpacing {
    // 1.4倍行距
    return self.font.pointSize * 1.4 - self.font.lineHeight;
}

@end

@implementation NSString (Size)

- (CGSize)stringSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    return [self stringSizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode lineSpacing:CGFLOAT_MIN];
}

- (CGSize)stringSizeWithFont:(UIFont *)font
           constrainedToSize:(CGSize)size
               lineBreakMode:(NSLineBreakMode)lineBreakMode
                 lineSpacing:(CGFloat)lineSpacing {
    return [self stringSizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode lineSpacing:lineSpacing alignment:NSTextAlignmentNatural];
}

- (CGSize)stringSizeWithFont:(UIFont *)font
           constrainedToSize:(CGSize)size
               lineBreakMode:(NSLineBreakMode)lineBreakMode
                 lineSpacing:(CGFloat)lineSpacing
                   alignment:(NSTextAlignment)alignment {
    if (font == nil) {
        return CGSizeZero;
    }

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    style.alignment = alignment;
    if (lineSpacing != CGFLOAT_MIN && lineSpacing > 0) {
        style.lineSpacing = lineSpacing;
    }

    NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
    CGSize estimatedSize = CGSizeZero;
    
    estimatedSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;

    CGSize labelSize = estimatedSize;
    //这里文本高度计算会偶现超出给定的高度，这里加个限制
    labelSize = CGSizeMake(ceilf(labelSize.width), MIN(ceilf(labelSize.height), size.height));
    return labelSize;
}

@end

@interface MyPlugin () {
    UIButton *_backgroundRoot;
    UIView *_contentView;
    UILabel *_tipsTitleLabel;
    UITextView *_tipsContentLabel;
}

@property (atomic) void (^callback)(BOOL agreed);

@property (nonatomic, weak) UIViewController * curVC;

@property (nonatomic, weak) UIView * alertView;

@property (nonatomic, weak) UIView *view;

@property (nonatomic, weak) UIView *alignView;

@end

__attribute__((constructor))
static void initPlugin() {
    [MyPlugin registerPluginAndInit:[[MyPlugin alloc] init]];
};

@implementation MyPlugin

// 声明插件ID
WEAPP_DEFINE_PLUGIN_ID(wx45xxxxxxxxxxx)

// 插件初始化方法，在注册插件后会被自动调用
- (void)initPlugin {
    NSLog(@"initPlugin");
    [self registerAppDelegateMethod:@selector(application:openURL:options:)];
    [self registerAppDelegateMethod:@selector(application:continueUserActivity:restorationHandler:)];
}

- (void)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    NSLog(@"url scheme");
}

- (void)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> *__nullable restorableObjects))restorationHandler {
    NSLog(@"universal link");
}

- (void)showPrivacyDialogWithCallback:(UIViewController *)curVC configs:(NSDictionary *)configs callback:(void (^)(BOOL))callback {
    
    self.callback = callback;
    
    _view = curVC.view;
    _alignView = curVC.view;
    
    // 设置基础的图层
    CGPoint pt = CGPointMake(0, 0);
    CGPoint ptNew = [_alignView convertPoint:pt toView:_view];
    _backgroundRoot = [[UIButton alloc] initWithFrame:CGRectMake(ptNew.x, ptNew.y, _alignView.width, _alignView.height)];
    _backgroundRoot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _backgroundRoot.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    _backgroundRoot.isAccessibilityElement = NO;
    
    
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = MIN(320, screenWidth - 32);
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
    _contentView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
                                     | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    NSString* backgroundColorStr = configs[@"styles"][@"backgroundColor"];
    _contentView.backgroundColor = [self colorWithHexString:backgroundColorStr alpha: 1.0];
    
    CGFloat cornerRadius = [configs[@"styles"][@"borderRadius"] doubleValue];
    _contentView.layer.cornerRadius = cornerRadius;

    BOOL dialogShowLine = [configs[@"styles"][@"showLine"] boolValue];

    [_backgroundRoot addSubview:_contentView];
    _contentView.centerX = _backgroundRoot.width / 2;
    _contentView.centerY = _backgroundRoot.height / 2;
    [_backgroundRoot setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_view addSubview:_backgroundRoot];
    
    // 内容区
    NSString *content = configs[@"message"];
    NSString *contentColor = configs[@"styles"][@"message"][@"color"];
    NSString *messageLinkColor = configs[@"styles"][@"messageLinks"][@"color"];

    _tipsContentLabel = [[UITextView alloc] init];
    [_contentView addSubview:_tipsContentLabel];
    _tipsContentLabel.editable = NO;
    _tipsContentLabel.selectable = NO;
    _tipsContentLabel.backgroundColor = [UIColor clearColor];
    _tipsContentLabel.attributedText = [self bulidNSAttributedStringContent:content contentColor:contentColor contentInfos:configs[@"messageLinks"] messageLinkColor:messageLinkColor];
#ifdef __IPHONE_16_0
    // iOS16 BUG allowsNonContiguousLayout默认值应为NO tapd: https://tapd.woa.com/weixin_iPhone/bugtrace/bugs/view?bug_id=1010031531102037309
    if (@available(iOS 16.0, *)) {
        _tipsContentLabel.layoutManager.allowsNonContiguousLayout = NO;
    }
#endif
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapLink:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [_tipsContentLabel addGestureRecognizer:tapRecognizer];
    
    // 标题
    NSString *title = configs[@"title"];
    NSString *titleColor = configs[@"styles"][@"title"][@"color"];
    _tipsTitleLabel = [[UILabel alloc] init];
    _tipsTitleLabel.text = @"janzenzhang";
    _tipsTitleLabel.textColor = [self colorWithHexString:titleColor alpha:1];
    
    _tipsTitleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightBold]; // style.css
    _tipsTitleLabel.textAlignment = NSTextAlignmentCenter;
    _tipsTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_contentView addSubview:_tipsTitleLabel];

    // 设置按钮
    [self updateSubViewsFrame:configs];

    // 取消按钮
    NSString *cancel = configs[@"cancel"];
    NSString *cancelBtnColor = configs[@"styles"][@"cancelButton"][@"color"];
    NSString *cancelButtonBackgroundColor = configs[@"styles"][@"cancelButton"][@"backgroundColor"];
    CGFloat f_cancelButtonLeft = [configs[@"styles"][@"cancelButton"][@"left"] doubleValue];
    CGFloat f_cancelButtonTop = [configs[@"styles"][@"cancelButton"][@"top"] doubleValue];
    CGFloat f_cancelButtonWidth = [configs[@"styles"][@"cancelButton"][@"width"] doubleValue];
    CGFloat f_cancelButtonHeight = [configs[@"styles"][@"cancelButton"][@"height"] doubleValue];
    CGFloat f_cancelButtonCornerRadius = [configs[@"styles"][@"cancelButton"][@"borderRadius"] doubleValue];
    UIButton *cancelBtn = nil;
    if (cancel) {
        cancelBtn = [_contentView viewWithTag:PRIVACY_DIALOG_CANCEL_TAG];
        if (!cancelBtn) {
            cancelBtn = [[UIButton alloc] init];
            [cancelBtn setTitle:cancel forState:UIControlStateNormal];
            cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
            UIColor *_cancelBtnColor = [self colorWithHexString:cancelBtnColor alpha:1.0];
            [cancelBtn setTitleColor:_cancelBtnColor forState:UIControlStateNormal];
            [cancelBtn addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
        }
//        cancelBtn.frame = CGRectMake(0, _contentView.height, _contentView.width / 2, 0);
        if (cancelButtonBackgroundColor != @(NO) && [cancelButtonBackgroundColor length] > 0) {
            cancelBtn.backgroundColor = [self colorWithHexString:cancelButtonBackgroundColor alpha:1.0];
        }
        
        cancelBtn.layer.cornerRadius = f_cancelButtonCornerRadius;
        
        cancelBtn.frame = CGRectMake(
                                    f_cancelButtonLeft,
                                    f_cancelButtonTop == 0 ? _contentView.height : f_cancelButtonTop,
                                    f_cancelButtonWidth == 0 ? _contentView.width / 2 : f_cancelButtonWidth,
                                    f_cancelButtonHeight == 0 ? 50 : f_cancelButtonHeight
                                    );
        cancelBtn.tag = PRIVACY_DIALOG_CANCEL_TAG;
        [_contentView addSubview:cancelBtn];
        if (dialogShowLine) {
            UIView *vlineView = [[UIView alloc] init];
            vlineView.frame = CGRectMake(cancelBtn.width, 0, (1.0 / [UIScreen mainScreen].scale), cancelBtn.height);
            vlineView.backgroundColor = [self colorWithHexString:@"#000000" alpha:0.5]; //MCOLORX(@"#MMTipsView", @"line_color");
            [cancelBtn addSubview:vlineView];
        }
        
        UIImage *cancelImage = [UIImage imageNamed:@"privacy_cancelButtonImage"];
        if (cancelImage != nil && cancelImage.CGImage != nil) {
            cancelBtn.layer.contents = (id)cancelImage.CGImage;
            cancelBtn.layer.contentsGravity = kCAGravityResize;
        }
    }

    // 确认按钮
    NSString *confirm = configs[@"confirm"];
    NSString *confirmBtnColor = configs[@"styles"][@"confirmButton"][@"color"];
    NSString *confirmButtonBackgroundColor = configs[@"styles"][@"confirmButton"][@"backgroundColor"];
    CGFloat f_confirmButtonLeft = [configs[@"styles"][@"confirmButton"][@"left"] doubleValue];
    CGFloat f_confirmButtonTop = [configs[@"styles"][@"confirmButton"][@"top"] doubleValue];
    CGFloat f_confirmButtonWidth = [configs[@"styles"][@"confirmButton"][@"width"] doubleValue];
    CGFloat f_confirmButtonHeight = [configs[@"styles"][@"confirmButton"][@"height"] doubleValue];
    CGFloat f_confirmButtonCornerRadius = [configs[@"styles"][@"confirmButton"][@"borderRadius"] doubleValue];
    UIButton *confirmBtn = [_contentView viewWithTag:PRIVACY_DIALOG_CONFIRM_TAG];
    if (!confirmBtn) {
        confirmBtn = [[UIButton alloc] init];

        [confirmBtn setTitle:confirm forState:UIControlStateNormal];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        UIColor *_confirmBtnColor = [self colorWithHexString:confirmBtnColor alpha:1.0];
        [confirmBtn setTitleColor:_confirmBtnColor forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
//    confirmBtn.frame = CGRectMake(cancelBtn.right, _contentView.height, cancel ? _contentView.width / 2 : _contentView.width, 0);
    confirmBtn.frame = CGRectMake(
                                f_confirmButtonLeft == 0 ? cancelBtn.right : f_confirmButtonLeft,
                                f_confirmButtonTop == 0 ? _contentView.height : f_confirmButtonTop,
                                f_confirmButtonWidth == 0 ? _contentView.width / 2 : f_confirmButtonWidth,
                                f_confirmButtonHeight == 0 ? 50 : f_confirmButtonHeight
                                );
    
    confirmBtn.layer.cornerRadius = f_confirmButtonCornerRadius;
    
    if (confirmButtonBackgroundColor != @(NO) && [confirmButtonBackgroundColor length] > 0) {
        confirmBtn.backgroundColor = [self colorWithHexString:confirmButtonBackgroundColor alpha:1.0];
    }

    confirmBtn.tag = PRIVACY_DIALOG_CONFIRM_TAG;
    [_contentView addSubview:confirmBtn];
    CGFloat cbHeight = confirmBtn.height;
    CGFloat cvHeight = _contentView.height;
    _contentView.height += confirmBtn.height;
    _contentView.top = (_backgroundRoot.height - _contentView.height) / 2;
    
    UIImage *confirmImage = [UIImage imageNamed:@"privacy_confirmButtonImage"];
    if (confirmImage != nil && confirmImage.CGImage != nil) {
        confirmBtn.layer.contents = (id)confirmImage.CGImage;
        confirmBtn.layer.contentsGravity = kCAGravityResize;
    }
    
    // 设置弹窗的宽高位置
    CGFloat f_contentViewLeft = [configs[@"styles"][@"left"] doubleValue];
    CGFloat f_contentViewTop = [configs[@"styles"][@"top"] doubleValue];
    CGFloat f_contentViewWidth = [configs[@"styles"][@"width"] doubleValue];
    CGFloat f_contentViewHeight = [configs[@"styles"][@"height"] doubleValue];
    if (f_contentViewLeft != 0) {
        _contentView.left = f_contentViewLeft;
    }
    if (f_contentViewTop != 0) {
        _contentView.top = f_contentViewTop;
    }
    if (f_contentViewWidth != 0) {
        _contentView.width = f_contentViewWidth;
    }
    if (f_contentViewHeight != 0) {
        _contentView.height = f_contentViewHeight;
    }
    
    UIImage *image = [UIImage imageNamed:@"privacy_contentViewImage"];
    if (image != nil && image.CGImage != nil) {
        _contentView.layer.contents = (id)image.CGImage;
        _contentView.layer.contentsGravity = kCAGravityResize;
    }
}

- (void)closeAlertView {
    
    [self.alertView removeFromSuperview];
    // 关掉自己
    self.callback(YES);
}

- (UIColor *)colorWithHexString:(NSString *)hexColor alpha:(float)opacity{
    NSString * cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString * rString = [cString substringWithRange:range];
    range.location = 2;
    NSString * gString = [cString substringWithRange:range];
    range.location = 4;
    NSString * bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:opacity];
}

- (void)updateSubViewsFrame:(NSDictionary *)config {
    // Title
    UIFont *titleFont = [UIFont systemFontOfSize:17.0 weight:UIFontWeightBold]; // style.css
    // title的宽度
    NSNumber* n_titleWidth = config[@"styles"][@"title"][@"width"];
    CGFloat f_titleWidth = [n_titleWidth doubleValue];
    
    if (f_titleWidth == 0) {
        f_titleWidth = _contentView.width - 2 * 24;
    }
    // title的高度
    NSNumber* n_titleHeight = config[@"styles"][@"title"][@"height"];
    CGFloat f_titleHeight = [n_titleHeight doubleValue];
    if (f_titleHeight == 0) {
        f_titleHeight = ceil(titleFont.lineHeight);
    }
    UInt16 lineCount = [self labelNumberOfLines:_tipsTitleLabel.text maxWidth:f_titleWidth font:titleFont];
    if (lineCount > 1) {
        f_titleHeight += _tipsTitleLabel.calcLineSpacing + titleFont.lineHeight; //numberOfLines定为2，加一行的高度即可
    }
    if (_tipsTitleLabel.text.length == 0) {
        f_titleHeight = 0;
    }
    NSNumber* titleLeft = config[@"styles"][@"title"][@"left"];
    NSNumber* titleTop = config[@"styles"][@"title"][@"top"];
    NSString* titleBackgroundColor = config[@"styles"][@"title"][@"backgroundColor"];
    CGFloat titleCornerRadius = [config[@"styles"][@"title"][@"borderRadius"] doubleValue];
    CGFloat f_titleLeft = [titleLeft doubleValue];
    CGFloat f_titleTop = [titleTop doubleValue];
    _tipsTitleLabel.frame =
    CGRectMake(f_titleLeft, f_titleTop, f_titleWidth, f_titleHeight);
    if (titleBackgroundColor != @(NO) && [titleBackgroundColor length] > 0) {
        _tipsTitleLabel.backgroundColor = [self colorWithHexString:titleBackgroundColor alpha:1.0];
    }
    _tipsTitleLabel.layer.cornerRadius = titleCornerRadius;

    // Message
    NSNumber* messageLeft = config[@"styles"][@"message"][@"left"];
    NSNumber* messageTop = config[@"styles"][@"message"][@"top"];
    NSNumber* messageWidth = config[@"styles"][@"message"][@"width"];
    NSNumber* messageHeight = config[@"styles"][@"message"][@"height"];
    NSString* messageBackgroundColor = config[@"styles"][@"message"][@"backgroundColor"];
    CGFloat messageCornerRadius = [config[@"styles"][@"message"][@"borderRadius"] doubleValue];
    CGFloat f_messageLeft = [messageLeft doubleValue];
    CGFloat f_messageTop = [messageTop doubleValue];
    CGFloat f_messageHeight = [messageHeight doubleValue];
    CGFloat f_messageWidth = [messageWidth doubleValue];
    
    // message的宽高
    if (f_messageWidth == 0) {
        f_messageWidth = _contentView.width - 2 * 24.0;
    }
    _tipsContentLabel.size = CGSizeMake(f_messageWidth, 0);
    [_tipsContentLabel sizeToFit];
    if (f_messageHeight == 0) {
        // 如果字体的实际高度高于设定的高度
        CGFloat maxHeight = 200;
        _tipsContentLabel.scrollEnabled = (_tipsContentLabel.height > maxHeight);
        _tipsContentLabel.height = MIN(maxHeight, _tipsContentLabel.height);
    } else {
        // 如果字体的实际高度高于设定的高度
        _tipsContentLabel.scrollEnabled = (_tipsContentLabel.height > f_messageHeight);
        _tipsContentLabel.height = f_messageHeight;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    _tipsContentLabel.textAlignment = NSTextAlignmentCenter;
    if (f_messageTop != 0 || f_messageLeft != 0) {
        _tipsContentLabel.center = CGPointMake(f_messageLeft + (_tipsContentLabel.width / 2), f_messageTop + (_tipsContentLabel.height / 2));
    } else {
        _tipsContentLabel.center = CGPointMake(_contentView.width / 2,
                                               (_tipsTitleLabel.height == 0 ? 0 : 16.0) + _tipsTitleLabel.bottom
                                               + _tipsContentLabel.height / 2);
    }
    
    if (messageBackgroundColor != @(NO) && [messageBackgroundColor length] > 0) {
        _tipsContentLabel.backgroundColor = [self colorWithHexString:messageBackgroundColor alpha:1.0];
    }
    
    _tipsContentLabel.layer.cornerRadius = messageCornerRadius;

    _contentView.height = _tipsContentLabel.bottom + 20;
}

- (NSAttributedString *)bulidNSAttributedStringContent:(NSString *)str contentColor:(NSString *)contentColor contentInfos:(NSDictionary *)contentInfos messageLinkColor:(NSString*)messageLinkColor{
    if (str == nil) {
        return nil;
    }

    UIColor *textColor = MCOLOR(contentColor);
    UIFont *textFont = [UIFont systemFontOfSize:17.0];
    
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSMutableParagraphStyle *mps = [[NSMutableParagraphStyle alloc] init];
    mps.lineSpacing = 4.0;
    mps.paragraphSpacing = 4.0;
    mps.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName : textColor,
        NSFontAttributeName : textFont,
        NSParagraphStyleAttributeName: mps,
    };
    [attributedMessage addAttributes:attributes range:NSMakeRange(0, [attributedMessage length])];

    [contentInfos enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *link, BOOL *stop) {
        NSRange range = [attributedMessage.mutableString rangeOfString:key];
        while ([attributedMessage.mutableString rangeOfString:key].location != NSNotFound) {
            [attributedMessage replaceCharactersInRange:range withString:link[@"text"]];
            [attributedMessage addAttribute:@"link" value:link[@"url"] range:range];
            [attributedMessage addAttribute:NSForegroundColorAttributeName value:[self colorWithHexString:messageLinkColor alpha:1.0] range:NSMakeRange(range.location, [link[@"text"] length])];
            range = [attributedMessage.mutableString rangeOfString:key];
        }
    }];

    return attributedMessage;
}

- (void)onTapLink:(UITapGestureRecognizer *)gesture {
    UITextView *textView = (UITextView *)gesture.view;
    CGPoint location = [gesture locationInView:textView];
    UITextPosition *position = [textView closestPositionToPoint:location];
    NSDictionary *attributes = [textView textStylingAtPosition:position inDirection:UITextStorageDirectionForward];
    NSString *linkURLString = [attributes objectForKey:@"link"];
    if (linkURLString) {
        [self openWebviewWithUrl:linkURLString];
    }
}

- (void)openWebviewWithUrl:(NSString *)webViewURL {
    UIViewController *webViewController = [[UIViewController alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:webViewController.view.bounds];
    [webViewController.view addSubview:webView];
    NSCharacterSet *allowedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodedURL = [webViewURL stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    NSURL *url = [NSURL URLWithString:encodedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [[self currentViewController] presentViewController:webViewController animated:YES completion:nil];
}

- (void)onClickBtn:(UIButton *)sender {
    if (self.callback) {
        NSInteger tag = sender.tag;

        if (tag == PRIVACY_DIALOG_CONFIRM_TAG) {
            self.callback(YES);
            return;
        }
        if (tag == PRIVACY_DIALOG_CANCEL_TAG) {
            self.callback(NO);
            return;
        }
    }

    [UIView animateWithDuration:0.15
    animations:^{
        self->_backgroundRoot.alpha = 0;
    }
    completion:^(BOOL finished) {
        [self->_backgroundRoot removeFromSuperview];
    }];
}

- (NSUInteger)labelNumberOfLines:(NSString *)text maxWidth:(CGFloat)maxWidth font:(UIFont *)font {
    CGFloat lineHeight = [self labelLineHeight:font];
    CGFloat totleHeight = [self labelHeight:text maxWidth:maxWidth font:font];
    return (totleHeight + lineHeight - 1) / lineHeight;
}

- (CGFloat)labelLineHeight:(UIFont *)font {
    return ceil(font.lineHeight);
}

- (CGFloat)labelHeight:(NSString *)text maxWidth:(CGFloat)maxWidth font:(UIFont *)font {
    return [self labelHeight:text maxWidth:maxWidth maxHeight:MAXFLOAT font:font];
}

- (CGFloat)labelHeight:(NSString *)text maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight font:(UIFont *)font {
    if ([text length] == 0) {
        return 0;
    }
    CGSize expectedLabelSize = [text stringSizeWithFont:font
                                      constrainedToSize:CGSizeMake(maxWidth, ceil(maxHeight))
                                          lineBreakMode:NSLineBreakByCharWrapping];
    return ceil(expectedLabelSize.height);
}

- (UIViewController *)currentViewController {
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    return viewController;
}

@end
