import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mygptapp/feature_box.dart';
import 'package:mygptapp/openai_service.dart';
import 'package:mygptapp/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int start = 200;
  int delay = 200;
  String? generatedContent;
  String? generatedImageUrl;
  FlutterTts flutterTts = FlutterTts();
  final OpenAIService openAIService = OpenAIService();
  String lastWords='';
  final  speachToText=SpeechToText();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeachToText();
    initTextToSpeach();
  }
  Future<void> initSpeachToText()async {
     await speachToText.initialize();
     setState(() {});
  }
  Future<void> initTextToSpeach() async{
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }
 Future<void> startListening() async {
    await speachToText.listen(onResult: onSpeechResult);
    setState(() {});
  }
 Future< void> stopListening() async {
    await speachToText.stop();
    setState(() {});
  }
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      print(lastWords);
    });
  }
  Future<void> systemSpeak(String content) async{
    await flutterTts.speak(content);
  }
  @override
  void dispose() {
    speachToText.stop();
    flutterTts.stop();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: BounceInDown(
          child: const Text("GPT")),leading: const Icon(Icons.menu),
        centerTitle: true,),
      body: SingleChildScrollView(
        child: Column(
            children: [
              //avatar
              ZoomIn(
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        margin: const EdgeInsets.only(top:4),
                        decoration: const BoxDecoration(color:Pallete.assistantCircleColor,
                            shape: BoxShape.circle
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 123,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage("assets/images/virtualAssistant.png"))
                        ),

                      ),
                    )
                  ],
                ),
              ),
              //chatBubble
              FadeInRight(
                child: Visibility(
                  visible: generatedImageUrl==null ,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                      top: 30
                    ),
                    decoration: BoxDecoration(
                      border:Border.all(
                        color: Pallete.borderColor,

                      ),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        topLeft:Radius.zero
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(generatedContent==null?"Good morning, What task can I do for you?":generatedContent!,
                      style: TextStyle(color: Pallete.mainFontColor,
                      fontSize: generatedContent==null?25:18,
                      fontFamily: 'Cera Pro'),),
                    ),
                  ),
                ),
              ),
              if(generatedImageUrl!=null) Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                    borderRadius:BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!),
                ),
              ),
              SlideInLeft(
                child: Visibility(
                  visible: generatedContent ==null && generatedImageUrl == null,
                  child: Container(padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(top: 10,left: 22),
                    child: const Text('here are a few features',style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                ),
              ),
              //suggestions list

               Visibility(
                 visible: generatedContent ==null && generatedImageUrl ==null ,
                 child: Column(
                  children: [
                    SlideInLeft(
                      delay:Duration(milliseconds: start),
                      child: const FeatureBox(color: Pallete.firstSuggestionBoxColor,
                        headerText: "ChatGPT",descriptionText: 'A smarter way to stay organized and informed with ChatGPT',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start+delay),
                      child: const FeatureBox(color: Pallete.secondSuggestionBoxColor,
                        headerText: "Dall-E",descriptionText: 'Get inspired and stay creative with your personal assistant Dall-E',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start +2*delay),
                      child: const FeatureBox(
                        color: Pallete.thirdSuggestionBoxColor,
                        headerText: "Smart Voice Assistant",
                        descriptionText: 'Get the best of both worlds with a voice assistant powered by Dall-E and CatGPT',
                      ),
                    ),
                  ],
              ),
               )

            ]
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start +3*delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if(await speachToText.hasPermission && speachToText.isNotListening){
              await startListening();
            }
            else if(speachToText.isListening){

             final speach= await openAIService.isArtPromptAPI(lastWords);
             if(speach.contains('https')){
               generatedImageUrl = speach;
               generatedContent = null;
               setState(() {});
             }
             else{
               generatedImageUrl = null;
               generatedContent = speach;
              setState(() {});
               await systemSpeak(speach);
             }
              await stopListening();
            }
            else{
              initSpeachToText();
            }
          },
          child: Icon(speachToText.isListening?Icons.stop:Icons.mic,
          ),
        ),
      ),
    );
  }
}