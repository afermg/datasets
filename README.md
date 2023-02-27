# JUMP Cell Painting Datasets

[![DOI](https://zenodo.org/badge/552371375.svg)](https://zenodo.org/badge/latestdoi/552371375)

This is a collection of [Cell Painting](https://jump-cellpainting.broadinstitute.org/cell-painting) image datasets generated by the [JUMP-CP Consortium](https://jump-cellpainting.broadinstitute.org/).

This repository contains notebooks and instructions to work with the datasets.

All the data is hosted on the Cell Painting Gallery on the Registry of Open Data on AWS ([https://registry.opendata.aws/cellpainting-gallery/](https://registry.opendata.aws/cellpainting-gallery/)). If you'd like to take a look at (a subset of) the data interactively, the [JUMP-CP Data Explorer](https://phenaid.ardigen.com/jumpcpexplorer/) by Ardigen and the [JUMP-CP Data Portal](https://www.springdiscovery.com/jump-cp) by Spring Discovery provide portals to do so.

## Details about the data

Currently, this collection comprises 4 datasets:

- The principal dataset of 116k chemical and >15k genetic perturbations the partners created in tandem (`cpg0016`), split across 12 data-generating centers. Human U2OS osteosarcoma cells are used.
- 3 pilot datasets created to test: different perturbation conditions (`cpg0000`, including different cell types), staining conditions (`cpg0001`), and microscopes (`cpg0002`).

### What’s available now

- All data [components](https://github.com/broadinstitute/cellpainting-gallery/blob/main/folder_structure.md) of the three pilots and the reprocessed dataset.
- Most data components (images, raw CellProfiler output, single-cell profiles, aggregated CellProfiler profiles) from 12 sources for the principal dataset. Each source corresponds to a unique data generating center (except `source_7` and `source_13`, which were from the same center).
- First draft of [metadata](metadata/README.md) files.
- A notebook to load and inspect the data currently available in the principal dataset.

**Please note: At present in the principal dataset (`cpg0016`), many compounds will be missing replicates, and a full QC of the dataset is pending. We don’t recommend performing any analysis with the principal dataset until all the remaining components and all sources are uploaded and the full QC of the dataset is complete. The other datasets are complete.**

### What’s coming up

- Extending the metadata and notebooks to the three pilots and the reprocessed dataset so that all these datasets can be quickly loaded together.
- Curated annotations for the compounds, obtained from [ChEMBL](https://www.ebi.ac.uk/chembl/) and other sources.
- The remaining data [components](https://github.com/broadinstitute/cellpainting-gallery/blob/main/folder_structure.md) (normalized profiles, feature selected profiles, treatment-level consensus profiles, quality control results) and the remaining sources for the principal dataset.
- Deep learning [embeddings](https://tfhub.dev/google/imagenet/efficientnet_v2_imagenet1k_s/feature_vector/2) using a pre-trained neural network for all 5 datasets.
- [Quality control](https://github.com/broadinstitute/cellpainting-gallery/blob/main/folder_structure.md#quality_control-folder-structure) results at the image level for the principal dataset to allow removing bad images.
- Our manuscript, Chandrasekaran et al., 2022b, which is being approved by pharmaceutical company partners and will be released on bioRxiv.

## How to load the data: notebooks and folder structure

See the [sample notebook](sample_notebook.ipynb) to learn more about how to load the data in the principal dataset.

To get set up to run the notebook, first install the python dependencies and activate the virtual environment

   ```bash
   # install pipenv if you don't have it already https://pipenv.pypa.io/en/latest/#install-pipenv-today
   pipenv install
   pipenv shell
   ```

See the typical [folder structure](https://github.com/broadinstitute/cellpainting-gallery/blob/main/folder_structure.md) for datasets in the Cell Painting Gallery.
Please [note](README.md#whats-available-now) that not all components are currently available.

## Citation/license

### Citing the JUMP resource as a whole

All the data is released with CC0 1.0 Universal (CC0 1.0).
Still, professional ethics require that you cite the associated publication.
Please use the following format to cite this resource as a whole:

_We used the JUMP Cell Painting datasets (Chandrasekaran et al., 2022b), available from the Cell Painting Gallery on the Registry of Open Data on AWS ([https://registry.opendata.aws/cellpainting-gallery/](https://registry.opendata.aws/cellpainting-gallery/))._

For applications which require a DOI, this repository is archived at <https://zenodo.org/record/7628768> automatically upon each release.
The permanent DOI is 10.5281/zenodo.7628768; individual versions will also be assigned DOIs, see the badge at the top of this README for the most recent DOI.

Please note that the JUMP whole-project manuscript (Chandrasekaran et al., 2022b) is currently in preparation.

### Citing individual JUMP datasets

To cite individual JUMP Cell Painting datasets, please follow the guidelines in the Cell Painting Gallery citation [guide](https://github.com/broadinstitute/cellpainting-gallery/#citationlicense).
Examples are as follows:

_We used the dataset cpg0001 (Cimini et al., 2022), available from the Cell Painting Gallery on the Registry of Open Data on AWS (<https://registry.opendata.aws/cellpainting-gallery/>)._

_We used the dataset cpg0000 (Chandrasekaran et al., 2022a), available from the Cell Painting Gallery on the Registry of Open Data on AWS (<https://registry.opendata.aws/cellpainting-gallery/>)._

## Gratitude

Thanks to Consortium Partner scientists for creating this data, from Ksilink, Amgen, AstraZeneca, Bayer, Biogen, the Broad Institute, Eisai, Janssen Pharmaceutica NV, Merck KGaA Darmstadt Germany, Pfizer, Servier, and Takeda.

Supporting Partners include Ardigen, Google Research, Nomic Bio, PerkinElmer, and Verily. Collaborators include the Pistoia Alliance, Umeå University, and the Stanford Machine Learning Group. The AWS Open Data Sponsorship Program is sponsoring data storage.

This work was funded by a major grant from the Massachusetts Life Sciences Center and the National Institutes of Health through MIRA R35 GM122547 to Anne Carpenter.

## Questions?

Please ask your questions via issues [https://github.com/jump-cellpainting/datasets/issues](https://github.com/jump-cellpainting/dataset/issues).

Keep posted on future data updates by subscribing to our email list, see the button here: <https://jump-cellpainting.broadinstitute.org/more-info>
