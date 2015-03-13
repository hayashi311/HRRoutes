# HRRoutes

JLRoutes~~をコピーして~~にインスパイアされて作ったやつです。

URLからViewControllerを作る

## Usage

### 対応するViewControllerでHRRoutesViewControllerプロトコルを実装する

```objc
@interface HogeViewController : UIViewController <HRRoutesViewController>
@end

@implementation HRSampleViewController

+ (NSString *)hr_urlPattern {
    return @"/sample/:title";
}

+ (HRSampleViewController*)controllerWithParameters:(NSDictionary *)parameters {
    HRSampleViewController *controller = [[HRSampleViewController alloc] init];
    controller.title = parameters[@"title"];
    return controller;
}

@end

```

登録
```objc
// AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[HRRoutes sharedRoutes] registerViewController:[HRSampleViewController class]];
    return YES;
}
```

適当なところで呼び出す
```objc
UIViewController *controller = [[HRRoutes sharedRoutes] instantiateViewControllerWithURL:url];
```

便利なやつ
```objc
[self.navigationController hr_pushViewControllerForURL:[NSURL URLWithString:@"/sample/hoge"]
                                              animated:YES];
```

## Requirements

## Installation

HRRoutes is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "HRRoutes", :git => 'git@github.com:hayashi311/HRRoutes.git'

## Author

Ryota Hayashi, hayashi311@gmail.com

## License

HRRoutes is available under the MIT license. See the LICENSE file for more info.

