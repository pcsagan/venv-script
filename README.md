<p align="center">
  <img src="https://i.imgur.com/PHgnvJV.png" title="source venv.sh">
</p>

## What is it?

A simple bash shell script for dealing with the following typical situation:
```
python -m venv venv
source venv/scripts/activate
pip install -r requirements.txt
```

## Usage

The script is executed using the command `source venv.sh`

* `-h` show help message and exit
* `-d` install dependencies from requirements_dev.txt
* `-n` the name of the virtual environment directory
* `-r` recreate the virtual environment
* `-q` the script will generate no output

### Aliasing venv.sh

The script can be aliased with the bash command `alias venv="source venv.sh"`

The alias can be made permanent by adding it to your `.bashrc` file. To reference the script in your user directory use
```shell
alias venv="source ~/venv.sh"
```

Now the command `venv` can be used in place of `source venv.sh`

## Examples

The examples below show how to invoke the script, as well as how to do the equivalent work on the command line.

### Using the source command

`source venv.sh`
```
python -m venv venv
source venv/scripts/activate
pip install -r requirements.txt
```

`source venv.sh -n "testing" -d`
```
python -m venv testing
source testing/scripts/activate
pip install -r requirements_dev.txt
```

`source venv.sh -r -q`
```
rm -r venv
python -m venv venv
source venv/scripts/activate
pip install -r requirements.txt
```

### Using an alias

`venv`
```
python -m venv venv
source venv/scripts/activate
pip install -r requirements.txt
```


`venv -n "testing" -d -r`
```
rm -r testing
python -m venv testing
source testing/scripts/activate
pip install -r requirements_dev.txt
```

## Notes

1. Wherever possible the script will verify a file or directory exists before trying to use or delete it.
2. Due to how shell scripts process arguments the `-q` flag must come first to ensure complete silence.

## License

This project is licensed under the **MIT license**. Feel free to edit and distribute this template as you like.

See [LICENSE](LICENSE) for more information.
