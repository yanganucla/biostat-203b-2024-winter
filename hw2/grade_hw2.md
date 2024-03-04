*Yang An*

### Overall Grade: 166/180

### Quality of report: 10/10

-   Is the homework submitted (git tag time) before deadline? Take 10 pts off per day for late submission.  

-   Is the final report in a human readable format html? 

-   Is the report prepared as a dynamic document (Quarto) for better reproducibility?

-   Is the report clear (whole sentences, typos, grammar)? Do readers have a clear idea what's going on and how results are produced by just reading the report? Take some points off if the solutions are too succinct to grasp, or there are too many typos/grammar. 

### Completeness, correctness and efficiency of solution: 121/130

- Q1 (17/20)

  - Q1.1 Explain how the dataframes are different. (-2)
  
  - Q1.2 Change character variables to factor to decrease runtime and memory (-1)

- Q2 (75/80)

    - Q2.1 (10/10) Explain why read_csv cannot ingest labevents.csv.gz
    
    - Q2.2 (10/10) Explain why read_csv cannot ingest labevents.csv.gz
    
    - Q2.3 (13/15) The Bash code should be able to generate a file `labevents_filtered.csv.gz` (127MB). Check the numbers of rows and columns are correct.
    
      - Need to display your answers in the html file (-2)
    
    - Q2.4 (14/15)
    
      - Need to display your answers in the html file (-1)
    
    - Q2.5 (14/15)
    
      - Display (-1)
    
    - Q2.6 (14/15)
    
      - Display (-1)

- Q3 (29/30) Steps should be documented and reproducible. Check final number of rows and columns.

  - Display (-1)
	    
### Usage of Git: 9/10

-   Are branches (`main` and `develop`) correctly set up? Is the hw submission put into the `main` branch?

  - Not using develop branch (-1)

-   Are there enough commits (>=5) in develop branch? Are commit messages clear? The commits should span out not clustered the day before deadline. 
          
-   Is the hw1 submission tagged? 

-   Are the folders (`hw1`, `hw2`, ...) created correctly? 
  
-   Do not put a lot auxiliary files into version control. 

-   If those gz data files or `pg42671` are in Git, take 5 points off.

### Reproducibility: 8/10

-   Are the materials (files and instructions) submitted to the `main` branch sufficient for reproducing all the results? Just click the `Render` button will produce the final `html`?

  - Can't reproduce. Line 228 is your directory. (-2)

-   If necessary, are there clear instructions, either in report or in a separate file, how to reproduce the results?

### R code style: 18/20

For bash commands, only enforce the 80-character rule. Take 2 pts off for each violation. 

-   [Rule 2.5](https://style.tidyverse.org/syntax.html#long-lines) The maximum line length is 80 characters. Long URLs and strings are exceptions. 

  - Some violations (-2)

-   [Rule 2.4.1](https://style.tidyverse.org/syntax.html#indenting) When indenting your code, use two spaces.  

-   [Rule 2.2.4](https://style.tidyverse.org/syntax.html#infix-operators) Place spaces around all infix operators (=, +, -, &lt;-, etc.).  

-   [Rule 2.2.1.](https://style.tidyverse.org/syntax.html#commas) Do not place a space before a comma, but always place one after a comma.  

-   [Rule 2.2.2](https://style.tidyverse.org/syntax.html#parentheses) Do not place spaces around code in parentheses or square brackets. Place a space before left parenthesis, except in a function call.
