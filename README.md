# Maximum Likelihood Supermatrix Tree

Description: 

# System requirements
## Local machine

I recommend running the workflow on HPC clusters, as the analyses are resource and time consuming.

- If you don't have it yet, it is necessary to have conda or miniconda in your machine.
Follow [there](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html) instructions.
	- I highly (**highly!**) recommend installing a much much faster package manager to replace conda, [mamba](https://github.com/mamba-org/mamba)
	- In you command-line, type:
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
3. `conda activate localconda`
4. `conda install -n localconda -c conda-forge mamba`

If you run `conda env list` you'll probably see something like this:
`/home/myusername/.conda/envs/localconda/`

# Data requirements

## Supermatrix Fasta file

## Partition file Txt file

## Tab-separated table

## Configuration file

Blabla

# Installation 

1. Clone this repository

`git clone https://gitlab.leibniz-lib.de/jwiggeshoff/ml-supermatrix-tree.git`

2. Activate your conda base

`coda activate base`

- If you are working on a cluster or have your own "local", isolated environment you want to activate instead (see [here](https://gitlab.leibniz-lib.de/jwiggeshoff/rna-seq-to-busco#hpc-system)), use its name to activate it

`conda activate localconda`

3. Install **ml-supermatrix-tree** into an isolated software environment by navigating to the directory where this repo is and run:

`conda env create --file environment.yaml`

If you followed what I recommended in the [System requirements](https://gitlab.leibniz-lib.de/jwiggeshoff/rna-seq-to-busco#local-machine), run this intead:

`mamba env create --file environment.yaml`

The environment from rna-seq-to-busco is created

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

`nohup snakemake --keep-going --use-conda --verbose --printshellcmds --reason --nolock --cores 11 > nohup_ml-supermatrix-tree_$(date +"%F_%H").out &`

Modify number of cores accordingly.

## HPC system

Two working options were tested to run the workflow in HPC clusters using the Sun Grid Engine (SGE) queue scheduler system.

For other systems, read more [here](https://snakemake.readthedocs.io/en/stable/executing/cluster.html).

### Before the first execution of the workflow

Run this to create the environments from the rules:

`snakemake --cores 8 --use-conda --conda-create-envs-only`

### Option 1:
`mkdir -p snakejob_logs`
`nohup snakemake --keep-going --use-conda --verbose --printshellcmds --reason --nolock --cores 31 --max-threads 15 --cluster "qsub -V -b y -j y -o snakejob_logs/ -cwd -q fast.q,small.q,medium.q,large.q -M user.email@gmail.com -m be" > nohup_ml-supermatrix-tree_$(date +"%F_%H").out &`

Remember to:
1. Modify *user.email@gmail.com*
3. Change values for --cores and --max-threads accordingly 

### Option 2:

A template jobscript `template_run_ml-supermatrix-tree.sh` is found under `misc/`

**Important:** Please, modify the qsub options according to your system! 
Features to modify:
- E-mail address: -M *user.email@gmail.com*
- Mailing settings, if needed: -m *be*
- If you  want to split stderr to stdout, use `-j n` instead and add the line `#$ -e cluster_logs/`
- If you want to, the name of the jobscript: `-N *ml-supermatrix-tree*`
- **Name of parallel environment (PE) as well as the number of maximum threads to use:** `-pe *smp 31*`
- **Queue name!** (extremely unique to your system): `-q *small.q,medium.q,large.q*`

Ater modifying the template, copy it (while also modifying its name) to the working directory:

If you are within the folder `misc/`:

`cp template_run_ml-supermatrix-tree.sh ../run_ml-supermatrix-tree.sh`

You should see within the path where the folders config/, resources/, results/, and workflow/ are, together with files README.md and environment.yaml

Finally, run:

`qsub run_ml-supermatrix-tree.sh`
