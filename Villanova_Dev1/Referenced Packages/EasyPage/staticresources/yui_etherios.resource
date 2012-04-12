/*
Copyright (c) 2009, Etherios LLC All rights reserved.

This source code cannot be copied, modified, or reproduced without the direct written consent of Etherios LLC.
version: 1.0
*/		

// Create a namespace for our custom functions
	    YAHOO.namespace("etherios");
	
		var posX;
		var posY;
		
		function handleClick(oEvent) {
			var scrOfX = 0, scrOfY = 0;
			  if( typeof( window.pageYOffset ) == 'number' ) {
			    //Netscape compliant
			    scrOfY = window.pageYOffset;
			    scrOfX = window.pageXOffset;
			  } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
			    //DOM compliant
			    scrOfY = document.body.scrollTop;
			    scrOfX = document.body.scrollLeft;
			  } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
			    //IE6 standards compliant mode
			    scrOfY = document.documentElement.scrollTop;
			    scrOfX = document.documentElement.scrollLeft;
			  }
	        posX = oEvent.clientX + scrOfX;
	        posY = oEvent.clientY + scrOfY;
	    }	    

		
   

		YAHOO.etherios.init = function(){
	    	
	    		document.body.className = document.body.className + " yui-skin-sam";
	    		YAHOO.etherios.loader = new YAHOO.widget.Panel("loader", 
				{ 

	                    visible         :   false,  
	                    draggable       :   false,   
	                    close           :   true,  
	                    modal           :   true,   
	                    fixedCenter     :   true,   
	                    zindex          :   40,     // Make sure it's on top of everything
	                    
	                    // This line adds the appear/vanish fade effect
	                    effect          :   {
	                                          effect:YAHOO.widget.ContainerEffect.FADE,
	                                          duration:0.35
	                                        } 
	            }
			); 
			YAHOO.etherios.loader.render(document.body);
	    }
	    
		YAHOO.etherios.showLoader = function() {
        		document.getElementById("loader").style.display = "block";
        		YAHOO.etherios.loader.show();
    		}

	    YAHOO.etherios.hideLoader = function() {
	    	YAHOO.etherios.loader.hide();
	    }


	 	YAHOO.util.Event.addListener(window, "load", YAHOO.etherios.init);	