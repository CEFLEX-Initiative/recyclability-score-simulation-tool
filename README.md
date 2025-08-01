![CEFLEX logo](https://ceflex.eu/wp-content/uploads/2017/03/CEFLEX_inline_100.png)
# The CEFLEX *recyclability score simulation* tool
## A tool to model the outcome in terms of scores and grades for packaging designs based on design-for-recycling tables and scoring systems
Today, a wide range of packaging designs are on the market and recent years have seen a substantial shift in packagings design, based on design-for-recycling considerations. Simultaneously, design-for-recycling guidelines are still being developed and updated and multiple such guidelines exist. Additionally, 'scoring systems', i.e., methodologies or rulesets for combining  packaging design information with design-for-recycling guidelines into a score and/or a grade are also continuing to be developed.
 
Based on the existince of a multitude of each of these three parts of designing and assessing packaging for its recyclability, it is not easy to check manually how the different possible choices for these three elements will ‘fit together’ in the sense of producing outcomes that represent the real-world outcomes of recycling operations.
 
This tool therefore provides a way of rapidly determining the outcomes in terms of a score and a grade for every combination of the scoring systems, design-for-recycling guideline tables and packaging designs that are provided as an input. It is a generic framework into which in principle any type of packaging design, DfR table and scoring system proposals can be loaded. 


What this tool is *not*:
- The tool is **not design guidance** nor does it express a design preference, although it ships with a representation (in Excel) of the CEFLEX D4ACE phase 2 design guideline table. This table is provided for information and illustration purposes and to allow to try out the tool without first having to create a design-for-recycling table from zero base. The tool is therefore not a ‘CEFLEX tool’, merely a tool built by CEFLEX.
 
- The tool is **not a specific scoring system**, although it ships with a representation (in R code) of the CEFLEX proposal for a scoring system under PPWR. This code is provided for information and illustration purposes and to allow to try out the tool without first having to create code for a scoring system from zero base.
 
Please take note of the contained LICENSE file in this repository which applies to the provided code and its use.
 
## Caveats
 
This tool was developed by CEFLEX, the Circular Economy for Flexible Packaging initiative to create a circular economy for flexible packaging. As such, it has been originally developed with flexible packaging (of any material) in mind. While it has already been partially expanded to be useful more generally, some limitations remain at this point. Furthermore, as design guidance becomes more detailed, not all the concepts it expresses are already possible to model in this tool (e.g., partial coverages). Future versions of this tool may address or remove these limitations.
 
- The tool currently does not consider separate components (i.e., a packaging unit containing one or multiple separate components cannot be assessed as one, the separate components can be assessed as separate packaging designs though)
- While the tool allows to add integrated components, it does not yet differentiate them fully (e.g., separate DfR requirements for the print on a cap vs. requirements for print on the main body of the packaging unit are not yet differentiated).
- Not every possible or existing expression found in DfR guideline tables can be expressed in the tool or its inputs at this time (e.g., if a DfR guidance table uses expressions such as 'only in combination with' or 'not in combination with', this logical connection cannot yet be expressed)
- Minimum amount requirements for materials cannot currently be described in the Excel file for the DfR table but must be described in the scoring model
- The tool cannot yet automatically assign recycling streams based on colour or opacity

## Assumptions
This tool makes certain assumptions and while it is possible to modify the code to change these, they are not currently offered as easily changeable options. They may or may not be made modular in future versions.
- DfR tables have three columns: green/fully compatible, yellow/limited compatibility, red/not compatible
- one or more component(s) and/or constituent(s) not contained in the applicable DfR table means no score can be assigned and the packaging designs 'needs testing' (if the applied scoring model uses DfR considerations)
- if no recycling stream (i.e., matching DfR table) is available, no score is given ('N/A', i.e., 'not available' result) if a scoring model uses DfR
 
 
## Using the tool
 
### Initial setup
This tool is written in [R](https://www.r-project.org) and relies on a number of existing R libraries.
 
To run the tool, a suitable R runtime must be installed (e.g., the base [R  runtime](https://www.r-project.org) or within a development environment such as [Visual Studio Code](https://code.visualstudio.com)).
 
Furthermore, the prerequisite R libraries must be installed. This can be achieved by running the file 'setup.R' once or by manually installing the following R libraries:
- tidyverse
- officer
- read_xlsx
- writexl
- splitstackshape
- tools
 
Note: future versions will reduce the number of dependencies related to the reading and writing of Microsoft office files.
 
 
### Running the tool
The workflow to use the modelling tool is:
- Provide packaging design specifications (in one or multile Excel files in the 'designs' folder)
- Provide DfR tables (in one or multile Excel files in the 'tables' folder)
- Provide at least one scoring system (in R code, in the 'models' folder)
- Run the main R script called 'analyse.R'
- Review the output in the 'output' folder:
  - An Excel file called 'Full assessment results (all combinations).xlsx' with every permutation of design, DfR table and scoring system provided as inputs
  - Individual text files with the analysis and result for each permutation of design, DfR table and scoring system
  - A graphical representation of the outcomes for each scoring system provided
