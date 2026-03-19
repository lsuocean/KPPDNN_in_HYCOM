
\name{HYCOM_DNN}
\title{HYCOM_DNN: Deep Neural Network Enhanced KPP scheme in HYCOM}
\description{
HYCOM_DNN is an extension of the HYCOM ocean model that integrates a deep neural network (DNN) into the KPP vertical mixing scheme.
}
\details{
The source code is developed based on the original HYCOM repository:
\url{https://github.com/HYCOM/HYCOM-src}

\strong{Features}{
\itemize{
\item Integration of a trained DNN into the KPP parameterization
\item Support for different wave-related configurations
\item Seamless coupling with existing HYCOM workflows
\item Minimal modification to external dependencies (e.g., FKB)
}
}

\strong{Configuration}{

A control flag \code{dnnflg} is introduced:

\itemize{
\item \code{dnnflg = 0}: Standard KPP_LMD
\item \code{dnnflg = 1}: KPP_DNN with no Stokes drift input 
\item \code{dnnflg = 2}: KPP_DNN with Stokes drift input
}
}


\strong{Code Modifications}{
\describe{
\item{\code{blkdat.F90}}{Reads \code{dnnflg} and loads DNN weights}
\item{\code{mod_cb_arrays.F90}}{Defines variables for HYCOM_DNN}
\item{\code{mxkprf.F90}}{Uses DNN to update KPP scheme}
}
}

\strong{Usage}{
\enumerate{
\item Edit blkdat.input
\item Set DNN weights path
\item Compile HYCOM
\item Run the model
}
}

\strong{Dependencies}{
\itemize{
\item HYCOM
\item Fortran compiler
\item Fortran Keras Bridge (FKB)
}
}

\strong{Notes}{

Manual configuration of DNN paths in \code{blkdat.F90} is required.
}
}
