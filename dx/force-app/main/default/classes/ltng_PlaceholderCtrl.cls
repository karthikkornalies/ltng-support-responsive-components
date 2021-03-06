/**
 * Controller for the Hero Button component.
 **/
public class ltng_PlaceholderCtrl {
    
    /** default resource URL **/
	public static final String DEFAULT_RESOURCE_URL = '/resource/ltng_TileLauncherHero';

	/** format of a static resource url **/
	public static final String STATIC_RESOURCE_URL_FORMAT = '/resource/{0}/{1}';

	/** format to split the custom permissions **/
	public static final String DELIMITER_PATTERN = ',';
	
	/**
	 * Determines the URL for a given static resource.
	 * <p>Not used for now as the shortcut /resource/ + resourceName
	 * 	is expected to remain for the foreseeable future.
	 *  This was included if that is ever not the case.</p>
	 * @param resourceName <String> - Developer/API name of the static resource.
	 **/
	@AuraEnabled(cacheable=true)
	public static String getResource( String resourceName ){
		String resultURL = DEFAULT_RESOURCE_URL;

		//try {
			resultURL = determineResourceURLs(resourceName);
		//} catch(Exception err){
		//	throw new AuraHandledException('unable to find static resource:' + resourceName);
		//}

		return resultURL;
	}

	//-- Helper Functions

	/**
	 * Convenience method for determining the URL for a single resource.
	 * @param resourceName (String) - API name for a single resource;
	 * @return String - url for that single resource.
	 **/
	public static String determineResourceURLs(String resourceName){
		Set<String> resourceAddresses = new Set<String>();
		resourceAddresses.add(resourceName);
		return determineResourceURLs(resourceAddresses).get(resourceName);
	}

	public static Map<String,String> determineResourceURLs(String[] resourceNames){
		Set<String> resourceAddresses = new Set<String>();
		resourceAddresses.addAll(resourceNames);
		return determineResourceURLs(resourceAddresses);
	}

	/**
	 * Given a list of resource api names, returns the corresponding URL for that resource.
	 * @param resourceNames (String[])
	 * @return Map<String,String> - map of those resource urls indexed by their name.
	 **/
	public static Map<String,String> determineResourceURLs(Set<String> resourceNames){
		Map<String,String> resourceUrlByName = new Map<String,String>();

		String resultURL;
		String timestamp;

		for (StaticResource resource : [
                SELECT Id, Name, SystemModstamp
                FROM StaticResource
                WHERE Name in :resourceNames
		]){
			timestamp = String.valueOf(resource.SystemModstamp.getTime());
			resultURL = String.format(STATIC_RESOURCE_URL_FORMAT,
				new String[]{ timestamp, resource.Name }
			);
			resourceUrlByName.put(resource.Name, resultURL);
		}

		return resourceUrlByName;
	}

	/**
	 * Determines if a user has access to a custom permission
	 * @param customPermissionName (String)
	 * @return Boolean
	 **/
	public static Boolean hasCustomPermission(String customPermissionName){
		if(String.isBlank(customPermissionName)){
			return(false);
		} else {
			customPermissionName = customPermissionName.trim();
		}
		return FeatureManagement.checkpermission(customPermissionName);
	}

	/**
	 * Determines if a user has access to custom permissions in a comma delimited list
	 * @param customPermissionsList (String) - comma separated list of custom permissions (ex: 'cPermission, cPermission2')
	 * @return Boolean - (true) if the user has access to any of the custom permissions list
	 **/
	public static Boolean hasAnyCustomPermission(String customPermissionsList){
		String[] customPermissions;
		
		if (customPermissionsList == null){
			return(false);
		}

		customPermissions = customPermissionsList.split(DELIMITER_PATTERN);
		for (String customPermission : customPermissions) {
			//-- succeed on one match
			if (hasCustomPermission(customPermission)){
				return true;
			}
		}

		return false;
	}
}