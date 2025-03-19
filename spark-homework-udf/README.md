# Homework: UDF Caching in Spark

In this assignment you'll implement UDF (user-defined function) result caching in [Apache Spark](http://spark.apache.org), which is a framework for distributed computing in the mold of MapReduce. This project will illustrate key concepts in data rendezvous and query evaluation, and you'll get some hands-on experience modifying Spark, which is widely used in the field. In addition, you'll get exposure to Scala, a JVM-based language that is gaining popularity for its clean functional style.

The assignment due date is published at the [class website](https://sites.google.com/site/cs143databasesystems/).

You can complete this **in pairs**, if you choose to. 
Lastly, there is a lot of code in this directory. Please look [here](https://github.com/ariyam/cs143_spark_hw/tree/master/sql) here to find the directory where the code is located.

## Assignment Goals

1. *Implement disk hash-partitioning*
2. *Implement in-memory UDF caching*
3. *Implement hash-partitioned UDF caching*

# Spark

Spark is an open-source distributed computing system written in [Scala](http://www.scala-lang.org). The project was started by Ph.D. students from the [AMPLab](https://amplab.cs.berkeley.edu) and is an integral part of the [Berkeley Data Analytics Stack](https://amplab.cs.berkeley.edu/software/) (BDAS—affectionately pronounced "bad-ass").

Like Hadoop MapReduce, Spark is designed to run functions over large collections of data, by supporting a simplified set of high-level data processing operations akin to the iterators we've been learning about in class. One of the most common uses of such systems is to implement parallel query processing in high level languages such as SQL. In fact, many recent research and development efforts in Spark have gone towards supporting a scalable and interactive relational database abstraction.

We'll be using, modifying, and studying aspects of Spark in this class to understand key concepts of modern data systems. More importantly you will see that the ideas we're covering in class -- some of which are decades old -- are still very relevant today. Specifically, we will be adding features to [Spark SQL](https://spark.apache.org/sql/).

One key limitation of Spark SQL is that it is currently a main-memory-only system.  As part of this class, we will extend it to include some out-of-core algorithms as well.

## Scala

Scala is a statically-typed language that supports many different programming paradigms. Its flexibility, power, and portability have become especially useful in distributed-systems research. 

Scala resembles Java, but it possesses a much broader set of syntax features to facilitate multiple paradigms. Knowing Java will help you understand some Scala code, but not much of it, and not knowing Scala will prevent you from fully taking advantage of its expressive power. Because you must write code in Scala, we strongly recommend you to acquire at least a passing familiarity with the language. 

[IntelliJ IDEA](https://www.jetbrains.com/idea/) tends to be the most commonly used IDE for developing in Spark. IntelliJ is a Java IDE that has a Scala (and vim!) plugin. There are also other options such as [Scala-IDE](http://scala-ide.org). 

You might find the following tutorials to be useful:
* [Twitter's Scala School](https://twitter.github.io/scala_school/)
* [Getting Started by Scala-Lang](http://www.scala-lang.org/documentation/getting-started.html)
* [A Scala Tutorial for Java Programmers](http://www.scala-lang.org/docu/files/ScalaTutorial.pdf)
* [TutorialsPoint's Scala Tutorial](http://www.tutorialspoint.com/scala/)

## Additional Reading for the Interested
* [Spark: Cluster Computing with Working Sets (HotCloud 2009)](https://amplab.cs.berkeley.edu/wp-content/uploads/2011/06/Spark-Cluster-Computing-with-Working-Sets.pdf)
* [Resilient Distributed Datasets: A Fault-Tolerant Abstraction for In-Memory Cluster Computing (NSDI 2012)](http://www.cs.berkeley.edu/~matei/papers/2012/nsdi_spark.pdf)
* [Shark: SQL and Rich Analytics at Scale (SIGMOD 2013)](http://www.cs.cmu.edu/~pavlo/courses/fall2013/static/papers/p13-xin.pdf)
* [Spark SQL: Relational Data Processing in Spark (SIGMOD 2015)](https://amplab.cs.berkeley.edu/wp-content/uploads/2015/03/SparkSQLSigmod2015.pdf) 

# Background and Framework

## UDFs (**U**ser **D**efined **F**unctions)

User-defined functions allow developers to define and exploit custom operations within expressions.  Imagine, for example, that you have a product catalog that includes photos of the product packaging.  You may want to register a user-defined function `extract_text` that calls an OCR algorithm and returns the text in an image, so that you can get queryable information out of the photos.  In SQL, you could imagine a query like this:
	
	SELECT P.name, P.manufacturer, P.price, extract_text(P.image), 
	  FROM Products P;
	 
The ability to register UDFs is very powerful -- it essentially turns your data processing framework into a general distributed computing framework.  But UDFs can often introduce performance bottlenecks, especially as we run them over millions of data items. 

If the input column(s) to a UDF contain a lot of duplicate values, it can be beneficial to improve performance by ensuring that the UDF is only called once per *distinct input value*, rather than once per *row*.  (For example in our Products example above, all the different configurations of a particular PC might have the same image.) In this assignment, we will implement this optimization.  We'll take it in stages -- first get it working for data that fits in memory, and then later for larger sets that require an out-of-core approach. We will use external hashing as the technique to "rendezvous" all the rows with the same input values for the UDF.

1. Implement disk-based hash partitioning.
1. Implement in-memory UDF caching.
1. Combine the above two techniques to implement out-of-core UDF caching.

If you're interested in the topic, the following paper will be an interesting read (including additional optimizations beyond what we have time for in this homework):

* [Query Execution Techniques for Caching Expensive Methods (SIGMOD 96)](http://db.cs.berkeley.edu/cs286/papers/caching-sigmod1996.pdf) 

## Project Framework

All the code you will be touching will be in three files -- `CS143Utils.scala`, `basicOperators.scala`, and `DiskHashedRelation.scala`. You might however need to consult other files within Spark or the general Scala APIs in order to complete the assignment thoroughly. Please make sure you look through *all* the provided code in the three files mentioned above before beginning to write your own code. There are a lot of useful functions in `CS143Utils.scala` as well as in `DiskHashedRelation.scala` that will save you a lot of time and cursing -- take advantage of them!

In general, we have defined most (if not all) of the methods that you will need. As before, in this project, you need to fill in the skeleton. The amount of code you will write is not very high -- the total staff solution is less than a 100 lines of code (not including tests). However, stringing together the right components in a memory-efficient way (i.e., not reading the whole relation into memory at once) will require some thought and careful planning.

## Some Terminology Differences

There are some potentially confusing differences between the terminology we use in class, and the terminology used in the SparkSQL code base:

* The "iterator" concept we learned in lecture is called a "node" in the SparkSQL code -- there are definitions in the code for UnaryNode and BinaryNode.  A query plan is called a SparkPlan, and in fact UnaryNode and BinaryNode extend SparkPlan (after all, a single iterator is a small query plan!)  You may want to find the file `SparkPlan.scala` in the SparkSQL source to see the API for these nodes.

* In some of the comments in SparkSQL, they also use the term "operator" to mean "node".  The file `basicOperators.scala` defines a number of specific nodes (e.g. Sort, Distinct, etc.).

* Don't confuse the [Scala interface `Iterator`](http://www.scala-lang.org/api/current/index.html#scala.collection.Iterator) with the iterator concept that we covered in lecture. The `Iterator` that you will be using in this project is a Scala language feature that you will use to implement your SparkSQL nodes.  `Iterator` provides an interface to Scala collections that enforces a specific API: the `next` and `hasNext` functions. 

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


