
## Quick Introduction

The input file `run.abi` allows one to perform all the four steps of a typical
GW calculations with Abinit (SCF, NSCF, screening, sigma).

To activate/deactivate the different steps one can play with the two
input variables `ndtset` (number of datasets) and
`jdtset` that is a list of `ndtset` integers giving the index of the dataset(s) to be executed.

To perform the first two steps (SCF + NSCF), one uses:

	ndtset 2
	jdtset 1 2

Once the computation is completed, one can activate the screening part with:

	ndtset 1
	jdtset 3

For the last step (sigma), one should use:

	ndtset 1
	jdtset 4

There's no needed to change other input variables to go from one step to the next one
as Abinit will automatically read the files produced by the previous datasets in the `outdata` directory

Before running the code, create the three directories: indata, outdata, tmpdata

then run the code by using e.g.:

	mpirun -n ${SLURM_NTASKS} abinit run.abi > run.log 2> run.err


Four Megabytes per CPU should be enough for this system.

Reference output files are available in `screening_refs` and `sigma_refs` but I don't expect the numerical
results to be stable as the WFK is not converged.

### MPI-parallelism in the SCF + NSCF part.

I've designed the input file so that one can execute this part on an arbitrary number of MPI procs.
For performance reasons, however, the number of MPI procs should be a multiple
of the number of k-points (called nkpt in run.abi).

Note that in real-applications, the NSCF part is one of the bottlenecks as one has to converge
many empty states.
In this benchmark, I force the NSCF solver to exit after one iteration to speed things up
so this part should take a couple of minutes.
Clearly, the final results will be completely unphysical.

### MPI-parallelism in the GW code

Both in the screening and in the sigma part, the MPI distribution is automatically defined
at runtime on the basis on the number of MPI procs provided by the user so there's no need
to set special MPI variables in the input file.
Note however that screening and sigma use two different MPI algorithms.

In the screening part one distributes the last (nband3 - nelect/2)
states where nelect is the number of valence electrons (this is a system-dependent quantity)
while in sigma we distribute nband4 states
(let's use the term "number of effective states" to denote this dimension).

To avoid load imbalance the number of effective states should be divisible by the
number of MPI procs but this is now always possible.
If the number of procs is larger than the number of effective states, the code activates
a different distribution scheme over transitions but I don't expect this algorithm to have
very good parallel efficiency.

Last but not least, the value of nband3 (nband4) used in the screening (sigma) part cannot be greater
than the number of bands computed in the NSCF run (nband2).
Abinit won't stop, it will just use the max number of bands found in the WFK file (nband2).
In a nutshell, in order to use more bands in the screening/sigma part one has to rerun the SCF+NSCF
with a larger value of nband2.

In a typical scenario, however, one would run the provided input file
(in particular the screening and the sigma part) with a different number of MPI procs
to analyze the strong scaling behavior.

## Final remarks

I consider ZrO2 a small systems when it comes to "standard" GW calculations where standard
means the fastest recipe available nowadays that is known to work well in "simple systems".

I don't expect great results in the strong scaling metrics because the workload is small
and other non-scalable sections such as the IO part or the routines used to distribute the work
at runtime are expected to dominate, especially for large number of cores.

Yet, one can use this input file to perform an initial POP analysis with a relatively small number of processors
(let's say <~ 500) to detect non-scalable sections, bottlenecks and inefficiencies.
I would suggest to focus more on the screening part as the sigma step for this system is relatively fast.
The main issue in sigma is represented by the memory requirements as not all the datastructures are MPI-distributed.

Once we have some results for these initial benchmark, we can discuss about the next steps and I can 
provide input files for larger systems.

