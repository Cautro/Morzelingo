import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';

class FreemodeAudioPage extends StatefulWidget {
  final String question;
  final String answer;
  const FreemodeAudioPage({super.key, required this.question, required this.answer});

  @override
  State<FreemodeAudioPage> createState() => _FreemodeAudioPageState();
}

class _FreemodeAudioPageState extends State<FreemodeAudioPage> {
  String text = "";
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Свободный режим - аудио"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: Column(
            children: [
              SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(height: 16,),
                          Text("Прослушайте морзе и переведите", style: Theme.of(context).textTheme.bodyLarge,),
                          SizedBox(height: 16,),
                          TextField(
                            controller: _controller,
                            onChanged: (value) {
                              setState(() {
                                text = value;
                                print(text);
                              });
                            },
                            decoration: InputDecoration(labelText: "Ответ"),
                          ),
                          SizedBox(height: 16,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                  context.read<FreemodeBloc>().add(AudioPlayEvent(question: widget.question));
                                },
                                child: Text("Прослушать", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),)
                            ),
                          ),
                          SizedBox(height: 16,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                  context.read<FreemodeBloc>().add(AnswerEvent(answer: widget.answer, text: text));
                                },
                                child: Text("Ответить", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),)
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );

  }
}