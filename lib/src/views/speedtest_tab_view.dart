import 'dart:math';

import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twitch_speedtest/src/models/app_state_model.dart';
import 'package:twitch_speedtest/src/models/twitch_state_model.dart';

class SpeedTestTabView extends StatelessWidget {
  Widget get _appLoading {
    return SpinKitFadingCircle(
      color: Colors.deepPurple,
      size: 50.0,
    );
  }

  Widget _ping(TwitchStateModel state) {
    final latency = state == TwitchLoadingState.TestingPing ? (state.lastLatency ?? state.avgLatency).toString() : (state.avgLatency).toString();

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Latency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(latency, style: TextStyle(fontSize: 32)),
                    Text('ms', style: TextStyle(fontSize: 16, color: Color(0xFFCACACA))),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Jitter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(state.jitter.toString(), style: TextStyle(fontSize: 32)),
                    Text('ms', style: TextStyle(fontSize: 16, color: Color(0xFFCACACA))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _speed(TwitchStateModel state) {
    final currentSpeed = ((state.lastSpeedBytes ?? 0.0) / 125000);
    final value = min(currentSpeed, 150);

    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SfRadialGauge(
                enableLoadingAnimation: true,
                animationDuration: 3000,
                axes: <RadialAxis>[
                  RadialAxis(
                    axisLineStyle: AxisLineStyle(thickness: 30),
                    showTicks: false,
                    minimum: 0,
                    maximum: 150,
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(currentSpeed.toStringAsFixed(2), style: TextStyle(fontSize: 38.0, fontWeight: FontWeight.bold)),
                              Text('Mbps', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      ),
                    ],
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: value,
                        color: Colors.deepPurpleAccent.shade200,
                        width: 30.0,
                        enableAnimation: true,
                      ),
                      NeedlePointer(
                        value: value,
                        enableAnimation: true,
                        needleStartWidth: 0,
                        needleEndWidth: 3,
                        needleColor: Colors.deepPurpleAccent.shade700,
                        knobStyle: KnobStyle(
                          color: Colors.white,
                          borderColor: Colors.deepPurpleAccent.shade700,
                          knobRadius: 0.06,
                          borderWidth: 0.04,
                        ),
                        tailStyle: TailStyle(
                          color: Colors.deepPurpleAccent.shade700,
                          width: 3,
                          length: 0.15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
          switch (twitchState.state) {
            case TwitchLoadingState.NoServers:
            case TwitchLoadingState.Error:
            case TwitchLoadingState.Preparing:
            case TwitchLoadingState.Standby:
              child = _standby(
                state: twitchState.state,
                onStartButtonPress: twitchState.start,
              );
              break;

            case TwitchLoadingState.TestingPing:
//            default:
              child = _ping(
                twitchState,
              );
              break;

            case TwitchLoadingState.TestingSpeed:
              child = _speed(
                twitchState,
              );
              break;
        }
        }

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            padding: EdgeInsetsDirectional.zero,
            middle: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Center(child: Text('SpeedTest')),
                Positioned(
                  left: -8,
                  right: -8,
                  bottom: 0,
                  child: CupertinoProgressBar(
                    value: twitchState.progress,
                    trackColor: null,
                  ),
                ),
              ],
            ),
//            middle: Text('SpeedTest'),

          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}
