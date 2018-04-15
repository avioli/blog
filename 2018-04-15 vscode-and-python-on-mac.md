# VSCode and Python on Mac

Apparently Python development setup in [VSCode][code] on a Mac could be very
easy, but also very complex.

I've decided to run [pipenv][pipenv] as a package/environment manager, which
should be supported by [VSCode][code] out of the box. It is and it isn't.

Apparently something in the chain of detection uses [Click][click], which has
an issue when your `LC_ALL` and `LANG` are not set. In my case `LC_ALL` was
blank, and my `LANG` was set to `en_AU.utf-8`.

I had to add to my `~/.bash_profile`:

```
export LANG=en_AU.utf-8 # manually added, just to be sure
export LC_ALL=$LANG
```

Then once I restarted [VSCode][code] it found my [pipenv][pipenv] interpreter
and all was fine.

[code]: https://code.visualstudio.com
[pipenv]: https://docs.pipenv.org
[click]: http://click.pocoo.org/5/python3/

Tags: VSCode Python