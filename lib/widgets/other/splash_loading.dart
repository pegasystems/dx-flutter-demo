// Copyright 2020 Pegasystems Inc. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SplashLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Container(
      color: Color(0xFF1F2555),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/pega.svg',
            color: Colors.white,
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Dx', style: TextStyle(color: Colors.lightBlue, fontSize: 60),),
                Text('F', style: TextStyle(color: Colors.purpleAccent, fontSize: 60),),
              ]
            )
          ),
          Container(
            padding: EdgeInsets.only(top: 15),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF295ED9)),
            )
          )
        ],
      )
    ));
  }
}
