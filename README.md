#  ILMTurk

This is a repository containing the web program to run an Iterated Learning experiment through mechanical turk and the final data and analysis scripts for the non-linear flute experiment.

##  Program

The folder `web` Contains public-facing code for the web program.  The folder `private` contains the server-side code and space for results to be written.

'private/fluteilm/outputLanguages/somefilename' - the final signal
for each meaning used by the participant

private/fluteilm/results/somefilename - a detailed recording of every
action taken by the participant. 

private/fluteilm/log/somefilename - details of client's browser type etc.

The training round includes reproducing 'arbitrary' signals.  These are loaded from private/fluteilm/trainingData/trainingSignals.txt.


### Parameters

####  Running an experiment with a live participant on a tablet:

http://host-server.com/fluteilm_SONA/tablet.html?SONA=t

Left handed version:

http://host-server.com/fluteilm_SONA/tablet.html?SONA=t&left=t

Tablets should use Firefox, and be set to 'full screen', portrait (you should lock the rotation).
Remember to clear Firefox's cache before you start so that the most recent version of the code is downloaded.
You should close the page after the experiment has finished (even if you are about to run another experiment).
If the whistle starts becoming slow, try shutting down/restarting the Firefox app entierly.

####  Running an experiment on mechanical turk:

host-server.com/fluteilm/index.html

####  Test experiment:

http://host-server.com/fluteilm_TEST/index.html?test=t

Or tablet version:
   
http://host-server.com/fluteilm_TEST/tablet.html?SONA=t&test=t

(The log never updates in this version, so data won't carry over from generations, though results files are written.  If you leave out the "?test=t" part, then the log will be updated.)

This means the output filename is set to 'testExperiment.txt' and the pass rate for the learning phase is set to 25% (just need one correct). 

## Stats

The data has been compiled into csv files here:  stats/Data/

Overall summaries of the data can be found here: stats/graphs/summary/Summary.pdf

The main analysis scripts are:

-  stats/R/TestPredictions_blmer_Combined.pdf
-  stats/R/TestRobustness.pdf