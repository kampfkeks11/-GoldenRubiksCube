 /*
 * Copyright (C) 2015 
 * Ewgenij Torkin 
 * ewgenij.torkin@gmail.com
 * www.goldenrubikscube.com
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

package 
{
	import away3d.entities.Sprite3D;
	import away3d.materials.MaterialBase;
	import away3d.primitives.PlaneGeometry;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.external.ExternalInterface;
	
	import away3d.containers.View3D;
	import away3d.textures.BitmapTexture;
	import away3d.controllers.HoverController;
	import away3d.events.MouseEvent3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.ColorMaterial;
	import flash.display.BitmapData;
	
	import userinterface.cursors.CursorManager;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;

	/*
	 * @author Ewgenij Torkin
	 */
	
	[SWF(backgroundColor = "#1a1a1a", width = 1038, height = 650, frameRate = "30", quality = "LOW")]
	public class Main extends Sprite 
	{
		//3DEngine variables
		public static var stageRef:Object;
		public static var _view:View3D;
		private var _cameraController:HoverController;
		
		public static var rubik:Rubik;
		
		//navigation variables
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		public static var move:Boolean = false;
		
		public static var initRot:Boolean = false;	
		
		[Embed(source="/../embeds/bg.jpg")] private var kosmosTextureImage:Class;
		private var _kosmosBgBitmap:Bitmap = new kosmosTextureImage();
		public static var _kosmosBg:Mesh;
		
		public function Main():void 
		{
			if (stage) 
			{
				init();
			}
			else 
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}

		private function init(e:Event = null):void 
		{
			stage.color = 0x1a1a1a;
			stageRef = stage;
			
			removeEventListener(Event.ADDED_TO_STAGE, init);

			CursorManager.init();
			
			initAway3D();
			
			var kosmosBitmapTex:BitmapTexture = new BitmapTexture(_kosmosBgBitmap.bitmapData);
			var kosmosTexMat:TextureMaterial = new TextureMaterial(kosmosBitmapTex);
			_kosmosBg = new Mesh(new PlaneGeometry(1024, 1024), kosmosTexMat);
			
			_kosmosBg.rotationX = 90;
			_kosmosBg.rotationZ = 180;
			_kosmosBg.z = -700;
			_kosmosBg.scale(1.7);
			
			rubik = new Rubik();
	
			addEventListeners();
		}
		
		public static function lookAtCubie(id:int, animated: Boolean):void
		{
			if (rubik) 
			{
				rubik.lookAtCubie(id, animated);
			}
		}

		public static function selectCubie(id:int):void
		{
			if (rubik)
			{
				rubik.sectionAutoRotationTimer.stop();
				initRot = false;	
				rubik.selectCubie(id - 1);
			}
		}
		
		public static function deselectCubie():void
		{
			rubik.deselectCubie();
		}	
		
		private function initAway3D():void
		{						
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			//setup view
			_view = new View3D();
			_view.antiAlias = 10;
			_view.width = 1038;
			_view.height = 650;
			_view.camera.lens.near = 5;
			_view.camera.lens.far = 3000;
			_view.backgroundColor = 0x1a1a1a;
			stage.addChild(_view);
			
			_view.forceMouseMove = true;

			//setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 0, 0, 16);
		}
		
		public static function addObjects():void
		{	
			_view.backgroundColor = 0x000;
			
			_view.scene.addChild(rubik);
			
			_view.scene.addChild(_kosmosBg);
			
			initRot = true;
		}

		private function addEventListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_kosmosBg.mouseEnabled = true;
			_kosmosBg.addEventListener(MouseEvent3D.MOUSE_DOWN, mouseDownHandler);
			_kosmosBg.addEventListener(MouseEvent3D.MOUSE_UP,   mouseUpHandler);
			_kosmosBg.addEventListener(MouseEvent3D.MOUSE_OVER, mouseOverHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,       stageMouseMoveHandler);
			stage.addEventListener(Event.MOUSE_LEAVE,       stageMouseLeaveHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,      onKeyDown);
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch(event.keyCode) {
					
				case Keyboard.NUMBER_1: lookAtCubie(0, true); break;											
				case Keyboard.NUMBER_2: lookAtCubie(1, true); break;											
				case Keyboard.NUMBER_3: lookAtCubie(2, true); break;											
				case Keyboard.NUMBER_4: lookAtCubie(3, true); break;											
				case Keyboard.NUMBER_5: lookAtCubie(4, true); break;											
				case Keyboard.NUMBER_6: lookAtCubie(5, true); break;	
				
				case Keyboard.Q: lookAtCubie(6, true); break;											
				case Keyboard.W: lookAtCubie(7, true); break;											
				case Keyboard.E: lookAtCubie(8, true); break;											
				case Keyboard.R: lookAtCubie(9, true); break;											
				case Keyboard.T: lookAtCubie(10, true); break;											
				case Keyboard.Z: lookAtCubie(11, true); break;
			}
		}
		
		private function mouseDownHandler(event:MouseEvent3D):void
		{
			if (rubik) rubik.deselectCubie();
			
			rubik.sectionAutoRotationTimer.stop();
			
			_lastMouseX = stage.mouseX;
			_lastMouseY = stage.mouseY;
			
			Mouse.cursor = CursorManager.MOVE_CLICKED_ARROWS;
			
			move = true;
			
			initRot = false;
		}
		
		private function mouseUpHandler(event:MouseEvent3D):void
		{
			Mouse.cursor = CursorManager.MOVE_ARROWS;
			
			move = false;
		}
		
		private function mouseOverHandler(event:MouseEvent3D):void
		{
			Mouse.cursor = CursorManager.MOVE_ARROWS;
		}

		private function stageMouseMoveHandler(event:MouseEvent):void
		{
			if (move)
			{
				if (rubik.inMotion) rubik.cancelRubikRotation();
				
				var transform:Matrix3D = rubik.transform;
				
				transform.appendRotation((stage.mouseY - _lastMouseY) / 5, new Vector3D(1, 0, 0));	
				transform.appendRotation( -(stage.mouseX - _lastMouseX) / 5, new Vector3D(0, 1, 0));

				rubik.transform = transform;
				
				_lastMouseY = stage.mouseY;
				_lastMouseX = stage.mouseX;
			}
		}
		
		private function stageMouseLeaveHandler(event:Event):void
		{
			Mouse.cursor = CursorManager.MOVE_ARROWS;
			
			move = false;
		}

		private function onEnterFrame(event:Event):void
		{		
			if (initRot)
			{
				rubik.pitch(1);
				rubik.yaw(1);			
			}

			_view.render();
		}
	}
}

import flash.display.BitmapData;
import flash.display3D.textures.RectangleTexture;
import flash.geom.ColorTransform;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.Event;
import flash.utils.ByteArray;
import tools.PNGEncoder;

import away3d.containers.ObjectContainer3D;
import away3d.materials.ColorMaterial;
import away3d.textures.BitmapCubeTexture;
import away3d.materials.methods.FresnelEnvMapMethod;
import away3d.utils.Cast;
import away3d.loaders.parsers.OBJParser;
import away3d.library.AssetLibrary;
import away3d.library.assets.AssetType;
import away3d.events.AssetEvent;
import away3d.entities.Mesh;
import away3d.events.MouseEvent3D;

import flash.system.Security;

import tools.fzip.FZip;
import tools.fzip.FZipFile;

class Rubik extends ObjectContainer3D
{		
	//3D models
	private var _cube1:Mesh;
	private var _cube2:Mesh;
	private var _plane2_1:Mesh;
	private var _plane2_2:Mesh;
	
	//Cubies
	private var _cubies:Vector.<Cubie>;
	public var selCubie:Object;
	
	private var _infoTool:InfoTool;
	
	//Automatic rotation
	public var sectionAutoRotationTimer:Timer = new Timer(1000);;
	private var _axis:int;
	private var _dir:int;
	private var _secRotCount:Number = 0;
	private var _temp:Vector.<Cubie>;
	private var _sectionInMotion:Boolean = false;
	private var _secRot:Sprite = new Sprite();
	private var _interpolateSectionTo:Matrix3D = new Matrix3D();

	private var _interpolateRubikTo:Matrix3D = new Matrix3D();
	private var _cubieToLookAt:int = -1;
	private var _rubRot:Sprite = new Sprite();
	private var _rubikInMotion:Boolean = false;
	private var _rubRotCount:int = 0;
	
	private var _soldPixelBlocks:int = 0;
	private var _soldPixelBlocksCount:int = 0;

	[Embed(source="/../embeds/cube.obj", mimeType="application/octet-stream")]
	private static var cubeModels:Class;
	
	[Embed(source="/../embeds/skybox/cube_front.jpg")]
	private static var PosX:Class;
	[Embed(source="/../embeds/skybox/cube_back.jpg")]
	private static var NegX:Class;
	[Embed(source="/../embeds/skybox/cube_top.jpg")]
	private static var PosY:Class;
	[Embed(source="/../embeds/skybox/cube_bottom.jpg")]
	private static var NegY:Class;
	[Embed(source="/../embeds/skybox/cube_left.jpg")]
	private static var PosZ:Class;
	[Embed(source="/../embeds/skybox/cube_right.jpg")]
	private static var NegZ:Class;
	
	[Embed(source="../data/init.zip", mimeType="application/octet-stream")]
	private static var init_zip:Class;

	private var _reflectiveMaterial: ColorMaterial;

	public function Rubik()
	{	
		Security.allowInsecureDomain("*");
		Security.allowDomain("*");

		initMaterial();
		loadObj();
	}

	/**
	 * Initialise the material
	 */
	private function initMaterial():void
	{
		//setup the skybox texture
		var skyboxTexture:BitmapCubeTexture = new BitmapCubeTexture(
			Cast.bitmapData(PosX), Cast.bitmapData(NegX),
			Cast.bitmapData(PosY), Cast.bitmapData(NegY),
			Cast.bitmapData(PosZ), Cast.bitmapData(NegZ)
		);
		
		// setup fresnel method using our reflective texture in the place of a static environment map
		var fresnelMethod:FresnelEnvMapMethod = new FresnelEnvMapMethod(skyboxTexture);
		fresnelMethod.normalReflectance = 1.1;
		fresnelMethod.fresnelPower = 5;
		
		//setup the reflective material
		_reflectiveMaterial = new ColorMaterial();
		_reflectiveMaterial.addMethod(fresnelMethod);
	}
	
	private function loadObj():void
	{
		AssetLibrary.enableParser(OBJParser);
		
		// load model data			
		AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
		AssetLibrary.loadData(new cubeModels());
	}	
	
   /*
	* Listener function for asset complete event on loader
	*/
	private function onAssetComplete(event:AssetEvent):void
	{	
		if (event.asset.assetType == AssetType.MESH) 
		{
			var scale:Number = 1.1;
			
			switch(event.asset.name)
			{
				case "cube1":
					_cube1 = event.asset as Mesh;
					_cube1.material = _reflectiveMaterial;
					_cube1.scale(scale);
					break;
				case "cube2":
					_cube2 = event.asset as Mesh;
					_cube2.material = _reflectiveMaterial;
					_cube2.scale(scale);
					break;
				case "plane2_1":
					_plane2_1 = event.asset as Mesh;
					_plane2_1.scale(scale);
					break;
				case "plane2_2":
					_plane2_2 = event.asset as Mesh;
					_plane2_2.scale(scale);
					break;
			}
		}

		if (_cube1 && _cube2 && _plane2_1 && _plane2_2)
		{
			generateRubik();

			sectionAutoRotationTimer.addEventListener(TimerEvent.TIMER, startSectionRotation);
			sectionAutoRotationTimer.start();
		}
	}
	
	private function generateRubik():void
	{
		var dist:Number = 3;
		
		var rotations:Array = new Array([ 90,   0,   0],[ 0, -90,   0],[  0,   0, 0],[-90, 0,   0],
										[  0, -90,  90],[ 0,   0,  90],[-90, -90, 0],[  0, 0, -90],
										[ 90,   0,  90],[ 0, 180,   0],[  0,  90, 0],[-90, 0, -90]);								
		
		var id:int = 0;
		
		_cubies = new Vector.<Cubie>();
		
		for (var x:int = -1; x < 2; x++ )	
		{
			for (var y:int = -1; y < 2; y++ )
			{
				for (var z:int = -1; z < 2; z++ )
				{												
					if (!(x==0 && y==0 && z==0))
					{	
						var cubeIndex:int = 0;
						
						if (x == -1) cubeIndex++;								
						if (x ==  1) cubeIndex++;
						if (y == -1) cubeIndex++;
						if (y ==  1) cubeIndex++;															
						if (z == -1) cubeIndex++;
						if (z ==  1) cubeIndex++;	

						var cubie:Cubie = new Cubie();										
						
						var body:Mesh;
						
						switch(cubeIndex)
						{
							case 1:
								
								cubie.extra = new Array(-1, x, y, z);
								
								body = _cube1.clone() as Mesh;
								body.mouseEnabled = true;

							break;
								
							case 2:
							
								cubie.extra = new Array(id, x, y, z);
								
								body = _cube2.clone() as Mesh;

								var planeLeft:Mesh = _plane2_1.clone() as Mesh;
								var planeRight:Mesh = _plane2_2.clone() as Mesh;

								cubie.rotationX = rotations[id][0];
								cubie.rotationY = rotations[id][1];
								cubie.rotationZ = rotations[id][2];
								
								id++;

								cubie.addFace(planeLeft); // Index 0
								cubie.addFace(planeRight);// Index 1														
								
								_cubies.push(cubie);
				
							break;
								
							case 3:
							
								cubie.extra = new Array(-1, x, y, z);
								
								body = _cube1.clone() as Mesh;
								body.mouseEnabled = true;
								
							break;
						}
						
						cubie.x = x * dist;
						cubie.y = y * dist;
						cubie.z = z * dist;

						cubie.addChild(body);

						addChild(cubie);	
					}
				}
			}
		}						
		
		_cube1 = _cube2 = _plane2_1 = _plane2_2 = null;

		var ba:ByteArray = ByteArray(new init_zip());
		var zip:FZip = new FZip(); 
		zip.addEventListener(Event.COMPLETE, onInitZipLoadComplete);
		zip.loadBytes(ba);
		
		// OR
		
		//var zip:FZip = new FZip();
		//zip.addEventListener(Event.COMPLETE, onInitZipLoadComplete);
		//zip.load(new URLRequest("http://localhost:8383/public/data/init.zip"));

		_infoTool = new InfoTool();
		Main.stageRef.addChild(_infoTool);
		
		Main.addObjects();
	}
	
	private function onInitZipLoadComplete(evt:Event):void 
	{	
		var dataStr:String;

		dataStr = evt.target.getFileAt(0).getContentAsString(false);
		
		loadPixelBlocksFromZip(dataStr);
	}
	
	private function loadPixelBlocksFromZip(dataStr:String):void
	{
		var pixelBlocks:Object = JSON.parse(dataStr).results;

		for (var obj:Object in pixelBlocks)
		{	
			_cubies[pixelBlocks[obj].c].faces[pixelBlocks[obj].f].plane.addPixelBlock(pixelBlocks[obj]);
		}
	
		for (var c:int = 0, cl:int = _cubies.length; c < cl; c++ )
		{
			_cubies[c].faces[0].plane.genFreePixelBlocks();
			_cubies[c].faces[1].plane.genFreePixelBlocks();
		}

		Main.addObjects();	
	}
	
	public function selectCubie(id:int):void
	{
		_cubies[id].showPlanes();
		
		if (selCubie) 
		{
			selCubie.hidePlanes();			
		}
		
		selCubie = _cubies[id];
	}
	
	public function lookAtCubie(id:int, animated:Boolean):void
	{
		if (_rubikInMotion) cancelRubikRotation();
		
		if (_sectionInMotion)
		{
			_cubieToLookAt = id;
			return;
		}
				
		Main.initRot = false;
		sectionAutoRotationTimer.stop();
		
		_interpolateRubikTo.identity();
				
		var forwardVector:Vector3D = new Vector3D(_cubies[id].x, _cubies[id].y, _cubies[id].z);
		var destVector:Vector3D = new Vector3D(0, 0, 1);

		_interpolateRubikTo.appendRotation(Vector3D.angleBetween(forwardVector, destVector) * 180 / Math.PI, crossProduct(forwardVector, destVector));		

		var rubikY:Vector3D = _interpolateRubikTo.transformVector(_cubies[id].transform.deltaTransformVector(new Vector3D(0, 1, 0)));
		
		rubikY.x = Math.round(rubikY.x);
		rubikY.y = Math.round(rubikY.y);
		rubikY.z = Math.round(rubikY.z);
		
		var crossPr:Vector3D = crossProduct(rubikY, new Vector3D(0, 1, 0));
		
		crossPr.x = Math.round(crossPr.x);
		crossPr.y = Math.round(crossPr.y);
		crossPr.z = Math.round(crossPr.z);
		
		if (rubikY.x == 0 && rubikY.y == -1 && rubikY.z == 0)
		{
			_interpolateRubikTo.appendRotation(Math.round(Vector3D.angleBetween(new Vector3D(0, 1, 0), rubikY) * 180 / Math.PI), new Vector3D(0, 0, 1));
		}
		else
		{
			_interpolateRubikTo.appendRotation(crossPr.z * Math.round(Vector3D.angleBetween(new Vector3D(0, 1, 0), rubikY) * 180 / Math.PI), new Vector3D(0, 0, 1));
		}
			
		if(animated)
		{
			_rubikInMotion = true;
			
			_rubRot.addEventListener(Event.ENTER_FRAME, rubikRotationStep);
		}
		else
		{
			transform = _interpolateRubikTo;
		}
	}
	
	public function cancelRubikRotation():void
	{
		_rubRot.removeEventListener(Event.ENTER_FRAME, rubikRotationStep);
		_rubRotCount = 0;
		_rubikInMotion = false;
	}
	
	private function rubikRotationStep(event:Event):void
	{		
		transform = Matrix3D.interpolate(transform, _interpolateRubikTo, (_rubRotCount + 1) * 0.05);

		_rubRotCount++;
		
		if (_rubRotCount > 20)
		{
			_rubRot.removeEventListener(Event.ENTER_FRAME, rubikRotationStep);
			_rubRotCount = 0;
			_rubikInMotion = false;
		}
	}
	
	public function crossProduct(v1:Vector3D, v2:Vector3D):Vector3D
	{
		var result:Vector3D = new Vector3D();
		
		result.x = (v1.y * v2.z - v1.z * v2.y);
		result.y = (v1.z * v2.x - v1.x * v2.z);
		result.z = (v1.x * v2.y - v1.y * v2.x);	
		
		return result;
	}
	
	public function deselectCubie():void
	{
		if (selCubie) 
		{
			selCubie.hidePlanes();
			selCubie = null;
		}
	}
	
	public function addFaceEventListeners():void
	{
		for (var i:int = 0, l:int = _cubies.length; i < l; i++ )
		{
			if (_cubies[i].faces)
			{
				_cubies[i].faces[0].addEventListeners();
				_cubies[i].faces[1].addEventListeners();
			}
		}
	}
	
	public function removeFaceEventListeners():void
	{
		for (var i:int = 0, l:int = _cubies.length; i < l; i++ )
		{
			if (_cubies[i].faces)
			{
				_cubies[i].faces[0].removeEventListeners();
				_cubies[i].faces[1].removeEventListeners();
			}
		}
	}
	
	private function startSectionRotation(event:TimerEvent):void
	{
		var axis:int = Math.random()*2.99 >> 0; 			
		var dir:int = (Math.round(Math.random()) == 0)? -1 : 1;	
		var layer:int = (Math.random() * 2.99 >> 0) - 1;		
		
		sectionRotation(axis, dir, layer);	
	}
	
	private function sectionRotation(axis:int, dir:int, layer:int):void
	{
		if (_sectionInMotion) return;
		
		_sectionInMotion = true;

		_axis = axis; _dir = dir;
		
		_temp = new Vector.<Cubie>();
		
		for(var i:int = 0, nc:int = numChildren; i < nc; i++)
		{
			if(getChildAt(i).extra[_axis + 1] == layer)
			{
				updateLocation(getChildAt(i), _axis, _dir);
				
				_temp.push(getChildAt(i));
			}
		}
		
		_secRot.addEventListener(Event.ENTER_FRAME, sectionRotationStep);
	}
	
	private function sectionRotationStep(event:Event):void
	{
		for(var i:int=0, l:int = _temp.length; i<l; i++)
		{
			var tempTransform:Matrix3D = _temp[i].transform.clone();
			
			switch(_axis)
			{
				case 0:
					tempTransform.appendRotation(_dir * Math.cos(_secRotCount) * 8.6, new Vector3D(1, 0, 0));
					_temp[i].transform = tempTransform;
					break;
				case 1:
					tempTransform.appendRotation(_dir * Math.cos(_secRotCount) * 8.6, new Vector3D(0, 1, 0));
					_temp[i].transform = tempTransform;
					break;
				case 2:
					tempTransform.appendRotation(_dir * Math.cos(_secRotCount) * 8.6, new Vector3D(0, 0, 1));
					_temp[i].transform = tempTransform;
					break;
			}
		}
		
		_secRotCount += 0.1;
		
		if (_secRotCount > Math.PI/2)
		{
			_secRot.removeEventListener(Event.ENTER_FRAME, sectionRotationStep);
			_secRotCount = 0;
			roundOffRotation();
			
			if (_cubieToLookAt != -1)
			{
				sectionAutoRotationTimer.stop();
				lookAtCubie(_cubieToLookAt, true);
			}
		}
	}
	
	public function roundOffRotation():void
	{
		if(!_sectionInMotion) return;
		
		for(var i:int=0, l:int = _temp.length; i<l; i++)
		{
			var m:Matrix3D = new Matrix3D(new <Number>[
				Math.round(_temp[i].transform.rawData[0]),  Math.round(_temp[i].transform.rawData[1]),  Math.round(_temp[i].transform.rawData[2]),  Math.round(_temp[i].transform.rawData[3]),
				Math.round(_temp[i].transform.rawData[4]),  Math.round(_temp[i].transform.rawData[5]),  Math.round(_temp[i].transform.rawData[6]),  Math.round(_temp[i].transform.rawData[7]),
				Math.round(_temp[i].transform.rawData[8]),  Math.round(_temp[i].transform.rawData[9]),  Math.round(_temp[i].transform.rawData[10]), Math.round(_temp[i].transform.rawData[11]),
				Math.round(_temp[i].transform.rawData[12]), Math.round(_temp[i].transform.rawData[13]), Math.round(_temp[i].transform.rawData[14]), Math.round(_temp[i].transform.rawData[15])
			]);
			
			_temp[i].transform = m;
		}

		_sectionInMotion = false;
	}
	
	public function updateLocation(cubie:ObjectContainer3D, axis:int, dir:int):void
	{
		var loc:Vector3D = new Vector3D();
		loc.x = cubie.extra[1];
		loc.y = cubie.extra[2];
		loc.z = cubie.extra[3];
		
		switch(axis)
		{
			case 0:
				cubie.extra[1] = loc.x;
				cubie.extra[2] = -1*dir*loc.z;
				cubie.extra[3] = dir*loc.y;
				break;
			case 1:
				cubie.extra[1] = dir*loc.z;
				cubie.extra[2] = loc.y;
				cubie.extra[3] = -1*dir*loc.x;
				break;
			case 2:
				cubie.extra[1] = -1*dir*loc.y;
				cubie.extra[2] = dir*loc.x;
				cubie.extra[3] = loc.z;
				break;
		}
	}
	
	public function get inMotion():Boolean{ return _rubikInMotion; }
	public function get infoTool():InfoTool{ return _infoTool; }
}

class Cubie extends ObjectContainer3D
{	
	private var _faces:Vector.<Face>;

	public function addFace(mesh:Mesh):void
	{
		if (!_faces) _faces = new Vector.<Face>();
		
		var face:Face = new Face(_faces.length, mesh);
		
		_faces.push(face);
		addChild(face);
	}
	
	public function showPlanes():void
	{
		if (_faces) 
		{
			_faces[0].showPlane();
			_faces[1].showPlane();
		}
	}
	
	public function hidePlanes():void
	{
		if (_faces) 
		{
			_faces[0].hidePlane();
			_faces[1].hidePlane();
		}
	}

	public function get faces():Vector.<Face>{ return _faces; }
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.ui.Mouse;
import flash.events.MouseEvent;
import away3d.textures.BitmapTexture;
import away3d.materials.TextureMaterial;
import userinterface.cursors.CursorManager;

class Face extends ObjectContainer3D
{
	[Embed(source="/../embeds/planeLeft.png")] private static var leftTextureImage:Class;
	private var bitmapLeft:Bitmap = new leftTextureImage();
	
	[Embed(source="/../embeds/planeRight.png")] private static var rightTextureImage:Class;
	private var bitmapRight:Bitmap = new rightTextureImage();

	private var _id:int;
	private var _mesh:Mesh;
	private var _plane:Plane;

	public function Face(id:int, mesh:Mesh)
	{		
		_id = id;
		
		var bitmapTex:BitmapTexture;
		var texMat:TextureMaterial;
		
		switch(_id)
		{
			case 0:
				bitmapTex = new BitmapTexture(bitmapLeft.bitmapData);
				texMat = new TextureMaterial(bitmapTex);
				break;
			case 1: 
				bitmapTex = new BitmapTexture(bitmapRight.bitmapData);
				texMat = new TextureMaterial(bitmapTex);
				break;
		}
		
		_plane = new Plane(this, bitmapTex);
		
		_mesh = mesh;

		_mesh.material = texMat;

		addChild(_mesh);
		
		addEventListeners();
	}

	public function addEventListeners():void
	{
		_mesh.addEventListener(MouseEvent3D.MOUSE_DOWN,  mouseDownHandler);
		_mesh.addEventListener(MouseEvent3D.MOUSE_UP,    mouseUpHandler);
		_mesh.addEventListener(MouseEvent3D.MOUSE_OVER,  mouseOverHandler);
		_mesh.addEventListener(MouseEvent3D.MOUSE_OUT,   mouseOutHandler);
		_mesh.mouseEnabled = true;
	}
	
	public function removeEventListeners():void
	{
		_mesh.removeEventListener(MouseEvent3D.MOUSE_DOWN,  mouseDownHandler);
		_mesh.removeEventListener(MouseEvent3D.MOUSE_UP,    mouseUpHandler);
		_mesh.removeEventListener(MouseEvent3D.MOUSE_OVER,  mouseOverHandler);
		_mesh.removeEventListener(MouseEvent3D.MOUSE_OUT,   mouseOutHandler);
		_mesh.mouseEnabled = false;
	}
	
	public function showPlane():void
	{
		_plane.show();
	}
	
	public function hidePlane():void
	{
		_plane.hide();
		
		var rubik:Object = parent.parent;
		rubik.addFaceEventListeners();
	}

	private function mouseDownHandler(event:MouseEvent3D):void
	{
		var cubie:Object = parent as Object;
		var rubik:Object = cubie.parent;
		
		rubik.sectionAutoRotationTimer.stop();
		Main.initRot = false;
		
		rubik.selectCubie(cubie.extra[0]);

		Mouse.cursor = CursorManager.AUTO;
	}
	
	private function mouseUpHandler(event:MouseEvent3D):void
	{
		Main.move = false;
		Mouse.cursor = CursorManager.ZOOM_IN;
	}
	
	private function mouseOverHandler(event:MouseEvent3D):void
	{
		if (!Main.move) Mouse.cursor = CursorManager.ZOOM_IN;
	}
	
	private function mouseOutHandler(event:MouseEvent3D):void
	{
		if (!Main.move && !_plane.isActive) Mouse.cursor = CursorManager.MOVE_ARROWS;
	}
	
	public function get plane():Plane
	{
		return _plane;
	}
	
	public function get Id():int
	{
		return _id;
	}
}

import flash.geom.Point;
import flash.display.PNGEncoderOptions;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;
import tools.fzip.FZipEvent;
import tools.BulkLoader;
import tools.BulkProgressEvent;

class Plane extends Sprite
{
	private var _face:Face;
	private var _mouseOverPixelBlock:PixelBlock;
	private var _bitmapTex:BitmapTexture;
	private var _active:Boolean = false;
	private var _selTool:SelectionTool;
	private var _pixelBlocksGrid:Array = new Array( 50 );
	private var _soldPixelBlocks:Array = new Array();
	private var _filesLoaded:Boolean = false;
	
	
	[Embed(source = "../data/c0_f0.zip", mimeType = "application/octet-stream")]
	private static var c0_f0_zip:Class;
	[Embed(source="../data/c0_f1.zip", mimeType="application/octet-stream")]
	private static var c0_f1_zip:Class;
	[Embed(source="../data/c1_f0.zip", mimeType="application/octet-stream")]
	private static var c1_f0_zip:Class;
	[Embed(source="../data/c1_f1.zip", mimeType="application/octet-stream")]
	private static var c1_f1_zip:Class;
	[Embed(source="../data/c2_f0.zip", mimeType="application/octet-stream")]
	private static var c2_f0_zip:Class;
	[Embed(source="../data/c2_f1.zip", mimeType="application/octet-stream")]
	private static var c2_f1_zip:Class;
	[Embed(source="../data/c3_f0.zip", mimeType="application/octet-stream")]
	private static var c3_f0_zip:Class;
	[Embed(source="../data/c3_f1.zip", mimeType="application/octet-stream")]
	private static var c3_f1_zip:Class;
	[Embed(source="../data/c4_f0.zip", mimeType="application/octet-stream")]
	private static var c4_f0_zip:Class;
	[Embed(source="../data/c4_f1.zip", mimeType="application/octet-stream")]
	private static var c4_f1_zip:Class;
	[Embed(source="../data/c5_f0.zip", mimeType="application/octet-stream")]
	private static var c5_f0_zip:Class;
	[Embed(source="../data/c5_f1.zip", mimeType="application/octet-stream")]
	private static var c5_f1_zip:Class;
	[Embed(source="../data/c6_f0.zip", mimeType="application/octet-stream")]
	private static var c6_f0_zip:Class;
	[Embed(source="../data/c6_f1.zip", mimeType="application/octet-stream")]
	private static var c6_f1_zip:Class;
	[Embed(source="../data/c7_f0.zip", mimeType="application/octet-stream")]
	private static var c7_f0_zip:Class;
	[Embed(source="../data/c7_f1.zip", mimeType="application/octet-stream")]
	private static var c7_f1_zip:Class;
	[Embed(source="../data/c8_f0.zip", mimeType="application/octet-stream")]
	private static var c8_f0_zip:Class;
	[Embed(source="../data/c8_f1.zip", mimeType="application/octet-stream")]
	private static var c8_f1_zip:Class;
	[Embed(source="../data/c9_f0.zip", mimeType="application/octet-stream")]
	private static var c9_f0_zip:Class;
	[Embed(source="../data/c9_f1.zip", mimeType="application/octet-stream")]
	private static var c9_f1_zip:Class;
	[Embed(source="../data/c10_f0.zip", mimeType="application/octet-stream")]
	private static var c10_f0_zip:Class;
	[Embed(source="../data/c10_f1.zip", mimeType="application/octet-stream")]
	private static var c10_f1_zip:Class;
	[Embed(source="../data/c11_f0.zip", mimeType="application/octet-stream")]
	private static var c11_f0_zip:Class;
	[Embed(source="../data/c11_f1.zip", mimeType="application/octet-stream")]
	private static var c11_f1_zip:Class;

	public function Plane(face:Face, bitmapTex:BitmapTexture)
	{
		_face = face;
		_selTool = new SelectionTool(this);

		_bitmapTex = bitmapTex;
		
		this.graphics.beginBitmapFill(_bitmapTex.bitmapData);
		this.graphics.drawRect(0, 0, _bitmapTex.bitmapData.width, _bitmapTex.bitmapData.height);
		this.graphics.endFill();
		
		switch(_face.Id)
		{
			case 0:
				this.x = 10;
				this.y = 69;
				break;
			case 1: 
				this.x = 516;
				this.y = 69;
				break;
		}
		
		this.visible = false;
		
		buttonMode = true;
		
		Main.stageRef.addChild(this);
		
		for (var row:int = 0; row < 50; row++ )
		{
			_pixelBlocksGrid[row] = new Array( 50 );
		}
	}
	
	public function addPixelBlock(pixelBlockObj:Object):void
	{
		var pixelBlock:PixelBlock = new PixelBlock(this, _selTool, _bitmapTex, false, pixelBlockObj.x*10, pixelBlockObj.y*10, pixelBlockObj.dx, pixelBlockObj.dy, pixelBlockObj.i, pixelBlockObj.l);
		
		for (var y:int = 0, cond1:int = pixelBlockObj.dy / 10; y < cond1; y++ )
		{
			for (var x:int = 0, cond2:int = pixelBlockObj.dx / 10; x < cond2; x++ )
			{
				_pixelBlocksGrid[int(pixelBlockObj.y + y)][int(pixelBlockObj.x + x)] = pixelBlock;
			}
		}
		
		_soldPixelBlocks.push(pixelBlock);
	}
	
	public function genFreePixelBlocks():void
	{
		for (var row:int = 0; row < 50; row++ )
		{
			for (var column:int = 0; column < 50; column++ )
			{
				if (_pixelBlocksGrid[row][column] == null)
				{
					_pixelBlocksGrid[row][column] = new PixelBlock(this, _selTool, _bitmapTex, true, column * 10, row * 10, 10, 10);
				}
			}
		}
	}
	
	public function startLoadingImagesFromZip():void
	{
		var zipName:String = "c" + (_face.parent as Object).extra[0] + "_f" + _face.Id;
		
		var ba:ByteArray;
		
		switch(zipName)
		{
			case "c0_f0":
				ba = ByteArray(new c0_f0_zip());
				break;
			case "c0_f1":
				ba = ByteArray(new c0_f1_zip());
				break;
			case "c1_f0":
				ba = ByteArray(new c1_f0_zip());
				break;
			case "c1_f1":
				ba = ByteArray(new c1_f1_zip());
				break;
			case "c2_f0":
				ba = ByteArray(new c2_f0_zip());
				break;
			case "c2_f1":
				ba = ByteArray(new c2_f1_zip());
				break;
			case "c3_f0":
				ba = ByteArray(new c3_f0_zip());
				break;
			case "c3_f1":
				ba = ByteArray(new c3_f1_zip());
				break;
			case "c4_f0":
				ba = ByteArray(new c4_f0_zip());
				break;
			case "c4_f1":
				ba = ByteArray(new c4_f1_zip());
				break;
			case "c5_f0":
				ba = ByteArray(new c5_f0_zip());
				break;
			case "c5_f1":
				ba = ByteArray(new c5_f1_zip());
				break;
			case "c6_f0":
				ba = ByteArray(new c6_f0_zip());
				break;
			case "c6_f1":
				ba = ByteArray(new c6_f1_zip());
				break;
			case "c7_f0":
				ba = ByteArray(new c7_f0_zip());
				break;
			case "c7_f1":
				ba = ByteArray(new c7_f1_zip());
				break;
			case "c8_f0":
				ba = ByteArray(new c8_f0_zip());
				break;
			case "c8_f1":
				ba = ByteArray(new c8_f1_zip());
				break;
			case "c9_f0":
				ba = ByteArray(new c9_f0_zip());
				break;
			case "c9_f1":
				ba = ByteArray(new c9_f1_zip());
				break;
			case "c10_f0":
				ba = ByteArray(new c10_f0_zip());
				break;
			case "c10_f1":
				ba = ByteArray(new c10_f1_zip());
				break;
			case "c11_f0":
				ba = ByteArray(new c11_f0_zip());
				break;
			case "c11_f1":
				ba = ByteArray(new c11_f1_zip());
				break;
		}
		
		var zip:FZip = new FZip(); 
		zip.addEventListener(FZipEvent.FILE_LOADED, onZipFileLoaded, false, 1, true);
		zip.loadBytes(ba);
		
		// OR
		
		/*
		var zip:FZip = new FZip();
		zip.addEventListener(FZipEvent.FILE_LOADED, onZipFileLoaded, false, 1, true);
		var file:String = "http://localhost:8383/public/data/c" + (_face.parent as Object).extra[0] + "_f" + _face.Id + ".zip";
		zip.load(new URLRequest(file));
		*/

		_filesLoaded = true;
	}
	
	private function onZipFileLoaded(evt:FZipEvent):void 
	{
		if (evt.file.content.bytesAvailable > 0)
		{
			var fileName:String = evt.file.filename;
			
			if(fileName.indexOf(".png") != -1)
			{		
				var loader:Loader = new Loader();
				var loaderContext:LoaderContext = new LoaderContext(); 
				loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD 
				loader.contentLoaderInfo.addEventListener(Event.INIT, pngLoaded, false, 0, true);				
				loader.loadBytes(evt.file.content, loaderContext);				
			}
			else if(fileName.indexOf(".json") != -1)
			{
				var pixelBlocks:Object = JSON.parse(evt.file.getContentAsString(false)).results;
				
				var pixelBlockData:Object;
				for (var obj:Object in pixelBlocks)
				{
					pixelBlockData = pixelBlocks[obj];
					_pixelBlocksGrid[pixelBlockData.y][pixelBlockData.x].infolink = pixelBlockData;
				}
			}	
		}
	}
	
	public function pngLoaded(evt: Event):void
	{
		var bitmapData:BitmapData = evt.target.content.bitmapData;
		for (var i:int = 0, l:int = _soldPixelBlocks.length; i < l; i++ )
		{
			_soldPixelBlocks[i].drawFromBitmap(bitmapData);
		}
		
		_bitmapTex.updateBitmap();
	}

	public function show():void
	{
		this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		this.addEventListener(MouseEvent.MOUSE_OUT,  mouseOutHandler);
		
		this.visible = true;
		_active = true;	
		
		if (!_filesLoaded)
		{
			startLoadingImagesFromZip();
		}
	}
	
	public function hide():void
	{
		this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		this.removeEventListener(MouseEvent.MOUSE_OUT,  mouseOutHandler);

		this.visible = false;
		_active = false;
		
		_bitmapTex.updateBitmap();
	}
	
	private function mouseOverHandler(event:MouseEvent):void
	{
		Mouse.cursor = CursorManager.AUTO;
	}
	
	private function mouseMoveHandler(event:MouseEvent):void
	{
		var gridPos:Point = gridPos(mouseX, mouseY);
		
		if (!(gridPos.x < 0 || gridPos.x > _pixelBlocksGrid[0].length -1 || gridPos.y < 0 || gridPos.y > _pixelBlocksGrid.length -1) )
		{
			if (_mouseOverPixelBlock != null) 
			{
				if (_mouseOverPixelBlock != _pixelBlocksGrid[gridPos.y][gridPos.x])
				{
					_mouseOverPixelBlock.mouseOutHandler();
					_pixelBlocksGrid[gridPos.y][gridPos.x].mouseOverHandler();
					_mouseOverPixelBlock = _pixelBlocksGrid[gridPos.y][gridPos.x];
				}				
			}
			else
			{
				_pixelBlocksGrid[gridPos.y][gridPos.x].mouseOverHandler();
				_mouseOverPixelBlock = _pixelBlocksGrid[gridPos.y][gridPos.x];
			}
		}
	}
	
	private function gridPos(mX:Number, mY:Number):Point
	{
		return new Point(Math.round(mX/10)-1, Math.round(mY/10)-1);
	}
	
	private function mouseDownHandler(event:MouseEvent):void
	{
		var gridPos:Point = gridPos(mouseX, mouseY);
		
		if (!(gridPos.x < 0 || gridPos.x > _pixelBlocksGrid[0].length -1 || gridPos.y < 0 || gridPos.y > _pixelBlocksGrid.length -1) )
		{
			_pixelBlocksGrid[gridPos.y][gridPos.x].mouseDownHandler();
		}
	}
	
	private function mouseOutHandler(event:MouseEvent):void
	{
		Mouse.cursor = CursorManager.MOVE_ARROWS;
		
		if (_mouseOverPixelBlock) 
		{
			_mouseOverPixelBlock.mouseOutHandler();
			_mouseOverPixelBlock = null;
		}
	}
	
	public function get pixelBlocks():Array
	{
		return _pixelBlocksGrid;
	}
	
	public function get isActive():Boolean
	{
		return _active;
	}
}

import flash.display.Loader;
import flash.events.IOErrorEvent;
import flash.system.LoaderContext;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.ImageDecodingPolicy;

class PixelBlock
{
	private var _selTool:SelectionTool;
	private var _selected:Boolean = false;
	private var _filled:Boolean = false;
	private var _free:Boolean = false;
	private var _offset:int = 6;
	
	private var _bitmapTex:BitmapTexture;
	private var _plane:Plane;
	
	private var _info:String;
	private var _link:String;
	private var _x:int;
	private var _y:int;
	private var _dx:int;
	private var _dy:int;
	
	[Embed(source="/../embeds/10x10pixel.png")] private static var _clearPixelsTextureImage:Class;
	private static var _clearPixelsBitmap:Bitmap = new _clearPixelsTextureImage();
	
	[Embed(source="/../embeds/select.png")] private static var _selectTextureImage:Class;
	private static var _selectBitmap:Bitmap = new _selectTextureImage();

	public function PixelBlock(plane:Plane, selTool:SelectionTool, bitmapTex:BitmapTexture, free:Boolean, posX:int, posY:int, dimX:int, dimY:int, info:String = null, link:String = null)
	{
		_selTool = selTool;
		_plane = plane;
		_bitmapTex = bitmapTex;
		_free = free;
		
		_x = posX;
		_y = posY;
		
		_dx = dimX;
		_dy = dimY;
		
		if (!free)
		{								
			var r:uint = Math.round(Math.random()*255);
			var g:uint = Math.round(Math.random()*255);
			var b:uint = Math.round(Math.random()*255);
			
			_bitmapTex.bitmapData.fillRect(new Rectangle(_x + _offset, _y + _offset, _dx, _dy), 0xffe8d5d5);						
			_bitmapTex.bitmapData.fillRect(new Rectangle(_x + _offset + 1, _y + _offset + 1, _dx - 1, _dy - 1), argb2int(255,r,g,b));								
			
			_info = info;
			_link = link;
		}
	}
	
	private function argb2int(a:uint, r:uint, g:uint, b:uint):uint
	{
		var intVal:uint = a << 24 | r << 16 | g << 8 | b;
		//var hexVal:String = intVal.toString(16);
		//hexVal = "#" + (hexVal.length < 6 ? "0" + hexVal : hexVal);
		return intVal; 
	}

	public function drawFromBitmap(bitmapData:BitmapData):void
	{
		_bitmapTex.bitmapData.copyPixels(bitmapData, new Rectangle(_x, _y, _dx, _dy), new Point(_x + _offset, _y + _offset));
	}

	public function fill(offsetX:int, offsetY:int, useOffset:Boolean = true):void
	{
		if (useOffset)
		{
			_bitmapTex.bitmapData.copyPixels(_selectBitmap.bitmapData, new Rectangle(_x - offsetX, _y - offsetY, _dx, _dy), new Point(_x + _offset, _y + _offset));				
		}
		else
		{
			_bitmapTex.bitmapData.copyPixels(_selectBitmap.bitmapData, new Rectangle(0, 0, _dx, _dy), new Point(_x + _offset, _y + _offset));	
		}
		
		_filled = true;
	}
	
	public function clear():void
	{
		_bitmapTex.bitmapData.copyPixels(_clearPixelsBitmap.bitmapData, new Rectangle(0, 0, _dx, _dy), new Point(_x + _offset, _y + _offset));
		_filled = false;
	}
	
	public function mouseOverHandler():void
	{
		if (!_selected && _free)
		{
			fill(0, 0, false);
		}
		else if (_selected)
		{
			Main.rubik.infoTool.show("Info...", _plane.localToGlobal(_selTool.minXY));
		}
		
		if (!_free)
		{
			if (_info == null)
			{
				Main.rubik.infoTool.show("Loading...", _plane.localToGlobal(new Point(_x + _offset,_y + _offset)));
			}
			else
			{
				Main.rubik.infoTool.show(_info, _plane.localToGlobal(new Point(_x + _offset,_y + _offset)));
			}
		}
	}
	
	public function mouseOutHandler():void
	{
		if (!_selected && _free)
		{
			clear();
		}
		
		if (_selected || !_free)
		{
			Main.rubik.infoTool.hide();
		}
	}
	
	public function mouseDownHandler():void
	{
		if (_free)
		{
			_selTool.notifyMouseDownOnPixelBlock(this);
		}
		else
		{
			if (_link != null)
			{
				var request:URLRequest = new URLRequest(_link);
				navigateToURL(request);
			}
		}
	}
	
	public function get info():String{ return _info; }
	public function get link():String { return _link; }
	public function get x():int{ return _x; }
	public function get y():int{ return _y; }
	public function get dx():int{ return _dx; }
	public function get dy():int { return _dy; }
	public function get isFree():Boolean { return _free; }
	
	public function set infolink(obj:Object):void { _info = obj.i; _link = obj.l; }
	public function set selected(value:Boolean):void{ _selected = value; }
}

import flash.external.ExternalInterface;

class SelectionTool
{
	private var _plane:Plane;
	private var _selectedPixelBlocks:Vector.<PixelBlock> = new Vector.<PixelBlock>();
	private var _minX:int, _minY:int, _maxX:int, _maxY:int;
	private var _buyBtn:Button;
	
	public function SelectionTool(plane:Plane)
	{
		_plane = plane;
	}
	
	public function notifyMouseDownOnPixelBlock(pixelBlock:PixelBlock):void
	{
		if (!_buyBtn)
		{
			_buyBtn = new Button(0, -32);
			_plane.addChild(_buyBtn);
		}
		
		for (var i:int = 0, l:int = _selectedPixelBlocks.length; i < l; i++ )
		{
			if (_selectedPixelBlocks[i].x == pixelBlock.x && _selectedPixelBlocks[i].y == pixelBlock.y)
			{
				for (i = 0; i < l; i++ )
				{
					_selectedPixelBlocks[i].clear();
					_selectedPixelBlocks[i].selected = false;
				}
				_selectedPixelBlocks = new Vector.<PixelBlock>();
				_buyBtn.hide();
				Main.rubik.infoTool.hide();
				return;
			}
		}

		if (_selectedPixelBlocks.length == 0)
		{
			_minX = _maxX = pixelBlock.x;
			_minY = _maxY = pixelBlock.y;
			
			pixelBlock.fill(_minX, _minY);
			pixelBlock.selected = true;
			_selectedPixelBlocks.push(pixelBlock);
			
			Main.rubik.infoTool.show("Info...", _plane.localToGlobal(new Point(pixelBlock.x + 6, pixelBlock.y + 6)));
		}
		else
		{
			_minX = Math.min(pixelBlock.x, _minX);
			_minY = Math.min(pixelBlock.y, _minY);
			
			_maxX = Math.max(pixelBlock.x, _maxX);
			_maxY = Math.max(pixelBlock.y, _maxY);
			
			var pixelBlocksOnPlane:Array = _plane.pixelBlocks;
		
			for (var row:int = 0, pixelBlocksOnPlanelength:int = pixelBlocksOnPlane.length; row < pixelBlocksOnPlanelength; row++ )
			{
				for ( var column:int = 0, pixelBlocksOnPlaneRowLength:int = pixelBlocksOnPlane[row].length; column < pixelBlocksOnPlaneRowLength; column++ )
				{
					var pixelBlockXOnPlane:PixelBlock = pixelBlocksOnPlane[row][column];

					var minRect:Rectangle = new Rectangle(_minX, _minY, _maxX - _minX + 10, _maxY - _minY + 10);
					var rect:Rectangle = new Rectangle(pixelBlockXOnPlane.x, pixelBlockXOnPlane.y, pixelBlockXOnPlane.dx, pixelBlockXOnPlane.dy);
										
					if(minRect.intersects(rect))
					{
						if (!pixelBlockXOnPlane.isFree)
						{
							for (var n:int = 0, _selectedPixelBlockslength:int = _selectedPixelBlocks.length; n < _selectedPixelBlockslength; n++)
							{
								_selectedPixelBlocks[n].clear();
								_selectedPixelBlocks[n].selected = false;
							}
							
							_selectedPixelBlocks = new Vector.<PixelBlock>();
							
							pixelBlock.fill(_minX, _minY);
							pixelBlock.selected = true;
							_selectedPixelBlocks.push(pixelBlock);
							
							_minX = _maxX = pixelBlock.x;
							_minY = _maxY = pixelBlock.y;
							_buyBtn.update(_maxX + 10 - _minX, _maxY + 10 - _minY);
							Main.rubik.infoTool.show("Info...", _plane.localToGlobal(new Point(pixelBlock.x + 6, pixelBlock.y + 6)));
							return;
						}
					
						pixelBlockXOnPlane.fill(_minX, _minY);
						pixelBlockXOnPlane.selected = true;
						_selectedPixelBlocks.push(pixelBlockXOnPlane);
					}
				}
			}
		}
		
		Main.rubik.infoTool.show("Info...", _plane.localToGlobal(new Point(_minX + 6, _minY + 6)));
		
		var dx:int = _maxX + 10 - _minX;		
		var dy:int = _maxY + 10 - _minY;
		
		_buyBtn.update(dx, dy);
		_buyBtn.show();
	}
	
	public function get minXY():Point{ return new Point(_minX + 6, _minY + 6); }
}

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.StyleSheet;
import flash.display.GraphicsPathWinding;

class InfoTool extends Sprite
{
	private var _styleSheet:StyleSheet = new StyleSheet();
	private var _tf:TextField;
	
	public function InfoTool()
	{
		_styleSheet.setStyle("Text", { color:'#1a1a1a', fontSize:'15', fontFamily: 'Times, Times New Roman, serif' } );

		_tf = new TextField();
		_tf.x = 4; _tf.y = 4;
		_tf.wordWrap = false;
		//_tf.width = 500;
		_tf.autoSize = TextFieldAutoSize.LEFT;
		_tf.mouseEnabled = false;
		this.buttonMode = false;
		addChild(_tf);
	}
	
	public function show(text:String, pos:Point):void
	{
		_tf.wordWrap = false;
		
		var htmlText:String = "<Text>"+ text +"</Text>";
		_tf.styleSheet = _styleSheet;
		_tf.htmlText = htmlText;
		
		if (_tf.width > 500)
		{
			_tf.wordWrap = true;
			_tf.width = 500;
		}

		_tf.styleSheet = _styleSheet;
		_tf.htmlText = htmlText;

		graphics.clear();
		if(pos.x -5 + _tf.width < Main.stageRef.width)
		{
			graphics.beginFill(0xffffff);
			graphics.lineStyle(1, 0xe8d5d5);
			graphics.drawPath(Vector.<int>([ 1,2,2,2,2,2,2,2]),
							  Vector.<Number>([0, 0,
											   0, _tf.height + 5, 
											   5, _tf.height + 5, 
											   10, _tf.height + 10, 
											   15, _tf.height + 5,
											   _tf.width + 5, _tf.height + 5,
											   _tf.width + 5, 0,
											   0, 0]),
							  GraphicsPathWinding.NON_ZERO);
			graphics.endFill();
			
			x = pos.x - 5; y = pos.y - _tf.height - 13;
		}
		else
		{
			graphics.beginFill(0xffffff);
			graphics.lineStyle(1, 0xe8d5d5);
			graphics.drawPath(Vector.<int>([ 1,2,2,2,2,2,2,2]),
							  Vector.<Number>([0, 0,
											   0, _tf.height + 5, 
											   _tf.width - 10, _tf.height + 5, 
											   _tf.width - 5, _tf.height + 10, 
											   _tf.width,  _tf.height + 5,
											   _tf.width + 4,      _tf.height + 5,
											   _tf.width + 4, 0,
											   0, 0]),
							  GraphicsPathWinding.NON_ZERO);
			graphics.endFill();
			
			x = pos.x - _tf.width + 10; y = pos.y - _tf.height - 13;
		}
		
		visible = true;
	}
	
	public function hide():void
	{
		visible = false;
	}
}

class Button extends Sprite
{
	private var _label:String;
	private var _tf:TextField;
	
	public function Button(posX:int = 0, posY:int = 0)
	{
		_tf = new TextField();
		_tf.textColor = 0xdedede;
		_tf.x = 4; _tf.y = 4;
		_tf.autoSize = TextFieldAutoSize.LEFT;
		_tf.mouseEnabled = false;
		
		x = posX; y = posY;
		this.buttonMode = true;
		addChild(_tf);		
	}
	
	public function show():void
	{
		visible = true;	
		addEventListener(MouseEvent.MOUSE_DOWN,  mouseDownHandler);
	}
	
	public function hide():void
	{
		visible = false;
		removeEventListener(MouseEvent.MOUSE_DOWN,  mouseDownHandler);
	}
	
	public function update(dx:int, dy:int):void
	{
		_tf.text = "Buy " + dx + " x " + dy + " pixel = " + dx * dy +"€";
		
		x = 249 - _tf.width / 2;

		graphics.clear();
		graphics.beginFill(0xdedede, 1);
		graphics.drawRect(0, 0, _tf.width + 10, _tf.height + 10);
		graphics.beginFill(0x3a3a3a, 1);
		graphics.drawRect(1,1, _tf.width + 8, _tf.height + 8);
		graphics.endFill();
	}	

	public function mouseDownHandler(event:MouseEvent):void
	{		

	}
	
	public function set position(value:Point):void{ x = value.x; y = value.y; }
}