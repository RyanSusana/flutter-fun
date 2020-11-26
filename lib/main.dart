import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(body: Home()),
    );
  }
}

class PageContent {
  final String bg, title, description;

  PageContent(this.title, this.description, this.bg);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController _controller = PageController(viewportFraction: 0.75);
  PageController _controllerBg = PageController();

  List<PageContent> contents;

  @override
  void initState() {
    contents = [
      PageContent("Joker", "Joker Descr",
          "https://www.uncommoncaribbean.com/wp-content/uploads/2017/01/Saint-Martin-Carnival-2016.jpg"),
      PageContent("Black Panther", "Joker Descr",
          "https://img.huffingtonpost.com/asset/5b9cc1a83c00004c0009e2a5.jpeg?ops=scalefit_960_noupscale"),
      PageContent("Good Boys", "Joker Descr",
          "https://i.pinimg.com/originals/d4/d5/f5/d4d5f5961e91de9a31be1b67663710d2.jpg"),
    ];

    _controller.addListener(() {
      double totalWidth = MediaQuery
          .of(context)
          .size
          .width;
      _controllerBg.jumpTo(_controller.page * totalWidth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: BgPageView(
              controllerBg: _controllerBg,
              contents: contents,
              controller: _controller,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 600,
              child: MainPageView(
                controller: _controller,
                contents: contents,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MainPageView extends StatelessWidget {
  const MainPageView({
    Key key,
    @required PageController controller,
    @required this.contents,
  })
      : _controller = controller,
        super(key: key);

  final PageController _controller;
  final List<PageContent> contents;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: BouncingScrollPhysics(),
      controller: _controller,
      itemCount: contents.length,
      itemBuilder: (BuildContext context, int index) {
        PageContent c = contents[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedBuilder(
            animation: _controller,
            child: NiceCard(page: c),
            builder: (BuildContext context, Widget child) {
              double distance = (_controller.page - index).abs();

              return Transform.translate(
                offset: Offset(0, 100 * distance),
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}

class NiceCard extends StatefulWidget {
  const NiceCard({
    Key key,
    @required this.page,
  }) : super(key: key);

  final PageContent page;

  @override
  _NiceCardState createState() => _NiceCardState();
}

class _NiceCardState extends State<NiceCard> {
  Color mainColor = Colors.white;
  @override
  void initState() {
    super.initState();
    _updatePalettes();
  }


  void _updatePalettes() async{
    var generator = await PaletteGenerator.fromImageProvider(NetworkImage(widget.page.bg));

    setState(() {
//      mainColor= generator.dominantColor.color;
    });
  }


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              "".text,
             AnimatedContainer(
                color: mainColor,
                duration: Duration(seconds: 1),
                height: 200,
                width: double.infinity,
              ),
            ],
          )
      ),
    );
  }
}

class BgPageView extends StatelessWidget {
  const BgPageView({
    Key key,
    @required PageController controllerBg,
    @required this.contents,
    @required PageController controller,
  })
      : _controllerBg = controllerBg,
        _controller = controller,
        super(key: key);

  final PageController _controllerBg;
  final List<PageContent> contents;
  final PageController _controller;

  @override
  Widget build(BuildContext context) {
    double totalWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Stack(
      children: <Widget>[
        PageView(
          controller: _controllerBg,
          physics: NeverScrollableScrollPhysics(),
          pageSnapping: false,
          children: contents
              .map((c) =>
              Stack(
                children: <Widget>[
                  AnimatedBuilder(
                    animation: _controllerBg,
                    child: SizedBox.expand(
                      child: Image.network(
                        c.bg,
                        fit: BoxFit.cover,
                      ),
                    ),
                    builder: (context, child) {
                      var page = _controller.page ?? 0;
                      int cur = page.floor();
                      double progression = page - cur;
                      return Stack(
                        children: <Widget>[
                          Transform.translate(
                            offset: Offset(
                                -totalWidth + progression * totalWidth, 0),
                            child: Transform.translate(
                              offset: Offset(
                                -totalWidth + totalWidth * progression,
                                0,
                              ),
                              child: ClipRect(
                                child: Transform.translate(
                                  offset: Offset(
                                      totalWidth - progression * totalWidth,
                                      0),
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: Offset(totalWidth * progression, 0),
                            child: ClipRect(
                              child: child,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ))
              .toList(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 500,
            width: totalWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white.withOpacity(0)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
