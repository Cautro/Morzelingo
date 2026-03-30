import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:morzelingo/pages/freemode/bloc/freemode_bloc.dart';
import 'package:morzelingo/pages/freemode/repository/freemode_repository.dart';
import 'package:morzelingo/pages/freemode/service/freemode_service.dart';
import 'package:morzelingo/pages/freemode/view/freemode_audio_page.dart';
import 'package:morzelingo/pages/freemode/view/freemode_page.dart';
import 'package:morzelingo/pages/freemode/view/freemode_text_page.dart';
import '../../../app_theme.dart';


class FreemodeFlowPage extends StatelessWidget {
  const FreemodeFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => FreemodeBloc(repository: FreemodeRepository(), service: FreemodeService()),
        child: BlocConsumer<FreemodeBloc, FreemodeState>(
          listener: (context, state) {
            if (state.success != null) {
              Fluttertoast.showToast(
                  msg: state.message.toString(),
                  backgroundColor: state.success! ? AppTheme.success : AppTheme.error,
                  textColor: Colors.white
              );
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case FreemodeStatus.idle:
                return FreemodePage();
              case FreemodeStatus.error:
                return Center(child: Text(state.message ?? "Непредвиденная ошибка"),);
              case FreemodeStatus.active:
                switch (state.mode) {
                  case FreemodeMode.audio:
                    return FreemodeAudioPage(answer: state.answer, question: state.question,);
                  case FreemodeMode.text:
                    return FreemodeTextPage(question: state.question, answer: state.answer,);
                  default:
                    return Center(child: Text(state.message ?? "Непредвиденная ошибка"),);
                }
            }
          },
        )
    );
  }

}
