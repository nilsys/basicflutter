import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  return runApp(MaterialApp(home: MyTodoRedis(),));
}

class MyTodoRedis extends StatefulWidget {
  @override
  _MyTodoRedisState createState() => _MyTodoRedisState();
}

class _MyTodoRedisState extends State<MyTodoRedis> {

  Map<String, dynamic> uiData;
  final TextEditingController _tc = new TextEditingController(text: "");

  Future<Map<String,dynamic>> _getData() async{
    try{
      final http.Response _res = await http.get("http://127.0.0.1:3000/data/get?key=key");
      return _parse(res: _res);
    }
    catch(e){
      return null;
    }

  }
  static Future<Map<String, String>> _toMap(Map<String, dynamic> data) async
   => {data.keys.toList()[0].toString() : data[data.keys.toList()[0]].toString()};

  Future<Map<String, dynamic>> _parse({http.Response res}) async{
    final Map<String, dynamic> _result = json.decode(res.body);
    return compute(_toMap, _result);
  }
  Future<void> _saveData({String data}) async{
    if(data.isEmpty) return;
    final http.Response _res = await http.post("http://127.0.0.1:3000/data/set?key=key&value=$data");
    final bool _check = json.decode(_res.body);
    if(!_check) return;
    _tc.text = "";
    return await _uiResetData();
  }

  Future<void> _uiResetData() async{
    this.uiData = await _getData();
    if(uiData == null){
      return Future.delayed(Duration(seconds: 8), () => _uiResetData());
    }
    setState(() {});
    return;
  }

  Widget _uiDataView({@required Map<String, dynamic> uiData}) => uiData == null
    ? Text("Load...")
    : Text(this.uiData['key'].toString());

  @override
  void initState() {
    Future.microtask(() async => _uiResetData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Node.js & Redis"),),
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: _tc,
                      decoration: InputDecoration(
                        fillColor: Colors.grey[300],
                        filled: true,
                        border: InputBorder.none,
                        hintText: "입력해주세요"
                      ),
                    )
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: ElevatedButton(
                    child: Text("Save"),
                    onPressed: () async => await _saveData(data: _tc.text),
                  ),
                )
              ],
            )
          ),
          Expanded(child: _uiDataView(uiData: this.uiData))
        ],
      ),
    );
  }
}
