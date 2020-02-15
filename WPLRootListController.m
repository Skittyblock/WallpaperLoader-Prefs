// WPLRootListController.m

#include "WPLRootListController.h"
#import <Photos/Photos.h>

@interface SBFWallpaperOptions : NSObject
@property (nonatomic, assign) int wallpaperMode;
@property (nonatomic, assign) double parallaxFactor;
@property (nonatomic, assign) NSString *name;
@end

extern int SBSUIWallpaperSetImages(id imageDict, id optionsDict, int locations, int interfaceStyle);

extern CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

// convert cp bitmaps
UIImage *imageFromCPBitmap(NSString *path) {
	CFArrayRef someArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)([NSData dataWithContentsOfFile:path]), NULL, 1, NULL);
	NSArray *array = (__bridge NSArray*)someArrayRef;
	return [UIImage imageWithCGImage:(__bridge CGImageRef)(array[0])];
}

@implementation WPLRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)chooseLightImage {
	self.choosingVariant = 0;
	[self openImagePicker];
}

- (void)chooseDarkImage {
	self.choosingVariant = 1;
	[self openImagePicker];
}

- (void)chooseLocation {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Set Lock Screen" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self setWallpaperWithLightImage:self.lightImage darkImage:self.darkImage location:1];
	}]];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Set Home Screen" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self setWallpaperWithLightImage:self.lightImage darkImage:self.darkImage location:2];
	}]];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Set Both" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self setWallpaperWithLightImage:self.lightImage darkImage:self.darkImage location:3];
	}]];

	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	
	//[actionSheet setModalPresentationStyle:UIModalPresentationPopover];
	[self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)setWallpaperWithLightImage:(UIImage *)lightImage darkImage:(UIImage *)darkImage location:(int)location {
	NSMutableDictionary *settings;
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("xyz.skitty.wplprefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("xyz.skitty.wplprefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}
	if (!settings) {
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/xyz.skitty.wplprefs.plist"];
	}

	BOOL parallax = [([settings objectForKey:@"parallax"] ?: @(YES)) boolValue];

	SBFWallpaperOptions *lightOptions = [[SBFWallpaperOptions alloc] init];
	[lightOptions setWallpaperMode:1];
	[lightOptions setParallaxFactor:parallax ? 1.0 : 0.0];
	[lightOptions setName:@"1234.WallpaperLoader Light"]; // Name must start with a number

	SBFWallpaperOptions *darkOptions = [[SBFWallpaperOptions alloc] init];
	[darkOptions setWallpaperMode:2];
	[darkOptions setParallaxFactor:parallax ? 1.0 : 0.0];
	[darkOptions setName:@"1234.WallpaperLoader Dark"];

	SBSUIWallpaperSetImages(@{@"light": lightImage ?: imageFromCPBitmap(@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"), @"dark": darkImage ?: imageFromCPBitmap(@"/var/mobile/Library/SpringBoard/LockBackgrounddark.cpbitmap")}, @{@"light": lightOptions, @"dark": darkOptions}, location, UIUserInterfaceStyleDark);

	[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshWallpaperPreview" object:nil];
}

// UIImagePickerControllerDelegate

- (void)openImagePicker {
	[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
		if (status == PHAuthorizationStatusAuthorized) {
			dispatch_async(dispatch_get_main_queue(), ^{
				UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
				[self presentViewController:imagePicker animated:YES completion:^{
					imagePicker.delegate = self;
				}];
			});
		}
	}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	if (self.choosingVariant == 0) {
		self.lightImage = [self downscaleImage:image];
	} else if (self.choosingVariant == 1) {
		self.darkImage = [self downscaleImage:image];
	}
	[picker dismissViewControllerAnimated:YES completion:^{
		[self chooseLocation];
	}];
}


// Other

- (UIImage *)downscaleImage:(UIImage *)image {
	CGFloat factor = 1024 / image.size.height;
	CGSize size = CGSizeMake(image.size.width*factor, 1024);

	UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

@end
