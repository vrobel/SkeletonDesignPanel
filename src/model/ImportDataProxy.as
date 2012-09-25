package model
{
	import akdcl.skeleton.factorys.BaseFactory;
	import akdcl.skeleton.objects.SkeletonData;
	import akdcl.skeleton.objects.TextureData;
	import akdcl.skeleton.utils.ConstValues;
	
	import message.MessageDispatcher;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.XMLListCollection;
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class ImportDataProxy
	{	
		private static var instance:ImportDataProxy
		public static function getInstance():ImportDataProxy{
			if(!instance){
				instance = new ImportDataProxy();
			}
			return instance;
		}
		
		public static function getElementByName(_xmlList:XMLList, _name:String = null):XML{
			if(_xmlList){
				if(_name){
					return _xmlList.(attribute(ConstValues.A_NAME) == _name)[0];
				}
				return _xmlList[0];
			}
			return null;
		}
		
		public static function getElementName(_xml:XML):String{
			return _xml?String(_xml.attribute(ConstValues.A_NAME)):"";
		}
		
		public var armaturesMC:XMLListCollection;
		
		private var armaturesXMLList:XMLList;
		private var animationsXMLList:XMLList;
		
		private var setTimeoutID:int;
		
		public var dataImportID:int = 0;
		public var dataImportAC:ArrayCollection = new ArrayCollection(["All library items", "Seleted items", "Exported SWF/PNG"]);
		
		public var dataExportID:int = 0;
		public var dataExportAC:ArrayCollection = new ArrayCollection(["SWF", "PNG"]);
		
		public var textureMaxWidthID:int = 2;
		public var textureMaxWidthAC:ArrayCollection = new ArrayCollection([128, 256, 512, 1024, 2048, 4096]);
		public function get textureMaxWidth():int{
			return int(textureMaxWidthAC.getItemAt(textureMaxWidthID));
		}
		
		public var texturePadding:int = 2;
		
		public var textureSortID:int = 0;
		public var textureSortAC:ArrayCollection = new ArrayCollection(["MaxRects"]);
		
		
		public function get skeletonName():String{
			return getElementName(__skeletonXML);
		}
		
		private var rawSkeletonXML:XML;
		private var __skeletonXML:XML;
		public function get skeletonXML():XML{
			return __skeletonXML;
		}
		
		private var __textureXML:XML;
		public function get textureXML():XML{
			return __textureXML;
		}
		
		private var __textureBytes:ByteArray;
		public function get textureBytes():ByteArray{
			return __textureBytes;
		}
		
		private var __armatureDataProxy:ArmatureDataProxy;
		public function get armatureDataProxy():ArmatureDataProxy{
			return __armatureDataProxy;
		}
		
		private var __animationDataProxy:AnimationDataProxy;
		public function get animationDataProxy():AnimationDataProxy{
			return __animationDataProxy;
		}
		
		private var __skeletonData:SkeletonData;
		public function get skeletonData():SkeletonData{
			return __skeletonData;
		}
		
		private var __textureData:TextureData;
		public function get textureData():TextureData{
			return __textureData;
		}
		
		private var __baseFactory:BaseFactory;
		public function get baseFactory():BaseFactory{
			return __baseFactory;
		}
		
		public function ImportDataProxy()
		{
			if (instance) {
				throw new IllegalOperationError("Singleton already constructed!");
			}
			armaturesMC = new XMLListCollection();
			
			__armatureDataProxy = new ArmatureDataProxy();
			__animationDataProxy = new AnimationDataProxy();
			__baseFactory = new BaseFactory();
		}
		
		public function setData(_skeletonXML:XML, _textureXML:XML, _textureData:ByteArray):void{
			rawSkeletonXML = _skeletonXML;
			__skeletonXML = rawSkeletonXML.copy();
			__textureXML = _textureXML;
			__textureBytes = _textureData;
			
			armaturesXMLList = __skeletonXML.elements(ConstValues.ARMATURES).elements(ConstValues.ARMATURE);
			animationsXMLList = __skeletonXML.elements(ConstValues.ANIMATIONS).elements(ConstValues.ANIMATION);
			
			armaturesMC.source = armaturesXMLList;
			
			if(__skeletonData){
				__skeletonData.dispose();
			}
			
			if(__textureData){
				__textureData.dispose();
			}
			
			__skeletonData = new SkeletonData(__skeletonXML);
			__textureData = new TextureData(__textureXML, __textureBytes, true);
			
			__baseFactory.skeletonData = __skeletonData;
			__baseFactory.textureData = __textureData;
			
			setTimeoutID = setTimeout(onUpdateHandler, 400);
		}
	
		private function onUpdateHandler():void{
			clearTimeout(setTimeoutID);
			MessageDispatcher.dispatchEvent(MessageDispatcher.CHANGE_IMPORT_DATA);
		}
			
		public function getArmatureXMLByName(_name:String = null):XML{
			return getElementByName(armaturesXMLList, _name);
		}
		
		public function getAnimationXMLByName(_name:String = null):XML{
			return getElementByName(animationsXMLList, _name);
		}
	}
}