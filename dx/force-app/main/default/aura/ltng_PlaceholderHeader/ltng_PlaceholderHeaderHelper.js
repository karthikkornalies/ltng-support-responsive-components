({
	initializeComponent : function(component, helper) { // eslint-disable-line
		//-- eslint-disable-line is to avoid complaints we are not using arguments
		//-- component and helper are included as good practice
		//-- so they are available when they are needed

		//-- do any initialization here
		
        //-- allow for a blank subtitle due to spring 2019 attribute cleanup.
		var subTitle = component.get('v.subTitle');
        if (subTitle === '-') {
            subTitle = '';
            component.set('v.subTitle', subTitle);
        }
	}
})