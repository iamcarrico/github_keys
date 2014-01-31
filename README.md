GitHub Keys Ruby Script
-----------------------

Here is a simple little script that I am using to learn more ruby. The goal? To have this script be able to go to GitHub, get a users public keys, and store them in the ~/.ssh/authorized_keys.

## Security

One might say, "Couldn't this be a security issue? I mean, that would allow a user to change who can access the server!". Well, yes. Except for this script to be able to execute properly, you already have to have access to edit the authorized_keys file. This script doesn't actually alter what a user can do, just makes what they can do easier.

## To do list:

All the to do list is at [issue #1](https://github.com/ChinggizKhan/github_keys/issues/1)

## License

This software is licensed under the MIT license. Three cheers for open source.
