//
//  LoginTableViewController.m
//  tuya-bizbundle-ios-sample-objc
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "LoginTableViewController.h"
#import "Alert.h"

static UIColor *LoginDemoColorFromHex(NSString *hexString) {
    NSString *cleanHex = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    unsigned int rgbValue = 0;
    [[NSScanner scannerWithString:cleanHex] scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue >> 16) & 0xFF) / 255.0
                           green:((rgbValue >> 8) & 0xFF) / 255.0
                            blue:(rgbValue & 0xFF) / 255.0
                           alpha:1.0];
}

static UIColor *LoginDemoBrandPrimaryColor(void) { return LoginDemoColorFromHex(@"#2F6BFF"); }
static UIColor *LoginDemoPageBackgroundColor(void) { return LoginDemoColorFromHex(@"#F7F9FC"); }
static UIColor *LoginDemoCardBackgroundColor(void) { return LoginDemoColorFromHex(@"#FFFFFF"); }
static UIColor *LoginDemoTextPrimaryColor(void) { return LoginDemoColorFromHex(@"#1B2430"); }
static UIColor *LoginDemoTextSecondaryColor(void) { return LoginDemoColorFromHex(@"#5B667A"); }
static UIColor *LoginDemoDividerColor(void) { return LoginDemoColorFromHex(@"#E6EBF2"); }

static const CGFloat LoginDemoCornerRadiusInput = 12.0;
static const CGFloat LoginDemoCornerRadiusCard = 16.0;
static const CGFloat LoginDemoCornerRadiusButton = 12.0;
static const CGFloat LoginDemoHorizontalPadding = 20.0;

@interface LoginTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.title = NSLocalizedString(@"Login", nil);
    self.view.backgroundColor = LoginDemoPageBackgroundColor();
    self.tableView.backgroundColor = LoginDemoPageBackgroundColor();
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionHeaderHeight = 10.0;
    self.tableView.sectionFooterHeight = 10.0;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    [self setupBrandHeader];
    [self styleTextField:self.countryCodeTextField];
    [self styleTextField:self.accountTextField];
    [self styleTextField:self.passwordTextField];
    [self styleLoginButton];
    [self styleForgetPasswordButton];
}

- (void)setupBrandHeader {
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 122.0)];
    header.backgroundColor = UIColor.clearColor;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LoginDemoHorizontalPadding, 24.0, width - LoginDemoHorizontalPadding * 2.0, 34.0)];
    titleLabel.text = @"欢迎回来";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightSemibold];
    titleLabel.textColor = LoginDemoTextPrimaryColor();

    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LoginDemoHorizontalPadding, 68.0, width - LoginDemoHorizontalPadding * 2.0, 20.0)];
    subtitleLabel.text = @"登录以继续使用智能家庭服务";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    subtitleLabel.textColor = LoginDemoTextSecondaryColor();

    [header addSubview:titleLabel];
    [header addSubview:subtitleLabel];
    self.tableView.tableHeaderView = header;
}

- (void)styleTextField:(UITextField *)textField {
    textField.backgroundColor = LoginDemoCardBackgroundColor();
    textField.textColor = LoginDemoTextPrimaryColor();
    textField.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    textField.layer.cornerRadius = LoginDemoCornerRadiusInput;
    textField.layer.borderWidth = 1.0;
    textField.layer.borderColor = LoginDemoDividerColor().CGColor;

    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 12.0, 44.0)];
    textField.leftView = leftPaddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)styleLoginButton {
    self.loginButton.backgroundColor = LoginDemoBrandPrimaryColor();
    [self.loginButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.loginButton.layer.cornerRadius = LoginDemoCornerRadiusButton;
    self.loginButton.layer.masksToBounds = YES;
}

- (void)styleForgetPasswordButton {
    [self.forgetPasswordButton setTitleColor:LoginDemoBrandPrimaryColor() forState:UIControlStateNormal];
    self.forgetPasswordButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = UIColor.clearColor;
    cell.contentView.backgroundColor = UIColor.clearColor;
    cell.textLabel.textColor = LoginDemoTextPrimaryColor();
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];

    CGFloat horizontalPadding = indexPath.section == 0 ? LoginDemoHorizontalPadding : 16.0;
    CGRect cardFrame = CGRectInset(cell.bounds, horizontalPadding, 3.0);
    UIView *cardBackground = [[UIView alloc] initWithFrame:cardFrame];
    cardBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cardBackground.backgroundColor = LoginDemoCardBackgroundColor();
    cardBackground.layer.cornerRadius = indexPath.section == 0 ? LoginDemoCornerRadiusCard : 14.0;
    cardBackground.layer.masksToBounds = YES;
    cell.backgroundView = cardBackground;

    UIView *selectedBackground = [[UIView alloc] initWithFrame:cardFrame];
    selectedBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    selectedBackground.backgroundColor = [LoginDemoBrandPrimaryColor() colorWithAlphaComponent:0.12];
    selectedBackground.layer.cornerRadius = indexPath.section == 0 ? LoginDemoCornerRadiusCard : 14.0;
    selectedBackground.layer.masksToBounds = YES;
    cell.selectedBackgroundView = selectedBackground;
}

#pragma mark - IBAction

- (IBAction)login:(UIButton *)sender {
    if ([self.accountTextField.text containsString:@"@"]) {
        [[ThingSmartUser sharedInstance] loginByEmail:self.countryCodeTextField.text email:self.accountTextField.text password:self.passwordTextField.text success:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TuyaSmartMain" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Login" message:error.localizedDescription];
        }];
    } else {
        [[ThingSmartUser sharedInstance] loginByPhone:self.countryCodeTextField.text phoneNumber:self.accountTextField.text password:self.passwordTextField.text success:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TuyaSmartMain" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Login" message:error.localizedDescription];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self login:nil];
    } else if (indexPath.section == 2) {
        [self.forgetPasswordButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
