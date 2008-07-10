Raptor = Object.extend(Raptor, {
    effectTime: 0.50,
    embossSize: 10,

    // 'this' is set to the element passed to textInputWithList
    pickItem: function(event) {
	this.textInput.setValue(event.element().innerHTML);
	this.textInput.focus();
	Effect.Appear(this.showButton, {duration: Raptor.effectTime });
	Effect.BlindUp(this.absSpan, { duration: Raptor.effectTime });
    },

    // 'this' is set to the element passed to textInputWithList
    openList: function(event) {
	Effect.BlindDown(this.absSpan, { duration: Raptor.effectTime });
	Effect.Fade(this.showButton, {duration: Raptor.effectTime});
    },

    getHeight: function(ele) {
	var oldPos = ele.getStyle('position');
	ele.setStyle({ position: 'absolute' });
	var height = ele.getHeight();
	ele.setStyle({ position: oldPos });
	return height;
    },

    getWidth: function(ele) {
	var oldPos = ele.getStyle('position');
	ele.setStyle({ position: 'absolute' });
	var width = ele.getWidth();
	ele.setStyle({ position: oldPos });
	return width;
    },

    textInputWithList : function(ele) {
	ele.setStyle({ position: 'relative' });
	var textInput = ele.down('input');
	textInput.addClassName('input-list-text');
	ele.textInput = textInput;
	var inputHeight = Raptor.getHeight(textInput);
	var inputHeightPX = inputHeight + 'px';
	var right = (parseInt(textInput.getStyle('borderRightWidth')) +
		     parseInt(textInput.getStyle('paddingRight'))) + 'px';
	var bottom = (-parseInt(textInput.getStyle('borderBottomWidth'))) + 'px';
	textInput.remove();

	var showButton = new Element('img', { src: '/images/BlueArrow.png', alt: 'Show List of Choices' });
	showButton.setStyle({ width: inputHeightPX,
			      height: inputHeightPX,
			      position: 'absolute',
			      padding: '0px',
			      right: '0px',
			      bottom: bottom });
	showButton.addClassName('input-list-button');
	ele.showButton = showButton;

	var pickList = ele.down('span');
	ele.pickList = pickList;
	var listHeight = Raptor.getHeight(pickList) + 'px';
	var listWidth = Raptor.getWidth(pickList) + 'px';
	var listPaddingLeft = (parseInt(pickList.getStyle('borderLeftWidth')) +
			       parseInt(pickList.getStyle('marginLeft')) +
			       parseInt(pickList.getStyle('paddingLeft')));
	var savedLineHeight = pickList.getStyle('lineHeight');
	pickList.remove();

	var inputSpan = new Element('span', { position: 'relative' });
	inputSpan.setStyle({ position: 'relative' });
	inputSpan.addClassName('input-list-span');
	ele.inputSpan = inputSpan;

	inputSpan.appendChild(textInput);
	inputSpan.appendChild(showButton);
	ele.appendChild(inputSpan);

	var absSpan = new Element('span');
	ele.absSpan = absSpan;
	absSpan.setStyle({ position: 'absolute',
			   top: inputHeightPX,
			   left: '0px',
			   width: (Raptor.embossSize * 2 + parseInt(listWidth)) + 'px',
			   zIndex: '1',
			   lineHeight: '0px' });

	var imageSpan = new Element('span');
	var topRow = new Element('span');
	imageSpan.appendChild(topRow);
	var topLeft = new Element('img', { src: '/images/BlueBar_tl.gif', alt: 'Top Left Corner' });
	var embossSizePX = Raptor.embossSize + 'px';
	topLeft.setStyle({ width: embossSizePX,
			   height: embossSizePX });
	topRow.appendChild(topLeft);
	var topCenter = new Element('img', { src: '/images/BlueBar_top.gif', alt: 'Top Center' });
	topCenter.setStyle({ width: listWidth,
			     height: embossSizePX,
			     backgroundRepeat: 'repeat-x' });
	topRow.appendChild(topCenter);
	var topRight = new Element('img', { src: '/images/BlueBar_tr.gif', alt: 'Top Right Corner' });
	topRight.setStyle({ width: embossSizePX,
			   height: embossSizePX });
	topRow.appendChild(topRight);
	topRow.appendChild(new Element('br'));

	var midRow = new Element('span');
	imageSpan.appendChild(midRow);
	var midLeft = new Element('img', { src: '/images/BlueBar_left.gif', alt: 'Mid Left Corner' });
	midLeft.setStyle({ width: embossSizePX,
			   height: listHeight,
			   backgroundRepeat: 'repeat-y' });
	midRow.appendChild(midLeft);
	var midCenter = new Element('img', { src: '/images/BlueBar_center.gif', alt: 'Mid Center' });
	midCenter.setStyle({ width: listWidth,
			     height: listHeight,
			     backgroundRepeat: 'repeat' });
	midRow.appendChild(midCenter);
	var midRight = new Element('img', { src: '/images/BlueBar_right.gif', alt: 'Mid Right Corner' });
	midRight.setStyle({ width: embossSizePX,
			    height: listHeight,
			    backgroundRepeat: 'repeat-y' });
	midRow.appendChild(midRight);
	midRow.appendChild(new Element('br'));

	var botRow = new Element('span');
	imageSpan.appendChild(botRow);
	var botLeft = new Element('img', { src: '/images/BlueBar_bl.gif', alt: 'Bot Left Corner' });
	botLeft.setStyle({ width: embossSizePX,
			   height: embossSizePX });
	botRow.appendChild(botLeft);
	var botCenter = new Element('img', { src: '/images/BlueBar_bot.gif', alt: 'Bot Center' });
	botCenter.setStyle({ width: listWidth,
			     height: embossSizePX,
			     backgroundRepeat: 'repeat-x' });
	botRow.appendChild(botCenter);
	var botRight = new Element('img', { src: '/images/BlueBar_br.gif', alt: 'Bot Right Corner' });
	botRight.setStyle({ width: embossSizePX,
			    height: embossSizePX });
	botRow.appendChild(botRight);
	botRow.appendChild(new Element('br'));

	var pickListLeft = (Raptor.embossSize + listPaddingLeft) + 'px';
	var pickListTop = (Raptor.embossSize) + 'px';
	pickList.setStyle({ position: 'absolute',
			    left: pickListLeft,
			    lineHeight: savedLineHeight,
			    top: pickListTop,
			    zIndex: '2' });

	absSpan.appendChild(imageSpan);
	absSpan.appendChild(pickList);
	ele.appendChild(absSpan);
	absSpan.hide();

	showButton.observe('click', Raptor.openList.bindAsEventListener(ele));
	pickList.childElements().each(function (listElement) {
	    listElement.addClassName('pick-list-item');
	    listElement.observe('click', Raptor.pickItem.bindAsEventListener(ele));
	});
    },
});

// document.observe('dom:loaded', function() {
//     $$('.input-with-list').each(Raptor.textInputWithList);
// });
