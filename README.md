# ANTI-FASc

ANTI-FASc, acronym for Automatic Numerical Tsunami Initial conditions: on-the-Fly rupture Areas and earthquake Scenarios, is a software enabling the fast computation of large ensembles of slip distributions on complex non-planar fault interfaces, such as the subducting plates. These slip models can be promptly used as initial conditions for the computation of tsunami scenarios in the framework of both Seismic-Probabilistic Tsunami Harzard Assessment (see Scala et al. 2020 PAGEOPH - Basili et al. 2021 Frontiers) and for real-time Probabilisitic Tsunami Forecasting (see Selva et al. 2021 Nature in press).

The software is composed by three modules

1- Preprocess module including:
    A mesh generator 
    The computation (through the lateration algorithm of k223d see Herrero and Murphy 2018, GJI) of a matrix containing all the interdistances among nodes for the computed mesh
    The computation of a grid of rupture barycenters optimised to minimize the repetition of similar rupture areas during the nex stage. This grid depends on magnitude binning and prescribed scaling law(s)

2 - Rupture areas computation:
    This part has two different use mode:
         Hazard: it computes all the possible different rupture areas (according to the previous barycenters selection) in the prescribed magnitude bins
         PTF: it computes all the scenarios “compatible” with estimation and uncertainty of magnitude and location for a given earthquake

3 - k223d - k-square slip distributions to 3D fault-planes
Computation of ensembles of stochastic k-square slip distributions for all the previously selected areas also accounting for other conditions (e.g. homogeneous or variable rigidity, surface slip amplification)

Along with the codes it has been provided a large dataset of precomputed mesh and rupture barycenter selection optimised for an assigned magnitude binning and considering the scaling relationship proposed by Strasser et al. (2010) and Murotani et al. (2011)



BIBLIOGRAPHY

Basili R., The Making of the NEAM Tsunami Hazard Model 2018 (NEAMTHM18), Frontiers in Earth Science, DOI: 10.3389/feart.2020.616594 

Herrero and Murphy, 
