# Please run this script from the top directory Liu_et_al_Sup_Files

#%% Cell 1 - Import prerequisites ---------------------------------------------
import csv
import pandas as pd
import pickle
import os
import os.path


#%% Cell 2 - Specify global variables -----------------------------------------
topLevelFolder4Data = "./indel/input"
topLevelFolder4Run = "./indel/raw_results"
folder4Summary = "./indel/summary"
if os.path.isdir(folder4Summary) == False:
    os.mkdir(folder4Summary)
# Specify dataset names
datasetNames = ("Noiseless", "Moderate", "Realistic")
# Specify name of computational approach
# to summarize from their profiling output.
toolName = "SigProfilerExtractor"
# Specify seeds used in analysis.
# Specify 5 seeds used in software running
seedsInUse = (145879, 200437, 310111, 528401, 1076753)


#%% Cell 3 - Run summary script -----------------------------------------------
DF = pd.DataFrame()
# "ii" serves as an index for row names of DataFrame
ii = 0
# Summarizing code-profiling results for R packages.
for datasetName in datasetNames:
    for seedInUse in seedsInUse:
        # Load profiling dict from a pickle file
        run_path = topLevelFolder4Run+"/"+toolName+\
            ".results/"+datasetName+"/seed."+str(seedInUse)
        pickle_file = open(run_path+"/profiling_info.pickle", "rb")
        profile_dict = pickle.load(pickle_file)
        pickle_file.close()
        # Calculate CPU time in seconds,
        # Including the process and its child processes.
        cpu_time = profile_dict['cpu_time']
        # Combine CPU time of all runs in seconds,
        # Including the process and its child processes.
        foo = pd.DataFrame({
            "Approach": toolName,
            "Noise_level": datasetName,
            "Run": "seed."+str(seedInUse),
            "CPU_time": cpu_time}, 
            index = [ii])
        DF = pd.concat([DF, foo])
        ii += 1
          

#%% Cell 4 - Write DF ---------------------------------------------------------
DF.to_csv(folder4Summary+"/cpu_time_SigProfilerExtractor.csv",
          index=False,
          quoting=csv.QUOTE_ALL)
