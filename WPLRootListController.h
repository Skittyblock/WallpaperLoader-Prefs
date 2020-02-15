// WPLRootListController.h

#import <Preferences/PSListController.h>

@interface WPLRootListController : PSListController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, retain) UIImage *lightImage;
@property (nonatomic, retain) UIImage *darkImage;
@property (nonatomic, assign) int choosingVariant;

- (void)chooseLocation;
- (void)chooseLightImage;
- (void)chooseDarkImage;

@end
