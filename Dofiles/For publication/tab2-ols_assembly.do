		
/*******************************************************************************
*  PROJECT:				Brigandage and Monarchical Legitimacy				   *
*																 			   *
*  PURPOSE:  			Estimate effect	of brigandage						   *
*						on constituent assembly voting outcomes				   *
*																			   *
*  WRITTEN BY:  	  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]   *
*  Last time modified:  April 2025										   	   *
*																			   *
********************************************************************************

	** REQUIRES:   		"${dt}/Brigandage_analysis_data.dta"
	
	** CREATES:	   		"${out}/tab2-ols_assembly.tex"
		
------------------------------------------------------------------------------*/
	
	* Load analysis dataset (clean and merged)
	use "${dt}/Brigandage_analysis_data.dta" , clear
	
	* Check for unique identifier
	isid 					 comune
		
	* Add variables needed to run Conley standard errors program
	gen  		  year = 0
	
	tab    region_code , gen(region)
	tab  province_code , gen(province)
	tab  district_code , gen(district)
	
	* Specify regression variables and options
	local explanatoryVar epi_tot_ihs
	local coeflabel 	 "Number of brigandage episodes (IHS)"
	local weight 		 ""
	local vce			 "vce(robust)"
	
	* Loop over outcome variables
	foreach outcomeVar in right_monarchy left_republic center_free  {
		
		* Estimate least-squares regression...
		* ... with region fixed effects
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   region?											///
							  `weights' 					 		        	///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(10)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_10 = string(pvalue , "%9.3f")
		
		
		* Correct p-values for spatial correlation
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   region?											///
							  `weights' 					 		        	///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(25)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_25 = string(pvalue , "%9.3f")
		
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   region?											///
							  `weights' 					 		        	///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(50)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_50 = string(pvalue , "%9.3f")
		
		
		
		eststo region_FE     : reghdfe                                      	///
							  `outcomeVar' `explanatoryVar'                 	///
						      `weights' 					 		        	///
						     , a(Regione_1861) `vce'
						   
		
		estadd local spatial_pvalue_10 = "[`pvalue_str_10']"
		estadd local spatial_pvalue_25 = "\{`pvalue_str_25'\}"
		estadd local spatial_pvalue_50 = "$\langle$`pvalue_str_50'$\rangle$"
		
		estadd local region "\checkmark"
		estadd local prov_  ""
		estadd local prov   ""
		estadd local dist   ""
		estadd local geo    ""
		estadd local demo   ""
		estadd local eco    ""
		
		sum							 `outcomeVar' 	  if e(sample) == 1
		estadd scalar y_mean   = r(mean)
		
		sum							 `explanatoryVar' if e(sample) == 1
		estadd scalar x_mean   = r(mean)
		estadd scalar N_	   = r(N)
		
		
		
		* ... with province controls
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   region?											///
							   youngm estate libarts  farmers artist 			///
							   fishermen duties tax_income publ_exp				///
							  `weights' 					 		        	///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(10)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_10 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   region?											///
							   youngm estate libarts  farmers artist 			///
							   fishermen duties tax_income publ_exp				///
							  `weights' 					 		        	///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(25)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_25 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   region?											///
							   youngm estate libarts  farmers artist 			///
							   fishermen duties tax_income publ_exp				///
							  `weights' 					 		        	///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(50)
							   
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_50 = string(pvalue , "%9.3f")
		
		eststo prov_ctrl 	 : reghdfe 							            	///
							  `outcomeVar' `explanatoryVar'		            	///
							   youngm estate libarts  farmers artist 	    	///
							   fishermen duties tax_income publ_exp 	    	///
						      `weights'											///
						     , a(Regione_1861) `vce'
		
		estadd local spatial_pvalue_10 = "[`pvalue_str_10']"
		estadd local spatial_pvalue_25 = "\{`pvalue_str_25'\}"
		estadd local spatial_pvalue_50 = "$\langle$`pvalue_str_50'$\rangle$"
	
		estadd local region "\checkmark"
		estadd local prov_  "\checkmark"
		estadd local prov   ""
		estadd local dist   ""
		estadd local geo    ""
		estadd local demo   ""
		estadd local eco    ""
		
		
		* ... with province fixed effects
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   province? province??								///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(10)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_10 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   province? province??								///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(25)
						   
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_25 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
							   province? province??								///
							 , lat(lat) lon(lon) 								///
							   timevar(year) panelvar(comune_code)				///
							   distcutoff(50)
						   
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_50 = string(pvalue , "%9.3f")
		
		eststo prov_FE       : reghdfe 									   	 	///
							  `outcomeVar' `explanatoryVar' 			    	///
						      `weights'				      						///
						     , a(Provincia_1861) `vce'
		
		estadd local spatial_pvalue_10 = "[`pvalue_str_10']"
		estadd local spatial_pvalue_25 = "\{`pvalue_str_25'\}"
		estadd local spatial_pvalue_50 = "$\langle$`pvalue_str_50'$\rangle$"
		
		estadd local region ""
		estadd local prov_  ""
		estadd local prov   "\checkmark"
		estadd local dist   ""
		estadd local geo    ""
		estadd local demo   ""
		estadd local eco    ""
		
		
		* ... with district fixed effects
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(10)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_10 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(25)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_25 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(50)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_50 = string(pvalue , "%9.3f")
		
		eststo dist_FE       : reghdfe `outcomeVar' `explanatoryVar'  			///
						      `weights'				      						///
						     , a(Circondario_1861) `vce'
		
		estadd local spatial_pvalue_10 = "[`pvalue_str_10']"
		estadd local spatial_pvalue_25 = "\{`pvalue_str_25'\}"
		estadd local spatial_pvalue_50 = "$\langle$`pvalue_str_50'$\rangle$"
		
		estadd local region ""
		estadd local prov_  ""
		estadd local prov   ""
		estadd local dist   "\checkmark"
		estadd local geo    ""
		estadd local demo   ""
		estadd local eco    ""
		
		
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Altitude Raggedness lat lon						///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(10)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_10 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Altitude Raggedness lat lon						///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(25)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_25 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Altitude Raggedness lat lon						///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(50)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_50 = string(pvalue , "%9.3f")
		
		eststo geo_ctrl	     : reghdfe 											///
							  `outcomeVar' `explanatoryVar'						///
						       Altitude Raggedness lat lon 						///
						      `weights'											///
						     , a(Circondario_1861) `vce'
		
		estadd local spatial_pvalue_10 = "[`pvalue_str_10']"
		estadd local spatial_pvalue_25 = "\{`pvalue_str_25'\}"
		estadd local spatial_pvalue_50 = "$\langle$`pvalue_str_50'$\rangle$"
		
		estadd local region ""
		estadd local prov_  ""
		estadd local prov   ""
		estadd local dist   "\checkmark"
		estadd local geo    "\checkmark"
		estadd local demo   ""
		estadd local eco    ""
		
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Popolazione_1861 								///
						       pop_growth density 								///
						       Altitude Raggedness lat lon						///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(10)
						   
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_10 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Popolazione_1861 								///
						       pop_growth density 								///
						       Altitude Raggedness lat lon						///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(25)
						   
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_25 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Popolazione_1861 								///
						       pop_growth density 								///
						       Altitude Raggedness lat lon						///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(50)
						   
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_50 = string(pvalue , "%9.3f")
		
		eststo demo_ctrl     : reghdfe 											///
							  `outcomeVar' `explanatoryVar'		  	    		///
							   Altitude Raggedness lat lon 			    		///
							   Popolazione_1861 								///
							   pop_growth density 								///
						      `weights' 										///
						     , a(Circondario_1861) `vce'
		
		estadd local spatial_pvalue_10 = "[`pvalue_str_10']"
		estadd local spatial_pvalue_25 = "\{`pvalue_str_25'\}"
		estadd local spatial_pvalue_50 = "$\langle$`pvalue_str_50'$\rangle$"
		
		estadd local region ""
		estadd local prov_  ""
		estadd local prov   ""
		estadd local dist   "\checkmark"
		estadd local geo    "\checkmark"
		estadd local demo   "\checkmark"
		estadd local eco    ""
		
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Popolazione_1861 								///
						       pop_growth density 								///
						       Altitude Raggedness lat lon						///
						       archbishop bishop 								///
						       collegi sec_school hospital manufact 			///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(10)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_10 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Popolazione_1861 								///
						       pop_growth density 								///
						       Altitude Raggedness lat lon						///
						       archbishop bishop 								///
							   collegi sec_school hospital manufact 			///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(25)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_25 = string(pvalue , "%9.3f")
		
		ols_spatial_HAC       `outcomeVar' `explanatoryVar'           			///
						       district? district??								///
						       Popolazione_1861 								///
						       pop_growth density 								///
						       Altitude Raggedness lat lon						///
						       archbishop bishop 								///
						   	   collegi sec_school hospital manufact 			///
						     , lat(lat) lon(lon) 								///
						       timevar(year) panelvar(comune_code)				///
						       distcutoff(50)
		
		mat    table         = r(table)
		scalar pvalue        = table[4,1]
		local  pvalue_str_50 = string(pvalue , "%9.3f")
		
		eststo eco_ctrl	     : reghdfe 											///
							  `outcomeVar' `explanatoryVar'			            ///
							   Altitude Raggedness lat lon 			            ///
							   Popolazione_1861 						        ///
							   pop_growth density 						        ///
							   archbishop bishop 						        ///
							   collegi sec_school hospital manufact 	        ///
						      `weights'											///
						      , a(Circondario_1861) `vce'
		
		estadd local spatial_pvalue_10 = "[`pvalue_str_10']"
		estadd local spatial_pvalue_25 = "\{`pvalue_str_25'\}"
		estadd local spatial_pvalue_50 = "$\langle$`pvalue_str_50'$\rangle$"
		
		estadd local region ""
		estadd local prov_  ""
		estadd local prov   ""
		estadd local dist   "\checkmark"
		estadd local geo    "\checkmark"
		estadd local demo   "\checkmark"
		estadd local eco    "\checkmark"
		
		#d	;
		
			esttab region_FE
					 prov_ctrl
					 prov_FE
					 dist_FE
					  geo_ctrl
					 demo_ctrl
					  eco_ctrl
					  
				using "${out}/`outcomeVar'_`explanatoryVar'.tex"
				
				,
				
				${esttabOptions}
				
					 keep(`explanatoryVar')
				coeflabel(`explanatoryVar' "\addlinespace[0.4em] \textbf{`coeflabel'}")
							 
					stats(spatial_pvalue_10
						  spatial_pvalue_25
						  spatial_pvalue_50
						  y_mean x_mean
						  N_
						  r2_a
						  ,
						  lab("\addlinespace[0.2em] \textit{p}-values corrected for spatial correlation"
							  " "
							  " "
							  "\addlinespace[0.6em] Sample mean of the outcome variable"
												   "Sample mean of the explanatory variable"
							  "\addlinespace[0.2em] Number of observations"
							  "\addlinespace[0.2em] Adjusted \textit{R}-squared"
							 )
						 fmt(0 0 0 %9.3f %9.3f %12.0fc %9.3f)
						 )
					   
					   b(%9.4f)
					  se(%9.4f)
			;
		#d	cr
	}
	
	
	* Initiate final LaTeX file
	file close _all
	file open  final_table using "${out}/todelete.tex" , text write replace
		
	* Append estimations in unique LaTeX file 								
	foreach outcomeVar in right_monarchy left_republic center_free  {
		
		file open panel_`outcomeVar' using "${out}/`outcomeVar'_`explanatoryVar'.tex" , text read
																				
		* Loop over lines of the LaTeX file and save everything in a local
		local `outcomeVar' ""				
		
			file read  panel_`outcomeVar' line										
		
		while r(eof) == 0 { 														
			
			local `outcomeVar' `" ``outcomeVar'' `line' "'								
			file read  panel_`outcomeVar' line										
		}																		
			file close panel_`outcomeVar'											
		
		sleep  ${sleepTime}
		erase "${out}/`outcomeVar'_`explanatoryVar'.tex" 								
	}																			
	
	* Append all locals as strings, add footnote and end of LaTeX environments
	#d	;
		file write final_table
			 
			 "					   														         	  \\[-1.2em]		  " _n
			 "&(1) &(2) &(3) &(4) &(5) &(6) &(7) 										         	  \\[0.25em]  \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{8}{c}{\large \textbf{Monarchist Parties}}        	  \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `right_monarchy'											            [0.5em]   \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{8}{c}{\large \textbf{Anti-Monarchist Parties}}        \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `left_republic' 										   			   [0.5em]    \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{8}{c}{\large \textbf{Christian Democrats: Free Vote}} \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `center_free'"
		;
	#d	cr
	
	file close _all
		
		
	* Clean up table			
	sleep 		 ${sleepTime}
cap erase	 	"${out}/todelete_.tex"
	filefilter  "${out}/todelete.tex"  		   ///
				"${out}/todelete_.tex" 		   ///
				, 							   ///
				from("0.000") to("$<$0.001")   replace
				
cap erase 		"${out}/tab2-ols_assembly.tex"
	sleep 		 ${sleepTime}
	filefilter  "${out}/todelete_.tex" 	       ///
				"${out}/tab2-ols_assembly.tex" ///
				 ,						       ///
				   from("[1em]") to("")
	
	sleep 		 ${sleepTime}
	erase 		"${out}/todelete.tex"
	
	sleep 		 ${sleepTime}
	erase 		"${out}/todelete_.tex"
		
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out}/tab2-ols_assembly.tex":"${out}/tab2-ols_assembly.tex"}"'

	
******************************** End of do-file ********************************
