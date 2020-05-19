<methodSet decisionsYear="xs:gYear"? …> 
	<notes>{any}</notes>? 
	<properties> 
		<classification little="xs:boolean"? 	<<<
			differential="xs:boolean"? 
			plain="xs:boolean"? 
			trebleDodging="xs:boolean"?> 
		[Place | Bob | Slow Course | Treble Bob | Delight |
		 Surprise | Alliance | 	Treble Place | Hybrid]? 
		</classification>? 
		<stage> xs:positiveInteger </stage>? 			<<<<
		<lengthOfLead> xs:positiveInteger </lengthOfLead>? 		<<<<<
		<numberOfHunts> xs:nonNegativeInteger </numberOfHunts>? 		<<<<<
		<huntbellPath> list of xs:positiveInteger </huntbellPath>? 		<<<<<
		<leadHead> rowType </leadHead>? 			<<<<<
		<leadHeadCode> leadHeadCodeType </leadHeadCode>? 		<<<<<
		<falseness> 												<<<<<
			<falseCourseHeads "fixed=fixedType"> 
			<inCourse> list of rowType </inCourse> 
			<outOfCourse> list of rowType </outOfCourse> 
			</falseCourseHeads>* 
			<fchGroups affected="affectedType"?> fchGroupString </fchGroups>? 
		</falseness>? 
		<symmetry>list of [palindromic|double|rotational]</symmetry>? 			<<<<<
		<extensionConstruction>extensionType</extensionConstruction>? 			<<<<<
		<notes>{any}</notes>? 											<<<<<
		<meta>{any}</meta>? 					<<<<<
	</properties> 
	<method>methodType</method>* 
</methodSet> 


<method id="xs:ID"? decisionsYear="xs:gYear"? …> 
	<name> xs:token </name>? 
	<classification little="xs:boolean"? 
			differential="xs:boolean"? 
		plain="xs:boolean"? 
		trebleDodging="xs:boolean"?> 
		[Place | Bob | Slow Course | Treble Bob | Delight | 
		Surprise | Alliance | Treble Place | Hybrid] ? 
	</classification>? 
	<title> xs:token </title>? 
	<stage> xs:positiveInteger </stage>? 
	<notation> notationType </notation>? 
	<lengthOfLead> xs:positiveInteger </lengthOfLead>? 
	<numberOfHunts> xs:nonNegativeInteger </numberOfHunts>? 
	<huntbellPath> list of xs:positiveInteger </huntbellPath>? 
	<leadHead> rowType </leadHead>? 
	<leadHeadCode> leadHeadCodeType </leadHeadCode>? 
	<falseness> 
		<falseCourseHeads fixed="fixedType"> 
		<inCourse> list of rowType </inCourse> 
		<outOfCourse> list of rowType </outOfCourse> 
		</falseCourseHeads>* 
		<fchGroups affected="affectedType"?> fchGroupString </fchGroups>? 
	</falseness>? 
	<symmetry>list of [palindromic|double|rotational]</symmetry>? 
	<extensionConstruction>extensionType</extensionConstruction>? 
	<notes>{any}</notes>? 
	<meta>{any}</meta>? 
	<references><ref>+</references>? 
	<performances><performance>+</performances>? 
</method> 
