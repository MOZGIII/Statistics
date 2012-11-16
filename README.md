# Statistics

This thing allows you to automatically generate some PDFs. Who knows what they came from, but some people find them useful.

## Installation

You need [Vagrant](http://vagrantup.com/) to use this.

On you host machine run `vagrant up`.

In the VM:

```shell
$ cd /vagrant
$ source vm_init.sh
```

The `source vm_init.sh` will run a prober script, which can work very long (~5-10 minutes) and fully automated, so you shall go and make a cup of tea.

## Usage

```shell
$ cd /vagrant
$ rake
```

Just use `rake`. It will tell you if you need something else.

That's it.
