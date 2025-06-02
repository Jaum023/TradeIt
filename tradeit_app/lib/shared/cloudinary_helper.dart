import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';

class CloudinaryHelper {
  static Future<String?> uploadImage(dynamic imageFile) async {
    const String cloudName = 'dlntdjm1l';
    const String uploadPreset = 'TradeIt';

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    if (kIsWeb) {
      final base64Image = base64Encode(imageFile as Uint8List);
      final randomName = 'web_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'file': 'data:image/png;base64,$base64Image',
          'upload_preset': uploadPreset,
          'public_id': randomName,
          'filename_override': randomName, 
        },
        encoding: Encoding.getByName('utf-8'),
      );
      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        return jsonResp['secure_url'];
      } else {
        print('Cloudinary error: ${response.body}');
        return null;
      }
    } else {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResp = json.decode(respStr);
        return jsonResp['secure_url'];
      } else {
        return null;
      }
    }
  }
}