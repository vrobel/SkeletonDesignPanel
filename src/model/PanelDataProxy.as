package model
{	
	import message.MessageDispatcher;
	
	import flash.errors.IllegalOperationError;
	
	import mx.collections.ArrayCollection;
	
	import control.ExportDataCommand;
	import utils.JSFL;
	import control.LoadFLADataCommand;
	import control.LoadFileDataCommand;
	import utils.TextureUtil;
	
	[Bindable]
	public class PanelDataProxy
	{
		private static var instance:PanelDataProxy
		public static function getInstance():PanelDataProxy{
			if(!instance){
				instance = new PanelDataProxy();
			}
			return instance;
		}
		
		private var importDataProxy:ImportDataProxy;
		
		private var isSWFSource:Boolean;
		private var isTextureChanged:Boolean;
		
		public var dataImportID:int = 0;
		public var dataImportAC:ArrayCollection = new ArrayCollection(["All library items", "Seleted items", "Exported SWF/PNG"]);
		
		public var dataExportID:int = 0;
		public var dataExportAC:ArrayCollection = new ArrayCollection(["SWF", "PNG"]);
		
		public var textureMaxWidthID:int = 2;
		public var textureMaxWidthAC:ArrayCollection = new ArrayCollection([128, 256, 512, 1024, 2048, 4096]);
		
		public var texturePadding:int = 2;
		
		public var textureSortID:int = 0;
		public var textureSortAC:ArrayCollection = new ArrayCollection(["MaxRects"]);
		
		public function PanelDataProxy()
		{
			if (instance) {
				throw new IllegalOperationError("Singleton already constructed!");
			}
			
			importDataProxy = ImportDataProxy.getInstance();
		}
		
		public function importData():void{
			switch(dataImportID){
				case 0:
					isSWFSource = false;
					LoadFLADataCommand.load(false, uint(textureMaxWidthAC.getItemAt(textureMaxWidthID)), texturePadding, importDataProxy);
					break;
				case 1:
					isSWFSource = false;
					LoadFLADataCommand.load(true, uint(textureMaxWidthAC.getItemAt(textureMaxWidthID)), texturePadding, importDataProxy);
					break;
				case 2:
					isSWFSource = true;
					control.LoadFileDataCommand.load(importDataProxy);
					break;
			}
			//isTextureChanged = false;
		}
		
		public function updateTexture():void{
			if(isSWFSource || !importDataProxy.skeletonName){
				return;
			}
			switch(textureSortID){
				case 0:
					TextureUtil.packTextures(uint(textureMaxWidthAC.getItemAt(textureMaxWidthID)), texturePadding, false, importDataProxy.textureData.xml);
					JSFL.packTextures(importDataProxy.textureData.xml);
					isTextureChanged = true;
					break;
			}
		}
		
		public function exportData():void{
			if(!importDataProxy.skeletonName){
				return;
			}
			ExportDataCommand.export(isTextureChanged);
		}
	}
}