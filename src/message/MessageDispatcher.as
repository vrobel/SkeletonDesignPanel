package message
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class MessageDispatcher extends EventDispatcher
	{
		static public const LOAD_FLADATA:String = "loadFladata";
		static public const LOAD_ARMATURE_DATA:String = "loadSkeletonData";
		static public const LOAD_ARMATURE_DATA_COMPLETE:String = "loadSkeletonDataComplete";
		static public const LOAD_TEXTURE_DATA_COMPLETE:String = "loadTextureDataComplete";
		static public const LOAD_TEXTURE_DATA:String = "loadTextureData";
		static public const LOAD_SWF:String = "loadSwf";
		static public const LOAD_SWF_COMPLETE:String = "loadSwfComplete";
		
		static public const LOAD_FILEDATA:String = "loadFiledata";
		static public const LOAD_FILEDATA_ERROR:String = "loadFiledataError";
		static public const LOAD_FILEDATA_PROGRESS:String = "loadFiledataProgress";
		static public const LOAD_FILEDATA_COMPLETE:String = "loadFiledataComplete";
		
		static public const EXPORT:String = "export";
		static public const EXPORT_CANCEL:String = "exportCancel";
		static public const EXPORT_ERROR:String = "exportError";
		static public const EXPORT_COMPLETE:String = "exportComplete";
		
		public static const CHANGE_IMPORT_DATA:String = "chagneImportData";
		public static const CHANGE_ARMATURE_DATA:String = "chagneArmatureData";
		public static const CHANGE_ANIMATION_DATA:String = "chagneAnimationData";
		public static const CHANGE_MOVEMENT_DATA:String = "chagneMovementData";
		public static const CHANGE_BONE_DATA:String = "chagneBoneData";
		public static const CHANGE_DISPLAY_DATA:String = "chagneDisplayData";
		
		public static const UPDATE_MOVEMENT_DATA:String = "updateMovementData";
		public static const UPDATE_MOVEMENTBONE_DATA:String = "updateMovementboneData";
		
		private static var instance:MessageDispatcher = new MessageDispatcher();
		
		public static function dispatchEvent(_type:String, ...args):void{
			var _event:Message = new Message(_type);
			_event.parameters = args;
			instance.dispatchEvent(_event);
		}
		
		public static function addEventListener(_type:String, _listener:Function):void{
			instance.addEventListener(_type, _listener);
		}
		
		public static function removeEventListener(_type:String, _listener:Function):void{
			instance.removeEventListener(_type, _listener);
		}
		
		public function MessageDispatcher()
		{
			super(this);
		}
	}
}