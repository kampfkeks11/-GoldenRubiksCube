package userinterface.cursors {
 
	import flash.display.BitmapData;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
 
	public class CursorManager {
 
		public static const HAND_CLICK:String 				= "handClick";
		public static const HAND_OPEN:String 				= "handOpen";
		public static const HAND_CLOSED:String 				= "handClosed";
		public static const MOVE_ARROWS:String 				= "moveArrows";
		public static const MOVE_CLICKED_ARROWS:String 		= "moveClickedArrows";
		public static const CLICK_ARROW:String 				= "clickArrow";
		public static const ZOOM_IN:String 					= "zoomIn";
		public static const AUTO:String						= MouseCursor.AUTO;
 
		[Embed(source = 'embeds/hand_click.png')]		private static const CLICK:Class;
		[Embed(source = 'embeds/hand_closed.png')]		private static const CLOSED:Class;
		[Embed(source = 'embeds/hand_open.png')]		private static const OPEN:Class;
		[Embed(source = 'embeds/move.png')]				private static const MOVE:Class;
		[Embed(source = 'embeds/move_clicked.png')]		private static const MOVE_CLICKED:Class;
		[Embed(source = 'embeds/arrow.png')]			private static const CLICK_ARR:Class;
		[Embed(source = 'embeds/zoomin.png')]			private static const ZOOM_IN_CUR:Class;
 
		public function CursorManager() {
			// do not instantiate -
			// use static init() method
		}
 
		public static function init():void {
			initCursors();
		}
 
		private static function initCursors():void {
			var c1:Vector.<BitmapData> = new <BitmapData>[new OPEN().bitmapData];
			var mcd1:MouseCursorData = new MouseCursorData();
			mcd1.data = c1;
			Mouse.registerCursor(HAND_OPEN, mcd1);
 
			var c2:Vector.<BitmapData> = new <BitmapData>[new CLOSED().bitmapData];
			var mcd2:MouseCursorData = new MouseCursorData();
			mcd2.data = c2;
			Mouse.registerCursor(HAND_CLOSED, mcd2);
			
			var c3:Vector.<BitmapData> = new <BitmapData>[new MOVE().bitmapData];
			var mcd3:MouseCursorData = new MouseCursorData();
			mcd3.data = c3;
			Mouse.registerCursor(MOVE_ARROWS, mcd3);
			
			var c4:Vector.<BitmapData> = new <BitmapData>[new CLICK().bitmapData];
			var mcd4:MouseCursorData = new MouseCursorData();
			mcd4.data = c4;
			Mouse.registerCursor(HAND_CLICK, mcd4);
			
			var c5:Vector.<BitmapData> = new <BitmapData>[new CLICK_ARR().bitmapData];
			var mcd5:MouseCursorData = new MouseCursorData();
			mcd5.data = c5;
			Mouse.registerCursor(CLICK_ARROW, mcd5);
			
			var c6:Vector.<BitmapData> = new <BitmapData>[new MOVE_CLICKED().bitmapData];
			var mcd6:MouseCursorData = new MouseCursorData();
			mcd6.data = c6;
			Mouse.registerCursor(MOVE_CLICKED_ARROWS, mcd6);
			
			var c9:Vector.<BitmapData> = new <BitmapData>[new ZOOM_IN_CUR().bitmapData];
			var mcd9:MouseCursorData = new MouseCursorData();
			mcd9.data = c9;
			Mouse.registerCursor(ZOOM_IN, mcd9);
		}
	}
}