#define log(z) NSLog(@"[KeyTransition] %@", z)

// Animation enums
enum {
	KTAnimationFade = 0,
	KTAnimationSlideVertical = 1,
	KTAnimationSlideHorizontal = 2,
	KTAnimationZoomIn = 3,
	KTAnimationZoomOut = 4
};
typedef NSUInteger KTAnimation;

// Preference settings
static BOOL isEnabled = YES, areDirectionsSwapped = NO;
static KTAnimation selectedAnimtion = KTAnimationFade;

// Interfaces

@interface UIKeyboardInputMode : NSObject
@end

@interface UIKeyboardImpl : UIView
// Custom methods I need to call myself
- (void)animateThatShtuff:(UIKeyboardInputMode *)newInputMode isGoingUp:(BOOL)isGoingUp;
- (UIImage *)imageWithView:(UIView *)view;
@end

@interface UIKeyboardInputModeController : NSObject
@property(retain) UIKeyboardInputMode *currentInputMode;
@property(retain, nonatomic) UIKeyboardInputMode *nextInputModeToUse;
+ (id)sharedInputModeController;
- (id)activeInputModes;
- (void)setCurrentInputMode:(UIKeyboardInputMode *)inputMode;
@end

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
	UIKeyboardInputModeController* inputModeController = [%c(UIKeyboardInputModeController) sharedInputModeController];
	int index = [inputModeController.activeInputModes indexOfObject:inputModeController.currentInputMode];
	// Check if swiped up or down
	if(swipeGesture.direction == (areDirectionsSwapped ? UISwipeGestureRecognizerDirectionDown : UISwipeGestureRecognizerDirectionUp)) {
		// Next keyboard
		log(@"Next keyboard");
		if(index == [inputModeController.activeInputModes count] - 1) index = -1;
		index++;
		[self animateThatShtuff:inputModeController.activeInputModes[index] isGoingUp:YES];
	}else {
		// Previous keyboard
		log(@"Previous keyboard");
		if(index == 0) index = [inputModeController.activeInputModes count];
		index--;
		[self animateThatShtuff:inputModeController.activeInputModes[index] isGoingUp:NO];
	}
}

%new - (void)animateThatShtuff:(UIKeyboardInputMode *)newInputMode isGoingUp:(BOOL)isGoingUp {
	UIKeyboardInputModeController* inputModeController = [%c(UIKeyboardInputModeController) sharedInputModeController];
	UIImageView* currentKeyboardView = [[UIImageView alloc] initWithImage:[self imageWithView:self]];
	switch(selectedAnimtion) {
		case KTAnimationFade:
			[UIView animateWithDuration:0.2 animations:^{
				self.alpha = 0;
			} completion:^(BOOL){
				[inputModeController setCurrentInputMode:newInputMode];
				[UIView animateWithDuration:0.2 animations:^{
					self.alpha = 1;
				}];
			}];
			break;
		case KTAnimationSlideVertical: {
			[self addSubview:currentKeyboardView];
			[inputModeController setCurrentInputMode:newInputMode];
			[UIView animateWithDuration:0.6 animations:^{
				CGRect newFrame = currentKeyboardView.frame;
				newFrame.origin.y = (isGoingUp ? (newFrame.size.height * 2) : -newFrame.size.height);
				currentKeyboardView.frame = newFrame;
				currentKeyboardView.alpha = 0;
			} completion:^(BOOL){
				[currentKeyboardView removeFromSuperview];
			}];
			break;
		}
		case KTAnimationSlideHorizontal: {
			[self addSubview:currentKeyboardView];
			[inputModeController setCurrentInputMode:newInputMode];
			[UIView animateWithDuration:0.6 animations:^{
				CGRect newFrame = currentKeyboardView.frame;
				newFrame.origin.x = (isGoingUp ? -newFrame.size.width : (newFrame.size.width * 2));
				currentKeyboardView.frame = newFrame;
				currentKeyboardView.alpha = 0;
			} completion:^(BOOL){
				[currentKeyboardView removeFromSuperview];
			}];
			break;
		}
		case KTAnimationZoomOut: {
			[self addSubview:currentKeyboardView];
			[inputModeController setCurrentInputMode:newInputMode];
			CGRect newFrame = CGRectMake((self.frame.size.width / 2) + 1, (self.frame.size.height / 2) + 1, 2, 2);
			[UIView animateWithDuration:0.9 animations:^{
				currentKeyboardView.frame = newFrame;
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

static void reloadPrefs() {
	NSDictionary* prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.sassoty.keytransition.plist"];
	isEnabled = !prefs[@"Enabled"] ? YES : [prefs[@"Enabled"] boolValue];
	areDirectionsSwapped = !prefs[@"SwappedDirections"] ? NO : [prefs[@"SwappedDirections"] boolValue];
	selectedAnimtion = !prefs[@"Animation"] ? KTAnimationFade : [prefs[@"Animation"] intValue];
}

%ctor {

	reloadPrefs();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
	        (CFNotificationCallback)reloadPrefs,
	        CFSTR("com.sassoty.keytransition.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

}
