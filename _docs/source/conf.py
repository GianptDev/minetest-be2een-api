# Configuration file for the Sphinx documentation builder.

project = 'Be2een Api'
copyright = '2023 _gianpy_'
author = 'GianptDev (_gianpy_)'

release = '1.0.stable'
version = '1.0.stable'

# -- General configuration

extensions = [
    'sphinx.ext.imgmath',
    'sphinx.ext.doctest',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.intersphinx',
    'sphinxcontrib.luadomain',
]

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}
intersphinx_disabled_domains = ['std']

templates_path = ['_templates']

# -- Options for HTML output

html_theme = 'sphinx_rtd_theme'

# -- Options for EPUB output
epub_show_urls = 'footnote'
