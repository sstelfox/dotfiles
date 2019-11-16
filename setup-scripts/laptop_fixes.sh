#!/bin/bash

source _root_prelude.sh

# Touchpad fix
grubby --update-kernel=ALL --args="psmouse.synaptics_intertouch=1"
