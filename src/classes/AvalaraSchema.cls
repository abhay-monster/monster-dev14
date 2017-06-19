public with sharing class AvalaraSchema {
    public static final String JURIS_TYPE_STATE = 'State';
    public static final String JURIS_TYPE_COUNTY = 'County';
    public static final String JURIS_TYPE_CITY = 'City';
    public static final String JURIS_TYPE_SPECIAL = 'Special'; 
        
    public class RequestHeader{
        public String EndPoint {set; get{
            return EndPoint != null ? EndPoint : Utility.getWebServiceEnpoint('AvalaraDev');
        }}
        public String Username;
        public String Password;
        public String Client;
        public String CompanyCode;
        public String Method {
            get{
                return Method == null ? 'POST' : Method;
            }set;
        }
        public String Country;
    }   
    virtual class JSONSerializable{
        public String serialize(){
            return JSON.serializePretty(this).replace('IsToCommitDocument', 'Commit');
        }
    }
    //GetTax Schema Start-----------------test
    public class GetTaxResponse{
        public String DocCode;
        public Date DocDate;
        public String TimeStamp;
        public Decimal TotalAmount;
        public Decimal TotalDiscount;
        public Decimal TotalExemption;
        public Decimal TotalTaxable;
        public Decimal TotalTax;
        public Decimal TotalTaxCalculated;
        public Date TaxDate;
        public TaxLine[] TaxLines;
        public TaxDetail[] TaxSummary;
        public TaxAddress[] TaxAddresses;
        public String ResultCode;
        public Message[] Messages;
    }
    
    public class GetTaxErrorResponse{
        public String ResultCode;
        public Message[] Messages;
    }
    
    public class TaxLine{
        public String LineNo;
        public String TaxCode;
        public String Taxability;
        public Decimal Taxable;
        public Decimal Rate;
        public Decimal Tax;
        public Decimal Discount;
        public Decimal TaxCalculated;
        public Decimal Exemption;
        public String BoundaryLevel;
        public TaxDetail[] TaxDetails;
    }
    
    public class TaxDetail{
        public String Country;
        public String JurisName;
        public String JurisType;
        public String JurisCode;
        public Decimal Rate;
        public String Region;
        public Decimal Tax;
        public Decimal Taxable;
        public String TaxName;
    }
    
    public class TaxAddress{
        public String Address;
        public String AddressCode;
        public String City;
        public String Region;
        public String Country;
        public String PostalCode;
        public Decimal Latitude;
        public Decimal Longitude;
        public String TaxRegionId;
        public String JurisCode;
    }
    
    public class GetTaxRequest  extends JSONSerializable{
        public String CustomerCode;
        public Date DocDate;
        public String CompanyCode;
        public String IsToCommitDocument;
        public String CurrencyCode;
        public String CustomerUsageType;
        public Decimal Discount;
        public String DocCode;
        public String PurchaseOrderNo;
        public String ExemptionNo;
        public String DetailLevel;
        public String DocType;
        public Line[] Lines;
        public Address[] Addresses;
        public String ReferenceCode;
        public String PosLaneCode;
        public String Client;
        public TaxOverride TaxOverride;
        public String BusinessIdentificationNo;
    }
    
    public class Line{
        public String LineNo;
        public String DestinationCode;
        public String OriginCode;
        public String ItemCode;
        public String TaxCode;
        public String CustomerUsageType;
        public String Description;
        public Decimal Qty;
        public Decimal Amount;
        public String Discounted;
        public String TaxIncluded;
        public String Ref1;
        public String Ref2;
        public TaxOverride TaxOverride;
    }
    
    public class Address{
        public String AddressCode;
        public String Line1;
        public String Line2;
        public String Line3;
        public String City;
        public String Region;
        public String Country;
        public String PostalCode;
        public Decimal Latitude;
        public Decimal Longitude;
        public String TaxRegionId;
        //Field used in address validation response
       /* public String ResultCode;
        public String PostNet;
        public String CarrierRoute;
        public String FipsCode;
        public String AddressType;
        public Message[] Messages;*/
    }
    // This inner class is used for address validation.
     public class Address2 extends JSONSerializable{
        public String AddressCode;
        public String Line1;
        public String Line2;
        public String Line3;
        public String City;
        public String Region;
        public String Country;
        public String PostalCode;
        public Decimal Latitude;
        public Decimal Longitude;
        public String TaxRegionId;
        //Field used in address validation response
        public String ResultCode;
        public String PostNet;
        public String CarrierRoute;
        public String FipsCode;
        public String AddressType;
        public Message[] Messages;
    }
    public class TaxOverride{
        public String TaxOverrideType;
        public Decimal TaxAmount;
        public Date TaxDate;
        public String Reason;
    }
    
    public class Message{
        public String Name;
        public String Summary;
        public String Details;
        public String Severity;
        public String RefersTo;
        public String Source;
        public String HelpLink;
    } 
    //GetTax Schema End-----------------
}