import 'package:flutter/material.dart';
import '../globals/myFonts.dart';
import '../globals/sizeConfig.dart';

class AuthScreenIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.horizontalBlockSize * 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: SizeConfig.screenHeight * 0.08,
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 28,
              child: Text(
                "TF",
                style: MyFonts.bold
                    .factor(8)
                    .setColor(Colors.blue[800]!)
                    .copyWith(fontSize: 18),
              ),
            ),
            SizedBox(
              height: SizeConfig.screenHeight * 0.02,
            ),
            Text(
              "Vamos começar",
              style: MyFonts.bold.factor(9),
            ),
            SizedBox(
              height: SizeConfig.screenHeight * 0.02,
            ),
            Text(
              "Planeje eventos com facilidade",
              style: MyFonts.medium.factor(4),
            ),
          ],
        ),
      ),
    );
  }
}
