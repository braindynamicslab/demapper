# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information
import os

project = 'MapperToolbox'
copyright = '2022, Brain Dynamics Lab @ Stanford'
author = 'Daniel Hasegan'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['sphinxcontrib.matlab', 'sphinx.ext.autodoc', 'sphinx.ext.napoleon']

templates_path = ['_templates']
exclude_patterns = []

def get_mappertoolbox_path():
  toks = os.path.abspath('.').split('/')
  mt_inds = [i for i,tok in enumerate(toks) if tok == 'mappertoolbox-matlab']
  return '/'.join(toks[:mt_inds[0]+1]) if len(mt_inds) else os.path.abspath('.')

primary_domain = 'mat'
matlab_src_dir = get_mappertoolbox_path()

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
