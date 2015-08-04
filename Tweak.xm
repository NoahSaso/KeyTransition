#define log(z) NSLog(@"[KeyTransition] %@", z)

typedef enum {
	KTAnimationFade,
	KTAnimationSwapUp,
	KTAnimationSwapDown
} KTAnimation;

static BOOL areDirectionsSwapped = NO;
static KTAnimation selectedAnimtion = KTAnimationFade;

@interface UIKeyboardInputMode : NSObject
@end

@interface UIKeyboardImpl : UIView
// Custom methods I need to call myself
- (void)animateThatShtuff:(UIKeyboardInputMode *)newInputMode;
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

// Target action for swipe gesture recognizer
%new - (void)transitionThoseKeyboards:(UISwipeGestureRecognizer *)swipeGesture {
	UIKeyboardInputModeController* inputModeController = [%c(UIKeyboardInputModeController) sharedInputModeController];
	int index = [inputModeController.activeInputModes indexOfObject:inputModeController.currentInputMode];
	log(@(index));
	// Check if swiped up or down
	if(swipeGesture.direction == (areDirectionsSwapped ? UISwipeGestureRecognizerDirectionDown : UISwipeGestureRecognizerDirectionUp)) {
		// Next keyboard
		log(@"Next keyboard");
		if(index == [inputModeController.activeInputModes count] - 1) index = -1;
		index++;
		[self animateThatShtuff:inputModeController.activeInputModes[index]];
	}else {
		// Previous keyboard
		log(@"Previous keyboard");
		if(index == 0) index = [inputModeController.activeInputModes count];
		index--;
		[self animateThatShtuff:inputModeController.activeInputModes[index]];
	}
}

%new - (void)animateThatShtuff:(UIKeyboardInputMode *)newInputMode {
	UIKeyboardInputModeController* inputModeController = [%c(UIKeyboardInputModeController) sharedInputModeController];
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
		default:
			[inputModeController setCurrentInputMode:newInputMode];
			break;
	}
}

%end
