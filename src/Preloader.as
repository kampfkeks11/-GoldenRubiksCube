package  
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.text.TextField; 

	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface; 
	
	import flash.net.FileReference;
	
	/**
	 * ...
	 * @author Ewgenij Torkin
	 */
	[SWF(backgroundColor = "#1a1a1a", width = 1038, height = 650, frameRate = "30", quality = "LOW")]
	public class Preloader extends MovieClip
	{
		private var _tf:TextField;
      
		public function Preloader() 
		{
			addEventListener(Event.ENTER_FRAME, progress);
			// show loader 
			_tf = new TextField();
			_tf.text = "LOADING... ";
			_tf.textColor = 0x766300;
			_tf.mouseEnabled = false;
			_tf.width = 200;
			_tf.x = 470;
			_tf.y = 315;
			addChild( _tf );			
		}
		  
		private function progress(e:Event):void 
		{
			var total:Number = this.stage.loaderInfo.bytesTotal;
			var loaded:Number = this.stage.loaderInfo.bytesLoaded;

			_tf.text = "LOADING... " + Math.floor((loaded / total) * 100) + "%";

			// update loader
			if (currentFrame == totalFrames)
			{
				removeEventListener(Event.ENTER_FRAME, progress);
				startup();
			}
		}
		
		private function startup():void 
		{
				_tf.visible = false;
				stop();
				var mainClass:Class = getDefinitionByName("Main") as Class;
				addChild(new mainClass() as DisplayObject);
		}   
	} 
}