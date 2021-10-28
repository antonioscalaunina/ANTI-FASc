The module named *k223d* generates for each rupture area computed in the *Rupture_areas_OF* module a prescribed number of k2 stochastic slip distributions.

This module is based on the code k223d available at *https://github.com/s-murfy/k223d*. The composite source model technique there implemented is in turn based on the slipk2 code available at: *https://github.com/andherit/slipk2*. The distributed module also contains the software computing the distances over non-regular mesh surfaces thourgh a double-lateration scheme. The kernel of this software distributed in the github repository *https://github.com/andherit/trilateration* and described in the papers Herrero & Murphy (2018, GJI). The input configurations are read through the use of the module *forparse* avaialable at the github repository *https://github.com/andherit/forparse*

In this repository, the software *k223d* has been modified to:

 - Compute set of *n* stochastic slip distributions over precomptued rupture areas, and using precomputed inter-nodes distances
 
 - Compute slip distributions accounting for a variable rigidity across the mesh

 - Write output files in the standard format of initial conditions for tsunami wave propagation simulator such as Tsunami-HySeA (see as reference *https://edanya.uma.es/hysea/index.php/models/tsunami-hysea*)

This module also makes use:

 - the module utm_geo from the repository *specfem3d* available at: *https://github.com/geodynamics/specfem3d/blob/master/src/shared/utm_geo.f90*.

 - 
BIBILIOGRAPHY

Selva, J., Lorito, S., Volpe, M. et al. (2021). Probabilistic tsunami forecasting for early warning. Nat Commun 12, 5677 (2021). DOI: 10.1038/s41467-021-25815-w
