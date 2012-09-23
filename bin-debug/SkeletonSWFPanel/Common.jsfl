var Common = {};
(function(){
	
Common.trace = function(){
	var _str = "";
	for(var _i = 0;_i < arguments.length;_i ++){
		if(_i!=0){
			_str += ", ";
		}
		_str += arguments[_i];
	}
	fl.trace(_str);
}

Common.formatNumber = function(_num, _retain){
	_retain = _retain || 100;
	return Math.round(_num * _retain) / 100;
}

Common.replaceString = function(_strOld, _str, _rep){
	if(_strOld){
		return _strOld.split(_str).join(_rep);
	}
	return "";
}

//是否为空图层
Common.isBlankLayer = function(_layer){
	for each(var _frame in Common.filterKeyFrames(_layer.frames)){
		if(_frame.elements.length){
			return false;
		}
	}
	return true;
}

//过滤关键帧
Common.filterKeyFrames = function(_frames){
	var _framesCopy = [];
	for each(var _frame in _frames){
		if(_framesCopy.indexOf(_frame) >= 0){
			continue;
		}
		_framesCopy.push(_frame);
	}
	return _framesCopy;
}

})();

