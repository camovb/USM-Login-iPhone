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

//para evitar paja de escribir
@interface UIAlertView(Advice)
+ (void) showAdviceWithMessage:(NSString*)message;
@end
@implementation UIAlertView(Advice)
+ (void) showAdviceWithMessage:(NSString*)message
{
    [[[[UIAlertView alloc] initWithTitle:@"Aviso" message:message delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil] autorelease] show];
}
@end



@implementation AutoLoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    //fondo al navigation (43 para que se vea la linea)
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 43)];
    [bgView setBackgroundColor:[UIColor colorWithRed:0 green:200.0/255.0 blue:245.0/255.0 alpha:0.5]];
    [navBar insertSubview:bgView atIndex:0];
    [bgView release];
    
    //si tiene los datos guardados, los recupera
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
    if (username) 
    {
        [textFieldUser setText:username];
    }
    if (password) 
    {
        [textFieldPass setText:password];
    }
    
    NSNumber *autoConnect = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto"];
    
    if (autoConnect && [autoConnect boolValue]) 
    {
        [switchAutoConnect setOn:YES];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidBecomeActive:) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:nil];
    
}

//si tiene guardado que intente conectar al iniciar...
-(void)applicationDidBecomeActive:(id)sender
{
    NSLog(@"Active");
    
    NSNumber *autoConnect = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto"];
    
    if (autoConnect && [autoConnect boolValue]) 
    {
        [self buttonLoginPressed:nil];
    }
}

//esconde los teclados
-(IBAction)hideKeyboard:(id)sender
{
    [textFieldUser resignFirstResponder];
    [textFieldPass resignFirstResponder];
}

//si cambia el switch, elimna lo guardado o guarda
-(IBAction)switchSaveChangeValue:(id)sender
{
    if ([switchRemember isOn]) 
    {
        [[NSUserDefaults standardUserDefaults] setObject:textFieldUser.text forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] setObject:textFieldPass.text forKey:@"pass"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pass"];
    }
    
    //si la acción la envia el boton
    if (sender) 
    {
        if ([switchRemember isOn]) 
        {
            [switchAutoConnect setEnabled:YES];
        }
        else
        {
            [switchAutoConnect setEnabled:NO];
            [switchAutoConnect setOn:NO animated:YES];
        }
    }
}
- (IBAction)switchAutoConnectChangeValue:(id)sender
{
    if ([switchAutoConnect isOn]) 
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"auto"];
        [[NSUserDefaults standardUserDefaults] setObject:textFieldUser.text forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] setObject:textFieldPass.text forKey:@"pass"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auto"];
    }
}

-(IBAction)buttonLoginPressed:(id)sender
{
    
    //valida los campos...
    if (!textFieldUser.text || [textFieldUser.text isEqualToString:@""]) 
    {
        [UIAlertView showAdviceWithMessage:@"Debe escribir su correo institucional"];
        return;
    }
    else if(!textFieldPass.text || [textFieldPass.text isEqualToString:@""])
    {
        [UIAlertView showAdviceWithMessage:@"Debe escribir su contrase√±a"];
        return;
    }
    
    //guarda los datos si es necesario
    [self switchSaveChangeValue:nil];
    
    //prepara la consulta
    NSString *post= [NSString stringWithFormat:@"username=%@&password=%@&buttonClicked=4",textFieldUser.text,textFieldPass.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/login.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    //carga la consulta en un webView
    [webHidden loadRequest:request];
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(webViewTimeOut:) userInfo:nil repeats:NO];
    timeOut = NO;
    
}
-(IBAction)buttonLogoutPressed:(id)sender
{
    
    [self switchSaveChangeValue:nil];
    
    //manda logout
    NSString *post= @"userStatus=1";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/logout.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    [webHidden loadRequest:request];
    [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(webViewTimeOut:) userInfo:nil repeats:NO];
    timeOut = NO;
    
}


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
        [UIAlertView showAdviceWithMessage:@"Se ha desautentificado correctamente"];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSLog(@"SHOULD START: %@",[request URL]);
    
    NSString *urlString = [NSString stringWithFormat:@"%@",[request URL]];
    
    //si intenta cargar usm, entonces perfect
    if ([urlString isEqualToString:@"http://www.usm.cl/"]) 
    {
        [UIAlertView showAdviceWithMessage:@"Se ha autentificado correctamente"];
        [activityIndicator setHidden:YES];
        timeOut = YES;
        return NO;
    }
    
    
    return YES;
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator setHidden:YES];
    
    if (!timeOut) 
    {
        [UIAlertView showAdviceWithMessage:@"Asegurese de estar conectado a una red WIFI"];

    }
   
}
-(void)webViewTimeOut:(id)sender
{
    if ([webHidden isLoading]) {
        [activityIndicator setHidden:YES];
        [webHidden stopLoading];
        timeOut = YES;
        [UIAlertView showAdviceWithMessage:@"Ha pasado el tiempo máximo de espera..."];

    }
    
}


//el primero avancza al siguiente campo, y el otro envia..
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag]==777) 
    {
        [textFieldPass becomeFirstResponder];
    }
    else if([textField tag]==888)
    {
        [self buttonLoginPressed:nil];
    }
    
    return YES;
}


- (void)dealloc
{
    [super dealloc];
}

@end
