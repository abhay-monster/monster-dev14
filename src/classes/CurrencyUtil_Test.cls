@isTest
public class CurrencyUtil_Test {
	
	static testMethod void testCurrencyUtil(){
		Test.startTest();
		CurrencyUtil currUtil = new CurrencyUtil();
		Set<String> isoSet = new Set<String>{'AED','AUD','USD'};
		currUtil = new CurrencyUtil(isoSet);
		Decimal amt = 123.5;
		Decimal d = currUtil.convertToUSD('AUD',amt);
		Decimal expected = 110.573909929268511057390992926851;
		//System.assertEquals(expected, d, 'Assertion Failed');
		d = currUtil.convertCurrency('USD', amt, 'AUD');
		Test.stopTest();
	}
}