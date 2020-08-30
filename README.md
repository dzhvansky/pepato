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
## Requirements

- octave version >= 5.2.0
- octave packages required: signal >= 1.4.1 statistics >= 1.4.1

## Usage
```
>>> ./run_pepato left BLF ./test_data ./test_data
``` 

- Set body side, NMF stop criteria, input dir and output dir
- Body side should be from the list of ['left', 'right']
- NMF stop criteria should be from the list of ['BLF', 'R2=0.90', 'N=4']

## Docker image 

_(only tested under linux)_

Run the following command in order to create the docker image:

```console
docker build . -t pi_pepato
```

Assuming folder `test_data` contains the input data, and folder `output` is already created (to contain output file):

```shell
docker run --rm -v $PWD/test_data:/in -v $PWD/output:/out pi_pepato ./run_pepato left BLF /in /out
```

## Acknowledgements

<a href="http://eurobench2020.eu">
  <img src="http://eurobench2020.eu/wp-content/uploads/2018/06/cropped-logoweb.png"
       alt="rosin_logo" height="60" >
</a>

Supported by Eurobench - the European robotic platform for bipedal locomotion benchmarking.
More information: [Eurobench website][eurobench_website]

<img src="http://eurobench2020.eu/wp-content/uploads/2018/02/euflag.png"
     alt="eu_flag" width="100" align="left" >

This project has received funding from the European Union’s Horizon 2020
research and innovation programme under grant agreement no. 779963.

The opinions and arguments expressed reflect only the author‘s view and
reflect in no way the European Commission‘s opinions.
The European Commission is not responsible for any use that may be made
of the information it contains.

[eurobench_logo]: http://eurobench2020.eu/wp-content/uploads/2018/06/cropped-logoweb.png
[eurobench_website]: http://eurobench2020.eu "Go to website"
