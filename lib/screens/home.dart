import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../utils/cron_service.dart';
import '../models/task.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<TaskModel> tasks = [];

  @override
  void initState() {
    CronService.init().then((List<TaskModel>? list) {
      if (list != null) {
        setState(() {
          tasks = list;
          CronService.register(tasks, context: context);
        });
      }
    });

    super.initState();
  }

  handleActiveChange(TaskModel model) {
    model.active = !model.active;
    setState(() {
      tasks = [...tasks];
      CronService.replace(tasks, context: context);
    });
  }

  handleEdit(TaskModel model) {
    _showFormDialog(
      form: model,
      scenario: 'update',
      callback: (TaskModel newModel) {
        setState(() {
          tasks = [...tasks]
            ..remove(model)
            ..add(newModel);
          CronService.replace(tasks, context: context);
        });
      },
    );
  }

  handleDelete(TaskModel model) {
    setState(() {
      tasks = [...tasks]..remove(model);
      CronService.replace(tasks, context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('定时器列表'),
        actions: [
          IconButton(
            onPressed: () {
              _showHelpDialog();
            },
            icon: Icon(Icons.help),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFormDialog(
            form: TaskModel.fromJson({
              'id': UniqueKey().toString(),
              'name': '',
              'schedule': '55 8,17 * * 1-5',
              'active': true,
            }),
            callback: (TaskModel model) {
              setState(() {
                tasks = [...tasks]..add(model);
                CronService.replace(tasks, context: context);
              });
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: tasks.length,
          itemBuilder: (context, index) => Slidable(
            key: Key(tasks[index].id),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            child: Container(
              color: Colors.white,
              child: ListTile(
                tileColor: theme.cardColor,
                leading: CircleAvatar(
                  foregroundColor: Colors.white,
                  backgroundColor: tasks[index].active
                      ? Colors.green.shade800
                      : Colors.grey.shade700,
                  child: tasks[index].active
                      ? Icon(Icons.check)
                      : Icon(Icons.close),
                ),
                title: Text(
                  tasks[index].name,
                  style: TextStyle(color: theme.textTheme.subtitle1!.color),
                ),
                subtitle: Text(
                  tasks[index].schedule,
                  style: TextStyle(color: theme.textTheme.headline1!.color),
                ),
              ),
            ),
            actions: [
              IconSlideAction(
                caption: tasks[index].active ? '禁用' : '启用',
                color: tasks[index].active
                    ? Colors.grey.shade700
                    : Colors.green.shade800,
                foregroundColor: Colors.white,
                icon: tasks[index].active ? Icons.close : Icons.check,
                onTap: () => handleActiveChange(tasks[index]),
              ),
            ],
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '编辑',
                color: Colors.blue.shade800,
                icon: Icons.edit,
                onTap: () => handleEdit(tasks[index]),
              ),
              IconSlideAction(
                caption: '删除',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => handleDelete(tasks[index]),
              ),
            ],
          ),
          separatorBuilder: (context, index) => Divider(),
        ),
      ),
    );
  }

  _showFormDialog({
    required TaskModel form,
    required Function(TaskModel) callback,
    String scenario = 'create',
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            final _formKey = GlobalKey<FormState>();
            final _nameController = TextEditingController.fromValue(
                TextEditingValue(text: form.name));
            final _scheduleController = TextEditingController.fromValue(
                TextEditingValue(text: form.schedule));
            return AlertDialog(
              title: Text(scenario == 'create' ? '添加' : '编辑'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.name,
                        controller: _nameController,
                        autofocus: true,
                        validator: (value) {
                          return value == null || value.isNotEmpty
                              ? null
                              : '名称不能为空';
                        },
                        decoration: InputDecoration(
                          labelText: '名称',
                          helperText: '用于区分\n例如：工作日打卡、加班打卡',
                        ),
                      ),
                      TextFormField(
                        controller: _scheduleController,
                        validator: (value) {
                          return value == null || value.isNotEmpty
                              ? null
                              : '调度不能为空';
                        },
                        decoration: InputDecoration(
                          labelText: '调度',
                          helperText:
                              '例如：55 8,17 * * 1-5\n表示：工作日早8:55和晚17:55打卡 \nminute (0 - 59)\nhour (0 - 23)\nday of the month (1 - 31)\nmonth (1 - 12)\nday of the week (0 - 6)',
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        callback(TaskModel.fromJson({
                          'id': form.id,
                          'name': _nameController.text,
                          'schedule': _scheduleController.text,
                          'active': form.active,
                        }));
                        Navigator.pop(context);
                      }
                    },
                    child: Text('保存'))
              ],
            );
          },
        );
      },
    );
  }

  _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('使用前必读！！！'),
          content: Container(
              child: Text(
            '''
【工作原理】
  1. 保持屏幕常亮
  2. 定时启动钉钉

【条件】
  1. 一个闲置安卓手机，确保时间正确
  2. 让手机保持最低消耗状态（移除锁屏、关闭声音、卸载无关的软件、屏幕亮度最低、深色模式）
  3. 设置钉钉【极速打卡】，确保打开钉钉能够【立即打卡】
  4. 安装本应用，新增定时器，并保持本应用【始终显示】在主屏幕
  5. 把手机藏在公司某个角落，记住不要锁在金属柜子里
''',
          )),
        );
      },
    );
  }
}
