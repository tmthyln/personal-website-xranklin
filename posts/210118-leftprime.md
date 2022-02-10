+++
using Dates

title = "Turn Left at the Next Prime"
blogpost = true
tags = ["julia", "math", "cs"]
date = Date(2021, 1, 18)
rss = """
	What happens when we traverse the grid of Gaussian integers by turning left whenever we hit a Gaussian prime? This is a Julia implementation of a simulation originally in Python (but was too slow for interactive exploration) of an idea originally brought up on Stack Overflow. Lots of interesting images.
	"""
desc = """
	What happens when we traverse the grid of Gaussian integers by turning left whenever we hit a Gaussian prime? This is a Julia implementation of a simulation originally in Python (but was too slow for interactive exploration) of an idea originally brought up on Stack Overflow. Lots of interesting images.
	"""
+++

@@sidetoc
\toc
@@

# Turn Left at the Next Prime
A while ago, John Cook made a
[post](https://www.johndcook.com/blog/2020/09/24/gaussian_integer_walk/)
about Gaussian integer walks. See his post for the details, but at the end, he provides
some Python code which he uses to generate the walks/plots. However, just for the
simulation starting at $127 + 130i$, it took several minutes for the whole process,
including plotting, which just seemed completely unreasonable to me as a Julia user. So
of course, I wanted to see if I could reimplement that code in Julia to be much faster
and yet not sacrifice ease of readability.

The basic premise is this: start at some point in the complex plane (with integer
coefficients), facing east. Move unit-by-unit until the number is a
[Gaussian prime](https://en.wikipedia.org/wiki/Gaussian_integer#:~:text=A%20Gaussian%20integer%20a%20%2B%20bi%20is%20a%20Gaussian%20prime%20if,the%20form%204n%20%2B%203);
if Gaussian prime, turn left.

## Code Reimplementation

The first thing we need is a function to determine if a complex number is a
Gaussian prime (Julia uses `im` for the imaginary unit):
```julia
function isgaussprime(z::Complex{<:Integer})
    a, b = real(z), imag(z)
    if a * b != 0
        return isprime(a^2 + b^2)
    else
        c = abs(a+b)
        return isprime(c) && c % 4 == 3
	end
end
```

To do the Gaussian walk, we are going to write the function `walk` that starts at some
point and keeps walking up to some limit (these walks all end up spirally, so we need
some limit):
```julia
function walk(start, limit = 10)
	points = [start]
	z = start
	delta = 1

	while limit > 0
		z = z + delta
		push!(points, z)

		isgaussprime(z) && (delta *= im)
		z == start && break
		limit -= 1
	end

	points
end
```

To support the interactivity, I also have some other related functions, see the attached
notebook.

(To be fair, the code above doesn't quite do the same thing as the original code in a
couple of ways, but it should still be straightforward to understand. There is also a huge
speed improvement, to the point that this can be done interactively.)

## Gaussian Prime Spirals
The cool part is what happens when we plot the walk for various complex numbers. To
verify the implementation against the original code, we'll use the same examples. First,
for $3 + 5i$,

\fig{spiral-3 + 5im.png}

The one that took a few minutes to plot:

\fig{spiral-127 + 130im.png}

The behavior honestly is very weird. A larger Gaussian prime doesn't necessarily mean a
longer period. Although a lot of these are symmetrical in some way, a lot aren't; for
example, $127+144i$ looks very not symmetrical (and is pretty short):

\fig{spiral-127 + 144im.png}

## Extra Code
The full Pluto notebook is
[here](https://github.com/tmthyln/notebooks/tree/master/LeftAtTheNextPrime)
for your perusal.

To determine the period of the cycle for a walk starting from some point:
```julia
function walklimit(start)
	limit = 1
	z = start
	delta = 1

	while true
		z = z + delta

		isgaussprime(z) && (delta *= im)
		z == start && break
		limit += 1
	end

	limit + 1
end
```

To determine the bounds of the cycle in order to draw a graph with the best range:
```julia
function walkbounds(start)
	min_real, max_real, min_imag, max_imag = real(start), real(start), imag(start), imag(start)
	z = start
	delta = 1

	while true
		z = z + delta

		min_real = min(min_real, real(z))
		max_real = max(max_real, real(z))
		min_imag = min(min_imag, imag(z))
		max_imag = max(max_imag, imag(z))

		isgaussprime(z) && (delta *= im)
		z == start && break
	end

	(min_real, max_real), (min_imag, max_imag)
end
```
