import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mygptapp/api.dart';
class OpenAIService {
  final List<Map<String, String>> message = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIkey',
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "user",
                "content": "does this message want to generate an AI picture, image, art or anything similar? '$prompt'. Simply answer with a yes or no.",
              },
              {
                "role": "user",
                "content": "Hello!"
              }
            ]
          })
      );
      print(response.body);
      if (response.statusCode == 200) {
        String content = jsonDecode(
            response.body)['choices'][0]['message']['content'];
        content = content.trim();
        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
          case 'YES':
            final response = dallEAPI(prompt);
            return response;
          default:
            final response = ChatGPTAPI(prompt);
            return response;
        }
      }
      return 'An internal error occurred';
    }
    catch (e) {
      return e.toString();
    }
  }

  Future<String> ChatGPTAPI(String prompt) async {
    message.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIkey',
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": message,
          })
      );
      print(response.body);
      if (response.statusCode == 200) {
        String content = jsonDecode(
            response.body)['choices'][0]['message']['content'];
        message.add({
          'role':'assistant',
          'content':content}
        );
        content = content.trim();
        return content;
      }
      return 'An internal error occurred';
    }
    catch (e) {
      return e.toString();
    }
  }


  Future<String> dallEAPI(String prompt) async {
    message.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
          Uri.parse('https://api.openai.com/v1/images/generations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIkey',
          },
          body: jsonEncode({
            'prompt':prompt,
            'n':1,
          })
      );
      print(response.body);
      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(
            response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        message.add({
            'role':'assistant',
            'content':imageUrl,
          });
        return imageUrl;
      }
      return 'An internal error occurred';
    }
    catch (e) {
      return e.toString();
    }
  }
}