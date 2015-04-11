#!/usr/bin/python

from jinja2 import Environment, Template
import yaml
import os
import sys
import shutil


class CollectionGenerator:
    def __init__(self, env, cvars, coll, tname, tvars):
        self.cvars = cvars
        self.env = env
        self.collection = coll
        self.tname = tname
        self.tvars = tvars

    def copy_render(self, src, dst):
        """
        Copy file or dir recursively from src to dst while file content
        is rendered as template using general values and values specific
        for collection.
        """
        if os.path.isdir(src):
            if not os.path.isdir(dst):
                os.makedirs(dst)
            files = os.listdir(src)
            for f in files:
                self.copy_render(os.path.join(src, f), 
                                 os.path.join(dst, f))
        else:
            # Construct a template, render dst, write, done.
            with open(src, 'r') as f:
                temp = self.env.from_string(f.read())
            with open(dst, "w") as f:
                f.write(temp.render(self.cvars))
 

    def handle_add_files(self):
        """
        Handle files that are added to Dockerfile using ADD command.
        These files are copied into dockerfile directory and content is used
        as template, so possible template macros are expanded.
        Add distro-specific files, distro-agnostic files are already in cvars
        if defined
        """
        add_key = 'add.{}'.format(self.tname)
        if add_key in self.cvars:
            add_files = self.cvars[add_key]
        elif 'add' in self.cvars:
            add_files = self.cvars['add']
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
                self.copy_render(src, os.path.join(self.outdir, dst_file))
            except ValueError:
                print('Error: added files spec has incorrect format: {}'.format(f))
        self.cvars['add_files'] = result


    def set_defaults(self):
        """
        Set up collection variables which can be substituted in templates
        """
        self.cvars["container"] = self.collection
        if 'collection' not in self.cvars:
            self.cvars["collection"] = self.collection
        if 'enable' not in self.cvars:
            self.cvars["enable"] = [self.cvars["collection"]]


    def generate(self, outdir):
        """
        Generates Dockerfile and files for one collection
        """
        self.outdir = outdir
        self.set_defaults()
        self.handle_add_files()
        for src, dst in self.tvars.items():
            # Allow use of variables in dst filenames as well as files
            dst = Template(dst).render(self.cvars)
            self.copy_render(src, os.path.join(self.outdir, dst))
            print("wrote %s for %s on %s" % (dst, self.collection, self.tname))


class DockerfileGenerator:
    def __init__(self, config_file):
        self.y = yaml.safe_load(open(config_file))
        self.env = Environment(keep_trailing_newline=True)

    def generate_all(self):
        """
        Loops through all collections in the config file and generates
        Dockerfile and other files for every collections specified.
        """
        for coll, cvars in self.y["containers"].items():
            for tname, tvars in self.y["templates"].items():
                outdir = tname + "." + coll
                try:
                    os.makedirs(outdir)
                except:
                    pass
                collection = CollectionGenerator(self.env, cvars, coll, tname, tvars)
                collection.generate(outdir)


if __name__ == "__main__":
    generator = DockerfileGenerator('rhscl.yaml')
    generator.generate_all()

