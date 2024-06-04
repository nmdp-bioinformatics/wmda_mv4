# wmda_mv4
WMDA matching validation code


# Requirements

This system works from a config file.
The default location is `conf/config.json`

The data sources are not included in this repo.

## MV4 dataset

The MV4 dataset needs to be downloaded.
A good location is `data/MV4`.
The files `donors.csv` and `patients.csv` should be in that directory.



## results datasets

The results datasets should be downloaded.

A good location is `data/results/REGISTRY/DATE/results.csv`.

For the comparison, a single letter code is used to identify this registry in the config file and will refer to it in the output.

## parameters

`keep_zero_prob`

If this is set to `0` then any cases where P(8/10) + P(9/10) + P(10/10) <=0 will be excluded from analysis.  Note the <= is needed because at least one participant saw fit to use negative probability values. 


# Procedure

1. download MV4 dataset and place it in `data/MV4/`.  The expected files are `patients.csv` and `donors.csv`.
2. set the `mv4_datadir` variable in `config.json` approrpriately
3. download results and place them in `data/results/REGISTRY/DATE/`
4. set update `config.json` results list with an apporpriate letter and filepath
5. repeat the previous two steps for all participating groups
6. run scripts/joinall.pl 
7. output will be in `output/all.txt`
8. run scripts/stats.pl
9. output will be in `output/stats.txt'


