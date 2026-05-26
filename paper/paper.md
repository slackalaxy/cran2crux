---
title: 'cran2crux: write CRUX ports for R-packages'
tags:
  - R
  - CRUX
  - packages
  - ports
  - CRAN
  - Bioconductor
authors:
  - name: Petar B. Petrov
    orcid: 0000-0001-5551-8032
    corresponding: true
    affiliation: "1, 2"
  - name: Valerio Izzi
    orcid: 0000-0002-9960-4917
    affiliation: 1
affiliations:
 - name: Faculty of Biochemistry and Molecular Medicine, University of Oulu, Oulu, Finland
   index: 1
 - name: Infotech Institute, University of Oulu, Oulu, Finland
   index: 2
date: 25 May 2026
bibliography: paper.bib
---

# Summary
R together with CRAN and Bioconductor provides one of the richest ecosystems for bioinformatics and computational biology, with thousands of specialized packages. While GNU/Linux is a widely-used operating system in this field, R-packages are typically managed independently of the system’s native package manager. This separation makes installation, updates and mass rebuilds cumbersome. CRUX, a minimalist semi-source GNU/Linux distribution, offers great flexibility with its ports-based system for the seamless integration of R-packages with its native package manager. Here, we present `cran2crux`, a tool that automatically generates CRUX ports for packages from both CRAN and Bioconductor. It performs recursive dependency resolution, handles naming conventions, extracts dependencies information, and supports inclusion of optional dependencies. The tool also provides convenient functions for checking updates and regenerating outdated ports. It can generate over 140 ports for complex packages such as Seurat in approximately 11 seconds, dramatically simplifying the maintenance of large R-package dedicated repositories on CRUX. `cran2crux` is available under the MIT license at https://github.com/izzilab/cran2crux. As of now, more than 650 R-packages ports, generated with the tool, are available in the CRUX ports database.

# Statement of need
The [R](https://www.R-project.org) [@core_team_r_2026] programming language and its ecosystem are heavily used in data science, with particularly strong adoption in bioinformatics and computational biology. R, together with [CRAN](https://cran.r-project.org) and the bioinformatics-oriented [Bioconductor](https://bioconductor.org/) project, forms one of the dominant platforms for the analysis of high-throughput biological data. This is made possible by thousands of R-packages, specifically tailored for genomics, transcriptomics, proteomics, single-cell analysis and more. 

GNU/Linux is widely-used in bioinformatics, due to its reliability, powerful command line shell and the plethora of dedicated, open-source tools. Software packaging is a core component of GNU/Linux distributions or any other UNIX-like operating system (OS). It provides a structured, centralized, and reliable way to install, update and remove software. R-packages are typically installed using R’s own package management tools (`install.packages()` for CRAN and `BiocManager::install()` for Bioconductor), placing them outside the system’s native package manager. Doing updates or mass rebuilds may, therefore, prove challenging and complicated, especially between major point releases of R, e.g. 4.5 to 4.6. Thanks to the flexibility of open-source, development of tools that bridge language-specific package ecosystems with the system-specific packaging is common.

[CRUX](https://crux.nu/) is a minimalist and highly customizable GNU/Linux distribution, that offers an elegant ports system and an advanced ports managing tool, called `prt-get` [@winkelmann_advanced_2002]. The ports are simple text files (Pkgfile), using BASH syntax, facilitating users to create and maintain their own repositories, deposited at the [ports database](https://crux.nu/portdb/). Despite this transparency, creating and maintaining a large repository of interdependent ports -- such as one containing hundreds/thousands of R packages -- can quickly become tedious and time-consuming.

To simplify installing, updating, and managing R-packages on CRUX, we developed `cran2crux` -- a simple tool that automatically generates ports for CRAN and Bioconductor entries, with recursive dependency resolution. Although initially created to support bioinformatics-focused R-packages, `cran2crux` is designed to work with virtually any package from CRAN or Bioconductor.

# State of the field
While mature tools exist for managing R packages within the R environment, no dedicated tool was previously available for automatically generating ports on the CRUX distribution. The closest analogous project is `cpan2crux`, which generates CRUX ports for Perl modules, and inspired the name of this project.

# Software design
The core components of `cran2crux` are written in R and invoked from a thin BASH wrapper that provides the command-line interface.  This design choice was made to take advantage of R’s package metadata handling while keeping the user-facing interface lightweight and familiar to CRUX users.

When writing the port’s Pkgfile, `cran2crux` first synchronizes with CRAN and Bioconductor, then adds dependencies information from the *Depends*, *Imports*, and *LinkingTo* fields, while optional dependencies are retrieved from the *Suggests* field. Dependencies specified in the *SystemRequirements* field fall outside the R ecosystem and at the moment `cran2crux` is not meant to handle them. However, adding such functionality is considered for the future. After building, the produced package is then ready to be installed system-wide, using CRUX’s `pkgutils` [@liden_pkgutils_nodate].

When generating ports recursively, `cran2crux` calculates the dependencies tree (default depth of 5 iterations) before writing the ports to disk. The default iterations value rarely needs to be changed and may be left unspecified by the user. Alternatively, ports for optional dependencies can also be generated (those listed in the *Suggests* field). Because this process is fully recursive too, it often results in the creation of thousands of ports and can be computationally intensive. For this reason, the recursive generation should be used with caution. When used, the recursion depth can be increased by passing a positive integer, larger or equal to 2 (e.g. 10). 

The tool also includes functionality to detect outdated installed packages and regenerate updated ports.

# Research impact statement
We have been maintaining an up-to-date CRUX repository of over 650 ports, called [r4](https://crux.nu/portdb/?a=repo&q=r4) for R-packages needed in our work, when doing software development in R. Among them are the [Matrisome AnalyzeR](https://matrinet.shinyapps.io/MatrisomeAnalyzer) [@petrov_matrisome_2023] -- a suite to annotate and quantify extracellular matrix (ECM) molecules in big datasets across organisms, [MatriCom](https://matrinet.shinyapps.io/matricom) [@lamba_matricom_2025], a tool which does single-cell RNA-sequencing data mining to infer cell–extracellular matrix interactions, [MatriSpace](https://matrinet.shinyapps.io/matrispace) [@oshinjo_matrispace_2026] -- an instrument for the identification and visualization of spatially resolved ECM gene expression patterns in health and disease, and [ProToDeviseR](https://matrinet.shinyapps.io/ProToDeviseR) [@petrov_protodeviser_2025] -- an automated protein topology scheme graphics generator. 

# Performance benchmarks
The Seurat package [@hao_dictionary_2024] is widely-used in bioinformatics, and has been established as a standard tool for single cell transcriptomics analyses. It is [available on CRAN](https://cran.r-project.org/web/packages/Seurat), where it lists over 50 first-level dependencies (*Depends*, *Imports* and *LinkingTo* fields). Processing Seurat and its dependencies recursively yields a total of 142 ports in about 11 seconds on an Intel i7-9700KF running at 3.6GHz, as reported by `time`. As a comparison, `cran2crux` was run by skipping the CRAN/Bioconductor synchronization step (data already downloaded beforehand), or setting the number of dependencies depth iterations to a lower value, e.g. 2 (Figure 1). 

![Performance benchmarks of cran2crux. Runs were timed with (default) or without CRAN and Bioconductor synchronization, as well as, with 5 (default) or 2 iterations for dependencies resolution. Error bars indicate standard deviation.](./fig_1.png)

Three runs were timed for each combination of conditions and the mean values of *real* (total elapsed time), *user* (time in user-space code) and *sys* (time in kernel/system calls), were calculated and plotted in [Gnumeric spreadsheet](https://gnome.pages.gitlab.gnome.org/gnumeric-web/). As expected, these run-times were shorter, illustrating that most time is spent on downloading package lists from upstream and resolving the full recursive dependency tree, while the actual local work on writing ports to disk is very fast.

# Adaptations to other distributions
Due to its open-source license (MIT) and relatively simple codebase, `cran2crux` can be easily ported or adapted to serve a similar purpose on other distributions. Any distribution that uses a ports-like packaging system — where each package is defined by a readable build recipe — could potentially benefit from a tool based on, or forked from `cran2crux`. Good candidates include [Arch Linux](https://archlinux.org/), [Slackware](http://www.slackware.com/) via the semi-official [SlackBuilds.org project](https://slackbuilds.org/) and [Void Linux](https://voidlinux.org/). A particularly interesting case is [BioArchLinux](https://bioarchlinux.org/) [@zhang_bioarchlinux_2025], a community project that maintains a large collection of bioinformatics tools on top of Arch Linux using PKGBUILDs. Since Arch Linux itself was originally inspired by CRUX, its PKGBUILD format is structurally very similar to CRUX’s Pkgfile. This makes BioArchLinux an excellent candidate for a cran2crux-based tool, as the core logic for generating package recipes would require only moderate adaptation.

# Acknowledgements
We thank the CRUX core team for their continued maintenance of the distribution and for keeping an always up-to-date port for R available. 

# Funding 
This work was supported by GeneCellNano flagship of the Research Council of Finland [VI, PBP], the DigiHealth-project, a strategic profiling project at the University of Oulu [VI] and the Infotech Institute [VI, PBP], the Cancer Foundation Finland [VI], the European Union CARES project [HORIZON-MSCA-2022-SE-01-01, to VI], and the Sigrid Jusélius  Stiftelse [decision 260193 to VI].

# Declaration of interests
The authors declare no competing interests.

# Author contributions
PBP wrote the code, performed the testing, did benchmarking and drafted the paper. VI acquired funding, contributed to the manuscript preparation and reviewed the code.

# AI usage disclosure
Generative AI tools (Grok) were used to assist with code quality assessment and, to a minor extent, with manuscript preparation. The authors reviewed, edited, validated all AI-assisted outputs and made the core design decisions.

# References
