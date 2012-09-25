package control
{
	import akdcl.skeleton.utils.ConstValues;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import makeswfs.make;
	
	import message.MessageDispatcher;
	
	import model.ImportDataProxy;
	
	import utils.JSFL;
	import utils.TextureUtil;
	
	public class LoadFLADataCommand
	{
		public static var instance:LoadFLADataCommand = new LoadFLADataCommand();
		
		private var urlLoader:URLLoader;
		private var intervalID:int;
		private var skeletonXML:XML;
		private var textureXML:XML;
		
		private var isLoading:Boolean;
		
		public function LoadFLADataCommand(){
			urlLoader = new URLLoader();
		}
		
		public function load(_isSelected:Boolean):void{
			if(!JSFL.isAvailable || isLoading){
				return;
			}
			var _length:uint = JSFL.getArmatureList(_isSelected);
			if(_length > 0){
				isLoading = true;
				skeletonXML = null;
				MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_FLADATA, _length);
				intervalID = setInterval(onGenerateFLAXMLHandler, 200);
			}
		}
		
		private function onGenerateFLAXMLHandler():void{
			var _result:* = JSFL.generateArmature();
			if(_result === false){
				MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_SKELETON_DATA_COMPLETE);
				JSFL.clearTextureSWFItem();
				textureXML = <{ConstValues.TEXTURE_ATLAS}/>;
				clearInterval(intervalID);
				intervalID = setInterval(onGenerateTextureSWFHandler, 20);
			}else if(_result !== true){
				MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_SKELETON_DATA);
				addSkeletonXML(_result as XML);
			}
		}
		
		private function onGenerateTextureSWFHandler():void{
			var _subTextureXML:XML = JSFL.addTextureToSWFItem();
			if(_subTextureXML){
				MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_TEXTURE_DATA);
				textureXML.appendChild(_subTextureXML);
			}else{
				MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_TEXTURE_DATA_COMPLETE);
				clearInterval(intervalID);
				TextureUtil.packTextures(ImportDataProxy.getInstance().textureMaxWidth, ImportDataProxy.getInstance().texturePadding, false, textureXML);
				JSFL.packTextures(textureXML);
				exportAndLoadSWF();
			}
		}
		
		private function addSkeletonXML(_skeletonXML:XML):void{
			if(skeletonXML){
				var _xmlList1:XMLList;
				var _xmlList2:XMLList;
				var _node1:XML;
				var _node2:XML;
				var _name:String;
				
				_xmlList1 = skeletonXML.elements(ConstValues.ARMATURES).elements(ConstValues.ARMATURE);
				_xmlList2 = _skeletonXML.elements(ConstValues.ARMATURES).elements(ConstValues.ARMATURE);
				for each(_node2 in _xmlList2){
					_name = _node2.attribute(ConstValues.A_NAME);
					_node1 = _xmlList1.(attribute(ConstValues.A_NAME) == _name)[0];
					if(_node1){
						delete _xmlList1[_node1.childIndex()];
					}
					skeletonXML.elements(ConstValues.ARMATURES).appendChild(_node2);
				}
				
				_xmlList1 = skeletonXML.elements(ConstValues.ANIMATIONS).elements(ConstValues.ANIMATION);
				_xmlList2 = _skeletonXML.elements(ConstValues.ANIMATIONS).elements(ConstValues.ANIMATION);
				for each(_node2 in _xmlList2){
					_name = _node2.attribute(ConstValues.A_NAME);
					_node1 = _xmlList1.(attribute(ConstValues.A_NAME) == _name)[0];
					if(_node1){
						delete _xmlList1[_node1.childIndex()];
					}
					skeletonXML.elements(ConstValues.ANIMATIONS).appendChild(_node2);
				}
			}else{
				skeletonXML = _skeletonXML;
			}
		}
		
		private function exportAndLoadSWF():void{
			MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_SWF);
			var _swfURL:String = JSFL.exportSWF();
			urlLoader.addEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(new URLRequest(_swfURL));
		}
		
		private function onURLLoaderCompleteHandler(_e:Event):void{
			isLoading = false;
			urlLoader.removeEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);
			MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_SWF_COMPLETE, skeletonXML, textureXML, make(_e.target.data, textureXML));
		}
	}
}