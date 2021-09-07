import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xenome/firebase_services/buildder_manager.dart';
import 'package:xenome/models/chartCirclePosition.dart';
import 'package:xenome/models/circleposition.dart';
import 'package:xenome/utils/session_manager.dart';
import 'package:xenome/utils/string_helper.dart';

class ScaleMoveableCircle extends StatefulWidget {
  ScaleMoveableCircle(this.getScaleHeatmap,this.id, this.type);
  final String id;
  final String type;
  
  Function  getScaleHeatmap;

  
  @override
  State<StatefulWidget> createState() {
    return _ScaleMoveableCircleState();
  }
}

class _ScaleMoveableCircleState extends State<ScaleMoveableCircle> {
  double xPosition = 163.2837611607143;
  double yPosition = 267.54464285714283;
  double borderWidth;
  int scaleColor = 4278190080;

  @override
  void initState() {
    super.initState();
    getPositionList();
    getScaleColor();
    borderWidth = 2.0;
  }

  getPositionList() async {
    CirclePosition _position = await BuildderManager.getScalePosition(SessionManager.getUserId(), widget.id, widget.type);
    setState(() {
      xPosition = _position.x;
      yPosition = _position.y;
    });
  }

  getScaleColor() async {
    int _scaleColor = await BuildderManager.getScaleColor(SessionManager.getUserId(), widget.id, widget.type);
    setState(() {
      scaleColor = _scaleColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yPosition,
      left: xPosition,
      child: GestureDetector(
        onPanUpdate: (tapInfo) {
          setState(() {
            borderWidth = 8.0;
            xPosition += tapInfo.delta.dx;
            yPosition += tapInfo.delta.dy;
            if(yPosition > 515.1339285714287){
              yPosition = 515.1339285714287;
            }
            if(yPosition < 22.566964285714334){
              yPosition = 22.566964285714334;
            }
            if(xPosition < 11.647321428571473){
              xPosition = 11.647321428571473;
            }
            if(xPosition > 315.63588169642867){
              xPosition = 315.63588169642867;
            }
          });
        },
        onPanEnd: (tapInfo) {
          setState(() {
            borderWidth = 2.0;
          });
          
          ChartCirclePosition chartPosition = ChartCirclePosition(x: xPosition, y: yPosition, uid:SessionManager.getUserId(), minOpacity: 5);
          CirclePosition position = CirclePosition(x: xPosition, y: yPosition, uid:SessionManager.getUserId());
          
          BuildderManager.updateScaleHeatmap(chartPosition, SessionManager.getUserId(), widget.id, widget.type);
          BuildderManager.updateScalePosition(position, SessionManager.getUserId(), widget.id, widget.type);
          Timer(const Duration(milliseconds: 500), (){
            widget.getScaleHeatmap(MediaQuery.of(context).size);
          });
        },
        child: 
          Container(
            child: new CircleAvatar(
                  child: new Text(''),
                  backgroundColor: intToColor(scaleColor).withOpacity(0.4),
                  radius: 30.0,
                ),
            width: 85.0,
            height: 85.0,
            padding: const EdgeInsets.all(0.0),
            decoration: new BoxDecoration(
              color: Colors.transparent, // border color
              shape: BoxShape.circle,
              border: Border.all(
                color: intToColor(scaleColor),
                width: borderWidth,
              ),
            )),
          ),
        );
  }
}
