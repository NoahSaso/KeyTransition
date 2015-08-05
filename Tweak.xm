#define log(z) NSLog(@"[KeyTransition] %@", z)

#include <stdlib.h>

// Animation enums
enum {
	KTAnimationFade,
	KTAnimationSlideVertical,
	KTAnimationSlideHorizontal,
	KTAnimationShrink,
	KTAnimationGrow,
	KTAnimationShrinkAndGrow,
	KTAnimationCount,
	KTAnimationRandom = 673
};
typedef NSUInteger KTAnimation;

// Preference settings
static BOOL isEnabled = YES, areDirectionsSwapped = NO, hideGlobeKey = NO;
static KTAnimation selectedAnimation = KTAnimationFade;

// Interfaces

@interface UIKeyboardInputMode : NSObject
@end

@interface UIKeyboardImpl : UIView
// Custom methods I need to call myself
- (void)animateThatShtuff:(UIKeyboardInputMode *)newInputMode isNext:(BOOL)isNext;
- (UIImage *)imageWithView:(UIView *)view;
@end

@interface UIKeyboardInputModeController : NSObject
@property(retain) UIKeyboardInputMode *currentInputMode;
@property(retain, nonatomic) UIKeyboardInputMode *nextInputModeToUse;
+ (id)sharedInputModeController;
- (id)activeInputModes;
- (void)setCurrentInputMode:(UIKeyboardInputMode *)inputMode;
@end

static void reloadPrefs();

%hook UIKeyboardImpl

// I guess it already has a delayed init method for me :D
- (void)delayedInit {
	%orig;
	if(!isEnabled) return;
	// Create swipe gesture recognizers
	UISwipeGestureRecognizer* swipeKeyGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(transitionThoseKeyboards:)];
	swipeKeyGestureUp.direction = (UISwipeGestureRecognizerDirectionUp);
	UISwipeGestureRecognizer* swipeKeyGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(transitionThoseKeyboards:)];
	swipeKeyGestureDown.direction = (UISwipeGestureRecognizerDirectionDown);
	// Add to view
	[self addGestureRecognizer:swipeKeyGestureUp];
	[self addGestureRecognizer:swipeKeyGestureDown];
	[swipeKeyGestureUp release];
	[swipeKeyGestureDown release];
}

// Get image from UIView
%new - (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]); 
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

// Target action for swipe gesture recognizer
%new - (void)transitionThoseKeyboards:(UISwipeGestureRecognizer *)swipeGesture {
	reloadPrefs();
	if(!isEnabled) {
		[self removeGestureRecognizer:swipeGesture];
		[swipeGesture release];
		return;
	}
	UIKeyboardInputModeController* inputModeController = [%c(UIKeyboardInputModeController) sharedInputModeController];
	int index = [inputModeController.activeInputModes indexOfObject:inputModeController.currentInputMode];
	// Check if swiped up or down
	if(swipeGesture.direction == (areDirectionsSwapped ? UISwipeGestureRecognizerDirectionDown : UISwipeGestureRecognizerDirectionUp)) {
		// Next keyboard
		log(@"Next keyboard");
		if(index == [inputModeController.activeInputModes count] - 1) index = -1;
		index++;
		[self animateThatShtuff:inputModeController.activeInputModes[index] isNext:YES];
	}else {
		// Previous keyboard
		log(@"Previous keyboard");
		if(index == 0) index = [inputModeController.activeInputModes count];
		index--;
		[self animateThatShtuff:inputModeController.activeInputModes[index] isNext:NO];
	}
}

%new - (void)animateThatShtuff:(UIKeyboardInputMode *)newInputMode isNext:(BOOL)isNext {
	if(!isEnabled) return;
	// Variables most or all animations need
	UIKeyboardInputModeController* inputModeController = [%c(UIKeyboardInputModeController) sharedInputModeController];
	UIImageView* currentKeyboardView = [[UIImageView alloc] initWithImage:[self imageWithView:self]];
	int currentAnimation = selectedAnimation;
	// Choose random
	if(currentAnimation == KTAnimationRandom) currentAnimation = arc4random_uniform(KTAnimationCount);
	// Choose shrink on next keyboard and grow on previous, kind of like a stack of cards
	if(currentAnimation == KTAnimationShrinkAndGrow) currentAnimation = (isNext ? KTAnimationShrink : KTAnimationGrow);
	switch(currentAnimation) {
		case KTAnimationFade:
			[UIView animateWithDuration:0.35 animations:^{
				self.alpha = 0;
			} completion:^(BOOL){
				[inputModeController setCurrentInputMode:newInputMode];
				[UIView animateWithDuration:0.35 animations:^{
					self.alpha = 1;
				}];
			}];
			break;
		case KTAnimationSlideVertical: {
			[self.superview addSubview:currentKeyboardView];
			self.alpha = 0;
			[inputModeController setCurrentInputMode:newInputMode];
			self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
			CGRect newFrame = currentKeyboardView.frame;
			newFrame.origin.y = (isNext ? (newFrame.size.height * 2) : -newFrame.size.height);
			[UIView animateWithDuration:0.75 animations:^{
				currentKeyboardView.frame = newFrame;
				currentKeyboardView.alpha = 0;
				self.alpha = 1;
				self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
			} completion:^(BOOL){
				[currentKeyboardView removeFromSuperview];
			}];
			break;
		}
		case KTAnimationSlideHorizontal: {
			[self.superview addSubview:currentKeyboardView];
			self.alpha = 0;
			[inputModeController setCurrentInputMode:newInputMode];
			self.frame = CGRectMake(self.frame.origin.x + (isNext ? self.frame.size.width : -self.frame.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			CGRect newFrame = currentKeyboardView.frame;
			newFrame.origin.x = (isNext ? -newFrame.size.width : newFrame.size.width);
			[UIView animateWithDuration:0.75 animations:^{
				currentKeyboardView.frame = newFrame;
				currentKeyboardView.alpha = 0;
				self.alpha = 1;
				self.frame = CGRectMake(self.frame.origin.x + (isNext ? -self.frame.size.width : self.frame.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			} completion:^(BOOL){
				[currentKeyboardView removeFromSuperview];
			}];
			break;
		}
		case KTAnimationShrink: {
			[self addSubview:currentKeyboardView];
			[inputModeController setCurrentInputMode:newInputMode];
			CGRect newFrame = CGRectMake((self.frame.size.width / 2) + 1, (self.frame.size.height / 2) + 1, 2, 2);
			[UIView animateWithDuration:0.75 animations:^{
				currentKeyboardView.frame = newFrame;
			} completion:^(BOOL){
				[currentKeyboardView removeFromSuperview];
			}];
			break;
		}
		case KTAnimationGrow: {
			[self addSubview:currentKeyboardView];
			CGPoint center = self.center;
			[inputModeController setCurrentInputMode:newInputMode];
			CGRect newFrame = CGRectMake(0, 0, currentKeyboardView.frame.size.width * 2, currentKeyboardView.frame.size.height * 2);
			[UIView animateWithDuration:0.75 animations:^{
				currentKeyboardView.frame = newFrame;
				currentKeyboardView.center = center;
				currentKeyboardView.alpha = 0;
			} completion:^(BOOL){
				[currentKeyboardView removeFromSuperview];
			}];
			break;
		}
		default:
			[inputModeController setCurrentInputMode:newInputMode];
			break;
	}
}

%end

// Hide globe key



static void reloadPrefs() {
	log(@"Loading prefs");
	NSDictionary* prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.sassoty.keytransition.plist"];
	isEnabled = !prefs[@"Enabled"] ? YES : [prefs[@"Enabled"] boolValue];
	areDirectionsSwapped = !prefs[@"SwappedDirections"] ? NO : [prefs[@"SwappedDirections"] boolValue];
	hideGlobeKey = !prefs[@"HideGlobeKey"] ? NO : [prefs[@"HideGlobeKey"] boolValue];
	selectedAnimation = !prefs[@"Animation"] ? KTAnimationFade : [prefs[@"Animation"] intValue];
}

%ctor {

	reloadPrefs();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
	        (CFNotificationCallback)reloadPrefs,
	        CFSTR("com.sassoty.keytransition.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

}
