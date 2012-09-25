package control
{
	import akdcl.skeleton.objects.SkeletonAndTextureRawData;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import message.MessageDispatcher;
	
	import model.ImportDataProxy;

	public class LoadFileDataCommand
	{
		private static const FILE_FILTER_ARRAY:Array = [new FileFilter("Exported data", "*." + String(["swf", "png"]).replace(/\,/g, ";*."))];
		public static var instance:LoadFileDataCommand = new LoadFileDataCommand();
		
		private var fileREF:FileReference;
		private var urlLoader:URLLoader;
		private var isLoading:Boolean;
		
		public function LoadFileDataCommand(){
			fileREF = new FileReference();
			urlLoader = new URLLoader();
		}
		
		public function load(_url:String = null):void{
			if(isLoading){
				return;
			}
			if(_url){
				isLoading = true;
				MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_FILEDATA);
				urlLoader.addEventListener(Event.COMPLETE, onURLLoaderHandler);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onURLLoaderHandler);
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.load(new URLRequest(_url));
			}else{
				fileREF.addEventListener(Event.SELECT, onFileHaneler);
				fileREF.browse(FILE_FILTER_ARRAY);
			}
		}
	
		private function onURLLoaderHandler(_e:Event):void{
			urlLoader.removeEventListener(Event.COMPLETE, onURLLoaderHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onURLLoaderHandler);
			switch(_e.type){
				case IOErrorEvent.IO_ERROR:
					isLoading = false;
					MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_FILEDATA_ERROR);
					break;
				case Event.COMPLETE:
					setData(_e.target.data);
					break;
			}
		}
		
		private function onFileHaneler(_e:Event):void{
			switch(_e.type){
				case Event.SELECT:
					isLoading = true;
					MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_FILEDATA);
					fileREF.removeEventListener(Event.SELECT, onFileHaneler);
					fileREF.addEventListener(Event.COMPLETE, onFileHaneler);
					fileREF.load();
					break;
				case Event.COMPLETE:
					fileREF.removeEventListener(Event.COMPLETE, onFileHaneler);
					setData(fileREF.data);
					break;
			}
		}
		
		private function setData(_data:ByteArray):void{
			isLoading = false;
			var _sat:SkeletonAndTextureRawData = new SkeletonAndTextureRawData(_data);
			MessageDispatcher.dispatchEvent(MessageDispatcher.LOAD_FILEDATA_COMPLETE, _sat.skeletonXML, _sat.textureXML, _sat.textureBytes);
			_sat.dispose();
		}
	}
}