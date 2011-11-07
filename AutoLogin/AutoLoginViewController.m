//
//  AutoLoginViewController.m
//  AutoLogin
//
//  Created by Camilo Andr√©s Vera Bezmalinovic on 6/15/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari¬≠a. All rights reserved.
//

#import "AutoLoginViewController.h"

//acepta los certificados chantas de la U
@interface NSURLRequest(anyssl)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
@end
@implementation NSURLRequest(anyssl)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}
@end

NSString *secretKey = @"<#key#>";

@implementation AutoLoginViewController

/*******************************************************************************
 MÉTODOS DE INICIO
 ******************************************************************************/

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNumber *autoConnect = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto"];
    
    if (autoConnect && [autoConnect boolValue]) 
        [switchAutoConnect setOn:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidBecomeActive:) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:nil];
    
    for (int i=0; i<8; i++) 
        notificationSlot[i]=NO;
}

//si tiene guardado que intente conectar al iniciar...
-(void)applicationDidBecomeActive:(id)sender
{    
    NSNumber *autoConnect = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto"];
    
    if (autoConnect && [autoConnect boolValue])
    {
        tryWithAll = YES;
        [self tryToConnectWithAccountAtIndex:0];
    }
}
/*******************************************************************************
 MÉTODOS INTERNOS
 ******************************************************************************/

//método obtenido en
//http://stackoverflow.com/questions/5198716/iphone-get-ssid-without-private-library
-(BOOL)isUsmNetwork
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count])
            break;
        [info release];
    }
    
    [ifs release];
    NSDictionary *wifi = [info autorelease];
    
    NSString *ssid = [wifi objectForKey:@"SSID"];
    
    if ([ssid hasPrefix:@"usm_"]) 
        return YES;
    
    [self showNotificationWithMessage:@"Debes estar conectado a una red USM"];
    
    return NO;
    
}

- (void)tryToConnectWithAccountAtIndex:(NSInteger)index
{
    [self hideKeyboard:nil];
    
    if (![self isUsmNetwork])
        return;
    
    NSMutableArray *accounts = [[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];

    if ([accounts count] <= index)
        return;

    NSDictionary *userData = [accounts objectAtIndex:index];
    NSString *user = [userData objectForKey:@"user"];
    NSString *pass = [(NSString*)[userData objectForKey:@"pass"] AES256DecryptWithKey:secretKey];
    //prepara la consulta
    NSString *post= [NSString stringWithFormat:@"username=%@&password=%@&buttonClicked=4",user,pass];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/login.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    //carga la consulta en un webView
    [webHidden loadRequest:request];
    
    //le pasa el index del usuario que trata de logear...
    [webHidden setTag:index];
    
    [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(webViewDidTimeOut:) userInfo:nil repeats:NO];
    timeOut = NO;
}
/*******************************************************************************
 MÉTODOS DE INTERFAZ
 ******************************************************************************/
//esconde los teclados
-(IBAction)hideKeyboard:(id)sender
{
    [textFieldUser resignFirstResponder];
    [textFieldPass resignFirstResponder];
}
- (IBAction)saveAccountButtonDidPress:(id)sender
{
    [self hideKeyboard:nil];
    
    //valida los campos...
    if (!textFieldUser.text || [textFieldUser.text isEqualToString:@""]) 
    {
        [self showNotificationWithMessage:@"Debes escribir tu correo institucional"];
        return;
    }
    else if(!textFieldPass.text || [textFieldPass.text isEqualToString:@""])
    {
        [self showNotificationWithMessage:@"Debes escribir tu contraseña"];
        return;
    }
    
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"]];
    if (!accounts) 
        accounts = [NSMutableArray array];

    NSString *passEnc = [textFieldPass.text AES256EncryptWithKey:secretKey];
    NSDictionary *userData = [NSDictionary dictionaryWithObjectsAndKeys:textFieldUser.text,@"user",passEnc,@"pass",nil];
    
    [accounts addObject:userData];
    
    [[NSUserDefaults standardUserDefaults] setObject:accounts forKey:@"accounts"];
    
    textFieldUser.text = @"";
    textFieldPass.text = @"";
    
    [tableViewAccounts reloadData];
    
}

- (IBAction)switchAutoConnectChangeValue:(id)sender
{
    if ([switchAutoConnect isOn])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"auto"];
        tryWithAll = YES;
        [self tryToConnectWithAccountAtIndex:0];
    }
    else
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auto"];
}


-(IBAction)buttonLogoutPressed:(id)sender
{
    [self hideKeyboard:nil];
        
    //manda logout
    NSString *post= @"userStatus=1";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/logout.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    [webHidden loadRequest:request];
    [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(webViewDidTimeOut:) userInfo:nil repeats:NO];
    timeOut = NO;
}
- (IBAction)infoButtonDidPress:(id)sender
{
    InfoViewController *info = [[InfoViewController alloc] initWithNibName:@"InfoView" bundle:[NSBundle mainBundle]];
    [info setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentModalViewController:info animated:YES];
    [info release];
}
/*******************************************************************************
 MÉTODOS PARA LAS NOTIFICACIONES
 ******************************************************************************/
-(void)showNotificationWithMessage:(NSString*)message
{
    CGFloat limit = 460;
    NSInteger index;
    for (index= 0; index < 8 ; index++) 
    {
        if (!notificationSlot[index]) 
        {
            notificationSlot[index] = YES;
            limit = limit-50*index;
            
            break;
        }
    }
    if (index==8) 
        return;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, limit, 310, 45)];
    [button setBackgroundColor:[UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0]];
    [button.titleLabel setFont:[UIFont fontWithName:@"Marker Felt" size:15.0]];
    [button.titleLabel setMinimumFontSize:8.0];
    [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [button.titleLabel setTextAlignment:UITextAlignmentCenter];
    [button setTitle:message forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setText:message];
    
    [button.layer setCornerRadius:10];
    [button.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [button.layer setBorderWidth:1.0];

    [button addTarget:self action:@selector(closeNotificationDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:index];
    [self.view insertSubview:button atIndex:20];
    [button release];
    
    [self animationStart:button];
    
    //[labelAux removeFromSuperview];
}
-(void)closeNotificationDidPress:(UIButton*)button
{
    //NSInteger index = [button tag];
    
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         button.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {}];
    
    notificationSlot[[button tag]] = NO;

    
}
-(void)animationStart:(UIButton*)button
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -50);
    [UIView animateWithDuration:0.5 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         button.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         //[self animationFinish:button];
                     }];
    
    [self performSelector:@selector(animationFinish:) withObject:button afterDelay:2.5];
}
-(void)animationFinish:(UIButton*)button
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(320, -50);
    [UIView animateWithDuration:0.3 
                          delay:0.0 
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         button.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         notificationSlot[[button tag]] = NO;
                         [button removeFromSuperview];
                     }];
    
    
}

/*******************************************************************************
 WEB VIEW DELEGATE
 ******************************************************************************/

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    //emiza a cargar, muestra el actitivy
    [activityIndicator setHidden:NO];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //oculta el activity
    [activityIndicator setHidden:YES];

    NSString *urlString = [NSString stringWithFormat:@"%@",[webView.request URL]];

    
    if([urlString isEqualToString:@"https://1.1.1.1/logout.html"])
    {
        [self showNotificationWithMessage:@"Te has desconectado correctamente"];
    }

}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSLog(@"SHOULD START: %@",[request URL]);
    
    NSString *urlString = [NSString stringWithFormat:@"%@",[request URL]];
    
    
    //si intenta cargar usm, entonces perfect
    if ([urlString isEqualToString:@"http://www.usm.cl/"] || [urlString hasSuffix:@"statusCode=1"]) 
    {
        [self showNotificationWithMessage:@"Te has conectado correctamente"];
        [activityIndicator setHidden:YES];
        timeOut = YES;
        return NO;
    }
    else if ([urlString hasSuffix:@"statusCode=3"] || [urlString hasSuffix:@"statusCode=2"])
    {
        [self showNotificationWithMessage:@"Tu usuario está utilizando por otro dispositivo"];
        [activityIndicator setHidden:YES];
        timeOut = YES;
        if(tryWithAll) [self tryToConnectWithAccountAtIndex:webView.tag+1];
        return NO;
        
    }
    else if ([urlString hasSuffix:@"statusCode=4"] || [urlString hasSuffix:@"statusCode=5"])
    {
        [self showNotificationWithMessage:@"Nombre de usuario o contraseña incorrectos"];
        [activityIndicator setHidden:YES];
        timeOut = YES;
        if(tryWithAll) [self tryToConnectWithAccountAtIndex:webView.tag+1];
        return NO;
        
    }
    
    
    return YES;
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator setHidden:YES];
    
    NSLog(@"FAIL! %@",error );
    
    if(tryWithAll) [self tryToConnectWithAccountAtIndex:webView.tag+1];

    
}
-(void)webViewDidTimeOut:(id)sender
{
    if ([webHidden isLoading] && !timeOut) 
    {
        [webHidden stopLoading];
        [self showNotificationWithMessage:@"Paso el tiempo máximo de espera"];
        timeOut = YES;
        if(tryWithAll) [self tryToConnectWithAccountAtIndex:webHidden.tag+1];

    }
    
}
/*******************************************************************************
 TEXT FIELD DELEGATE
 ******************************************************************************/

//el primero avancza al siguiente campo, y el otro envia..
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag]==777) 
    {
        [textFieldPass becomeFirstResponder];
    }
    else if([textField tag]==888)
    {
        [self saveAccountButtonDidPress:nil];
    }
    
    return YES;
}
/*******************************************************************************
 TABLEVIEW DELEGATES
 ******************************************************************************/
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSMutableArray *accounts = [[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
    NSDictionary *account = [accounts objectAtIndex:indexPath.row];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:22];
    cell.textLabel.minimumFontSize = 9.0;
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    [cell setSelectedBackgroundView:[[UIView alloc] autorelease]];
    
    cell.imageView.image = [UIImage imageNamed:@"email"];
    cell.textLabel.text = [account objectForKey:@"user"];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tryWithAll = NO;
    [self tryToConnectWithAccountAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"]];

    [accounts removeObjectAtIndex:indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setObject:accounts forKey:@"accounts"];
    
    [tableViewAccounts reloadData];
}

/*******************************************************************************
 FIN
 ******************************************************************************/
- (void)dealloc
{
    [super dealloc];
}

@end
