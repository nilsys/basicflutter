import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:redis/redis.dart';
// https://pub.dev/packages/redis
// 직접 연결
// - 서버를 통해 실행(Redis와 직접 연결은 정책상 통과하지 못 할 수 있음. Dart 서버사이드에서 사용하기 위함. ex/ dart-angel )
// - IOS 테스트는 가능
// - Android 직접 연결 테스트 불가

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  return runApp(MaterialApp(home: MyRedis(),));
}

class MyRedis extends StatefulWidget {
  @override
  _MyRedisState createState() => _MyRedisState();
}

class _MyRedisState extends State<MyRedis> {
  RedisConnection conn = new RedisConnection();
  @override
  void initState() {
    Future.microtask(() async => await conn.connect('localhost',6379)
        .then((Command command) async{
          await command.send_object( ["SET","key","SET REDIS DATA!"] )
            .then((var response) async{
              print("response : $response");
              print(response.runtimeType);
              return;
            });
          String data = await command.send_object(["GET","key"])
            .then((var response) => response.toString()) ?? "Redis";
          print("DATA1 : $data");
          return;
        }));
    Future.microtask(() async => await conn.connect('localhost',6379)
      .then((Command command) async{

        // null ?? "value"
        String data = await command.send_object(RedisQuery.getQuery(key: RedisQuery.KEY)) ?? "Redis2";
        print("DATA2 : $data");

        // List Data : SET
        await command.send_object(["SET",'key2','["2","key1","key2","first","second"]']);
        var data2 = await command.send_object(RedisQuery.getQuery(key: 'key2'));
        print("data2 : $data2");
        print(json.decode(data2)[0]);

        // List Data : SET Encode -> GET Decode
        List lData = [1,2,3,4,5];
        String lDataEn = json.encode(lData);
        await command.send_object(["SET",'key3',lDataEn]);
        var data3 = await command.send_object(RedisQuery.getQuery(key: 'key3'));
        print("data3 : $data3");
        List lDataDe = json.decode(data3);
        print(lDataDe[0]);
        return;
      })
    );

    super.initState();
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Redis"),));
}

class RedisQuery{

  static const String KEY = "key33";

  static List<String> setQuery({@required String key, @required String value}){
    assert(key != null);
    assert(value != null);
    return ["SET", key, value];
  }

  static List<String> getQuery({@required String key}){
    assert(key != null);
    return ["GET", key];
  }

}
