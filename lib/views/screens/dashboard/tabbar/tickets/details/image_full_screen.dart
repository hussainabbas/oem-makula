import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageViewFullScreen extends StatefulWidget {
  const ImageViewFullScreen({Key? key, required String imageURL})
      : _imageURL = imageURL,
        super(key: key);

  final String _imageURL;

  @override
  _ImageViewFullScreenState createState() => _ImageViewFullScreenState();
}

class _ImageViewFullScreenState extends State<ImageViewFullScreen> {
  @override
  Widget build(BuildContext context) {
    //print("object = > ${_dashBoardController.imageUrlRx.value}");
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            color: Colors.black,
            child: Center(
              child: Hero(
                tag: widget._imageURL,
                child: CachedNetworkImage(
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.zero,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  imageUrl: widget._imageURL,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 32, 8, 8),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
