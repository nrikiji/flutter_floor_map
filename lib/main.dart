import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Floor Map'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const DEFAULT_MARKER_SIZE = 50.0;

class _MyHomePageState extends State<MyHomePage> {
  final image = Image.asset("images/map.png").image;
  final photoController = PhotoViewController();

  // Default map image scale value.
  double defaultImageScale = 0.75;

  // Size of the area for displaying the map's image.
  double viewportWidth;
  double viewportHeight;

  // Size of the map's original image
  double imageWidth;
  double imageHeight;

  // Position of the marker on the map image
  double markerPositionX = 633;
  double markerPositionY = 1103;

  // Marker's position on the screen
  double markerLeft = 0;
  double markerTop = 0;

  // Marker display size
  double markerSize = DEFAULT_MARKER_SIZE;

  // The initial display should be such that the marker is at the center of the screen.
  bool initialized = false;

  // Get the size of the map image.
  void _resolveImageProvider() {
    ImageStream stream = image.resolve(createLocalImageConfiguration(context));
    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      imageWidth = info.image.width.toDouble();
      imageHeight = info.image.height.toDouble();
    }));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImageProvider();
  }

  @override
  void initState() {
    photoController
      ..outputStateStream.listen(
            (event) {
          // Size of the map image on the screen.
          double virtualImageWidth = imageWidth * event.scale;
          double virtualImageHeight = imageHeight * event.scale;

          // Width and height of the map image protrudes from the screen
          double overWidth = (virtualImageWidth - viewportWidth) / 2;
          double overHeight = (virtualImageHeight - viewportHeight) / 2;

          // The current scale value relative to the default scale value.
          double diffScale = event.scale / defaultImageScale;

          // Location of the marker on the map image
          double absoluteMarkerPositionX = markerPositionX * event.scale - markerSize / 2;
          double absoluteMarkerPositionY = markerPositionY * event.scale - markerSize;

          setState(() {
            // Resize the marker image to fit the scale.
            markerSize = DEFAULT_MARKER_SIZE * diffScale;

            // Position of the marker on the screen
            markerLeft = event.position.dx - overWidth + absoluteMarkerPositionX;
            markerTop = event.position.dy - overHeight + absoluteMarkerPositionY;

            if (!initialized) {
              // The initial display should be such that the marker is centered on the screen.
              photoController.position = Offset(
                virtualImageWidth / 2 - absoluteMarkerPositionX - markerSize / 2,
                virtualImageHeight / 2 - absoluteMarkerPositionY - markerSize,
              );
              initialized = true;
            }
          });
        },
      );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Size of the area to display the map image.
          viewportWidth = constraints.maxWidth;
          viewportHeight = constraints.maxHeight;

          return Stack(
            children: [
              Container(
                child: PhotoView(
                  controller: photoController,
                  imageProvider: image,
                  initialScale: defaultImageScale,
                  minScale: PhotoViewComputedScale.covered,
                ),
              ),
              Positioned(
                child: Image.asset("images/marker.png"),
                left: markerLeft,
                top: markerTop,
                width: markerSize,
              ),
            ],
          );
        },
      ),
    );
  }
}
