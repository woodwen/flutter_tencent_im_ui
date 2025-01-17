import 'package:flutter/material.dart';
import 'package:flutter_tencent_im_ui/common/avatar.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/pages/conversion/conversion.dart';
import 'package:flutter_tencent_im_ui_test/conversationInfo/conversationInfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Groups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GroupsState();
}

class GroupItem extends StatelessWidget {
  GroupItem(this.groupInfo);
  final V2TimGroupInfo groupInfo;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => Conversion(
                'group_${groupInfo.groupID}',
                AppBar(
                  title: Text("${groupInfo.groupID}"),
                  backgroundColor: CommonColors.getThemeColor(),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.account_box,
                        color: CommonColors.getWitheColor(),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (context) =>
                                ConversationInfo(groupInfo.groupID, 2),
                          ),
                        );
                      },
                    )
                  ],
                ),
                (_, message) {},
                (_) {}),
          ),
        );
      },
      child: Container(
        height: 50,
        child: Row(
          children: [
            Container(
              child: Avatar(
                avtarUrl: groupInfo.faceUrl == '' || groupInfo.faceUrl == null
                    ? 'images/logo.png'
                    : groupInfo.faceUrl,
                width: 30,
                height: 30,
                radius: 0,
              ),
              padding: EdgeInsets.only(
                right: 10,
              ),
            ),
            Expanded(
              child: Container(
                child: Text(groupInfo.groupName!),
              ),
            )
          ],
        ),
        margin: EdgeInsets.only(top: 10),
        color: CommonColors.getWitheColor(),
        padding: EdgeInsets.all(10),
      ),
    );
  }
}

class GroupsState extends State<Groups> {
  GroupsState() {
    getJoinedGroupList();
  }
  List<V2TimGroupInfo> groupList = List.empty(growable: true);
  getJoinedGroupList() async {
    V2TimValueCallback<List<V2TimGroupInfo>> data = await TencentImSDKPlugin
        .v2TIMManager
        .getGroupManager()
        .getJoinedGroupList();
    if (data.code == 0) {
      List<V2TimGroupInfo>? list = data.data;
      if (list != null && list.length > 0) {
        setState(() {
          groupList = list;
        });
      }
    }
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('群聊'),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: CommonColors.getGapColor(),
                child: groupList.length > 0
                    ? ListView(
                        children: groupList.map((e) => GroupItem(e)).toList(),
                      )
                    : Center(
                        child: Text(
                          "暂未加入群组",
                          style: TextStyle(
                            color: CommonColors.getTextWeakColor(),
                          ),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
