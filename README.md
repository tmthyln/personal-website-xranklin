# Personal Portfolio of Past and Present (and Potentially Pondering) Projects

This website contains a portfolio of miscellaneous projects and things I've done, 
from significant school projects to teaching notes to side projects to one-offs.

Originally built with Vue, then converted to Nuxt, but Javascript was abandoned in 
favor of a simpler Franklin.jl-based static generator (with minimal Javascript!).

Built with Franklin.jl.

## Setup

This site is tested with Julia 1.6 and higher. 
The website sources should only be modified from a non-`master` branch
(the main development branch is the `dev` branch).

## Development

Assuming Julia is installed, first ensure that the packages are installed:
```julia-repl
(env) pkg> activate .
(personal-website) pkg> instantiate
(personal-website) pkg> update
```

Then, in a Julia REPL,
```julia
using Franklin
Franklin.serve()
```

## Deployment

Commits to the `dev` branch on GitHub trigger the GitHub workflow, which pushes the built and 
optimized files to the root directory of the master branch.

Cloudflare Pages is set up to build from the master branch.
