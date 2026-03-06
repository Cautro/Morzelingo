import 'package:flutter/material.dart';

class FreemodePage extends StatefulWidget {
  const FreemodePage({super.key});

  @override
  State<FreemodePage> createState() => _FreemodePageState();
}

class _FreemodePageState extends State<FreemodePage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: Center(
            child: Container(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.all(16),
                            child: Text("Свободный режим", style: Theme.of(context).textTheme.titleLarge,),
                          ),
                          SizedBox(height: 16,),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/freemodeaudio");
                                },
                                child: Text("Играть в режиме аудио", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),),
                              ),
                          ),
                          SizedBox(height: 16,),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/freemodetext");
                                },
                                child: Text("Играть в режиме текста", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),),
                              ),
                            ),
                        ]
                    ),
                  )
                )
            ),
          )

          )
          ),
    );
  }
}
