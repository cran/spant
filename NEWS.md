# spant 0.17.0
* Added a function to grid shift 2D MRSI data in the x/y direction.
* Better plotting/fitting support for masking data by setting data points to NA.
* Bug fix for interactive voxel selection position indicator.
* Added mask_xy to mask voxels in a centered rectangular region.
* Minor changes to improve parallel processing support.

# spant 0.16.0
* SNR is now defined as the max data point divided by the standard deviation of
the noise (n.b. factor of two has been removed in-line with upcoming terminology
paper).
* Default rats method improved to work with multidimensional datasets.
* Added norm_mrs function to normalise the intensity of spectral data.
* Added bc_constant function to correct spectral baselines by a constant offset.
* Added re_weighting function to apply a resolution enhancement weighting to the
FID.
* Performance improvement for apodise_xy function.
* sd function now works for mrs_data.
* Added 2D MRSI support for Siemens IMA format.

# spant 0.15.0
* Bug fix for using auto_phase function with a single spectrum.
* Bug fix for comb_coils not returning unaveraged data when requested.
* Added options to combine metabolite signals from the stackplot of a fit object
and adjust the plot margins.
* Added comb_fits function.
* Added collapse_to_dyns function for mrs_fit objects.
* RDA reader now extracts geometry information.

# spant 0.14.0
* Added options to omit basis signals, change label names and combine lipid and
MM signals from the stackplot of a fit object.
* Added auto_phase function for zeroth order phase-correction of simple spectra.
* Added get_subset function to aid MRSI slicing.
* Added decimate_mrs function.
* Added fit_amps function to quickly extract amplitude estimates from a fit
object.
* Bug fix for int_spec function.
* sim_basis function arguments updated to accept acq_par objects.

# spant 0.13.0
* Various bug fixes for Siemens TWIX reader.
* rats and tdsr functions now use the mean spectrum as the default reference.
* Added the option to remove the x axis in an mrs_data plot.
* Added ylim and y_scale options to fit plotting.
* Added %$% operator from magrittr package.
* Added an interpolation option to calc_spec_snr.
* Added hline and vline options to image.mrs_data.

# spant 0.12.0
* Fit results stackplot now has the option to display labels.
* Added the option to reverse eddy current correction.
* Improved GE p-file reader.
* diff function can now be applied to mrs_data objects.
* Complex functions: Re, Im, Mod, Arg and Conj can now be applied to mrs_data 
objects.
* Default simulations for Glc and NAAG have been improved.

# spant 0.11.0
* Added mar argument to plot command.
* td2fd and fd2td now give warnings when used with data already in the target
domain.
* Improved documentation formatting consistency and fixed some spelling errors.
* Added rats method.

# spant 0.10.0
* The names of in-built pulse sequence functions now all start with seq_* to
make them easier to find.
* Added new functions to simulate the following MRS sequences: CPMG, MEGA-PRESS, 
STEAM, sLASER. sLASER sequence kindly contributed by Pierre-Gilles Henry.
* Bug fix for get_mol_names function.
* stackplot function now accepts labels argument and time-domain plotting.
* def_acq_paras function now accepts arguments to override the defaults.
* Added a source field to mol.paras object to cite the origin of the values.
* Option to restore plotting par defaults.
* The magrittr pipe operator is now exported.

# spant 0.9.0
* Updated plotting modes to be one of : "re", "im", "mod" or "arg".
* Updated int_spec function to use "re", "im", or "mod".
* Added a function to replicate data across a particular dimension.
* Added a convenience function to simulate normal looking 1H brain MRS data.
* phase and shift functions now accept vector inputs.

# spant 0.7.0
* Added new function for frequency drift correction.
* Added support for Siemens ima and TWIX SVS data.
* Added support for GE p-file SVS data.
* Added apply_axes fn.
* Support for reading SPM style segmentation results (spm_pve2categorical).

# spant 0.6.0
* Interactive plotting function added for fit results - plot_fit_slice_inter.
* Bug fix for appending dynamic results.
* Bug fix for reading list data files without reference data.
* Bug fix for append_dyns function.
* basis2mrs_data function has been extended to allow the summation of basis
elements and setting of individual amplitudes.
* Added a shift function for manual frequency shift adjustment.
* Added initial unit tests and automated coveralls checking.

# spant 0.5.0
* A default brain PRESS basis is now simulated by the fit_mrs function when the
basis argument isn't specified.
* Added calc_peak_info function for simple singlet analyses.
* crop_spec function now maintains the original frequency scale.
* The basis set used for analyses has now been added to the fit result object.
* Bug fix for simulating basis sets with one element.
* lb function can now be used with basis-set objects.
* Bug fix for spar_sdat reader for non-localised MRS.
* AppVeyor now being used to test Windows compatibility - John Muschelli.

# spant 0.4.0
* Bug fix for SPAR/SDAT SVS voxel dimensions.
* MRSI support added for Philips SPAR/SDAT data.
* Fit plots now default to the full spectral range unless xlim is specified.
* Fit plots allow the x, y, z, coil, dynamic indices to be specified.
* Added the option to subtract the baseline from fit plots.

# spant 0.3.0
* Added stackplot method for fit objects.
* Added functions for registering and visualising SVS volumes on images and 
performing partial volume correction.
* Philips "list data" also now reads noise scans.
* calc_coil_noise_cor, calc_coil_noise_sd functions added to aid coil 
combination.
* Documentation updates for plotting methods.
* Added some simulation methods to userland.

# spant 0.2.0
* Added Siemens RDA format reader.
* Added Philips "list data" format reader.
* Added Bruker paravision format reader.
* Added PROPACK option for HSVD based filtering.
* Added a coil combination function.
* Bug fix for incorrect ppm scale on fit plots when fs != 2000Hz.
* Bug fix for VARPRO analytical jacobian calculation.

# spant 0.1.0
* First public release.
