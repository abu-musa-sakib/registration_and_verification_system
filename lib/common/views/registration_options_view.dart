import 'package:flutter/material.dart';
import 'package:registration_and_verification_system/common/utils/extensions/size_extension.dart';
import 'package:registration_and_verification_system/common/utils/custom_button.dart';
import 'package:registration_and_verification_system/constants/theme.dart';
import 'package:registration_and_verification_system/register_face/register_face_view_auto.dart';
import 'package:registration_and_verification_system/register_face/register_face_view_manual.dart';

class RegistrationOptionsView extends StatelessWidget {
  const RegistrationOptionsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Registration Options"),
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
                      builder: (context) => RegisterFaceViewAuto(),
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
                      builder: (context) => const RegisterFaceViewManual(),
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
