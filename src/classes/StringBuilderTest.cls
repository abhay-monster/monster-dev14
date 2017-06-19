@isTest
private class StringBuilderTest {
    
    private static testMethod void testStringBuilder1()
    {
        StringBuilder sb = StringBuilder.NewStringBuilder();
        sb.Append('HAPPY HOLIDAYS!');
        System.assertNotEquals(sb.AsString(), '');
        System.assertNotEquals(sb.AsString(), null);
    }
    
    static testMethod void testStringBuilder2()
    {
        StringBuilder sb = StringBuilder.NewWithFirstValue('THIS IS A TEST FOR CLOUD SHERPAS');
        sb.Append('This is the second line');
        System.assertNotEquals(sb.AsString(), '');
        System.assertNotEquals(sb.AsString(), null);
        System.assert(sb.AsString().contains('CLOUD SHERPAS'));
    }
    
    static testMethod void testStringBuilder3()
    {
        StringBuilder sb = StringBuilder.NewWithFirstValue('THIS IS A TEST FOR CLOUD SHERPAS');
        sb.Clear();
        System.assertEquals(sb.AsString(), '');
        System.assert(sb.AsString().contains('CLOUD SHERPAS') == false);
    }
    
    static testMethod void testStringBuilder4()
    {
        StringBuilder sb = StringBuilder.NewStringBuilder();
        sb.AppendLine('CLOUD SHERPAS');
        sb.Append('ROCKS!');
        System.assertNotEquals(sb.AsString(), '');
        System.assertNotEquals(sb.AsString(), null);
        System.assert(sb.AsString().contains('\r\n'));
    } 
}