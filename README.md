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
(basic functionality)
### Packages required: signal >= 1.4.1 statistics >= 1.4.1
### Run (bash)
```
>>> ./run_pepato left BLF ./test_data ./test_data
``` 
- Set body side, NMF stop criteria, input dir and output dir
- Body side should be from the list of ['left', 'right']
- NMF stop criteria should be from the list of ['BLF', 'R2=0.90', 'N=4']
### Run (octave-client)
```
>>> pepato_basic('test_data', 'test_data', 'left', {20, 400, 200, 8, 10, 'N=4'}, 'db/db_healthy_adults_8m.mat', {'BiFe', 'SeTe', 'VaMe', 'VaLa', 'ReFe', 'TiAn', 'GaMe', 'Sol'});
``` 
- Set input_folder, output_folder, body_side, config parameters, database filename and list of muscles (optional)
- Format of path folder: path from current folder or full path
- The output files will be saved to the output folder as 'subject_N_run_R_output.yaml'


## MATLAB version >= 2015b
(full functionality, advanced GUI)
### Run
```
>>> PEPATO(8, 'left', 'cfg/initial_cfg.mat', 'db/db_healthy_adults_8m', {'BiFe', 'SeTe', 'VaMe', 'VaLa', 'ReFe', 'TiAn', 'GaMe', 'Sol'});
``` 
- Set GUI font size, body side, name of config file, name of database file and muscle list (optional)