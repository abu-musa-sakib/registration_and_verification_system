import 'package:flutter/material.dart';
import 'package:registration_and_verification_system/authenticate_face/authenticate_face_view_auto.dart';
import 'package:registration_and_verification_system/authenticate_face/authenticate_face_view_manual.dart';
import 'package:registration_and_verification_system/common/utils/extensions/size_extension.dart';
import 'package:registration_and_verification_system/common/utils/custom_button.dart';
import 'package:registration_and_verification_system/common/views/check_user_view.dart';
import 'package:registration_and_verification_system/constants/theme.dart';

class VerificationOptionsView extends StatelessWidget {
  const VerificationOptionsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Verification Options"),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldTopGradientClr,
              scaffoldBottomGradientClr,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Choose option",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 0.033.sh,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.07.sh),
              CustomButton(
                text: "Automatic",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AuthenticateFaceViewAuto(),
                    ),
                  );
                },
              ),
              SizedBox(height: 0.025.sh),
              CustomButton(
                text: "Manual",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AuthenticateFaceViewManual(),
                    ),
                  );
                },
              ),
              SizedBox(height: 0.025.sh),
              CustomButton(
                text: "Verify by ID",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CheckUserView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
