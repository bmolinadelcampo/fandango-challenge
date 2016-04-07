//
//  ViewController.m
//  Fandango Challenge
//
//  Created by Belén Molina del Campo on 05/04/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *titlesArray;
@property (strong, nonatomic) NSMutableArray *shortTitlesArray;
@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableString *titleString;
@property (strong, nonatomic) NSMutableDictionary *filmsDictionary;
- (void)loadFilms;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titlesArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.imagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.filmsDictionary = [[NSMutableDictionary alloc] init];
    self.shortTitlesArray = [[NSMutableArray alloc] init];
    [self loadFilms];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.titlesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filmCell"];
    NSUInteger row = indexPath.row;
    NSString *titleString = [self.filmsDictionary objectForKey:self.shortTitlesArray[row]][1];
    cell.textLabel.text = titleString;
    cell.textLabel.font = [UIFont systemFontOfSize:20.0];
    cell.textLabel.textColor = [UIColor colorWithRed:0.75 green:0.17 blue:0.64 alpha:1];
    
    cell.imageView.image = [self.filmsDictionary objectForKey:self.shortTitlesArray[row]][0];
    return cell;
}

- (void)loadFilms
{
    [self.titlesArray removeAllObjects];
    [[self tableView] reloadData];
    
    self.session = [NSURLSession sharedSession];
    NSURL *ourUrl = [NSURL URLWithString:@"http://www.fandango.com/rss/newmovies.rss"];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:ourUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              NSLog(@"%@", data);
                                              NSXMLParser *ourParser = [[NSXMLParser alloc] initWithData:data];
                                              [ourParser setDelegate:self];
                                              [ourParser parse];
                                              for (int i = 0; i < [self.titlesArray count] ; i++) {
                                                  NSArray *imageAndFullTitle = @[self.imagesArray[i], self.titlesArray[i]];
                                                  [self.filmsDictionary setObject:imageAndFullTitle forKey:self.shortTitlesArray[i]];
                                              }
                                              [self.shortTitlesArray sortUsingSelector:@selector(compare:)];
                                              NSLog(@"%@", self.titlesArray);
                                              NSLog(@"%@", self.shortTitlesArray);
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [self.tableView reloadData];
                                              });
                                              NSLog(@"Table reloaded");
                                          }];
    [downloadTask resume];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"title"] && ![self.titleString isEqualToString:@"New Movies"]) {
        NSLog(@"Found new title!");
        self.titleString = [[NSMutableString alloc] init];
    }
    
//    if ([elementName isEqualToString:@"img"] && ![[attributeDict valueForKey:@"alt"] isEqualToString:@"Buy Tickets"]) {
//        NSLog(@"%@", attributeDict);
//    }
    
    if ([elementName isEqualToString:@"enclosure"]) {
        NSArray *ourArray = [attributeDict allValues];
        NSURL *ourURL = [NSURL URLWithString:ourArray[0]];
        UIImage *posterImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:ourURL]];
        NSLog(@"%@", posterImage);
        [self.imagesArray addObject:posterImage];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.titleString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"title"] && ![self.titleString isEqualToString:@"New Movies"]) {
        NSLog(@"ended title: %@", self.titleString);
        [self.titlesArray addObject:[NSString stringWithString:self.titleString]];
        [self createShortTitle:self.titleString];
        self.titleString = nil;
    }
}

- (void)createShortTitle:(NSString *)originalTitle
{
    NSArray *wordsToRemove = @[@"The ", @"the ", @"Of ", @"of ", @"A ", @" a", @"An ", @" an", @"With ", @" with", @"In ", @" in", @"On ", @" on", @"Under ", @" under", @"At ", @" at", @"For ", @" for", @"And ", @" and", @"To ", @" to", @"But ", @" but", @"So ", @" so"];
    NSString* shortTitleString = [[NSString alloc] initWithString:originalTitle];
    
    for (int i = 0; i < [wordsToRemove count]; i++) {
        NSRange replaceRange = [shortTitleString rangeOfString:wordsToRemove[i]];
        if (replaceRange.location != NSNotFound){
            shortTitleString = [shortTitleString stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
    }
    NSLog(@"Short title is: %@", shortTitleString);
    [self.shortTitlesArray addObject:shortTitleString];
}
@end
