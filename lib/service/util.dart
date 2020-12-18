class Util{
  /// 播放量显示处理
    static String playNumsFormat(String playNumsStr){
        var playInt = int.tryParse(playNumsStr);
        if(playInt == null){
          return playNumsStr.replaceFirst("万", "W");
        }
        else{
          if(playInt/10000>0){
            var res = (playInt/10000).toStringAsFixed(1);
            return "${res}W";
          }
          else if(playInt/1000>0){
            var res = (playInt/1000).toStringAsFixed(1);
            return "${res}K";
          }
          else{
            return playNumsStr;
          }
        }
    }
}