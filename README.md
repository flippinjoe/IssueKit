# ![Imgur](http://i.imgur.com/UXN1tVV.png) IssueKit

A drop-in component for creating GitHub issues for your app. **You should only include this code in debug builds,** as it can contain sensitive information like API keys.

![Screenshot](http://i.imgur.com/vyjd3sMl.png?1)

## Setup

Get an API access token from your [GitHub settings](https://github.com/settings/applications):

![Access token image](http://i.imgur.com/cJqyqam.png)

If you want image uploads, [create an 'anonymous' Imgur application](http://api.imgur.com/oauth2/addclient) and note its client ID.

![Client ID image](http://i.imgur.com/i50KbnX.png)

Finally, IssueKit requires [CocoaPods](http://cocoapods.org). Add it to your `Podfile`:

```ruby
pod 'IssueKit'
```

Run `pod install` and you're off!

## Usage

Setup `ISKIssueManager` in `application:didFinishLaunchingWithOptions:`

```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Reponame must be in '<username>/<reponame>' format.
    [[ISKIssueManager defaultManager] setupWithReponame:@"usepropeller/IssueKit" andAccessToken:@"YOUR_GITHUB_ACCESS_TOKEN"];

    // If you have an Imgur client ID
    [[ISKIssueManager defaultManager] setupImageUploadsWithClientID:@"YOUR_IMGUR_CLIENT_ID"];

    return YES;
}
```

With these settings, IssueKit will create an issue with an 'IssueKit' label on the repo you specified.

### Presenting via Gesture

You can present the IssueKit prompt via a three-finger-double-tap anywhere on the window at anytime in your app. This may not work for perfectly for all apps, as some views and configurations swallow gestures or will have performance impacts.

```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // after installation
    [[ISKIssueManager defaultManager] installGestureOnWindow: self.window];
    
    // ...
}
```

### DIY Presentation

You can call `-presentIssueViewControllerOnViewController` when you want to show the IssueKit prompt after a specific event.

```Objective-C
- (IBAction)showIssueViewController:(id)sender {
    [[ISKIssueManager defaultManager] presentIssueViewControllerOnViewController:self];
}
```

## Contact

[Mert Dümenci](http://dumenci.me/)
[@mertdumenci](https://twitter.com/mertdumenci)
