import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:twitch_speedtest/src/models/app_state_model.dart';
import 'package:twitch_speedtest/src/models/twitch_state_model.dart';

class SpeedTestTabView extends StatelessWidget {
  Widget get _appLoading {
    return SpinKitFadingCircle(
      color: Colors.deepPurple,
      size: 50.0,
    );
  }

  Widget _standby({ TwitchLoadingState state, Function onStartButtonPress }) {
    ButtonState buttonState = ButtonState.idle;

    switch (state) {
      case TwitchLoadingState.Error:
        buttonState = ButtonState.fail;
        break;

      case TwitchLoadingState.Preparing:
        buttonState = ButtonState.loading;
        break;
    }

    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ProgressButton.icon(iconedButtons: {
                ButtonState.idle:
                    IconedButton(
                      text: 'Start',
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      color: Colors.deepPurple.shade500,
                    ),

                ButtonState.loading:
                    IconedButton(
                      text: 'Loading',
                      color: Colors.deepPurple.shade700,
                    ),

                ButtonState.fail:
                    IconedButton(
                      text: 'Failed',
                      color: Colors.deepPurple.shade700,
                      icon: Icon(Icons.cancel, color: Colors.white),
                    ),

                ButtonState.success:
                    IconedButton(
                      text: 'Success',
                      icon: Icon(Icons.check_circle, color: Colors.white),
                      color: Colors.deepPurple.shade700,
                    ),
                },
                onPressed: onStartButtonPress,
                state: buttonState,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateModel, TwitchStateModel>(
      builder: (context, appState, twitchState, child) {
        Widget child = SizedBox();

        if (appState.isLoading) {
          child = _appLoading;
        } else {
          child = _standby(
              state: twitchState.state,
              onStartButtonPress: twitchState.init,
          );
        }

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('SpeedTest'),
          ),
          child: child,
        );
      },
    );
  }
}
