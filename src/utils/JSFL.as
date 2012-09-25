package utils
{
	import adobe.utils.MMExecute;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.messaging.channels.StreamingAMFChannel;
	
	[Bindable]
	public class JSFL
	{
		private static const JSFL_URL:String = "SkeletonDesignPanel/skeleton.jsfl";
		
		private static var urlLoader:URLLoader = new URLLoader();
		if(JSFL.isAvailable){
			urlLoader.addEventListener(Event.COMPLETE, onJSFLHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onJSFLHandler);
			urlLoader.load(new URLRequest (JSFL.JSFL_URL));
		}
		
		private static function onJSFLHandler(_e:Event):void{
			urlLoader.removeEventListener(Event.COMPLETE, onJSFLHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onJSFLHandler);
			switch(_e.type){
				case IOErrorEvent.IO_ERROR:
					break;
				case Event.COMPLETE:
					JSFL.runJSFL(_e.target.data);
					break;
			}
		}
		
		private static function xmlToString(_xml:XML):String{
			return <a a={_xml.toXMLString()}/>.@a.toXMLString();
		}
		
		private static function runJSFL(_code:String):String{
			var _result:*;
			try {
				_result = MMExecute(_code);
			}catch(_e:Error){
			}
			return _result;
		}
		
		public static function get isAvailable():Boolean{
			try{
				MMExecute("fl;");
				return true;
			}catch(_e:Error){
			}
			return false;
		}
		
		public static function trace(...arg):String{
			var _str:String = "";
			for(var _i:uint = 0;_i < arg.length;_i ++){
				if(_i!=0){
					_str += ", ";
				}
				_str += arg[_i];
			}
			if(isAvailable){
				MMExecute("fl.trace('" +_str+ "');");
			}
			return _str;
		}
		
		public static function getArmatureList(_isSelected:Boolean):int{
			var _code:String = _isSelected?"Skeleton.getArmatureList(fl.getDocumentDOM().library.getSelectedItems());":"Skeleton.getArmatureList(fl.getDocumentDOM().library.items);";
			return int(runJSFL(_code));
		}
		
		public static function generateArmature():*{
			var _result:String = runJSFL("Skeleton.generateArmature();");
			if(_result == "true"){
				return true;
			}else if(_result == "false"){
				return false;
			}
			return XML(_result);
		}
		
		public static function clearTextureSWFItem():void{
			runJSFL("Skeleton.clearTextureSWFItem()");
		}
		
		public static function addTextureToSWFItem():XML{
			var _result:String = runJSFL("Skeleton.addTextureToSWFItem()");
			if(_result == "false"){
				return null;
			}
			return XML(_result);
		}
		
		public static function packTextures(_textureAtlasXML:XML = null):void{
			var _str:String = xmlToString(_textureAtlasXML);
			runJSFL("Skeleton.packTextures('" + _str + "');");
		}
		
		public static function exportSWF():String{
			return runJSFL("Skeleton.exportSWF();");
		}
		
		public static function changeArmatureConnection(_armatureName:String, _armatureXML:XML):void{
			runJSFL("Skeleton.changeArmatureConnection('" + _armatureName + "','" + xmlToString(_armatureXML) + "');");
		}
		
		public static function changeMovement(_armatureName:String, _movementName:String, _movementXML:XML):void{
			runJSFL("Skeleton.changeMovement('" + _armatureName + "','" + _movementName + "','" + xmlToString(_movementXML) + "');");
		}
	}
}