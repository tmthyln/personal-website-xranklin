<!--
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
-->
@def website_title = "Timothy Lin"
@def website_descr = "Personal website and blog for Tim Lin"
@def website_url   = "https://timothylin.me"

@def author = "Timothy Lin"
@def generate_rss = true

@def blogpost = false

@def mintoclevel = 2

<!--
Add here files or directories that should be ignored by Franklin, otherwise
these files might be copied and, if markdown, processed by Franklin which
you might not want. Indicate directories by ending the name with a `/`.
-->
@def ignore = ["node_modules/", "franklin", "franklin.pub", ".github/", ".idea/", "public/"]

<!--
Global latex commands
-->
\newcommand{\reason}[1]{\quad\text{#1}}
