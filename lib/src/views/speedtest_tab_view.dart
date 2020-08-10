import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:cupertino_progress_bar/cupertino_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twitch_speedtest/src/models/app_state_model.dart';
import 'package:twitch_speedtest/src/models/twitch_state_model.dart';

class SpeedTestTabView extends StatelessWidget {
  Widget get _appLoading {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CupertinoActivityIndicator(
          iOSVersionStyle: CupertinoActivityIndicatorIOSVersionStyle.iOS14,
          radius: 24.0,
        ),
        SizedBox(height: 18.0),
        Text('connecting'.tr(), style: TextStyle(fontSize: 14.0), textAlign: TextAlign.center),
      ],
    );
  }

  Widget get _networkError {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('연결 오류'),
      ],
    );
  }

  Widget _reporting() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 18.0),
        CupertinoActivityIndicator(
          iOSVersionStyle: CupertinoActivityIndicatorIOSVersionStyle.iOS14,
          radius: 24.0,
        ),
        SizedBox(height: 18.0),
        Text('speedtest.finishing'.tr(), style: TextStyle(fontSize: 14.0), textAlign: TextAlign.center),
        SizedBox(height: 18.0),
      ],
    );
  }

  Widget _simpleInfo() {
    const numberStyle = TextStyle(
      fontFamily: 'Gauge Mono',
      fontWeight: FontWeight.bold,
      fontSize: 28,
      height: 1.1,
    );

    return Consumer<TwitchStateModel>(
      builder: (context, state, child) {
        final latency = state.state == TwitchLoadingState.TestingPing ? (state.lastLatency ?? state.avgLatency).toString() : state.avgLatency?.toString() ?? '-';

        return Container(
          child: GridView.count(
            crossAxisCount: 3,
            padding: EdgeInsets.all(4.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('speedtest:title.latency'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(latency, style: numberStyle),
                  Text('ms', style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey2)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('speedtest:title.jitter'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(state.jitter?.toString() ?? '-', style: numberStyle),
                  Text('ms', style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey2)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('speedtest:title.stream'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(state.lastSpeedMbps.toStringAsFixed(2), style: numberStyle),
                  Text('Mbps', style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey2)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _gauge() {
    const numberStyle = TextStyle(
      fontFamily: 'Gauge Mono',
      fontSize: 33.0,
      fontWeight: FontWeight.bold,
      letterSpacing: -1,
    );

    return Consumer<TwitchStateModel>(
      builder: (context, state, child) {
        final double value = state.state == TwitchLoadingState.TestingSpeed ? min(state.lastSpeedMbps, 150.0) : 0.0;

        return Container(
            child: SfRadialGauge(
              enableLoadingAnimation: true,
              animationDuration: 3000,
              axes: <RadialAxis>[
                RadialAxis(
                  axisLineStyle: AxisLineStyle(
                    thickness: 25,
                    cornerStyle: CornerStyle.bothCurve,
                  ),
                  showTicks: true,
                  minimum: 0.0,
                  maximum: 150.0,
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(state.lastSpeedMbps.toStringAsFixed(2), style: numberStyle),
                            const Text('Mbps', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      angle: 90,
                      positionFactor: 0.75,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: value,
                      color: Colors.deepPurpleAccent.shade200,
                      width: 25.0,
                      animationType: AnimationType.ease,
                      animationDuration: 200,
                      enableAnimation: true,
                      cornerStyle: CornerStyle.bothCurve,
                      gradient: SweepGradient(
                        colors: <Color>[
                          Colors.deepPurpleAccent,
                          Colors.purpleAccent.shade700,
                        ],
                        stops: [0.2, 1],
                      ),
                    ),
                    NeedlePointer(
                      value: value,
                      animationDuration: 200,
                      animationType: AnimationType.ease,
                      enableAnimation: true,
                      needleStartWidth: 0,
                      needleEndWidth: 3,
                      needleColor: Colors.deepPurpleAccent.shade700,
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.deepPurpleAccent,
                          Colors.deepPurple,
                        ],
                      ),
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
            )
        );
      },
    );
  }

  Widget _standby() {
    return Consumer<TwitchStateModel>(
      builder: (context, state, child) {
        ButtonState buttonState = ButtonState.idle;

        switch (state.state) {
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
                  ProgressButton.icon(
                    maxWidth: 200.0,
                    height: 60.0,
                    radius: 18.0,
                    iconedButtons: {
                      ButtonState.idle:
                      IconedButton(
                        text: 'speedtest.start'.tr(),
                        icon: Icon(Icons.play_arrow, color: Colors.white),
                        color: Colors.deepPurple.shade500,
                      ),

                      ButtonState.loading:
                      IconedButton(
                        text: 'speedtest.loading'.tr(),
                        color: Colors.deepPurple.shade700,
                      ),

                      ButtonState.fail:
                      IconedButton(
                        text: 'speedtest.failed'.tr(),
                        color: Colors.deepPurple.shade700,
                        icon: Icon(Icons.cancel, color: Colors.white),
                      ),

                      ButtonState.success:
                      IconedButton(
                        text: 'speedtest.success'.tr(),
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        color: Colors.deepPurple.shade700,
                      ),
                    },
                    onPressed: state.start,
                    state: buttonState,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _common() {
    return Consumer2<AppStateModel, TwitchStateModel>(
      builder: (context, appState, state, child) {
        final hasIpInfo = appState.myIpInfo != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            Text('network'.tr(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            SizedBox(height: 2.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ...(hasIpInfo && appState.myIpInfo.countryFlag?.length > 0 ? [
                  SvgPicture.network('https://cdn.ipregistry.co/flags/twemoji/${appState.myIpInfo.countryCode.toLowerCase()}.svg', height: 18.0),
                  SizedBox(width: 6.0),
                ] : []),
                Text(appState.myIpInfo?.isp ?? appState.myIpInfo?.org ?? '-'),
              ],
            ),
            ...(
              hasIpInfo
                ? [
                  SizedBox(height: 3.0),
                  Text('${appState.myIpInfo.country}, ${appState.myIpInfo.region}', style: TextStyle(fontSize: 12.0, color: CupertinoColors.systemGrey)),
                ] : []
            ),

            SizedBox(height: 14.0),

            Text('mode'.tr(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            SizedBox(height: 2.0),
            CupertinoSlidingSegmentedControl(
              children: {
                TwitchTestType.Multi: Text('mode:multi').tr(),
                TwitchTestType.Single: Text('mode:single').tr(),
              },
              groupValue: state.testType,
              onValueChanged: (newValue) {
                state.setTestType(newValue);
              },
            ),
            SizedBox(height: 8.0),
            Text('mode:warning'.tr(), style: TextStyle(fontSize: 12.0, color: CupertinoColors.darkBackgroundGray)),

            SizedBox(height: 14.0),

            Text('testing-servers'.tr(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            SizedBox(height: 2.0),
            ...(
              state.twitchServers.length > 0
                ? state.twitchServers.map((twitchServer) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('${twitchServer.location} (${twitchServer.code})', style: TextStyle(fontSize: 12)),
                    ],
                  );
                }) : [Text('-')]
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateModel, TwitchStateModel>(
      builder: (context, appState, twitchState, child) {
        Widget child = Container();

        if (appState.isLoading) {
          child = _appLoading;
        } else if (appState.isUnavailable) {
          child = _networkError;
        } else {
          switch (twitchState.state) {
            case TwitchLoadingState.NoServers:
            case TwitchLoadingState.Error:
            case TwitchLoadingState.Preparing:
            case TwitchLoadingState.Standby:
              child = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _standby(),
                ],
              );
              break;

            case TwitchLoadingState.TestingPing:
//            default:
              break;

            case TwitchLoadingState.TestingSpeed:
            case TwitchLoadingState.TestingSpeedDone:
              child = Container(
                child: _gauge(),
              );
              break;

            case TwitchLoadingState.Reporting:
              child = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _reporting(),
                ],
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
                Center(child: Text('tab:speedtest.title').tr()),
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

          ),
          child: SafeArea(
            child: Scaffold(
              body: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Container(
                        child: _simpleInfo(),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: child,
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: _common(),
                    ),
                  ),
                ],
            ),
          )

//            child: Padding(
//              padding: const EdgeInsets.all(18.0),
//              child: Container(
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    child,
//                    SizedBox(height: 18.0),
//                    _common(),
//                  ],
//                ),
//              ),
//            ),
          ),
        );
      },
    );
  }
}
