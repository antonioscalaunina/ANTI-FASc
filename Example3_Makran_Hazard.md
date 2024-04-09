# EXAMPLE 3 Tohoku earthquake

In this guided example, we described a different application. Given a mesh, we define an ensemble of slip distributions which represent an almost homogeneous 
coverage of the whole seismogenic area. In this view, the ensemble can be used for the Probablistic Tsunami Hazard Assessment, or as a precmputed ensemble to
extract the needed scenario for PTF application (see Basili et al. 2021 and Selva et al. 2021 [bibliography here](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/README.md) )

# 1 - Installation

If you have already run the first two examples you should have installed all the requirments. Otherwise please follow the instructions [here](https://github.com/antonioscalaunina/ANTI-FASc/blob/main/Example1_Tohoku.md)

# 2 - Preprocess

To run this example you should copy the input_Makran.json into the standard input.json file

    cp input_Makran.json input.json

The preprocess steps might be skipped for this applications exploiting the already available files stored in the folder *config_files*. However with the following 

            {"zone_name": "kurilsjapan2",    #Name chosen by the user, arbitrary
            "Merc_zone": 54,             #Mercator Zone
            "acronym": "KJ2",                #Acronym (THREE DIGITS!) - it will be used to generate and use all the configuration files all the process long
            "mesh_gen": 1,               # 1 means that a new mesh should be generated
            "slab_file": "kur_slab2_dep_02.24.18.xyz",    #name of the Slab 2.0 file
            "seismog_depth": 60,            #Max depth (km) included in the mesh. It will exclude all the nodes deeper if a new mesh is being generated
            "depth_interpolator": "v4"      # Algorithm of interpolation between Slab and grid nodes depth. "v4" is the suggested option but it could not work depending on MATLAB configuration. It can also significantly slow down the process. In this case replace "v4"                                                with "nearest"
            "mesh_convex": 0.5              # Mesh convexity: defined in the range [0 1]. 0 convex hull mesh boundary - 1 tightest single-region boundary. Use always values <= 0.5. Sometimes mesh generation might produce error about the non-uniqueness of face ID due to                                                the concavity of mesh boundary: in that case, please slightly decrease "mesh_convex" 
            "element_size": 12.5e3,         #Average size of mesh face

            "Event": {
            "Name": "Tohoku",                    # Name for the event
            "Hypo_LonLat" : [142.369, 38.322],   #Fixed epicenter
            "Magnitude" : 9.0                    #Fixed magnitude
                    },
            "Configure": {
            "application": "PTF",                # This application limits the computed scenarios to magnitude and location range around the set values. See *Example3_HazardMakran.md* for "Hazard" application           
            "shape": "Rectangle",                # This choice allows to compute scenarios with aspect ratio L/W preserved. The other possible choice is "Circle". More details in the Wiki documentation (under construction)
            "numb_stoch": 5,                     # Number of stochastic slip for each rupture areas
            "variable_mu": 1,                    # 1 means that also the distributions with variable rigidity have to be computed
            "Magnitude_lb": 0.15,                # Magnitude in a range [Mw-0.15 Mw+0.15] will be accounted, used only for "application": "PTF"
            "Magnitude_ub": 0.15,
            "hypo_baryc_distance": 1.0,          # Rupture barycenters at less than 1 Length (inferred from scaling law for each Magnitude bin) form hypocenter will be accounted, used only for "application": PTF
            "minimum_bnd_distance": 0.25,        # These two options are used to limit the number of rupture areas dependending on Magnitude (and Rupture areas extension). In the preprocess file a set of rupture barycenter is selected. In particular with thia choice,                                                         the nodes closer than 0.25 times the Width are discarded.
            "minimum_interdistance": 0.1,        # With this choices the selected rupture barycenter are distant from each other more than 0.1 times the Length. This will avoid to have very similar rupture areas and reduce the number of scenarios at largest magnitude                                                         bins (see Scala et al. 2020 and Bayraktar et al. 2024)
            "Fact_area_scaling": 1,              # With this choice generate rupture areas having exactly the size expected from the selected scaling relationship are computed
            "Rigidity_file_logic": 0,            # No rigidity file is used for defining the rigidity variation with depth
            "Rigidity_file": "Rigidity_variation.txt",
            "Stress_drop_var": 0,                # No stress drop variation is imposed among scenarios
            "Fact_rigidity": 0.5                 # If "Rigidity_file_logic": 0 a rigidity variation similar to what proposed by Scala et al. 2020 is imposed. This choice uses at each depth an intermediate value between the Bilek & Lay (1999) variation and PREM is                                                             imposed. See Scala et al. (2020) and the Wiki documentation for more details
