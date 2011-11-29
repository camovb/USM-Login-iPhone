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

NSString *secretKey = @"key";

@implementation AutoLoginViewController
@synthesize textFieldUser,textFieldPass,rememberOption,rememberOptionLabel;
@synthesize activityIndicator;
@synthesize containerView;
@synthesize logo;
@synthesize extensionButton,loginButton,logoutButton;
@synthesize notificationView,notificationLabel,notificationImage;
@synthesize rememberView,rememberLabel;


/*******************************************************************************
 MÉTODOS DE INICIO
 ******************************************************************************/

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    webHidden = [[UIWebView alloc] init];
    webHidden.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidBecomeActive:) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:nil];
    
    //color más oscuro a los placeholders
    [textFieldUser setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [textFieldPass setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    //agrega la view sobre la otra..
    [[textFieldUser superview] addSubview:rememberView];
    
    //rescata si está recordado.. y actualiza los switch
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    BOOL on = [[UD objectForKey:@"remember"] boolValue];
    
    rememberOption.on = on;
    
    //hace visible la view y agrega los datos.
    if (on) 
    {
        rememberView.alpha = 1.0;
        rememberView.userInteractionEnabled=YES;
        
        rememberOptionLabel.alpha = 1.0;
        rememberOption.alpha = 1.0;
        
        NSString *user = [UD objectForKey:@"user"];
        NSString *extension = [UD objectForKey:@"extension"];
        
        rememberLabel.text = [user stringByAppendingString:extension];

    }
    else
    {
        rememberView.alpha = 0.0;
        [rememberView setUserInteractionEnabled:NO];
        
        rememberOptionLabel.alpha = 0.0;
        rememberOption.alpha = 0.0;
    }
    
    if (!on && (textFieldPass.text.length == 0 || textFieldUser.text.length == 0))
    {
        loginButton.alpha = 0.0;
        logoutButton.alpha = 0.0;
    }

}


//si tiene guardado que intente conectar al iniciar...
-(void)applicationDidBecomeActive:(id)sender
{   
    NSString *passEnc = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
    
    textFieldUser.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    textFieldPass.text = [passEnc AES256DecryptWithKey:secretKey];
    
    NSString *title = [[NSUserDefaults standardUserDefaults] objectForKey:@"extension"];
    
    
    
    if (!title || [title isEqualToString:@""]) 
        [extensionButton setTitle:@"@alumnos.usm.cl" forState:UIControlStateNormal];
    else
        [extensionButton setTitle:title forState:UIControlStateNormal];
    
    
    rememberOption.enabled = YES;
    if (!textFieldUser.text || [textFieldUser.text isEqualToString:@""]) 
    {
        rememberOption.on=NO;
        rememberOption.enabled = NO;
        return;
    }
    else if(!textFieldPass.text || [textFieldPass.text isEqualToString:@""])
    {
        rememberOption.on=NO;
        rememberOption.enabled = NO;
        return;
    } 
    
    [self tryToConnect];
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
    
    [self showNotificationMessage:@"Debes estar conectado a una red USM" isSuccess:NO];
    
    return NO;
}


- (void)tryToConnect
{
    [self hideKeyboard:nil];
    
    if (![self isUsmNetwork])
        return;

    NSString *user = textFieldUser.text;
    NSString *extension = extensionButton.titleLabel.text;
    NSString *pass = textFieldPass.text;
    
    if (!user || [user isEqualToString:@""] || !pass || [pass isEqualToString:@""])
        return;
    
    //prepara la consulta
    NSString *post= [NSString stringWithFormat:@"username=%@%@&password=%@&buttonClicked=4",user,extension,pass];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/login.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    //carga la consulta en un webView
    [webHidden loadRequest:request];
        
    [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(webViewDidTimeOut:) userInfo:nil repeats:NO];
    timeOut = NO;
}


- (void)inputFilled:(BOOL)isFilled
{
    if (isFilled)
    {
        rememberOption.enabled = YES;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             self.rememberOptionLabel.alpha = 1.0;
             self.rememberOption.alpha = 1.0;
             self.loginButton.alpha = 1.0;
         } completion:^(BOOL finished) {}];
    }
    else
    {
        rememberOption.enabled = NO;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             self.rememberOptionLabel.alpha = 0.0;
             self.rememberOption.alpha = 0.0;
             self.loginButton.alpha = 0.0;
         } completion:^(BOOL finished) {}];
    }
}


/*******************************************************************************
 MÉTODOS DE INTERFAZ
 ******************************************************************************/

//esconde los teclados
- (IBAction)hideKeyboard:(id)sender
{
    [textFieldUser resignFirstResponder];
    [textFieldPass resignFirstResponder];
    CGRect frame = containerView.frame;
    
    if (frame.origin.y == -105)
    {
        frame.origin.y = 0;
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            containerView.frame = frame;
            logo.alpha = 1;
        } completion:^(BOOL finished) {}];
    }
}


- (IBAction)loginButtonDidPress:(id)sender
{
    [self hideKeyboard:nil];
    
    //valida los campos...
    if (!textFieldUser.text || [textFieldUser.text isEqualToString:@""]) 
    {
        [self showNotificationMessage:@"Debes escribir tu correo institucional" isSuccess:NO];
        return;
    }
    else if(!textFieldPass.text || [textFieldPass.text isEqualToString:@""])
    {
        [self showNotificationMessage:@"Debes escribir tu contraseña" isSuccess:NO];
        return;
    }
    
    [self tryToConnect];
}


- (IBAction)extensionButtonDidPress:(id)sender
{
    UIButton *button = sender;
    NSString *title = button.titleLabel.text;
    
    if ([title isEqualToString:@"@alumnos.usm.cl"]) 
    {
        [button setTitle:@"@usm.cl" forState:UIControlStateNormal];
    }
    else
    {
        [button setTitle:@"@alumnos.usm.cl" forState:UIControlStateNormal];
    }
}


- (IBAction)buttonLogoutPressed:(id)sender
{
    [self hideKeyboard:nil];
        
    if (![self isUsmNetwork]) 
        return;
    
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


- (IBAction)rememberOptionDidChange:(id)sender
{
    UISwitch *sw = sender;
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    
    if ([sw isOn]) 
    {
        NSString *user = textFieldUser.text;
        NSString *pass = [textFieldPass.text AES256EncryptWithKey:secretKey];
        NSString *extension = extensionButton.titleLabel.text;
        
        [UD setObject:user      forKey:@"user"];
        [UD setObject:pass      forKey:@"pass"];
        [UD setObject:extension forKey:@"extension"];
        [self hideKeyboard:nil];
        
        rememberOptionLabel.text = @"Olvídame";
        rememberLabel.text = [user stringByAppendingString:extension];
        rememberView.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            rememberView.alpha = 1;
        } completion:^(BOOL finished) {}];
    }
    else
    {
        rememberOptionLabel.text = @"Recuerdame";
        
        rememberView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            rememberView.alpha = 0;
        } completion:^(BOOL finished) {}];
        
        
        [UD removeObjectForKey:@"user"];
        [UD removeObjectForKey:@"pass"];
        [UD removeObjectForKey:@"extension"];
    }
    
    [UD setObject:[NSNumber numberWithBool:sw.on] forKey:@"remember"];
}


/*******************************************************************************
 MÉTODOS PARA LAS NOTIFICACIONES
 ******************************************************************************/

- (void)showNotificationMessage:(NSString*)message isSuccess:(BOOL)success;
{
    NSLog(@"Notification: %@",message);
    
    notificationLabel.text = message;
    
    if (success) 
    {
        notificationImage.image = [UIImage imageNamed:@"image-notification-success"];
    }
    else
        notificationImage.image = [UIImage imageNamed:@"image-notification-fail"]; 
    
    [UIView animateWithDuration:0.7
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         notificationView.alpha=1;
                     } completion:^(BOOL finished) {
                         
                     }];
    
    [self performSelector:@selector(notificationDidPress:) withObject:nil afterDelay:2];
}


- (IBAction)notificationDidPress:(id)sender
{
    [UIView animateWithDuration:0.5 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         notificationView.alpha=0;
                     } completion:^(BOOL finished) {
                         
                     }];
}


/*******************************************************************************
 WEB VIEW DELEGATE
 ******************************************************************************/

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    //empieza a cargar, muestra el actitivy
    [activityIndicator setHidden:NO];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //oculta el activity
    [activityIndicator setHidden:YES];

    NSString *url = [[webView.request URL] absoluteString];

    if([url isEqualToString:@"https://1.1.1.1/logout.html"])
    {
        [self showNotificationMessage:@"Te has desconectado correctamente" isSuccess:YES];
        logoutButton.userInteractionEnabled = NO;
        loginButton.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            logoutButton.alpha = 0;
            loginButton.alpha = 1;
        } completion:^(BOOL finished) {}];
    }

}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
        
    NSString *url = [[request URL] absoluteString];
    NSLog(@"url: %@",url);
    //busca el status code
    NSRange r = [url rangeOfString:@"statusCode="];
    NSInteger status = 0;
    if (r.location != NSNotFound) 
        status = [[url substringWithRange:NSMakeRange(r.location+r.length, 1)] intValue];
    
    //si intenta cargar usm, entonces perfect
    if ([url isEqualToString:@"http://www.usm.cl/"] || status==1)
    {
        [self showNotificationMessage:@"Te has conectado correctamente" isSuccess:YES];
        
        loginButton.userInteractionEnabled = NO;
        logoutButton.userInteractionEnabled=YES;
        [UIView animateWithDuration:0.5 animations:^{
            loginButton.alpha = 0;
            logoutButton.alpha = 1;
        } completion:^(BOOL finished) {}];
        
        [activityIndicator setHidden:YES];
        timeOut = YES;
        
        return NO;
    }
    else if (status==2 || status==3)
    {
        [self showNotificationMessage:@"Tu usuario está utilizando por otro dispositivo" isSuccess:NO];
        [activityIndicator setHidden:YES];
        timeOut = YES;
        
        return NO;
    }
    else if (status==4 || status==5)
    {
        [self showNotificationMessage:@"Nombre de usuario o contraseña incorrectos" isSuccess:NO];
        [activityIndicator setHidden:YES];
        timeOut = YES;
        
        return NO;   
    }

    
    
    return YES;
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator setHidden:YES];
}


-(void)webViewDidTimeOut:(id)sender
{
    if ([webHidden isLoading] && !timeOut) 
    {
        [webHidden stopLoading];
        [self showNotificationMessage:@"Paso el tiempo máximo de espera" isSuccess:NO];
        timeOut = YES;

    }
}


/*******************************************************************************
 TEXT FIELD DELEGATE
 ******************************************************************************/

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect frame = containerView.frame;
    
    if (frame.origin.y == 0) {
        frame.origin.y = -105;
        
        [UIView animateWithDuration:0.3 
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
            containerView.frame = frame;
            logo.alpha = 0;
        } completion:^(BOOL finished) {}];
    }

    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == loginTagUserTextField) 
    {
        [textFieldPass becomeFirstResponder];
    }
    else
    {
        [self tryToConnect];
    }
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSLog(@"newText: %@",newText);

    //de esta forma valida que ambos campos de texto estén completos
    if (textField.tag == loginTagUserTextField)
    {
        if ([newText length] > 0 && [textFieldPass.text length] > 0) 
            [self inputFilled:YES];
        else
            [self inputFilled:NO];
    }
    else
    {
        if ([newText length] > 0 && [textFieldUser.text length] > 0) 
            [self inputFilled:YES];
        else
            [self inputFilled:NO];
    }

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    
    
    [self inputFilled:NO];
    
    return YES;
}


/*******************************************************************************
 FIN
 ******************************************************************************/

- (void)dealloc
{
    [textFieldUser release];
    [textFieldPass release];
    [rememberOption release];
    [rememberOptionLabel release];
    [activityIndicator release];
    [webHidden release];
    [containerView release];
    [logo release];
    [extensionButton release];
    [loginButton release];
    [logoutButton release];
    
    [notificationView release];
    [notificationLabel release];
    [notificationImage release];
    
    [rememberView removeFromSuperview];
    [rememberView release];
    [rememberLabel release];
    
    [super dealloc];
}

@end
