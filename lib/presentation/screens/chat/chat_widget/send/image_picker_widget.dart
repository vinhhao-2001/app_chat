import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_types/image_data.dart';
import '../../../../../core/theme/app_text.dart';
import '../../../../../domain/entities/message_entity.dart';
import '../../../../blocs/chat/chat_bloc.dart';
import '../../../../widgets/loading_widget.dart';

class ImagePickerWidget extends StatefulWidget {
  final String token;
  final String friendID;

  const ImagePickerWidget({
    super.key,
    required this.token,
    required this.friendID,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<AssetEntity> _images = [];
  final List<AssetEntity> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadImages();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 216,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                final selectedIndex = _selectedImages.indexOf(image);

                return FutureBuilder<File?>(
                  future: image.file,
                  builder: (context, snapshot) {
                    final file = snapshot.data;
                    if (file == null) {
                      return const Center(child: LoadingWidget(size: 60));
                    }
                    return GestureDetector(
                      onTap: () => _selectImage(image),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Image.file(file, fit: BoxFit.cover),
                            ),
                            if (selectedIndex != -1)
                              Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    (selectedIndex + 1).toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedImages.isNotEmpty)
            ElevatedButton(
              onPressed: _sendSelectedImages,
              child: Text('${AppText.textSend} ${_selectedImages.length} '
                  '${AppText.textImage}'),
            ),
        ],
      ),
    );
  }

  void _selectImage(AssetEntity image) {
    setState(() {
      if (_selectedImages.contains(image)) {
        _selectedImages.remove(image);
      } else {
        _selectedImages.add(image);
      }
    });
  }

  Future<void> _sendSelectedImages() async {
    for (var image in _selectedImages) {
      final file = await image.file;
      if (file != null) {
        final newMessage = MessageEntity(
          content: '',
          createdAt: DateTime.now(),
          messageType: 1,
          isSend: 0,
          files: [],
          images: [
            ImageData(
              urlImage: file.path,
              fileName: file.path.split('/').last,
            ),
          ],
        );
        if (!mounted) return;
        BlocProvider.of<ChatBloc>(context)
            .add(SendMessage(widget.token, widget.friendID, newMessage));
      }
    }

    setState(() {
      _selectedImages.clear();
    });
  }

  Future<void> _requestPermissionAndLoadImages() async {
    final status = await Permission.storage.request();

    if (status.isDenied) {
      openAppSettings();
    } else if (status.isGranted) {
      final albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isNotEmpty) {
        final recentAlbum = albums.first;
        final recentImages =
            await recentAlbum.getAssetListPaged(page: 0, size: 100);
        setState(() {
          _images = recentImages;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _selectedImages.clear();
  }
}
