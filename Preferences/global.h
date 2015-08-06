#define KTColor [UIColor colorWithRed:.17 green:.47 blue:.83 alpha:1]
#define KTBundle [NSBundle bundleWithPath:@"/Library/PreferenceBundles/KeyTransition.bundle"]

@interface UIImage (Private)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end
