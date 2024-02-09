*Yang An*

### Overall Grade: 117/130

### Quality of report: 10/10

-   Is the homework submitted (git tag time) before deadline? Take 10 pts off per day for late submission.
-   Is the final report in a human readable format html?
-   Is the report prepared as a dynamic document (Quarto) for better reproducibility?
-   Is the report clear (whole sentences, typos, grammar)? Do readers have a clear idea what's going on and how results are produced by just reading the report? Take some points off if the solutions are too succinct to grasp, or there are too many typos/grammar.

### Completeness, correctness and efficiency of solution: 75/80

-   Q1 (10/10)

    Is the GitHub.com repository name set up correctly? If using name other than `biostat-203b-2024-winter`, take 5 points off.

-   Q2 (20/20)

    If CITI training is not completed successfully, take 15 points off.

    If PhysioNet crecential is not complete, take 5 pts off.

-   Q3 (15/20)

    Q3.1, if the gz files are ever decompressed or copied in the solutions, take 5 points off.

    For Q3.5 and Q3.6, should skip the header when finiding the unique values of each variable. Take 5 points of if not done so.

    **3.5, 3.6 Header not removed**

-   Q4 (10/10)

    It's fine to just count the lines containing each name. If a student figures out a way to count the words (one line may contain the same name multiple times), give bonus points.

-   Q5 (10/10)

-   Q6 (10/10)

### Usage of Git: 10/10

-   Are branches (`main` and `develop`) correctly set up? Is the hw submission put into the `main` branch?
-   Are there enough commits (\>=5) in develop branch? Are commit messages clear? The commits should span out not clustered the day before deadline.
-   Is the hw1 submission tagged?
-   Are the folders (`hw1`, `hw2`, ...) created correctly?
-   Do not put a lot auxiliary files into version control.
-   If those gz data files or `pg42671` are in Git, take 5 points off.

### Reproducibility: 2/10

**All code chunks set to eval = False, could not render results**

-   Are the materials (files and instructions) submitted to the `main` branch sufficient for reproducing all the results? Just click the `Render` button will produce the final `html`?

-   If necessary, are there clear instructions, either in report or in a separate file, how to reproduce the results?

### R code style: 20/20

For bash commands, only enforce the 80-character rule. Take 2 pts off for each violation.

-   [Rule 2.5](https://style.tidyverse.org/syntax.html#long-lines) The maximum line length is 80 characters. Long URLs and strings are exceptions.

-   [Rule 2.4.1](https://style.tidyverse.org/syntax.html#indenting) When indenting your code, use two spaces.

-   [Rule 2.2.4](https://style.tidyverse.org/syntax.html#infix-operators) Place spaces around all infix operators (=, +, -, \<-, etc.).

-   [Rule 2.2.1.](https://style.tidyverse.org/syntax.html#commas) Do not place a space before a comma, but always place one after a comma.

-   [Rule 2.2.2](https://style.tidyverse.org/syntax.html#parentheses) Do not place spaces around code in parentheses or square brackets. Place a space before left parenthesis, except in a function call.
