boxcutter
=========

Sets up up my mac.

Installation
------------

```sh
bash <(curl -s https://raw.githubusercontent.com/johnliu/boxcutter/master/bootstrap.sh)
```

This script will clone the setup directory to ~/Projects/johnliu. After cloning the setup directory,
it will open a new Terminal instance at ~/Projects/johnliu/boxcutter. Configure the machine's 
`defaults.yml` file and run `make`.

TODO
----

- [ ] Fix unknown developers thing.
- [ ] Fix become not working as expected.
- [ ] Separate out logic for running .macos script from syncing templates.
