//
//  NoteDetailsViewController.m
//  ByteClub
//
//  Created by Charlie Fulton on 7/28/13.
//  Copyright (c) 2013 Razeware. All rights reserved.
//

#import "NoteDetailsViewController.h"
#import "Dropbox.h"
#import "DBFile.h"

@interface NoteDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *filename;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation NoteDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.note) {
        self.filename.text = [[_note fileNameShowExtension:YES] lowercaseString];
        [self retreiveNoteText];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)retreiveNoteText
{

}

#pragma mark - send messages to delegate

- (IBAction)done:(id)sender
{
    // must contain text in textview
    if (![_textView.text isEqualToString:@""]) {
        
        // check to see if we are adding a new note
        if (!self.note) {
            DBFile *newNote = [[DBFile alloc] init];
            newNote.root = @"dropbox";
            self.note = newNote;
        }
        
        _note.contents = _textView.text;
        _note.path = _filename.text;
        
        // - UPLOAD FILE TO DROPBOX - //
        NSURL *url = [Dropbox uploadURLForPath:_note.path];
        // use mutable request so we can set http method PUT
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod:@"PUT"];
        
        NSData *noteContents = [_note.contents dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLSessionUploadTask *uploadTask =
        [_session
         uploadTaskWithRequest:request
         fromData:noteContents
         completionHandler:^(NSData *data,
                             NSURLResponse *response,
                             NSError *error) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             
             if (!error
                 && (200 == httpResponse.statusCode)) {

                 // hybrid completion handling- block calls a delegate
                 // Tutorial says -
                 // In a production-level application you could pass a new DBFile object back to the delegate and sync up your persistent data.
                 // For the purposes of this application, you simply refresh the NotesViewController with a new network call.
                 [self.delegate noteDetailsViewControllerDoneWithDetails:self];

             } else {
                 // alert for error saving / updating note
             }
         }];
        
        [uploadTask resume];
        
    } else {
        UIAlertView *noTextAlert = [[UIAlertView alloc] initWithTitle:@"No text"
                                                              message:@"Need to enter text"
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
        [noTextAlert show];
    }
}

- (IBAction)cancel:(id)sender
{
    
    [self.delegate noteDetailsViewControllerDidCancel:self];
}

@end
