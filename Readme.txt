* in 4-17 version, the actions are sampling (uniformly?)
pomdp struct members definition:
 
nrStates       - (1 x 1) number of states
states         - (nrStates x X) chars, name of each state *)
nrActions      - (1 x 1) number of actions
actions        - (nrActions x X) chars, name of each action *)
nrObservations - (1 x 1) number of observations
observations   - (nrObservations x X) chars, name of each
                 observation *)
gamma          - (1 x 1) discount factor
values         - (1 x X) chars, 'reward' or 'cost'
start          - (1 x nrStates) start distribution *)
if useSparse
reward3S     - (1 x nrActions) cell array, containing structs:
                   {nrActions}(nrStates x nrStates)
                       a          s'         s          R(s',s,a)
   observationS - (1 x nrActions) cell array, containing structs:
                   {nrActions}(nrStates x nrObservations)
                       a          s'         o          P(o|s',a)
   transitionS  - (1 x nrActions) cell array, containing structs:
                   {nrActions}(nrStates x nrStates)
                       a          s'         s          P(s'|s,a)
 else
   reward3        - (nrStates x nrStates x nrActions)
                        s'         s           a        R(s',s,a)
   observation    - (nrStates x nrObservations x nrActions)
                        s'          o                a  P(o|s',a)
   transition     - (nrStates x nrStates x nrActions)
                        s'         s           a        P(s'|s,a)
 end

Members marked by *) are optional: they might not be present in
the POMDP file, in that case these members are non-existing or
empty.