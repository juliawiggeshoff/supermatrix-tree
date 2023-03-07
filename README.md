# Maximum-Likelihood Supermatrix Tree with IQ-TREE

The workflow is designed to perform substituion model selections, maximum likelihood tree estimation (random and parsimonious starting trees), nonparametric bootstrapping (BS), and two single branch tests (SH-like approximate likelihood ratio test - SH-aLRT - and approximate Bayes test - aBayes).  Finally, two consensus trees are created, one with the BS support values and the other with the combined SH-aLRT and aBayes values.

The analyses are done with IQ-TREE v2.2.0.3. It requires, among other things, a supermatrix FASTA file and its corresponding partition file in TXT format, which will be converted to NEXUS. Alternatively, a partition file already in NEXUS format can be provided.

Click [here](https://gitlab.leibniz-lib.de/jwiggeshoff/ml-supermatrix-tree#data-requirements) to know more about the data requirements.

# System requirements
## Local machine

I recommend running the workflow on a HPC system, as the analyses are resource and time consuming.

- If you don't have it yet, it is necessary to have conda or miniconda in your machine.
Follow [these](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html) instructions.
	- After you are all set with conda, I highly (**highly!**) recommend installing a much much faster package manager to replace conda, [mamba](https://github.com/mamba-org/mamba)
	- First activate your conda base

	`conda activate base`
	- Then, type:
	
	`conda install -n base -c conda-forge mamba` 

- Likewise, follow [this](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) tutorial to install Git if you don't have it.

## HPC system

Follow the instructions from your cluster administrator regarding loading of  modules, such as loading a root distribution from Conda.
For example, with the cluster I work with, we use modules to set up environmental variables, which have to first be loaded within the jobscripts. They modify the $PATH variable after loading the module.

e.g.:
`module load anaconda3/2022.05`

You usually don't have sudo rights to install anything to the root of the cluster. So, as I wanted to work with a more updated distribution of conda and especially use mamba to replace conda as a package manager, I had to first create my own "local" conda, i.e. I first loaded the module and then created a new environment I called localconda 
1. `module load anaconda3/2022.05`
2. `conda create -n localconda -c conda-forge conda=22.9.0`
3. `conda install -n localconda -c conda-forge mamba`
4. `conda activate localconda`

If you run `conda env list` you'll probably see something like this:
`/home/myusername/.conda/envs/localconda/`

# Data requirements

## Supermatrix: Fasta file

The supermatrix used when developing this project was generated by concatenating multiple sequence alignment files from orthologs, which had been predicted among *de novo* assembled transcripts. Therefore, each "full sequence" after a header corresponds to several "smaller" sequences put together. 

**Important:** the sequences are on the amino acid level and so should yours! Compatibility with different sequence types will be released soon.

The concatenated dataset was generated with the tool [FASconCAT-G](https://github.com/PatrickKueck/FASconCAT-G), which also writes a file noting the start and end of the sequences from each ortholog in the supermatrix, representing the
partition boundaries. 

## Partition file: Txt file or Nex file

The partition generated with FASconCAT-G is in text format and has to be converted to nexus to be compatible with IQ-TREE.

This is how my example partition file looks like:

```
charset 3133at6447 = 1 - 463 ;
charset 7677at6447 = 464 - 636;
charset 3966at6447 = 637 - 1001;
		...
charset 1248at6447 = 72452 - 73396;
charset 7265at6447 = 73397 - 73664;
```

If this is **exactly** how your partition file looks liks, e.g. if you also used FASconCAT-G, then the file will be converted to a compatible nexus. If that is true, please write **true** in the cell corresponding to the colum **"Convert_or_not"** in the [tab-separated file you also have to provide](https://gitlab.leibniz-lib.de/jwiggeshoff/ml-supermatrix-tree/-/tree/main/#contents-of-the-table). If your file does not look like the example above, please write **false** instead.

If you choose **true**, the first rule of the workflow will adjust the file by adding a tab-delimiter in front of “charset” and including the keyword “#nexus” in the first line, followed by a second line starting the sets block (“begin sets;”). The last line from the file ends the block with “end;”

This is how the partition file in nexus file should look like:

```
#nexus
begin sets;
        charset 3133at6447 = 1 - 463 ;
        charset 7677at6447 = 464 - 636;
        charset 3966at6447 = 637 - 1001;
			...
        charset 1248at6447 = 72452 - 73396;
        charset 7265at6447 = 73397 - 73664;
end;
```

If your partition file is still not in nexus format but does not look like mine from FASconCAT-G, then **please adjust it manually before starting the workflow.** Make sure to add **false** to the table.

More information on the [IQ-TREE manual](http://www.iqtree.org/doc/Complex-Models)

## Tab-separated table

Template table provided in `config/species_table.tsv`. Modify following the name of your project and the filenames from the partition and supermatrix files. 

You can simultaneously run multiple analyses with this table. 

The table is important not only to know how the two input files are named and where they are located, but also to write the names of the output directory and files in meaninful ways, i.e. results/[*my_project_name*]/tree_BS_[*my_project_name*].suptree 

### Contents of the table:
- **Project_name:** Name of your project, e.g. Phylogeny_Mollusca
- **Partition_file:** e.g. charset_mollusca_fasconcat-g.txt
- **Convert_or_not:** write true or false in case the partition file needs to be converted. See [partition file](https://gitlab.leibniz-lib.de/jwiggeshoff/ml-supermatrix-tree/-/tree/main/#partition-file-txt-file-or-nex-file) for more details.
- **Supermatrix_file:** e.g. supermatrix_mollusca.fas
- **Path:** path to input files within the `resources` directory. 
	- Create a folder in `resources` named meaningfully, so you can keep track of each project. Copy your two input files to it.
		- e.g. `resources/phylogeny_mollusca_input`
		- Contents of the subfolder `resources/phylogeny_mollusca_input`:
			- charset_mollusca_fasconcat-g.txt
			- supermatrix_mollusca.fas

**Important**:
- **No cell can be empty**, as Snakemake will see this as missing input file and the analyses will not run
- **Never modify the headers** from the table otherwise the same thing will happen
- The names of the partition file and supermatrix have to be the same as the actual files you copied into `resources/[my_project_name]`

|Project_name|Partition_file|Convert_or_not|Supermatrix_file|Path|
|--|--|--|--|--|
|Phylogeny_Mollusca|charset_mollusca_fasconcat-g.txt|true|supermatrix_mollusca.fas|resources/phylogeny_mollusca_input


## Configuration file

Template found in `config/configfile.yaml`. Modify accordingly.

Required file for important settings from the analyses. Workflow will fail if anything is wrong or missing.

### Contents of the configfile:

- **dataset:** path to the table described above.
	- You can keep the path as `"config/dataset_info.tsv"`as long as you remember to modify the cells according to your input files as project names
- **ML_trees:** Number of tree searches to be conducted using parsimonious and random starting trees.

# Installation 

1. Clone this repository

`git clone https://gitlab.leibniz-lib.de/jwiggeshoff/ml-supermatrix-tree.git`

2. Activate your conda base

`conda activate base`

- If you are working on a cluster or have your own "local", isolated environment you want to activate instead (see [here](https://gitlab.leibniz-lib.de/jwiggeshoff/ml-supermatrix-tree#hpc-system)), use its name to activate it

`conda activate localconda`

3. Install **ml-supermatrix-tree** into an isolated software environment by navigating to the directory where this repo is and run:

`conda env create --file environment.yaml`

If you followed what I recommended in the [System requirements](https://gitlab.leibniz-lib.de/jwiggeshoff/ml-supermatrix-tree#local-machine), run this intead:

`mamba env create --file environment.yaml`

The environment from ml-supermatrix-tree is created

4. *Always* activate the environment before running the workflow

On a local machine:

`conda activate ml-supermatrix-tree`

If you are on a cluster and/or created the environment "within" another environment, you want to run this first:

`conda env list`

You will probably see something like this among your enviornments:

`home/myusername/.conda/envs/localconda/envs/ml-supermatrix-tree`

From now own, you have to give this full path when activating the environment prior to running the workflow

`conda activate /home/myusername/.conda/envs/localconda/envs/ml-supermatrix-tree`

# Running the workflow

Remember to always activate the environment first

`conda activate ml-supermatrix-tree`

or

`conda activate /home/myusername/.conda/envs/localconda/envs/ml-supermatrix-tree`

## Local machine

**Not recommended** unless you have a lot of storage and CPUs available (and time to wait...). Nevertheless, you can simply run like this:

`nohup snakemake --configfile config/configfile.yaml --keep-going --use-conda --verbose --printshellcmds --reason --nolock --cores 11 > nohup_ml-supermatrix-tree_$(date +"%F_%H").out &`

Modify number of cores accordingly.

## HPC system

Two working options were tested to run the workflow in HPC clusters using the Sun Grid Engine (SGE) queue scheduler system.

For other systems, read more [here](https://snakemake.readthedocs.io/en/stable/executing/cluster.html).

### Before the first execution of the workflow

Run this to create the environments from the rules:

`snakemake --cores 8 --use-conda --conda-create-envs-only`

### Option 1:

`mkdir snakejob_logs`


`nohup snakemake --configfile config/configfile.yaml --keep-going --use-conda --verbose --printshellcmds --reason --nolock --rerun-incomplete --cores 31 --max-threads 15 --cluster "qsub -terse -V -b y -j y -o snakejob_logs/ -cwd -q fast.q,small.q,medium.q,large.q -M user.email@gmail.com -m be -pe smp {threads}" --cluster-cancel "qdel" > nohup_ml-supermatrix-tree_$(date +"%F_%H").out &`

Remember to:
1. Modify *user.email@gmail.com*
2. Change values for --cores and --max-threads accordingly 
3. Change environment for -pe as needed (e.g. smp)

### Option 2:

A template jobscript `template_run_ml-supermatrix-tree.sh` is found under [`misc/`](https://gitlab.leibniz-lib.de/jwiggeshoff/ml-supermatrix-tree/-/tree/main/misc)


**Important:** Please, modify the qsub options according to your system! 
Features to modify:
- E-mail address: `-M user.email@gmail.com`
- Mailing settings, if needed: `-m be`
- If you  want to split stderr to stdout, use `-j n` instead and add the line `#$ -e cluster_logs/`
- If you want to, the name of the jobscript: `-N ml-supermatrix-tree`
- **Name of parallel environment (e.g. smp) as well as the number of maximum threads to use:** `-pe smp 31`
- **Queue name!** (extremely unique to your system): `-q small.q,medium.q,large.q`

Ater modifying the template, copy it (while also modifying its name) to the working directory:

If you are within the folder `misc/`:

`cp template_run_ml-supermatrix-tree.sh ../run_ml-supermatrix-tree.sh`

You should see `run_ml-supermatrix-tree.sh` within the path where the folders config/, resources/, results/, and workflow/ are, together with files README.md and environment.yaml

Remember to `mkdir cluster_logs` before running for the first time

Finally, run:

`qsub run_ml-supermatrix-tree.sh`

# Finishing the workflow: report.html

Upon successfully finishing the analyses, Snakemake will **automatically** generate a compressed report in the working directory, `report.html` 

It describes the used software versions, the commands, and paths to in and output files. 

**To be released:** Summary of main results, drawn trees 

To know more about report files, see the documentation from Snakemake [here](https://snakemake.readthedocs.io/en/stable/snakefiles/reporting.html).

# Done :)
