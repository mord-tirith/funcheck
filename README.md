# funcheck
Function checker for 42 school projects

## Install
Simply run the Makefile and it'll install the files needed for the program as well as the alias funcheck.

## Use
`funcheck binary_file [list of allowed functions]`

The program compares which functions are used in the named binary file to the list of allowed functions.

For 42 School projects, so long as the file's name matches the mandatory name of the file to be handed in, funcheck should work without a given list.

E.g.:
`funcheck philo_bonus` will automatically use the list of allowed functions for the bonus version of the Philosophers project. However, if your binary is named something like `a.out`, you'll need to provide the list on your own.

### TODO list:

1 - finish adding projects of Milestone 5
2 - implement check for library projects instead of program projects (libft, ft_printf etc.)
