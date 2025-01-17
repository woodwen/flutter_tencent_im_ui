import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tencent_im_ui/common/colors.dart';
import 'package:flutter_tencent_im_ui/provider/currentMessageList.dart';
import 'package:flutter_tencent_im_ui/utils/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class AdvanceMsg extends StatefulWidget {
  AdvanceMsg(Key key, this.toUser, this.type, this.sendText,
      this.sendTextMsgSuc, this.moreBtnClick)
      : super(key: key);
  final String? sendText;
  final String toUser;
  final int type;
  final VoidCallback sendTextMsgSuc;
  final VoidCallback moreBtnClick;

  @override
  AdvanceMsgState createState() => AdvanceMsgState();
}

class AdvanceMsgState extends State<AdvanceMsg> {
  final picker = ImagePicker();
  String? sendText;
  @override
  void initState() {
    sendText = widget.sendText;
    super.initState();
  }

  void updateSendButtonStatus(String? text) {
    setState(() {
      sendText = text;
    });
  }

  sendTextMsg(context) async {
    if (sendText == '' || sendText == null) {
      return;
    }
    V2TimValueCallback<V2TimMessage> sendRes;
    if (widget.type == 1) {
      sendRes = await TencentImSDKPlugin.v2TIMManager
          .sendC2CTextMessage(text: sendText!, userID: widget.toUser);
    } else {
      sendRes = await TencentImSDKPlugin.v2TIMManager.sendGroupTextMessage(
          text: sendText!, groupID: widget.toUser, priority: 1);
    }

    if (sendRes.code == 0) {
      String key = (widget.type == 1
          ? "c2c_${widget.toUser}"
          : "group_${widget.toUser}");
      List<V2TimMessage> list = List.empty(growable: true);
      list.add(sendRes.data!);
      Provider.of<CurrentMessageListModel>(context, listen: false)
          .addMessage(key, list);
      widget.sendTextMsgSuc();
      updateSendButtonStatus(null);
    } else {
      Utils.toast("发送失败 ${sendRes.code} ${sendRes.desc}");
    }
  }

  Widget build(BuildContext context) {
    return sendText == null || sendText == ''
        ? Container(
            width: 44,
            height: 44,
            child: IconButton(
              icon: Icon(
                Icons.add,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () async {
                widget.moreBtnClick();
              },
            ))
        : Container(
            padding: EdgeInsets.only(right: 12),
            width: 60,
            height: 30,
            child: CupertinoButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: () {
                  sendTextMsg(context);
                },
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                color: CommonColors.getGreenColor(),
                child: Text('发送',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold))),
          );
  }
}
