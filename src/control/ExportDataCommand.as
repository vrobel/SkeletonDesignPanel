package control
{
	import akdcl.skeleton.objects.TextureData;
	
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import makeswfs.make;
	
	import message.MessageDispatcher;
	import message.Message;
	
	import model.ImportDataProxy;
	import model.JSFLProxy;
	
	import utils.PNGEncoder;
	
	public class ExportDataCommand
	{
		public static var instance:ExportDataCommand = new ExportDataCommand();
		
		private var fileREF:FileReference;
		private var exportType:uint;
		private var isExporting:Boolean;
		private var urlLoader:URLLoader;
		
		private var importDataProxy:ImportDataProxy;
		private var textureData:TextureData;
		private var textureBytesReload:ByteArray;
		
		public function ExportDataCommand()
		{
			fileREF = new FileReference();
			urlLoader = new URLLoader();
			
			importDataProxy = ImportDataProxy.getInstance();
			
		}
		
		public function export(_exportType:uint, _reloadFLAData:Boolean):void{
			if(isExporting){
				return;
			}
			isExporting = true;
			exportType = _exportType;
			if(textureData){
				textureData.dispose();
			}
			textureData = null;
			if(_reloadFLAData){
				MessageDispatcher.addEventListener(JSFLProxy.EXPORT_SWF, jsflProxyHandler);
				JSFLProxy.getInstance().exportSWF();
			}else{
				exportStart();
			}
		}
		
		private function jsflProxyHandler(_e:Message):void{
			MessageDispatcher.removeEventListener(JSFLProxy.EXPORT_SWF, jsflProxyHandler);
			var _result:String = _e.parameters[0];
			urlLoader.addEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.load(new URLRequest(_result));
		}
		
		private function onURLLoaderCompleteHandler(_e:Event):void{
			urlLoader.removeEventListener(Event.COMPLETE, onURLLoaderCompleteHandler);
			textureBytesReload = make(_e.target.data, importDataProxy.textureXML);
			textureData = new TextureData(importDataProxy.textureXML, textureBytesReload, true, exportStart);
		}
		
		private function exportStart():void{
			var _data:ByteArray;
			switch(exportType){
				case 0:
					_data = getExportSWF();
					if(_data){
						exportSave(_data, importDataProxy.skeletonName + ".swf");
					}else{
						isExporting = false;
						MessageDispatcher.dispatchEvent(MessageDispatcher.EXPORT_ERROR);
					}
					break;
				case 1:
					exportSave(getExportPNG(), importDataProxy.skeletonName + ".png");
					break;
			}
		}
		
		private function getExportSWF():ByteArray{
			if(textureData || importDataProxy.textureData.clip){
				return getExportByteArray(textureBytesReload || importDataProxy.textureBytes, importDataProxy.textureXML, importDataProxy.skeletonXML);
			}
			return null;
		}
		
		private function getExportPNG():ByteArray{
			var _textureData:TextureData = textureData || importDataProxy.textureData;
			if(_textureData.clip){
				return getExportByteArray(PNGEncoder.encode(_textureData.bitmap.bitmapData), importDataProxy.textureXML, importDataProxy.skeletonXML);
			}else{
				return getExportByteArray(textureBytesReload || importDataProxy.textureBytes, importDataProxy.textureXML, importDataProxy.skeletonXML);
			}
		}
		
		private function getExportByteArray(_byteArray:ByteArray, _textureXML:XML, _skeletonXML:XML):ByteArray {
			var _byteArrayCopy:ByteArray = new ByteArray();
			_byteArrayCopy.writeBytes(_byteArray);
			
			var _xmlByte:ByteArray = new ByteArray();
			_xmlByte.writeUTFBytes(_textureXML.toXMLString());
			_xmlByte.compress();
			
			_byteArrayCopy.position = _byteArrayCopy.length;
			_byteArrayCopy.writeBytes(_xmlByte);
			_byteArrayCopy.writeInt(_xmlByte.length);
			
			_xmlByte.length = 0;
			_xmlByte.writeUTFBytes(_skeletonXML.toXMLString());
			_xmlByte.compress();
			
			_byteArrayCopy.position = _byteArrayCopy.length;
			_byteArrayCopy.writeBytes(_xmlByte);
			_byteArrayCopy.writeInt(_xmlByte.length);
			
			return _byteArrayCopy;
		}
		
		private function exportSave(_data:ByteArray, _name:String):void{
			MessageDispatcher.dispatchEvent(MessageDispatcher.EXPORT, _name);
			fileREF.addEventListener(Event.CANCEL, onFileSaveHandler);
			fileREF.addEventListener(Event.COMPLETE, onFileSaveHandler);
			fileREF.save(_data, _name);
		}
		
		private function onFileSaveHandler(_e:Event):void{
			fileREF.removeEventListener(Event.CANCEL, onFileSaveHandler);
			fileREF.removeEventListener(Event.COMPLETE, onFileSaveHandler);
			isExporting = false;
			switch(_e.type){
				case Event.CANCEL:
					MessageDispatcher.dispatchEvent(MessageDispatcher.EXPORT_CANCEL);
					break;
				case Event.COMPLETE:
					importDataProxy.isTextureChanged = false;
					MessageDispatcher.dispatchEvent(MessageDispatcher.EXPORT_COMPLETE);
					break;
			}
		}
	}
}