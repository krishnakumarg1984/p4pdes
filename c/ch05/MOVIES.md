Making movies
=============

PETSc TS codes, like the ones in this directory, can generate binary files containing the _trajectory_, that is, the time-axis _t_ and the solution _y(t)_.  One may then plot solutions as curves in the time-versus-solution plane, as trajectories.  Additionally, for codes that solve PDEs in two spatial dimensions, e.g. `heat.c` and `pattern.c` in this directory, one can generate a movie.

The light-weight method here is based on the [python](https://www.python.org/)/[matplotlib](http://matplotlib.org/) script `plotTS.py` in the current directory.  It needs either local copies of, or sym-links to, `PetscBinaryIO.py` and `petsc_conf.py` which are in `$PETSC_DIR/lib/petsc/bin/`.

For improved visualization one might either improve/modify the script or switch to a more advanced visualization framework like [paraview](http://www.paraview.org/).

trajectories
------------

First we show how to view trajectories as curves in the _t,y_ plane.  One gets multiple curves on the same graph if the vector _y_ has dimension greater than one.

For saving an image file of type `.png` with the same basic appearance, use `plotTS.py`:

        ./ode -ts_monitor binary:t.dat -ts_monitor_solution binary:y.dat
        ./plotTS.py t.dat y.dat -o result.png

(A common error at this stage arises from not copying `PetscBinaryIO.py` and `petsc_conf.py` from `$PETSC_DIR/bin/` to the current directory, or making sym-links.)

Without option `-o` (or `-oroot` below), the script simply shows the result on the screen:

        ./plotTS.py t.dat y.dat

For comparison, one can also use PETSc alone for a run-time "line-graph" view:

        ./ode -ts_monitor_lg_solution -draw_pause 0.1

The heat equation solution from `heat.c` _can_ be viewed by one of the methods above, but it is not the natural and desired visualization.  Just give it a try to see!


movie for scalar PDE in spatial 2D
----------------------------------

Two of the codes here have two spatial dimensions, namely `heat.c` and `pattern.c`.  They use both a `TS` and a 2D `DMDA` object.  Viewing the trajectory they generate requires making a movie.

Again, PETSc alone can generate the movie at run-time, for instance by

        ./heat -da_refine 4 -ts_monitor_solution draw -draw_pause 0.2

The question is how to save a convenient, possibly high-resolution, movie for future viewing.  Here is an example.  First generate and save the solution in PETSc binary-format files:

        ./heat -ts_monitor binary:t.dat -ts_monitor_solution binary:u.dat \
            -ts_max_time 0.02 -ts_dt 0.001 -da_refine 5

This run reports that the grid has dimensions 193 by 192.  Adding these grid dimension as options, the same script shows a movie on the screen:

        ./plotTS.py -mx 129 -my 128 t.dat u.dat

Simply add a filename root to save the frames in individual files:

        ./plotTS.py -mx 129 -my 128 t.dat u.dat -oroot bar

This generates files `bar000.png`, `bar001.png`, and so on, using the name pattern `bar%03d.png`.

Now use the [`ffmpeg`](https://www.ffmpeg.org/) tool, for example, to generate a `.m4v` format movie from the collection of `.png` image files:

        ffmpeg -r 4 -i bar%03d.png bar.m4v     # set rate to 4 frames/second

The compression from the `.m4v` format and `ffmpeg` is substantial.  While `u.dat` is several MB, `bar.m4v` is under 100 KB.

Viewing the movie itself requires some viewer.  On linux platforms, `totem` or `vlc` are possibilities.


movie for dof>1 PDE in spatial 2D
-----------------------------------

For problems with multiple degrees of freedom, like `pattern.c`, PETSc opens one window for each component:

        ./pattern -ts_adapt_type none -da_refine 4 -ts_max_time 300 -ts_dt 5 \
             -ts_monitor_solution draw

Generating the movie with `plotTS.py` requires setting the degrees of freedom `-dof 2`, and choosing one component using either option `-c 0` or `-c 1`.  For example:

        ./pattern -ts_adapt_type none -da_refine 5 -ts_max_time 300 -ts_dt 5 \
             -ts_monitor binary:t.dat -ts_monitor_solution binary:uv.dat
        ./plotTS.py -mx 96 -my 96 -dof 2 -c 0 t.dat uv.dat -oroot foo

Now we generate a movie the same way as above;

        ffmpeg -r 4 -i foo%03d.png foo.m4v

