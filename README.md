Proteomics Shortcourse
----------------------

R shiny apps for proteomics.

- Evaluation of decoy quality
- Differential analysis using MSqRob

Website
------
https://statomics.github.io/pda/


Getting Started
----------------

1. Launch an R studio interface in an R docker along with bioconductor packages for proteomics.

[![Binder](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/statOmics/pda/master?urlpath=rstudio)

2. Alternatively, you can launch R studio via the jupyter binder environment:

[![Binder](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/statOmics/pda/master)

Once inside Jupyter Notebook, RStudio Server should be an option under the menu
"New":

![](./pages/figs/rstudio-session.jpg)

3. You can install your own local docker by downloading the entire repository and invoking
```
docker build <path to proteomicsShortCourse directory> -t msqrob_docker
```

Credits
-------
- The [rocker-binder team](https://github.com/rocker-org/binder) for providing a docker image with shiny proxy support.
- Adriaan Sticker and Ludger Goeminne, statOmics developers of MSqRob and saas.
- Laurant Gatto developer of MSnBase.
