import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:album_manager/album_manager.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final List<String> _btnTitles = ['保存图片二进制到相册', '视频二进制保存到相册'];
  final List<String> _remoteurl = [
    'http://192.168.1.4:8080/uploads/4/0B257318-3EFE-4FB6-8AF5-4E8B5E4D512F-L0-001.heic',
    'http://192.168.1.4:8080/uploads/4/8BC8290D-ACB1-4859-B224-7C7775D44ABB-L0-001.mp4',
  ];

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await AlbumManager.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              const Expanded(
                  child: SizedBox(
                height: 50,
              )),
              Expanded(child: Text('Running on: $_platformVersion\n')),
              Expanded(
                  flex: 8,
                  child: Container(
                    constraints: const BoxConstraints.tightFor(width: 200),
                    child: ListView.builder(
                        // padding: const EdgeInsets.all(20),
                        itemCount: _btnTitles.length,
                        itemBuilder: (context, idx) => ElevatedButton(
                              onPressed: () => onPressed(context, idx),
                              child: Text(
                                _btnTitles[idx],
                              ),
                            )),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void onPressed(BuildContext context, int idx) {
    showDialog(
        context: context,
        builder: (c) {
          return CupertinoAlertDialog(
            title: const Text(
              '正在保存',
            ),
            content: _readerDownloadProgress(c, idx),
            actions: [
              TextButton(
                style: TextButton.styleFrom(alignment: Alignment.center),
                onPressed: () {
                  Navigator.pop(c);
                },
                child: const Text('取消'),
              )
            ],
          );
        });
  }

  _readerDownloadProgress(BuildContext c, int idx) {
    double progress = 0;
    StateSetter? stateSetter;
    var url = _remoteurl[idx];
    print(url);
    getTemporaryDirectory().then((tmpDir) {
      var name = url.substring(url.lastIndexOf('/') + 1);
      var savePath = '${tmpDir.path}/$name';
      _dio.download(url, savePath, onReceiveProgress: (int cur, int total) {
        progress = cur / total;
        if (null != stateSetter) {
          stateSetter!(() {});
        }
      }).then((response) {
        stateSetter = null;
        var ext = name.substring(name.lastIndexOf('.') + 1).toLowerCase();
        if (RegExp(r'^(png|jpeg|heic|jpg)?$').hasMatch(ext)) {
          AlbumManager.saveToAlbum(savePath, title: name, mimeType: 'image/png', albumName: 'image_sync')
              .then((value) => {Navigator.pop(c)});
        } else if (RegExp(r'^(mp4|avi|mov|rmvb)?$').hasMatch(ext)) {
          AlbumManager.saveToAlbum(savePath, title: '1$name', mimeType: 'video/mp4', albumName: 'image_sync')
              .then((value) => {Navigator.pop(c)});
        }
      });
    });

    return StatefulBuilder(builder: (BuildContext context, state) {
      stateSetter = state;
      return Text('已完成${(progress * 100).toInt()}%');
    });
  }
}
