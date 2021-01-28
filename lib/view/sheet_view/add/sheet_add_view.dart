import 'package:flutter/material.dart';
import 'package:whisper/model/music_model.dart';
import 'package:whisper/service/data/config_data_service.dart';

typedef void TextFieldSubmitCallback(String value);
typedef void RadioChangeCallback(MusicSource source);

class SheetAddView extends StatefulWidget {
  @override
  State<SheetAddView> createState() => new _SheetAddViewState();

  final TextFieldSubmitCallback onTextChange; //提交事件
  final RadioChangeCallback onRadioChanged; //tab切换事件

  SheetAddView(this.onTextChange, this.onRadioChanged);
}

class _SheetAddViewState extends State<SheetAddView>
    with TickerProviderStateMixin {
  MusicSource source = MusicSource.unknow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          child: _buildTextField(),
          padding: EdgeInsets.all(15),
        ),
        _buildSelector(),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      style: Theme.of(context).textTheme.bodyText1,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 0),
        labelText: '输入歌单完整地址或ID',
        helperText: '浏览器中打开歌单详情，复制完整地址或ID',
      ),
      autofocus: true,
      onChanged: _textChanged,
    );
  }

  //歌单来源选择
  Widget _buildSelector() {
    var theme = Theme.of(context);

    //构造选项
    var childs = <Widget>[];
    for (var item in ConfigDataService.config.musicSourcSeq) {
      childs.add(RadioListTile(
        title: Text(
          item.desc,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color, fontSize: 14),
        ),
        value: item,
        groupValue: source,
        onChanged: (value) {
          setState(() {
            source = value;
          });
          widget.onRadioChanged?.call(value);
        },
        activeColor: theme.primaryColor,
        dense: true,
        secondary: Image.asset(
          "images/icon/${item.name}.png",
          width: 18,
          height: 18,
        ),
      ));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: childs,
    );
  }

  _textChanged(String url) {
    // https://www.kugou.com/yy/special/single/3385960.html
    // https://y.music.163.com/m/playlist?app_version=7.3.50&id=740915547&userid=56454789&creatorId=56454789
    // https://y.qq.com/n/yqq/playlist/7373665951.html
    // https://music.migu.cn/v3/music/playlist/183454210?page=1&from=migu
    // https://www.xiami.com/collect/1132777108
    try {
      //输入内容尝试解析
      Uri u = Uri.parse(url);

      //解析不出 直接返回原文
      var host = u.host;
      if (host == '') widget.onTextChange?.call(url);

      //根据host解析来源
      if (host.contains(".kugou.")) {
        setState(() {
          source = MusicSource.kugou;
        });
        widget.onRadioChanged?.call(source);

        //解析ID
        var id = u.pathSegments.last.replaceAll(new RegExp(r'.html'), '');
        widget.onTextChange?.call(id);
      }
      else if (host.contains(".163.")) {
        setState(() {
          source = MusicSource.netease;
        });
        widget.onRadioChanged?.call(source);

        //解析ID
        var id = u.queryParameters["id"];
        widget.onTextChange?.call(id);
      }
      else if (host.contains(".qq.")) {
        setState(() {
          source = MusicSource.tencent;
        });
        widget.onRadioChanged?.call(source);

        //解析ID
        var id = u.pathSegments.last.replaceAll(new RegExp(r'.html'), '');
        widget.onTextChange?.call(id);
      }
      else if (host.contains(".migu.")) {
        setState(() {
          source = MusicSource.migu;
        });
        widget.onRadioChanged?.call(source);

        //解析ID
        var id = u.pathSegments.last.replaceAll(new RegExp(r'.html'), '');
        widget.onTextChange?.call(id);
      }
      else if (host.contains(".xiami.")) {
        setState(() {
          source = MusicSource.xiami;
        });
        widget.onRadioChanged?.call(source);

        //解析ID
        var id = u.pathSegments.last.replaceAll(new RegExp(r'.html'), '');
        widget.onTextChange?.call(id);
      }
    } catch (exp) {
      widget.onTextChange?.call(url);
    }
  }
}
