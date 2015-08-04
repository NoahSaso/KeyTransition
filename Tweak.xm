#define log(z) NSLog(@"[KeyTransition] %@", z)

static BOOL areDirectionsSwapped = NO;

@interface UIKeyboardImpl : UIView
@end
@interface UIKeyboardInputMode : NSObject
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
		log(@(index));
		[inputModeController setCurrentInputMode:inputModeController.activeInputModes[index]];
	}else {
		// Previous keyboard
		log(@"Previous keyboard");
		if(index == 0) index = [inputModeController.activeInputModes count];
		index--;
		log(@(index));
		[inputModeController setCurrentInputMode:inputModeController.activeInputModes[index]];
	}
}

%end
