#
import numpy as np


#######################################################################
#Make pdb
#######################################################################
#
#Generate a list of lines for a pdb file for a given coordinate matrix
#
#inputs
#r - matrix of bead positions
#connect - list of tuples (i,j) which specify beads that are connected
#Atom - list of strings where A[i] is the name atom of the ith bead
#serial -numpy array of atom serial  numbers
#b - numpy vector of b-factors
#occup - numpy vector of occupancies 
#chain - list of strings of chain names for ith bead
#res - list of strings with residue names
#element - list of element names 
#topology - topology of chain. "circular" or "linear"
#######################################################################


def mkpdb(r, connect = None,Atom = None, serial = None,b = None, occup = None, chain = None, res = None, element = None,topology = 'linear'):
    N = len(r[:,0]) #number of beads

    #Define default values if None given for atom specifiers
    if Atom is None:
        Atom = ['A1' for i in range(N)]
    if serial is None:
        serial = [i for i in range(N)]
    if b is None:
        b = np.zeros(N)
    if occup is None:
        occup = np.ones(N)
    if chain is None:
        chain = ['A' for i in range(N)]
    if res is None:
        res = ['DNA' for i in range(N)]
    if element is None:
        element = ['C' for i in range(N)]

    #If no connectivity set is given, adjacent beads are connected while respecting topology
    if connect is None:
        connect = [(i,i+1) for i in range(N-1)]
        if topology == 'circular':
            connect.append((N-1,0))
    
    #Initialize list of lines
    lines = []
    #loop over atoms
    for i in range(N):
        line = 'ATOM'.ljust(6)
        line += ('%s' %serial[i]).rjust(5)
        line += ('%s' %Atom[i]).rjust(5)
        line += ' '
        line += ('%s' %res[i]).rjust(3)
        line += ('%s' %chain[i]).rjust(2)
        line += ' '*8
        line += ('%.1f' % r[i,0]).rjust(8)
        line += ('%.1f' % r[i,1]).rjust(8)
        line += ('%.1f' % r[i,2]).rjust(8)
        line += ('%.1f' % occup[i]).rjust(6)
        line += ('%.1f' % b[i]).rjust(6)
        line += element[i].rjust(12) 
        lines.append(line)
    
    #loop over connections
    for i,c in enumerate(connect):
        line = 'CONECT'.rjust(6)
        line += ('%s' %c[0]).rjust(5)
        line += ('%s' %c[0]).rjust(5) 
        line += ('%s' %c[1]).rjust(5)
        lines.append(line)
    lines.append('END')
    #return list of lines
    return lines

#################################################################
#Save a pdb file, given a list of lines
##################################################################
#inputs
#save_file - string containing file name
#lines - list of strings, each corresponding to a line of the pdb
#as generated by mk_pdb

def save_pdb(save_file,lines):
    with open(save_file, 'w') as f:
        for line in lines:
            f.write(line  + '\n')

