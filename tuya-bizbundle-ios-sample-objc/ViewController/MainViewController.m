//
//  MainViewController.m
//  tuya-bizbundle-ios-sample-objc
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "MainViewController.h"
#import "UIButton+Extensions.h"

@interface MainViewController ()
// MARK: - IBOutlet
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIStackView *actionStackView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation MainViewController

static UIColor *MainPageColorFromHex(NSString *hexString) {
    NSString *cleanHex = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    unsigned int rgbValue = 0;
    [[NSScanner scannerWithString:cleanHex] scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue >> 16) & 0xFF) / 255.0
                           green:((rgbValue >> 8) & 0xFF) / 255.0
                            blue:(rgbValue & 0xFF) / 255.0
                           alpha:1.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.backButtonTitle = @"";
    if (@available(iOS 14.0, *)) {
        self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
    }
    [self configureView];
}

- (void)configureView {
    UIColor *pageBackgroundColor = MainPageColorFromHex(@"#F2F4F7");
    UIColor *brandColor = MainPageColorFromHex(@"#1F6BFF");
    UIColor *primaryTextColor = MainPageColorFromHex(@"#111827");
    UIColor *secondaryTextColor = MainPageColorFromHex(@"#6B7280");

    self.view.backgroundColor = pageBackgroundColor;
    self.actionStackView.spacing = 16.0;

    [self.loginButton roundCorner];
    self.loginButton.layer.cornerRadius = 14.0;
    self.loginButton.backgroundColor = brandColor;
    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
    [self.loginButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];

    [self.registerButton roundCorner];
    self.registerButton.layer.cornerRadius = 14.0;
    self.registerButton.backgroundColor = UIColor.whiteColor;
    self.registerButton.layer.borderWidth = 1.0;
    self.registerButton.layer.borderColor = [brandColor colorWithAlphaComponent:0.28].CGColor;
    self.registerButton.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
    [self.registerButton setTitleColor:primaryTextColor forState:UIControlStateNormal];

    self.versionLabel.textColor = secondaryTextColor;
    self.versionLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];

    UILabel *heroTitle = [[UILabel alloc] init];
    heroTitle.translatesAutoresizingMaskIntoConstraints = NO;
    heroTitle.text = @"涂鸦智能";
    heroTitle.textColor = primaryTextColor;
    heroTitle.font = [UIFont systemFontOfSize:34.0 weight:UIFontWeightSemibold];

    UILabel *heroSubtitle = [[UILabel alloc] init];
    heroSubtitle.translatesAutoresizingMaskIntoConstraints = NO;
    heroSubtitle.text = @"连接设备，掌控你的家";
    heroSubtitle.textColor = secondaryTextColor;
    heroSubtitle.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightRegular];

    [self.view addSubview:heroTitle];
    [self.view addSubview:heroSubtitle];

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [heroTitle.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor constant:32.0],
        [heroTitle.trailingAnchor constraintLessThanOrEqualToAnchor:safeArea.trailingAnchor constant:-32.0],
        [heroTitle.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:44.0],

        [heroSubtitle.leadingAnchor constraintEqualToAnchor:heroTitle.leadingAnchor],
        [heroSubtitle.trailingAnchor constraintLessThanOrEqualToAnchor:safeArea.trailingAnchor constant:-32.0],
        [heroSubtitle.topAnchor constraintEqualToAnchor:heroTitle.bottomAnchor constant:10.0]
    ]];
}

@end
