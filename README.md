# Temporally Multiplexed Imaging

This repository includes code and images to reproduce figure 2C from the paper *Temporally multiplexed imaging of dynamic signaling networks in living cells* by Qian et al., 2022.

To run the code, clone this repository to a separate folder and run one of the following files:

- TMI_signal_unmixng_of_6_FPs_code1.m
- TMI_signal_unmixng_of_6_FPs_code2.m
- TMI_simulation_6_FPs.m 

The first two files contain different optimization methods used to reconstruct images of different FPs from a brief single-channel movie. The third file contains a similar approach applied to a simulated brief movie where ground truth is known.

The repository also contains an ImageJ/Fiji macro (CytosolicRingSegmentation.ijm) that is used for cytosolic ring segmentation. To use this macro, open an image with a set of ROIs already defined in the ROI Manager.

If there are any issues running the code, feel free to open an issue on this repository.
