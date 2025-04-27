		
/*******************************************************************************
*  PROJECT:				Brigandage and Monarchical Legitimacy				   *
*																 			   *
*  PURPOSE:  			Estimate effect	of brigandage repression			   *
*						on referendum voting outcomes			   			   *
*																			   *
*  WRITTEN BY:  	  	Matteo Ruzzante [matteo.ruzzante@u.northwestern.edu]   *
*  Last time modified:  April 2025										   	   *
*																			   *
********************************************************************************

	** REQUIRES:   		"${dt}/Brigandage_analysis_data.dta"
	
	** CREATES:	   		"${out}/tab6-srdd_assembly.tex"
		
------------------------------------------------------------------------------*/
	
	* Load analysis dataset (clean and merged)
	use "${dt}/Brigandage_analysis_data.dta" , clear
	
	* Fix border fixed effect
	fre	 	border
	replace border = "Apulia-Basilicata" if border == "Apulia"
	replace border = "Apulia-Basilicata" if border == "Basilicata"
	
	* Identify treated provinces
	fre 					       Provincia_1861
	gen     Pica_province = inlist(Provincia_1861 , "Abruzzo Ulteriore I"  ///
											      , "Calabria Ulteriore I" ///
											      , "Napoli" 			   ///
											      , "Terra di Bari"        ///
											      , "Terra d'Otranto"      ///
											  )
	replace Pica_province =   Pica_province == 0
	fre 	Pica_province
	tab 	Pica_province          Provincia_1861
	tab 	Pica_province          Regione_1861
	
	
	* Specify regression variables and options
	local   xVars "lat lon"
	
	* Loop over outcome variables
	foreach outcomeVar in right_monarchy left_republic center_free {
		
		eststo border_FE :                              		///
		areg  `outcomeVar' Pica_province `xVars' 				///
						 , a(border) vce(robust)
		
		sum	  `outcomeVar'  if e(sample) == 1
		estadd scalar N_     = r(N)
		
		sum	  `outcomeVar'  if e(sample) == 1 & Pica_province == 0
		estadd scalar y_mean = r(mean)
		
		
		estadd local prov  ""
		estadd local geo   ""
		estadd local demo  ""
		estadd local eco   ""
		
		eststo prov_ctrl :                     					///
		areg  `outcomeVar' Pica_province `xVars' 				///
						   youngm estate libarts farmers artist ///
						   fishermen duties tax_income publ_exp ///
						 , a(border) vce(robust)
		
		estadd local prov  "\checkmark"
		estadd local geo   ""
		estadd local demo  ""
		estadd local eco   ""
		
		eststo geo_ctrl :                                       ///				
		areg  `outcomeVar' Pica_province `xVars'				///
						   youngm estate libarts farmers artist ///
						   fishermen duties tax_income publ_exp ///
						   Altitude Raggedness					///
						 , a(border) vce(robust)
		
		estadd local prov  "\checkmark"
		estadd local geo   "\checkmark"
		estadd local demo  ""
		estadd local eco   ""
		
		eststo demo_ctrl :                                      ///					  
		areg  `outcomeVar' Pica_province `xVars'				///
						   youngm estate libarts farmers artist ///
						   fishermen duties tax_income publ_exp ///
						   Altitude Raggedness					///
						   Popolazione_1861 					///
						   pop_growth density					///
						 , a(border) vce(robust)
		
		estadd local prov  "\checkmark"
		estadd local geo   "\checkmark"
		estadd local demo  "\checkmark"
		estadd local eco   ""
		
		eststo eco_ctrl : 					                    ///	
		areg  `outcomeVar' Pica_province `xVars' 				///
						   youngm estate libarts farmers artist ///
						   fishermen duties tax_income publ_exp ///
						   Altitude Raggedness					///
						   Popolazione_1861 					///
						   pop_growth density					///
						   archbishop bishop 					///
						   collegi sec_school hospital manufact ///
						 , a(border) vce(robust)
		
		estadd local prov  "\checkmark"
		estadd local geo   "\checkmark"
		estadd local demo  "\checkmark"
		estadd local eco   "\checkmark"
		
		#d	;
		
			esttab border_FE
				   prov_ctrl
				   geo_ctrl
				   demo_ctrl
				   eco_ctrl
					  
				using "${out}/`outcomeVar'.tex"
				
				,
				
				${esttabOptions}
				
					 keep(Pica_province
						  )
				coeflabel(Pica_province "\addlinespace[0.4em] \textbf{Pica Law (0/1)}"
						  )
							 
					stats(y_mean
						  N_
						  r2_a
						  ,
						  lab("\addlinespace[0.6em] Sample mean of the outcome variable \\ \hspace{1em} in provinces without Pica Law"
							  "\addlinespace[0.2em] Number of observations"
							  "\addlinespace[0.2em] Adjusted \textit{R}-squared"
							 )
						 fmt(%9.3f %12.0fc %9.3f)
						 )
					   
					   b(%9.3f)
					  se(%9.3f)
			;
		#d	cr
	}


	* Initiate final LaTeX file
	file close _all
	file open  final_table using "${out}/todelete.tex" , text write replace
		
	* Append estimations in unique LaTeX file 								
	foreach outcomeVar in right_monarchy left_republic center_free {						
		
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
			 
			 "					   														              \\[-1.2em]		  " _n
			 "&(1) &(2) &(3) &(4) &(5) 	 											                  \\[0.25em]  \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{6}{c}{\large \textbf{Monarchist Parties}} 		      \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `right_monarchy'											            [0.5em]   \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{6}{c}{\large \textbf{Anti-Monarchist Parties}}        \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `left_republic' 											            [0.5em]   \midrule" _n
			 "\addlinespace[0.5em] \multicolumn{6}{c}{\large \textbf{Christian Democrats: Free Vote}} \\[-1em] \\ \midrule" _n
			 "\addlinespace[0.2em] `center_free'"
		;
	#d	cr
	
	file close _all
		
		
	* Clean up table			
	sleep 		 ${sleepTime}
cap erase	 	"${out}/tab6-srdd_assembly.tex"
	filefilter  "${out}/todelete.tex"  			    ///
				"${out}/tab6-srdd_assembly.tex" , ///
				from("[1em]") to("") replace	
	
	sleep 		 ${sleepTime}
	erase 		"${out}/todelete.tex"
	
	* Add link to the file (filefilter does not provide it automatically)
	di as text `"Open final file in LaTeX here: {browse "${out}/tab6-srdd_assembly.tex":"${out}/tab6-srdd_assembly.tex"}"'
		
		
******************************** End of do-file ********************************
	