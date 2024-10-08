import '../globals/myColors.dart';
import '../globals/myFonts.dart';
import '../globals/mySpaces.dart';
import '../globals/sizeConfig.dart';
import '../models/group.dart';
import '../models/task.dart';
import '../providers/tasks.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_range_picker/time_range_picker.dart';
import '../miscellaneous/functions.dart' as func;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditTask extends StatefulWidget {
  final Task task;
  const EditTask(this.task);
  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  late Task task;
  DateTime? _selectedDate;
  TimeOfDay? _startTime, _endTime;
  String? _taskName;
  Group? _value;
  bool _isToggle = false;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: (_selectedDate == null) ? task.date : _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null)
      setState(() {
        _selectedDate = pickedDate;
      });
  }

  void _selectTime() async {
    TimeRange result = await showTimeRangePicker(
      use24HourFormat: false,
      backgroundWidget: Image.asset(
        "assets/images/clock.png",
        height: 200,
        width: 200,
      ),
      strokeWidth: 4,
      ticks: 24,
      ticksOffset: -7,
      ticksLength: 15,
      ticksColor: Colors.grey,
      labels: ["12 am", "3 am", "6 am", "9 am", "12 pm", "3 pm", "6 pm", "9 pm"]
          .asMap()
          .entries
          .map((e) {
        return ClockLabel.fromIndex(idx: e.key, length: 8, text: e.value);
      }).toList(),
      context: context,
    );
    setState(() {
      _endTime = result.endTime;
      _startTime = result.startTime;
    });
  }

  @override
  void initState() {
    super.initState();
    task = widget.task;
    _isToggle = task.remind == "yes" ? true : false;
  }

  void saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      var newTask = Task(
          id: task.id,
          title: (_taskName == null) ? task.title : _taskName!,
          date: (_selectedDate == null) ? task.date : _selectedDate!,
          startTime: (_startTime == null) ? task.startTime : _startTime!,
          endTime: (_endTime == null) ? task.endTime : _endTime!,
          category: (_value == null) ? task.category : _value!,
          remind: _isToggle ? "yes" : "no");
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Tasks')
          .doc(task.id)
          .set(newTask.toMap());
      Provider.of<Tasks>(context, listen: false).updateTask(task, newTask);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Task updated successfully")));
    } catch (error) {
      func.showError(error.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final taskData = Provider.of<Tasks>(context, listen: false);
    return Material(
      child: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MySpaces.vGapInBetween,
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Atualizar tarefa',
                            style: MyFonts.bold
                                .size(SizeConfig.horizontalBlockSize * 8),
                          ),
                        ),
                        MySpaces.vLargeGapInBetween,
                        TextFormField(
                          initialValue: task.title,
                          cursorHeight: 28,
                          cursorColor: Colors.grey[400],
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 20.0,
                          ),
                          decoration: InputDecoration(
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            hintStyle: TextStyle(color: Colors.grey),
                            focusColor: Colors.grey[800],
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade900,
                              ),
                            ),
                            hintText: 'Nome da tarefa',
                          ),
                          onSaved: (value) {
                            _taskName = value ?? '-';
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "O nome da tarefa não pode estar vazio";
                            }
                            return null;
                          },
                        ),
                        MySpaces.vSmallGapInBetween,
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: _selectDate,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    border: Border.all(
                                      color: Colors.amber.shade100,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                                MySpaces.hMediumGapInBetween,
                                Text(
                                  DateFormat("EEEE dd, MMMM", "pt_BR").format(
                                      (_selectedDate == null)
                                          ? task.date
                                          : _selectedDate!),
                                  style: MyFonts.bold
                                      .size(SizeConfig.horizontalBlockSize * 5)
                                      .setColor(kGrey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        MySpaces.vGapInBetween,
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: _selectTime,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    border: Border.all(
                                      color: Colors.orange.shade100,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                                MySpaces.hMediumGapInBetween,
                                Text(
                                  (_startTime == null && _endTime == null)
                                      ? "${func.hours(task.startTime)} : ${func.minutes(task.startTime)} ${func.timeMode(task.startTime)} - ${func.hours(task.endTime)} : ${func.minutes(task.endTime)} ${func.timeMode(task.endTime)}"
                                      : "${func.hours(_startTime)} : ${func.minutes(_startTime)} ${func.timeMode(_startTime)} - ${func.hours(_endTime)} : ${func.minutes(_endTime)} ${func.timeMode(_endTime)}",
                                  style: MyFonts.bold
                                      .size(SizeConfig.horizontalBlockSize * 5)
                                      .setColor(kGrey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        MySpaces.vMediumGapInBetween,
                        Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    border: Border.all(
                                      color: Colors.purple.shade100,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Icon(
                                    Icons.category,
                                    color: Colors.purple.shade400,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 20,
                                  ),
                                  child: DropdownButton<Group>(
                                    hint: Text(
                                      task.category.title,
                                      style: MyFonts.medium.size(
                                          SizeConfig.horizontalBlockSize * 5),
                                    ),
                                    items:
                                        taskData.categories.map((Group item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item.title,
                                          style: MyFonts.medium.size(
                                              SizeConfig.horizontalBlockSize *
                                                  5),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _value = value!;
                                      });
                                    },
                                    value: _value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        MySpaces.vMediumGapInBetween,
                        Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        border: Border.all(
                                          color: Colors.blue.shade100,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Icon(
                                        Icons.notifications_none_outlined,
                                        color: Colors.blue.shade400,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Text(
                                        "Notificar",
                                        style: MyFonts.medium.size(18),
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isToggle = !_isToggle;
                                    });
                                  },
                                  icon: (_isToggle == true)
                                      ? Icon(
                                          Icons.toggle_on,
                                          color: Colors.blue,
                                        )
                                      : Icon(Icons.toggle_off),
                                  iconSize: 60,
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        MySpaces.vMediumGapInBetween,
                        Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: saveForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Atualizar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ]),
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
