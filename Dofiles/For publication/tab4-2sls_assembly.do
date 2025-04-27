	
/*******************************************************************************
*  PROJECT:				Brigandage and Monarchical Legitimacy				   *
*																 			   *
*  PURPOSE:  			Estimate effect	of brigandage						   *
*						on constituent assembly voting outcomes			   	   *
*																			   *
*  WRITTEN BY:  	  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]   *
*  Last time modified:  April 2025										   	   *
*																			   *
********************************************************************************

	** REQUIRES:   		"${dt}/Brigandage_analysis_data.dta"
	
	** CREATES:	   		"${out}/tab4-2sls_assembly.tex"
		
------------------------------------------------------------------------------*/
							
	* Load analysis dataset (clean and merged)
	use "${dt}/Brigandage_analysis_data.dta" , clear
	
	* Check for unique identifier
	isid 					 comune
	
	* Specify regression variables and options
	local   command 		"ivreg2"
	local   standard_errors "rob"
	local   exogenousVar1 	 forest_dist
	local   exogenousVar2    Altitude
	local   endogenousVar    epi_tot_ihs
	local	coeflabel 		"Number of brigandage episodes (IHS)"			
		
	* Loop over outcome variables
	foreach outcomeVar in right_monarchy left_republic center_free  {
		
		* Estimate two-stage-least-squares regression...
		* ... with municipality controls
		eststo demo_ctrl :  `command' `outcomeVar' 						       ///
							Popolazione_1861 							       ///
							pop_growth density 							       ///
						 ( `endogenousVar' = `exogenousVar1' `exogenousVar2' ) ///
						 , `standard_errors' first
		
		di e(arf)
		
		mat 		   first 	 = e(first)
		estadd  scalar pr2	 	 =   first[3,1]
		weakivtest
		estadd  scalar eff_Fstat = r(F_eff) : demo_ctrl
		
		
		eststo eco_ctrl	 : `command' `outcomeVar' 						       ///
							Popolazione_1861 							       ///
							pop_growth density 							       ///
							archbishop bishop 							       ///
							collegi sec_school hospital manufact 		       ///
						 ( `endogenousVar' = `exogenousVar1' `exogenousVar2' ) ///
						 , `standard_errors' first
		
		di e(arf)
		
		mat 		   first 	 = e(first)	
		estadd  scalar pr2	 	 =   first[3,1]
		weakivtest
		estadd  scalar eff_Fstat = r(F_eff) : eco_ctrl
		
		
		* ... with region fixed effeinteractcts
		eststo region_FE : `command' `outcomeVar' 						       ///
							i.region_code 								       ///
							Popolazione_1861 							       ///
							pop_growth density 							       ///
							archbishop bishop 							       ///
							collegi sec_school hospital manufact 		       ///
						 ( `endogenousVar' = `exogenousVar1' `exogenousVar2' ) ///
						 , `standard_errors' first
		
		mat 		   first 	 = e(first)
		estadd  scalar pr2	 	 =   first[3,1]
		weakivtest
		estadd  scalar eff_Fstat = r(F_eff) : region_FE

		
		* ... with province fixed effects
		eststo prov_FE   : `command' `outcomeVar' 							   ///
							i.province_code 								   ///
							Popolazione_1861 								   ///
							pop_growth density 								   ///
							archbishop bishop 								   ///
							collegi sec_school hospital manufact 			   ///
						 ( `endogenousVar' = `exogenousVar1' `exogenousVar2' ) ///
						 , `standard_errors' first
		
		mat 		   first 	 = e(first)	
		estadd  scalar pr2	 	 =   first[3,1]
		weakivtest
		estadd  scalar eff_Fstat = r(F_eff) : prov_FE
		di e(arf)
		
		* ... with district fixed effects
		eststo dist_FE   : `command' `outcomeVar' 							   ///
							i.district_code 								   ///
							Popolazione_1861 								   ///
							pop_growth density 								   ///
							archbishop bishop 								   ///
							collegi sec_school hospital manufact 			   ///
						 ( `endogenousVar' = `exogenousVar1' `exogenousVar2' ) ///
						 , `standard_errors' first
		
		mat 		   first 	 = e(first)	
		estadd  scalar pr2	 	 =   first[3,1]
		weakivtest
		estadd  scalar eff_Fstat = r(F_eff) : dist_FE
		di e(arf)
		
		#d	;
		
			esttab   demo_ctrl
					  eco_ctrl
				   region_FE
					 prov_FE
					 dist_FE
					  
				using "${out}/`outcomeVar'.tex"
				
				,
				
				${esttabOptions}
				
					 keep(`endogenousVar')
				coeflabel(`endogenousVar' "\addlinespace[0.4em] \textbf{`coeflabel'}")
							 
					stats(N
		
						  eff_Fstat pr2
						  ,
						  lab("\addlinespace[0.6em] Number of observations"
		
							  "\addlinespace[0.2em] Effective first-stage \textit{F}-statistic"
												   "Partial \textit{R}-squared"
							 )
						 fmt(%12.0fc

							 %12.1fc %9.3f)
						 )
					   
					   b(%9.4f)
					  se(%9.4f)
			;
		#d	cr
	}		
				
				
	* Initiate final LaTeX file
	file close _all
	file open  final_table using "${out}/todelete.tex" , text write replace
				
	foreach outcomeVar in right_monarchy left_republic center_free  {
		
		file open panel_`outcomeVar' using "${out}/`outcomeVar'.tex" , text read
																				
		* Loop over lines of the LaTeX file and save everything in a local
		local `outcomeVar' ""				
		
			file read  panel_`outcomeVar' line										
		
		while r(eof) == 0 { 														
			
			local `outcomeVar' `" ``outcomeVar'' `line' "'								
			file read  panel_`outcomeVar' line										
		}																		
			file close panel_`outcomeVar'											
		
		sleep  ${sleepTime}
		erase "${out}/`outcomeVar'.tex" 								
	}																			
	
	* Append all locals as strings, add footnote and end of LaTeX environments																
	#d	;
		file write final_table
			 
			 "					   														         	  \\[-1.2em]		  " _n
			 "&(1) &(2) &(3) &(4) &(5)  											         	  	  \\[0.25em]  \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{6}{c}{\large \textbf{Monarchist Parties}}        	  \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `right_monarchy'											            [0.5em]   \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{6}{c}{\large \textbf{Anti-Monarchist Parties}}        \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `left_republic' 										   			   [0.5em]    \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{6}{c}{\large \textbf{Christian Democrats: Free Vote}} \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `center_free'"
		;
	#d	cr
	
	file close _all
		

* Clean up table			
cap erase	 	"${out}/tab4-2sls_assembly.tex"
	filefilter  "${out}/todelete.tex"  			  ///
				"${out}/tab4-2sls_assembly.tex" , ///
				from("[1em]") to("") replace	
	
	sleep 		 ${sleepTime}
	erase 		"${out}/todelete.tex"
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out}/tab4-2sls_assembly.tex":"${out}/tab4-2sls_assembly.tex"}"'
	
	
******************************** End of do-file ********************************	