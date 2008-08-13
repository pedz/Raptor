// Twisty.js
//
// Copyright (c) 2007 Red Hat, Inc.
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// 
// Provide a nice interface for creating disclosure triangles in a web page
// To use: 
//
// put onload="initTwisty();" in your <body> tag.
//
// You should have this in your style sheet:
//
//     .twisty:hover {
//      background-color: #f0f0f0;
//      border: 1px solid #e0e0e0;
//      margin-left: -1px;
//    }
//
//    .twisty {
//      cursor: hand;
//      cursor: pointer;
//    }
//
// When you have a section you wish to expose/hide, put:
//
// <div>Some Label <img class="twisty" src="twisty-down.gif" onclick="toggleTwisty('childid'); return false;">
//   <div id="childid">
//     <div>Some content</div>
//   </div>
// </div>

function setNewBaseSrc(ele, newBaseSrc) {
    var dirPath = ele.src.replace(/[^\/]*$/, '');
    ele.setAttribute('src', dirPath + newBaseSrc);
}

function hideTwisty (id) {
  var el = getElemById (id);
  var twisty;

  if (el) {
    setStyle (el, {display: 'none'});
  }

  for (var i = 0; i < el.parentNode.childNodes.length; i++) {
    if (el.parentNode.childNodes[i].nodeName == 'A') {
      var t = el.parentNode.childNodes[i];
      for (var j = 0; j < t.childNodes.length; j++) {
	if (t.childNodes[j].className == 'twisty')
	  twisty = t.childNodes[j];
      }
    }
  }
  
  if (typeof twisty != "undefined")
    setNewBaseSrc(twisty, 'twisty-hidden.gif');

}

function toggleTwisty (id) {
    var el = getElemById (id);
    var twisty;
    
    for (var i = 0; i < el.parentNode.childNodes.length; i++) {
      if (el.parentNode.childNodes[i].nodeName == 'A') {
	var t = el.parentNode.childNodes[i];
	for (var j = 0; j < t.childNodes.length; j++) {
	  if (t.childNodes[j].className == 'twisty')
	    twisty = t.childNodes[j];
	}
      }
    }
    

    var twisties = getElementsByClassName (document, "img", "twisty");

    for (var i = 0; i < twisties.length; i++) {
	if (twisties[i].src.indexOf('twisty-do-down.gif') != -1) {
	    setNewBaseSrc(twisties[i], 'twisty-down.gif');
	} else if (twisties[i].src.indexOf('twisty-do-hidden.gif') != -1) {
	    setNewBaseSrc(twisties[i], 'twisty-hidden.gif');
	}
    }
    
    if (el.style.display == "none") {
      if (typeof twisty != "undefined")
	setNewBaseSrc(twisty, 'twisty-do-down.gif');
      if (typeof Effect != "undefined") {
	Effect.toggle(id, "Slide", {duration:.4});
      } else {
	setStyle(el, {display: 'block'});
      }
    } else {
      if (typeof twisty != "undefined")
	setNewBaseSrc(twisty, 'twisty-do-hidden.gif');
      if (typeof Effect != "undefined") {
	Effect.toggle(id, "Slide", {duration:.4});
      } else {
	setStyle(el, {display: 'none'});
      }
    }
}


function getElementsByClassName(oElm, strTagName, strClassName){
  var arrElements = (strTagName == "*" && document.all)? document.all : oElm.getElementsByTagName(strTagName);
  var arrReturnElements = new Array();
  strClassName = strClassName.replace(/\-/g, "\\-");
  var oRegExp = new RegExp("(^|\\s)" + strClassName + "(\\s|$)");
  var oElement;
  for(var i=0; i<arrElements.length; i++){
    oElement = arrElements[i];
    if(oRegExp.test(oElement.className)){
      arrReturnElements.push(oElement);
    }
  }
  return (arrReturnElements);
}

function getElemById(aID){ 

  if (document.getElementById)
    return document.getElementById(aID);
  
  return document.all[aID];
}

function setStyle(element, style) {
  for (var name in style) {
    var value = style[name];
    element.style[name] = value;
  }
  return element;
}
