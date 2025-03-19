
# Setup


## `git` and GitHub

`git` is a *version control* system, helping you track different versions of your code, synchronize them across different machines, and collaborate with others. [GitHub](https://github.com) is a site which supports this system, hosting it as a service.

If you don't know much about `git`, we *strongly recommend* you to familiarize yourself with this system; you'll be spending a lot of time with it!
There are many guides to using `git` online - [here](http://git-scm.com/book/en/v1/Getting-Started) is a great one to read. 


## Setting up your repository and pulling the framework

You should first set up a remote **private** repository (e.g., spark-homework). Github gives private repository to students (but this may take some time). If you don't have a private repository, think TWICE about checking it in public repository, as it will be available for others to checheckout.

    $ cd ~

Clone your personal repository. It should be empty.

    $ git clone "https://github.com/xx/yy.git"

Enter the cloned repository, track the course repository and clone it.

    $ cd yy/
    $ git remote add course "https://github.com/UCLA-BDL/spark-homework.git"
    $ git pull course master

NOTE: Please do not be overwhelmed by the amount of code that is here. Spark is a big project with a lot of features. The code that we will be touching will be contained within one specific directory: sql/core/src/main/scala/org/apache/spark/sql/execution/. The tests will all be contained in sql/core/src/test/scala/org/apache/spark/sql/execution/

Push clone to your personal repository.

    $ git push origin master
    
Every time that you add some code, you can commit the modifications to the remote repository.

    $ git commit -m 'update to homework'
    $ git push origin master


### Receiving assignment updates

It may be necessary to receive updates to our assignment (even though we try to release them as "perfectly" as possible the first time). Assuming you set up the tracking correctly, you can simply run this following command to receive assignment updates:

    $ git pull course master


## Searching files in UNIX

The following UNIX command will come in handy, when you need to find the location of a file. Example- Find location of a file named 'DiskHashedRelation.scala' in my current repository.   

    $ find ./ -name 'DiskHashedRelation.scala' 


