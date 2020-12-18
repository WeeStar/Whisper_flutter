import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whisper/service/http/api_service.dart';
import 'package:whisper/view/sheet_view/banner/banner_view.dart';
import 'package:whisper/view/sheet_view/recom/sheet_recom_list.dart';

class MainViewRecom extends StatelessWidget {
  MainViewRecom(this.recomSheets);
  final List<RecomModel> recomSheets;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, position) {
          if (position == 0) {
            return SizedBox(
                height: width * 0.95,
                child: BannerView(recomSheets
                    .map((e) =>
                        e.sheets[new Random().nextInt(e.sheets.length - 1)])
                    .toList()));
          }
          return SheetRecomListView(recomSheets[position - 1]);
        },
        itemCount: recomSheets.length + 1,
        separatorBuilder: (context, index) {
          return Divider(
            height: 0.1,
            indent: 20,
            color: Theme.of(context).disabledColor,
          );
        },
      ),
    );
  }
}
