import 'dart:math';
import 'dart:ui';
import 'package:CoronaTV/pdf.dart';
import 'package:app_settings/app_settings.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:call_number/call_number.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:share/share.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'Infect.dart';
import 'package:flutter/services.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

const String testDevice = ' ';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Corona TV",
      theme: ThemeData(
        accentColor: Colors.red,
      ),
      home: CoVIn(),
    ),
  );
}

class CoVIn extends StatefulWidget {
  @override
  _CoVInState createState() => _CoVInState();
}

class _CoVInState extends State<CoVIn> with TickerProviderStateMixin {
  TextStyle slidingHeadking = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>[
      'insurance',
      'sports',
      'financial',
      'facebook',
      'corona',
      'hospital',
      'covid',
      'china',
      'india'
    ],
  );

  InterstitialAd _interstitialAd;
  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        adUnitId: 'ca-app-pub-1476007057124353/3778188947',
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("InterstitialAd $event");
        });
  }

  var currentItemSelected = null;
  List regionalData, summary;
  int districtIndex = -1;
  int showIndex = -1, stateIndex = -1;
  bool playing = true;
  String msg =
      "Hi! check out this app -CoronaTV to keep updated about the latest "
      "COVID-19 infected, deaths, recovered cases of all countries. Also,Indian "
      "state wise data is also available with graphs. Also get to know much more "
      "about virus- history, symptoms, prcautions, emergency helpline etc . "
      "Dowload now to know more. https://prayant-gupta.itch.io/corona-tv ";
  bool showStatesInfo = false;
  bool showAboutApp = false;
  bool showAboutMe = false;
  bool dataforGraph = false;
  bool showSummary = false;
  bool showGraph = false;
  int contactIndex = -1;
  bool showAbout = false;
  bool isCollapsed = true; //change1
  bool showWorld = true;
  List<String> stateList;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 500);
  AnimationController _controller;
  AnimationController _insidecontroller;
  Animation<Offset> _slideAnimation;
  Animation _fadeAnimation;
  Animation _insidefadeAnimation;
  Animation<double> _scaleAnimation;
  var itemToShow;
  var summaryData;
  var timeData;
  var data2;
  var contactData;
  var date1;
  var extractdata4, extractdata5;
  StreamSubscription<DataConnectionStatus> listener;
  GlobalKey<RefreshIndicatorState> refreshKey;

  Future<String> make_request() async {
    stateList = new List<String>();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    var status = await checkInternet();
    Fluttertoast.showToast(
      msg: "Refreshing",
      //textColor: Colors.blue,
      toastLength: Toast.LENGTH_LONG,
    );
    debugPrint("make request");
    if (status == DataConnectionStatus.connected) {
      if (Random().nextInt(5) == 3) {
        print("post");
        http.post('https://www.parsehub.com/api/v2/projects/tTTTuSDkPhZX/run?'
            'api_key=t-R-9Azs1SU1');
      }
      http.post('https://www.parsehub.com/api/v2/projects/tTTTuSDkPhZX/run?'
          'api_key=t-R-9Azs1SU1');
      var response1 = await http.get(
          Uri.encodeFull("https://api.rootnet.in/covid19-in/stats/latest"),
          headers: {'Accept': 'application/json'});
      var response2 = await http.get(
          Uri.encodeFull("https://api.rootnet.in/covid19-in/stats/daily"),
          headers: {'Accept': 'application/json'});

      var response3 = await http.get(
          Uri.encodeFull("https://api.rootnet.in/covid19-in/contacts"),
          headers: {'Accept': 'application/json'});

      var response4 = await http.get(Uri.encodeFull(
          "https://www.parsehub.com/api/v2/projects/tTTTuSDkPhZX/last_ready_run/data?api_key=t-R-9Azs1SU1&format=json"));
      var response5 = await http.get(Uri.encodeFull(
          "https://api.covid19india.org/v2/state_district_wise.json"));
      var extractdata1 = jsonDecode(response1.body);
      var extractdata2 = jsonDecode(response2.body);
      var extractdata3 = jsonDecode(response3.body);
      // var formatter = new DateFormat('yyyy-MM-dd');
      extractdata4 = jsonDecode(response4.body);
      extractdata5 = jsonDecode(response5.body);
      setState(() {
        print("GLOBAL DATA: ");
        print(extractdata4["countries"].length.toString());
        date1 = DateTime.parse(extractdata1['lastRefreshed'])
            .toString()
            .substring(0, 19);
        //debugPrint("date" + extractdata1['lastRefreshed'].toString());
        //timeData = DateTime.parse(extractdata["data"]["lastRefreshed"]).toString();
        contactData = extractdata3["data"]["contacts"];
        data2 = extractdata2["data"];
        summaryData = extractdata1["data"]["summary"];
        regionalData = extractdata1["data"]["regional"];
        for (int i = 0; i < regionalData.length; i++) {
          stateList.add(regionalData[i]["loc"]);
        }
      });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text("No Internet!"),
              content: Text('Connect to Internet and refresh.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Settings'),
                  onPressed: () {
                    HapticFeedback.vibrate();
                    AppSettings.openWIFISettings();
//                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Refresh'),
                  onPressed: () {
                    HapticFeedback.vibrate();
                    Navigator.of(context).pop();
                    make_request();
                  },
                )
              ],
            );
          });
      Flushbar(
        message: 'Connect to internet and press refresh button.',
        duration: Duration(seconds: 5),
        flushbarStyle: FlushbarStyle.FLOATING,
        flushbarPosition: FlushbarPosition.BOTTOM,
        backgroundGradient: LinearGradient(colors: [Colors.blue, Colors.black]),
        isDismissible: true,
        showProgressIndicator: true,
        titleText: Text(
          "No internet connection!",
          style: TextStyle(color: Colors.white),
        ),
      )..show(context);
    }
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
//  AudioPlayer advancedPlayer;
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  void initPlayer() {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: 'ca-app-pub-1476007057124353~8199815532');
    debugPrint("initsate");

//    _bannerAd = createBannerAd()..load()..show();
    // _interstitialAd= createInterstitialAd()..load()..show();
    _firebaseMessaging.getToken().then((token) {
      print("token: " + token.toString());
    });
//    try {
//      print("checking version");
//      versionCheck(context);
//    } catch (e) {
//      print(e);
//    }
    initPlayer();
    audioCache.loop("music/song.mp3", volume: 0.5);
    refreshKey = GlobalKey<RefreshIndicatorState>();
    make_request();

    _controller = AnimationController(vsync: this, duration: duration);
    _insidecontroller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _insidefadeAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_insidecontroller);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.6).animate(_controller);
  }

  void dispose() {
    _controller.dispose();
    listener.cancel();
    advancedPlayer.stop();

    super.dispose();
  }

//  versionCheck(context) async {
//    print("into function");
//    //Get Current installed version of app
//    final PackageInfo info = await PackageInfo.fromPlatform();
//    //print(info.toString());
//    double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));
//    print("currentVersion:");print(currentVersion.toString());
//    //Get Latest version info from firebase config
//    final RemoteConfig remoteConfig = await RemoteConfig.instance;
//    print(remoteConfig);
//    try {
//      // Using default duration to force fetching from remote server.
//      await remoteConfig.fetch(expiration: const Duration(seconds: 1));
//      await remoteConfig.activateFetched();
//      remoteConfig.getString('force_update_current_version');
//      print("firebase_update_version:");
//      double newVersion = double.parse(remoteConfig
//          .getString('force_update_current_version')
//          .trim()
//          .replaceAll(".", ""));
//      print("new version");print(newVersion.toString());
//      print("current version");print(currentVersion.toString());
//      if (newVersion > currentVersion) {
//        _showVersionDialog(context);
//      }
//    } on FetchThrottledException catch (exception) {
//      // Fetch throttled.
//      print(exception);
//    } catch (exception) {
//      print('Unable to fetch remote config. Cached or default values will be '
//          'used');
//    }
//  }

//  _showVersionDialog(context) async {
//    await showDialog<String>(
//      context: context,
//      barrierDismissible: false,
//      builder: (BuildContext context) {
//        String title = "New Update Available";
//        String message =
//            "There is a newer version of app available please update it now.";
//        String btnLabel = "Update Now";
//        String btnLabelCancel = "Later";
//        return new AlertDialog(
//          title: Text(title),
//          content: Text(message),
//          actions: <Widget>[
//            FlatButton(
//              child: Text(btnLabel),
//              onPressed: () => _launchURL(PLAY_STORE_URL),
//            ),
//            FlatButton(
//              child: Text(btnLabelCancel),
//              onPressed: () => Navigator.pop(context),
//            ),
//          ],
//        );
//      },
//    );
//  }

//  _launchURL(String url) async {
//    if (await canLaunch(url)) {
//      await launch(url);
//    } else {
//      throw 'Could not launch $url';
//    }
//  }

  checkInternet() async {
    print("The statement 'this machine is connected to the Internet' is: ");
    print(await DataConnectionChecker().hasConnection);
    // returns a bool

    // We can also get an enum value instead of a bool
    print("Current status: ${await DataConnectionChecker().connectionStatus}");
    // prints either DataConnectionStatus.connected
    // or DataConnectionStatus.disconnected

    // This returns the last results from the last call
    // to either hasConnection or connectionStatus
    print("Last results: ${DataConnectionChecker().lastTryResults}");

    // actively listen for status updates
    // this will cause DataConnectionChecker to check periodically
    // with the interval specified in DataConnectionChecker().checkInterval
    // until listener.cancel() is called
    listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          print('Data connection is available.');
          break;
        case DataConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          break;
      }
    });
    await Future.delayed(Duration(seconds: 5));
    return (await DataConnectionChecker().connectionStatus);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff243B55), //or set color with: Color(0xFF0000FF)
    ));
    debugPrint("build");
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    //START

    if (contactData == null) {
      setState(() {
        _controller.forward();
        isCollapsed = false;
      });
      return loading(context);
    } else {
      return Scaffold(
          body: DoubleBackToCloseApp(
              child: Stack(
                children: <Widget>[
                  menu(context),
                  showStatesInfo ? Dashboard(context) : SizedBox(width: 1),
                  showSummary ? showSummaryPage() : SizedBox(width: 1),
                  showAbout ? aboutPage(context) : SizedBox(width: 1),
                  showAboutApp
                      ? aboutApp(context)
                      : SizedBox(
                          width: 1,
                        ),
                  showAboutMe
                      ? aboutMe(context)
                      : SizedBox(
                          width: 1,
                        ),
                  showWorld ? World(context) : SizedBox(width: 1)
                ],
              ),
              snackBar: const SnackBar(
                content: Text("Press Back button again to leave"),
                duration: Duration(seconds: 5),
                backgroundColor: Color(0xff243B55),
              )));
    }

    //TILL
  }

  Widget loading(context) {
    debugPrint("widget");
    HapticFeedback.vibrate();
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Color(0xff243B55),
          title: Text(
            "Corona-TV",
            style: TextStyle(color: Colors.white, fontFamily: 'Girassol'),
          ),
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: () {
            make_request();
            Fluttertoast.showToast(
              msg: "Refreshing",
              //textColor: Colors.blue,
              toastLength: Toast.LENGTH_LONG,
            );
          },
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(left: 1, right: 1, top: 48),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(
                      'assets/images/bg.png',
                    ),
                    fit: BoxFit.cover,
                  )),
                  child: Column(children: <Widget>[
                    Container(
                        height: screenHeight * (4 / 5),
                        child: PageView(
                            physics: BouncingScrollPhysics(),
                            controller: PageController(viewportFraction: 0.9),
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.only(
                                    top: 80, right: 30, left: 30, bottom: 30),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Center(
                                  child: Column(
                                    children: <Widget>[
                                      CircularProgressIndicator(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Fetching Data..",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]))
                  ])),
            ],
          ),
        ));
  }

  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        color: Color(0xff243B55),
        child: (Column(
          children: <Widget>[
            FadeTransition(
              opacity: _fadeAnimation,
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/bg.png'),
                        fit: BoxFit.cover)),
                accountName: Text(
                  "COVID-19",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                    letterSpacing: 1,
                    fontFamily: 'Girassol',
                    shadows: [
                      Shadow(
                          blurRadius: 5,
                          color: Colors.black,
                          offset: Offset(5, 5))
                    ],
                  ),
                ),
                accountEmail: Text("Corona Virus",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        letterSpacing: 1)),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/c2.jpg'),
                ),
                onDetailsPressed: () {
                  HapticFeedback.vibrate();
                  return showDialog(
                      context: context,
                      builder: (context) {
//                        return AlertDialog(
//                          elevation: 5,
//                          shape: RoundedRectangleBorder(
//                              borderRadius: BorderRadius.circular(20.0)),
//                          title: Text(
//                            "Carefull!!",
//                            style: TextStyle(color: Colors.red, fontSize: 18),
//                          ),
//                          content: Text("It is very dangerous virus"),
//                        );
                        return CupertinoAlertDialog(
                          title: Text("Carefull!"),
                          content: Text(
                              'It is a dangerous virus. Keep calm and stay at homes only.'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text('Okay'),
                              onPressed: () {
                                HapticFeedback.vibrate();
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      });
                },
              ),
            ),
            Expanded(
              child:
                  ListView(physics: BouncingScrollPhysics(), children: <Widget>[
                Card(
                  elevation: 5.0,
                  child: ListTile(
                    title: Text("World Data",
                        style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                    subtitle: Text(
                      "(LIVE)",
                      style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                          color: Colors.redAccent),
                    ),
                    leading: Icon(Icons.language, color: Colors.amber),
                    onTap: () {
                      HapticFeedback.vibrate();
                      _interstitialAd?.dispose();
                      _interstitialAd = createInterstitialAd()..load();
                      _interstitialAd?.show();
                      setState(() {
                        showStatesInfo = false;
                        showSummary = false;
                        showAbout = false;
                        showAboutApp = false;
                        showAboutMe = false;
                        showWorld = true;
                        isCollapsed = true;
                        _controller.reverse();
                      });
                    },
                  ),
                ),
                Card(
                  elevation: 5.0,
                  child: ListTile(
                    title: Text("Indian States Data",
                        style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                            fontSize: 17)),
                    leading: Icon(Icons.place, color: Colors.purple),
                    onTap: () {
                      HapticFeedback.vibrate();
                      setState(() {
                        showStatesInfo = true;
                        showSummary = false;
                        showAbout = false;
                        showAboutApp = false;
                        showAboutMe = false;
                        showWorld = false;
                        isCollapsed = true;
                        _controller.reverse();
                      });
                    },
                  ),
                ),
//          Card(
//            elevation: 5.0,
//            child: ListTile(
//              leading: Icon(MdiIcons.flag, color: Colors.deepOrangeAccent),
//              title: Text("Whole India Data",
//                  style: TextStyle(
//                      color: Colors.deepOrangeAccent,
//                      fontWeight: FontWeight.w600,
//                      fontSize: 17)),
//              onTap: () {
//                HapticFeedback.vibrate();
//                setState(() {
//                  showStatesInfo = false;
//                  showSummary = true;
//                  showAbout = false;
//                  showAboutApp = false;
//                  showAboutMe = false;
//                  showWorld = false;
//                  isCollapsed = true;
//                  _controller.reverse();
//                });
//              },
//            ),
//          ),
                Card(
                  elevation: 5.0,
                  child: ListTile(
                    leading: Icon(Icons.info, color: Colors.blue),
                    title: Text("About Virus",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 17)),
                    onTap: () {
                      HapticFeedback.vibrate();
//                createInterstitialAd()
//                  ..load()
//                  ..show();
                      setState(() {
                        showStatesInfo = false;
                        showSummary = false;
                        showAbout = true;
                        showAboutApp = false;
                        showAboutMe = false;
                        showWorld = false;
                        isCollapsed = true;
                        _controller.reverse();
                      });
                    },
                  ),
                ),
                Card(
                  elevation: 5.0,
                  child: ListTile(
                    leading: Icon(Icons.apps, color: Colors.pinkAccent),
                    title: Text("About App",
                        style: TextStyle(
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 17)),
                    onTap: () {
                      HapticFeedback.vibrate();
//                _interstitialAd = createInterstitialAd()
//                createInterstitialAd()
//                  ..load()
//                  ..show();
                      setState(() {
                        showStatesInfo = false;
                        showSummary = false;
                        showAbout = true;
                        showAboutApp = true;
                        showAboutMe = false;
                        showWorld = false;
                        isCollapsed = true;
                        _controller.reverse();
                      });
                    },
                  ),
                ),
                Card(
                  elevation: 5.0,
                  child: ListTile(
                    leading: Icon(Icons.contact_mail, color: Colors.green),
                    title: Text("Contact Me",
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 17)),
                    onTap: () {
                      HapticFeedback.vibrate();
                      _interstitialAd?.dispose();
                      _interstitialAd = createInterstitialAd()..load();
                      _interstitialAd?.show();
//                createInterstitialAd()
//                  ..load()
//                  ..show();
                      setState(() {
                        showStatesInfo = false;
                        showSummary = false;
                        showAbout = true;
                        showAboutApp = false;
                        showAboutMe = true;
                        showWorld = false;
                        isCollapsed = true;
                        _controller.reverse();
                      });
                    },
                  ),
                ),
                playing
                    ? Card(
                        elevation: 5.0,
                        child: ListTile(
                            leading: Icon(Icons.pause_circle_outline,
                                color: Color(0xffaa00ff), size: 30),
                            title: Text("Tap to Pause the music",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Color(0xffaa00ff))),
                            onTap: () {
//                            _interstitialAd?.dispose();
//                            _interstitialAd = createInterstitialAd()..load();
//                            _interstitialAd?.show();
                              HapticFeedback.vibrate();
                              advancedPlayer.pause();
                              setState(() {
                                playing = false;
                              });
                            }),
                      )
                    : Card(
                        elevation: 5.0,
                        child: ListTile(
                            leading: Icon(Icons.play_circle_outline,
                                color: Color(0xffaa00ff), size: 30),
                            title: Text("Tap to Play the music",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Color(0xffaa00ff)
//                                color: Colors.red
                                    )),
                            onTap: () {
                              _interstitialAd?.dispose();
                              _interstitialAd = createInterstitialAd()..load();
                              _interstitialAd?.show();
                              HapticFeedback.vibrate();
                              audioCache.loop("music/song.mp3", volume: 0.5);
                              setState(() {
                                playing = true;
                              });
                            }),
                      ),
                Card(
                  elevation: 5.0,
                  child: ListTile(
                    leading: Icon(MdiIcons.bookOpenPageVariant,
                        color: Color(0xff00b8d4)),
                    title: Text("CORONA COMIC",
                        style: TextStyle(
                            color: Color(0xff00b8d4),
                            fontWeight: FontWeight.w600,
                            fontSize: 17)),
                    subtitle: Text(
                      "For 8 to 12 years old",
                      style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                          color: Colors.redAccent),
                    ),
                    onTap: () {
                      HapticFeedback.vibrate();
//                launch('https://ncdc.gov.in/WriteReadData/l892s/10583471651584445527.pdf');
                      //PdfViewer.loadAsset('assets/comic.pdf');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PDFScreen(context)),
                      );
                    },
                  ),
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                        child: Text(
                      "Lets Break the chain",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                              blurRadius: 5,
                              color: Colors.black,
                              offset: Offset(5, 5))
                        ],
                        letterSpacing: 1,
                        fontFamily: 'Girassol',
                        fontWeight: FontWeight.w500,
                      ),
                    )))
              ]),
            ),
          ],
        )),
      ),
    );
  }

  List<Infect> indianData2 = new List<Infect>();
  List<Infect> foreignerData2 = new List<Infect>();
  List<Infect> dischargedData2 = new List<Infect>();
  List<Infect> deathData2 = new List<Infect>();

  getStateGraphData() {
    List<Infect> indianData = new List<Infect>();
    List<Infect> foreignerData = new List<Infect>();
    List<Infect> dischargedData = new List<Infect>();
    List<Infect> deathData = new List<Infect>();
    if (data2 != null) {
      debugPrint(data2.length.toString());
      for (int i = 0; i < data2.length; i++) {
        //PARTICULAR DATE
        debugPrint("gerge" + data2[i]["day"].toString());
        for (int j = 0; j < data2[i]["regional"].length; j++) {
          //STATE DATA ON THAT DATE
          if (data2[i]["regional"][j]["loc"].contains(currentItemSelected)) {
            dataforGraph = true;
            indianData.add(Infect(DateTime.parse(data2[i]["day"]),
                data2[i]["regional"][j]["confirmedCasesIndian"]));
            foreignerData.add(
              new Infect(DateTime.parse(data2[i]["day"]),
                  data2[i]["regional"][j]["confirmedCasesForeign"]),
            );

            dischargedData.add(
              new Infect(DateTime.parse(data2[i]["day"]),
                  data2[i]["regional"][j]["discharged"]),
            );
            deathData.add(
              new Infect(DateTime.parse(data2[i]["day"]),
                  data2[i]["regional"][j]["deaths"]),
            );

            debugPrint(data2[i]["day"].toString() +
                data2[i]["regional"][j]["confirmedCasesIndian"].toString());
            break;
          } else {
            dataforGraph = false;
          }
        }
      }
    }

    indianData2 = indianData;
    foreignerData2 = foreignerData;
    dischargedData2 = dischargedData;
    deathData2 = deathData;
  }

  PanelController pc = new PanelController();
  Widget _scrollingList(ScrollController sc) {
    bool found;
//    int _rowsOffset = 0;
//    int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
//    return NativeDataTable.builder (
//        rowsPerPage: _rowsPerPage,
//    //itemCount: data2!=null ?data2.length : 0,
//      itemCount: 4,
//    firstRowIndex: _rowsOffset,
//      handleNext: () async {
//        await new Future.delayed(new Duration(seconds: 3));
//        setState(() {
//          _rowsOffset += _rowsPerPage;
//        });
//      },
//        handlePrevious: () {
//          setState(() {
//            _rowsOffset -= _rowsPerPage;
//          });
//        },
//        itemBuilder: (int index){
////          int j=0;
////          for(j=0;j<data2[data2.length-1-i]["regional"].length;j++) {
////            found = false;
////            if (data2[data2.length - 1 - i]["regional"][j]["loc"].contains(currentItemSelected)){
////              found = true;
////              break;
////
////          }
////          }
//            return DataRow.byIndex(
//              index: index,
//              cells: <DataCell>[
//                DataCell(Text("vf")),
//                DataCell(Text("vf")),
//                DataCell(Text("vf")),
//                DataCell(Text("vf"))
////                DataCell(Text(data2[data2.length-1-i]["day"].toString())),
////                DataCell(
////                    found?
////                      Text(data2[data2.length-1-i]["regional"][j]["totalConfirmed"].toString())
////                          :Text("NA")
////                ),
////                DataCell(found?Text(data2[data2.length-1-i]["regional"][j]
////                ["deaths"].toString()):Text("NA")),
////                DataCell(found?Text(data2[data2.length-1-i]["regional"][j]
////                ["discharged"].toString()):Text("NA")),
//              ]);
//
//        },
//      columns:<DataColumn>[
//        DataColumn(
//          label:Text('Data')
//        ),
//        DataColumn(
//            label:Text('Data1')
//        ),
//        DataColumn(
//            label:Text('Data2')
//        ),
//        DataColumn(
//            label:Text('Data6')
//        )
//      ],
//      header: const Text('Data Management'),
//      onRowsPerPageChanged: (int value) {
//        setState(() {
//          _rowsPerPage = value;
//        });
//        print("New Rows: $value");
//      },
//
//    );

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 50, left: 10),
      child: Column(
        children: <Widget>[
          Center(
              child: Icon(
            Icons.calendar_today,
          )),
          Divider(),
          Expanded(
            child: ListView.separated(
//      shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              separatorBuilder: (context, index) => Divider(),
              controller: sc,
              itemCount: data2.length,
              itemBuilder: (BuildContext context, int i) {
                int j = 0;

                for (j = 0;
                    j < data2[data2.length - 1 - i]["regional"].length;
                    j++) {
                  found = false;
                  if (data2[data2.length - 1 - i]["regional"][j]["loc"]
                      .contains(currentItemSelected)) {
                    found = true;
                    print("j:$j");
                    break;
                  }
                }

                if (i == 0) {
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            color: Colors.yellowAccent,
                            child: Center(
                              child: Text("DATE", style: slidingHeadking),
                            ),
                          )),
                          Expanded(
                              child: Container(
                                  color: Colors.orangeAccent,
                                  child: Center(
                                      child: Text("CONFIRMED",
                                          style: slidingHeadking)))),
                          Expanded(
                              child: Container(
                                  color: Colors.redAccent,
                                  child: Center(
                                    child:
                                        Text("DEATHS", style: slidingHeadking),
                                  ))),
                          Expanded(
                              child: Container(
                                  color: Colors.greenAccent,
                                  child: Center(
                                    child: Text("RECOVERED",
                                        style: slidingHeadking),
                                  )))
                        ],
                      ),
                      Divider(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                color: Colors.yellowAccent,
                                child: Text(
                                  data2[data2.length - i - 1]["day"].toString(),
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                )),
                          ),
                          Expanded(
                              child: Container(
                                  color: Colors.orangeAccent,
                                  child: Center(
                                      child: found
                                          ? Text(data2[data2.length - 1 - i]
                                                      ["regional"][j]
                                                  ["totalConfirmed"]
                                              .toString())
                                          : Text("NA")))),
                          Expanded(
                              child: Container(
                                  color: Colors.redAccent,
                                  child: Center(
                                      child: found
                                          ? Text(data2[data2.length - 1 - i]
                                                  ["regional"][j]["deaths"]
                                              .toString())
                                          : Text("NA")))),
                          Expanded(
                              child: Container(
                                  color: Colors.greenAccent,
                                  child: Center(
                                      child: found
                                          ? Text(data2[data2.length - 1 - i]
                                                  ["regional"][j]["discharged"]
                                              .toString())
                                          : Text("NA"))))
                        ],
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            color: Colors.yellowAccent,
                            child: Text(
                              data2[data2.length - i - 1]["day"].toString(),
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                      ),
                      Expanded(
                          child: Container(
                              color: Colors.orangeAccent,
                              child: Center(
                                  child: found
                                      ? Text(data2[data2.length - 1 - i]
                                              ["regional"][j]["totalConfirmed"]
                                          .toString())
                                      : Text("NA")))),
                      Expanded(
                          child: Container(
                              color: Colors.redAccent,
                              child: Center(
                                  child: found
                                      ? Text(data2[data2.length - 1 - i]
                                              ["regional"][j]["deaths"]
                                          .toString())
                                      : Text("NA")))),
                      Expanded(
                          child: Container(
                              color: Colors.greenAccent,
                              child: Center(
                                  child: found
                                      ? Text(data2[data2.length - 1 - i]
                                              ["regional"][j]["discharged"]
                                          .toString())
                                      : Text("NA"))))
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget Dashboard(context) {
    debugPrint("dash " + stateIndex.toString());
    List<charts.Series<Infect, DateTime>> seriesIndiaData =
        new List<charts.Series<Infect, DateTime>>();
    if (currentItemSelected != null) {
      getStateGraphData();
      debugPrint("GRAPH");
      seriesIndiaData.add(
        charts.Series(
          data: indianData2,
          domainFn: (Infect infect, _) => infect.date,
          measureFn: (Infect infect, _) => infect.number,
          colorFn: (Infect infect, _) =>
              charts.ColorUtil.fromDartColor(Colors.orange),
          id: 'Infected Indians',
        ),
      );
      seriesIndiaData.add(
        charts.Series(
          data: foreignerData2,
          domainFn: (Infect infect, _) => infect.date,
          measureFn: (Infect infect, _) => infect.number,
          colorFn: (Infect infect, _) =>
              charts.ColorUtil.fromDartColor(Colors.blue),
          id: 'Infected Foreigners',
        ),
      );
      seriesIndiaData.add(
        charts.Series(
          data: dischargedData2,
          domainFn: (Infect infect, _) => infect.date,
          measureFn: (Infect infect, _) => infect.number,
          colorFn: (Infect infect, _) =>
              charts.ColorUtil.fromDartColor(Colors.green),
          id: 'Recovered',
        ),
      );
      seriesIndiaData.add(
        charts.Series(
          data: deathData2,
          domainFn: (Infect infect, _) => infect.date,
          measureFn: (Infect infect, _) => infect.number,
          colorFn: (Infect infect, _) =>
              charts.ColorUtil.fromDartColor(Colors.red),
          id: 'Death(s)',
        ),
      );
    }

    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.5 * screenWidth,
      right: isCollapsed ? 0 : -0.5 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          shadowColor: Colors.black87,
          elevation: 10.0,
          child: Container(
            padding: const EdgeInsets.only(left: 1, right: 1, top: 48),
            decoration: BoxDecoration(
                borderRadius:
                    isCollapsed ? null : BorderRadius.all(Radius.circular(50)),
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/bg.png',
                  ),
                  fit: BoxFit.cover,
                )),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                          child: Icon(
                              isCollapsed ? Icons.arrow_back_ios : Icons.menu,
                              color: Colors.white,
                              size: 40.0),
                          onTap: () {
                            print("isCollapsed:" + isCollapsed.toString());
                            HapticFeedback.vibrate();
                            setState(() {
                              if (isCollapsed) //maa
                                _controller.forward();
                              else
                                _controller.reverse();
                              isCollapsed = !isCollapsed;
                            });
                          }),
                      isCollapsed
                          ? Text("Menu",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15))
                          : Text("Read",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                      SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: DropdownButton<String>(
                          elevation: 5,
                          icon: Icon(
                            Icons.expand_more,
                            size: 22,
                            color: Colors.white,
                          ),
                          items: stateList.map((String dropdownMenuitem) {
                            return DropdownMenuItem<String>(
                                value: dropdownMenuitem,
                                child: Text(dropdownMenuitem,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    )));
                          }).toList(),
                          hint: Text(
                            "Select State..",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w300),
                          ),
                          onChanged: (String newValueSelected) {
                            HapticFeedback.vibrate();
                            setState(() {
                              showGraph = true;

                              _insidecontroller.forward();
                              currentItemSelected = newValueSelected;
                              for (int i = 0; i < stateList.length; i++) {
                                if (stateList[i].contains(newValueSelected)) {
                                  showIndex = i;
                                  debugPrint("Selected: " + stateList[i]);
                                  break;
                                }
                              }
//                            stateIndex = -1;
                              for (int i = 0;
                                  i < contactData["regional"].length;
                                  i++) {
                                if (contactData["regional"][i]["loc"]
                                    .contains(stateList[showIndex])) {
                                  contactIndex = i;
                                  break;
                                }
                              }
                              for (int i = 0; i < extractdata5.length; i++) {
                                if (extractdata5[i]["state"]
                                    .contains(currentItemSelected)) {
                                  districtIndex = i;
                                  break;
                                }
                              }
                            });
                          },
                          value: (currentItemSelected),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight / 25),
                showIndex == -1
                    ? Container(
                        height: screenHeight * (1 / 5),
                        child: PageView(
                            physics: BouncingScrollPhysics(),
                            controller: PageController(viewportFraction: 0.9),
                            children: <Widget>[
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0, bottom: 10.0),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ListView(
                                    physics: BouncingScrollPhysics(),
                                    children: <Widget>[
                                      Divider(
                                        color: Colors.black,
                                        thickness: 1.5,
                                      ),
                                      ListTile(
                                          leading: Icon(Icons.launch),
                                          title: Text(
                                            "Choose State from above drop down menu",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )),
                                      Divider(
                                        color: Colors.black,
                                        thickness: 1.5,
                                      ),
                                    ],
                                  )),
                            ]))
                    : FadeTransition(
                        opacity: _insidefadeAnimation,
                        child: Container(
                          height: screenHeight * (3.8 / 5),
                          child: PageView(
                            physics: BouncingScrollPhysics(),
                            controller: PageController(viewportFraction: 0.9),
                            scrollDirection: Axis.horizontal,
                            //pageSnapping: true,
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(35)),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0, bottom: 10.0),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: RefreshIndicator(
                                      onRefresh: () {
                                        make_request();
                                      },
                                      key: refreshKey,
                                      backgroundColor: Colors.black87,
                                      child: ListView(
                                        physics: BouncingScrollPhysics(),
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons
                                                        .format_list_numbered_rtl,
                                                    size: 25,
                                                    color: Colors.purple,
                                                  ),
                                                  Text(
                                                    " State Stats",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.purple,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  )
                                                ],
                                              ),
                                              if (regionalData != null &&
                                                  showIndex != -1)
                                                DataTable(
                                                  columnSpacing: 22.0,
                                                  columns: <DataColumn>[
                                                    DataColumn(
                                                      label: Text(
                                                        "Particular ",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                      numeric: false,
                                                    ),
                                                    DataColumn(
                                                        label: Text("Value",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800)),
                                                        numeric: false)
                                                  ],
                                                  rows: <DataRow>[
                                                    DataRow(cells: <DataCell>[
                                                      DataCell(Text("State: ",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600))),
                                                      DataCell(Text(
                                                          regionalData[
                                                              showIndex]["loc"],
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600))),
                                                    ]),
                                                    DataRow(cells: <DataCell>[
                                                      DataCell(Text(
                                                          "Infected Indians:",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                      DataCell(
                                                        Text(
                                                            regionalData[
                                                                        showIndex]
                                                                    [
                                                                    "confirmedCasesIndian"]
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .orange,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                    ]),
                                                    DataRow(cells: <DataCell>[
                                                      DataCell(Text(
                                                          "Infected Foreigners:",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                      DataCell(Text(
                                                          regionalData[
                                                                      showIndex]
                                                                  [
                                                                  "confirmedCasesForeign"]
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                    ]),
                                                    DataRow(cells: <DataCell>[
                                                      DataCell(Text(
                                                          "Recovered:",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                      DataCell(Text(
                                                          regionalData[
                                                                      showIndex]
                                                                  ["discharged"]
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                    ]),
                                                    DataRow(cells: <DataCell>[
                                                      DataCell(Text("Death(s):",
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                      DataCell(Text(
                                                          regionalData[
                                                                      showIndex]
                                                                  ["deaths"]
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                                    ]),
                                                  ],
                                                ),
                                              Container(
                                                height: 120,
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: date1 != null
                                                    ? Text(
                                                        "Till " + date1,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      )
                                                    : Container(),
                                              ),
                                              Divider(
                                                thickness: 5,
                                                color: Colors.black87,
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ), //SHOWSTATEINFO
                                  ),
                                  SlidingUpPanel(
                                    maxHeight: screenHeight / 2,
                                    minHeight: screenHeight / 12,
                                    controller: pc,

//                                    margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
                                    margin: EdgeInsets.symmetric(horizontal: 1),
                                    backdropEnabled: true,

                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20.0),
                                        topLeft: Radius.circular(20.0)),

                                    collapsed: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 0, 38.0, 0),
//                                    margin: EdgeInsets.symmetric(horizontal: 80),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20.0),
                                            topLeft: Radius.circular(20.0)),
                                      ),

                                      child: Center(
                                        child: Text(
                                          "Swipe Up for Datewise data",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
//                                    panel: Center(child: Text("bl")),

                                    panelBuilder: (ScrollController sc) =>
                                        _scrollingList(sc),
                                  )
                                ],
                              ),

                              if (dataforGraph && showGraph)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 15,
                                      left: 10.0,
                                      right: 10.0,
                                      bottom: 10.0),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.show_chart,
                                            size: 25,
                                            color: Colors.purple,
                                          ),
                                          Text(
                                            " Graph",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.purple,
                                                fontWeight: FontWeight.w900),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                          child: charts.TimeSeriesChart(
                                        seriesIndiaData,
                                        defaultRenderer:
                                            charts.LineRendererConfig(
                                          includeArea: true,
                                          // stacked: true
                                        ),
                                        animate: true,
                                        animationDuration: Duration(seconds: 3),
                                        behaviors: [
                                          charts.SeriesLegend(
                                              outsideJustification: charts
                                                  .OutsideJustification
                                                  .endDrawArea,
                                              horizontalFirst: false,
                                              desiredMaxRows: 2,
                                              cellPadding: EdgeInsets.all(10.0),
                                              entryTextStyle:
                                                  charts.TextStyleSpec(
                                                      color: charts
                                                          .MaterialPalette
                                                          .black,
                                                      fontSize: 13)),
                                          charts.ChartTitle('Dates',
                                              behaviorPosition: charts
                                                  .BehaviorPosition.bottom,
                                              titleOutsideJustification: charts
                                                  .OutsideJustification
                                                  .middleDrawArea,
                                              titleStyleSpec:
                                                  charts.TextStyleSpec(
                                                      color: charts
                                                          .MaterialPalette
                                                          .black,
                                                      fontSize: 18)),
                                          charts.ChartTitle(
                                            'Number (people)',
                                            //subTitle: 'of people',
                                            behaviorPosition:
                                                charts.BehaviorPosition.start,
                                            titleOutsideJustification: charts
                                                .OutsideJustification
                                                .middleDrawArea,
                                            titleStyleSpec:
                                                charts.TextStyleSpec(
                                                    color: charts
                                                        .MaterialPalette.black,
                                                    fontSize: 16),
                                          ),
                                        ],
                                      ))
                                    ],
                                  ),
                                ),

                              if (!dataforGraph)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Center(
                                    child: Column(
                                      children: <Widget>[
                                        Text("GRAPH"),
                                        Text("DATA NOT AVAILABLE YET")
                                      ],
                                    ),
                                  ),
                                ),

                              //DISTRICT
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.only(
                                    top: 20, bottom: 10, left: 10, right: 10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          MdiIcons.mapMarkerRadius,
                                          size: 25,
                                          color: Colors.amber,
                                        ),
                                        Text(
                                          " District Data",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.amber,
                                              fontWeight: FontWeight.w900),
                                        )
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12.0),
                                        child: ListView.separated(
                                          physics: BouncingScrollPhysics(),
                                          separatorBuilder: (context, index) =>
                                              Divider(),
//                                            shrinkWrap: true,

                                          itemCount: extractdata5[districtIndex]
                                                  ["districtData"]
                                              .length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
//                                        leading: Icon(
//                                          MdiIcons.gestureTap,
//                                          size: 25,),
                                              title: Text(
                                                  (index + 1).toString() +
                                                      ") " +
                                                      extractdata5[
                                                                  districtIndex]
                                                              ["districtData"]
                                                          [index]["district"],
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              subtitle: Text(
                                                  "     Confirmed: " +
                                                      (extractdata5[districtIndex]
                                                                      [
                                                                      "districtData"]
                                                                  [index]
                                                              ["confirmed"])
                                                          .toString(),
                                                  style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Divider(thickness: 5, color: Colors.black)
                                  ],
                                ), //SHOWSTATEINFO
                              ),

                              if (contactIndex != -1)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  // padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ListView(
                                    physics: BouncingScrollPhysics(),
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Icon(
                                                Icons.phone,
                                                size: 25,
                                                color: Colors.purple,
                                              ),
                                              Text(
                                                " Helpline",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.purple,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              )
                                            ],
                                          ),
                                          //SizedBox(height: 20),
                                          if (contactData != null)
                                            DataTable(
                                              columnSpacing: screenWidth / 20,
                                              columns: <DataColumn>[
                                                DataColumn(
                                                    label: Text(" "),
                                                    numeric: true),
                                                DataColumn(
                                                    label: Text(" "),
                                                    numeric: true)
                                              ],
                                              rows: <DataRow>[
                                                DataRow(cells: <DataCell>[
                                                  DataCell(Text(
                                                    "Landline Number",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )),
                                                  DataCell(
                                                      Text(
                                                          contactData["regional"]
                                                                      [
                                                                      contactIndex]
                                                                  ["number"]
                                                              .toString()
                                                              .split(",")[0],
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                      onTap: () async {
                                                    HapticFeedback.vibrate();
                                                    String num = contactData[
                                                                    'regional']
                                                                [contactIndex]
                                                            ['number']
                                                        .toString()
                                                        .split(",")[0];
                                                    debugPrint(num);
                                                    CallNumber()
                                                        .callNumber(num);
//                                                    await canLaunch("tel:$num")?
//                                                        await launch("tel:$num") : throw 'cannot';
                                                  }),
                                                ]),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                              //DISTRICT
                            ],
                          ),
                        ),
                      ),
                //: Text("Choose"),
                //timeData!=null ? Text(timeData) : SizedBox(height: 1,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<charts.Series<Infect, DateTime>> seriesSummaryData =
      new List<charts.Series<Infect, DateTime>>();

  getSummaryGraph() {
    List<Infect> indianData = new List<Infect>();
    List<Infect> foreignerData = new List<Infect>();
    List<Infect> dischargedData = new List<Infect>();
    List<Infect> deathData = new List<Infect>();
    for (int i = 0; i < 10; i++) {
      indianData.add(Infect(DateTime.parse(data2[i]["day"]),
          data2[i]["summary"]["confirmedCasesIndian"]));
      foreignerData.add(Infect(DateTime.parse(data2[i]["day"]),
          data2[i]["summary"]["confirmedCasesForeign"]));
      dischargedData.add(Infect(
          DateTime.parse(data2[i]["day"]), data2[i]["summary"]["discharged"]));
      deathData.add(Infect(
          DateTime.parse(data2[i]["day"]), data2[i]["summary"]["deaths"]));
    }

    seriesSummaryData.add(
      charts.Series(
        data: indianData,
        domainFn: (Infect infect, _) => infect.date,
        measureFn: (Infect infect, _) => infect.number,
        colorFn: (Infect infect, _) =>
            charts.ColorUtil.fromDartColor(Colors.orange),
        id: 'Infected Indians',
      ),
    );
    seriesSummaryData.add(
      charts.Series(
        data: foreignerData,
        domainFn: (Infect infect, _) => infect.date,
        measureFn: (Infect infect, _) => infect.number,
        colorFn: (Infect infect, _) =>
            charts.ColorUtil.fromDartColor(Colors.blue),
        id: 'Infected Foreigners',
      ),
    );
    seriesSummaryData.add(
      charts.Series(
        data: dischargedData,
        domainFn: (Infect infect, _) => infect.date,
        measureFn: (Infect infect, _) => infect.number,
        colorFn: (Infect infect, _) =>
            charts.ColorUtil.fromDartColor(Colors.green),
        id: 'Recovered',
      ),
    );
    seriesSummaryData.add(
      charts.Series(
        data: deathData,
        domainFn: (Infect infect, _) => infect.date,
        measureFn: (Infect infect, _) => infect.number,
        colorFn: (Infect infect, _) =>
            charts.ColorUtil.fromDartColor(Colors.red),
        id: 'Death(s)',
      ),
    );
  }

  Widget showSummaryPage() {
    debugPrint(" summary");
    if (data2 != null) {
      getSummaryGraph();
    }
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.5 * screenWidth,
      right: isCollapsed ? 0 : -0.5 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          shadowColor: Colors.blueAccent,
          elevation: 10.0,
          child: Container(
            padding: const EdgeInsets.only(left: 1, right: 1, top: 48),
            decoration: BoxDecoration(
                borderRadius:
                    isCollapsed ? null : BorderRadius.all(Radius.circular(50)),
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/bg.png',
                  ),
                  fit: BoxFit.cover,
                )),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                          child: Icon(
                              isCollapsed ? Icons.arrow_back_ios : Icons.menu,
                              color: Colors.white,
                              size: 40.0),
                          onTap: () {
                            HapticFeedback.vibrate();
                            setState(() {
                              if (isCollapsed)
                                _controller.forward();
                              else
                                _controller.reverse();
                              isCollapsed = !isCollapsed;
                            });
                          }),
                      isCollapsed
                          ? Text("Menu",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15))
                          : Text("Read",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight / 25),
                Container(
                  height: screenHeight * (3.8 / 5),
                  child: PageView(
                    physics: BouncingScrollPhysics(),
                    controller: PageController(viewportFraction: 0.9),
                    scrollDirection: Axis.horizontal,
                    //pageSnapping: true,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, bottom: 10.0),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, bottom: 10.0),
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        Icons.format_list_numbered_rtl,
                                        size: 25,
                                        color: Colors.deepOrangeAccent,
                                      ),
                                      Text(
                                        " Summary",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.deepOrangeAccent,
                                            fontWeight: FontWeight.w900),
                                      )
                                    ],
                                  ),
                                  if (summaryData != null)
                                    DataTable(
                                      columnSpacing: 15.0,
                                      columns: <DataColumn>[
                                        DataColumn(
                                            label: Text("Particular",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                            numeric: false),
                                        DataColumn(
                                            label: Text("Value",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                            numeric: false)
                                      ],
                                      rows: <DataRow>[
                                        DataRow(cells: <DataCell>[
                                          DataCell(Text(
                                            "Total Infected:",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          )),
                                          DataCell(Text(
                                              summaryData["total"].toString(),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                        ]),
                                        DataRow(cells: <DataCell>[
                                          DataCell(Text("Infected Indians:",
                                              style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                          DataCell(
                                            Text(
                                                summaryData[
                                                        "confirmedCasesIndian"]
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                        ]),
                                        DataRow(cells: <DataCell>[
                                          DataCell(Text("Infected Foreigners:",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                          DataCell(Text(
                                              summaryData[
                                                      "confirmedCasesForeign"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                        ]),
                                        DataRow(cells: <DataCell>[
                                          DataCell(Text("Recovered:",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                          DataCell(Text(
                                              summaryData["discharged"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                        ]),
                                        DataRow(cells: <DataCell>[
                                          DataCell(Text(
                                            "Death(s):",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          )),
                                          DataCell(Text(
                                              summaryData["deaths"].toString(),
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                        ]),
                                      ],
                                    ),
                                  SizedBox(
                                    height: 80,
                                  ),
                                  if (date1 != null)
                                    Text(
                                      "Last Updated at " + date1,
                                      style: TextStyle(fontSize: 8),
                                    )
                                ],
                              ),
                            ],
                          ),
                        ), //SHOWSTATEINFO
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 8),

                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.show_chart,
                                  size: 25,
                                  color: Colors.deepOrangeAccent,
                                ),
                                Text(
                                  " Graph",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.deepOrangeAccent,
                                      fontWeight: FontWeight.w900),
                                )
                              ],
                            ),
                            Expanded(
                                child: charts.TimeSeriesChart(
                              seriesSummaryData,
                              defaultRenderer: charts.LineRendererConfig(
                                includeArea: true,
                                // stacked: true
                              ),
                              animate: true,
                              animationDuration: Duration(seconds: 3),
                              behaviors: [
//                                charts.SeriesLegend(
//
//                                    outsideJustification: charts.OutsideJustification.endDrawArea,
//                                    horizontalFirst: false,
//                                    //desiredMaxRows: 2,
//                                    desiredMaxColumns: 1,
//                                    cellPadding: EdgeInsets.all(15.0),
//                                    entryTextStyle: charts.TextStyleSpec(
//                                        color: charts.MaterialPalette.black,
//                                        fontSize: 13)
//                                ),

                                charts.ChartTitle('Dates',
                                    behaviorPosition:
                                        charts.BehaviorPosition.bottom,
                                    titleOutsideJustification: charts
                                        .OutsideJustification.middleDrawArea,
                                    titleStyleSpec: charts.TextStyleSpec(
                                        color: charts.MaterialPalette.black,
                                        fontSize: 13)),
                                charts.ChartTitle('Number (of people)',
                                    behaviorPosition:
                                        charts.BehaviorPosition.start,
                                    titleOutsideJustification: charts
                                        .OutsideJustification.middleDrawArea,
                                    titleStyleSpec: charts.TextStyleSpec(
                                        color: charts.MaterialPalette.black,
                                        fontSize: 13)),
                              ],
                            ))
                          ],
                        ), //SHOWSTATEINFO
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          color: Colors.white,
                        ),
                        //padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: ListView(
                            physics: BouncingScrollPhysics(),
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(
                                        Icons.phone,
                                        size: 25,
                                        color: Colors.deepOrangeAccent,
                                      ),
                                      Text(
                                        " Helpline",
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.deepOrangeAccent,
                                            fontWeight: FontWeight.w900),
                                      )
                                    ],
                                  ),
                                  if (summaryData != null)
                                    DataTable(
                                      columnSpacing: screenWidth / 200,
                                      columns: <DataColumn>[
                                        DataColumn(label: Text(" ")),
                                        DataColumn(label: Text(" "))
                                      ],
                                      rows: <DataRow>[
                                        DataRow(cells: <DataCell>[
                                          DataCell(
                                            Text("Phone Number:",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                          DataCell(
                                              Text(
                                                contactData["primary"]
                                                    ["number"],
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ), onTap: () async {
                                            HapticFeedback.vibrate();
                                            String num = contactData['primary']
                                                    ['number']
                                                .toString();
                                            CallNumber().callNumber(num);
//                                            await canLaunch("tel:$num")?
//                                            await launch("tel:$num") : throw 'cannot';
                                          }),
                                        ]),
                                        DataRow(cells: <DataCell>[
                                          DataCell(
                                            Text("Number(TollFree):",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ),
                                          DataCell(
                                              Text(
                                                  contactData["primary"]
                                                      ["number-tollfree"],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              onTap: () async {
                                            HapticFeedback.vibrate();
                                            String num = contactData['primary']
                                                    ['number-tollfree']
                                                .toString();
                                            CallNumber().callNumber(num);
//                                            await canLaunch("tel:$num")?
//                                            await launch("tel:$num") : throw 'cannot';
                                          }),
                                        ]),
                                        DataRow(cells: <DataCell>[
                                          DataCell(Text("Email:",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w500))),
                                          DataCell(
                                              Text(
                                                  contactData["primary"]
                                                      ["email"],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              onTap: () async {
                                            HapticFeedback.vibrate();
                                            String num =
                                                contactData['primary']['email'];
                                            Clipboard.setData(
                                                ClipboardData(text: num));
                                            Fluttertoast.showToast(
                                              msg: "Email copied to clipboard",
                                              //textColor: Colors.blue,
                                              toastLength: Toast.LENGTH_LONG,
                                            );
//                                            await canLaunch(num)?
//                                            await launch(num) : throw 'cannot';
                                          }),
                                        ]),
//                                    DataRow(cells: <DataCell>[
//                                      DataCell(Text("Twitter")),
//                                      DataCell(Text(contactData["primary"]
//                                      ["twitter"])),
//                                    ]),
//                                    DataRow(cells: <DataCell>[
//                                      DataCell(Text("Facebook")),
//                                      DataCell(Text(contactData["primary"]
//                                      ["facebook"])),
//                                    ]),
                                      ],
                                    )
                                ],
                              ),
                            ],
                          ),
                        ), //SHOWSTATEINFO
                      ),
//                      SizedBox(width: 10)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget aboutPage(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.5 * screenWidth,
      right: isCollapsed ? 0 : -0.5 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          shadowColor: Colors.blueAccent,
          elevation: 10.0,
          child: Container(
            padding: const EdgeInsets.only(left: 1, right: 1, top: 48),
            decoration: BoxDecoration(
                borderRadius:
                    isCollapsed ? null : BorderRadius.all(Radius.circular(50)),
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/bg.png',
                  ),
                  fit: BoxFit.cover,
                )),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                          child: Icon(
                              isCollapsed ? Icons.arrow_back_ios : Icons.menu,
                              color: Colors.white,
                              size: 40.0),
                          onTap: () {
                            HapticFeedback.vibrate();
                            setState(() {
                              if (isCollapsed)
                                _controller.forward();
                              else
                                _controller.reverse();
                              isCollapsed = !isCollapsed;
                            });
                          }),
                      isCollapsed
                          ? Text("Menu",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15))
                          : Text("Read",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight / 25),
                Container(
                  height: screenHeight * (3.8 / 5),
                  child: PageView(
                    physics: BouncingScrollPhysics(),
                    controller: PageController(viewportFraction: 0.9),
                    scrollDirection: Axis.horizontal,
                    //pageSnapping: true,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.import_contacts,
                                    size: 25,
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    " About Corona",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w900),
                                  )
                                ],
                              ),

                              Expanded(
                                  child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 15, bottom: 20),
                                      child: ListView(
                                          physics: BouncingScrollPhysics(),
                                          children: <Widget>[
                                            ExpansionTile(
                                              leading: Icon(
                                                MdiIcons.bug,
                                                size: 25,
                                              ),
                                              trailing: Icon(
                                                Icons.add_circle_outline,
                                              ),
                                              title: Text("Corona Virus",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text.rich(
                                                  TextSpan(
                                                      style: TextStyle(
                                                          wordSpacing: 1,
                                                          letterSpacing: 0.5,
                                                          fontSize: 15),
                                                      text:
                                                          "Coronaviruses are a large family of viruses which may cause illness in animals or humans.  In humans, several coronaviruses are known to cause respiratory infections ranging from the common cold to more severe diseases such as ",
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                "Middle East Respiratory Syndrome (MERS) and Severe Acute Respiratory Syndrome (SARS). ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "The most recently discovered coronavirus causes coronavirus disease COVID-19.")
                                                      ]),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                MdiIcons.copyright,
                                                size: 25,
                                              ),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text(
                                                "COVID-19",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              children: <Widget>[
                                                Text.rich(
                                                  TextSpan(
                                                      style: TextStyle(
                                                          wordSpacing: 1,
                                                          letterSpacing: 0.5,
                                                          fontSize: 15),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "COVID-19 ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "is the infectious disease caused by the most recently discovered "),
                                                        TextSpan(
                                                            text:
                                                                "Coronavirus. ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "This new virus and disease were unknown before the outbreak began in "),
                                                        TextSpan(
                                                            text:
                                                                "Wuhan, China, in December 2019. ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                " “Co” refers to corona, “Vi” to virus, and “D” to disease",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ]),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                          ]))),
                              Divider(thickness: 5, color: Colors.black)
//
                            ],
                          ),
                        ), //SHOWSTATEINFO
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 8),

                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.new_releases,
                                  size: 25,
                                  color: Colors.blue,
                                ),
                                Text(
                                  " Symptoms",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w900),
                                )
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 20),
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  //physics: AlwaysScrollableScrollPhysics(),
                                  child: DataTable(
                                    //columnSpacing: 8.0,
                                    columns: <DataColumn>[
                                      DataColumn(
                                          label: Text(
                                        "People may experience: ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )),
                                    ],
                                    rows: <DataRow>[
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text(
                                          "Dry Cough",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        )),
                                      ]),
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text("Fever",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))),
                                      ]),
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text("Fatigue",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))),
                                      ]),
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text("Difficulty in Breathing",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))),
                                      ]),
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text("Aches and Pains",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))),
                                      ]),
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text("Nasal Congestion",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))),
                                      ]),
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text("Runny nose",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))),
                                      ]),
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text("Sore Throat",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))),
                                      ]),
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text("Diarrohea",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500))),
                                      ]),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Divider(
                              color: Colors.black,
                              thickness: 5,
                            ),
                          ],
                        ), //SHOWSTATEINFO
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.security,
                                    size: 25,
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    " Prevention",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w900),
                                  )
                                ],
                              ),
                              Expanded(
                                  child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 15, bottom: 20),
                                      child: ListView(
                                          physics: BouncingScrollPhysics(),
                                          children: <Widget>[
                                            ExpansionTile(
                                              leading: Icon(
                                                MdiIcons.handWater,
                                                size: 22,
                                              ),
                                              trailing: Icon(
                                                Icons.add_circle_outline,
                                              ),
                                              title: Text("Wash Your Hands",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text(
                                                    "Washing your hands with soap and water or using alcohol-based hand rub kills viruses that may be on your hands.",
                                                    style: TextStyle(
                                                        wordSpacing: 1,
                                                        letterSpacing: 0.5,
                                                        fontSize: 15)),
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                Icons.straighten,
                                                size: 20,
                                              ),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text("Maintain distance",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text(
                                                  "Maintain at least 1 metre (3 feet) distance between yourself and anyone who is coughing or sneezing." +
                                                      "When someone coughs or sneezes they spray small liquid droplets from their nose or mouth which may contain virus. If you are too close, you can breathe in the droplets, including the COVID-19 virus if the person coughing has the disease.",
                                                  style: TextStyle(
                                                      wordSpacing: 1,
                                                      letterSpacing: 0.5,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                Icons.pan_tool,
                                                size: 20,
                                              ),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text(
                                                  "Avoid touching eyes, nose and mouth.",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text(
                                                  "Hands touch many surfaces and can pick up viruses. Once contaminated, hands can transfer the virus to your eyes, nose or mouth. From there, the virus can enter your body and can make you sick.",
                                                  style: TextStyle(
                                                      wordSpacing: 1,
                                                      letterSpacing: 0.5,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                Icons.ac_unit,
                                                size: 20,
                                              ),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text(
                                                  "Follow good respiratory hygiene",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text(
                                                  "Covering your mouth and nose with your bent elbow or tissue when you cough or sneeze. Then dispose of the used tissue immediately",
                                                  style: TextStyle(
                                                      wordSpacing: 1,
                                                      letterSpacing: 0.5,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                Icons.home,
                                                size: 20,
                                              ),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text("Stay home",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text(
                                                  "Staying at home most of the time and maintaining social distance will keep you and others away from virus.",
                                                  style: TextStyle(
                                                      wordSpacing: 1,
                                                      letterSpacing: 0.5,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                Icons.directions_car,
                                                size: 20,
                                              ),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text("Avoid Travelling",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text(
                                                  "This will also protect you and  prevent spread of viruses and other infections.",
                                                  style: TextStyle(
                                                      wordSpacing: 1,
                                                      letterSpacing: 0.5,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                Icons.system_update_alt,
                                                size: 20,
                                              ),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text("Keep Up-to-date",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text(
                                                  "Keep up to date on the latest COVID-19 hotspots (cities or local areas where COVID-19 is spreading widely",
                                                  style: TextStyle(
                                                      wordSpacing: 1,
                                                      letterSpacing: 0.5,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ]))),
                              Divider(thickness: 5, color: Colors.black)
                            ],
                          ),
                        ), //SHOWSTATEINFO
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    MdiIcons.headQuestionOutline,
                                    size: 25,
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    " Q&A",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w900),
                                  )
                                ],
                              ),

                              Expanded(
                                  child: Padding(
                                      padding:
                                          EdgeInsets.only(top: 15, bottom: 20),
                                      child: ListView(
                                          physics: BouncingScrollPhysics(),
                                          children: <Widget>[
                                            ExpansionTile(
                                              leading: Icon(
                                                  MdiIcons.fileQuestionOutline,
                                                  size: 22),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text(
                                                  "Should I worry about COVID-19?",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
//
                                                Text.rich(
                                                  TextSpan(
                                                      style: TextStyle(
                                                          wordSpacing: 1,
                                                          letterSpacing: 0.5,
                                                          fontSize: 15),
                                                      text: "Illness due to ",
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "COVID-19 ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "infection is generally mild, especially for children and young adults. However, it can cause serious illness: about "),
                                                        TextSpan(
                                                            text:
                                                                "1 in every 5 people and need intensive hospital care.",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ]),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                  MdiIcons.fileQuestionOutline,
                                                  size: 22),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text(
                                                  "Is there any vaccine,drug or treatment for COVID-19?",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text.rich(
                                                  TextSpan(
                                                      style: TextStyle(
                                                          wordSpacing: 1,
                                                          letterSpacing: 0.5,
                                                          fontSize: 15),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "Not yet. ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "To date, there is no vaccine and no specific antiviral medicine to prevent or treat "),
                                                        TextSpan(
                                                            text:
                                                                "COVID-2019. ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "However, people with serious illness should be hospitalized and recovered ones thank to medical care."),
                                                      ]),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                  MdiIcons.fileQuestionOutline,
                                                  size: 22),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text(
                                                  "Is COVID-19 the same as SARS?",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text.rich(
                                                  TextSpan(
                                                      style: TextStyle(
                                                          wordSpacing: 1,
                                                          letterSpacing: 0.5,
                                                          fontSize: 15),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "No. ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "The virus that causes "),
                                                        TextSpan(
                                                            text:
                                                                "COVID-2019 & SARS. ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "are related to each other genetically, but the diseases they cause are quite different."),
                                                      ]),
                                                )
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                            ExpansionTile(
                                              leading: Icon(
                                                  MdiIcons.fileQuestionOutline,
                                                  size: 22),
                                              trailing: Icon(
                                                  Icons.add_circle_outline),
                                              title: Text("Should I wear mask?",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              children: <Widget>[
                                                Text(
                                                  "Only wear a mask if you are ill with COVID-19 symptoms (especially coughing) or looking after someone who may have COVID-19",
                                                  style: TextStyle(
                                                      wordSpacing: 1,
                                                      letterSpacing: 0.5,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                            Divider(color: Colors.grey),
                                          ]))),
                              Divider(thickness: 5, color: Colors.black)
//
                            ],
                          ),
                        ), //SHOWSTATEINFO
                      ),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      MdiIcons.lightbulbOutline,
                                      size: 25,
                                      color: Colors.blue,
                                    ),
                                    Text(
                                      "Tip",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w900),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20),
                                Expanded(
                                  child: Material(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    elevation: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(35)),
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/hindi.jpg'),
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                ListTile(
                                  title: Text(
                                    "PM Narendra Modi emphasised this slogan while addressing on March 24, 2020.",
                                    style: TextStyle(
                                        wordSpacing: 1,
                                        letterSpacing: 0.5,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Divider(),
                                Divider(thickness: 5, color: Colors.black),
                              ]))),
//                      SizedBox(width: 1)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget aboutApp(context) {
    return AnimatedPositioned(
        duration: duration,
        top: 0,
        bottom: 0,
        left: isCollapsed ? 0 : 0.5 * screenWidth,
        right: isCollapsed ? 0 : -0.5 * screenWidth,
        child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                shadowColor: Colors.blueAccent,
                elevation: 10.0,
                child: Container(
                    padding: const EdgeInsets.only(left: 1, right: 1, top: 48),
                    decoration: BoxDecoration(
                        borderRadius: isCollapsed
                            ? null
                            : BorderRadius.all(Radius.circular(50)),
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/bg.png',
                          ),
                          fit: BoxFit.cover,
                        )),
                    child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                                child: Icon(
                                    isCollapsed
                                        ? Icons.arrow_back_ios
                                        : Icons.menu,
                                    color: Colors.white,
                                    size: 40.0),
                                onTap: () {
                                  HapticFeedback.vibrate();
                                  setState(() {
                                    if (isCollapsed)
                                      _controller.forward();
                                    else
                                      _controller.reverse();
                                    isCollapsed = !isCollapsed;
                                  });
                                }),
                            isCollapsed
                                ? Text("Menu",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15))
                                : Text("Read",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15)),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight / 25),
                      Container(
                          height: screenHeight * (3.8 / 5),
                          child: PageView(
                              physics: BouncingScrollPhysics(),
                              controller: PageController(viewportFraction: 0.9),
                              scrollDirection: Axis.horizontal,
                              //pageSnapping: true,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.import_contacts,
                                              size: 25,
                                              color: Colors.pinkAccent,
                                            ),
                                            Text(
                                              " About App",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.pinkAccent,
                                                  fontWeight: FontWeight.w900),
                                            )
                                          ],
                                        ),

                                        Expanded(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 15, bottom: 20),
                                                child: ListView(
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    children: <Widget>[
                                                      ListTile(
                                                        title: Text(
                                                            "CoronaTV app show the latest data of Covid-19 cases of whole world with country specifics also."),
                                                      ),
                                                      Divider(),
                                                      ListTile(
                                                        title: Text(
                                                          "It also shows the data of Indian States, like infected Indians,infected foreigners(residing in India),recovered and deaths.",
                                                          style: TextStyle(
                                                              wordSpacing: 1,
                                                              letterSpacing:
                                                                  0.5,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                      Divider(),
                                                      ListTile(
                                                        title: Text(
                                                          "Graphical representation will help you to understand the trends.",
                                                          style: TextStyle(
                                                              wordSpacing: 1,
                                                              letterSpacing:
                                                                  0.5,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                      Divider(),
                                                      ListTile(
                                                        title: Text(
                                                          "Your questions regarding the CoronaVirus are also answered.",
                                                          style: TextStyle(
                                                              wordSpacing: 1,
                                                              letterSpacing:
                                                                  0.5,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                      Divider(),
                                                      ListTile(
                                                          title: Text(
                                                        "Know how to prevent the virus from spreading and protect you and others from this deadly virus.",
                                                        style: TextStyle(
                                                            wordSpacing: 1,
                                                            letterSpacing: 0.5,
                                                            fontSize: 15),
                                                      )),
                                                      Divider(),
                                                    ]))),
                                        Divider(
                                            thickness: 5, color: Colors.black)
//
                                      ],
                                    ),
                                  ), //SHOWSTATEINFO
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              MdiIcons.sourceBranch,
                                              size: 25,
                                              color: Colors.pinkAccent,
                                            ),
                                            Text(
                                              " Source",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.pinkAccent,
                                                  fontWeight: FontWeight.w900),
                                            )
                                          ],
                                        ),
                                        Expanded(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 15, bottom: 20),
                                                child: ListView(
                                                    physics:
                                                        BouncingScrollPhysics(),
                                                    children: <Widget>[
                                                      ListTile(
                                                        title: Text(
                                                            "This app fetches the data from APIs and WHO website."),
                                                      ),
                                                      Divider(),
                                                      ListTile(
                                                          title: Text(
                                                              "https://api.rootnet.in/covid19-in/stats/latest",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue)),
                                                          onTap: () async {
                                                            HapticFeedback
                                                                .vibrate();
                                                            String num =
                                                                "https:api.rootnet.in/covid19-in/stats/latest";
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text: num));
                                                            Fluttertoast
                                                                .showToast(
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER,
                                                              msg:
                                                                  "Link copied to clipboard",
                                                              //textColor: Colors.blue,
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                            );
//                                                        await canLaunch(num)?
//                                                        await launch(num) : throw 'cannot';
                                                          }),
                                                      Divider(),
                                                      ListTile(
                                                          title: Text(
                                                              "https://api.rootnet.in/covid19-in/stats/daily",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue)),
                                                          onTap: () async {
                                                            HapticFeedback
                                                                .vibrate();
                                                            String num =
                                                                "https:api.rootnet.in/covid19-in/stats/daily";
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text: num));
                                                            Fluttertoast
                                                                .showToast(
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER,
                                                              msg:
                                                                  "Link copied to clipboard",
                                                              //textColor: Colors.blue,
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                            );
//                                                        await canLaunch(num)?
//                                                        await launch(num) : throw 'cannot';
                                                          }),
                                                      Divider(),
                                                      ListTile(
                                                          title: Text(
                                                              " https://api.rootnet.in/covid19-in/contacts",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blue)),
                                                          onTap: () async {
                                                            HapticFeedback
                                                                .vibrate();
                                                            String num =
                                                                "https:api.rootnet.in/covid19-in/contacts";
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text: num));
                                                            Fluttertoast
                                                                .showToast(
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER,
                                                              msg:
                                                                  "Link copied to clipboard",
                                                              //textColor: Colors.blue,
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                            );
//                                                        await canLaunch(num)?
//                                                        await launch(num) : throw 'cannot';
                                                          }),
                                                      Divider(),
                                                      ListTile(
                                                          title: Text(
                                                            " https://www.who.int/news-room/q-a-detail/q-a-coronaviruses",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue),
                                                          ),
                                                          onTap: () async {
                                                            HapticFeedback
                                                                .vibrate();
                                                            String num =
                                                                "https:www.who.int/news-room/q-a-detail/q-a-coronaviruses";
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text: num));
                                                            Fluttertoast
                                                                .showToast(
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER,
                                                              msg:
                                                                  "Link copied to clipboard",
                                                              //textColor: Colors.blue,
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                            );
//                                                        await canLaunch(num)?
//                                                        await launch(num) : throw 'cannot';
                                                          }),
                                                      Divider()
                                                    ]))),
                                        Divider(
                                            thickness: 5, color: Colors.black)
                                      ],
                                    ),
                                  ), //SHOWSTATEINFO
                                ),
//                                SizedBox(width: 1)
                              ]))
                    ])))));
  }

  Widget aboutMe(context) {
    return AnimatedPositioned(
        duration: duration,
        top: 0,
        bottom: 0,
        left: isCollapsed ? 0 : 0.5 * screenWidth,
        right: isCollapsed ? 0 : -0.5 * screenWidth,
        child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                shadowColor: Colors.blueAccent,
                elevation: 10.0,
                child: Container(
                    padding: const EdgeInsets.only(left: 1, right: 1, top: 48),
                    decoration: BoxDecoration(
                        borderRadius: isCollapsed
                            ? null
                            : BorderRadius.all(Radius.circular(50)),
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/bg.png',
                          ),
                          fit: BoxFit.cover,
                        )),
                    child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                                child: Icon(
                                    isCollapsed
                                        ? Icons.arrow_back_ios
                                        : Icons.menu,
                                    color: Colors.white,
                                    size: 40.0),
                                onTap: () {
                                  HapticFeedback.vibrate();
                                  setState(() {
                                    if (isCollapsed)
                                      _controller.forward();
                                    else
                                      _controller.reverse();
                                    isCollapsed = !isCollapsed;
                                  });
                                }),
                            isCollapsed
                                ? Text("Menu",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15))
                                : Text("Read",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15)),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight / 25),
                      Container(
                          height: screenHeight * (3.8 / 5),
                          child: PageView(
                              physics: BouncingScrollPhysics(),
                              controller: PageController(viewportFraction: 0.9),
                              scrollDirection: Axis.horizontal,
                              //pageSnapping: true,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10, right: 10, left: 10),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.import_contacts,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                          Text(
                                            " Contact Details",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w900),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: ListView(
                                            physics: BouncingScrollPhysics(),
                                            children: <Widget>[
                                              UserAccountsDrawerHeader(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                35)),
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/cover.jpg'),
                                                        fit: BoxFit.cover)),
                                                accountName: Text(
                                                  "Prayant Gupta",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 22,
                                                      fontFamily: 'Pacifico'),
                                                ),
                                                accountEmail: Text(
                                                  "(Developer)",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                currentAccountPicture:
                                                    CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                      'assets/images/me.png'),
                                                ),
                                              ),
                                              Divider(),
                                              ExpansionTile(
                                                trailing: Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                title: Text("Connect via",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                children: <Widget>[
                                                  Wrap(
                                                    direction: Axis.vertical,
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons.phone,
                                                                size: 25,
                                                                color: Colors
                                                                    .brown),
                                                            onPressed:
                                                                () async {
                                                              String num =
                                                                  "8826173684";
                                                              HapticFeedback
                                                                  .vibrate();
                                                              CallNumber()
                                                                  .callNumber(
                                                                      num);
//                                                          await canLaunch(n)? await launch(n) : throw'cnat';
//
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                                MdiIcons
                                                                    .whatsapp,
                                                                size: 25,
                                                                color: Colors
                                                                    .green),
                                                            onPressed:
                                                                () async {
                                                              HapticFeedback
                                                                  .vibrate();
                                                              FlutterOpenWhatsapp
                                                                  .sendSingleMessage(
                                                                      "+918826173684",
                                                                      "Hello");
//                                                          _launchWhatsApp();
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                                MdiIcons.gmail,
                                                                size: 25,
                                                                color:
                                                                    Colors.red),
                                                            onPressed:
                                                                () async {
                                                              HapticFeedback
                                                                  .vibrate();
                                                              String n =
                                                                  "prayantgupta15@gmailcom";
                                                              Clipboard.setData(
                                                                  ClipboardData(
                                                                      text: n));
                                                              Fluttertoast
                                                                  .showToast(
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                msg:
                                                                    "E-mail copied to clipboard",
                                                                //textColor: Colors.blue,
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                              );
//                                                          await canLaunch(n)?await launch(n): throw'cannot';
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                                MdiIcons
                                                                    .facebook,
                                                                size: 25,
                                                                color: Colors
                                                                    .blue),
                                                            onPressed:
                                                                () async {
                                                              HapticFeedback
                                                                  .vibrate();
                                                              String n =
                                                                  "https:www.facebook.com/prayant.gupta";
                                                              Clipboard.setData(
                                                                  ClipboardData(
                                                                      text: n));
                                                              Fluttertoast
                                                                  .showToast(
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                msg:
                                                                    "FB-Link copied to clipboard",
                                                                //textColor: Colors.blue,
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                              );
//                                                          await canLaunch(n)? await launch(n) : throw'cnat';
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                                MdiIcons
                                                                    .instagram,
                                                                size: 25,
                                                                color: Colors
                                                                    .pink),
                                                            onPressed:
                                                                () async {
                                                              HapticFeedback
                                                                  .vibrate();
                                                              String n =
                                                                  "https:instagram.com/gupta_prayant";
                                                              Clipboard.setData(
                                                                  ClipboardData(
                                                                      text: n));
                                                              Fluttertoast
                                                                  .showToast(
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                msg:
                                                                    "Insta-link copied to clipboard",
                                                                //textColor: Colors.blue,
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                              );
//                                                          await canLaunch(n)? await launch(n) : throw'cnat';
                                                            },
                                                          ),
                                                          IconButton(
                                                            icon: Icon(
                                                              MdiIcons.linkedin,
                                                              size: 25,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              HapticFeedback
                                                                  .vibrate();
                                                              String n =
                                                                  "https:www.linkedin.com/in/prayant-g-92b6a6112/";
                                                              Clipboard.setData(
                                                                  ClipboardData(
                                                                      text: n));
                                                              Fluttertoast
                                                                  .showToast(
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                msg:
                                                                    "Linkedin-link copied to clipboard",
                                                                //textColor: Colors.blue,
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                              );
//                                                            await canLaunch(n)? await launch(n) : throw'cnat';
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              ExpansionTile(
                                                trailing: Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                title: Text("Share app via",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                children: <Widget>[
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: <Widget>[
                                                        IconButton(
                                                          icon: Icon(
                                                              MdiIcons.whatsapp,
                                                              size: 25,
                                                              color:
                                                                  Colors.green),
                                                          onPressed: () async {
                                                            HapticFeedback
                                                                .vibrate();
                                                            final RenderBox
                                                                box = context
                                                                    .findRenderObject();
                                                            Share.share(msg,
                                                                sharePositionOrigin:
                                                                    box.localToGlobal(
                                                                            Offset.zero) &
                                                                        box.size);
//                                                        FlutterShareMe()
//                                                            .shareToWhatsApp(
//                                                                base64Image:
//                                                                msg: msg);
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                              MdiIcons
                                                                  .shareVariant,
                                                              size: 25,
                                                              color: Colors
                                                                  .deepOrange),
                                                          onPressed: () async {
                                                            HapticFeedback
                                                                .vibrate();
                                                            final RenderBox
                                                                box = context
                                                                    .findRenderObject();
                                                            Share.share(msg,
                                                                sharePositionOrigin:
                                                                    box.localToGlobal(
                                                                            Offset.zero) &
                                                                        box.size);
//                                                        FlutterShareMe().shareToSystem(msg: msg);
                                                          },
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                              Divider(),
                                            ]),
                                      ),
                                      Divider(thickness: 5, color: Colors.black)
                                    ],
                                  ), //SHOWSTATEINFO
                                ),
//                                SizedBox(width: 1)
                              ]))
                    ])))));
  }

  Widget World(context) {
    return AnimatedPositioned(
        duration: duration,
        top: 0,
        bottom: 0,
        left: isCollapsed ? 0 : 0.5 * screenWidth,
        right: isCollapsed ? 0 : -0.5 * screenWidth,
        child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                shadowColor: Colors.blueAccent,
                elevation: 10.0,
                child: Container(
                    padding: const EdgeInsets.only(left: 1, right: 1, top: 48),
                    decoration: BoxDecoration(
                        borderRadius: isCollapsed
                            ? null
                            : BorderRadius.all(Radius.circular(50)),
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/bg.png',
                          ),
                          fit: BoxFit.cover,
                        )),
                    child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                                child: Icon(
                                    isCollapsed
                                        ? Icons.arrow_back_ios
                                        : Icons.menu,
                                    color: Colors.white,
                                    size: 40.0),
                                onTap: () {
                                  HapticFeedback.vibrate();
                                  setState(() {
                                    if (isCollapsed)
                                      _controller.forward();
                                    else
                                      _controller.reverse();
                                    isCollapsed = !isCollapsed;
                                  });
                                }),
                            isCollapsed
                                ? Text("Menu",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15))
                                : Text("Read",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15)),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight / 25),
                      Container(
                          height: screenHeight * (3.8 / 5),
                          child: PageView(
                              physics: BouncingScrollPhysics(),
                              controller: PageController(viewportFraction: 0.9),
                              scrollDirection: Axis.horizontal,
                              //pageSnapping: true,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0, bottom: 10.0),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(10, 20, 10, 10),
                                    child: RefreshIndicator(
                                      key: refreshKey,
                                      backgroundColor: Colors.black87,
                                      onRefresh: () {
                                        make_request();
                                      },
                                      child: SingleChildScrollView(
                                          physics: BouncingScrollPhysics(),
//                                          AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons
                                                        .format_list_numbered_rtl,
                                                    size: 25,
                                                    color: Colors.amber,
                                                  ),
                                                  Text(
                                                    " Summary",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.amber,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              DataTable(
                                                columnSpacing: 15.0,
                                                columns: <DataColumn>[
                                                  DataColumn(
                                                      label: Text("Particular",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800)),
                                                      numeric: false),
                                                  DataColumn(
                                                      label: Text("Value",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800)),
                                                      numeric: true)
                                                ],
                                                rows: <DataRow>[
                                                  DataRow(cells: <DataCell>[
                                                    DataCell(Text(
                                                      "Total Infected:",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )),
                                                    DataCell(Text(
                                                        extractdata4[
                                                                "Global_Confirmed"]
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                                  ]),
                                                  DataRow(cells: <DataCell>[
                                                    DataCell(Text("Recovered:",
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                                    DataCell(Text(
                                                        extractdata4[
                                                                "Global_Recovered"]
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                                  ]),
                                                  DataRow(cells: <DataCell>[
                                                    DataCell(Text(
                                                      "Death(s):",
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    )),
                                                    DataCell(Text(
                                                        extractdata4[
                                                                "Global_Deaths"]
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                                  ]),
                                                ],
                                              ),
                                              Container(
                                                height: 200,
                                                padding:
                                                    EdgeInsets.only(bottom: 10),
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                  "Swipe down to Refresh",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              Divider(
                                                  thickness: 5,
                                                  color: Colors.black)
                                            ],
                                          )),
                                    ),
                                  ), //SHOWSTATEINFO
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10, left: 10, right: 10),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            MdiIcons.mapMarkerRadius,
                                            size: 25,
                                            color: Colors.amber,
                                          ),
                                          Text(
                                            " Countries Data",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.amber,
                                                fontWeight: FontWeight.w900),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: ListView.separated(
                                            physics: BouncingScrollPhysics(),
                                            separatorBuilder:
                                                (context, index) => Divider(),
//                                            shrinkWrap: true,
                                            itemCount: extractdata4["countries"]
                                                .length,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                elevation: 3,
                                                child: ExpansionTile(
                                                  leading: Icon(
                                                    MdiIcons.gestureTap,
                                                    size: 25,
                                                  ),
                                                  title: Text(
                                                      extractdata4["countries"]
                                                              [index]["name"]
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  children: <Widget>[
                                                    DataTable(
                                                      columnSpacing: 22.0,
                                                      headingRowHeight: 30,
                                                      columns: <DataColumn>[
                                                        DataColumn(
                                                          label: Text(
                                                            "Case",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .blue),
                                                          ),
                                                          numeric: false,
                                                        ),
                                                        DataColumn(
                                                            label: Text(
                                                                "Number of persons",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .blue)),
                                                            numeric: false)
                                                      ],
                                                      rows: <DataRow>[
                                                        DataRow(
                                                            cells: <DataCell>[
                                                              DataCell(Text(
                                                                  "Confirmed:",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .orange,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))),
                                                              DataCell(
                                                                Text(
                                                                    extractdata4["countries"][index]
                                                                            [
                                                                            "total_confirmed"]
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .orange,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w500)),
                                                              ),
                                                            ]),
                                                        DataRow(
                                                            cells: <DataCell>[
                                                              DataCell(Text(
                                                                  "Recovered:",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))),
                                                              DataCell(Text(
                                                                  extractdata4["countries"]
                                                                              [
                                                                              index]
                                                                          [
                                                                          "total_recovered"]
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))),
                                                            ]),
                                                        DataRow(
                                                            cells: <DataCell>[
                                                              DataCell(Text(
                                                                  "Death(s):",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))),
                                                              DataCell(Text(
                                                                  extractdata4["countries"]
                                                                              [
                                                                              index]
                                                                          [
                                                                          "total_deaths"]
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500))),
                                                            ]),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ), //SHOWSTATEINFO
                                ),
//                                SizedBox(width: 1)
                              ]))
                    ])))));
  }

//  _launchWhatsApp() async {
//    String phoneNumber = '+91-8826173684';
//    String message =
//        'Hello bro!!. Your app seems to be very fascinating. I am <YOUR_NAME> from <CITY/STATE>.';
//    var whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$message";
//    if (await canLaunch(whatsappUrl)) {
//      await launch(whatsappUrl);
//    } else {
//      throw 'Could not launch $whatsappUrl';
//    }
//}
}
