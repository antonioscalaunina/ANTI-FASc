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
