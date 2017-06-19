// helper class to hold classes and trigger data to help determine code coverage
	public class CodeCov_ApexClass {
	       public String className { get; set; }
	       public Integer classSize { get; set; }
	       public Id classCreatedBy{ get; set; }
	       public Id classLastModifiedBy{ get; set; }
	       public String classBody{ get; set; }
	       public Integer	  classIsTestClass{ get; set; }
	       public Integer    classAssertCount{ get; set; }
	       public Integer 	  classSeeAllData{ get; set; }
	       public Datetime lastModifiedDate{ get; set; }

		   // constructor
		   public CodeCov_ApexClass(String name, Integer size, Id createdBy, 
				   			Id lastModifiedBy,String body,Integer IsTestClass,Integer AssertCount,Integer SeeAllData, Datetime lastModifiedDate) {
		      this.className = name;
		      this.classSize = size;
		      this.classCreatedBy = createdBy;
		      this.classLastModifiedBy = lastModifiedBy;
		      this.classBody = body;
		      this.classIsTestClass = IsTestClass;
		      this.classAssertCount = AssertCount;
		      this.classSeeAllData = SeeAllData;
		      this.lastModifiedDate = lastModifiedDate;
		   } // end constructor

	 }	// end in class ApexClass