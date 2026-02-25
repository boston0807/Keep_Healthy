import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/config/cloud_config.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_api/uploader/uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/transformation/effect/effect.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
import 'dart:async';
import 'dart:io';

class CloudinaryService {
  final String apiKey = "581977842454375";
  final String apiSercret = '0ujNmkLjrnRjvEWO7dsZgnb2STE';
  late final cloudinary ;


  CloudinaryService();

  void initCloudinaryService(){
    cloudinary = Cloudinary.fromStringUrl("cloudinary:$apiKey:$apiSercret@keephealthy");
    cloudinary.config.urlConfig.secure = true;
  }

  Future<void> upload(File imageFile, String userID) async{
    try{
      final respond = await cloudinary.uploader().upload(imageFile, params: UploadParams(resourceType: 'image', folder: 'profile_picture', publicId: userID, overwrite: true, uniqueFilename: false,
      useFilename: true, tags: ['profile', 'user']));
      print(respond.secureUrl); 
    } catch (e){
      throw e.toString();
    }
  }
}