/*
	Developed by Robert Nyman, http://www.robertnyman.com
	Code/licensing: http://code.google.com/p/getelementsbyclassname/
*//*
var getElementsByClassName = function (className, tag, elm){
	if (document.getElementsByClassName) {
		getElementsByClassName = function (className, tag, elm) {
			elm = elm || document;
			var elements = elm.getElementsByClassName(className),
				nodeName = (tag)? new RegExp("\\b" + tag + "\\b", "i") : null,
				returnElements = [],
				current;
			for(var i=0, il=elements.length; i<il; i+=1){
				current = elements[i];
				if(!nodeName || nodeName.test(current.nodeName)) {
					returnElements.push(current);
				}
			}
			return returnElements;
		};
	}
	else if (document.evaluate) {
		getElementsByClassName = function (className, tag, elm) {
			tag = tag || "*";
			elm = elm || document;
			var classes = className.split(" "),
				classesToCheck = "",
				xhtmlNamespace = "http://www.w3.org/1999/xhtml",
				namespaceResolver = (document.documentElement.namespaceURI === xhtmlNamespace)? xhtmlNamespace : null,
				returnElements = [],
				elements,
				node;
			for(var j=0, jl=classes.length; j<jl; j+=1){
				classesToCheck += "[contains(concat(' ', @class, ' '), ' " + classes[j] + " ')]";
			}
			try	{
				elements = document.evaluate(".//" + tag + classesToCheck, elm, namespaceResolver, 0, null);
			}
			catch (e) {
				elements = document.evaluate(".//" + tag + classesToCheck, elm, null, 0, null);
			}
			while ((node = elements.iterateNext())) {
				returnElements.push(node);
			}
			return returnElements;
		};
	}
	else {
		getElementsByClassName = function (className, tag, elm) {
			tag = tag || "*";
			elm = elm || document;
			var classes = className.split(" "),
				classesToCheck = [],
				elements = (tag === "*" && elm.all)? elm.all : elm.getElementsByTagName(tag),
				current,
				returnElements = [],
				match;
			for(var k=0, kl=classes.length; k<kl; k+=1){
				classesToCheck.push(new RegExp("(^|\\s)" + classes[k] + "(\\s|$)"));
			}
			for(var l=0, ll=elements.length; l<ll; l+=1){
				current = elements[l];
				match = false;
				for(var m=0, ml=classesToCheck.length; m<ml; m+=1){
					match = classesToCheck[m].test(current.className);
					if (!match) {
						break;
					}
				}
				if (match) {
					returnElements.push(current);
				}
			}
			return returnElements;
		};
	}
	return getElementsByClassName(className, tag, elm);
};*/

function gup( name )
{
	name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regexS = "[\\?&]"+name+"=([^&#]*)";
	var regex = new RegExp( regexS );
	var results = regex.exec( window.location.href );
	if( results == null )
		return "";
	else
		return results[1];
}

function setInitialTopic()
{
	var initial = gup("initial");
	setTopic( initial );

	// Hook up onclick handlers for anchors
	var allTreeLinks = parent.toc.document.getElementById("helpTreeId").getElementsByTagName("a" ); 

   	for (var i=0; i<allTreeLinks.length; ++i)
   	{
	   	var par = allTreeLinks[i].parentNode;

	   	if ( par.className=="htLink" || par.className=="htLinkSelected" )
	   	{
	   		allTreeLinks[i].onclick = function() { onSetTopicClick(this); }
		}		   		
	}
}

function setTopic( topicId )
{
	if ( null==topicId || ""==topicId )
		return;
		
	internalSetTopic( topicId.toLowerCase(), true );
}

function internalSetTopic( topicId, setURL )
{
	var allTreeLinks = parent.toc.document.getElementById("helpTreeId").getElementsByTagName("a" ); 
	var page = "";

	// Find the page
   	for (var i=0; i<allTreeLinks.length; ++i)
   	{
   		if ( allTreeLinks[i].id == topicId )
   		{
			page = allTreeLinks[i].href;
   			break;
   		}
	}
	
	// If we found a page, set the selection
	if ( "" != page )
	{	
	   	for (var i=0; i<allTreeLinks.length; ++i)
	   	{
		   	var par = allTreeLinks[i].parentNode;
		   	
		   	if ( par.className == "htLink" )
		   	{
		   		if ( allTreeLinks[i].id == topicId )
		   			par.className = "htLinkSelected";
			}		   		
		   	else if ( par.className == "htLinkSelected" )
		   	{
		   		if ( allTreeLinks[i].id != topicId )
		   			par.className = "htLink";
			}		   		
		}
	}
	
	if ( setURL && ""!=page )
	{
		parent.content.location.href = page;
	}

}


function onSetTopicClick(elem)
{
	internalSetTopic( elem.id, false );
}



function displayOrPopup(topic)
{
	if ( null!=window.parent && null!=window.parent.setTopic && window!=window.parent )
	{
		window.parent.setTopic(topic);
	}
	else
	{
	    win = window.open( 'MSOMainFrame.html?initial=' + topic, '_blank', 'width=800,height=800,resizable=yes,toolbar=yes,status=no,scrollbars=yes,menubar=yes,directories=no,location=no', false);
	    win.focus();
	}
}


