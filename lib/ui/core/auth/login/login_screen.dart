import 'package:flutter/material.dart';
import 'package:flutter_application_test/data/const/image_urls.dart';
import 'package:flutter_application_test/routes/app_routes.dart';
import 'package:flutter_application_test/ui/core/auth/login/widgets/login_bottom_sheet.dart';
import 'package:flutter_application_test/ui/core/ui/theme/app_theme.dart';
import 'package:flutter_application_test/ui/core/ui/widgets/custom_elevated_buttom.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: 
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ 
                Image.asset(ImageUrls.appTitle, width: 250,),
                Image.asset(ImageUrls.appLogo, width: 200,),
                Column(
                  children: [
                    CustomFilledButton(
                      label: 'Entrar',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => LoginBottomSheet(),
                        );
                      },
                      backgroundColor: AppTheme.primary,
                    ),
                    SizedBox(height: 4.0),
                    CustomOutlinedButton(
                      label: 'Criar conta',
                      onPressed: () {
                        navigatorKey.
                        currentState?.
                        pushNamed
                        (AppRoutes.accountCreationScreen);
                      }, 
                      borderColor: AppTheme.primary,
                      textColor: AppTheme.primary,
                    ),
                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}