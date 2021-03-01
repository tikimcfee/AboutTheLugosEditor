# So I want to reload things and be less lazy


Also, it sucks constantly rebuilding everything. So I got a heads up to try [this tool called "modd"](https://github.com/cortesi/modd), which watches your filesystem and then runs commands when a file in said system changes. So, this weird script snippit:

```shell script
[file: "modd.conf"]

**/*.go {
    prep: go test @dirmods
}
```

Given `go test @dirmods` is a `shell` command to run `go test` means:

```
For every file that ends in "go":
    do this and wait until it's done: go test @allTheDirectoriesThatChanged 
```

Get it? Good. Do this:

```shell script
$ brew install modd
```

Now you have `modd`. Let's test it with this stuff:

```shell script
$ mkdir ~/ImTestingModd && cd ~/ImTestingModd
$ touch modd.conf
$ touch testing.txt
```

We're going to make `modd` watch any `txt` files and do something when it notices it. Stick this in `modd.conf`,

```
*.txt { 
    prep: echo @mods
}
```

Now, if everything works and you run `modd` in the right directory, you'll see something like this:

```shell script
$ modd
14:23:38: prep: echo "./testing.txt"
./testing.txt
>> done (8.810929ms)
```

So that's a list of all the files that match `*.txt`. It's just so fancy. Now, run this in another shell in the same directory and watch the magic occur:

```shell script
$ echo "nowai" >> testing.txt
```

It's just so neat. Alright so now we can change files and do things when that happens. So what do we do?

Maybe we can make a new package target which is 'GenerateStuff', and that target has its own executable `main.swift` that imports some or all of the files we want to generate from, and then run it. We'll need to make some project and package changes to accomodate this. I started reading [the ultimate guide](https://fivestars.blog/code/ultimate-guide-swift-executables.html). This is truly a *fantastic* article. Whether or not they know it, the person or peoples writing this did the thing that I absolutely adore in technical reviews: giving a quick heads up on each and every term used, even if it's  a "standard" one or a "known" here.

There's certainly an expectation of core understaning here, but still, I found it incredible refreshing to see not just the terms of how the package system work, but also their direct usage and definitions. Made making changes super easy.

Ok, so if we're going to be making this simple and executable, we can start with the reorganizing the project itself. At some point, I'll do a before and after, but this is journal mode for now. At the moment, the structure looks like:

```
Sources
    App
        ServerCodez.swift
    Generators
        main.swift
    Run
        main.swift
    Stylesdata
        SharedData.swift
    Tests
        MoarTests
            AppTests.swift
```

So the idea here is the things you'll be generating from are dependencies for `App` and `Generators`; that means `StylesData` is just some swift files with its smallest set of dependencies (I'll put the links somewhere). So now that we've got these target setup, we can build and run the ones that have a `main.swift`.


