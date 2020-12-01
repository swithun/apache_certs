# apache_certs

Scripts for generating CSR and installing certificates

There are two scripts in this repo. The first one, `generate.sh`, is
used to generate CSRs. It takes a single argument, which is the domain
for which you'd like to generate a CSR. If the domain has an optional
www. at the start, include this in the argument, and both (www. and no
www.) forms will be included.

For example, if you want to create a CSR to handle www.example.com and
example.com, use this command:

`./generate.sh www.example.com`

But if you have a subdomain which will not have a www. form, use this
command:

`./generate.sh sub.example.com`

The script will create a directory using the domain name and the
current year, e.g. www.example.com_2020. Inside this, you will fine:

- `./www.example.com_2020/www.example.com_2020.key`
- `./www.example.com_2020/www.example.com_2020.csr`

You will want to edit the SSL config lines within the script to suit
your institution.

Once you've used the CSR to obtain a ZIP of the the certificates (a
certificate for the domain, plus root and intermediate certificates),
use `install.sh` to help with the installation of these. Using the
example above, you could type:

`./install.sh www.example.com_2020/ example.zip`

This will generate the following files:

- `./www.example.com_2020/www.example.com_2020.crt`
- `./www.example.com_2020/www.example.com_2020.ca-bundle`

and you will have this one from having run `generate.sh`:

- `./www.example.com_2020/www.example.com_2020.key`

You can then copy these to the appropriate directory for Apache to use
them.

If you've generated the files on one machine, but you want to copy
them to other servers (e.g. a world-facing server and the one to which
it proxies requests), then you can add the names of the servers to the
`install.sh` command:

`./install.sh www.example.com_2020/ example.zip front back`

This will do the same as above, but also copy the files to the servers
`front` and `back`, installing them in Debian's default Apache SSL
directory and changing their permissions.

You will then need to edit Apache's config and reload Apache.