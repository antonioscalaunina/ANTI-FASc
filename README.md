# ANTI-FASc

ANTI-FASc, acronym for Automatic Numerical Tsunami Initial conditions: on-the-Fly rupture Areas and earthquake Scenarios, is a software enabling the fast computation of large ensembles of slip distributions on complex non-planar fault interfaces (Maesano et al. 2017, Sci. Rep.; Tonini et al. 2021, GJI) such as the subducting plates. These slip models can be promptly used as initial conditions for the computation of tsunami scenarios in the framework of both Seismic-Probabilistic Tsunami Harzard Assessment (see Scala et al. 2020 PAGEOPH - Basili et al. 2021 Frontiers) and for real-time Probabilisitic Tsunami Forecasting (see Selva et al. 2021 Nature in press).

The software is composed by three modules

1- Preprocess module including:
    
   - A mesh generator 
    
   - The computation (through the lateration algorithm of k223d, see Herrero and Murphy 2018, GJI) of a matrix containing all the interdistances among nodes for the computed mesh
    
   - The computation of a grid of rupture barycenters optimised to minimize the repetition of similar rupture areas during the nex stage. This grid depends on magnitude binning and prescribed scaling law(s)

2 - Rupture areas computation:
    
   This part has two different use mode:
         
   - Hazard: it computes all the possible different rupture areas (according to the previous barycenters selection) in the prescribed magnitude bins
         
   - PTF: it computes all the scenarios “compatible” with estimation and uncertainty of magnitude and location for a given earthquake

3 - k223d - k-square slip distributions to 3D fault planes

   Computation of ensembles of stochastic k-square slip distributions for all the previously selected areas also accounting for other conditions (e.g. homogeneous or variable rigidity, surface slip amplification)

Along with the codes it has been provided a large dataset of precomputed meshes and the related rupture barycenters selections optimised for an assigned magnitude binning and considering the scaling relationship proposed by Strasser et al. (2010, SRL) and Murotani et al. (2013, SRL)



BIBLIOGRAPHY

Basili R. et al. (2021), The Making of the NEAM Tsunami Hazard Model 2018 (NEAMTHM18), Frontiers in Earth Science, DOI: 10.3389/feart.2020.616594 

Herrero and Murphy (2018), 	Self-similar slip distributions on irregular shaped faults, Geophysical Journal International, DOI: 10.1093/gji/ggy104

Maesano, F.E., Tiberti, M.M. and Basili, R. (2017), The Calabrian Arc: Three-dimensional modelling of the subduction interface, Scientific Reports DOI: 10.1038/s41598-017-09074-8

Murotani, S., Satake, K., and Fujii, Y. (2013), Scaling relations of seismic moment, rupture area, average slip, and asperity size for M~9 subduction-zone earthquakes, Geophysical Research Letters, 40, DOI: 10.1002/grl.50976.

Scala A. et al. (2020), Effect of Shallow Slip Amplification Uncertainty on Probabilistic Tsunami Hazard Analysis in Subduction Zones: Use of Long-Term Balanced Stochastic Slip Models, Pure and Applied Geophysics, DOI: 10.1007/s00024-019-02260-x

Strasser, F. O., Arango, M. C., & Bommer, J. J. (2010), Scaling of the source dimensions of interface and intraslab subduction-zone earthquakes with moment magnitude. Seismological Research Letters, DOI: 10.1785/gssrl.81.6.941.

Tonini et al. (2020), Importance of earthquake rupture geometry on tsunami modelling: The Calabrian Arc subduction interface (Italy) case study, Geophysical Journal International, DOI: 10.1093/gji/ggaa409
