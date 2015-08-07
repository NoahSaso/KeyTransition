#define log(z) NSLog(@"[KeyTransition] %@", z)

#import <AudioToolbox/AudioServices.h>
#include <stdlib.h>

// Vibrate method
extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id arg, NSDictionary* vibratePattern);

// Animation enums
enum {
	KTAnimationFade,
	KTAnimationSlideVertical,
	KTAnimationSlideHorizontal,
	KTAnimationShrink,
	KTAnimationGrow,
	KTAnimationShrinkAndGrow,
	KTAnimationCount,
	KTAnimationRandom = 673,
	KTAnimationNone = 674
};
typedef NSUInteger KTAnimation;

// Preference settings
static BOOL isEnabled = YES,
areDirectionsSwapped = NO,
hideGlobeKey = NO,
vibrateChange = NO,
activeAreaLeft = YES,
activeAreaMiddle = YES,
activeAreaRight = YES;
static int vibrationLength = 100;
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

// Vibrate on change

%hook UIKeyboardInputModeController

- (void)setCurrentInputMode:(UIKeyboardInputMode *)inputMode {
	%orig;
	if(!isEnabled || !vibrateChange) return;
	// Vibrate for 100 ms
	NSArray* arr = [NSArray arrayWithObjects:@(YES), @(vibrationLength), nil];
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:arr forKey:@"VibePattern"];
	dict[@"Intensity"] = @(1);
	// Play vibration
	AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, dict);
}

%end

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
	if(!isEnabled) {
		[self removeGestureRecognizer:swipeGesture];
		[swipeGesture release];
		return;
	}
	// Confirm it was in the allowed region of the keyboard
	CGFloat swipeLocationX = [swipeGesture locationInView:self].x;
	CGFloat columnWidth = self.frame.size.width / 3;
	if(!(activeAreaLeft && swipeLocationX <= columnWidth) &&
		!(activeAreaMiddle && (swipeLocationX >= columnWidth && swipeLocationX <= columnWidth*2)) &&
		!(activeAreaRight && swipeLocationX >= columnWidth*2)) {
		log(@"Swipe outside of active areas");
		return;
	}
	// Process swipe
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
	// No animation
	if(currentAnimation == KTAnimationNone) {
		[inputModeController setCurrentInputMode:newInputMode];
		return;
	}
	// Choose random
	if(currentAnimation == KTAnimationRandom) currentAnimation = arc4random_uniform(KTAnimationCount);
	// Choose shrink on next keyboard and grow on previous, kind of like a stack of cards
	if(currentAnimation == KTAnimationShrinkAndGrow) currentAnimation = (isNext ? KTAnimationShrink : KTAnimationGrow);
	switch(currentAnimation) {
		case KTAnimationFade:
			// Activate animations to hide current keyboard, swap it, then show new keyboard
			[UIView animateWithDuration:0.35 animations:^{
				self.alpha = 0;
			} completion:^(BOOL){
				// Change keyboard
				[inputModeController setCurrentInputMode:newInputMode];
				[UIView animateWithDuration:0.35 animations:^{
					self.alpha = 1;
				}];
			}];
			break;
		case KTAnimationSlideVertical: {
			// Add an image of the current keyboard to the superview of the general keyboard class and hide the new one
			[self.superview addSubview:currentKeyboardView];
			self.alpha = 0;
			// Change keyboard
			[inputModeController setCurrentInputMode:newInputMode];
			// Put the new keyboard off screen
			self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
			// Put the old keyboard up/down according to if it's the next or previous swipe
			CGRect newFrame = currentKeyboardView.frame;
			newFrame.origin.y = (isNext ? (newFrame.size.height * 2) : -newFrame.size.height);
			// Activate animations
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
			// Add an image of the current keyboard to the superview of the general keyboard class and hide the new one
			[self.superview addSubview:currentKeyboardView];
			self.alpha = 0;
			// Change keyboard
			[inputModeController setCurrentInputMode:newInputMode];
			// Put the new keyboard off screen
			self.frame = CGRectMake(self.frame.origin.x + (isNext ? self.frame.size.width : -self.frame.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
			// Put the old keyboard left/right according to if it's the next or previous swipe
			CGRect newFrame = currentKeyboardView.frame;
			newFrame.origin.x = (isNext ? -newFrame.size.width : newFrame.size.width);
			// Activate animations
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
			// Add an image of the current keyboard to the view
			[self addSubview:currentKeyboardView];
			// Change keyboard
			[inputModeController setCurrentInputMode:newInputMode];
			// Shrink the current keyboard
			CGRect newFrame = CGRectMake((self.frame.size.width / 2) + 1, (self.frame.size.height / 2) + 1, 2, 2);
			// Activate animations
			[UIView animateWithDuration:0.75 animations:^{
				currentKeyboardView.frame = newFrame;
			} completion:^(BOOL){
				[currentKeyboardView removeFromSuperview];
			}];
			break;
		}
		case KTAnimationGrow: {
			// Add an image of the current keyboard to the view
			[self addSubview:currentKeyboardView];
			// Get old center to keep new one in place
			CGPoint center = self.center;
			// Change keyboard
			[inputModeController setCurrentInputMode:newInputMode];
			// Grow the current keyboard
			CGRect newFrame = CGRectMake(0, 0, currentKeyboardView.frame.size.width * 2, currentKeyboardView.frame.size.height * 2);
			// Activate animations
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
			// Switch like normal because of some failure with the preferences idk this should never happen unless the user manually changes the preferences file
			[inputModeController setCurrentInputMode:newInputMode];
			break;
	}
}

%end

// Hide globe/emoji key

%hook UIKeyboardLayoutStar



%end

// Prefs

static void reloadPrefs() {
	NSDictionary* prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.sassoty.keytransition.plist"];
	isEnabled = !prefs[@"Enabled"] ? YES : [prefs[@"Enabled"] boolValue];
	hideGlobeKey = !prefs[@"HideGlobeKey"] ? NO : [prefs[@"HideGlobeKey"] boolValue];
	areDirectionsSwapped = !prefs[@"SwappedDirections"] ? NO : [prefs[@"SwappedDirections"] boolValue];
	vibrateChange = !prefs[@"VibrateChange"] ? NO : [prefs[@"VibrateChange"] boolValue];
	vibrationLength = !prefs[@"VibrationLength"] ? 100 : [prefs[@"VibrationLength"] floatValue];
	if(vibrationLength < 50) vibrationLength = 50;
	selectedAnimation = !prefs[@"Animation"] ? KTAnimationFade : [prefs[@"Animation"] intValue];
	activeAreaLeft = !prefs[@"ActiveAreaLeft"] ? YES : [prefs[@"ActiveAreaLeft"] boolValue];
	activeAreaMiddle = !prefs[@"ActiveAreaMiddle"] ? YES : [prefs[@"ActiveAreaMiddle"] boolValue];
	activeAreaRight = !prefs[@"ActiveAreaRight"] ? YES : [prefs[@"ActiveAreaRight"] boolValue];
}

%ctor {

	reloadPrefs();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
	        (CFNotificationCallback)reloadPrefs,
	        CFSTR("com.sassoty.keytransition.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

}
