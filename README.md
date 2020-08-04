# PEPATO
PErformance indicators of spatiotemporal PATterns of the spinal muscle coordination Output during walking with an exoskeleton


## Data format

[4.5. Electromyography file](https://github.com/aremazeilles/eurobench_documentation/blob/master/data_format.adoc#electromyography-file)

[4.9. Gait events file](https://github.com/aremazeilles/eurobench_documentation/blob/master/data_format.adoc#gait-events-file)

- Electromiography and Gait events files should be named the same
- File name format (gait speed V should be from the list of [2, 4, 6] km per hour):
```
subject_N_run_R_speedVkmh_emg.csv
subject_N_run_R_speedVkmh_gaitEvents.yaml
```


## Octave version >= 5.2.0
### Packages required: signal >= 1.4.1 statistics >= 1.4.1
### Run (bash)
```
>>> ./run_pepato left BLF ./test_data ./test_data
``` 
- Set body side, NMF stop criteria, input dir and output dir
- Body side should be from the list of ['left', 'right']
- NMF stop criteria should be from the list of ['BLF', 'R2=0.90', 'N=4']