import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';

class PDFScreen  extends StatefulWidget {

  BuildContext context;
  PDFScreen(this.context);

  @override
  _PDFScreenState createState() => _PDFScreenState(context);
}

class _PDFScreenState extends State<PDFScreen> {
  BuildContext contet;
  _PDFScreenState(this.contet);
  String pathPDF = "";
  bool _isPDF = true;
  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;
        _isPDF = false;
        print(pathPDF);
      });
    });
  }

  Future<File> createFileOfPdfUrl() async {
    final url = "https://ncdc.gov.in/WriteReadData/l892s/10583471651584445527.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(contet) {
    return _isPDF ? Scaffold(
      appBar: AppBar(
          title: Text("CORONA COMIC",
              style: TextStyle(color: Colors.white,fontFamily: 'Girassol')),

        backgroundColor: Color(0xff243B55),

//          flexibleSpace: FlexibleSpaceBar(
//      stretchModes: <StretchMode>[
//             StretchMode.zoomBackground,
//              StretchMode.blurBackground,
//              StretchMode.fadeTitle,
//              ],
//            centerTitle: true,
//            title: const Text('National Center for Disease Control'),
//            background: Stack(
//                  fit: StackFit.expand,
//                    children: [
//                                Image.network(
//                                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
//                                fit: BoxFit.cover,
//                              ),
////        const DecoratedBox(
////            decoration: BoxDecoration(
////              gradient: LinearGradient(
////                begin: Alignment(0.0, 0.5),
////                end: Alignment(0.0, 0.0),
////                colors: <Color>[
////                  Color(0x60000000),
////                  Color(0x00000000),
////                ],
////              ),
////            )
////        )
//                    ]
//    )
//    ),






      ),
      body: Container(
        color: Color(0xff243B55),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              CircularProgressIndicator(),
              SizedBox(height: 10,),
              Text("Loading from 'ncdc.gov.in'",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,

          ),
              )
            ],
          )

        ),
      ),
    )
    : PDFViewerScaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff243B55),
            title: Text("CORONA COMIC",style: TextStyle(color: Colors.white,fontFamily: 'Girassol'))),
        path: pathPDF);
  }
}
