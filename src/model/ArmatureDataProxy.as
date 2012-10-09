package model
{
	import akdcl.skeleton.utils.ConstValues;
	import akdcl.skeleton.utils.generateBoneData;
	
	import flash.events.Event;
	
	import message.MessageDispatcher;
	
	import mx.collections.XMLListCollection;
	
	import utils.JSFL;
	
	[Bindable]
	public class ArmatureDataProxy
	{
		public var bonesMC:XMLListCollection;
		public var displaysMC:XMLListCollection;
		
		private var xml:XML;
		private var bonesXMLList:XMLList;
		
		private var boneXML:XML;
		private var displaysXMLList:XMLList;
		private var displayXML:XML;
		
		public function get source():XML{
			return xml;
		}
		
		public function get armatureName():String{
			return ImportDataProxy.getElementName(xml);
		}
		
		public function get boneName():String{
			return ImportDataProxy.getElementName(boneXML);
		}
		
		public function ArmatureDataProxy()
		{
			bonesMC = new XMLListCollection();
			displaysMC = new XMLListCollection();
		}
		
		public function setData(_xml:XML):void{
			xml = _xml;
			bonesMC.removeAll();
			if(xml){
				bonesXMLList = xml.elements(ConstValues.BONE);
				bonesMC.source = getBoneList();
			}else{
				bonesXMLList = null;
				bonesMC.source = null;
			}
			
			MessageDispatcher.dispatchEvent(MessageDispatcher.CHANGE_ARMATURE_DATA);
		}
		
		public function changeBone(_boneName:String = null):void{
			boneXML = ImportDataProxy.getElementByName(bonesXMLList, _boneName);
			displaysXMLList = boneXML.elements(ConstValues.DISPLAY);
			
			displaysMC.source = displaysXMLList;
			MessageDispatcher.dispatchEvent(MessageDispatcher.CHANGE_BONE_DATA);
		}
		
		public function changeBoneDisplay(_displayName:String = null):void{
			displayXML = ImportDataProxy.getElementByName(displaysXMLList, _displayName);
			MessageDispatcher.dispatchEvent(MessageDispatcher.CHANGE_DISPLAY_DATA);
		}
		
		public function changeBoneParent(_boneXMLOnTree:XML):Boolean{
			var _name:String = ImportDataProxy.getElementName(_boneXMLOnTree);
			var _boneXML:XML = ImportDataProxy.getElementByName(bonesXMLList, _name);
			var _parentXML:XML = _boneXMLOnTree.parent();
			var _parentName:String = ImportDataProxy.getElementName(_parentXML);
			
			var _isChange:Boolean;
			if(_parentXML.name() == _boneXMLOnTree.name()){
				if(_boneXML.attribute(ConstValues.A_PARENT) != _parentName){
					_boneXML[ConstValues.AT + ConstValues.A_PARENT] = _parentName;
					_isChange = true;
				}
			}else{
				if(_boneXML.attribute(ConstValues.A_PARENT).length() > 0){
					_isChange = true;
					delete _boneXML[ConstValues.AT + ConstValues.A_PARENT];
				}
			}
			if(_isChange){
				_parentXML = ImportDataProxy.getElementByName(bonesXMLList, _parentName);
				generateBoneData(
					_name, 
					_boneXML, 
					_parentXML, 
					ImportDataProxy.getInstance().skeletonData.getArmatureData(armatureName).getData(_name)
				);
			}
			return _isChange;
		}
		
		private function getBoneList():XMLList{
			var _boneXMLList:XMLList = xml.copy().elements(ConstValues.BONE);
			var _dic:Object = {};
			var _parentXML:XML;
			var _parentName:String;
			var _boneXML:XML;
			var _length:int = _boneXMLList.length();
			for(var _i:int = _length-1;_i >= 0;_i --){
				_boneXML = _boneXMLList[_i];
				delete _boneXML[ConstValues.DISPLAY];
				_dic[_boneXML.attribute(ConstValues.A_NAME)] = _boneXML;
				_parentName = _boneXML.attribute(ConstValues.A_PARENT);
				if (_parentName){
					_parentXML = _dic[_parentName] || _boneXMLList.(attribute(ConstValues.A_NAME) == _parentName)[0];
					if (_parentXML){
						delete _boneXMLList[_i];
						_parentXML.appendChild(_boneXML);
					}
				}
			}
			return _boneXMLList;
		}
	}
}