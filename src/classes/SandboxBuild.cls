// 
// (c) 2016 Appirio, Inc.
//
// This class is a script that runs after a sandbox refresh has occurred
// main use case is for modifying custom settings so that production endpoints
// are not hit
//
// 21 Jul 2016 - Jeff Lescarbeau - Initial creation/POC for custom settings
//
global class SandboxBuild implements SandboxPostCopy{
	final String CLASSNAME = '\n\n**** SandboxBuild.METHODNAME()';


	global void runApexClass(SandboxContext context){
		final string METHODNAME = CLASSNAME.replace('METHODNAME','runApexClass');
		system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

		

		//new methods in helper class
		SandboxBuildHelper sbh = new SandboxBuildHelper();
		sbh.updateIntegrationSettings();
		sbh.updateTaxNowSettings();
		sbh.updateApttusURLs();
		sbh.updateEmails();
		sbh.updateEmailtoCase();
	}
}