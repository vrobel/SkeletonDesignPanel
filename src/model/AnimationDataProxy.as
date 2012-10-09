package model
{
	import akdcl.skeleton.objects.AnimationData;
	import akdcl.skeleton.objects.MovementBoneData;
	import akdcl.skeleton.objects.MovementData;
	import akdcl.skeleton.utils.ConstValues;
	import akdcl.skeleton.utils.generateAnimationData;
	
	import flash.events.Event;
	
	import message.MessageDispatcher;
	
	import mx.collections.XMLListCollection;
	
	[Bindable]
	public class AnimationDataProxy
	{
		public var movementsMC:XMLListCollection;
		
		private var xml:XML;
		private var movementsXMLList:XMLList;
		
		private var movementXML:XML;
		private var movementBonesXMLList:XMLList;
		
		private var movementBoneXML:XML;
		
		public function get source():XML{
			return xml;
		}
		
		public function get animationName():String{
			return ImportDataProxy.getElementName(xml);
		}
		
		public function get movementName():String{
			return ImportDataProxy.getElementName(movementXML);
		}
		
		public function get boneName():String{
			return ImportDataProxy.getElementName(movementBoneXML);
		}
		
		public function get durationTo():int{
			if(!movementXML){
				return -1;
			}
			return int(movementXML.attribute(ConstValues.A_DURATION_TO));
		}
		public function set durationTo(_value:int):void{
			if(movementXML){
				movementXML[ConstValues.AT + ConstValues.A_DURATION_TO] = _value;
				updateMovement();
			}
		}
		
		public function get durationTween():int{
			if(movementXML?int(movementXML.attribute(ConstValues.A_DURATION)) == 1:true){
				return -1;
			}
			return int(movementXML.attribute(ConstValues.A_DURATION_TWEEN));
		}
		public function set durationTween(_value:int):void{
			if(movementXML){
				movementXML[ConstValues.AT + ConstValues.A_DURATION_TWEEN] = _value;
				updateMovement();
			}
		}
		
		public function get loop():Boolean{
			return movementXML?Boolean(int(movementXML.attribute(ConstValues.A_LOOP)) == 1):false;
		}
		public function set loop(_value:Boolean):void{
			if(movementXML){
				movementXML[ConstValues.AT + ConstValues.A_LOOP] = _value?1:0;
				updateMovement();
			}
		}
		
		public function get tweenEasing():Number{
			return movementXML?Number(movementXML.attribute(ConstValues.A_TWEEN_EASING)):0;
		}
		public function set tweenEasing(_value:Number):void{
			if(movementXML){
				movementXML[ConstValues.AT + ConstValues.A_TWEEN_EASING] = _value;
				updateMovement();
			}
		}
		
		public function get boneScale():int{
			return (movementBoneXML?Number(movementBoneXML.attribute(ConstValues.A_MOVEMENT_SCALE)):1) * 100;
		}
		public function set boneScale(_value:int):void{
			if(movementBoneXML){
				movementBoneXML[ConstValues.AT + ConstValues.A_MOVEMENT_SCALE] = _value * 0.01;
				updateMovementBone();
			}
		}
		
		public function get boneDelay():int{
			return (movementBoneXML?Number(movementBoneXML.attribute(ConstValues.A_MOVEMENT_DELAY)):0) * 100;
		}
		public function set boneDelay(_value:int):void{
			if(movementBoneXML){
				movementBoneXML[ConstValues.AT + ConstValues.A_MOVEMENT_DELAY] = _value * 0.01;
				updateMovementBone();
			}
		}
		
		public function AnimationDataProxy()
		{
			movementsMC = new XMLListCollection();
		}
		
		public function setData(_xml:XML):void{
			xml = _xml;
			if(xml){
				movementsXMLList = xml.elements(ConstValues.MOVEMENT);
			}else{
				movementsXMLList = null;
			}
			
			movementsMC.source = movementsXMLList;
			
			MessageDispatcher.dispatchEvent(MessageDispatcher.CHANGE_ANIMATION_DATA);
		}
		
		public function changeMovement(_movementName:String = null):void{
			movementXML = ImportDataProxy.getElementByName(movementsXMLList, _movementName);
			if(movementXML){
				movementBonesXMLList = movementXML.elements(ConstValues.BONE);
			}else{
				movementBonesXMLList = null;
			}
			
			MessageDispatcher.dispatchEvent(MessageDispatcher.CHANGE_MOVEMENT_DATA, ImportDataProxy.getElementName(movementXML));
		}
		
		public function changeBone(_boneName:String = null):void{
			movementBoneXML = ImportDataProxy.getElementByName(movementBonesXMLList, _boneName);
		}
		
		public function changeBoneParent(_boneName:String):void{
			generateAnimationData(
				animationName, 
				xml, 
				ImportDataProxy.getInstance().skeletonData.getArmatureData(animationName),
				ImportDataProxy.getInstance().skeletonData.getAnimationData(animationName)
			);
		}
		
		private function updateMovement():void{
			var _animationData:AnimationData = ImportDataProxy.getInstance().skeletonData.getAnimationData(animationName);
			var _movementData:MovementData = _animationData.getData(movementName);
			
			_movementData.durationTo = durationTo;
			_movementData.durationTween = durationTween;
			_movementData.loop = loop;
			_movementData.tweenEasing = tweenEasing;
			
			MessageDispatcher.dispatchEvent(MessageDispatcher.UPDATE_MOVEMENT_DATA, movementName, movementXML);
		}
		
		private function updateMovementBone():void{
			var _animationData:AnimationData = ImportDataProxy.getInstance().skeletonData.getAnimationData(animationName);
			var _movementData:MovementData = _animationData.getData(movementName);
			var _movementBoneData:MovementBoneData = _movementData.getData(boneName);
			
			_movementBoneData.scale = boneScale * 0.01;
			_movementBoneData.delay = boneDelay * 0.01;
			if(_movementBoneData.delay > 0){
				_movementBoneData.delay -= 1;
			}
			MessageDispatcher.dispatchEvent(MessageDispatcher.UPDATE_MOVEMENTBONE_DATA, movementName, movementXML);
		}
	}
}