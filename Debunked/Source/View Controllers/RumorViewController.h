//  Copyright (c) 2009-2016 Robert Ruana <rob@robruana.com>
//
//  This file is part of Debunked.
//
//  Debunked is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Debunked is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Debunked.  If not, see <http://www.gnu.org/licenses/>.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AsynchronousViewController.h"
#import "RumorDataSource.h"


@interface RumorViewController: AsynchronousViewController<
									UIWebViewDelegate, 
									UIActionSheetDelegate,
									MFMailComposeViewControllerDelegate,
									UIPrintInteractionControllerDelegate>
{
    UIWebView *webView;
    BOOL isWebViewLoaded;
}

@property (nonatomic,readonly) RumorDataSource *rumorDataSource;

- (void)segmentAction:(id)sender;
- (void)handleShareButton;

@end
