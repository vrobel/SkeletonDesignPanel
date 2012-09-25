var Skeleton = {};
(function(){

var SKELETON = "skeleton";

var ARMATURES = "armatures";
var ARMATURE = "armature";
var BONE = "b";
var DISPLAY = "d";

var ANIMATIONS = "animations";
var ANIMATION = "animation";
var MOVEMENT = "mov";
var EVENT = "event";
var FRAME = "f";

var TEXTURE_ATLAS = "TextureAtlas";
var SUB_TEXTURE = "SubTexture";

var AT = "@";
var A_BONE_TYPE = "bT";
var A_NAME = "name";
var A_START = "st";
var A_DURATION = "dr";
var A_DURATION_TO = "to";
var A_DURATION_TWEEN = "drTW";
var A_LOOP = "lp";
var A_MOVEMENT_SCALE = "sc";
var A_MOVEMENT_DELAY = "dl";

var A_PARENT = "parent";
var A_X = "x";
var A_Y = "y";
var A_SCALE_X = "cX";
var A_SCALE_Y = "cY";
var A_SKEW_X = "kX";
var A_SKEW_Y = "kY";
var A_Z = "z";
var A_DISPLAY_INDEX = "dI";
var A_EVENT = "evt";
var A_SOUND = "sd";
var A_SOUND_EFFECT = "sdE";
var A_TWEEN_EASING ="twE";
var A_TWEEN_ROTATE ="twR";
var A_IS_ARMATURE = "isArmature";
var A_MOVEMENT = "mov";

var A_LOCAL_SKEW_X = "localSkewX";
var A_LOCAL_SKEW_Y = "localSkewY";

var A_WIDTH = "width";
var A_HEIGHT = "height";
var A_PIVOT_X = "pX";
var A_PIVOT_Y = "pY";

var V_SOUND_LEFT = "l";
var V_SOUND_RIGHT = "r";
var V_SOUND_LEFT_TO_RIGHT = "lr";
var V_SOUND_RIGHT_TO_LEFT = "rl";
var V_SOUND_FADE_IN = "in";
var V_SOUND_FADE_OUT = "out";

var MOVIE_CLIP = "movie clip";
var GRAPHIC = "graphic";
var STRING = "string";
var LABEL_TYPE_NAME = "name";
var EVENT_PREFIX = "@";
var MOVEMENT_PREFIX = "#";
var NO_EASING = "^";
var DELIM_CHAR = "|";
var UNDERLINE_CHAR = "_";

var SKELETON_PANEL = "SkeletonDesignPanel";
var ARMATURE_DATA = "armatureData";
var ANIMATION_DATA = "animationData";

var TEXTURE_SWF_ITEM = "textureSWFItem";
var TEXTURE_SWF = "armatureTextureSWF.swf";

var helpPoint = {x:0, y:0, skewX:0, skewY:0};

/*
var currentDom;
var currentLibrary;
var currentDomName;

var xml;
var armaturesXML;
var animationsXML;

var armatureXML;
var animationXML;
var armatureConnectionXML;

var importItems;
var textureItems;
var textureLength;
var textureIndex;
*/


function trace(){
	var _str = "";
	for(var _i = 0;_i < arguments.length;_i ++){
		if(_i!=0){
			_str += ", ";
		}
		_str += arguments[_i];
	}
	fl.trace(_str);
}

function formatNumber(_num, _retain){
	_retain = _retain || 100;
	return Math.round(_num * _retain) / 100;
}

replaceString = function(_strOld, _str, _rep){
	if(_strOld){
		return _strOld.split(_str).join(_rep);
	}
	return "";
}

//是否为空图层
function isBlankLayer(_layer){
	for each(var _frame in filterKeyFrames(_layer.frames)){
		if(_frame.elements.length){
			return false;
		}
	}
	return true;
}

//过滤关键帧
function filterKeyFrames(_frames){
	var _framesCopy = [];
	for each(var _frame in _frames){
		if(_framesCopy.indexOf(_frame) >= 0){
			continue;
		}
		_framesCopy.push(_frame);
	}
	return _framesCopy;
}

function errorDOM(){
	if(!currentDom){
		alert("没有打开的 FLA 档案！");
		return true;
	}
	return false;
}

function transfromParentPoint(_point, _symbol, _parentSymbol){
	var _dX = _symbol.x - _parentSymbol.x;
	var _dY = _symbol.y - _parentSymbol.y;
	var _r = Math.atan2(_dY, _dX) - _parentSymbol.skewY * Math.PI / 180;
	var _len = Math.sqrt(_dX * _dX + _dY * _dY);
	_point.x = _len * Math.cos(_r);
	_point.y = _len * Math.sin(_r);
}

//防止对象命名非法
function formatName(_obj){
	var _name = _obj.name;
	if(!_name){
		_obj.name = _name = "unnamed" + Math.round(Math.random()*10000);
	}else if(_name.indexOf(DELIM_CHAR) >= 0){
		_obj.name = _name = replaceString(_name, DELIM_CHAR, "");
	}
	return _name;
}

//避开重名
function formatSameName(_obj, _dic){
	var _i = 0;
	var _name = formatName(_obj);
	while(_dic[_name]){
		_name = _obj.name + _i;
		_i ++;
	}
	if(_i > 0){
		_obj.name = _name;
	}
	_dic[_name] = true;
	return _name;
}

//是否为不补间关键帧
function isNoEasingFrame(_frame){
	return _frame.labelType == LABEL_TYPE_NAME && _frame.name.indexOf(NO_EASING) >= 0;
}

//是否为事件关键帧
function isSpecialFrame(_frame, _framePrefix, _returnName){
	var _b = _frame.labelType == LABEL_TYPE_NAME && _frame.name.indexOf(_framePrefix) >= 0 && _frame.name.length > 1;
	if(_b && _returnName){
		var _arr = _frame.name.split(DELIM_CHAR);
		for each(var _str in _arr){
			if(_str.indexOf(_framePrefix) == 0){
				return _str.substr(1);
			}
		}
		trace("错误的特殊关键帧命名！", _frame.name);
		return false;
	}
	return _b;
}

//是否为主关键帧
function isMainFrame(_frame){
	return _frame.labelType == LABEL_TYPE_NAME && !isNoEasingFrame(_frame) && !isSpecialFrame(_frame, EVENT_PREFIX) && !isSpecialFrame(_frame, MOVEMENT_PREFIX);
}

//是否为主标签层
function isMainLayer(_layer){
	for each(var _frame in filterKeyFrames(_layer.frames)){
		if(isMainFrame(_frame)){
			return true;
		}
	}
	return false;
}

//是否符合 armature 结构，如果是返回 mainLayer 和 boneLayers
function isArmatureItem(_item){
	var _layersFiltered = [];
	var _mainLayer;
	for each(var _layer in _item.timeline.layers){
		switch(_layer.layerType){
			case "folder":
			case "guide":
			case "mask":
				break;
			default:
				if(isMainLayer(_layer)){
					_mainLayer = _layer;
				}else if(!isBlankLayer(_layer)){
					_layersFiltered.unshift(_layer);
				}
				break;
		}
	}
	
	if(_mainLayer && _layersFiltered.length > 0){
		_layersFiltered.unshift(_mainLayer);
		return _layersFiltered;
	}
	return null;
}

//过滤符合骨骼的元素
function getBoneSymbol(_elements){
	for each(var _element in _elements){
		if(_element.symbolType == MOVIE_CLIP || _element.symbolType == GRAPHIC){
			return _element;
		}
	}
	return null;
}

//获取骨骼
function getBoneFromLayers(layers, _boneName, _frameIndex){
	for each(var _layer in layers){
		if(_layer.name == _boneName){
			return getBoneSymbol(_layer.frames[_frameIndex].elements);
		}
	}
	return null;
}

//写入骨架关联数据
function setArmatureConnection(_item, _data){
	_item.addData(ARMATURE_DATA, STRING, _data);
}

function getMovementXML(_movementName, _item, _duration){
	var _xml = <{MOVEMENT} {A_NAME} = {_movementName}/>;
	if(_item.hasData(ANIMATION_DATA)){
		var _animationXML = XML(_item.getData(ANIMATION_DATA));
		var _movementXML = _animationXML[MOVEMENT].(@name == _movementName)[0];
	}
	_xml[AT + A_DURATION] = _duration;
	if(_movementXML){
		_xml[AT + A_DURATION_TO] = _movementXML[AT + A_DURATION_TO];
	}else{
		_xml[AT + A_DURATION_TO] = 6;
	}
	if(_duration > 1){
		if(_movementXML){
			_xml[AT + A_DURATION_TWEEN] = _movementXML[AT + A_DURATION_TWEEN];
			_xml[AT + A_LOOP] = _movementXML[AT + A_LOOP];
			_xml[AT + A_TWEEN_EASING] = _movementXML[AT + A_TWEEN_EASING].length()?_movementXML[AT + A_TWEEN_EASING]:NaN;
		}else{
			_xml[AT + A_DURATION_TWEEN] = _duration > 2?_duration:10;
			if(_duration == 2){
				_xml[AT + A_LOOP] = 1;
				_xml[AT + A_TWEEN_EASING] = 2;
			}else{
				_xml[AT + A_LOOP] = 0;
				_xml[AT + A_TWEEN_EASING] = NaN;
			}
		}
	}
	return _xml;
}

function getMovementBoneXML(_movementXML, _boneName){
	var _xml = _movementXML[BONE].(@name == _boneName)[0];
	if(!_xml){
		_xml = <{BONE} {A_NAME} = {_boneName}/>;
		_xml[AT + A_MOVEMENT_SCALE] = 1;
		_xml[AT + A_MOVEMENT_DELAY] = 0;
		_movementXML.appendChild(_xml);
	}
	return _xml;
}

function getBoneXML(_name, _z){
	var _xml = armatureXML[BONE].(@name == _name)[0];
	if(!_xml){
		_xml = <{BONE} {A_NAME} = {_name}/>;
		var _connectionXML = armatureConnectionXML[BONE].(@name == _name)[0];
		if(_connectionXML && _connectionXML[AT + A_PARENT][0]){
			_xml[AT + A_PARENT] = _connectionXML[AT + A_PARENT];
		}
		/*_xml[AT + A_X] = formatNumber(_point.x);
		_xml[AT + A_Y] = formatNumber(_point.y);
		_xml[AT + A_SKEW_X] = formatNumber(_point.skewX);
		_xml[AT + A_SKEW_Y] = formatNumber(_point.skewY);*/
		_xml[AT + A_Z] = _z;
		armatureXML.appendChild(_xml);
	}
	return _xml;
}

function getDisplayXML(_boneXML, _imageName, _isArmature){
	var _xml = _boneXML[DISPLAY].(@name == _imageName)[0];
	if(!_xml){
		_xml = <{DISPLAY} {A_NAME} = {_imageName}/>;
		if(_isArmature){
			_xml[AT + A_IS_ARMATURE] = 1;
		}
		_boneXML.appendChild(_xml);
	}
	return _xml;
}

function generateMovement(_item, _mainFrame, _layers){
	var _start = _mainFrame.frame.startFrame;
	var _duration = _mainFrame.duration;
	var _movementXML = getMovementXML(_mainFrame.frame.name, _item, _duration);
	
	var _boneNameDic = {};
	var _boneZDic = {};
	var _zList = [];
	var _frameStart;
	var _frameDuration;
	var _boneList;
	var _z;
	var _i;
	var _movementBoneXML;
	var _frameXML;
	var _symbol;
	var _boneName;
	
	for each(var _layer in _layers){
		_boneName = formatName(_layer);
		_boneZDic[_boneName] = [];
		_movementBoneXML = null;
		for each(var _frame in filterKeyFrames(_layer.frames.slice(_start, _start + _duration))){
			if(_frame.startFrame < _start){
				_frameStart = 0;
				_frameDuration = _frame.duration - _start + _frame.startFrame;
			}else if(_frame.startFrame + _frame.duration > _start + _duration){
				_frameStart = _frame.startFrame - _start;
				_frameDuration = _duration - _frame.startFrame + _start;
			}else{
				_frameStart = _frame.startFrame - _start;
				_frameDuration= _frame.duration;
			}
			_symbol = getBoneSymbol(_frame.elements);
			if(!_symbol){
				continue;
			}
			if(!_movementBoneXML){
				_movementBoneXML = getMovementBoneXML(_movementXML, _boneName);
			}
			for(_i = _frameStart ;_i < _frameStart + _frameDuration;_i ++){
				_z = _zList[_i];
				if(isNaN(_z)){
					_zList[_i] = _z = 0;
				}else{
					_zList[_i] = ++_z;
				}
			}
			_boneList = _boneZDic[_boneName];
			for(_i = _frameStart;_i < _frameStart + _frameDuration;_i ++){
				if(!isNaN(_boneList[_i])){
					_boneName = formatSameName(_layer, _boneNameDic);
					_boneList = _boneZDic[_boneName] = [];
					_movementBoneXML = getMovementBoneXML(_movementXML, _boneName);
				}
				_boneList[_i] = _z;
			}
			
			if(_frame.tweenType == "motion object"){
				
				break;
			}
			_frameXML = generateFrame(_frame, _boneName, _symbol, _z, _layers, Math.max(_frame.startFrame, _start));
			_frameXML[AT + A_START] = _frameStart;
			_frameXML[AT + A_DURATION] = _frameDuration;
			_movementBoneXML.appendChild(_frameXML);
		}
	}
	
	var _prevFrameXML;
	var _prevStart;
	var _prevDuration;
	var _frameIndex;
	
	for each(var _movementBoneXML in _movementXML[BONE]){
		_boneName = _movementBoneXML[AT + A_NAME];
		for each(_frameXML in _movementBoneXML[FRAME]){
			_frameStart = Number(_frameXML[AT + A_START]);
			_frameIndex = _frameXML.childIndex();
			if(_frameIndex == 0){
				if(_frameStart > 0){
					_movementBoneXML.prependChild(<{FRAME} {A_DURATION} = {_frameStart} {A_DISPLAY_INDEX} = "-1"/>);
				}
			}else {
				_prevStart = Number(_prevFrameXML[AT + A_START]);
				_prevDuration = Number(_prevFrameXML[AT + A_DURATION]);
				if(_frameStart > _prevStart + _prevDuration){
					_movementBoneXML.insertChildBefore(_frameXML, <{FRAME} {A_DURATION} = {_frameStart - _prevStart - _prevDuration} {A_DISPLAY_INDEX} = "-1"/>);
				}
			}
			if(_frameIndex == _movementBoneXML[FRAME].length() - 1){
				_frameStart = Number(_frameXML[AT + A_START]);
				_prevDuration = Number(_frameXML[AT + A_DURATION]);
				if(_frameStart + _prevDuration < _duration){
					_movementBoneXML.appendChild(<{FRAME} {A_DURATION} = {_duration - _frameStart - _prevDuration} {A_DISPLAY_INDEX} = "-1"/>);
				}
			}
			//tweenRotate属性应留给补间的到点而不是起点
			//逆时针x0或顺时针x0有时需要忽略
			if(_prevFrameXML && _prevFrameXML[AT + A_TWEEN_ROTATE][0]){
				var _dSkY = Number(_frameXML[AT + A_LOCAL_SKEW_Y]) - Number(_prevFrameXML[AT + A_LOCAL_SKEW_Y]);
				if(_dSkY < -180){
					_dSkY += 360;
				}
				if(_dSkY > 180){
					_dSkY -= 360;
				}
				_tweenRotate = Number(_prevFrameXML[AT + A_TWEEN_ROTATE]);
				if(_dSkY !=0){
					if(_dSkY < 0){
						if(_tweenRotate >= 0){
							_tweenRotate ++;
						}
					}else{
						if(_tweenRotate < 0){
							_tweenRotate --;
						}
					}
				}
				_frameXML[AT + A_TWEEN_ROTATE] = _tweenRotate;
				delete _prevFrameXML[AT + A_TWEEN_ROTATE];
			}
			
			_prevFrameXML = _frameXML;
		}
	}
	delete _movementXML[BONE][FRAME][AT + A_START];
	delete _movementXML[BONE][FRAME][AT + A_LOCAL_SKEW_Y];
	animationXML.appendChild(_movementXML);
}

function generateFrame(_frame, _boneName, _symbol, _z, _layers, _start){
	var _frameXML = <{FRAME}/>;
	var _boneXML = getBoneXML(_boneName, _z);
	if(_boneXML){
		var _parentName = _boneXML[AT + A_PARENT][0];
	}
	
	if(_parentName){
		var _parentSymbol = getBoneFromLayers(_layers, _parentName, _start);
	}
	if (_parentSymbol) {
		transfromParentPoint(helpPoint, _symbol, _parentSymbol);
		helpPoint.skewX = _symbol.skewX - _parentSymbol.skewX;
		helpPoint.skewY = _symbol.skewY - _parentSymbol.skewY;
	}else {
		helpPoint.x = _symbol.x;
		helpPoint.y = _symbol.y;
		helpPoint.skewX = _symbol.skewX;
		helpPoint.skewY = _symbol.skewY;
	}
	
	if(!_boneXML[AT + A_X][0]){
		_boneXML[AT + A_X] = formatNumber(helpPoint.x);
		_boneXML[AT + A_Y] = formatNumber(helpPoint.y);
		_boneXML[AT + A_SKEW_X] = formatNumber(helpPoint.skewX);
		_boneXML[AT + A_SKEW_Y] = formatNumber(helpPoint.skewY);
	}
	/*if(_parentName && !_parentSymbol){
		//预留切换父骨骼
	}*/
	//x、y、skewX、skewY为相对数据
	_frameXML[AT + A_X] = formatNumber(helpPoint.x - Number(_boneXML[AT + A_X]));
	_frameXML[AT + A_Y] = formatNumber(helpPoint.y - Number(_boneXML[AT + A_Y]));
	_frameXML[AT + A_SKEW_X] = formatNumber(helpPoint.skewX - Number(_boneXML[AT + A_SKEW_X]));
	_frameXML[AT + A_SKEW_Y] = formatNumber(helpPoint.skewY - Number(_boneXML[AT + A_SKEW_Y]));
	_frameXML[AT + A_SCALE_X] = formatNumber(_symbol.scaleX);
	_frameXML[AT + A_SCALE_Y] = formatNumber(_symbol.scaleY);
	_frameXML[AT + A_Z] = _z;
	//临时数据
	_frameXML[AT + A_LOCAL_SKEW_Y] = _symbol.skewY;
	
	var _imageItem = _symbol.libraryItem;
	var _imageName = formatName(_imageItem);
	var _isArmature = isArmatureItem(_imageItem);
	var _displayXML = getDisplayXML(_boneXML, _imageName, _isArmature);
	_frameXML[AT + A_DISPLAY_INDEX] = _displayXML.childIndex();
	if(_isArmature){
		Skeleton.generateArmature(_symbol);
	}else{
		if(textureItems.indexOf(_imageItem) < 0){
			textureItems.push(_imageItem);
		}
	}
	
	var _str = isSpecialFrame(_frame, MOVEMENT_PREFIX, true);
	if(_str){
		_frameXML[AT + A_MOVEMENT] = _str;
	}
	
	//补间
	if(isNoEasingFrame(_frame)){
		//带有"^"标签的关键帧，将不会被补间
		_frameXML[AT + A_TWEEN_EASING] = NaN;
	}else if(_frame.tweenType == "motion"){
		_frameXML[AT + A_TWEEN_EASING] = formatNumber(_frame.tweenEasing * 0.01);
		var _tweenRotate = NaN;
		switch(_frame.motionTweenRotate){
			case "clockwise":
				_tweenRotate = _frame.motionTweenRotateTimes;
				break;
			case "counter-clockwise":
				_tweenRotate = - _frame.motionTweenRotateTimes;
				break;
		}
		if(!isNaN(_tweenRotate)){
			_frameXML[AT + A_TWEEN_ROTATE] = _tweenRotate;
		}
	}
	
	//event
	_str = isSpecialFrame(_frame, EVENT_PREFIX, true);
	if(_str){
		_frameXML[AT + A_EVENT] = _str;
	}

	//sound
	if(_frame.soundName){
		_frameXML[AT + A_SOUND] = _frame.soundLibraryItem.linkageClassName || _frame.soundName;
		var _soundEffect;
		switch(_frame.soundEffect){
			case "left channel":
				_soundEffect = V_SOUND_LEFT;
				break;
			case "right channel":
				_soundEffect = V_SOUND_RIGHT;
				break;
			case "fade left to right":
				_soundEffect = V_SOUND_LEFT_TO_RIGHT;
				break;
			case "fade right to left":
				_soundEffect = V_SOUND_RIGHT_TO_LEFT;
				break;
			case "fade in":
				_soundEffect = V_SOUND_FADE_IN;
				break;
			case "fade out":
				_soundEffect = V_SOUND_FADE_OUT;
				break;
		}
		if(_soundEffect){
			_frameXML[AT + A_SOUND_EFFECT] = _soundEffect;
		}
	}
	
	return _frameXML;
}

Skeleton.getArmatureList = function(_items){
	fl.outputPanel.clear();
	currentDom = fl.getDocumentDOM();
	currentLibrary = currentDom?currentDom.library:null;
	if(errorDOM()){
		return 0;
	}
	currentDom.exitEditMode();
	
	currentDomName = currentDom.name.split(".")[0];
	xml = null;
	
	importItems = [];
	textureItems = [];
	for each(var _item in _items){
		if((_item.symbolType == MOVIE_CLIP || _item.symbolType == GRAPHIC) && isArmatureItem(_item)){
			importItems.push(_item);
		}
	}
	return importItems.length;
}

Skeleton.generateArmature = function(_item){
	if(importItems.length == 0){
		return false;
	}
		
	if(_item){
		var _index = importItems.indexOf(_item);
		if(_index >= 0){
			importItems.splice(_index, 1);
		}
	}else{
		_item = importItems.pop();
		if(!_item){
			return true;
		}
		xml = <{SKELETON} {A_NAME} = {currentDomName}/>;
		armaturesXML = <{ARMATURES}/>;
		animationsXML = <{ANIMATIONS}/>;
		xml.appendChild(armaturesXML);
		xml.appendChild(animationsXML);
	}
	
	var _armatureName = formatName(_item);
	if(armaturesXML[ARMATURE].(@name == _armatureName)[0]){
		return true;
	}
	
	var _layersFiltered = isArmatureItem(_item);
	var _mainLayer = _layersFiltered.shift();
	
	armatureXML = <{ARMATURE} {A_NAME} = {_armatureName}/>;
	armaturesXML.appendChild(armatureXML);
	animationXML = <{ANIMATION} {A_NAME} = {_armatureName}/>;
	//只有1个 movement 且movement.duration只有1，则定义没有动画的骨骼
	if(_mainLayer.frameCount > 1){
		animationsXML.appendChild(animationXML);
	}
	
	armatureConnectionXML = _item.hasData(ARMATURE_DATA)?XML(_item.getData(ARMATURE_DATA)):armatureXML;
	
	var _keyFrames = filterKeyFrames(_mainLayer.frames);
	var _length = _keyFrames.length;
	var _nameDic = {};
	
	var _frame;
	var _mainFrame;
	var _isEndFrame;
	
	for(var _iF = 0;_iF < _length;_iF ++){
		_frame = _keyFrames[_iF];
		if(isMainFrame(_frame)){
			//新帧
			_mainFrame = {};
			_mainFrame.frame = _frame;
			_mainFrame.duration = _frame.duration;
			formatSameName(_frame, _nameDic);
		}else if(_mainFrame){
			//继续
			_mainFrame.duration += _frame.duration;
			if(_iF + 1 != _length){
				_mainFrame[_frame.startFrame] = _frame;
			}
		}else{
			//忽略
			continue;
		}
		_isEndFrame = _iF + 1 == _length || isMainFrame(_keyFrames[_iF + 1]);
		if(_mainFrame && _isEndFrame){
			//结束前帧
			generateMovement(_item, _mainFrame, _layersFiltered);
		}
	}
	//setArmatureConnection(_item, armatureXML.toXMLString());
	return xml.toXMLString();
}

Skeleton.clearTextureSWFItem = function(){
	if(!currentLibrary.itemExists(TEXTURE_SWF_ITEM)){
		currentLibrary.addNewItem(MOVIE_CLIP, TEXTURE_SWF_ITEM);
	}
	currentLibrary.editItem(TEXTURE_SWF_ITEM);
	xml = null;
	
	var _timeline = currentDom.getTimeline();
	_timeline.currentLayer = 0;
	_timeline.removeFrames(0, _timeline.frameCount);
	_timeline.insertBlankKeyframe(0);
	_timeline.insertBlankKeyframe(1);
	return textureItems.length;
}

Skeleton.addTextureToSWFItem = function(){
	var _timeline = currentDom.getTimeline();
	if(textureItems.length ==0){
		_timeline.removeFrames(1, 1);
		return false;
	}
	
	_timeline.currentFrame = 0;
	var _item = textureItems.pop();
	var _name = _item.name;
	helpPoint.x = helpPoint.y = 0;
	if(!currentLibrary.addItemToDocument(helpPoint, _name)){
		currentLibrary.addItemToDocument(helpPoint, _name);
	}
	
	_symbol = currentDom.selection[0];
	if(_symbol.symbolType != MOVIE_CLIP){
		_symbol.symbolType = MOVIE_CLIP;
	}
	var _subTextureXML = <{SUB_TEXTURE} {A_NAME} = {_name}/>;
	_subTextureXML[AT + A_PIVOT_X] = formatNumber(_symbol.x - _symbol.left);
	_subTextureXML[AT + A_PIVOT_Y] = formatNumber(_symbol.y - _symbol.top);
	_subTextureXML[AT + A_WIDTH] = Math.ceil(_symbol.width);
	_subTextureXML[AT + A_HEIGHT] = Math.ceil(_symbol.height);
	
	_timeline.currentFrame = 1;
	return _subTextureXML.toXMLString();
}

Skeleton.packTextures = function(_textureAtlasXML){
	if(errorDOM()){
		return;
	}
	
	if(!currentLibrary.itemExists(TEXTURE_SWF_ITEM)){
		return;
	}
	_textureAtlasXML = XML(_textureAtlasXML).toXMLString();
	_textureAtlasXML = replaceString(_textureAtlasXML, "&lt;", "<");
	_textureAtlasXML = replaceString(_textureAtlasXML, "&gt;", ">");
	_textureAtlasXML = XML(_textureAtlasXML);
	
	var _subTextureXMLList = _textureAtlasXML[SUB_TEXTURE];
	
	var _textureItem = currentLibrary.items[currentLibrary.findItemIndex(TEXTURE_SWF_ITEM)];
	var _timeline = _textureItem.timeline;
	_timeline.currentFrame = 0;
	var _name;
	var _textureXML;
	for each(var _texture in _textureItem.timeline.layers[0].frames[0].elements){
		_textureXML = _subTextureXMLList.(@name == _texture.libraryItem.name)[0];
		if(_textureXML){
			if(_texture.scaleX != 1){
				_texture.scaleX = 1;
			}
			if(_texture.scaleY != 1){
				_texture.scaleY = 1;
			}
			if(_texture.skewX != 0){
				_texture.skewX = 0;
			}
			if(_texture.skewY != 0){
				_texture.skewY = 0;
			}
			_texture.x += Number(_textureXML[AT + A_X]) - _texture.left;
			_texture.y += Number(_textureXML[AT + A_Y]) - _texture.top;
		}
	}
	currentDom.selectAll();
	currentDom.selectNone();
}

Skeleton.exportSWF = function(){
	if(errorDOM()){
		return;
	}
	
	if(!currentLibrary.itemExists(TEXTURE_SWF_ITEM)){
		return;
	}
	var _folderURL = fl.configURI;
	var _pathDelimiter;
	if(_folderURL.indexOf("/")>=0){
		_pathDelimiter = "/";
	}else if(_folderURL.indexOf("\\")>=0){
		_pathDelimiter = "\\";
	}else{
		return;
	}
	_folderURL = _folderURL + "WindowSWF" + _pathDelimiter + SKELETON_PANEL;
	if(!FLfile.exists(_folderURL)){
		FLfile.createFolder(_folderURL);
	}
	var _swfURL = _folderURL + _pathDelimiter + TEXTURE_SWF;
	currentLibrary.items[currentLibrary.findItemIndex(TEXTURE_SWF_ITEM)].exportSWF(_swfURL);
	return _swfURL;
}

//通过骨架名写入骨架关联数据
Skeleton.changeArmatureConnection = function(_armatureName, _data){
	if(errorDOM()){
		return;
	}
	var _item = currentLibrary.items[currentLibrary.findItemIndex(_armatureName)];
	if(!_item){
		trace("未找到 " + _armatureName + " 元件，请确认保持 FLA 文件同步！");
		return;
	}
	_data = XML(_data).toXMLString();
	_data = replaceString(_data, "&lt;", "<");
	_data = replaceString(_data, "&gt;", ">");
	setArmatureConnection(_item, _data);
}

Skeleton.changeMovement = function(_armatureName, _movementName, _data){
	if(errorDOM()){
		return;
	}
	var _item = currentLibrary.items[currentLibrary.findItemIndex(_armatureName)];
	if(!_item){
		trace("未找到 " + _armatureName + " 元件，请确认保持 FLA 文件同步！");
		return;
	}
	
	_data = XML(_data).toXMLString();
	_data = replaceString(_data, "&lt;", "<");
	_data = replaceString(_data, "&gt;", ">");
	_data = XML(_data);
	
	var _animationXML;
	if(_item.hasData(ANIMATION_DATA)){
		_animationXML = XML(_item.getData(ANIMATION_DATA));
	}else{
		_animationXML = <{ANIMATION}/>;
	}
	var _movementXML = _animationXML[MOVEMENT].(@name == _movementName)[0];
	if(_movementXML){
		_animationXML[MOVEMENT][_movementXML.childIndex()] = _data;
	}else{
		_animationXML.appendChild(_data);
	}
	delete _data[BONE].*;
	_item.addData(ANIMATION_DATA, STRING, _animationXML.toXMLString());
}

})();