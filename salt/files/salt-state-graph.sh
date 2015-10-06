#!/bin/bash

salt-call state.show_highstate --out yaml > ./highstate
python salt-state-graph.py < ./highstate > ./highstate.dot
dot -Tpng < ./highstate.dot -o ./highstate.png
dot -Tsvg < ./highstate.dot -o ./highstate.svg
