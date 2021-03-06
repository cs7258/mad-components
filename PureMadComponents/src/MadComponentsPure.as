/**
 * <p>Original Author: Daniel Freeman</p>
 *
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 *
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 *
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 *
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 */


package
{
	
	import com.danielfreeman.madcomponents.*;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextFormat;
	import pureHelpers.UIPickerBank;
	
	public class MadComponentsPure extends Sprite {
		
		public function MadComponentsPure(screen:Sprite = null) {
			if (screen)
				screen.addChild(this);
			
			stage.align = StageAlign.TOP_LEFT;  
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var label:UILabel = new UILabel(this, 20, 10, "Hello World", new TextFormat("Times",24,0xCCCCCC,true));
			var button:UIButton = new UIButton(this, 20, 50, "button", 0xCCFFCC);
			button.fixwidth = 80.0;
			var slider:UISlider = new UISlider(this, 20, 100);
			slider.fixwidth = 160.0;
			slider.value = 0.3;
			var input:UIInput = new UIInput(this, 20, 140, "input", new <uint>[0x9999AA,0xEEEEFF], true);
			
			var pickerBank:UIPickerBank = new UIPickerBank(this, 20, 200, 280, 160, 2);
			var picker0:UIPicker = UIPicker(pickerBank.findViewById("column0"));
			var picker1:UIPicker = UIPicker(pickerBank.findViewById("column1"));
			var picker2:UIPicker = UIPicker(pickerBank.findViewById("column2"));
		
			picker0.xmlData = <data>
								<January/>
								<February/>
								<March/>
								<April/>
								<May/>
								<June/>
								<July/>
								<August/>
								<September/>
								<October/>
								<November/>
								<December/>
							</data>;
			
			var data:Array = [];
			for (var i:int = 1; i<=31; i++) {
				data.push({label:i.toString()});
			}
			picker1.data = data;
			
			var uiSwitch:UISwitch = new UISwitch(this ,20, 380);
		}
	}
}