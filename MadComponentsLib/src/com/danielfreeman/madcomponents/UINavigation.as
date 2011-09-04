﻿/** * <p>Original Author: Daniel Freeman</p> * * <p>Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions:</p> * * <p>The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software.</p> * * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE.</p> * * <p>Licensed under The MIT License</p> * <p>Redistributions of files must retain the above copyright notice.</p> */package com.danielfreeman.madcomponents {	import flash.display.Sprite;	import flash.display.DisplayObject;	import flash.events.Event;	import flash.events.KeyboardEvent;	import flash.events.MouseEvent;	import flash.ui.Keyboard;	/** *  MadComponents navigation controller * <pre> * &lt;navigation *    id = "IDENTIFIER" *    colour = "#rrggbb" *    background = "#rrggbb, #rrggbb, ..." *    visible = "true|false" *    gapV = "NUMBER" *    gapH = "NUMBER" *    alignH = "left|right|centre|fill" *    alignV = "top|bottom|centre|fill" *    rightButton = "TEXT" *    rightArrow = "TEXT" *    leftArrow = "TEXT" *    title = "TEXT" *    autoFill = "true|false" *    autoTitle = "TEXT" *    border = "true|false" *    mask = "true|false" * /&gt; * </pre> */		public class UINavigation extends UIPages {			protected static const BACK : uint = 0x01000016;		protected var _navigationBar:UINavigationBar;		protected var _pressedCell:int = -1;		protected var _autoForward:Boolean = true;		protected var _autoBack:Boolean = true;		protected var _autoTitle:String = "";		protected var _autoFill:Boolean = false;		protected var _row:Object = null;		protected var _titles:Array = [];				public function UINavigation(screen:Sprite, xml:XML, attributes:Attributes) {			_navigationBar = new UINavigationBar(this, attributes);			var copyAttributes:Attributes = attributes.copy();			copyAttributes.height-= _navigationBar.height;			copyAttributes.y=_navigationBar.height;			super(screen, xml, copyAttributes);			_attributes.y=_navigationBar.height;			if (_thisPage)				_thisPage.y = _navigationBar.height;			_navigationBar.backButton.addEventListener(MouseEvent.MOUSE_UP, goBack);			_navigationBar.backButton.visible = false;			addEventListener(UIList.CLICKED, goForward);				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);			setChildIndex(_navigationBar, numChildren-1);			if (xml.@rightButton.length()>0) {				_navigationBar.rightButtonText = xml.@rightButton[0].toString();				_navigationBar.rightButton.visible = true;			}			if (xml.@rightArrow.length()>0) {				_navigationBar.rightButtonText = xml.@rightArrow[0].toString();				_navigationBar.rightButton.visible = false;				_navigationBar.rightArrow.visible = true;			}			if (xml.@leftArrow.length()>0) {				_navigationBar.backButton.text = xml.@leftArrow[0].toString();			}			if (xml.@title.length()>0) {				_navigationBar.text = xml.@title[0].toString();			}			if (xml.@autoFill.length()>0) {				_autoFill = xml.@autoFill[0].toString() != "false";			}			if (xml.@autoTitle.length()>0) {				_autoTitle = xml.@autoTitle[0].toString();			}		}				override public function set visible(value:Boolean):void {			if (value) {				addEventListener(UIList.CLICKED, goForward);				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);			}			else {				removeEventListener(UIList.CLICKED, goForward);				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);			}				super.visible = value;		}		/** *  Rearrange the layout to new screen dimensions */			override public function layout(attributes:Attributes):void {			_navigationBar.fixwidth = attributes.width;			var copyAttributes:Attributes = attributes.copy();			copyAttributes.height-= _navigationBar.height;			copyAttributes.y=_navigationBar.height;			super.layout(copyAttributes);			_attributes.y=_navigationBar.height;			if (_thisPage)				_thisPage.y = _navigationBar.height;		}				public function set text(value:String):void { // Deprecated			_navigationBar.text = value;		}		/** *  Title of navigation bar */			public function set title(value:String):void {			_navigationBar.text = value;		}		/** *  If false, clicking on list row won't change page */			public function set autoForward(value:Boolean):void {			_autoForward = value;		}/** *  If false, clicking on back button won't revert to previous page */			public function set autoBack(value:Boolean):void {			_autoBack = value;		}		/** *  UINavigationBar */			public function get navigationBar():UINavigationBar {			return _navigationBar;		}		/** *  Go forward handler */			protected function goForward(event:Event):void {			if (!_slideTimer.running) {				_pressedCell = UIList(event.target).index;				_row = UIList(event.target).row;				if (_autoForward) {					if (_autoTitle!="" && _row[_autoTitle]) {						title = _titles[_page] = _row[_autoTitle];					}					nextPage(UIPages.SLIDE_LEFT);				}			}		}		/** *  Go back handler */			protected function goBack(event:MouseEvent = null):void {			if (!_slideTimer.running && _autoBack) {				if (_autoTitle!="") {						title = (_page>1 && _titles[_page-2]) ? _titles[_page-2] : "";				}				previousPage(UIPages.SLIDE_RIGHT);			}		}		/** *  Do page transition */			override protected function doTransition(transition:String):void {			var lastContainer:DisplayObject = Sprite(_lastPage).getChildAt(0);			if (lastContainer is UIList) {				_pressedCell = UIList(lastContainer).index;				_row = UIList(lastContainer).row;			}			var thisContainer:DisplayObject = Sprite(_thisPage).getChildAt(0);			if (_row && thisContainer is IContainerUI && (_autoFill || (IContainerUI(thisContainer).xml.@autoFill.length()>0 && IContainerUI(thisContainer).xml.@autoFill[0]!="false"))) {				if (thisContainer is UIForm) {					UIForm(thisContainer).data = _row;				}				else if (thisContainer is UIScrollVertical && !(thisContainer is UIList)) {					UIScrollVertical(thisContainer).data = _row;				}			}			super.doTransition(transition);			_navigationBar.backButton.visible = pageNumber>0 && _navigationBar.backButton.text!="";		}		/** *  Index of last list row clicked  */			public function get index():int {			return _pressedCell;		}		/** *  Data object of last list row clicked  */		public function get row():Object {			return _row;		}		/** *  Label of last list row clicked  */		public function get label():String {			return _row ? _row.label : "";		}		/** *  Change page */		override public function goToPage(value:int, transition:String = ""):void {			if (_slideTimer.running)				return;			super.goToPage(value, transition);			updateNavigationBar();		}		/** *  Go to next page */		override public function nextPage(transition:String=""):void {			if (_slideTimer.running)				return;			super.nextPage(transition);			updateNavigationBar();		}		/** *  Go to previous page */		override public function previousPage(transition:String=""):void {			if (_slideTimer.running)				return;			super.previousPage(transition);			updateNavigationBar();		}		/** *  Update navigation bar */		protected function updateNavigationBar():void {			if (_transition==SLIDE_DOWN || _transition==DRAWER_DOWN)				_navigationBar.backButton.visible = _lastPageIndex>0 && _navigationBar.backButton.text!="";			else				_navigationBar.backButton.visible = isSimpleTransition(_transition) && _page>0 && _navigationBar.backButton.text!="";			if (_autoTitle!="") {				title = (_page>0 && _titles[_page-1]) ? _titles[_page-1] : "";			}		}		/** *  Keyboard handler */		protected function keyHandler(event:KeyboardEvent):void {			if (event.keyCode == BACK) {				goBack();				event.preventDefault();				event.stopImmediatePropagation();			}		}						override public function destructor():void {			super.destructor();			removeEventListener(UIList.CLICKED, goForward);			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);		}	}}