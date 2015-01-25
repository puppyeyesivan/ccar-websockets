package util;
import haxe.Json;
import js.html.Event;
import js.Browser;
import js.html.Element;
import js.html.InputElement;
import js.html.Text;
import js.html.TextAreaElement;

import js.html.DivElement;
import js.html.Document;
import js.html.ButtonElement;
import js.html.SelectElement;
import js.html.OptionElement;

class Util {
	public static function NEW_LINE () : Int {
		return 10;
	}
	public static function TAB() : Int {
		return 9 ;
	}
	public static function CR() : Int {
		return 13;
	}
	public static function isSignificantWS(code : Int) {
		//newline, tab or carriage return
		return (code == TAB() || code == NEW_LINE() || code == CR());
	}
	public static function createDivTag(document : Document, className : String) : DivElement {
		var div : DivElement = cast document.getElementById(className);
		if (div == null) {
			div = cast document.createDivElement();
			div.id = className;
			div.className = className;
			document.body.appendChild(div);
		}
		return div;
	}


	public static function createInputElement(document : Document, 
		parent : DivElement, elementClass : String
		, elementName : String): Void {
		trace("Creating input element " + elementName);
		var div = createDivTag(document, elementClass);
		var inputElement = document.createInputElement();
		inputElement.id = elementName;
		div.appendChild(inputElement);
		parent.appendChild(div);
	}

	public static function createTextAreaElement(document : Document
		, parent : DivElement 
		, elementName : String
		, elementClass : String) : Void {
			trace("Creating text area element");
			var div = createDivTag(document, elementClass);
			var areaElement = document.createTextAreaElement();
			areaElement.id = elementName;
			div.appendChild(areaElement);
			parent.appendChild(div);
	}

	public static function createListElement(document : Document
		, parent : DivElement
		, elementClass : String
		, elementName : String) : Void {
			trace("Creating list element");
			var div = createDivTag(document, elementClass);
			var listElement = document.createUListElement();
			listElement.id = elementName;
			div.appendChild(listElement);
			parent.appendChild(div);
		}
	public static function createButtonElement (document : Document
		, parent : DivElement
		, elementClass : String
		, elementName : String): Void {
			trace("Creating button element");
			var div = createDivTag(document, elementClass);
			var element : ButtonElement = document.createButtonElement();
			element.value = elementName;
			element.id = elementName;
			element.innerHTML = elementName;
			div.appendChild(element);
			parent.appendChild(div);
		}
	public static function createSelectElement(document : Document 
					, parent : DivElement
					, elementClass : String
					, elementName : String){
			trace("Create selection element");
			var div = createDivTag(document, elementClass);
			var element : SelectElement = document.createSelectElement();
			element.id = elementName;
			div.appendChild(element);
			parent.appendChild(div);
		}

	public static function createElementWithLabel(document : Document
			, parent : DivElement, elementId : String, elementLabel : String) : Void{
			trace("Element id " + elementId + "->" + "Label " + elementLabel);
			var div = Util.createDivTag(document, DIV + elementLabel);
			var inputLabel = document.createLabelElement();
			var input = document.createInputElement();
			input.id = elementId;
			inputLabel.id = LABEL + elementId;
			inputLabel.innerHTML = elementLabel;
			div.appendChild(inputLabel);
            div.appendChild(input);
            parent.appendChild(div);
	}

	public static function createTextAreaElementWithLabel(document : Document
			, parent : DivElement
			, elementId : String 
			, elementLabel : String) : Void {
			
			var inputLabel = document.createLabelElement();
			inputLabel.id = LABEL + elementId;
			inputLabel.innerHTML = elementLabel;
			createTextAreaElement(document, parent, elementId, elementLabel);			
			var textAreaElement : Text = cast document.getElementById(elementId);

	}

	//Prefix: to maintain uniqueness
	private static var LABEL: String = "LABEL_";
	private static var DIV : String = "DIV_";
}