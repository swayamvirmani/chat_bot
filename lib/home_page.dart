import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: '0', firstName: 'User');
  ChatUser geminiUser = ChatUser(id: '1', firstName: 'Gemini', profileImage: "https://logowik.com/content/uploads/images/google-ai-gemini91216.logowik.com.webp");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Chat'),
    ),
    body: _buildUi(),
    );
  }
  Widget _buildUi(){
    return DashChat(
    currentUser: currentUser, 
    onSend: _sendMessage,
    messages: messages,
    );
  }
  void _sendMessage(ChatMessage chatMessage){
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try{
        String question = chatMessage.text;
        gemini.streamGenerateContent(question).listen((event){
          ChatMessage? lastMessage = messages.firstOrNull;

          if(lastMessage != null && lastMessage.user == geminiUser){
            lastMessage = messages.removeAt(0);
            String response = event.content?.parts?.fold("",(previous, current) => "$previous${current.text}") ?? "";
            lastMessage.text += response; 
            setState(() {
              messages = [lastMessage!, ...messages];
            });

          }else{
            String response = event.content?.parts?.fold("",(previous, current) => "$previous${current.text}") ?? "";
            ChatMessage message = ChatMessage(
              user: geminiUser, 
              createdAt: DateTime.now(),
              text: response,
        );
        setState(() {
          messages = [message, ...messages];
        });
        }
        });

    }catch (e){
      print(e);
    }
    
  }
}