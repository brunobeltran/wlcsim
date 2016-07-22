#
# Makefile
#
# wlcsim
#
# Author: Bruno Beltran <brunobeltran0@gmail.com>
#

# # replaced rm **.o with more portable find commands
# # and regex search =~ in distclean with manual check for Y/y
SHELL:=/bin/bash
# .SHELLFLAGS="-O extglob -c"

# script to automatically generate dependencies
MAKEDEPEND=./fort_depend.py

# $(DEP_FILE) is a .dep file generated by fort_depend.py
DEP_FILE = wlcsim.dep

# compiler
FC = gfortran

# compile flags
FCFLAGS = -O3 -Jsrc -Isrc -Isrc/third_party -cpp
# FASTFLAGS = -O3 -Jsrc -Isrc -Isrc/third_party -cpp
# PEDANTICFLAGS = -ggdb -Jsrc -Isrc -Isrc/third_party -cpp -fcheck=all -Wall -pedantic

# link flags
FLFLAGS =

# modules first, since they're heavily depended on
# when doing it this way, a module must be listed after other modules it
# depends on
MOD_SRC := src/third_party/mt19937.f90 src/third_party/kdtree2.f90 src/BDcode/colsort.f90
MOD_MOD := $(addprefix src/,$(notdir $(MOD_SRC:.f90=.mod)))
SRC := src/DATAcode/MINV.f90 src/DATAcode/find_struc.f90 src/BDcode/force_elas.f90 src/BDcode/force_ponp.f90 src/BDcode/RKstep.f90 src/BDcode/concalc.f90 src/SIMcode/debugging.f90 src/third_party/dgtsv.f src/BDcode/BDsim.f90 src/MCcode/MC_move.f90 src/MCcode/MCsim.f90 src/MCcode/MC_elas.f90 src/MCcode/MC_capsid_ex.f90 src/MCcode/MC_self.f90 src/SIMcode/globals.f90 src/SIMcode/stressp.f90 src/SIMcode/energy_ponp.f90 src/SIMcode/gasdev.f90 src/SIMcode/r_to_erg.f90 src/SIMcode/ran2.f90 src/SIMcode/decim.f90 src/SIMcode/wlcsim.f90 src/SIMcode/stress.f90 src/SIMcode/ran1.f90 src/SIMcode/energy_elas.f90 src/SIMcode/initcond.f90 src/SIMcode/getpara.f90 src/BDcode/colchecker.f90
OBJ := $(addsuffix .o,$(basename $(MOD_SRC))) $(addsuffix .o,$(basename $(SRC)))
TEST := src/CCcode/test_sort.f90

# program name
PROGRAM = wlcsim.exe

# test:
# 	@echo $(value MOD_MOD)

# by default, compile only
all: $(PROGRAM) Makefile $(DEP_FILE)

# a target to just run the main program
run: $(PROGRAM) dataclean
	./$(PROGRAM)

# target to build main program
$(PROGRAM): $(OBJ)
	$(FC) $(FCFLAGS) $(FLFLAGS) -o $@ $^

.PHONY: depend clean destroy dataclean

clean: dataclean
	find src \( -iname '*.o' -or -iname '*.mod' \) -delete
	rm -f wlcsim wlcsim.dep

dataclean:
	mkdir -p data trash
	touch "data/`date`"
	mv data/* trash/.

DEATH=rm -rf trash data savedata par-run-dir.*
distclean: clean
	@echo "About to destroy all simulation data, are you sure? ";
	read REPLY; \
	echo ""; \
	if [[ "$${REPLY:0:1}" == "Y" || "$${REPLY:0:1}" == "y" ]]; then \
		echo 'Running `${DEATH}`'; \
		${DEATH}; \
	else \
		echo 'Canceling data deletion!'; \
	fi

# Make dependencies
depend: $(DEP_FILE)

$(DEP_FILE): $(MOD_SRC) $(SRC)
	@echo "Making dependencies!"
	$(MAKEDEPEND) -w -o $(DEP_FILE) -f $(SRC) $(MOD_SRC) -c "$(FC) -c $(FCFLAGS) "

include $(DEP_FILE)
