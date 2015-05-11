#!/usr/bin/python

from jinja2 import Environment, Template, FileSystemLoader
import yaml
import os
import sys
import shutil
import argparse


class CollectionGenerator:
    def __init__(self, gen, cvars, coll, tname, tvars):
        self.cvars = cvars
        self.gen = gen
        self.collection = coll
        self.tname = tname
        self.tvars = tvars

    def copy_render(self, src, dst, allways_render=True):
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
                                 os.path.join(dst, f),
                                 allways_render=allways_render)
        else:
            if allways_render or src.endswith('.tpl'):
                if dst.endswith('.tpl'):
                    dst = dst[0:-4]
                # Construct a template, render dst, write, done.
                with open(src, 'r') as f:
                    temp = self.gen.env.from_string(f.read())
                with open(dst, "w") as f:
                    f.write(temp.render(self.cvars))
            else:
                shutil.copyfile(src, dst)
            shutil.copymode(src, dst)
 

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
                [src, dst_file, dst_dir] = f
                dst_file = self.gen.env.from_string(dst_file).render(self.cvars)
                dst_dir = self.gen.env.from_string(dst_dir).render(self.cvars)
                # we use dst_file here since that is how the file is called
                # in the dockerfile directory
                self.copy_render(os.path.join(self.gen.cwd, src),
                                 os.path.join(self.outdir, dst_file),
                                 allways_render=False)
                print("wrote %s for %s on %s" % (os.path.join(self.outdir, dst_file), self.collection, self.tname))
                d_src = os.path.join('.', dst_file)
                d_dst = os.path.join(dst_dir, dst_file)
                uniq = True
                for i in result:
                    if i['src'] == d_src and i['dst'] == d_dst:
                        uniq = False
                if not uniq:
                    continue
                result.append({'src': d_src,
                               'dst': d_dst})
            except ValueError:
                print('Error: added files spec has incorrect format: {}'.format(f))
        self.cvars['add_files'] = result


    def handle_other_files(self):
        """
        Handle files that are just added to Dockerfile directory and these
        files also can include template macros that will be expanded.
        """
        add_key = 'files.{}'.format(self.tname)
        if add_key in self.cvars:
            add_files = self.cvars[add_key]
        elif 'files' in self.cvars:
            add_files = self.cvars['files']
        else:
            add_files = []

        # Set correct src and dst values
        for f in add_files:
            try:
                [src, dst_file] = f
                self.copy_render(os.path.join(self.gen.cwd, src),
                                 os.path.join(self.outdir, dst_file),
                                 allways_render=False)
                print("wrote %s for %s on %s" % (os.path.join(self.outdir, dst_file), self.collection, self.tname))
            except ValueError:
                print('Error: files spec has incorrect format: {}'.format(f))


    def set_defaults(self):
        """
        Set up collection variables which can be substituted in templates
        """
        # copy values from template, just add no overwrite nor add duplicates
        for k in self.tvars:
            if k not in self.cvars:
                self.cvars[k] = self.tvars[k]
            elif type(self.cvars[k]) is list:
                for kk in self.tvars[k]:
                    if kk not in self.cvars[k]:
                        self.cvars[k].append(kk)

        # add some more values specific for the collection
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
        self.handle_other_files()


class DockerfileGenerator:
    def __init__(self, config_file, result_dir):
        self.config_file = config_file
        self.y = yaml.safe_load(open(self.config_file))
        self.env = Environment(keep_trailing_newline=True)
        self.env.loader = FileSystemLoader('.')
        self.cwd = os.path.dirname(self.config_file)
        self.result_dir = result_dir

    def generate_all(self):
        """
        Loops through all collections in the config file and generates
        Dockerfile and other files for every collections specified.
        """
        for coll, cvars in self.y["containers"].items():
            for tname, tvars in self.y["templates"].items():
                outdir = os.path.join(self.result_dir, tname + "." + coll)
                try:
                    os.makedirs(outdir)
                except:
                    pass
                collection = CollectionGenerator(self, cvars, coll, tname, tvars)
                collection.generate(outdir)


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='RHSCL Dockerfile Generator')
    parser.add_argument('-c', '--config_file', metavar='rhscl.yaml', type=str,
                        default='rhscl.yaml',
                        help='YAML with collections specification, rhscl.yaml'+
                             'used as default')
    parser.add_argument('-r', '--result', metavar='dir', type=str, default='.',
                        help='Result dir where to store dockerfiles, default is "."')
    args = parser.parse_args()
    generator = DockerfileGenerator(args.config_file, args.result)
    generator.generate_all()

