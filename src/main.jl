using Distributed
using Gtk
using InspectDR
using Reactive
using Colors
using DataFrames
using DataStructures
using Dates
using Distributions
using Interpolations
using FFTW
using Statistics
using Printf
using CSV
using LibSerialPort
using NumericIO
using LabjackU6Library

# Custom Packages
addprocs(2)
include("DataAcquisitionLoops.jl")
include("PowerSpectra.jl")
include("MCA.jl")
using .DataAcquisitionLoops, .PowerSpectra, .MCA

# Start DAQ Loops
Godot1 = @spawnat 2 DataAcquisitionLoops.aquire(-1)
Godot2 = @spawnat 3 MCA.acquire_mca()

(@isdefined wnd) && destroy(wnd)                   # Destroy window if exists
gui = GtkBuilder(filename = pwd() * "/gui.glade")      # Load the GUI template
wnd = gui["mainWindow"]                            # Set the main windowx

include("gtk_graphs.jl")              # Generic GTK graphing routines
include("global_variables.jl")        # Signals and global constants
include("gtk_callbacks.jl")           # Link GTK GUI fields with code
include("gui_updates.jl")             # Update loops for GUI IO
include("labjack_io.jl")              # Labjack Data Aquisition
include("synthetic_data_stream.jl")   # Synthetic Data Aquistion for testing
include("setup_graphs.jl")            # Initialize graphs for GUI

Gtk.showall(wnd)                      # Show the window

oneHz = every(1.0)               # 1  Hz timer
tenHz = every(0.1)               # 10 Hz timer
griddedHz = every(10)            # regridding update frequency
graphHz = every(15)              # graph update frequency
ECHz = every(300)                # EC data update frequency

griddedData = map(_ -> (@async update_gridded_data()), griddedHz)
graphLoop1 = map(_ -> (@async update_graphs()), graphHz)
graphLoop2 = map(_ -> (@async update_turbulence()), graphHz)
tenHzFields = map(_ -> (@async update_oneHz()), oneHz)
oneHzFields = map(_ -> (@async update_tenHz()), tenHz)
ECdataDump = map(_ -> (@async update_EC()), ECHz)
PSDdataDump = map(_ -> (@async update_spectra()), ECHz)


#@spawnat 2 DataAcquisitionLoops.sendStr1("STS,45.0\r");
#@spawnat 2 DataAcquisitionLoops.sendStr1("STC,9.0\r");
#@spawnat 2 DataAcquisitionLoops.sendStr1();
@spawnat 2 DataAcquisitionLoops.sendStr1("RALL\r");
a,b,c = @spawnat 2 DataAcquisitionLoops.readStr1()
