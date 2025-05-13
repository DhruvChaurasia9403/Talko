import 'dart:developer';
import 'package:chatting/AI/Model/chat_message_model.dart';
import 'package:chatting/AI/utils/Constants.dart';
import 'package:dio/dio.dart';

class ChatRepo {
  static Future<String> chatTextGenerationRepo(List<ChatMessageModel> previousMessages) async {
    try {
      Dio dio = Dio();
      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey',
        data: {
          "contents": previousMessages.map((e) => e.toMap()).toList(),
          "generationConfig": {
            "temperature": 0.9,
            "topK": 1,
            "topP": 1,
            "maxOutputTokens": 2048,
            "stopSequences": []
          },
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            },
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_MEDIUM_AND_ABOVE"
            }
          ]
        },
      );

      log(response.toString());

      if (response.statusCode == 200) {
        var data = response.data;

        if (data != null &&
            data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          String generatedText = data['candidates'][0]['content']['parts'][0]['text'];
          return generatedText;
        }
      }

      return "No response from the model.";
    } catch (e) {
      log("Error in chatTextGenerationRepo: $e");
      return "An error occurred while generating a response.";
    }
  }
}
