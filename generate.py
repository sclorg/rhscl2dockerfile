#!/usr/bin/python

from jinja2 import Environment, Template
import yaml
import os
import sys
import shutil


def copy(src, dst):
    if os.path.isdir(src):
        if os.path.exists(dst):
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
    else:
        shutil.copy(src, dst)


def get_add_files(cvars, tname):
    # Add distro-specific files, distro-agnostic files are already in cvars
    # if defined
    add_key = 'add.{}'.format(tname)
    if add_key in cvars:
        add_files = cvars[add_key]
    elif 'add' in cvars:
        add_files = cvars['add']
    else:
        add_files = []

    # Set correct src and dst values
    result = []
    for f in add_files:
        try:
            [src, dst_file, dst_dir] = f.split()
            # we use dst_file here since that is how the file is called
            # in the dockerfile directory
            result.append({'src': os.path.join('.', dst_file),
                           'dst': os.path.join(dst_dir, dst_file)})
            copy(src, os.path.join(outdir, dst_file))
        except ValueError:
            print('Error: added files spec has incorrect format: {}'.format(f))
    return result


y = yaml.safe_load(open('rhscl.yaml'))

env = Environment(keep_trailing_newline=True)

for coll, cvars in y["containers"].items():
    for tname, tvars in y["templates"].items():
        outdir = tname + "." + coll
        try:
            os.makedirs(outdir)
        except:
            pass
        # Set up collection variables which can be substituted in templates
        cvars["container"] = coll
        if 'collection' not in cvars:
            cvars["collection"] = coll
        if 'enable' not in cvars:
            cvars["enable"] = [cvars["collection"]]
        cvars['add_files'] = get_add_files(cvars, tname)

        for template, output in tvars.items():
            # Allow use of variables in output filenames as well as files
            output = os.path.join(outdir, Template(output).render(cvars))
            # Construct a template, render output, write, done.
            temp = env.from_string(open(template, "r").read())
            outp = temp.render(cvars)
            open(output, "w").write(outp)
             
            print("wrote %s for %s on %s" % (output, coll, tname))
	    	
