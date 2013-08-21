﻿/** * <p>Original Author: Daniel Freeman</p> * * <p>Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions:</p> * * <p>The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software.</p> * * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE.</p> * * <p>Licensed under The MIT License</p> * <p>Redistributions of files must retain the above copyright notice.</p> */package com.danielfreeman.madcomponents {	import flash.display.DisplayObject;	import flash.display.InteractiveObject;	import flash.display.Shape;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.TextEvent;	import flash.events.TimerEvent;	import flash.geom.Rectangle;	import flash.text.TextFormat;/** * A list row was clicked.  This is a bubbling event. */	[Event( name="clicked", type="flash.events.Event" )]/** * A list row was long-clicked. */	[Event( name="longClick", type="flash.events.Event" )]/** * The Pull-Down-To-Refresh header was activated */	[Event( name="pullRefresh", type="flash.events.Event" )]	/** *  MadComponents List * <pre> * &lt;list *    id = "IDENTIFIER" *    colour = "#rrggbb" *    background = "#rrggbb, #rrggbb, ..." *    visible = "true|false" *    gapV = "NUMBER" *    gapH = "NUMBER" *    border = "true|false" *    autoLayout = "true|false" *    lines = "true|false" *    pullDownRefresh = "true|false" *    pullDownColour = "#rrggbb" *    sortBy = "IDENTIFIER" *    sortMode = "MODE" *    index = "INTEGER" *    highlightPressed = "true|false" *    showPressed = "true|false" *    mask = "true|false" *    alignV = "scroll|no scroll" *    labelField = "IDENTIFIER" * /&gt; * </pre> */	public class UIList extends UIScrollVertical {			public static const CLICK_START:String = "clickStart";		public static const CLICKED:String = "clicked";		public static const CLICKED_END:String = "listClickedEnd";		public static const CLICK_CANCEL:String = "listClickCancel";		public static const LONG_CLICK:String = "longClick";		public static const REFRESH:String = "pullRefresh";		protected static const ARROW:Number = 6;		protected static const TOP:Number = 40;		protected static const PULL_THRESHOLD:Number = 70;				protected const FORMAT:TextFormat = new TextFormat("Tahoma",18);				public static var LONG_CLICK_THRESHOLD:int = 16;		public static var HIGHLIGHT:uint = 0x9999FF;		public static var PULL_DOWN_TEXT:String = "pull down to refresh";		public static var REFRESH_TEXT:String = "refreshing...";		public static var TOUCH_THRESHOLD:int = 1;		protected var _renderer:XML;		protected var _simple:Boolean;		protected var _count:int = 0;		protected var _cellHeight:Number = -1;		protected var _pressedCell:int = -1;		protected var _highlight:Shape;		protected var _clickRow:Boolean = true;		protected var _cellTop:Number=Number.NEGATIVE_INFINITY;		protected var _cellRendererLeft:Number = 0;		protected var _colours:Vector.<uint>;		protected var _suffix:String = "";		protected var _font:String = "";		protected var _model:Model = null;		protected var _search:UISearch = null;		protected var _top:Number = 0;		protected var _rendererAttributes:Attributes;		protected var _field:String;		protected var _data:Array;		protected var _filteredData:Array = [];		protected var _sortBy:String = "";		protected var _sortMode:String = "";		protected var _row:UIForm;		protected var _lines:Boolean = false;		protected var _cell:*;		protected var _refresh:UIRefresh = null;		protected var _refreshState:Boolean = false;		protected var _showPressed:Boolean = false;		protected var _textAlign:String;		protected var _highlightPressed:Boolean = true;		protected var _rowClick:Boolean = false;		protected var _highlightColour:uint = HIGHLIGHT;		protected var _labelField:String = "label";		protected var _highlightIsOn:Boolean = false;		protected var _saveIndex:int = -1;		protected var _header:int = 0;		protected var _arrows:Boolean;		public function UIList(screen:Sprite, xml:XML, attributes:Attributes) {			_colours = attributes.backgroundColours;			_arrows = xml.@arrows == "true";			if (xml.@header.length() > 0) {				_header = parseInt(xml.@header);			}			_highlightPressed = xml.@highlightPressed != "false";			if (xml.@labelField.length() > 0) {				_labelField = xml.@labelField;			}			if (xml.@highlightColour.length() > 0) {				_highlightColour = UI.toColourValue(xml.@highlightColour);			}			super(screen, xml, attributes);			_renderer = renderer(xml);			_simple = _renderer.toXMLString() == "";			if (!_simple && !_rendererAttributes) {				initialiseRenderAttributes(xml, attributes);			}			if (xml.@lines.length()>0 && xml.@lines[0].toString()!="false") {				_lines=true;			}			if (xml.font.length()>0) {				_font = xml.font[0].toXMLString();			}			if (xml.search.length()>0) {				var searchAttributes:Attributes = attributes.copy(xml.search[0]);				searchAttributes.x = searchAttributes.y = 0;				_search = new UISearch(_slider,xml.search[0], searchAttributes);				if (xml.search[0].@id.length()>0)					_search.name = xml.search[0].@id[0];				_top = _search.height;				if (xml.search[0].@field.length()>0) {					_field=xml.search[0].@field[0];					_search.addEventListener(TextEvent.TEXT_INPUT, searchHandler);				}			}			if (xml.@pullDownRefresh.length()>0 && xml.@pullDownRefresh[0]!="false") {				_refresh = new UIRefresh(_slider, 0, -TOP/2, xml.@pullDownColour.length()>0 ? UI.toColourValue(xml.@pullDownColour[0]) : 0x333333, PULL_DOWN_TEXT);			}			if (xml.@sortBy.length()>0) {				_sortBy = xml.@sortBy[0];			}			if (xml.@sortMode.length()>0) {				_sortMode = xml.@sortMode[0];			}			if (xml.@showPressed.length()>0) {				_showPressed = xml.@showPressed[0]=="true";			}			if (xml.data.length()>0) {				xmlData = xml.data[0];			}			if (xml.model.length()>0) {				_model = new UI.ModelClass(this, xml.model[0]);			}			buttonMode = useHandCursor = true;			if (xml.@index.length()>0) {				index = parseInt(xml.@index);			}		}						public function set header(value:int):void {			_header = value;		}						public function get header():int {			return _header;		}						public function set labelField(value:String):void {			_labelField = value ? value : "label";		}						public function set colours(value:Vector.<uint>):void {			_colours = value;		}						protected function initialiseRenderAttributes(xml:XML, attributes:Attributes):void {			_rendererAttributes = attributes.copy();			_rendererAttributes.parse(xml);			_rendererAttributes.x = _rendererAttributes.y = 0;			_rendererAttributes.width-=2*_rendererAttributes.paddingH;			_rendererAttributes.height-=2*_rendererAttributes.paddingV;		}						protected function indexToScrollPosition(value:int):Number {			return _cellHeight * value - _offset;		}						public function setIndex(value:int, animate:Boolean = false, move:Boolean = false, highlight:Boolean = false):void {			_pressedCell = value;			if (value < 0) {				return;			}			if (animate) { // && sliderY + _cellHeight * value < MAXIMUM_DY/2) {				_endSlider = indexToScrollPosition(value);				_moveTimer.start();			}			else if (move) {				scrollPositionY = indexToScrollPosition(value);			}						if (highlight) {				illuminate(value, false);			}		}		/** *  Scroll to index */		public function set index(value:int):void {			setIndex(value, false, false, _showPressed);		}						public function get rendererXML():XML {			return _renderer;		}				override protected function doLayoutHandler(event:Event):void {			doLayout();			event.stopPropagation();		}		/** *  Extract renderer XML from XML */		protected function renderer(xml:XML):XML {			var children:XMLList = xml.children();			if (children.length()==0)				return XML("");			else if (xml.data.length()==0 && xml.font.length()==0 && xml.model.length()==0 && xml.search.length()==0)				return children[0];						for each (var child:XML in children) {				if (child.localName()!="data" && child.localName()!="font" && child.localName()!="model" && child.localName()!="search" && child.localName()!="detail") {					return child;				}			}			return XML("");		}				/** *  If set to false, the no highlight appears */		public function set highlightPressed(value:Boolean):void {			_highlightPressed = value;		}				/** *  If set to true, the click highlight remains */		public function set showPressed(value:Boolean):void {			_showPressed = value;		}						public function get showPressed():Boolean {			return _showPressed;		}				/** *  Clears the click highlight. */		public function clearPressed():void {			_highlight.graphics.clear();			_highlightIsOn = false;		}						protected function dispatchClickedEnd():void {			if (!_classic) {				dispatchEvent(new Event(CLICKED, true));			}			dispatchEvent(new Event(CLICKED_END, true));		}/** *  Clears the click highlight. - for controlling list externally and firing CLICKED_END event. *  (Most developers will likely never have a need to call this). */		public function endPressed(delay:Boolean = false):void {			if (delay) {				_showPressed = false;				_clickTimer.reset();				_clickTimer.start();			}			else {				clearPressed();				dispatchClickedEnd();			}		}		/** *  Set XML data */		public function set xmlData(value:XML):void {			var result:Array = [];			var children:XMLList = value.children();			for each (var child:XML in children)				if (child.nodeKind()!="text")					result.push(attributesToObject(child));			data = result;		}						protected function attributesToObject(child:XML):Object {			var item:Object = new Object();			var attributes:XMLList = child.attributes();			if (attributes.length()==0) {				item = {label:child.localName()};			}			else {				for (var i:int=0; i<attributes.length(); i++) {					  item[attributes[i].name().toString()] = attributes[i].toString();				}			}			return item;		}		/** *  Draw background */		override public function drawComponent():void {			graphics.clear();			if (_colours && _colours.length > 0) {				graphics.beginFill(_colours[0]);			}			else {				graphics.beginFill(0,0);			}			graphics.drawRect(0, 0, _attributes.widthH, _attributes.heightV);		}		/** *  Rearrange the layout to new screen dimensions */			override public function layout(attributes:Attributes):void {			var i:int;			var cell:*;			_width = attributes.width;			_height = attributes.height;			if (_search) {				_search.fixwidth = attributes.width;			}			_attributes = attributes;			drawComponent();			_slider.graphics.clear();			if (_simple) {				for (i = 0; i<_slider.numChildren; i++) {					cell = _slider.getChildAt(i);					if (cell is UILabel) {						UILabel(cell).fixwidth = _attributes.width-2*_attributes.paddingH;						cell.multiline = cell.wordWrap = false;					}				}			}			else {				_rendererAttributes.width=attributes.width - 2*attributes.paddingH;				_rendererAttributes.height=attributes.width - 2*attributes.paddingH;				if (_filteredData && _autoLayout) {					autoLayout();				}				else {					for (i = 0; i<_slider.numChildren; i++) {						cell = _slider.getChildAt(i);						if (cell is UIForm) {							UIForm(cell).layout(_rendererAttributes);						}					}				}			}			refreshMasking();			if (!_autoLayout || _simple) {				redrawCells();			}			if (_highlightIsOn && _showPressed) {				setIndex(_pressedCell, false, false, true);			}			calculateMaximumSlide();		}						protected function autoLayout():void {			var last:Number = _top + _attributes.paddingV;			for (var i:int = 0;i<_filteredData.length;i++) {				var cell:* = _slider.getChildByName("label_"+i.toString());				if (cell && cell is UIForm) {					UIForm(cell).layout(_rendererAttributes);					cell.y = last;					last += cell.height + _attributes.paddingV;					drawCell(last, i);					last += _attributes.paddingV;				}			}		}		/** *  Refresh layout */			override public function doLayout():void {			layout(_attributes);			adjustMaximumSlide();		}		/** *  Redraw cell chrome */			protected function redrawCells():void {			initDraw();			if (!_autoLayout) {				for (var l:int = 0; l < _filteredData.length; l++) {					drawCell(_cellHeight*(l+1) + _top, l);				}			}		}		/** *  Set up the scrolling part of the list */			override protected function createSlider(xml:XML, attributes:Attributes):void {			addChild(_slider = new Sprite());			_slider.addChild(_highlight=new Shape());			_width = attributes.width;			_height = attributes.height;		}						protected function sortParameter(value:String):* {			if (value.indexOf(",")<0) {				return value;			}			else {				return value.split(",");			}		}		/** *  Assign array of objects data */			override public function set data(value:Object):void {			_data = value as Array;			if (_sortBy!="" && _data) {				_data.sortOn(sortParameter(_sortBy),sortParameter(_sortMode));			}			clearPressed();			filteredData = value as Array;		}		/** *  Set filtered data ( a sub-set of full data ). */			public function set filteredData(value:Array):void {			_filteredData = value;			data0 = value;		}		/** *  Set list data */			protected function set data0(value:Array):void {			if (_refresh)				_refresh.changeState(PULL_DOWN_TEXT, false);			clearCells();			initDraw();			if (_simple)				simpleRenderers(value, _cellTop + 2 * _attributes.paddingV);			else				customRenderers(value, _cellTop + _attributes.paddingV);			if (_autoLayout) {				doLayout();			}			calculateMaximumSlide();		}		/** *  Calculate maximum slide */			protected function calculateMaximumSlide():void {			_scrollerHeight = _slider.height - (_refresh ? TOP : 0);			_maximumSlide = _scrollerHeight - _height;			if (_maximumSlide < 0) {				_maximumSlide = 0;			}			if (_count>0 && (_cellHeight<0 || _autoLayout)) {				_cellHeight = (_slider.height - _top - (_refresh ? TOP : 0)) / _count;			}		}						override protected function adjustMaximumSlide():void {		}		/** *  Data */			public function get data():Object {			return _data;		}		/** *  Filtered data */			public function get filteredData():Array {			return _filteredData;		}		/** *  Filter the data according to a search string */			public function filter(searchFor:String, field:String = "", caseSensitive:Boolean = false):void {			if (searchFor == "") {				filteredData = _data;			}			else {				if (field == "") {					field = _field;				}				var result:Array = [];				for each (var record:Object in _data) {					var item:String = record[field];					if (!caseSensitive)						item = item.toLowerCase();					if (item.indexOf(searchFor) >= 0)						result.push(record);				}				filteredData = result;			}		}		/** *  Create list with simple default label rows */			protected function simpleRenderers(value:Array, position:Number = -1):void {			if (position < 0)				position = 2 * _attributes.paddingV;			_count = 0;			_textAlign = _attributes.textAlign;			for each (var record:* in value) {				var label:UILabel = labelCell(record, position);				position += label.height + 2 * _attributes.paddingV;				drawCell(position, _count);				position += 2 * _attributes.paddingV;				_cellHeight = 4 * _attributes.paddingV + label.height;				_count++;			}		}		/** *  Create a simple list label row */			protected function labelCell(record:*, position:Number):UILabel {			var labelText:String = record is String ? record : record[_labelField];			var label:UILabel = newLabel();//_attributes.x + 			label.y = position;			label.name = "label_"+_count.toString()+_suffix;			if (XML("<t>"+labelText+"</t>").hasComplexContent()) {				var xmlString:String = XML("<t>"+labelText+"</t>").toXMLString();				label.htmlText = xmlString;			}			else {				if (_font!="") {					label.htmlText = _font.substr(0,_font.length-2)+ ">" + labelText + "</font>";				}				else {					label.text = labelText;				}			}						if (_textAlign != "") {				var format:TextFormat = new TextFormat();				format.align = _textAlign;				label.setTextFormat(format);			}						label.fixwidth = _attributes.width-2*_attributes.paddingH;			label.multiline = label.wordWrap = false;						return label;		}		/** *  Clear list */			protected function initDraw():void {			_slider.graphics.clear();			resizeRefresh();			_slider.graphics.beginFill(_colour);			_slider.graphics.drawRect(0, _top, _width, 1);			_cellTop = _top;		}		/** *  Resize list row chrome */			protected function resizeRefresh():void {			if (_refresh) {				_slider.graphics.beginFill(_colours.length>0 ? _colours[_colours.length-1] : 0xF9F9F9);				_slider.graphics.drawRect(0, -TOP, attributes.width, TOP);				_refresh.x = (attributes.width - _refresh.width) / 2;			}		}		/** *  Clear list */			protected function clearCells():void {			var i:int = _slider.numChildren;			while (--i>=(_search ? 2 : 1)+(_refresh ? 1 : 0)) {				var child:DisplayObject = DisplayObject(_slider.getChildAt(i));				if (child.hasOwnProperty("destructor")) {					Object(child).destructor();				}				_slider.removeChildAt(i);			}		}		/** *  Draw row chrome */			protected function drawCell(position:Number, count:int):void {			drawSimpleCell(position, count);		}						protected function drawArrow(x:Number, y:Number):void {			_slider.graphics.beginFill(_colour);			_slider.graphics.moveTo(x, y);			_slider.graphics.lineTo(x - ARROW, y - ARROW);			_slider.graphics.lineTo(x - ARROW, y + ARROW);			_slider.graphics.lineTo(x, y);			_slider.graphics.endFill();		}		/** *  Draw row chrome */			protected function drawSimpleCell(position:Number, count:int):void {		//	position = Math.floor(position);			if (_colours.length > 1) {				_slider.graphics.beginFill(_colours[count % (_colours.length - 1) + 1]);				_slider.graphics.drawRect(0, _cellTop + 2, _width, position - _cellTop - 1);				_slider.graphics.endFill();			}			_slider.graphics.beginFill(_colour);			_slider.graphics.drawRect(0, position, _width, 1);			_slider.graphics.endFill();			drawLines(position);			if (_arrows && (_header > 0 ? count >= _header : count < _count + _header)) {				drawArrow(_width - _attributes.paddingH, (_cellTop + position) / 2);			}			_cellTop = position;		}		/** *  Draw lines within row */			protected function drawLines(position:Number):void {			if (_lines && _cell is UIForm) {				_slider.graphics.beginFill(_colours.length > 0 ? _colours[0] : 0x666666);				var positions:Array = _cell.positions;				for (var i:int = 1; i<positions.length; i++) {					_slider.graphics.drawRect(_cell.x+positions[i] - _attributes.paddingH/2, _cellTop+1, 1, position - _cellTop);				}				_slider.graphics.endFill();			}		}		/** *  Return DisplayObject of button pressed */		override protected function pressButton():DisplayObject {			_scrollBarLayer.graphics.clear();			clearPressed();			if (!_simple || _slider.mouseY < _top) {				doSearchHit();			}			illuminate();			return _pressButton;		}						public function doClickRow(dispatch:Boolean = true):Boolean {			_highlight.graphics.clear();			_showPressed = true;			illuminate(-1, dispatch);			return dispatch && _pressedCell >= 0 && _pressedCell < _count;		}						protected function pressedCellLimits(groupDetail:Object = null):void {			if (_pressedCell < _header || _pressedCell >= _count) {				_pressedCell = _saveIndex;			}		}						protected function illuminate(pressedCell:int = -1, dispatch:Boolean = true):void {			const tweak:Number = 2.0;			var sliderMouseY:Number = _slider.visible ? _slider.mouseY : mouseY - _sliderPosition;			if (!_pressButton && _clickRow) {				if (_autoLayout && !_simple && sliderMouseY > _top) {					_pressedCell = pressedCell>=0 ? pressedCell : autoLayoutPressedCell(sliderMouseY);					pressedCellLimits();					if (_row && _pressedCell >= _header && _pressedCell < _count) {						if (_highlightPressed) {							_highlight.graphics.beginFill(_highlightColour);							_highlight.graphics.drawRect(0, _row.y - _attributes.paddingV + tweak, _width, _row.height + 2*_attributes.paddingV - tweak ); //_attributes.x + 							_highlight.graphics.endFill();						}						activate(dispatch);					}				}				else {					_pressedCell = pressedCell>=0 ? pressedCell : Math.floor((sliderMouseY - _top)/_cellHeight);					pressedCellLimits();					if (_pressedCell >= _header && _pressedCell < _count) {						if (_highlightPressed) {							_highlight.graphics.beginFill(_highlightColour);							_highlight.graphics.drawRect(0, _top + _pressedCell * _cellHeight + tweak, _width, _cellHeight - tweak); //_attributes.x + 							_highlight.graphics.endFill();						}						activate(dispatch);					}				}			}		}		/** *  If autoLayout="true", which cell was clicked? */		protected function autoLayoutPressedCell(y:Number):int {			var n:int = 0;			for (var l:int=0;l<_slider.numChildren - 1;l++) {				var row:* = _slider.getChildAt(l+1);								if (row && row is UIForm) {					_row = UIForm(row);					if (_row.y + _row.height + _attributes.paddingV > y)						return n;					n++;				}			}			return -1;		}				/** *  Row has been clicked */		protected function activate(dispatch:Boolean = true):void {			if (_classic) {				_touchTimer.stop();				_dragTimer.stop();				stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);				_clickTimer.stop();				_clickTimer.reset();				_clickTimer.start();			}		//	stopMovement(); //new - interfered with picker.			if (dispatch) {				_rowClick = true;				if (_touchTimer.currentCount >= LONG_CLICK_THRESHOLD) {					dispatchEvent(new Event(LONG_CLICK));				}				else {					dispatchEvent(new Event(_classic ? CLICKED : CLICK_START, true));				}			}		}						override protected function mouseDown(event:MouseEvent):void {			_saveIndex = _pressedCell;			_rowClick = false;			super.mouseDown(event);		}						override protected function mouseUp(event:MouseEvent):void {			if (!_classic && _rowClick) {				if (!_showPressed) {					clearPressed();				}				if (_touchTimer.currentCount < TOUCH_THRESHOLD || Math.abs(_delta) > DELTA_THRESHOLD) {					doCancel();				}				else {					dispatchClickedEnd();				}				_rowClick = false;			}			super.mouseUp(event);		}						protected function doCancel():void {			_pressedCell = _saveIndex;			dispatchEvent(new Event(CLICK_CANCEL, true));			_highlight.graphics.clear();			if (_showPressed && _pressedCell >= 0) {				illuminate(_pressedCell, false);			}		}						override public function touchCancel():void {trace("UIList.touchCancel");			super.touchCancel();			clearPressed();			if (!_classic && _rowClick) {			//	_highlight.graphics.clear();				doCancel();				_rowClick = false;			}		}		/** *  Index of last row clicked */		public function get index():int {			return _pressedCell;		}		/** *  Data object for last row clicked */		public function get row():Object {			return (_pressedCell>=0) ? _filteredData[_pressedCell] : null;		}		/** *  Click up handler */		override protected function clickUp(event:TimerEvent):void {			if (!_simple) {				super.clickUp(event);			}			if (_clickRow) {				if (!_showPressed) {					clearPressed();				}				dispatchClickedEnd();			}			_scrollBarLayer.graphics.clear();		}		/** *  Create list with custom renderers */		protected function customRenderers(value:Array, position:Number = -1):void {			if (position < 0)				position = _attributes.paddingV;			_count = 0;			for each (var record:Object in value) {				customCell(record, position);				position += _cell.height + _attributes.paddingV;				drawCell(position, _count);				position += _attributes.paddingV;				_count++;			}		}		/** *  Instanciate a new list row */		protected function newRow():UIForm {			return new UI.FormClass(_slider, _renderer, _rendererAttributes, true);		}				/** *  Instanciate a new list label */		protected function newLabel():UILabel {			return new UILabel(_slider, _attributes.paddingH, 0, "", FORMAT);		}		/** *  Create and position a new list row */		protected function customCell(record:Object, position:Number):void {			if (!UI.isForm(_renderer.localName())) {				_renderer = XML("<horizontal>" + _renderer.toXMLString() + "</horizontal>");			}			_cell = newRow();			_cell.x = _cellRendererLeft + _rendererAttributes.paddingH;			_cell.y = position;			_cell.mouseChildren = false;			_cell.name = "label_"+_count.toString()+_suffix;			fillInValues(_cell, record);		}		/** *  Assign data to custom renderer components */		protected function fillInValues(cell:UIForm, record:Object):void {			var view:*;			if (record is String) {				view = cell.findViewById("label");				if (view) {					view.text = String(record);				}			}			else {			for (var id:String in record) {				view = cell.findViewById(id);				if (view) {					var value:String = record[id];					try {						if (XML("<o>"+value+"</o>").hasComplexContent() && view is UILabel) {							view.htmlText = value;						}						else {							view.text = value;						}					}					catch (error:Error) {						view.text = value;					}				}			}			}		}		/** *  If true, rows are clickable */		public function set clickRow(value:Boolean):void {			_clickRow = value;		}		/** *  Model */		override public function get model():Model {			return _model;		}		/** *  Handle search field filter */		protected function searchHandler(event:Event):void {			filter(_search.text.toLowerCase());		}		/** *  Determine what has been clicked */		override protected function doSearchHit():void {			super.doSearchHit();			if (_pressButton is InteractiveObject && !InteractiveObject(_pressButton).mouseEnabled) {				_pressButton = null;			}		}		/** *  Return component matching id within row matching row index */		override public function findViewById(id:String, row:int = -1, group:int = -1):DisplayObject {			if (_search && _search.name == id) {				return _search;			}			else if (_simple) {				return _slider.getChildByName(id+"_"+row.toString());			}			else if (row>=0) {				var container:IContainerUI = IContainerUI(_slider.getChildByName("label_"+row.toString()));				return container ? container.findViewById(id, row, group) : null;			}			else {				return null;			}		}						public function get rowContainer():IContainerUI {			return IContainerUI(_slider.getChildAt(_pressedCell+1));		}		/** *  Mouse move handler */		override protected function mouseMove(event:TimerEvent):void {			if (_refresh && !_refreshState && sliderY > PULL_THRESHOLD) {				_refresh.changeState(REFRESH_TEXT, true);				if (_model) {					_model.refresh();				}				_refreshState = true;				dispatchEvent(new Event(REFRESH));			}			super.mouseMove(event);			if (_rowClick && _distance < THRESHOLD && _touchTimer.currentCount == LONG_CLICK_THRESHOLD) {				pressButton();			}		}		/** *  Stop list movement */		override protected function stopMovement():void {			super.stopMovement();			_refreshState = false;		}						public function get length():int {			return _count;		}						override public function rowRectangle(y:Number):Rectangle {			for (var l:int=0;l<_slider.numChildren - 1;l++) {				var row:DisplayObject = _slider.getChildAt(l+1);				if (row.y + row.height + _attributes.paddingV > y) {					if (_simple) {						return new Rectangle(0, row.y - 2 * _attributes.paddingV, _attributes.width, row.height + 4 * _attributes.paddingV);					}					else {						return new Rectangle(0, row.y - _attributes.paddingV, _attributes.width, row.height + 2 * _attributes.paddingV);					}									}			}			return null;		}						public function set searchVisible(value:Boolean):void {			if (_search) {				_search.visible = value;				_top = value ? _search.height : 0;			}		}						override public function destructor():void {			super.destructor();			if (_search) {				_search.removeEventListener(TextEvent.TEXT_INPUT, searchHandler);				_search.destructor();			}		}	}}