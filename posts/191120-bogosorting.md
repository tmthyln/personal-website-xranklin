@def title = "Analysis of BogoSelectionSort"
@def blogpost = true
@def tags = ["umd", "math", "cs"]
@def date = Date(2019, 11, 20)
@def rss = "An analysis of a bad (but not that bad) sorting algorithm."
@def desc = "An analysis of a bad (but not that bad) sorting algorithm."
@def hascode = true
@def sidetoc = true
@def lang = "java"

# From BogoSelectionSort to infinity and beyond!

\toc

A student in a class I TA for at UMD decided to make a variant of a BOGO sort that has selection sort-like properties. On Piazza, they asked what the runtime would be, guessing a median runtime of $O(n^2n!)$.
               
Here’s the code in Java (pretty much verbatim):

```java
public static ArrayList<Integer> bogoSelectionSort(ArrayList<Integer> list) {
    ArrayList<Integer> ans = new ArrayList<>();
    int size = list.size();

    for (int i = 0; i < size(); i++) {
        int min = list.get(0);

        for (int j = 0; j < list.size(); j++)
            for (list.get(j) < min)
                min = list.get(j);

        if (min == list.get(0)) {
            ans.add(min);
            list.remove(0);
        } else {
            Collections.shuffle(list);
            i--;
        }
    }
    return ans;
}
```

## Best-case analysis
Well, obviously, the best case happens when we very, very luckily always get the minimum to be the first element (or the input is already sorted). Approximately, 
 * the outer for loop runs proportional to $n = \mathtt{list.size()}$,
 * the inner loop will run in time proportional to $n$,
 * `list.remove(0)` will run in time proportional to $n$, and
 * `Collections.shuffle(list)` will run in time proportional to $n$.
Overall, best case is $O(n^2)$.

## Worst-case analysis
It could run forever. $O(\infty)$. (This is just as useful as the best-case analysis above.)

## Average-case analysis
To model the outer `for`-loop, we can describe it as a linear number of operations of the body. Even though we might repeat a step, we can model that as part of what's happening inside the loop. So we can model the complexity as
$$ T(n) = \sum_{i=0}^{n-1} \text{Inner}(i) $$

For the average-case, we care the expectation of the exact formula.
\begin{align}
    \mathbb{E}\big[ T(n) \big] &= \mathbb{E}\Bigg[ T(n) = \sum_{i=0}^{n-1} \text{Inner}(i) \Bigg] \\
    &= \sum_{i=0}^{n-1} \mathbb{E}\big[ \text{Inner}(i) \big] \reason{(linearity of expectation)}
\end{align}

### Expectation of $\text{Inner}(\cdot)$
First, we'll find a closed form for the inner function, given a particular iteration index `i`, and then find its expectation.

Note that so long as we continue to fail to get the minimum of the list in the right position, we do the same amount of work since the size of the list doesn't change. Once we succeed, the size of the list changes (and thus the amount of work done). At a high level,
$$ \text{Inner}(i, k) = k \cdot \text{work done per failure} + \text{work done on success} $$

So how much work is done for each failure (for a fixed `i`)? Regardless of success or failure, we look for the minimum of the remaining elements of the list, which takes time about $n-i$. On fail, the list is shuffled in time $n-i$. On success, the minimum is added to the result `ArrayList` and removed from the _front_ of the list taking time $n-1$. In both cases, we do $\approx 2(n-i)$ work.

\begin{align}
    \text{Inner}(i, k; n) &= k \cdot 2(n-i) + 2(n-i) \\
    &= 2(n-i)(k+1)
\end{align}

Now, finding the expectation of our function,

\begin{align}
    \mathbb{E}\big[ \text{Inner}(i, k; n) \big] &= \mathbb{E}\big[ 2(n-i)(k+1) \big] \\
    &= 2(n-i)\mathbb{E}\big[ k \big] + 2(n-i) \reason{(linearity of expectation)}
\end{align}

For a given iteration (at index `i`), how many failures do we expect before the first success? This is a classic application of a geometric distribution. We'll use the following definition:
$$ P(k; p) = p(1-p)^k \reason{with} \quad \mathbb{E}\big[ k \big] = \dfrac{1-p}{p} $$
where $p$ is the probability of success.

At iteration `i`, there are $n-i$ elements in the list, so we have a $\dfrac{1}{n-i}$ probability of getting the minimum in the  first position (given a proper, uniformly random shuffle and the list contains distinct elements). Now, we can calculate the expectation of $k$.

\begin{align}
    \mathbb{E}\big[ k \big] &= \dfrac{1-p}{p}\Big\vert_{p = \frac{1}{n-i}} \\
    &= \dfrac{1-\frac{1}{n-i}}{\frac{1}{n-i}} \\
    &= n - i - 1,
\end{align}

giving us an average of $n-i-1$ failures. Substituting into the full expectation,

\begin{align}
    \mathbb{E}\big[ T(n) \big] &= \sum_{i=0}^{n-1} \mathbb{E}\big[ \text{Inner}(i) \big] \\
    &= \sum_{i=0}^{n-1} 2(n-i)\mathbb{E}\big[ k \big] + 2(n-i) \\
    &= \sum_{i=0}^{n-1} 2(n-i)(n-i-1) + 2(n-i) \\
    &= 2 \sum_{i=0}^{n-1} (n-i)^2 \\
    &= 2 \sum_{i=1}^n i^2 \reason{(change of variables)} \\
    &= \dfrac{n(n+1)(2n+1)}{3} \reason{(sum of squares)} \\
    &\in O(n^3)
\end{align}

## Median-case analysis
Suppose we want to know the median instead of the average amount of work done? It would be really nice if we could just reuse the analysis from above but substitute the median of the geometric distribution: $\Bigg\lceil \dfrac{-1}{\lg(1-p)} \Bigg\rceil - 1$. However, there are some issues we should resolve first (which might make the analysis more complicated):

1. In general, there's no linearity of medians.
2. There's inconsistent notation for medians, so I'll use $\mu_{1/2}\big[\cdot\big]$ as a median operator.
3. Medians are discrete, not continuous like expectations. We'll have to bound the expression to make it useful. (See how the median of the geometric distribution contains a ceiling operation.)

### Linearity of medians (special case)
Although there's no linearity of medians in general, it does hold for the geometric distribution. Specifically, _monotonically decreasing distributions_ are closed under (positive) scalar multiplication and addition. For monotonically decreasing distributions $X$ and $Y$,
1. **Multiplication by a positive scalar.**  $\mu_{1/2}\big[ aX \big] = a\mu_{1/2}\big[X\big]$ where $a$ is a positive real. Scaling all values by the same amount doesn't change the relative order. If $a$ were allowed to be non-positive, then either $X$ would have no order (if $a=0$) or the order would be reversed (if $a < 0$).
2. **Addition of a scalar.** By similar logic, $\mu_{1/2}\big[ X + c \big] = \mu_{1/2}\big[X\big] + c$, where $c$ is any real. Relative order is preserved. 
3. **Addition.** Adding $X$ to $Y$ doesn't change the order of $Y$ (or vice versa). For $i < j$, it must be the case that $X_i + Y_i > X_j + Y_j$, since both $X_i > X_j$ and $Y_i > Y_j$.
So in this case, we _can_ apply linearity.

### Median of $\text{Inner}(\cdot)$
Because we now have linearity, we can start from the inner function from before.

\begin{align}
    \text{Inner}(i, k; n) &= 2(n-i)(k+1) \\
    \mu_{1/2}\big[ \text{Inner}(i, k; n) \big] &= \mu_{1/2}\big[ 2(n-i)(k+1) \big] \\
    &= 2(n-i)\Big( \mu_{1/2}\big[ k \big] \Big) \reason{(special case of linearity of medians)} \\
    &= 2(n-i)\Bigg\lceil \dfrac{-1}{\lg(1-p)} \Bigg\rceil \reason{(using the median of the geometric distribution)} \\
    &< 2(n-i)\Bigg( \dfrac{-1}{\lg(1-p)} + 1 \Bigg) \reason{(upper bound on the ceiling function)} \\
    &= 2(n-i)\Bigg( \dfrac{-1}{\lg(1-\frac{1}{n-i})} + 1 \Bigg)
\end{align}

Note that the function is ill-defined for $i = n - 1$ since we would need to evaluate $\lg(0)$. So we can evaluate what happens in the case separately. When $i = n - 1$, there is $n-(n-1) = 1$ element in the list. With only one element in the list, it must be in the first position, so we do $2(n-(n-1)) = 2$ steps of work. To be precise, the median of the function $\text{Inner}(i; n)$ is bounded (and can be approximated) by

$$ \mu_{1/2}\big[ \text{Inner}(i; n) \big] < \begin{cases} 2(n-i)\Bigg( \dfrac{-1}{\lg(1-\frac{1}{n-i})} + 1 \Bigg) & i < n - 1 \\ 2 & i = n - 1 \end{cases}$$

### Putting it all together
Coming back to the original problem, we want to find the median of our original definition of $T(n)$:

\begin{align}
    \mu_{1/2}\big[ T(n) \big] &= \mu_{1/2}\Big[ \sum_{i=0}^{n-1} \text{Inner}(i; n) \Big] \\
    &= \sum_{i=0}^{n-1} \mu_{1/2}\big[ \text{Inner}(i; n) \big] \reason{(special case of linearity of medians)} \\
    &= 2 + \sum_{i=0}^{n-2} \mu_{1/2} \big[ Inner(i; n) \big] \reason{(exclude problematic index)} \\
    &< 2 + 2 \sum_{i=0}^{n-2} (n-i)\Bigg( \dfrac{-1}{\lg\Big( 1 - \frac{1}{n-i} \Big)} + 1 \Bigg) \reason{(using upper bound on median)} \\
    &= 2 + 2 \sum_{i=2}^n i\Bigg( \dfrac{-1}{\lg\Big( 1 - \frac{1}{n-i} \Big)} + 1 \Bigg) \reason{(change of variables)} \\
    &= 2 + 2 \sum_{i=2}^n i + 2 \sum_{i=2}^n \dfrac{-1}{\lg\Big( 1 - \frac{1}{i} \Big)} \reason{(separate summation terms)} \\
    &= n(n+1) + 2 \sum_{i=2}^n \dfrac{-i}{\lg\Big( 1 - \frac{1}{i} \Big)} \reason{(Gauss's sum)}
\end{align}

Now, it's not easy to get $\dfrac{-i}{\lg\big( 1 - \frac{1}{i} \big)}$ into an explicit form, so we'll try bounding it with a polynomial. Let's guess $i^2$ as our upper bound.

\begin{align}
    \lim_{i\rightarrow\infty} \dfrac{i^2}{\dfrac{-i}{\lg\big( 1-\frac{1}{i} \big)}} &= \lim_{i\rightarrow\infty} \bigg( -i\lg\Big( 1-\frac{1}{i} \Big) \bigg) \\
    &= \lim_{i\rightarrow\infty} \dfrac{-\lg\big( 1-\frac{1}{i} \big)}{1/i} \reason{(rewrite into indeterminate form $\frac{0}{0}$)} \\
    &= \lim_{i\rightarrow\infty} \dfrac{-\Big( 1-\frac{1}{i} \Big)^{-1}/i^2}{-1/i^2} \reason{(l'Hôpital's Rule)} \\
    &= \lim_{i\rightarrow\infty} \dfrac{1}{1-\dfrac{1}{i}} \\
    &= 1
\end{align}

Since 1 is finite and nonzero, our "bad" function from above, $\dfrac{-i}{\lg\big( 1 - \frac{1}{i} \big)}$, can be bounded by a constant multiple of $i^2$, so long as we choose a big enough multiple. It turns out that $i^2$ is already big enough. For positive $i$, if we try to find the intersection points between the two functions:

\begin{align}
    i^2 &= \dfrac{-i}{\lg\big( 1-\frac{1}{i} \big)} \\
    \frac{-1}{i} &= \lg\big( 1 - \frac{1}{i} \big) \\
    x &= \lg(1 + x), \forall x < 0 \reason{(letting $x=\frac{-1}{i}$)} \\
    2^x &= x + 1
\end{align}
For negative $x$, there are no values that satisfy that equation, so there are also no intersection points between the two functions. Since 
$$ \dfrac{-i}{\lg\big( 1- \frac{1}{i} \big)}\Bigg\vert_{i=2} = 2 < 4 = i^2\Big\vert_{i=2}, $$
we have an upper bound. Going back to our median,

\begin{align}
    \mu_{1/2}\big[ T(n) \big] &= n(n+1) + 2 \sum_{i=2}^n \dfrac{-i}{\lg\big( 1-\frac{1}{i} \big)} \\
    &< n(n+1) + 2 \sum_{i=2}^n i^2 \\
    &= n(n+1) + \dfrac{n(n+1)(2n+1)}{3} \reason{(sum of squares)} \\
    &\in O(n^3)
\end{align}

So both the average and median cases result in the same estimate of a cubic algorithm.

## A worse sort?
So even though this sorting algorithm is naive and inefficient, it's not really all that inefficient. In fact, it's really only one simple step away from a typical quadratic sorting algorithm. How could we get something that is really inefficient? That's the question addressed in _How inefficient can a sort algorithm be?_[^1]. The paper describes a method to make an abitrarily inefficient sorting algorithm.

[^1]: **Miguel A. Lerma**. [_How inefficient can a sort algorithm be?_](https://arxiv.org/abs/1406.1077) June 5, 2014.
