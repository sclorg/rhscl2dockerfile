#!/usr/bin/python

from jinja2 import Environment, Template
import yaml
import os
import sys

y = yaml.safe_load(open('rhscl.yaml'))

env = Environment(keep_trailing_newline=True)

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
        if 'enable' not in cvars:
            cvars["enable"] = cvars["collection"]
        for template, output in tvars.items():
            # Allow use of variables in output filenames as well as files
            output = outdir + "/" + Template(output).render(cvars)
            # Construct a template, render output, write, done.
            temp = env.from_string(open(template, "r").read())
            outp = temp.render(cvars)
            open(output, "w").write(outp)
             
            print("wrote %s for %s on %s" % (output, coll, tname))
	    	
