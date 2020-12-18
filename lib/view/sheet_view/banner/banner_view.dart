//导航tab
import 'package:flutter/material.dart';
import 'package:whisper/model/sheet_model.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:whisper/view/sheet_view/banner/banner_item_view.dart';
import 'package:whisper/view/sheet_view/info/sheet_info_view.dart';

class BannerView extends StatefulWidget {
  BannerView(this.recomSheets);
  final List<SheetModel> recomSheets;

  @override
  _BannerViewState createState() => new _BannerViewState();
}

class _BannerViewState extends State<BannerView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return BannerItemView(widget.recomSheets[index]);
      },
      itemCount: widget.recomSheets.length,
      viewportFraction: 0.8,
      scale: 0.9,
      autoplay: true,
      autoplayDelay: 5000,
      autoplayDisableOnInteraction: true,
      onTap: (index) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SheetInfoView(widget.recomSheets[index]);
        }));
      },
    );
  }
}
