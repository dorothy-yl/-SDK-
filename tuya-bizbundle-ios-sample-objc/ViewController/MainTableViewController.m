//
//  MainTableViewController.m
//  tuya-bizbundle-ios-sample-objc_Example
//
//  Created by Gino on 2021/3/3.
//  Copyright © 2021 Tuya. All rights reserved.
//

#import "MainTableViewController.h"
#import "Alert.h"
#import "Home.h"
#import <ThingModuleServices/ThingModuleServices.h>
#import <ThingSmartBizCore/ThingSmartBizCore.h>
#import "DeviceListTableViewController.h"
#import <ThingSmartMiniAppBizBundle/ThingSmartMiniAppBizBundle.h>
#import "DemoBaseTableViewController.h"
#import "ThemeManagerViewController.h"
#import "ServiceListViewController.h"
#import "tuya_bizbundle_ios_sample_objc_Example-Swift.h"
#import <ThingModuleManager/ThingModuleManager.h>

static UIColor *MainDemoColorFromHex(NSString *hexString) {
    NSString *cleanHex = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    unsigned int rgbValue = 0;
    [[NSScanner scannerWithString:cleanHex] scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue >> 16) & 0xFF) / 255.0
                           green:((rgbValue >> 8) & 0xFF) / 255.0
                            blue:(rgbValue & 0xFF) / 255.0
                           alpha:1.0];
}

static UIColor *MainDemoBrandPrimaryColor(void) { return MainDemoColorFromHex(@"#2F6BFF"); }
static UIColor *MainDemoPageBackgroundColor(void) { return MainDemoColorFromHex(@"#F7F9FC"); }
static UIColor *MainDemoCardBackgroundColor(void) { return MainDemoColorFromHex(@"#FFFFFF"); }
static UIColor *MainDemoTextPrimaryColor(void) { return MainDemoColorFromHex(@"#1B2430"); }
static UIColor *MainDemoTextSecondaryColor(void) { return MainDemoColorFromHex(@"#5B667A"); }

@interface MainTableViewController () <ThingSmartHomeManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *currentHomeLabel;

@property (strong, nonatomic) ThingSmartHomeManager *homeManager;



@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.title = @"涂鸦智能";
    self.view.backgroundColor = MainDemoPageBackgroundColor();
    self.tableView.backgroundColor = MainDemoPageBackgroundColor();
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 6.0;
    }

    [self.logoutButton setTitleColor:MainDemoBrandPrimaryColor() forState:UIControlStateNormal];
    self.logoutButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    self.logoutButton.backgroundColor = UIColor.clearColor;
    self.logoutButton.layer.cornerRadius = 0.0;
    self.logoutButton.contentEdgeInsets = UIEdgeInsetsZero;

    self.currentHomeLabel.textColor = MainDemoTextSecondaryColor();
    self.currentHomeLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
    self.currentHomeLabel.textAlignment = NSTextAlignmentRight;
    [self initiateCurrentHome];
    [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHomeDataProtocol) withInstance:self];
    [[ThingSmartBizCore sharedInstance] registerService:@protocol(ThingSmartHouseIndexProtocol) withInstance:self];
    [self setupActionMapping];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([Home getCurrentHome]) {
        self.currentHomeLabel.text = [Home getCurrentHome].name;
    }
}

- (void)initiateCurrentHome {
    self.homeManager.delegate = self;
    [self.homeManager getHomeListWithSuccess:^(NSArray<ThingSmartHomeModel *> *homes) {
        if (homes && homes.count > 0) {
            [Home setCurrentHome:homes.firstObject];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)setupActionMapping {
    self.actionMapping = @[
        @[ACTION(@selector(gotoFamilyManagement)), ACTION_NULL, ACTION(@selector(logoutTapped:))],
        @[ACTION(@selector(gotoCategoryViewController))],
        @[ACTION_NULL],
        @[ACTION_NULL]
    ];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"家庭";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 28.0 : 6.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        header.contentView.backgroundColor = MainDemoPageBackgroundColor();
        header.textLabel.textColor = MainDemoTextSecondaryColor();
        header.textLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightSemibold];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = UIColor.clearColor;
    cell.contentView.backgroundColor = UIColor.clearColor;

    CGRect cardFrame = CGRectInset(cell.bounds, 14.0, 4.0);
    UIView *cardBackground = [[UIView alloc] initWithFrame:cardFrame];
    cardBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cardBackground.backgroundColor = MainDemoCardBackgroundColor();
    cardBackground.layer.cornerRadius = 14.0;
    cardBackground.layer.masksToBounds = YES;
    cell.backgroundView = cardBackground;

    UIView *selectedBackground = [[UIView alloc] initWithFrame:cardFrame];
    selectedBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    selectedBackground.backgroundColor = [MainDemoBrandPrimaryColor() colorWithAlphaComponent:0.12];
    selectedBackground.layer.cornerRadius = 14.0;
    selectedBackground.layer.masksToBounds = YES;
    cell.selectedBackgroundView = selectedBackground;

    [self styleLabelsInView:cell.contentView];
}

- (void)styleLabelsInView:(UIView *)container {
    for (UIView *subview in container.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            if (label == self.currentHomeLabel) {
                label.textColor = MainDemoTextSecondaryColor();
                label.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
            } else {
                label.textColor = MainDemoTextPrimaryColor();
                label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
            }
        } else {
            [self styleLabelsInView:subview];
        }
    }
}

- (ThingSmartHome *)getCurrentHome {
    if (![Home getCurrentHome]) {
        return  nil;
    }
    
    ThingSmartHome *home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
    return home;
}

- (BOOL)homeAdminValidation {
    return YES;
}

- (void)homeManager:(ThingSmartHomeManager *)manager didAddHome:(ThingSmartHomeModel *)homeModel {
    if (homeModel.dealStatus <= ThingHomeStatusPending && homeModel.name.length > 0) {
        UIAlertController *alertController;
        alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Invite you to join the family", @""), homeModel.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ThingSmartHome *home = [ThingSmartHome homeWithHomeId:homeModel.homeId];
            [home joinFamilyWithAccept:YES success:^(BOOL result) {} failure:^(NSError *error) {}];
        }];
        
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"Refuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ThingSmartHome *home = [ThingSmartHome homeWithHomeId:homeModel.homeId];
            [home joinFamilyWithAccept:NO success:^(BOOL result) {} failure:^(NSError *error) {}];
        }];
        [alertController addAction:action];
        [alertController addAction:refuseAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:alertController animated:true completion:nil];
        });
    }
}

#pragma mark - IBAction

- (IBAction)logoutTapped:(UIButton *)sender {
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"You're going to log out this account.", @"User tapped the logout button.") preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[ThingSmartUser sharedInstance] loginOut:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Logout." message:error.localizedDescription];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    alertViewController.popoverPresentationController.sourceView = sender;
    [alertViewController addAction:logoutAction];
    [alertViewController addAction:cancelAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}


#pragma mark - Table view data source


- (void)gotoFamilyManagement {
    id<ThingFamilyProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingFamilyProtocol)];
    [impl gotoFamilyManagement];
}

- (void)gotoCategoryViewController {
    id<ThingActivatorProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingActivatorProtocol)];
    [impl gotoCategoryViewController];
  
    [impl activatorCompletion:ThingActivatorCompletionNodeNormal customJump:NO completionBlock:^(NSArray * _Nullable deviceList) {
        NSLog(@"deviceList: %@",deviceList);
    }];
}

- (void)gotoProductActivatorViewController {
    CustomActivatorViewController *vc = [[CustomActivatorViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoAddScene {
    id<ThingSmartSceneProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSmartSceneProtocol)];
    [impl addAutoScene:^(ThingSmartSceneModel *secneModel, BOOL addSuccess) {
            
    }];
}

- (void)gotoMessageCenterViewControllerWithAnimated {
    id<ThingMessageCenterProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingMessageCenterProtocol)];
    [impl gotoMessageCenterViewControllerWithAnimated:YES];
}

- (void)gotoHelpCenter {
    id<ThingHelpCenterProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingHelpCenterProtocol)];
    [impl gotoHelpCenter];
}

- (void)requestMallPage {
    id<ThingMallProtocol> mallImpl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingMallProtocol)];
    [mallImpl requestMallPage:ThingMallPageTypeHome completionBlock:^(__kindof UIViewController * _Nonnull page, NSError * _Nonnull error) {
        if (error) {
            [Alert showBasicAlertOnVC:self withTitle:@"" message:error.description];
            return;
        }
        
        [self.navigationController pushViewController:page animated:YES];
    }];
}

- (void)gotoAmazonAlexa {
    [ThingSmartBizCore.sharedInstance registerService:@protocol(ThingValueAddedServicePlugAPIProtocol) withClass:ThingValueAddedServicePlugAPIProtocolImpl.class];
    id<ThingValueAddedServiceProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingValueAddedServiceProtocol)];

    // 跳转到 Alexa 快绑页面
    [impl goToAmazonAlexaLinkViewControllerSuccess:^(BOOL result) {
        // 可以做 loading 操作
    } failure:^(NSError * _Nonnull error) {
        // 可以做 loading 操作
    }];
}

- (void)gotoAddLightScene {
    id<ThingLightSceneProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingLightSceneProtocol)];
    [impl createNewLightScene];
}

- (void)gotoShare {

    id<ThingSocialProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingSocialProtocol)];

    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        [impl registerWithType:ThingSocialWechat appKey:@"xx" appSecret:@"xx" universalLink:@"https://xx.com"];
    });

    /// 分享文本
    if ([impl avaliableForType:ThingSocialWechat]) {
        ThingSocialShareModel *shareModel = [[ThingSocialShareModel alloc] initWithShareType:ThingSocialWechat];
        shareModel.content = @"content";
        shareModel.mediaType = ThingSocialShareContentText;
        [impl shareTo:ThingSocialWechat shareModel:shareModel success:^{

        } failure:^{

        }];
    }

}

- (void)gotoMiniApp {
    // 以id形式打开小程序
    [[ThingMiniAppClient coreClient] openMiniAppByAppId:@"tydhopggfziofo1h9h"];
}

- (void)gotoServiceList {
    [self.navigationController pushViewController:[ServiceListViewController new] animated:YES];
}

- (void)gotoBuyPhone {
    id<ThingPersonalServiceProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingPersonalServiceProtocol)];
    [impl requestPersonalService:ThingPersonalServiceTypePushCall completionBlock:^(__kindof UIViewController *page, NSError *error) {
        if (page) {
            [self.navigationController pushViewController:page animated:YES];
        } else {
            NSLog(@"request phone error %@", error);
        }
    }];
}

- (void)gotoBuySMS {
    id<ThingPersonalServiceProtocol> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingPersonalServiceProtocol)];
    [impl requestPersonalService:ThingPersonalServiceTypePushSMS completionBlock:^(__kindof UIViewController *page, NSError *error) {
        if (page) {
            [self.navigationController pushViewController:page animated:YES];
        } else {
            NSLog(@"request sms error %@", error);
        }
    }];
}

- (void)openAIAssistant {
    id<ThingModuleRouteBlueprint> impl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingModuleRouteBlueprint)];

    // you should replace the link with your own AI Assistant mini app link
    NSString *link = @"miniApp?url=godzilla://tynd4cl6fgspw1samx&aiPtChannel=pj_1a4b4c28e741c000";
    [impl openRoute:link withParams:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show-device-list-detail"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeDeviceDetail;
    }
    
    if ([segue.identifier isEqualToString:@"show-device-list-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeDevicePanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-device-list-ota"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeDeviceOTA;
    }
    
    if ([segue.identifier isEqualToString:@"show-ipc-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeIPCPanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-camera-playback-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraPlayBackPanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-camera-cloud-storage-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraCloudStoragePanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-camera-message-center-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraMessageCenterPanel;
    }
    
    if ([segue.identifier isEqualToString:@"show-camera-photo-library-panel"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraPhotoLibraryPanel;
    }
    if ([segue.identifier isEqualToString:@"show-camera-vas-page"] && [segue.destinationViewController isKindOfClass:[DeviceListTableViewController class]]) {
        ((DeviceListTableViewController*)(segue.destinationViewController)).deviceListType = DeviceListTypeCameraVAS;
    }
}

- (ThingSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[ThingSmartHomeManager alloc] init];
    }
    return _homeManager;
}

- (void)gotoThemeManager {
    id<ThingThemeManagerProtocol> themeImpl = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingThemeManagerProtocol)];
    ThemeManagerViewController * vc = [[ThemeManagerViewController alloc] initWithThemeImpl:themeImpl];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
