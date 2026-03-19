# HYCOM_DNN

## Description
HYCOM_DNN is an extension of the HYCOM ocean model that integrates a deep neural network (DNN) into the KPP vertical mixing scheme.

## Details
The source code is developed based on the original HYCOM repository:  
https://github.com/HYCOM/HYCOM-src

The Fortran Keras Bridge (FKB) module (https://github.com/scientific-computing/FKB) is used to recover DNN structures from saved weight & bias files and make predictions online in *HYCOM_DNN*

---

## **Features**
- Integration of a trained DNN into the KPP parameterization  
- Support for different wave-related configurations  
- Seamless coupling with existing HYCOM workflows  
- Minimal modification to external dependencies (e.g., FKB)  

---

## **Directories**
- `HYCOM_KPPDNN_src`: HYCOM_KPP_DNN source codes & FKB modules
- `dnn_param`: DNN weights and biases used by FKB to recover DNN structure & parameters to normalize DNN inputs

## **Configuration**

A control flag `dnnflg` is introduced in the source codes:

- `dnnflg = 0`: Standard KPP_LMD  
- `dnnflg = 1`: KPP_DNN with no Stokes drift input  
- `dnnflg = 2`: KPP_DNN with Stokes drift input  

---

## **Code Modifications**

- `blkdat.F90`  
  Reads `dnnflg` and loads DNN weights  

- `mod_cb_arrays.F90`  
  Defines variables for HYCOM_DNN  

- `mxkprf.F90`  
  Uses DNN to update KPP scheme  

---

## **Usage**

1. Edit `dnnflg` in `blkdat.input`  
2. Set DNN weights path in `blkdat.F90`
3. Compile HYCOM  using `csh Make.csh`
4. Run the model  

---

## **Dependencies**

- HYCOM  
- Fortran compiler  
- Fortran Keras Bridge (FKB)  

---

## **Notes**

Manual configuration of DNN paths in `blkdat.F90` is required.
