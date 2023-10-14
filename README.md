### Vs. Recorder
Vs. Recorder is an mGBA script for recording fights and communicating with the calc for Crystal Kaizo+.

### Installation
* Download Vs. Recorder
	* On GitHub, hit the green "Code" button then "Download ZIP"
	* Unzip into a folder
* In mGBA, enable Vs. Recorder
	* Found under Tools > Scripting...
	* In the Scripting menu File > Load Script
	* Choose `main.lua` in the Vs. Recorder folder
	* If successful, the console should read `Vs. Recorder started!`
	* You will need to enable Vs. Recorder every time you start mGBA in order to use it
* (Optional) In the [calc](https://emi.dev/ck+/), enable Vs. Recorder in the settings
	* If successful, the Sync button should show up
	* If it fails to connect, the button will turn red. Make sure Vs. Recorder is running
	* If Vs. Recorder is running, you can press Sync to update your box, like dragging in your save

### Fights
While enabled, Vs. Recorder will collect the fights you do in the folder you installed in `fights.vs`.
This is the file that needs to be manually submitted and approved to add statistics to the calc.

If you want to split up your runs, you can rename `fights.vs` to something else and Vs. Recorder will start writing a new file.

Once you've submitted your files for review, you can delete the local copy.
