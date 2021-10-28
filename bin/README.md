The *Rupture_areas_OF* generates rupture areas, according to prescribed magnitude-size scaling, starting from a barycenter selection over the selected fault surface.
It can either use the precomputed barycenter selection from the preprocess module *ind_baryc_pre.m* or define this selection on-the-fly during the run. This latter procedure, however, significantly enlarge the computational time.

It can work in two modes:

 - Hazard: it computes all the possible different rupture areas (according to the previous barycenters selection) in the prescribed magnitude bins

 - PTF: it computes all the scenarios “compatible” with estimation and uncertainty of magnitude and location for a given earthquake
