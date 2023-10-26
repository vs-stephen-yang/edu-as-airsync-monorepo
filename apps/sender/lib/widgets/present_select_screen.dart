import 'dart:async';

import 'package:display_cast_flutter/generated/l10n.dart';
import 'package:display_cast_flutter/providers/present_state_provider.dart';
import 'package:display_cast_flutter/utilities/connect_timer.dart';
import 'package:display_cast_flutter/utilities/debug_mode_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';

class PresentSelectScreen extends StatelessWidget {
  const PresentSelectScreen({super.key});

  static SelectScreenDialog? selectScreenDialog;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PresentStateProvider provider =
          Provider.of<PresentStateProvider>(context, listen: false);
      // start timeout timer (30 sec)
      ConnectionTimer.getInstance().startConnectionTimeoutTimer(() {
        // onFinish
        if (context.mounted) {
          selectScreenDialog?.cancel();
        }
      });
      await showDialog<CustomDesktopCapturerSource>(
        context: context,
        builder: (context) => selectScreenDialog = SelectScreenDialog(),
      ).then((value) {
        debugModePrint('selectedSource: $value');
        ConnectionTimer.getInstance().stopConnectionTimeoutTimer();
        if (value != null && value.selectedSource != null) {
          if (WebRTC.platformIsWindows && value.selectedSource?.type != SourceType.Window) {
            provider.presentStart(selectedSource: value.selectedSource, systemAudio: value.systemAudio);
          } else {
            provider.presentStart(selectedSource: value.selectedSource);
          }
        } else {
          SelectScreenDialog._timer?.cancel();
          for (var element in selectScreenDialog!._subscriptions) {
            element.cancel();
          }
          // moderator mode
          if (provider.moderator != null) {
            provider.presentStop();
          } else {
            provider.presentStop();
            provider.presentEnd();
          }
        }
      });
    });
    return const SizedBox();
  }
}

class SelectScreenDialog extends Dialog {
  SelectScreenDialog({super.key}) {
    Future.delayed(const Duration(milliseconds: 100), () {
      _getSources(SourceType.Screen);
    });

    _subscriptions.add(desktopCapturer.onAdded.stream.listen((source) {
      _sources[source.id] = source;
      _stateSetter?.call(() {});
    }));

    _subscriptions.add(desktopCapturer.onRemoved.stream.listen((source) {
      _sources.remove(source.id);
      _stateSetter?.call(() {});
    }));

    _subscriptions
        .add(desktopCapturer.onThumbnailChanged.stream.listen((source) {
      _stateSetter?.call(() {});
    }));
  }

  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  final Map<String, DesktopCapturerSource> _sources = {};
  static DesktopCapturerSource? _selectedSource;
  static StateSetter? _stateSetter;
  static Timer? _timer;
  late BuildContext ctx;
  bool _systemAudio = false;

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 640,
          height: 560,
          color: const Color.fromARGB(255, 63, 63, 63),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        S.of(context).present_select_screen_description,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        child: const Icon(Icons.close, color: Colors.white),
                        onTap: () => cancel(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      _stateSetter = setState;
                      return DefaultTabController(
                        length: 2,
                        child: Builder(
                          builder: (context) {
                            TabController tabController = DefaultTabController.of(context);
                            return Column(
                              children: <Widget>[
                                Container(
                                  constraints:
                                      const BoxConstraints.expand(height: 24),
                                  child: TabBar(
                                      onTap: (value) {
                                        Future.delayed(
                                            const Duration(milliseconds: 300), () {
                                          _getSources(value == 0
                                              ? SourceType.Screen
                                              : SourceType.Window);
                                        });
                                      },
                                      tabs: [
                                        Tab(
                                            child: Text(
                                          S.of(context).present_select_screen_entire,
                                          style: const TextStyle(color: Colors.white60),
                                        )),
                                        Tab(
                                            child: Text(
                                              S.of(context).present_select_screen_window,
                                          style: const TextStyle(color: Colors.white60),
                                        )),
                                      ]),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Expanded(
                                  child: TabBarView(children: [
                                    Align(
                                        alignment: Alignment.center,
                                        child: GridView.count(
                                          crossAxisSpacing: 8,
                                          crossAxisCount: 2,
                                          children: _sources.entries
                                              .where((element) =>
                                                  element.value.type ==
                                                  SourceType.Screen)
                                              .map((e) => ThumbnailWidget(
                                                    onTap: (source) {
                                                      setState(() {
                                                        _selectedSource = source;
                                                      });
                                                    },
                                                    source: e.value,
                                                    selected: _selectedSource?.id ==
                                                        e.value.id,
                                                  ))
                                              .toList(),
                                        )),
                                    Align(
                                        alignment: Alignment.center,
                                        child: GridView.count(
                                          crossAxisSpacing: 8,
                                          crossAxisCount: 3,
                                          children: _sources.entries
                                              .where((element) =>
                                                  element.value.type ==
                                                  SourceType.Window)
                                              .map((e) => ThumbnailWidget(
                                                    onTap: (source) {
                                                      setState(() {
                                                        _selectedSource = source;
                                                      });
                                                    },
                                                    source: e.value,
                                                    selected: _selectedSource?.id ==
                                                        e.value.id,
                                                  ))
                                              .toList(),
                                        )),
                                  ]),
                                ),
                                if (WebRTC.platformIsWindows && tabController.index == SourceType.Screen.index)
                                  Row(
                                  children: [
                                    Checkbox(
                                        value: _systemAudio,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _systemAudio = value!;
                                          });
                                        }),
                                    Text(S.of(context).present_select_screen_share_audio,
                                        style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                            ],
                          );
                          }
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ButtonBar(
                  children: <Widget>[
                    MaterialButton(
                      child: Text(
                        S.of(context).present_select_screen_cancel,
                        style: const TextStyle(color: Color.fromARGB(255, 41, 121, 255),),
                      ),
                      onPressed: () {
                        cancel();
                      },
                    ),
                    MaterialButton(
                      color: const Color.fromARGB(255, 41, 121, 255),
                      child: Text(
                        S.of(context).present_select_screen_share,
                      ),
                      onPressed: () {
                        _ok(_selectedSource, _systemAudio);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void cancel() async {
    _timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    Navigator.pop<CustomDesktopCapturerSource>(ctx, null);
  }

  void _ok(DesktopCapturerSource? selectedSource, bool systemAudio) async {
    _timer?.cancel();
    for (var element in _subscriptions) {
      element.cancel();
    }
    Navigator.pop<CustomDesktopCapturerSource>(ctx, CustomDesktopCapturerSource(selectedSource, systemAudio));
  }

  Future<void> _getSources(SourceType sourceType) async {
    try {
      var sources = await desktopCapturer.getSources(types: [sourceType]);
      for (var element in sources) {
        debugModePrint(
            'name: ${element.name}, id: ${element.id}, type: ${element.type}');
      }
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        desktopCapturer.updateSources(types: [sourceType]);
      });
      _sources.clear();
      for (var element in sources) {
        _sources[element.id] = element;
      }
      _stateSetter?.call(() {});
      return;
    } catch (e) {
      debugModePrint(e.toString());
    }
  }
}

class CustomDesktopCapturerSource {
  DesktopCapturerSource? selectedSource;
  bool systemAudio = false;

  CustomDesktopCapturerSource(this.selectedSource, this.systemAudio);
}

class ThumbnailWidget extends StatefulWidget {
  const ThumbnailWidget(
      {Key? key,
      required this.source,
      required this.selected,
      required this.onTap})
      : super(key: key);
  final DesktopCapturerSource source;
  final bool selected;
  final Function(DesktopCapturerSource) onTap;

  @override
  State createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _subscriptions.add(widget.source.onThumbnailChanged.stream.listen((event) {
      setState(() {});
    }));
    _subscriptions.add(widget.source.onNameChanged.stream.listen((event) {
      setState(() {});
    }));
  }

  @override
  void deactivate() {
    for (var element in _subscriptions) {
      element.cancel();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Container(
          decoration: widget.selected
              ? BoxDecoration(
                  border: Border.all(width: 2, color: Colors.blueAccent))
              : null,
          child: InkWell(
            onTap: () {
              debugModePrint('Selected source id => ${widget.source.id}');
              widget.onTap(widget.source);
            },
            child: widget.source.thumbnail != null
                ? Image.memory(
                    widget.source.thumbnail!,
                    gaplessPlayback: true,
                    alignment: Alignment.center,
                  )
                : Container(),
          ),
        )),
        Text(
          widget.source.name,
          style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight:
                  widget.selected ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
