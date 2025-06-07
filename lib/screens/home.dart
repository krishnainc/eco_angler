import 'package:flutter/material.dart';
import 'package:eco_angler/screens/dishes.dart';
import 'package:eco_angler/widgets/grid_product.dart';
import 'package:eco_angler/widgets/home_category.dart';
import 'package:eco_angler/widgets/slider_item.dart';
import 'package:eco_angler/util/fish.dart';
import 'package:eco_angler/util/fishingspot.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:eco_angler/screens/weather.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';




class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home>{
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        'https://www.youtube.com/watch?v=spTWwqVP_2s', // Replace with your own
      )!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }


  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  int _current = 0;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0,0,10.0,0),
        child: ListView(
          children: <Widget>[

            SizedBox(height: 10.0),

            WeatherCard(), // <- This shows the dynamic weather widget

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Invasive Fish Species in Malaysia",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

              ],
            ),

            SizedBox(height: 30.0),

            //Slider Here

            CarouselSlider(
                items: fish.map<Widget>((food) {
                  return AbsorbPointer(
                    absorbing: true, // Disable clicking
                    child: SliderItem(
                      img: food['img'],
                      isFav: false,
                      name: food['name'],
                      rating: 5.0,
                    ),
                  );
                }).toList(),
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height / 2.4,
                autoPlay: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            SizedBox(height: 10.0),


            Text(
              "Watch: Impact of Invasive Fish Species",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.redAccent,
              width: MediaQuery.of(context).size.width,
              aspectRatio: 16 / 9,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
