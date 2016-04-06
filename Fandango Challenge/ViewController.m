//
//  ViewController.m
//  Fandango Challenge
//
//  Created by Belén Molina del Campo on 05/04/2016.
//  Copyright © 2016 Belén Molina del Campo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *filmsArray;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableString *titleString;
- (void)loadFilms;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filmsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self loadFilms];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filmsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"filmCell"];
    NSUInteger row = indexPath.row;
    NSString *titleString = self.filmsArray[row];
    cell.textLabel.text = titleString;
    cell.textLabel.font = [UIFont systemFontOfSize:10.0];
    cell.textLabel.textColor = [UIColor colorWithRed:0.75 green:0.17 blue:0.64 alpha:1];
    return cell;
}

- (void)loadFilms
{
    [self.filmsArray removeAllObjects];
    [[self tableView] reloadData];
    
    self.session = [NSURLSession sharedSession];
    NSURL *ourUrl = [NSURL URLWithString:@"http://www.fandango.com/rss/newmovies.rss"];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:ourUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              NSLog(@"%@", data);
                                              NSXMLParser *ourParser = [[NSXMLParser alloc] initWithData:data];
                                              [ourParser setDelegate:self];
                                              [ourParser parse];
                                              [[self tableView] reloadData];
                                          }];
    [downloadTask resume];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    if ([elementName isEqualToString:@"title"] && ![self.titleString isEqualToString:@"New Movies"]) {
        NSLog(@"Found new title!");
        self.titleString = [[NSMutableString alloc] init];
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
        [self.filmsArray addObject:[NSString stringWithString:self.titleString]];
        self.titleString = nil;
    }
}
@end
