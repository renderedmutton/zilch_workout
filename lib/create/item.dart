import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/create/createBloc.dart';
import 'package:zilch_workout/create/createEvent.dart';
import 'package:zilch_workout/create/createState.dart';
import 'package:zilch_workout/create/segmentData.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart' as RL;
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:zilch_workout/appConstants.dart';

class Item extends StatefulWidget {
  final SegmentData data;
  final bool isFirst;
  final bool isLast;
  final bool selected;
  //final List<SegmentData> datas;
  //final int repeated;
  Item(
      {required this.data,
      required this.isFirst,
      required this.isLast,
      required this.selected});

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  Widget _buildChild(BuildContext context, RL.ReorderableItemState state) {
    SegmentData data = widget.data;
    //bool isFirst = widget.isFirst;
    //bool isLast = widget.isLast;

    BoxDecoration decoration;
    TextEditingController powerController =
        TextEditingController(text: data.power.toString());
    TextEditingController slopeController =
        TextEditingController(text: data.slope.toStringAsFixed(1));
    FocusNode f1 = FocusNode();
    FocusNode f2 = FocusNode();
    int dur = data.duration;

    if (state == RL.ReorderableItemState.dragProxy ||
        state == RL.ReorderableItemState.dragProxyFinished) {
      // slightly transparent background white dragging (just like on iOS)
      decoration = BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == RL.ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: !placeholder //isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: placeholder //isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.white);
    }

    Widget dragHandle = RL.ReorderableListener(
      child: Container(
        padding:
            EdgeInsets.only(right: 8.0, left: 8.0, top: 45.0, bottom: 45.0),
        color: Color(0x08000000),
        child: Center(
          child: Icon(Icons.reorder, color: Color(0xFF888888)),
        ),
      ),
    );

    void _showBottomModalSheet(CreateBloc createBloc) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return BlocProvider.value(
                value: createBloc,
                child: BlocBuilder<CreateBloc, CreateState>(
                    builder: (context, state) {
                  return Container(
                    height: MediaQuery.of(context).copyWith().size.height / 3,
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red),
                                )),
                            TextButton(
                                onPressed: () {
                                  context.read<CreateBloc>().add(ItemChanged(
                                      key: data.key, duration: dur));
                                  Navigator.of(context).pop();
                                },
                                child: Text('Submit')),
                          ]),
                      CupertinoTimerPicker(
                          initialTimerDuration:
                              Duration(seconds: data.duration),
                          onTimerDurationChanged: (value) {
                            dur = value.inSeconds;
                            dur = dur >= 10 ? dur : 10;
                          }),
                    ]),
                  );
                }));
          });
    }

    void _savePower(BuildContext context) {
      int p = int.tryParse(powerController.text) ?? data.power;
      p = p > 2000 ? 2000 : p;
      powerController.text = p.toString();
      context.read<CreateBloc>().add(ItemChanged(key: data.key, power: p));
    }

    void _saveSlope(BuildContext context) {
      double grad =
          (num.tryParse(slopeController.text) ?? data.slope).toDouble();
      double mod = pow(10.0, 1).toDouble();
      grad = ((grad * mod).roundToDouble() / mod);
      grad = grad > 25.0 ? 25.0 : grad;
      grad = grad < -25.0 ? -25.0 : grad;
      int buffer = (grad * 10).round();
      grad = buffer / 10;
      slopeController.text = grad.toStringAsFixed(1);
      context.read<CreateBloc>().add(ItemChanged(key: data.key, slope: grad));
    }

    Widget content =
        BlocBuilder<CreateBloc, CreateState>(builder: (context, createState) {
      return Container(
        decoration: decoration,
        child: Opacity(
          opacity: state == RL.ReorderableItemState.placeholder ? 0.0 : 1.0,
          child: Row(children: [
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      width: widget.selected ? 3.0 : 1.0,
                      color:
                          widget.selected ? Colors.blue : Colors.grey.shade50)),
              height: data.type == 1 ? 135 : 205,
              padding: EdgeInsets.all(8.0),
              child: KeyboardActions(
                config: KeyboardActionsConfig(
                    nextFocus: false,
                    keyboardBarColor: Colors.grey,
                    actions: [
                      KeyboardActionsItem(
                          focusNode: f1,
                          onTapAction: () {
                            _savePower(context);
                          }),
                      KeyboardActionsItem(
                          focusNode: f2,
                          onTapAction: () {
                            _saveSlope(context);
                          })
                    ]),
                child: Column(children: [
                  GestureDetector(
                    onTap: () =>
                        context.read<CreateBloc>().add(ItemSelected(data.key)),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 20.0,
                      color: Colors.white,
                      child: Row(children: [
                        Icon(data.type == 1
                            ? Icons.flash_on
                            : Icons.terrain_rounded),
                        Text(data.type == 1 ? 'ERG' : 'Slope')
                      ]),
                    ),
                  ),
                  Container(
                    height: 60.0,
                    child: TextField(
                      controller: powerController,
                      keyboardType: TextInputType.number,
                      focusNode: f1,
                      scrollPadding: EdgeInsets.all(65.0),
                      decoration: InputDecoration(
                          labelText: data.type == 1 ? 'Power' : 'Target Power'),
                    ),
                  ),
                  if (data.type == 2)
                    TextField(
                      controller: slopeController,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      autocorrect: false,
                      focusNode: f2,
                      scrollPadding: EdgeInsets.all(65.0),
                      decoration: InputDecoration(labelText: 'Slope'),
                      onSubmitted: (value) => _saveSlope(context),
                    ),
                  SizedBox(height: 10.0),
                  Container(
                    alignment: Alignment.centerLeft,
                    height: 25.0,
                    child: GestureDetector(
                      onTap: () => _showBottomModalSheet(
                          BlocProvider.of<CreateBloc>(context)),
                      child: Text(
                        'Duration: ' +
                            AppConstants().getTimeFormat(data.duration),
                      ),
                    ),
                  ),
                ]),
              ),
            )),
            dragHandle,
          ]),
        ),
      );
    });

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return RL.ReorderableItem(
        key: widget.data.key, //
        childBuilder: _buildChild);
  }
}
