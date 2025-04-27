
<p align="center">
	<img src="https://github.com/MRuzzante/italy-brigandage-monarchy/raw/master/img/Northwestern-University-Symbol.png?raw=true")>
</p>


# Replication Package for "Brigandage and the Political Legacy of Monarchical Legitimacy in Southern Italy"
<span>&#x1f1e7;&#x1f1f7;</span> :it: :crown: :shield: :crossed_swords: :evergreen_tree: :mount_fuji: :hourglass_flowing_sand: :ballot_box: :scroll:

&nbsp;

This repository contains the codes that replicate the figures and tables presented in the paper "Brigandage and the Political Legacy of Monarchical Legitimacy in Southern Italy" (2025) by Matteo Ruzzante and Cristoforo Pizzimenti. [[PDF]](https://github.com/MRuzzante/italy-brigandage-monarchy/blob/master/Brigandage_Monarchy_Published.pdf) [[BibTeX]](https://github.com/MRuzzante/italy-brigandage-monarchy/blob/master/Brigandage_Monarchy_Citation.bib)
The individual do-files and R-scripts with their respective output are explained below.
The data are not publicly available.

&nbsp;


## Abstract
Political legitimacy plays a pivotal role in securing the effectiveness and longevity of a governing system,
yet it can be eroded by the way rulers handle popular uprisings.
This paper studies whether a historical shock in the legitimacy of monarchic rule can have long-term, intergenerational consequences on political attitudes.
The unification of Italy ignited a violent reaction against the new ruler in its southern provinces known as the ``Great Brigandage''.
We use fixed effects regressions with a wide set of controls and an instrumental variable approach based on military suitability of the terrain in order to show that, ceteris paribus, municipalities exposed to brigandage in the 1861--1870 period had lower turnout in the 1946 Institutional Referendum and were significantly less likely to vote for the survival of the monarchy.
Heterogeneity analysis leveraging a spatial discontinuity in martial law suggests that anti-monarchic sentiment likely stemmed from the collective memory of brigandage repression.
We interpret our findings as evidence that latent preferences toward political systems are endogenously shaped by historical events and can be brought to the surface by changes in the institutional environment.


## [Ungated Full Paper](https://github.com/MRuzzante/italy-brigandage-monarchy/blob/master/Brigandage_Monarchy_Published.pdf)


## Codes
The name of the do-files or R-script corresponds to the `.tex` or `.png` files to be created in the output folder.
All tables and figures were included &ndash; without further editing &ndash; in the TeX source file behind the published version of the paper.

The `MAIN_brigands.do` file executes the following codes:

<details title="tables">
	<summary>
		<font size="5">
			<strong><em>
				Tables
			</strong></em>
		</font>
	</summary>
	<ol>
		<li><code>tab1-ols_referendum.do</code> estimates and produces Table 1: *Effect of Brigandage on Referendum Voting Outcomes -- OLS Estimates*.</li>
		<li><code>tab2-ols_assembly</code> estimates and produces Table 2: *Effect of Brigandage on Constituent Assembly Voting Outcomes -- OLS Estimates*.</li>
		<li><code>tab3-2sls_referendum.do</code> estimates and produces Table 3: *Effect of Brigandage on Referendum Voting Outcomes -- 2SLS Estimates*.</li>
		<li><code>tab4-2sls_assembly.do</code> estimates and produces Table 4: *Effect of Brigandage on Constituent Assembly Voting Outcomes -- 2SLS Estimates*.</li>
		<li><code>tab5-srdd_referendum.do</code> estimates and produces Table 5: *Effect of Brigandage Repression on Referendum Voting Outcomes -- Spatial RDD Estimates*.</li>
		<li><code>tab6-srdd_assembly.do</code> estimates and produces Table 6: *Effect of Brigandage Repression on Constitutional Assembly Voting Outcomes -- Spatial RDD Estimates*.</li>
	</ol>
</details>


## Contact
If you have any comment, suggestion or request for clarifications, you can contact Matteo Ruzzante at <a href="mailto:matteo.ruzzante@u.northwestern.edu">matteo.ruzzante@u.northwestern.edu</a> or directly open an issue or pull request in this GitHub repository.</p>

&nbsp;

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.