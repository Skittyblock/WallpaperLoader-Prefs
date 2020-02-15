// WPLPreviewCell.m

#import "WPLPreviewCell.h"

extern id SBSUIWallpaperGetPreviewWithImage(int location, int opacity, id image);

@implementation WPLPreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)rid {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PreviewCell"];

	if (self) {
		[self update];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:@"RefreshWallpaperPreview" object:nil];
	}

	return self;
}

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PreviewCell"];
}

- (void)update {
	[self.lightImageView removeFromSuperview];
	CGFloat width = [UIScreen mainScreen].bounds.size.width*(244.5/[UIScreen mainScreen].bounds.size.height);
	self.lightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - width - 11.5, 21.5, width, 244.5)];
	self.lightImageView.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg"];
	[self addSubview:self.lightImageView];

	[self.darkImageView removeFromSuperview];
	self.darkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 + 11.5, 21.5, width, 244.5)];
	self.darkImageView.image = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackgroundThumbnaildark.jpg"];
	[self addSubview:self.darkImageView];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self update];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
	return 287;
}

@end

