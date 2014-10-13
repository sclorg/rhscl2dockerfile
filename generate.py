#!/usr/bin/python

from jinja2 import Template
import yaml
import os
import sys

y = yaml.safe_load(open('rhscl.yaml'))

for coll, cvars in y["collections"].items():
    for tname, tvars in y["templates"].items():
        outdir = tname + "." + coll
        try:
            os.makedirs(outdir)
        except:
            pass
        # Set up collection variables which can be substituted in templates
        if 'collection' not in cvars:
            cvars["collection"] = coll
        for template, output in tvars.items():
            # Allow use of variables in output filenames as well as files
            output = outdir + "/" + Template(output).render(cvars)
            # Produce output from template through Cheetah:
            temp = Template(open(template, "r").read()).render(cvars)
            # Write it.
            open(output, "w").write(temp)
             
            print("wrote %s for %s on %s" % (output, coll, tname))
	    	
