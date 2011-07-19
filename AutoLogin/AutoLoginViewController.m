//
//  AutoLoginViewController.m
//  AutoLogin
//
//  Created by Camilo Andrés Vera Bezmalinovic on 6/15/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
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
    //fondo al navigation
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 43)];
    [bgView setBackgroundColor:[UIColor colorWithRed:0 green:200.0/255.0 blue:245.0/255.0 alpha:0.5]];
    [navBar insertSubview:bgView atIndex:0];
    [bgView release];
    
    //si tiene los datos guardados, los recupera
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
    if (username) 
    {
        [user setText:username];
    }
    if (password) 
    {
        [pass setText:password];
    }
    
}

//esconde los teclados
-(IBAction)hideKeyboard:(id)sender
{
    [user resignFirstResponder];
    [pass resignFirstResponder];
}

//si cambia el switch, elimna lo guardado o guarda
-(IBAction)switchSaveChangeValue:(id)sender
{
    if ([save isOn]) 
    {
        [[NSUserDefaults standardUserDefaults] setObject:user.text forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] setObject:pass.text forKey:@"pass"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pass"];
    }
}
-(IBAction)buttonLoginPressed:(id)sender
{
    
    if (![Connection checkWithAlert:YES]) 
    {
        return;
    }
    
    //valida los campos...
    if (!user.text || [user.text isEqualToString:@""]) 
    {
        [UIAlertView showAdviceWithMessage:@"Debe escribir su correo institucional"];
        return;
    }
    else if(!pass.text || [pass.text isEqualToString:@""])
    {
        [UIAlertView showAdviceWithMessage:@"Debe escribir su contraseña"];
        return;
    }
    
    //guarda los datos si es necesario
    [self switchSaveChangeValue:nil];
    
    //prepara la consulta
    NSString *post= [NSString stringWithFormat:@"username=%@&password=%@&buttonClicked=4",user.text,pass.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/login.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    //carga la consulta en un webView
    [web loadRequest:request];
    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    //emiza a cargar, muestra el actitivy
    [loading setHidden:NO];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //oculta el activiti
    [loading setHidden:YES];
    NSString *urlString = [NSString stringWithFormat:@"%@",[webView.request URL]];

    
    //si llega a usm, entonces perfect
    if ([urlString isEqualToString:@"http://www.usm.cl/"]) 
    {
        [UIAlertView showAdviceWithMessage:@"Se ha autentificado correctamente"];
    }
    else if([urlString isEqualToString:@"https://1.1.1.1/logout.html"])
    {
        [UIAlertView showAdviceWithMessage:@"Se ha desautentificado correctamente"];
    }
}


-(IBAction)buttonLogoutPressed:(id)sender
{
    if (![Connection checkWithAlert:YES]) 
    {
        return;
    }
    
    [self switchSaveChangeValue:nil];
    
    //manda logout
    NSString *post= @"userStatus=1";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/logout.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    
    [web loadRequest:request];

}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag]==777) 
    {
        [pass becomeFirstResponder];
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
