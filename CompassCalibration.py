# -*- coding: utf-8 -*-
__doc__ = """
---------------------------------------------------------------------------
 Calypso Ultrasonic Anemometer - Compass Calibration Algorithm
---------------------------------------------------------------------------
"""
__date__ = "mon/dd/2018"
__author__ = "Volker Petersen"
__copyright__ = "Copyright (c) 2017 Volker Petersen"
__license__ = "Python 3.6 | GPL http://www.gnu.org/licenses/gpl.txt"
__version__ = "xxx.py [ver1.0]"

try:
	import os
	import sys
	import inspect
	import numpy as np
	import matplotlib.pyplot as plt
	from datetime import datetime

except ImportError as e:
	print("Import error: %s \nAborting the program %s" %(e, __version__))
	sys.exit()

def analyze_data(cwd, name):
	csv = np.genfromtxt(os.path.join(cwd, name), delimiter=",", skip_header=1)
	raw = csv[:,6]
	rawY = np.sin(np.deg2rad(raw))
	rawX = np.cos(np.deg2rad(raw))
	print(raw[:10])
	print(rawX[:10], rawY[:10])

	plt.plot(rawX, rawY, 'o')
"""
|------------------------------------------------------------------------------------------
| main
|------------------------------------------------------------------------------------------
"""
if __name__ == "__main__":
	print (__doc__)

	# fetch the content from the default settings file
	cwd = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))

	analyze_data(cwd, "CompassCalibrationTestData.csv")

	print ("\n\nProgram is done!\n")
