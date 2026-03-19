# HYCOM_DNN

## Description
HYCOM_DNN is an extension of the HYCOM ocean model that integrates a deep neural network (DNN) into the KPP vertical mixing scheme.

## Details
The source code is developed based on the original HYCOM repository:  
https://github.com/HYCOM/HYCOM-src

---

## **Features**
- Integration of a trained DNN into the KPP parameterization  
- Support for different wave-related configurations  
- Seamless coupling with existing HYCOM workflows  
- Minimal modification to external dependencies (e.g., FKB)  

---

## **Configuration**

A control flag `dnnflg` is introduced:

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

1. Edit `blkdat.input`  
2. Set DNN weights path  
3. Compile HYCOM  
4. Run the model  

---

## **Dependencies**

- HYCOM  
- Fortran compiler  
- Fortran Keras Bridge (FKB)  

---

## **Notes**

Manual configuration of DNN paths in `blkdat.F90` is required.
