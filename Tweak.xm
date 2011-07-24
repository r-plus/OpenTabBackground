static BOOL isAvoidingSwitchTab = NO;

%hook BrowserController
- (void)loadURLInNewWindow:(NSURL *)url animated:(BOOL)animated
{
  isAvoidingSwitchTab ? %orig(url,NO) : %orig ;
}
%end

%hook TabController
- (void)switchToTabDocument:(id)tabDocument inBackground:(BOOL)background
{  
  if (isAvoidingSwitchTab && !background)
  {
    isAvoidingSwitchTab = NO;
    return;
  }
  %orig;
}
%end

%hook UIWebDocumentView
- (void)_showLinkSheet
{
  isAvoidingSwitchTab = YES;
  %orig;
}

- (void)_showImageSheet
{
  isAvoidingSwitchTab = YES;
  %orig;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != 1 && buttonIndex != 3)
    isAvoidingSwitchTab = NO;
  %orig;
}
%end

/*
//BETA.

////feature
//1.No ActionSheet appeer.
//2.Show 'done' HUD.

////known issue
//1.ugly page behavior after action.

#import <UIKit/UIKit.h>

@interface BrowserController : NSObject//WebUIController
+ (id)sharedBrowserController;
- (void)loadURLInNewWindow:(id)url animated:(BOOL)animate;
@end

@interface UIWebDocumentView : UIWebView//UIWebTiledView
+ (id)standardTextViewPreferences;
- (void)hideBrowserSheet:(id)sheet;
@end

@interface UIProgressHUD : UIView
- (void)show: (BOOL)yesOrNo;
- (void)setText: (NSString *)text;
- (void)showInView:(id)view;
- (void)hide;
- (void)done;
- (UIProgressHUD *)initWithWindow: (UIView *)window;
@end

UIProgressHUD *progressHUD;

%hook UIWebDocumentView

- (void)_showLinkSheet
{
  NSLog(@"self is %@", self);
  NSLog(@"showLinkSheet self is %@", NSStringFromClass([self class]));  
  %log;
  %orig;
}

- (BOOL)canOpenNewPageForURL:(id)url
{
  %log;
  NSLog(@"self is %@", self);
  return NO;
}

- (void)showBrowserSheet:(id)sheet atPoint:(CGPoint)point
{
  %log;
  isAvoidingSwitchTab = YES;
  NSURL *url = [NSURL URLWithString:[sheet title]];
  [[%c(BrowserController) sharedBrowserController] loadURLInNewWindow:url animated:NO];

  CGFloat w = self.window.frame.size.width - 200.0f;
  CGFloat h = self.window.frame.size.height - 180.0f;
  progressHUD = [[UIProgressHUD alloc] initWithFrame:CGRectMake(w / 2, h / 2, 200, 120)];
  [progressHUD setText:@"done"];
  [progressHUD done];
  [progressHUD showInView:self.window];
  [progressHUD setAlpha:0.0f];
  CGAffineTransform affine = CGAffineTransformMakeScale (0.3, 0.3);
  [progressHUD setTransform: affine];
  [UIView beginAnimations: nil context: NULL];
  [UIView setAnimationDuration: 0.3];
  [progressHUD setAlpha:1.0f];
  affine = CGAffineTransformMakeScale (1.0, 1.0);
  [progressHUD setTransform: affine];
  [UIView commitAnimations];
  
  [self performSelector:@selector(progressHUDAffineToRemove) withObject:nil afterDelay:0.5];

//  %orig;
}

%new(v@:)
- (void)progressHUDAffineToRemove
{
  [UIView beginAnimations: nil context: NULL];
  [UIView setAnimationDuration: 0.3];
  [progressHUD setAlpha:0.0f];
  CGAffineTransform affine = CGAffineTransformMakeScale (1.5, 1.5);
  [progressHUD setTransform: affine];
  [UIView commitAnimations];
  
  [NSTimer scheduledTimerWithTimeInterval:0.3
                                   target:self
                                 selector:@selector(endTimer:)
                                 userInfo:nil
                                  repeats:NO];
}

%new(v@:@)
- (void)endTimer:(NSTimer*)timer
{
	[progressHUD hide];
	[progressHUD release];
	progressHUD = nil;	
}

%end

%hook TabDocument
-(void)mightLoadURL:(id)url
{
  %log;
  //NSURL* url2 = MSHookIvar<NSURL *>(self, "_URL");
  //NSLog(@"%@", url2);
  //%orig(url2);
}
%end

*/