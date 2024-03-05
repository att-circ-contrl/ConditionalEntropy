# Test code for the entropy library.
# Written by Christopher Thomas.

MATLAB=matlab
MATFLAGS=-nodisplay -nodesktop -nosplash

default:
	@echo "Targets:   run clean force"

force: clean run


clean:
	rm -f output/*

checkdirs:
	./checkdirs.sh

run: checkdirs
	nice -n +10 $(MATLAB) $(MATFLAGS) \
		-r "dbstop if error; run('do_test.m'); exit;"

#
# This is the end of the file.
