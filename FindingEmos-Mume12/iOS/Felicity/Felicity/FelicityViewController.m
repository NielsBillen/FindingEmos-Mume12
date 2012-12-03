//
//  FelicityViewController.m
//  Felicity
//
//  Deze klasse controleert de interactie tussen de verschillende views
//  in de applicatie.
//
//  Created by Stijn Adams on 16/10/12.
//  Copyright (c) 2012 Ariadne. All rights reserved.
//

#import "FelicityViewController.h"
#import "InputViewController.h"
#import "OutputViewController.h"
#import "SettingsViewController.h"

@implementation FelicityViewController

@synthesize scrollView, pageControl, navBar;

/*
** Initialiseert de Input- en Results Page op de juiste plaats in de scrollview.
*/
- (void)initializePage:(UIViewController*)viewController atPageNumber:(NSInteger)pageNumber {
    
    CGRect pageFrame = viewController.view.frame;
    pageFrame.origin.x = 320 * pageNumber;
    pageFrame.origin.y = 0;
    viewController.view.frame = pageFrame;
}

/*
** Wordt opgeroepen wanneer de view geladen is.
** Initialiseert de scrollview.
** Maakt de input- en results page aan.
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.frame = CGRectMake(0, 0, 320, 385);
    self.scrollView.contentSize = CGSizeMake(self->scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
    
    inputPage = [[InputViewController alloc] initWithNibName:@"InputView" bundle:nil];
    [self.scrollView addSubview:inputPage.view];
    
	outputPage = [[OutputViewController alloc] initWithNibName:@"OutputView" bundle:nil];
	[self.scrollView addSubview:outputPage.view];
    
    [self initializePage:inputPage atPageNumber:0];
    [self initializePage:outputPage atPageNumber:1];
    [self setTitle];
}

/*
** Wordt opgeroepen wanneer de user scrollt in de scrollview.
** Gaat na of de user tijdens het scrollen op een andere pagina terechtkomt.
*/
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if(!usingPageControl) {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        CGFloat xOffset = self.scrollView.contentOffset.x;
        
        int pageNumber = floor((xOffset - pageWidth/2) / pageWidth) + 1;
        self.pageControl.currentPage = pageNumber;
        
        if(pageNumber == 1) {
            [outputPage viewDidAppear:YES];
        }
        
        [self setTitle];
    }
}

/*
** Wordt opgeroepen wanneer de user de pagina verandert dmv de UIPageControl.
*/
- (IBAction)changePage:(id)sender {
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    if(self.pageControl.currentPage == 1) {
        [outputPage viewDidAppear:YES];
    }
    
    [self setTitle];
    usingPageControl = YES;
}

/*
** Wordt opgeroepen wanneer de scrollview stopt met scrollen.
** Zet usingPageControl op NO; dit is nodig om het flashen van UIPageControl
** tegen te houden wanneer de gebruiker wisselt van pagina dmv deze UIPageControl
*/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    usingPageControl = NO;
}

/*
** Wordt opgeroepen wanneer de scrollview begint met scrollen.
** Zet usingPageControl op NO; dit is nodig om het flashen van UIPageControl
** tegen te houden wanneer de gebruiker wisselt van pagina dmv deze UIPageControl
*/
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    usingPageControl = NO;
}

/*
** Past de titel van de topbar aan aan de huidige pagina.
*/
- (void)setTitle {
    if(self.pageControl.currentPage == 0) {
        navBar.topItem.title = @"Felicity";
    }
    else if(self.pageControl.currentPage == 1) {
        navBar.topItem.title = @"Results";
    }
}

@end
