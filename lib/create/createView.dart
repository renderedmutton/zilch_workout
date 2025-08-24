import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart' as RL;
import 'package:zilch_workout/auth/formSubmissionStatus.dart';
import 'package:zilch_workout/create/createStatus.dart';
import 'package:zilch_workout/create/createBloc.dart';
import 'package:zilch_workout/create/createEvent.dart';
import 'package:zilch_workout/create/createState.dart';
import 'package:zilch_workout/create/graphPainter.dart';
import 'package:zilch_workout/create/segmentData.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/session/sessionCubit.dart';

class CreateView extends StatefulWidget {
  @override
  _CreateViewState createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  void _showConfirmDeleteDialog(
      BuildContext context, CreateBloc createBloc, String workoutId) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: createBloc,
          child:
              BlocBuilder<CreateBloc, CreateState>(builder: (context, state) {
            return SimpleDialog(
              title: Text('Confirm Delete', textAlign: TextAlign.center),
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () {
                            context
                                .read<CreateBloc>()
                                .add(DeleteWorkout(workoutId));
                            Navigator.of(context).pop();
                          },
                          child: Text('DELETE'))
                    ])
              ],
            );
          }),
        );
      },
    );
  }

  void _showLoadDialog(BuildContext context, CreateBloc createBloc) {
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: BlocProvider.value(
              value: createBloc,
              child: BlocBuilder<CreateBloc, CreateState>(
                  builder: (context, state) {
                return AlertDialog(
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 96.0),
                  title: Text('Load Workouts'),
                  content: state.workouts.isEmpty
                      ? Center(child: Text('No Workouts Found'))
                      : Container(
                          width: MediaQuery.of(context).size.width - 12,
                          child: ListView.builder(
                              itemCount: state.workouts.length,
                              itemBuilder: (context, index) {
                                return Row(children: [
                                  Expanded(
                                      child: Text(state.workouts[index].name!)),
                                  IconButton(
                                      onPressed: () => _showConfirmDeleteDialog(
                                          context,
                                          createBloc,
                                          state.workouts[index].id),
                                      icon: Icon(Icons.delete,
                                          color: Colors.red)),
                                  SizedBox(width: 16.0),
                                  ElevatedButton(
                                      onPressed: () {
                                        context.read<CreateBloc>().add(
                                            LoadWorkout(
                                                state.workouts[index].id));
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Load')),
                                ]);
                              }),
                        ),
                );
              }),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (ctx, animation1, animation2) {
        return widget;
      },
    );
  }

  void _saveWorkoutDialog(BuildContext context, CreateBloc createBloc) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: createBloc,
          child:
              BlocConsumer<CreateBloc, CreateState>(builder: (context, state) {
            if (state.createStatus is CreationFailure) {
              return SimpleDialog(
                  title: Text('Overwrite existing file?',
                      textAlign: TextAlign.center),
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel')),
                          ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(primary: Colors.red),
                              onPressed: () {
                                context.read<CreateBloc>().add(UpdateWorkout());
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'))
                        ])
                  ]);
            }
            return SimpleDialog(
              title: Text('Saving', textAlign: TextAlign.center),
              children: [CupertinoActivityIndicator()],
            );
          }, listener: (context, state) {
            if (state.createStatus is CreationSuccess)
              Navigator.of(context).pop();
          }),
        );
      },
    );
  }

  void _showNameDialog(CreateBloc createBloc, bool forSave, String oldName) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: createBloc,
          child:
              BlocBuilder<CreateBloc, CreateState>(builder: (context, state) {
            final _formKey = GlobalKey<FormState>();
            TextEditingController nameController =
                TextEditingController(text: state.name);
            nameController.selection = TextSelection.fromPosition(
                TextPosition(offset: nameController.text.length));
            return SimpleDialog(
              title: Text(forSave ? 'Save Workout?' : 'Rename Workout',
                  textAlign: TextAlign.center),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: nameController,
                          //autofocus: true,
                          autocorrect: false,
                          //initialValue: state.name,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(errorMaxLines: 2),
                          validator: (value) => state.isValidName
                              ? null
                              : 'Only a-z,A-Z,0-9, _-=@,.',
                          onFieldSubmitted: (value) => context
                              .read<CreateBloc>()
                              .add(WorkoutNameChanged(value)),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            context
                                .read<CreateBloc>()
                                .add(WorkoutNameChanged(oldName));
                            Navigator.of(context).pop();
                          },
                        ),
                        if (forSave)
                          ElevatedButton(
                            child: Text('Save'),
                            onPressed: () {
                              if (state.segmentWidgets.length > 0) {
                                if (_formKey.currentState!.validate()) {
                                  context.read<CreateBloc>().add(
                                      WorkoutNameChanged(nameController.text));
                                  context
                                      .read<CreateBloc>()
                                      .add(CreateWorkout());
                                  _saveWorkoutDialog(context,
                                      BlocProvider.of<CreateBloc>(context));
                                }
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          )
                        else
                          ElevatedButton(
                            child: Text('OK'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<CreateBloc>().add(
                                    WorkoutNameChanged(nameController.text));
                                Navigator.of(context).pop();
                              }
                            },
                          )
                      ],
                    )
                  ],
                )
              ],
            );
          }),
        );
      },
    );
  }

  Widget _loaderWidgets(
      BuildContext context, CreateState state, double unitHeightValue) {
    return BlocListener<CreateBloc, CreateState>(
      listener: (context, state) {
        final formStatus = state.formStatus;
        if (formStatus is SubmissionFailure) {
          _showSnackBar(context, formStatus.exception.toString());
        }
      },
      child: Row(children: [
        IconButton(
          icon: Icon(Icons.folder_open),
          tooltip: 'load file',
          onPressed: () {
            context.read<CreateBloc>().add(GetWorkouts());
            _showLoadDialog(context, BlocProvider.of<CreateBloc>(context));
          },
          iconSize: unitHeightValue * 5,
          highlightColor: Colors.white24,
        ),
        IconButton(
          icon: Icon(Icons.save),
          tooltip: 'save file',
          onPressed: () {
            context.read<CreateBloc>().add(GetWorkouts());
            _showNameDialog(
                BlocProvider.of<CreateBloc>(context), true, state.name);
          },
          iconSize: unitHeightValue * 5,
          highlightColor: Colors.white24,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _showNameDialog(
                BlocProvider.of<CreateBloc>(context), false, state.name),
            child: Text(state.name,
                style: TextStyle(fontSize: unitHeightValue * 2.5),
                textAlign: TextAlign.center),
          ),
        ),
      ]),
    );
  }

  void _graphSelectItem(BuildContext context, Key? key) {
    if (key == null) {
      context.read<CreateBloc>().add(ItemClearSelection());
    } else {
      context.read<CreateBloc>().add(ItemSelected(key));
    }
  }

  Widget _paintedWidget(BuildContext context, CreateState state) {
    List<int> zones = [
      (state.user.zone1 * state.user.ftp * 0.01).round(),
      (state.user.zone2 * state.user.ftp * 0.01).round(),
      (state.user.zone3 * state.user.ftp * 0.01).round(),
      (state.user.zone4 * state.user.ftp * 0.01).round(),
      (state.user.zone5 * state.user.ftp * 0.01).round()
    ];
    List<SegmentData> segments =
        state.segmentWidgets.map((e) => e.data).toList();
    return GestureDetector(
      onTapDown: (details) {
        //print('${details.localPosition.dx},${details.localPosition.dy}');
        context.read<CreateBloc>().add(TouchXYChanged(details.localPosition));
      },
      onTapUp: (details) =>
          context.read<CreateBloc>().add(TouchXYChanged(null)),
      child: CustomPaint(
        painter: GraphPainter(segments, state.selectedSegments, zones,
            state.touchXY, (Key? key) => _graphSelectItem(context, key)),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.75),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    int index = message.lastIndexOf('Exception: ');
    message = index == -1 ? message : message.substring(index + 11);
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Size mediaSize = MediaQuery.of(context).size;
    double unitHeightValue = MediaQuery.of(context).size.longestSide * 0.01;

    return BlocProvider(
      create: (context) => CreateBloc(
          user: context.read<SessionCubit>().currentUser,
          dataRepo: context.read<DataRepository>()),
      child: BlocBuilder<CreateBloc, CreateState>(builder: (context, state) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: CustomScrollView(slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: false,
                backgroundColor: Colors.grey[50],
                shape: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                title: Text('Create', style: TextStyle(color: Colors.black)),
                centerTitle: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  // load save and title header
                  _loaderWidgets(context, state, unitHeightValue),
                  Divider(),
                  //painter
                  Container(
                    color: Colors.grey.shade100,
                    width: mediaSize.width,
                    height: MediaQuery.of(context).size.shortestSide * 0.75,
                    child: _paintedWidget(context, state),
                  ),
                ]),
              ),
              //graph buttons header
              SliverPersistentHeader(
                pinned: true,
                floating: true,
                delegate: CreateSliverPersistentHeaderDelegate(),
              ),
              //reorderable segments
              SliverList(
                delegate: SliverChildListDelegate([
                  RL.ReorderableList(
                    child: Column(children: state.segmentWidgets),
                    onReorder: (Key item, Key newPos) {
                      context
                          .read<CreateBloc>()
                          .add(ReorderSegment(item, newPos));
                      return true;
                    },
                    onReorderDone: (Key item) {},
                  ),
                ]),
              ),
            ]),
          ),
        );
      }),
    );
  }
}

class CreateSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return BlocBuilder<CreateBloc, CreateState>(builder: (context, state) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        color: Colors.grey.shade50,
        child: Column(
          children: [
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.read<CreateBloc>().add(CurrentTypeChanged()),
                  child: Text(state.currentType == 1 ? 'ERG' : 'SLOPE',
                      style: TextStyle(fontSize: 14.0)),
                ),
                ElevatedButton(
                    onPressed: () =>
                        context.read<CreateBloc>().add(AddSegment()),
                    child: Icon(Icons.add)),
                ElevatedButton(
                    onPressed: () =>
                        context.read<CreateBloc>().add(CopySegment()),
                    child: Icon(Icons.copy)),
                ElevatedButton(
                    onPressed: () =>
                        context.read<CreateBloc>().add(RemoveSegment()),
                    child: Icon(Icons.remove)),
              ],
            ),
            Divider(),
          ],
        ),
      );
    });
  }

  @override
  double get maxExtent => kToolbarHeight + 24;

  @override
  double get minExtent => kToolbarHeight + 24;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
